import 'dart:convert';
import '../utils/api_constants.dart';
import '../network/api_client.dart';

class NotificationApiService {
  /// Ambil daftar notifikasi
  static Future<Map<String, dynamic>> getNotifications({
    String category = 'all',
    bool unreadOnly = false,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = {
      'category': category,
      if (unreadOnly) 'unread': 'true',
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}',
    ).replace(queryParameters: queryParams);

    final response = await ApiClient().get(uri.toString());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load notifications');
  }

  /// Ambil kategori notifikasi
  static Future<List<dynamic>> getCategories() async {
    final response = await ApiClient().get(
      '${ApiConstants.baseUrl}${ApiConstants.notificationCategories}',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  /// Tandai notifikasi sebagai dibaca
  static Future<bool> markAsRead(int notificationId) async {
    final response = await ApiClient().patch(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId/read',
    );
    return response.statusCode == 200;
  }

  /// Tandai semua notifikasi sebagai dibaca
  static Future<int> markAllAsRead() async {
    final response = await ApiClient().patch(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}/read-all',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data['updated_count'] ?? 0;
    }
    return 0;
  }

  /// Hapus notifikasi
  static Future<bool> deleteNotification(int notificationId) async {
    final response = await ApiClient().delete(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId',
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
}
