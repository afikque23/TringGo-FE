import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/location_point.dart';
import '../model/trip_model.dart';
import 'location_service.dart';
import 'background_tracking_handler.dart';

/// Service untuk mengelola tracking session (start, stop, calculate stats)
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final LocationService _locationService = LocationService();
  final BackgroundTrackingManager _backgroundManager =
      BackgroundTrackingManager();

  TripModel? _currentTrip;
  StreamSubscription<LocationPoint>? _locationSubscription;
  Timer? _durationTimer;

  final StreamController<TripModel> _tripController =
      StreamController<TripModel>.broadcast();

  Stream<TripModel> get tripStream => _tripController.stream;
  TripModel? get currentTrip => _currentTrip;
  bool get isTracking =>
      _currentTrip != null && _currentTrip!.status == 'active';

  /// Start tracking session baru dengan background support
  Future<bool> startTracking({required String motorcycleName}) async {
    if (isTracking) {
      print('⚠️ Tracking sudah aktif');
      return false;
    }

    try {
      print('🚀 Starting tracking for $motorcycleName...');

      // Initialize background manager
      await _backgroundManager.initialize();
      print('✅ Background manager initialized');

      // Get initial location
      print('📍 Getting initial location...');
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation == null) {
        print('❌ Tidak bisa mendapatkan lokasi awal');
        return false;
      }

      print(
        '✅ Initial location: lat=${currentLocation.latitude}, lng=${currentLocation.longitude}',
      );

      // Create new trip
      _currentTrip = TripModel.createNew(
        motorcycleName: motorcycleName,
        startPoint: currentLocation,
      );
      print('✅ Trip created with ID: ${_currentTrip!.id}');

      // Start location updates
      print('🛰️ Starting location updates...');
      final started = await _locationService.startLocationUpdates();
      if (!started) {
        print('❌ Failed to start location updates');
        _currentTrip = null;
        return false;
      }
      print('✅ Location updates started');

      // Listen to location updates
      _locationSubscription = _locationService.locationStream.listen(
        _onLocationUpdate,
        onError: (error) {
          print('Error in tracking: $error');
        },
      );

      // Start duration timer (update setiap detik)
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentTrip != null) {
          _currentTrip = _currentTrip!.copyWith(
            duration: _currentTrip!.duration + 1,
          );
          _tripController.add(_currentTrip!);

          // Update notification dengan stats terbaru
          _backgroundManager.updateStats(
            distance: _currentTrip!.totalDistance,
            duration: _currentTrip!.formattedDuration,
          );
        }
      });

      // Start background tracking (foreground service)
      final backgroundStarted = await _backgroundManager
          .startBackgroundTracking();
      if (!backgroundStarted) {
        print(
          'Warning: Background tracking tidak bisa dimulai, tracking akan berjalan di foreground only',
        );
      }

      // Listen to data from background
      _backgroundManager.listenToBackgroundData((data) {
        if (data['type'] == 'stopRequest') {
          // User pressed stop button in notification
          stopTracking();
        } else if (data['type'] == 'location') {
          // Handle location from background task
          // Already handled by location stream
        }
      });

      _tripController.add(_currentTrip!);
      return true;
    } catch (e) {
      print('Error starting tracking: $e');
      _currentTrip = null;
      return false;
    }
  }

  /// Handle setiap location update
  void _onLocationUpdate(LocationPoint newPoint) {
    if (_currentTrip == null) return;

    final points = List<LocationPoint>.from(_currentTrip!.points);

    if (points.isEmpty) {
      print('🎯 First location point added');
      points.add(newPoint);
      _currentTrip = _currentTrip!.copyWith(points: points);
      _tripController.add(_currentTrip!);
      return;
    }

    final lastPoint = points.last;

    // Calculate distance dari point terakhir
    final distance = _locationService.calculateDistance(
      lastPoint.latitude,
      lastPoint.longitude,
      newPoint.latitude,
      newPoint.longitude,
    );

    print(
      '📍 Distance from last point: ${(distance * 1000).toStringAsFixed(1)}m, '
      'Speed: ${(newPoint.speed * 3.6).toStringAsFixed(1)} km/h',
    );

    // Always update speed untuk real-time tracking
    final currentSpeedKmh = newPoint.speed * 3.6; // Convert m/s to km/h
    final newMaxSpeed = currentSpeedKmh > _currentTrip!.maxSpeed
        ? currentSpeedKmh
        : _currentTrip!.maxSpeed;

    // Hanya tambah point jika jarak cukup signifikan (> 1 meter) untuk avoid GPS jitter
    if (distance > 0.001) {
      points.add(newPoint);

      // Update total distance
      final newTotalDistance = _currentTrip!.totalDistance + distance;

      // Calculate average speed (distance / time)
      final newAverageSpeed = _currentTrip!.duration > 0
          ? (newTotalDistance / _currentTrip!.duration) * 3600
          : 0.0;

      print(
        '✅ Point added! Total distance: ${newTotalDistance.toStringAsFixed(3)} km, '
        'Avg speed: ${newAverageSpeed.toStringAsFixed(1)} km/h',
      );

      // Update trip
      _currentTrip = _currentTrip!.copyWith(
        points: points,
        totalDistance: newTotalDistance,
        averageSpeed: newAverageSpeed,
        maxSpeed: newMaxSpeed,
      );

      _tripController.add(_currentTrip!);
    } else {
      // Meskipun tidak tambah point, tetap update max speed
      if (newMaxSpeed > _currentTrip!.maxSpeed) {
        print('⚡ Max speed updated: ${newMaxSpeed.toStringAsFixed(1)} km/h');
        _currentTrip = _currentTrip!.copyWith(maxSpeed: newMaxSpeed);
        _tripController.add(_currentTrip!);
      }
    }
  }

  /// Stop tracking dan selesaikan trip
  Future<TripModel?> stopTracking() async {
    if (_currentTrip == null) return null;

    try {
      // Stop background tracking first
      await _backgroundManager.stopBackgroundTracking();
      _backgroundManager.stopListening();

      // Stop location updates
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _locationService.stopLocationUpdates();

      // Stop duration timer
      _durationTimer?.cancel();
      _durationTimer = null;

      // Finalize trip
      final completedTrip = _currentTrip!.copyWith(
        endTime: DateTime.now(),
        status: 'completed',
      );

      // Save trip (implementasi save ke storage/API nanti)
      await _saveTrip(completedTrip);

      _tripController.add(completedTrip);

      final tripToReturn = completedTrip;
      _currentTrip = null;

      return tripToReturn;
    } catch (e) {
      print('Error stopping tracking: $e');
      return null;
    }
  }

  /// Pause tracking (belum diimplementasi penuh)
  void pauseTracking() {
    _locationSubscription?.pause();
    _durationTimer?.cancel();
  }

  /// Resume tracking (belum diimplementasi penuh)
  void resumeTracking() {
    _locationSubscription?.resume();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTrip != null) {
        _currentTrip = _currentTrip!.copyWith(
          duration: _currentTrip!.duration + 1,
        );
        _tripController.add(_currentTrip!);
      }
    });
  }

  /// Cancel tracking tanpa save
  void cancelTracking() {
    _backgroundManager.stopBackgroundTracking();
    _backgroundManager.stopListening();
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _durationTimer?.cancel();
    _durationTimer = null;
    _locationService.stopLocationUpdates();
    _currentTrip = null;
  }

  /// Save trip ke storage (bisa local atau API)
  Future<void> _saveTrip(TripModel trip) async {
    try {
      print('💾 Saving trip...');
      final prefs = await SharedPreferences.getInstance();

      // Get existing trips
      final tripsJson = prefs.getStringList('trip_history') ?? [];

      // Add new trip at the beginning (latest first)
      tripsJson.insert(0, jsonEncode(trip.toJson()));

      // Keep only last 100 trips to avoid storage issues
      if (tripsJson.length > 100) {
        tripsJson.removeRange(100, tripsJson.length);
      }

      // Save back to storage
      await prefs.setStringList('trip_history', tripsJson);

      print('✅ Trip saved successfully! Total trips: ${tripsJson.length}');
      print('   Distance: ${trip.totalDistance.toStringAsFixed(2)} km');
      print('   Duration: ${trip.formattedDuration}');
      print('   Points: ${trip.points.length}');
    } catch (e) {
      print('❌ Error saving trip: $e');
    }
  }

  /// Get trip history dari storage
  Future<List<TripModel>> getTripHistory() async {
    try {
      print('📖 Loading trip history...');
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getStringList('trip_history') ?? [];

      print('✅ Found ${tripsJson.length} trips in storage');

      final trips = tripsJson
          .map((json) {
            try {
              return TripModel.fromJson(
                jsonDecode(json) as Map<String, dynamic>,
              );
            } catch (e) {
              print('⚠️ Error parsing trip: $e');
              return null;
            }
          })
          .whereType<TripModel>()
          .toList();

      print('✅ Successfully loaded ${trips.length} trips');
      return trips;
    } catch (e) {
      print('❌ Error loading trip history: $e');
      return [];
    }
  }

  /// Check apakah GPS dan permission siap
  Future<bool> checkGpsReady() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final hasPermission = await _locationService.checkAndRequestPermission();
    return hasPermission;
  }

  /// Open GPS settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings untuk permission
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Get current location info (tanpa start tracking)
  Future<LocationPoint?> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  /// Dispose resources
  void dispose() {
    cancelTracking();
    _backgroundManager.dispose();
    _tripController.close();
  }
}
