import 'dart:convert';
import '../network/api_config.dart';
import '../network/api_client.dart';
import '../model/service_schedule_model.dart';

class ServiceScheduleService {
  // Singleton pattern
  static final ServiceScheduleService _instance =
      ServiceScheduleService._internal();
  factory ServiceScheduleService() => _instance;
  ServiceScheduleService._internal();

  final _apiClient = ApiClient();

  /// Get all service schedules
  /// Optional: Pass vehicleId to filter schedules for a specific vehicle
  Future<List<ServiceScheduleModel>> getAllSchedules({int? vehicleId}) async {
    try {
      var endpoint = '/service-schedules';
      if (vehicleId != null) endpoint += '?vehicle_id=$vehicleId';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING SERVICE SCHEDULES');
      print('URL: ${ApiConfig.baseUrl}$endpoint');

      final response = await _apiClient
          .get(endpoint)
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
            'reminder_threshold': apiData['reminder_threshold'],
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
      final response = await _apiClient
          .get('/service-schedules/$id')
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
          'reminder_threshold': apiData['reminder_threshold'],
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
      final response = await _apiClient
          .get('/service-schedules/status/$vehicleId')
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
      final response = await _apiClient
          .get('/service-schedules/primary')
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
      // Build payload matching backend requirements
      // Backend expects schedule_type to be 'km' or 'time' (not 'mileage')
      final scheduleType = schedule.intervalType == 'mileage'
          ? 'km'
          : schedule.intervalType;

      final body = <String, dynamic>{
        'vehicle_id': schedule.vehicleId,
        'service_type_id': schedule.serviceTypeId ?? 1,
        'schedule_type': scheduleType, // 'km' or 'time'
        'interval_value': schedule.intervalValue, // Add interval_value
        // Don't send service_name - backend doesn't support this column
        // Backend will get it from service_type relationship
        if (schedule.notes != null && schedule.notes!.isNotEmpty)
          'notes': schedule.notes,
      };

      // Add schedule-type-specific fields
      if (scheduleType == 'km') {
        body['target_km'] =
            schedule.nextServiceMileage ?? schedule.intervalValue;
      } else if (scheduleType == 'time') {
        // Ensure target_date is always in the future (at least tomorrow)
        DateTime targetDate;
        if (schedule.nextServiceDate != null) {
          // User manually selected a date - use it directly
          targetDate = schedule.nextServiceDate!;
        } else {
          // No date selected - calculate from interval_value (in MONTHS)
          // Add interval months from now
          final now = DateTime.now();
          final monthsToAdd = schedule.intervalValue > 0
              ? schedule.intervalValue
              : 1;

          // Add months to current date
          targetDate = DateTime(now.year, now.month + monthsToAdd, now.day);

          // Handle edge case: if target date is today or in the past, add 1 more month
          if (!targetDate.isAfter(now)) {
            targetDate = DateTime(
              now.year,
              now.month + monthsToAdd + 1,
              now.day,
            );
          }
        }

        body['target_date'] = targetDate.toIso8601String().split('T')[0];
      }

      // Add custom reminder threshold if provided
      if (schedule.reminderThreshold != null) {
        body['reminder_threshold'] = schedule.reminderThreshold;
        // Temporary workaround: Send null for reminder_option_id when using custom threshold
        // Backend should make reminder_option_id nullable in the migration
        body['reminder_option_id'] = null;
      } else {
        // If no custom reminder, also ensure reminder_option_id is null
        body['reminder_option_id'] = null;
      }

      // Debug logging
      print('=== CREATE SCHEDULE DEBUG ===');
      print('Endpoint: ${ApiConfig.baseUrl}/service-schedules');
      print('Vehicle ID: ${schedule.vehicleId}');
      print('Schedule Type: $scheduleType');
      print('Payload: ${json.encode(body)}');
      print('============================');

      final response = await _apiClient
          .post('/service-schedules', body: body)
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
              schedule.serviceName ??
              'Unknown Service',
          'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
          'interval_value': apiData['interval_value'] ?? schedule.intervalValue,
          'last_service_mileage':
              apiData['start_odometer'] ?? apiData['last_service_mileage'],
          'last_service_date': apiData['last_service_date'],
          'next_service_mileage': apiData['target_km'],
          'next_service_date': apiData['target_date'],
          'reminder_threshold': apiData['reminder_threshold'],
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
      // Build payload matching backend requirements for update
      final scheduleType = schedule.intervalType == 'mileage'
          ? 'km'
          : schedule.intervalType;

      final body = <String, dynamic>{
        'service_type_id': schedule.serviceTypeId ?? 1,
        'schedule_type': scheduleType,
        'interval_value': schedule.intervalValue, // Add interval_value
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

      // Add custom reminder threshold if provided
      if (schedule.reminderThreshold != null) {
        body['reminder_threshold'] = schedule.reminderThreshold;
        // Temporary workaround: Send null for reminder_option_id when using custom threshold
        // Backend should make reminder_option_id nullable in the migration
        body['reminder_option_id'] = null;
      } else {
        // If no custom reminder, also ensure reminder_option_id is null
        body['reminder_option_id'] = null;
      }

      final response = await _apiClient
          .put('/service-schedules/$id', body: body)
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
              apiData['service_type']?['name'] ?? schedule.serviceName,
          'interval_type': scheduleType == 'km' ? 'mileage' : 'time',
          'interval_value': apiData['interval_value'] ?? schedule.intervalValue,
          'last_service_mileage': apiData['start_odometer'],
          'last_service_date': apiData['last_service_date'],
          'next_service_mileage': apiData['target_km'],
          'next_service_date': apiData['target_date'],
          'reminder_threshold': apiData['reminder_threshold'],
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
      final response = await _apiClient
          .delete('/service-schedules/$id')
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete schedule: $e');
      rethrow;
    }
  }

  /// Check reminders for a vehicle based on current odometer
  /// Triggers notifications for schedules that reached their reminder threshold
  Future<Map<String, dynamic>> checkReminders(
    int vehicleId,
    int currentOdometer,
  ) async {
    try {
      final body = {'current_odometer': currentOdometer};

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔔 CHECKING SERVICE REMINDERS');
      print('Vehicle ID: $vehicleId');
      print('Current Odometer: $currentOdometer km');

      final response = await _apiClient
          .post('/service-schedules/check-reminders/$vehicleId', body: body)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] ?? {};

        final remindersTriggered = data['reminders_triggered'] ?? 0;
        final reminders = data['reminders'] ?? [];

        if (remindersTriggered > 0) {
          print('⚠️ Reminders triggered: $remindersTriggered');
          for (var reminder in reminders) {
            print('  • ${reminder['service_type']}: ${reminder['message']}');
          }
        } else {
          print('✅ No reminders triggered');
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return data;
      } else {
        print('❌ Failed to check reminders: ${response.statusCode}');
        print('Response: ${response.body}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Failed to check reminders: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking reminders: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Reset reminder flag for a schedule
  /// Call this after updating a schedule with new target to re-enable reminders
  Future<void> resetReminder(int scheduleId) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 RESETTING REMINDER FLAG');
      print('Schedule ID: $scheduleId');

      final response = await _apiClient
          .post('/service-schedules/$scheduleId/reset-reminder')
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Reminder flag reset successfully');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      } else {
        print('❌ Failed to reset reminder: ${response.statusCode}');
        print('Response: ${response.body}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Failed to reset reminder: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error resetting reminder: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }
}
