import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import 'auth_storage.dart';

class NotificationApiService {
  /// Ambil daftar notifikasi
  static Future<Map<String, dynamic>> getNotifications({
    String category = 'all',
    bool unreadOnly = false,
    int page = 1,
    int perPage = 10,
  }) async {
    final headers = await _getHeaders();
    final queryParams = {
      'category': category,
      if (unreadOnly) 'unread': 'true',
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load notifications');
  }

  /// Ambil kategori notifikasi
  static Future<List<dynamic>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notificationCategories}',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  /// Tandai notifikasi sebagai dibaca
  static Future<bool> markAsRead(int notificationId) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId/read',
      ),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  /// Tandai semua notifikasi sebagai dibaca
  static Future<int> markAllAsRead() async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/read-all',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data['updated_count'] ?? 0;
    }
    return 0;
  }

  /// Hapus notifikasi
  static Future<bool> deleteNotification(int notificationId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId',
      ),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  /// Ambil jumlah unread (untuk badge)
  static Future<int> getUnreadCount() async {
    try {
      final result = await getNotifications(perPage: 1);
      return result['data']?['unread_count'] ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Build headers dengan auth token (NO device ID for ownership)
  static Future<Map<String, String>> _getHeaders() async {
    final authStorage = AuthStorage();
    final token = await authStorage.getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
