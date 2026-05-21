import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../model/user_profile_model.dart';
import 'auth_storage.dart';

/// Profile Service
/// Handles user profile operations with automatic token refresh
class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _apiClient = ApiClient();
  final _authStorage = AuthStorage();

  /// Get user profile
  Future<UserProfileModel> getProfile() async {
    try {
      print('🔍 Fetching user profile...');
      final response = await _apiClient.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final profile = UserProfileModel.fromJson(jsonData['data']);
          print('✅ Profile loaded: ${profile.name}');
          return profile;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to get profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  /// Supports updating: name, email, phone, location, avatar, password
  Future<UserProfileModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    File? avatarFile,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    try {
      print('🔄 Updating profile...');

      // Get access token
      var accessToken = await _authStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token available');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileUpdate}'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Accept'] = 'application/json';

      // Add fields
      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;
      if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }

      // Password change fields
      if (currentPassword != null && currentPassword.isNotEmpty) {
        request.fields['current_password'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        request.fields['new_password'] = newPassword;
      }
      if (newPasswordConfirmation != null &&
          newPasswordConfirmation.isNotEmpty) {
        request.fields['new_password_confirmation'] = newPasswordConfirmation;
      }

      // Add avatar file
      if (avatarFile != null) {
        print('📷 Uploading avatar...');
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        final refreshed = await _apiClient.refreshTokens();
        if (refreshed) {
          accessToken = await _authStorage.getAccessToken() ?? accessToken;
          final retryRequest = await _buildProfileUpdateRequest(
            accessToken: accessToken,
            name: name,
            email: email,
            phone: phone,
            location: location,
            avatarFile: avatarFile,
            currentPassword: currentPassword,
            newPassword: newPassword,
            newPasswordConfirmation: newPasswordConfirmation,
          );
          final retryStreamedResponse = await retryRequest.send();
          response = await http.Response.fromStream(retryStreamedResponse);
        }
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final profile = UserProfileModel.fromJson(jsonData['data']);
          print('✅ Profile updated successfully');
          return profile;
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 400) {
        // Invalid current password
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Current password is incorrect');
      } else if (response.statusCode == 422) {
        // Validation error
        final jsonData = json.decode(response.body);
        final errors = jsonData['data'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = errors.values
              .expand((e) => e as List)
              .map((e) => e.toString())
              .join(', ');
          throw Exception(errorMessages);
        }
        throw Exception('Validation failed');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to update profile: $e');
      rethrow;
    }
  }

  Future<http.MultipartRequest> _buildProfileUpdateRequest({
    required String accessToken,
    String? name,
    String? email,
    String? phone,
    String? location,
    File? avatarFile,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileUpdate}'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Accept'] = 'application/json';

    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
    if (location != null && location.isNotEmpty) {
      request.fields['location'] = location;
    }

    if (currentPassword != null && currentPassword.isNotEmpty) {
      request.fields['current_password'] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      request.fields['new_password'] = newPassword;
    }
    if (newPasswordConfirmation != null && newPasswordConfirmation.isNotEmpty) {
      request.fields['new_password_confirmation'] = newPasswordConfirmation;
    }

    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );
    }

    return request;
  }

  /// Delete avatar
  Future<UserProfileModel> deleteAvatar() async {
    try {
      print('🗑️ Deleting avatar...');
      final response = await _apiClient.delete(ApiConfig.profileAvatar);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final profile = UserProfileModel.fromJson(jsonData['data']);
          print('✅ Avatar deleted successfully');
          return profile;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to delete avatar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to delete avatar: $e');
      rethrow;
    }
  }
}
