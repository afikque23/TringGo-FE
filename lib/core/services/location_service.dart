import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../model/location_point.dart';

/// Service untuk mengelola GPS dan location tracking
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<LocationPoint> _locationController =
      StreamController<LocationPoint>.broadcast();

  Stream<LocationPoint> get locationStream => _locationController.stream;
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Check apakah GPS service sudah aktif di device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check dan request location permission
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, user harus buka settings
      return false;
    }

    return true;
  }

  /// Get current position sekali
  Future<LocationPoint?> getCurrentLocation() async {
    try {
      // Check permission
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      // Check GPS service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      return _positionToLocationPoint(position);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start listening untuk location updates
  Future<bool> startLocationUpdates() async {
    if (_isTracking) return true;

    try {
      // Check permission
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return false;
      }

      // Check GPS service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location service not enabled');
        return false;
      }

      print('Starting location updates with high accuracy...');

      // Settings untuk tracking - optimized untuk berkendara
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy
            .bestForNavigation, // Best accuracy untuk navigation
        distanceFilter: 1, // Update setiap 1 meter untuk lebih responsif
        // Tidak pakai timeLimit agar tracking continuous
      );

      // Start streaming
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              print(
                '📍 Location update: lat=${position.latitude}, lng=${position.longitude}, '
                'speed=${position.speed.toStringAsFixed(2)} m/s, accuracy=${position.accuracy.toStringAsFixed(1)}m',
              );
              final locationPoint = _positionToLocationPoint(position);
              _locationController.add(locationPoint);
            },
            onError: (error) {
              print('❌ Error in location stream: $error');
            },
          );

      _isTracking = true;
      print('✅ Location tracking started successfully');
      return true;
    } catch (e) {
      print('❌ Error starting location updates: $e');
      return false;
    }
  }

  /// Stop listening untuk location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
  }

  /// Calculate distance between two points (in kilometers)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Menggunakan formula Haversine dari Geolocator
    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000; // Convert ke kilometer
  }

  /// Convert Position dari Geolocator ke LocationPoint model
  LocationPoint _positionToLocationPoint(Position position) {
    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed, // dalam m/s
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  /// Open location settings di device
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (untuk permission)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Dispose resources
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }

  /// Get last known position (cached)
  Future<LocationPoint?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return _positionToLocationPoint(position);
      }
      return null;
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate speed in km/h from m/s
  double speedToKmh(double speedInMs) {
    return speedInMs * 3.6;
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}
