import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../network/api_config.dart';
import '../network/api_client.dart';
import '../model/service_history_model.dart';
import 'auth_storage.dart';

class ServiceHistoryService {
  // Singleton pattern
  static final ServiceHistoryService _instance =
      ServiceHistoryService._internal();
  factory ServiceHistoryService() => _instance;
  ServiceHistoryService._internal();

  final _authStorage = AuthStorage();
  final _apiClient = ApiClient();

  /// Send multipart request with automatic token refresh on 401
  Future<http.Response> _sendMultipartRequest(
    http.MultipartRequest request,
  ) async {
    try {
      final streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // If 401, try to refresh token and retry once
      if (response.statusCode == 401) {
        print('🔄 Received 401, attempting token refresh...');

        final refreshed = await _apiClient.refreshTokens();
        if (refreshed) {
          final newAccessToken = await _authStorage.getAccessToken();
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            print('✅ Token refreshed, retrying request...');

            // Recreate the request with new token
            final retryRequest = _cloneMultipartRequest(
              request,
              newAccessToken,
            );
            final retryStreamedResponse = await retryRequest.send();
            response = await http.Response.fromStream(retryStreamedResponse);
          }
        }
      }

      return response;
    } catch (e) {
      print('❌ Multipart request failed: $e');
      rethrow;
    }
  }

  /// Clone a multipart request with new auth token
  http.MultipartRequest _cloneMultipartRequest(
    http.MultipartRequest original,
    String newToken,
  ) {
    final cloned = http.MultipartRequest(original.method, original.url);
    cloned.headers.addAll(original.headers);
    cloned.headers['Authorization'] = 'Bearer $newToken';
    cloned.fields.addAll(original.fields);
    cloned.files.addAll(original.files);
    return cloned;
  }

  /// Get all service histories
  Future<List<ServiceHistoryModel>> getAllHistories() async {
    try {
      print(
        '🔍 Fetching service histories from: ${ApiConfig.baseUrl}/service-histories',
      );
      final response = await _apiClient
          .get('/service-histories')
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
      } else if (response.statusCode == 404) {
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null && errorData['message'].toString().contains('Motor utama belum ditetapkan')) {
            print('⚠️ Primary motorcycle not set, returning empty array');
            return [];
          }
          throw Exception(errorData['message'] ?? 'Failed to load histories: 404');
        } catch (e) {
          if (e is FormatException) {
             throw Exception('Failed to load histories: 404');
          }
          rethrow;
        }
      } else {
        String errorMessage = 'Failed to load histories: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Failed to fetch histories: $e');
      rethrow;
    }
  }

  /// Get history by ID
  Future<ServiceHistoryModel> getHistoryById(int id) async {
    try {
      print('🔍 Fetching service history detail: /service-histories/$id');
      final response = await _apiClient
          .get('/service-histories/$id')
          .timeout(ApiConfig.connectTimeout);

      print('📥 Service history detail status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Service history detail response: $jsonData');
        final data = jsonData['data'];
        // Handle nested structure: {data: {service_history: {...}}}
        if (data is Map<String, dynamic> &&
            data.containsKey('service_history')) {
          print(
            '🔍 receipt_url field: ${data['service_history']['receipt_url']}',
          );
          return ServiceHistoryModel.fromJson(data['service_history']);
        }
        // Fallback: data might be the object directly
        print('🔍 receipt_url field: ${data['receipt_url']}');
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
      final response = await _apiClient
          .get('/service-histories/cost-summary')
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Backend returns data.summary object
        return jsonData['data']?['summary'] ?? {};
      } else if (response.statusCode == 404) {
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null && errorData['message'].toString().contains('Motor utama belum ditetapkan')) {
            print('⚠️ Primary motorcycle not set, returning empty summary');
            return {};
          }
          throw Exception(errorData['message'] ?? 'Failed to load cost summary: 404');
        } catch (e) {
          if (e is FormatException) {
             throw Exception('Failed to load cost summary: 404');
          }
          rethrow;
        }
      } else {
        String errorMessage = 'Failed to load cost summary: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Failed to fetch cost summary: $e');
      rethrow;
    }
  }

  /// Create new service history
  Future<ServiceHistoryModel> createHistory(
    ServiceHistoryModel history, {
    File? receiptFile,
  }) async {
    try {
      final token = await _authStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      // Create multipart request if there's a file, otherwise use JSON
      if (receiptFile != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/service-histories'),
        );

        // Add headers
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        // Add fields
        request.fields['service_type'] = history.serviceName;
        request.fields['performed_at'] = history.serviceDate
            .toIso8601String()
            .split('T')
            .first;
        if (history.odometer != null) {
          request.fields['odometer'] = history.odometer.toString();
        }
        if (history.cost != null) {
          request.fields['cost'] = history.cost.toString();
        }
        request.fields['currency'] = history.currency ?? 'IDR';
        if (history.serviceProvider != null) {
          request.fields['service_provider'] = history.serviceProvider!;
        }
        if (history.notes != null) {
          request.fields['notes'] = history.notes!;
        }

        // Add receipt file
        print('📷 Uploading receipt image...');
        request.files.add(
          await http.MultipartFile.fromPath('receipt_photo', receiptFile.path),
        );

        print('📤 Creating service history with file upload');
        final response = await _sendMultipartRequest(request);

        print('📥 Create response status: ${response.statusCode}');
        print('📄 Create response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          print('✅ Service history created successfully with image');
          final data = jsonData['data'];
          if (data is Map<String, dynamic> &&
              data.containsKey('service_history')) {
            return ServiceHistoryModel.fromJson(data['service_history']);
          }
          return ServiceHistoryModel.fromJson(data);
        } else {
          throw Exception(
            'Failed to create history: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        // JSON request without file
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
        };

        print('📤 Creating service history with body: $body');

        final response = await _apiClient
            .post('/service-histories', body: body)
            .timeout(ApiConfig.connectTimeout);

        print('📥 Create response status: ${response.statusCode}');
        print('📄 Create response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          print('✅ Service history created successfully');
          final data = jsonData['data'];
          if (data is Map<String, dynamic> &&
              data.containsKey('service_history')) {
            return ServiceHistoryModel.fromJson(data['service_history']);
          }
          return ServiceHistoryModel.fromJson(data);
        } else {
          throw Exception(
            'Failed to create history: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      print('❌ Failed to create history: $e');
      rethrow;
    }
  }

  /// Update service history
  Future<ServiceHistoryModel> updateHistory(
    int id,
    ServiceHistoryModel history, {
    File? receiptFile,
  }) async {
    try {
      final token = await _authStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      // Create multipart request if there's a file, otherwise use JSON
      if (receiptFile != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/service-histories/$id'),
        );

        // Add headers (using POST with _method override for file upload)
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
        request.fields['_method'] = 'PUT';

        // Add fields
        request.fields['service_type'] = history.serviceName;
        request.fields['performed_at'] = history.serviceDate
            .toIso8601String()
            .split('T')
            .first;
        if (history.odometer != null) {
          request.fields['odometer'] = history.odometer.toString();
        }
        if (history.cost != null) {
          request.fields['cost'] = history.cost.toString();
        }
        request.fields['currency'] = history.currency ?? 'IDR';
        if (history.serviceProvider != null) {
          request.fields['service_provider'] = history.serviceProvider!;
        }
        if (history.notes != null) {
          request.fields['notes'] = history.notes!;
        }

        // Add receipt file
        print('📷 Uploading receipt image...');
        request.files.add(
          await http.MultipartFile.fromPath('receipt_photo', receiptFile.path),
        );

        print('📤 Updating service history with file upload');
        final response = await _sendMultipartRequest(request);

        print('📥 Update response status: ${response.statusCode}');
        print('📄 Update response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          print('✅ Service history updated successfully with image');
          final data = jsonData['data'];
          if (data is Map<String, dynamic> &&
              data.containsKey('service_history')) {
            return ServiceHistoryModel.fromJson(data['service_history']);
          }
          return ServiceHistoryModel.fromJson(data);
        } else {
          throw Exception(
            'Failed to update history: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        // JSON request without file
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
        };

        final response = await _apiClient
            .put('/service-histories/$id', body: body)
            .timeout(ApiConfig.connectTimeout);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final data = jsonData['data'];
          if (data is Map<String, dynamic> &&
              data.containsKey('service_history')) {
            return ServiceHistoryModel.fromJson(data['service_history']);
          }
          return ServiceHistoryModel.fromJson(data);
        } else {
          throw Exception(
            'Failed to update history: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      print('Failed to update history: $e');
      rethrow;
    }
  }

  /// Delete service history
  Future<void> deleteHistory(int id) async {
    try {
      final response = await _apiClient
          .delete('/service-histories/$id')
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
