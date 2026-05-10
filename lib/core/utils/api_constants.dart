import '../network/api_config.dart';

class ApiConstants {
  // Keep a single source of truth for backend URL.
  // Configure it in ApiConfig.baseUrl.
  static const String baseUrl = ApiConfig.baseUrl;

  // Endpoints
  static const String deviceTokensRegister = '/device-tokens/register';
  static const String deviceTokensUnregister = '/device-tokens/unregister';
  static const String deviceTokensStatus = '/device-tokens/status';
  static const String notifications = '/notifications';
  static const String notificationCategories = '/notification-categories';
  static const String notificationPreferences = '/notification-preferences';
}
