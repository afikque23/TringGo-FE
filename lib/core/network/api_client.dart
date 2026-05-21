import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_storage.dart';
import 'api_config.dart';

/// API Client with automatic token refresh
/// Handles authentication and auto-refreshes access tokens when expired
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _authStorage = AuthStorage();
  static const int _maxRetries = 1;

  Future<bool>? _refreshInFlight;

  /// Expose auth storage for debugging/testing
  AuthStorage get authStorage => _authStorage;

  /// Make authenticated GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _makeRequest('GET', endpoint, headers: headers);
  }

  /// Make authenticated POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest('POST', endpoint, headers: headers, body: body);
  }

  /// Make authenticated PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest('PUT', endpoint, headers: headers, body: body);
  }

  /// Make authenticated PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest('PATCH', endpoint, headers: headers, body: body);
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _makeRequest('DELETE', endpoint, headers: headers);
  }

  /// Internal method to make requests with auto-refresh
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    int retryCount = 0,
  }) async {
    // Get access token
    String? accessToken = await _authStorage.getAccessToken();

    // Make the request
    var response = await _sendRequest(
      method,
      endpoint,
      accessToken,
      headers,
      body,
    );

    // If 401 Unauthorized and we haven't retried yet, try to refresh token
    if (response.statusCode == 401 && retryCount < _maxRetries) {
      print('🔄 Access token expired, attempting refresh...');
      final refreshed = await _refreshAccessTokenSingleFlight();

      if (refreshed) {
        // Retry the original request with new token
        accessToken = await _authStorage.getAccessToken();
        return _sendRequest(method, endpoint, accessToken, headers, body);
      } else {
        print('❌ Token refresh failed, user needs to login again');
        // Token refresh failed, return the 401 response
        // The app should handle this by navigating to login
        return response;
      }
    }

    return response;
  }

  /// Public: attempt to refresh tokens using the stored refresh token.
  /// Returns true if new tokens were saved.
  Future<bool> refreshTokens() async {
    return _refreshAccessTokenSingleFlight();
  }

  /// Send HTTP request
  Future<http.Response> _sendRequest(
    String method,
    String endpoint,
    String? accessToken,
    Map<String, String>? additionalHeaders,
    Object? body,
  ) async {
    final uri = _resolveUri(endpoint);
    print('🌐 [$method] $uri');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?additionalHeaders,
    };

    // Add authorization header if token exists
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    switch (method) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PATCH':
        return await http.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw UnsupportedError('Method $method not supported');
    }
  }

  Uri _resolveUri(String endpoint) {
    final normalized = endpoint.trim();

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return Uri.parse(normalized);
    }

    if (normalized.startsWith('/')) {
      return Uri.parse('${ApiConfig.baseUrl}$normalized');
    }

    return Uri.parse('${ApiConfig.baseUrl}/$normalized');
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshAccessTokenSingleFlight() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;

    final future = _refreshAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
    _refreshInFlight = future;
    return future;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _authStorage.getRefreshToken();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 REFRESH TOKEN DEBUG');
      print(
        'Refresh Token Retrieved: ${refreshToken?.substring(0, 20) ?? 'NULL'}...',
      );
      print('Refresh Token Length: ${refreshToken?.length ?? 0}');
      print('Refresh Token Empty: ${refreshToken?.isEmpty ?? true}');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token available');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return false;
      }

      print('📡 Refreshing token...');
      print('Endpoint: ${ApiConfig.baseUrl}${ApiConfig.authRefreshToken}');
      print(
        'Request Body: {"refresh_token": "${refreshToken.substring(0, 20)}..."}',
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authRefreshToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final newAccessToken = data['data']['access_token'];
          final newRefreshToken = data['data']['refresh_token'];

          print('✅ Received new tokens from backend');
          print(
            'New Access Token: ${newAccessToken?.substring(0, 20) ?? 'NULL'}...',
          );
          print(
            'New Refresh Token: ${newRefreshToken?.substring(0, 20) ?? 'NULL'}...',
          );

          // Save new tokens
          await _authStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          print('✅ Token refreshed successfully');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return true;
        } else {
          print('❌ Invalid response structure');
          print('Response data: $data');
        }
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        // Refresh token is invalid/expired/revoked. Clear local session so the
        // app won't keep treating the user as logged in.
        await _authStorage.clearAll();
        print('🧹 Cleared local tokens due to invalid refresh token');
      }

      print('❌ Token refresh failed: ${response.statusCode}');
      print('Response: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authStorage.isLoggedIn();
  }

  /// Logout - clear all tokens
  Future<void> logout() async {
    try {
      // Call logout endpoint on backend
      final accessToken = await _authStorage.getAccessToken();
      if (accessToken != null) {
        final response = await http
            .post(
              Uri.parse(ApiConfig.logoutUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          print('✅ Logout API successful');
        } else if (response.statusCode == 401) {
          print(
            '⚠️ Token already invalid (401) - proceeding with local logout',
          );
        } else {
          print('⚠️ Logout API returned status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('⚠️ Logout API error: $e');
      // Continue with local logout even if API fails
    } finally {
      // Always clear local tokens regardless of API response
      await _authStorage.clearAll();
      print('✅ Local tokens cleared successfully');
    }
  }
}
