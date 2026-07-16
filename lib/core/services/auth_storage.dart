import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens
/// Uses platform-specific secure storage (Keychain on iOS, Keystore on Android)
class AuthStorage {
  // Singleton pattern
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Storage keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _pendingVerificationEmailKey = 'pending_verification_email';

  /// Save authentication tokens after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Save user data
  Future<void> saveUserData({
    required int userId,
    required String email,
    String? name,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId.toString()),
      _storage.write(key: _userEmailKey, value: email),
      if (name != null) _storage.write(key: _userNameKey, value: name),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Get user ID
  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    return userIdStr != null ? int.tryParse(userIdStr) : null;
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Get user name
  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  /// Check if user is logged in (has valid refresh token)
  Future<bool> isLoggedIn() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Clear all tokens and user data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Update access token only (after refresh)
  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  /// Save pending email verification state (for register/login recovery flow)
  Future<void> savePendingVerificationEmail(String email) async {
    await _storage.write(key: _pendingVerificationEmailKey, value: email);
  }

  /// Read pending email verification state
  Future<String?> getPendingVerificationEmail() async {
    return await _storage.read(key: _pendingVerificationEmailKey);
  }

  /// Clear pending email verification state
  Future<void> clearPendingVerificationEmail() async {
    await _storage.delete(key: _pendingVerificationEmailKey);
  }
}
