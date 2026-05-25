import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

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
  static String get baseUrl =>
      ApiConfig.baseUrl.replaceAll('/v1/motorcycle', '');

  static Future<Map<String, String>> _getHeaders() async {
    final authStorage = AuthStorage();
    final token = await authStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 1. Cek Status Tracking
  static Future<TrackingStatus> checkStatus(int motorId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/motors/$motorId/tracking/status'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TrackingStatus.fromJson(json);
    } else {
      throw Exception('Gagal memuat status tracking');
    }
  }

  /// 2. Mulai Tracking (Start)
  static Future<bool> startTracking(int motorId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/motors/$motorId/tracking/start'),
      headers: headers,
    );

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
  static Future<Map<String, dynamic>> stopTracking(int motorId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/motors/$motorId/tracking/stop'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['trip'] ??
          {}; // Mengembalikan data summary trip (termasuk duration_minutes)
    } else {
      throw Exception('Gagal menghentikan tracking');
    }
  }

  /// 4. Ambil Lokasi Terakhir (IoT)
  static Future<Map<String, dynamic>?> getLatestLocation(int motorId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/motors/$motorId/tracking/last-location'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Jika belum ada data koordinat
      if (json['latitude'] == null) return null;
      return json;
    } else {
      throw Exception('Gagal mengambil lokasi terakhir');
    }
  }
}
