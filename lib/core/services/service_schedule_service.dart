import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_config.dart';
import '../model/service_schedule_model.dart';
import 'auth_service.dart';
import 'device_service.dart';

class ServiceScheduleService {
  // Singleton pattern
  static final ServiceScheduleService _instance =
      ServiceScheduleService._internal();
  factory ServiceScheduleService() => _instance;
  ServiceScheduleService._internal();

  final _authService = AuthService();
  final _deviceService = DeviceService();

  /// Get headers for API requests
  /// If authenticated: uses Authorization Bearer token
  /// If guest: uses X-Device-ID header
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    final token = await _authService.getToken();

    // Always include device id header if available. Some endpoints require
    // a device identifier even when the request is authenticated.
    final deviceId = await _deviceService.getDeviceId();
    if (deviceId.isNotEmpty) {
      headers['X-Device-ID'] = deviceId;
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get all service schedules
  /// Optional: Pass vehicleId to filter schedules for a specific vehicle
  Future<List<ServiceScheduleModel>> getAllSchedules({int? vehicleId}) async {
    try {
      final headers = await _getHeaders();

      var url = '${ApiConfig.baseUrl}/service-schedules';
      if (vehicleId != null) {
        url += '?vehicle_id=$vehicleId';
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING SERVICE SCHEDULES');
      print('URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Server response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        print('📊 Server returned ${data.length} schedules');

        final schedules = data.map((apiData) {
          // Transform API response to match our model structure
          final scheduleType = apiData['schedule_type'] ?? 'km';
          final transformedData = <String, dynamic>{
            'id': apiData['id'],
            'vehicle_id': apiData['vehicle_id'],
            'service_type_id': apiData['service_type']?['id'],
            'service_name':
                apiData['service_name'] ??
                apiData['service_type']?['name'] ??
                'Unknown Service',
            'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
            'interval_value': apiData['interval_value'] ?? 0,
            'last_service_mileage':
                apiData['start_odometer'] ?? apiData['last_service_mileage'],
            'last_service_date': apiData['last_service_date'],
            'next_service_mileage': apiData['target_km'],
            'next_service_date': apiData['target_date'],
            'reminder_threshold': apiData['reminder_option']?['id'],
            'reminder_enabled': apiData['is_active'] ?? true,
            'status': apiData['status'] ?? 'active',
            'notes': apiData['notes'],
            'created_at': apiData['created_at'],
            'updated_at': apiData['updated_at'],
          };
          return ServiceScheduleModel.fromJson(transformedData);
        }).toList();

        if (schedules.isNotEmpty) {
          print('Service schedules:');
          for (var s in schedules) {
            print(
              '  • ${s.serviceName} (ID: ${s.id}, VehicleID: ${s.vehicleId})',
            );
          }
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return schedules;
      } else {
        print('❌ Server returned error ${response.statusCode}');
        print('📄 Response: ${response.body}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to fetch schedules: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Get schedule by ID
  Future<ServiceScheduleModel> getScheduleById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-schedules/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final apiData = jsonData['data'];

        // Transform API response to match our model structure
        final scheduleType = apiData['schedule_type'] ?? 'km';
        final transformedData = <String, dynamic>{
          'id': apiData['id'],
          'vehicle_id': apiData['vehicle_id'],
          'service_type_id': apiData['service_type']?['id'],
          'service_name':
              apiData['service_name'] ??
              apiData['service_type']?['name'] ??
              'Unknown Service',
          'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
          'interval_value': apiData['interval_value'] ?? 0,
          'last_service_mileage':
              apiData['start_odometer'] ?? apiData['last_service_mileage'],
          'last_service_date': apiData['last_service_date'],
          'next_service_mileage': apiData['target_km'],
          'next_service_date': apiData['target_date'],
          'reminder_threshold': apiData['reminder_option']?['id'],
          'reminder_enabled': apiData['is_active'] ?? true,
          'status': apiData['status'] ?? 'active',
          'notes': apiData['notes'],
          'created_at': apiData['created_at'],
          'updated_at': apiData['updated_at'],
        };

        return ServiceScheduleModel.fromJson(transformedData);
      } else {
        throw Exception('Failed to load schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch schedule: $e');
      rethrow;
    }
  }

  /// Get schedule status by vehicle ID
  Future<Map<String, dynamic>> getScheduleStatus(int vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/service-schedules/status/$vehicleId',
            ),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? {};
      } else {
        throw Exception(
          'Failed to load schedule status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to fetch schedule status: $e');
      rethrow;
    }
  }

  /// Get primary vehicle schedules with real-time status evaluation
  /// This is the recommended endpoint for mobile apps
  /// Returns schedules sorted by priority (critical > warning > normal)
  Future<Map<String, dynamic>> getPrimaryVehicleSchedules() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-schedules/primary'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? {};
      } else {
        throw Exception(
          'Failed to load primary vehicle schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to fetch primary vehicle schedules: $e');
      rethrow;
    }
  }

  /// Create new service schedule
  Future<ServiceScheduleModel> createSchedule(
    ServiceScheduleModel schedule,
  ) async {
    try {
      final headers = await _getHeaders();

      // Build payload matching backend requirements
      // Backend expects schedule_type to be 'km' or 'time' (not 'mileage')
      final scheduleType = schedule.intervalType == 'mileage'
          ? 'km'
          : schedule.intervalType;

      final body = <String, dynamic>{
        'vehicle_id': schedule.vehicleId,
        'service_type_id': schedule.serviceTypeId ?? 1,
        'schedule_type': scheduleType, // 'km' or 'time'
        if (schedule.serviceName != null && schedule.serviceName!.isNotEmpty)
          'service_name': schedule.serviceName,
        if (schedule.notes != null && schedule.notes!.isNotEmpty)
          'notes': schedule.notes,
      };

      // Add schedule-type-specific fields
      if (scheduleType == 'km') {
        body['target_km'] =
            schedule.nextServiceMileage ?? schedule.intervalValue;
      } else if (scheduleType == 'time') {
        body['target_date'] = schedule.nextServiceDate != null
            ? schedule.nextServiceDate!.toIso8601String().split('T')[0]
            : DateTime.now()
                  .add(Duration(days: schedule.intervalValue))
                  .toIso8601String()
                  .split('T')[0];
      }

      // Add reminder option if provided
      if (schedule.reminderThreshold != null) {
        body['reminder_option_id'] = schedule.reminderThreshold;
      }

      // Debug logging
      print('=== CREATE SCHEDULE DEBUG ===');
      print('Endpoint: ${ApiConfig.baseUrl}/service-schedules');
      print('Vehicle ID: ${schedule.vehicleId}');
      print('Schedule Type: $scheduleType');
      print('Payload: ${json.encode(body)}');
      print('Headers: ${headers.keys.toList()}');
      print('============================');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/service-schedules'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final apiData = jsonData['data'];

        // Transform API response to match our model structure
        final scheduleType = apiData['schedule_type'] ?? 'km';
        final transformedData = <String, dynamic>{
          'id': apiData['id'],
          'vehicle_id': apiData['vehicle_id'],
          'service_type_id': apiData['service_type']?['id'],
          'service_name':
              apiData['service_name'] ??
              apiData['service_type']?['name'] ??
              'Unknown Service',
          'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
          'interval_value': apiData['interval_value'] ?? 0,
          'last_service_mileage':
              apiData['start_odometer'] ?? apiData['last_service_mileage'],
          'last_service_date': apiData['last_service_date'],
          'next_service_mileage': apiData['target_km'],
          'next_service_date': apiData['target_date'],
          'reminder_threshold': apiData['reminder_option']?['id'],
          'reminder_enabled': apiData['is_active'] ?? true,
          'status': apiData['status'] ?? 'active',
          'notes': apiData['notes'],
          'created_at': apiData['created_at'],
          'updated_at': apiData['updated_at'],
        };

        return ServiceScheduleModel.fromJson(transformedData);
      } else {
        throw Exception(
          'Failed to create schedule: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to create schedule: $e');
      rethrow;
    }
  }

  /// Update service schedule
  Future<ServiceScheduleModel> updateSchedule(
    int id,
    ServiceScheduleModel schedule,
  ) async {
    try {
      final headers = await _getHeaders();

      // Build payload matching backend requirements for update
      final scheduleType = schedule.intervalType == 'mileage'
          ? 'km'
          : schedule.intervalType;

      final body = <String, dynamic>{
        'service_type_id': schedule.serviceTypeId ?? 1,
        'schedule_type': scheduleType,
        if (schedule.serviceName != null && schedule.serviceName!.isNotEmpty)
          'service_name': schedule.serviceName,
        if (schedule.notes != null) 'notes': schedule.notes,
        'is_active': schedule.reminderEnabled ? 1 : 0,
      };

      // Add schedule-type-specific fields
      if (scheduleType == 'km') {
        body['target_km'] =
            schedule.nextServiceMileage ?? schedule.intervalValue;
      } else if (scheduleType == 'time' && schedule.nextServiceDate != null) {
        body['target_date'] = schedule.nextServiceDate!.toIso8601String().split(
          'T',
        )[0];
      }

      // Add reminder option if provided
      if (schedule.reminderThreshold != null) {
        body['reminder_option_id'] = schedule.reminderThreshold;
      }

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/service-schedules/$id'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final apiData = jsonData['data'];

        // Transform API response to match our model structure
        final scheduleType = apiData['schedule_type'] ?? 'km';
        final transformedData = <String, dynamic>{
          'id': apiData['id'],
          'vehicle_id': apiData['vehicle_id'],
          'service_type_id': apiData['service_type']?['id'],
          'service_name': apiData['service_type']?['name'],
          'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
          'interval_value':
              apiData['interval_value'] ??
              (scheduleType == 'km' ? apiData['target_km'] : 0),
          'last_service_mileage': apiData['start_odometer'],
          'last_service_date': apiData['last_service_date'],
          'next_service_mileage': apiData['target_km'],
          'next_service_date': apiData['target_date'],
          'reminder_threshold': apiData['reminder_option']?['id'],
          'reminder_enabled': apiData['is_active'] ?? true,
          'status': apiData['status'] ?? 'active',
          'notes': apiData['notes'],
          'created_at': apiData['created_at'],
          'updated_at': apiData['updated_at'],
        };

        return ServiceScheduleModel.fromJson(transformedData);
      } else {
        throw Exception(
          'Failed to update schedule: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to update schedule: $e');
      rethrow;
    }
  }

  /// Delete service schedule
  Future<void> deleteSchedule(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/service-schedules/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete schedule: $e');
      rethrow;
    }
  }
}
