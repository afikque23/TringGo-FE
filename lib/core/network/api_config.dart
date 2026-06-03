/// API Configuration
/// Contains all API endpoints and base URL configuration
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for the API
  /// For Android Emulator: use 127.0.0.1 (with adb reverse) or 10.0.2.2
  /// For iOS Simulator: use localhost or 127.0.0.1
  /// For Physical Device: use your computer's IP address (e.g., 192.168.1.125)

  // ========================================
  // PILIH SALAH SATU (uncomment yang mau dipakai):
  // ========================================

  // PRODUCTION (VPS Rumahweb) ✅ AKTIF
  static const String baseUrl = 'http://tringgo.site/api/v1/motorcycle';

  // EMULATOR (Default)
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1/motorcycle';

  // PHYSICAL DEVICE (HP Fisik)
  // static const String baseUrl = 'http://172.20.10.2:8000/api/v1/motorcycle';

  // NGROK (Universal)
  // Works on: Emulator, Physical Device, Postman, All devices!
  // static const String baseUrl =
  // 'https://leguminous-nonshredding-felicia.ngrok-free.dev/api/v1/motorcycle';

  /// API Endpoints
  // Motorcycle
  static const String motorcycle = '/motorcycle';

  // Trips
  static const String trips = '/trips';
  static const String tripById = '/trips'; // + /{id}

  // Odometer
  static const String updateOdometer = '/vehicles'; // + /{vehicleId}/odometer

  // Authentication
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authRefreshToken = '/auth/refresh-token';
  static const String authLogout = '/auth/logout';

  // Profile
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileAvatar = '/profile/avatar';

  // Tips Perawatan
  static const String tips = '/tips'; // Protected endpoint
  static const String tipsPublic = '/public/tips'; // Public endpoint
  static const String tipById = '/tips'; // + /{id}
  static const String tipByIdPublic = '/public/tips'; // + /{id}
  static const String tipLike = '/tips'; // + /{id}/like
  static const String tipBookmark = '/tips'; // + /{id}/bookmark
  static const String tipShare = '/tips'; // + /{id}/share
  static const String tipUseTemplate = '/tips'; // + /{id}/use-template

  /// Full URLs
  // Motorcycle URLs
  static String get motorcycleUrl => '$baseUrl$motorcycle';

  // Trip URLs
  static String get tripsUrl => '$baseUrl$trips';
  static String tripByIdUrl(String id) => '$baseUrl$tripById/$id';

  // Odometer URLs
  static String updateOdometerUrl(int vehicleId) =>
      '$baseUrl$updateOdometer/$vehicleId/odometer';

  // Authentication URLs
  static String get registerUrl => '$baseUrl$authRegister';
  static String get loginUrl => '$baseUrl$authLogin';
  static String get verifyEmailUrl => '$baseUrl$authVerifyEmail';
  static String get resendOtpUrl => '$baseUrl$authResendOtp';
  static String get forgotPasswordUrl => '$baseUrl$authForgotPassword';
  static String get resetPasswordUrl => '$baseUrl$authResetPassword';
  static String get refreshTokenUrl => '$baseUrl$authRefreshToken';
  static String get logoutUrl => '$baseUrl$authLogout';

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
