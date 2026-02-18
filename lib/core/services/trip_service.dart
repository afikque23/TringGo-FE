import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_config.dart';
import '../model/trip_model.dart';
import 'auth_service.dart';
import 'device_service.dart';

/// Service untuk mengelola Trip API calls
class TripService {
  // Singleton pattern
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final _authService = AuthService();
  final _deviceService = DeviceService();

  /// Get headers for API requests
  /// If authenticated: uses Authorization Bearer token
  /// If guest: uses X-Device-ID header
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    final token = await _authService.getToken();

    if (token != null && token.isNotEmpty) {
      // Authenticated mode
      headers['Authorization'] = 'Bearer $token';
    } else {
      // Guest mode - use device ID
      final deviceId = await _deviceService.getDeviceId();
      headers['X-Device-ID'] = deviceId;
    }

    return headers;
  }

  /// Create/Save new trip to backend
  /// Returns the saved trip with server-generated ID
  Future<TripModel?> createTrip(TripModel trip) async {
    try {
      print('📤 Sending trip to backend...');
      final headers = await _getHeaders();

      // Prepare trip data for backend
      final tripData = {
        'vehicle_id':
            trip.motorcycleName, // You might want to pass actual vehicle ID
        'start_time': trip.startTime.toIso8601String(),
        'end_time': trip.endTime?.toIso8601String(),
        'total_distance': trip.totalDistance,
        'duration': trip.duration,
        'average_speed': trip.averageSpeed,
        'max_speed': trip.maxSpeed,
        'status': trip.status,
        'points': trip.points
            .map(
              (point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
                'speed': point.speed,
                'altitude': point.altitude,
                'accuracy': point.accuracy,
                'timestamp': point.timestamp.toIso8601String(),
              },
            )
            .toList(),
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.tripsUrl),
            headers: headers,
            body: json.encode(tripData),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Trip saved to backend successfully');
        final jsonData = json.decode(response.body);

        // If backend returns the trip object
        if (jsonData['data'] != null) {
          return TripModel.fromJson(jsonData['data']);
        }

        return trip; // Return original if backend doesn't return the object
      } else {
        print('❌ Failed to save trip: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Failed to save trip: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error saving trip to backend: $e');
      // Don't throw - just return null for offline handling
      return null;
    }
  }

  /// Get all trips from backend
  Future<List<TripModel>> getAllTrips({
    int? limit,
    int? offset,
    String? vehicleId,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (vehicleId != null) queryParams['vehicle_id'] = vehicleId;

      final uri = Uri.parse(
        ApiConfig.tripsUrl,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load trips: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error loading trips from backend: $e');
      return [];
    }
  }

  /// Get trip by ID from backend
  Future<TripModel?> getTripById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(ApiConfig.tripByIdUrl(id)), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          return TripModel.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting trip by ID: $e');
      return null;
    }
  }

  /// Delete trip from backend
  Future<bool> deleteTrip(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse(ApiConfig.tripByIdUrl(id)), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    }
  }

  /// Update vehicle odometer after trip
  /// This is called after finishing a trip to update the vehicle's odometer
  Future<bool> updateVehicleOdometer({
    required int vehicleId,
    required double newOdometer,
    String? notes,
  }) async {
    try {
      print('📤 Updating odometer to $newOdometer km...');
      final headers = await _getHeaders();

      final data = {'odometer': newOdometer, if (notes != null) 'notes': notes};

      final response = await http
          .put(
            Uri.parse(ApiConfig.updateOdometerUrl(vehicleId)),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        print('✅ Odometer updated successfully');
        return true;
      } else {
        print('❌ Failed to update odometer: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating odometer: $e');
      return false;
    }
  }

  /// Sync local trips to backend
  /// Useful for batch upload of offline trips
  Future<int> syncLocalTripsToBackend(List<TripModel> localTrips) async {
    int syncedCount = 0;

    for (var trip in localTrips) {
      final result = await createTrip(trip);
      if (result != null) {
        syncedCount++;
      }

      // Add small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('✅ Synced $syncedCount/${localTrips.length} trips to backend');
    return syncedCount;
  }

  /// Add manual distance to vehicle
  /// Creates a trip record without GPS points and updates vehicle odometer
  Future<Map<String, dynamic>?> addManualDistance({
    required int vehicleId,
    required double distanceKm,
    required DateTime tripDate,
    String? notes,
  }) async {
    try {
      print('📤 Adding manual distance: $distanceKm km to vehicle $vehicleId');
      final headers = await _getHeaders();

      final data = {
        'vehicle_id': vehicleId,
        'distance_km': distanceKm,
        'trip_date': tripDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/trips/manual-distance'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Manual distance added successfully');
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        print('❌ Failed to add manual distance: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Failed to add manual distance: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error adding manual distance: $e');
      return null;
    }
  }
}
