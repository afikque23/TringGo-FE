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
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/service-histories'),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Backend returns data.service_histories array
        final List<dynamic> data = jsonData['data']?['service_histories'] ?? [];
        return data.map((json) => ServiceHistoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load histories: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch histories: $e');
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
        return ServiceHistoryModel.fromJson(jsonData['data']);
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
        // Backend returns data.summary object
        return jsonData['data']?['summary'] ?? {};
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
      // Build payload to match backend expected field names.
      // Backend gets vehicle from session (primary vehicle), not from payload
      final body = <String, dynamic>{
        // Backend expects 'service_type' and 'performed_at' keys
        'service_type': history.serviceName,
        'performed_at': history.serviceDate.toIso8601String(),
        'odometer': history.mileage,
        'cost': history.cost,
        if (history.currency != null) 'currency': history.currency,
        if (history.workshopName != null)
          'service_provider': history.workshopName,
        if (history.notes != null) 'notes': history.notes,
        if (history.receiptImage != null) 'receipt_url': history.receiptImage,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/service-histories'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ServiceHistoryModel.fromJson(jsonData['data']);
      } else {
        throw Exception(
          'Failed to create history: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Failed to create history: $e');
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
      // Build payload aligned to backend field names for update as well.
      final body = <String, dynamic>{
        'service_type': history.serviceName,
        'performed_at': history.serviceDate.toIso8601String(),
        'odometer': history.mileage,
        'cost': history.cost,
        if (history.currency != null) 'currency': history.currency,
        if (history.workshopName != null)
          'service_provider': history.workshopName,
        if (history.notes != null) 'notes': history.notes,
        if (history.receiptImage != null) 'receipt_url': history.receiptImage,
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
        return ServiceHistoryModel.fromJson(jsonData['data']);
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
