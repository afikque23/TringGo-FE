/// API Configuration
/// Contains all API endpoints and base URL configuration
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for the API
  /// For Android Emulator: use 127.0.0.1 (with adb reverse) or 10.0.2.2
  /// For iOS Simulator: use localhost or 127.0.0.1
  /// For Physical Device: use your computer's IP address (e.g., 192.168.1.125)

  // ACTIVE: Using 127.0.0.1 with adb reverse tcp:8000 tcp:8000
  // Note: Laravel in this project exposes routes under the `/motorcycle` prefix
  // so include that segment in the base URL to avoid "route not found" errors.
  // static const String baseUrl = 'http://127.0.0.1:8000/api/v1/motorcycle';

  // OPTION 2: Android Emulator via 10.0.2.2 (no adb reverse)
  static const String baseUrl = 'http://192.168.1.11:8000/api/v1/motorcycle';

  // OPTION 3: Physical Device - use your computer's actual IP (replace .125)
  // static const String baseUrl = 'http://192.168.1.125:8000/api/v1/motorcycle';

  // OPTION 4: iOS Simulator
  // static const String baseUrl = 'http://localhost:8000/api/v1/motorcycle';

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

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
