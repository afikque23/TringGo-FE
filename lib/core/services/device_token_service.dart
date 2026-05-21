import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/api_constants.dart';
import '../network/api_client.dart';

class DeviceTokenService {
  /// Register FCM token ke backend
  static Future<bool> register(String fcmToken) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final response = await ApiClient().post(
        '${ApiConstants.baseUrl}${ApiConstants.deviceTokensRegister}',
        body: {
          'fcm_token': fcmToken,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_name': deviceInfo,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Device token registered successfully');
        return true;
      } else {
        print('Failed to register token: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering device token: $e');
      return false;
    }
  }

  /// Unregister FCM token dari backend
  static Future<bool> unregister(String fcmToken) async {
    try {
      final response = await ApiClient().post(
        '${ApiConstants.baseUrl}${ApiConstants.deviceTokensUnregister}',
        body: {'fcm_token': fcmToken},
      );

      if (response.statusCode == 200) {
        print('Device token unregistered successfully');
        return true;
      } else {
        print('Failed to unregister token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error unregistering device token: $e');
      return false;
    }
  }

  /// Cek status device tokens
  static Future<Map<String, dynamic>?> getStatus() async {
    try {
      final response = await ApiClient().get(
        '${ApiConstants.baseUrl}${ApiConstants.deviceTokensStatus}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      print('Error getting device token status: $e');
      return null;
    }
  }

  /// Get device name untuk identifikasi
  static Future<String> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.name} ${iosInfo.model}';
    }

    return 'Unknown Device';
  }
}
