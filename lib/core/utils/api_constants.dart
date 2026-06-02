class ApiConstants {
  // TODO: Ganti dengan URL backend Laravel Anda
  // Untuk emulator Android: http://10.0.2.2:8000
  // Untuk device fisik: http://YOUR_IP_ADDRESS:8000
  // Untuk production: http://tringgo.site
  static const String baseUrl = 'http://tringgo.site/api/v1/motorcycle';

  // Endpoints
  static const String deviceTokensRegister = '/device-tokens/register';
  static const String deviceTokensUnregister = '/device-tokens/unregister';
  static const String deviceTokensStatus = '/device-tokens/status';
  static const String notifications = '/notifications';
  static const String notificationCategories = '/notification-categories';
  static const String notificationPreferences = '/notification-preferences';
}
