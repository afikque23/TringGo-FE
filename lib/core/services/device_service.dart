import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing device identification for guest mode
/// Generates and persists a unique device ID for API requests
class DeviceService {
  // Singleton pattern
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _deviceIdKey = 'device_id';
  static const String _deviceNameKey = 'device_name';

  /// Get or generate device ID
  /// This ID is used to identify guest users in the API
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate new UUID for this device
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  /// Save device name (optional)
  Future<void> saveDeviceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceNameKey, name);
  }

  /// Get device name
  Future<String?> getDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceNameKey);
  }

  /// Clear device data (use with caution)
  Future<void> clearDeviceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceNameKey);
  }
}
