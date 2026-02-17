import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_config.dart';
import '../model/service_history_model.dart';
import 'auth_service.dart';
import 'device_service.dart';

class ServiceHistoryService {
  // Singleton pattern
  static final ServiceHistoryService _instance =
      ServiceHistoryService._internal();
  factory ServiceHistoryService() => _instance;
  ServiceHistoryService._internal();

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

  /// Get all service histories
  Future<List<ServiceHistoryModel>> getAllHistories() async {
    try {
      final headers = await _getHeaders();
      print(
        '🔍 Fetching service histories from: ${ApiConfig.baseUrl}/service-histories',
      );
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-histories'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Service histories response status: ${response.statusCode}');
      print('📄 Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Parsed JSON: $jsonData');
        final data = jsonData['data'];
        print('📊 Data field type: ${data.runtimeType}');
        print('📊 Data field value: $data');

        // API returns nested structure: {data: {service_histories: [...]}}
        if (data is Map<String, dynamic> &&
            data.containsKey('service_histories')) {
          final histories = data['service_histories'];
          if (histories is List) {
            print('✅ Found ${histories.length} service histories');
            return histories
                .map((json) => ServiceHistoryModel.fromJson(json))
                .toList();
          }
        }
        // Fallback: check if data itself is a List (for backwards compatibility)
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          return data
              .map((json) => ServiceHistoryModel.fromJson(json))
              .toList();
        }
        print('⚠️ No service histories found, returning empty array');
        return [];
      } else {
        throw Exception('Failed to load histories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to fetch histories: $e');
      rethrow;
    }
  }

  /// Get history by ID
  Future<ServiceHistoryModel> getHistoryById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-histories/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        // Handle nested structure: {data: {service_history: {...}}}
        if (data is Map<String, dynamic> &&
            data.containsKey('service_history')) {
          return ServiceHistoryModel.fromJson(data['service_history']);
        }
        // Fallback: data might be the object directly
        return ServiceHistoryModel.fromJson(data);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch history: $e');
      rethrow;
    }
  }

  /// Get cost summary
  Future<Map<String, dynamic>> getCostSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-histories/cost-summary'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? {};
      } else {
        throw Exception('Failed to load cost summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch cost summary: $e');
      rethrow;
    }
  }

  /// Create new service history
  Future<ServiceHistoryModel> createHistory(ServiceHistoryModel history) async {
    try {
      final headers = await _getHeaders();
      // Build payload to match actual backend API fields (from working Postman request)
      // Backend gets vehicle from session (primary vehicle), not from payload
      final body = <String, dynamic>{
        'service_type': history.serviceName,
        'performed_at': history.serviceDate
            .toIso8601String()
            .split('T')
            .first, // YYYY-MM-DD format
        if (history.odometer != null) 'odometer': history.odometer,
        if (history.cost != null) 'cost': history.cost,
        'currency': history.currency ?? 'IDR',
        if (history.serviceProvider != null)
          'service_provider': history.serviceProvider,
        if (history.notes != null) 'notes': history.notes,
        if (history.receiptUrl != null) 'receipt_photo': history.receiptUrl,
      };

      print('📤 Creating service history with body: $body');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/service-histories'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Create response status: ${response.statusCode}');
      print('📄 Create response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Service history created successfully');
        // API returns nested structure: {data: {service_history: {...}}}
        final data = jsonData['data'];
        if (data is Map<String, dynamic> &&
            data.containsKey('service_history')) {
          return ServiceHistoryModel.fromJson(data['service_history']);
        }
        // Fallback: data might be the object directly
        return ServiceHistoryModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to create history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Failed to create history: $e');
      rethrow;
    }
  }

  /// Update service history
  Future<ServiceHistoryModel> updateHistory(
    int id,
    ServiceHistoryModel history,
  ) async {
    try {
      final headers = await _getHeaders();
      // Build payload to match actual backend API fields
      final body = <String, dynamic>{
        'service_type': history.serviceName,
        'performed_at': history.serviceDate
            .toIso8601String()
            .split('T')
            .first, // YYYY-MM-DD format
        if (history.odometer != null) 'odometer': history.odometer,
        if (history.cost != null) 'cost': history.cost,
        'currency': history.currency ?? 'IDR',
        if (history.serviceProvider != null)
          'service_provider': history.serviceProvider,
        if (history.notes != null) 'notes': history.notes,
        if (history.receiptUrl != null) 'receipt_photo': history.receiptUrl,
      };

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/service-histories/$id'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        // Handle nested structure: {data: {service_history: {...}}}
        if (data is Map<String, dynamic> &&
            data.containsKey('service_history')) {
          return ServiceHistoryModel.fromJson(data['service_history']);
        }
        // Fallback: data might be the object directly
        return ServiceHistoryModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to update history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to update history: $e');
      rethrow;
    }
  }

  /// Delete service history
  Future<void> deleteHistory(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/service-histories/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete history: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete history: $e');
      rethrow;
    }
  }
}
