import 'dart:convert';

import '../network/api_client.dart';
import '../network/api_config.dart';

class TrackingStatus {
  final bool isTracking;
  final int? activeTripId;

  TrackingStatus({required this.isTracking, this.activeTripId});

  factory TrackingStatus.fromJson(Map<String, dynamic> json) {
    return TrackingStatus(
      isTracking: json['is_tracking'] ?? false,
      activeTripId: json['active_trip'] != null
          ? json['active_trip']['id']
          : null,
    );
  }
}

class TrackingApiService {
  // Gunakan IP yang sesuai dengan backend
  static String get baseUrl => ApiConfig.baseUrl;
  static final ApiClient _apiClient = ApiClient();

  /// 1. Cek Status Tracking
  static Future<TrackingStatus> checkStatus(int motorId) async {
    final url = '$baseUrl/motors/$motorId/tracking/status';
    print('🌐 [GET] $url');
    final response = await _apiClient.get(url);

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TrackingStatus.fromJson(json);
    } else {
      throw Exception(
        'Gagal memuat status tracking. Status: ${response.statusCode}',
      );
    }
  }

  /// 1b. Ambil detail trip berdasarkan ID.
  static Future<Map<String, dynamic>> getTripById(int tripId) async {
    final response = await _apiClient.get('$baseUrl/trips/$tripId');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic> &&
          json['data'] is Map<String, dynamic>) {
        return json['data'] as Map<String, dynamic>;
      }
      if (json is Map && json['data'] is Map) {
        return Map<String, dynamic>.from(json['data'] as Map);
      }
      throw Exception('Format detail trip tidak valid');
    }

    throw Exception('Gagal mengambil detail trip');
  }

  /// 2. Mulai Tracking (Start)
  static Future<bool> startTracking(int motorId) async {
    final url = '$baseUrl/motors/$motorId/tracking/start';
    print('🌐 [POST] $url');
    final response = await _apiClient.post(url);

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      // Kasus: Trip masih aktif
      return false;
    } else {
      throw Exception('Gagal memulai tracking');
    }
  }

  /// 3. Berhentikan Tracking (Stop)
  /// [clientDistanceKm] — jarak yang dihitung lokal di mobile, dikirim sebagai fallback
  /// ke backend jika TripPoints tidak tersimpan (mqtt:subscribe tidak berjalan)
  static Future<Map<String, dynamic>> stopTracking(
    int motorId, {
    double clientDistanceKm = 0,
    double clientAvgSpeedKph = 0,
    int clientMaxSpeedKph = 0,
    int clientDurationSec = 0,
    List<Map<String, dynamic>> clientRoutePoints = const [],
  }) async {
    final body = {
      if (clientDistanceKm > 0)
        'client_distance_meters': (clientDistanceKm * 1000).round(),
      if (clientAvgSpeedKph > 0) 'client_avg_speed_kph': clientAvgSpeedKph,
      if (clientMaxSpeedKph > 0) 'client_max_speed_kph': clientMaxSpeedKph,
      if (clientDurationSec > 0) 'client_duration_seconds': clientDurationSec,
      if (clientRoutePoints.isNotEmpty)
        'client_route_points': clientRoutePoints,
    };

    final response = await _apiClient.post(
      '$baseUrl/motors/$motorId/tracking/stop',
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Kembalikan respons penuh (termasuk 'summary' dengan distance_km)
      return json as Map<String, dynamic>;
    } else {
      throw Exception('Gagal menghentikan tracking');
    }
  }

  /// 4. Ambil Lokasi Terakhir (IoT)
  static Future<Map<String, dynamic>?> getLatestLocation(int motorId) async {
    final uri = Uri.parse('$baseUrl/motors/$motorId/tracking/last-location')
        .replace(
          queryParameters: {
            '_': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
    print('🌐 [GET] $uri');
    final response = await _apiClient.get(
      uri.toString(),
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    print('📥 [Last Location] Status: ${response.statusCode}');
    print('📥 [Last Location] Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Tetap kembalikan payload walau koordinat null, agar status IoT bisa di-update.
      if (json is Map<String, dynamic>) {
        return json;
      }
      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }
      return null;
    } else {
      throw Exception('Gagal mengambil lokasi terakhir');
    }
  }
}
