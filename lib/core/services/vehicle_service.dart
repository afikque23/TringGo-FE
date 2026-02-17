import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_config.dart';
import '../model/vehicle_model.dart';
import 'auth_service.dart';
import 'device_service.dart';
import 'local_vehicle_storage.dart';

class VehicleService {
  // Singleton pattern
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal();

  final _authService = AuthService();
  final _deviceService = DeviceService();
  final _localStorage = LocalVehicleStorage();

  /// Check if user is logged in
  Future<bool> _isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  /// Get headers for API requests
  /// If authenticated: uses Authorization Bearer token
  /// If guest: uses X-Device-ID header
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    final token = await _authService.getToken();

    if (token != null && token.isNotEmpty) {
      // Authenticated mode
      headers['Authorization'] = 'Bearer $token';
      print(
        '🔐 Auth mode: AUTHENTICATED (token: ${token.substring(0, 20)}...)',
      );
    } else {
      // Guest mode - use device ID
      final deviceId = await _deviceService.getDeviceId();
      headers['X-Device-ID'] = deviceId;
      print('👤 Auth mode: GUEST (device: $deviceId)');
    }

    return headers;
  }

  /// Sanitize headers for logging (hide sensitive data)
  String _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      final token = sanitized['Authorization']!;
      sanitized['Authorization'] = '${token.substring(0, 20)}...';
    }
    return sanitized.toString();
  }

  /// Debug: Print current auth status
  Future<void> debugPrintAuthInfo() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 CURRENT AUTH STATUS');

    final isLoggedIn = await _isLoggedIn();
    print('Logged in: $isLoggedIn');

    final token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      print('Token: ${token.substring(0, 30)}...');
      print('Token length: ${token.length}');
    } else {
      print('Token: null/empty');
    }

    final userId = await _authService.getUserId();
    print('User ID: $userId');

    final deviceId = await _deviceService.getDeviceId();
    print('Device ID: $deviceId');

    final localVehicles = await _localStorage.getAllVehicles();
    print('Local vehicles count: ${localVehicles.length}');
    if (localVehicles.isNotEmpty) {
      print('Local vehicles:');
      for (var v in localVehicles) {
        print(
          '  • ${v.title} (ID: ${v.id}, UserID: ${v.userId}, Primary: ${v.isPrimary})',
        );
      }
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Get all vehicles (server-first, fallback to local if offline)
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      // Always try server first (works for both authenticated and guest mode)
      final headers = await _getHeaders();
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING VEHICLES FROM SERVER');
      print('URL: ${ApiConfig.baseUrl}/vehicles');
      print('Headers: ${_sanitizeHeaders(headers)}');

      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/vehicles'), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Server response: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        final serverVehicles = data
            .map((json) => VehicleModel.fromJson(json))
            .toList();

        print('📊 Server returned ${serverVehicles.length} vehicles');

        // Check if server returned empty data
        if (serverVehicles.isEmpty) {
          print('⚠️ Server returned EMPTY array!');

          // Get local vehicles to check if we have data locally
          final localVehicles = await _localStorage.getAllVehicles();
          print('📦 Local storage has ${localVehicles.length} vehicles');

          if (localVehicles.isNotEmpty) {
            // Server returned empty but we have local data
            // This might indicate auth/sync issue - keep local data as safeguard
            print('🛡️ PROTECTING LOCAL DATA!');
            print(
              '⚠️ Server returned empty but local storage has ${localVehicles.length} vehicles',
            );
            print('⚠️ This may indicate:');
            print('   • Token expired or invalid');
            print('   • Device ID changed/mismatch');
            print('   • User ID mismatch');
            print('   • Server filtering/permission issue');
            print('✅ Using local data instead of syncing empty array');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            return localVehicles;
          } else {
            print('❌ Both server AND local storage are empty!');
            print('💡 Possible causes:');
            print('   • New user - no vehicles added yet');
            print('   • Auth failed - showing empty for wrong user');
            print('✅ Sync completed');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('   • Data was deleted from both server and local');
          }
        }

        // Update local storage with server data (only if not empty or both are empty)
        print('💾 Syncing ${serverVehicles.length} vehicles to local storage');
        await _localStorage.clearAllVehicles();
        for (var vehicle in serverVehicles) {
          await _localStorage.addVehicle(vehicle);
        }

        return serverVehicles;
      } else {
        // Include response body for easier debugging of 4xx/5xx errors
        print(
          '❌ Server returned error ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Failed to load vehicles: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Failed to fetch from server: $e');
      final localVehicles = await _localStorage.getAllVehicles();
      print(
        '📦 Fallback: Using ${localVehicles.length} vehicles from local storage',
      );
      // Fallback to local storage if server request fails
      return localVehicles;
    }
  }

  /// Get primary vehicle (server-first, fallback to local)
  Future<VehicleModel?> getPrimaryVehicle() async {
    try {
      final headers = await _getHeaders();
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING PRIMARY VEHICLE');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/primary'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Primary vehicle response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          final vehicle = VehicleModel.fromJson(jsonData['data']);
          print('✓ Primary vehicle from server:');
          print('   • Name: ${vehicle.title}');
          print('   • ID: ${vehicle.id}');
          print('   • User ID: ${vehicle.userId}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return vehicle;
        } else {
          print('⚠️ Server returned 200 but data is null');
        }
      } else if (response.statusCode == 404) {
        print('❌ Server returned 404: No primary vehicle found on server');
        print('📄 Response: ${response.body}');
      } else {
        print('❌ Server returned error ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Failed to get primary from server: $e');
    }

    // Fallback to local storage
    final localPrimary = await _localStorage.getPrimaryVehicle();
    if (localPrimary != null) {
      print('📦 Fallback: Using primary vehicle from local:');
      print('   • Name: ${localPrimary.title}');
      print('   • ID: ${localPrimary.id}');
      print('   • User ID: ${localPrimary.userId}');
    } else {
      print('❌ No primary vehicle in local storage either!');
      print('💡 User needs to add a vehicle first');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return localPrimary;
  }

  /// Get vehicle by ID (local-first)
  Future<VehicleModel?> getVehicleById(int id) async {
    final vehicles = await _localStorage.getAllVehicles();
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new vehicle (server-first, fallback to local)
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/vehicles'),
            headers: headers,
            body: json.encode(vehicle.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final serverVehicle = VehicleModel.fromJson(jsonData['data']);
        // Save to local storage as backup
        await _localStorage.addVehicle(serverVehicle);
        return serverVehicle;
      } else {
        throw Exception(
          'Failed to create vehicle: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to create vehicle on server: $e');
      // Fallback: save locally only
      final savedVehicle = await _localStorage.addVehicle(vehicle);
      return savedVehicle;
    }
  }

  /// Update vehicle (server-first, fallback to local)
  Future<VehicleModel> updateVehicle(int id, VehicleModel vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/$id'),
            headers: headers,
            body: json.encode(vehicle.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final serverVehicle = VehicleModel.fromJson(jsonData['data']);
        // Update local storage
        await _localStorage.updateVehicle(id, serverVehicle);
        return serverVehicle;
      } else {
        throw Exception(
          'Failed to update vehicle: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to update vehicle on server: $e');
      // Fallback: update locally only
      final updated = await _localStorage.updateVehicle(id, vehicle);
      if (updated == null) {
        throw Exception('Vehicle not found');
      }
      return updated;
    }
  }

  /// Delete vehicle (server-first, fallback to local)
  Future<void> deleteVehicle(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully deleted on server, now delete locally
        await _localStorage.deleteVehicle(id);
      } else {
        throw Exception('Failed to delete vehicle: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete vehicle on server: $e');
      // Fallback: delete locally only
      await _localStorage.deleteVehicle(id);
    }
  }

  /// Set vehicle as primary (server-first, fallback to local)
  Future<VehicleModel> setPrimaryVehicle(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/$id/set-primary'),
            headers: headers,
            body: json.encode({}), // Empty body for POST request
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final serverVehicle = VehicleModel.fromJson(jsonData['data']);
        // Update local storage
        await _localStorage.setPrimaryVehicle(id);
        return serverVehicle;
      } else {
        // Include response body to reveal validation errors from server
        throw Exception(
          'Failed to set primary vehicle: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to set primary on server: $e');
      // Fallback: set locally only
      final updated = await _localStorage.setPrimaryVehicle(id);
      if (updated == null) {
        throw Exception('Vehicle not found');
      }
      return updated;
    }
  }

  /// Get service metrics (distance since last service, until next service)
  Future<Map<String, dynamic>> getServiceMetrics() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/primary/service-metrics'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? {};
      } else {
        throw Exception(
          'Failed to get service metrics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to fetch service metrics: $e');
      return {
        'current_odometer': 0,
        'distance_since_service': 0,
        'distance_until_next_service': 0,
      };
    }
  }

  /// Get usage pattern statistics
  Future<Map<String, dynamic>> getUsagePattern() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/primary/usage-pattern'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? {};
      } else {
        throw Exception('Failed to get usage pattern: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch usage pattern: $e');
      return {
        'average_km_per_day': 0.0,
        'weekly_km': 0.0,
        'monthly_km': 0.0,
        'usage_intensity': 'light',
        'odometer': 0,
      };
    }
  }
}
