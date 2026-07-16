import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'otp_verification_page.dart';
import '../dashboard/dashboard.dart';
import '../widget/page_transition.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/api_config.dart';
import '../../core/services/auth_storage.dart';
import '../../core/services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authStorage = AuthStorage();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPendingVerification();
  }

  Future<void> _checkPendingVerification() async {
    final pendingEmail = await _authStorage.getPendingVerificationEmail();
    if (!mounted || pendingEmail == null || pendingEmail.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lanjut Verifikasi'),
          content: Text(
            'Anda punya proses verifikasi OTP yang belum selesai untuk $pendingEmail. Lanjutkan sekarang?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _authStorage.clearPendingVerificationEmail();
              },
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SmoothPageRoute(
                    page: OtpVerificationPage(
                      email: pendingEmail,
                      isFromRegistration: true,
                    ),
                  ),
                );
              },
              child: const Text('Lanjut'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email dan password harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check response structure
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];

          // Save tokens (access_token and refresh_token for persistent login)
          if (responseData['access_token'] != null &&
              responseData['refresh_token'] != null) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('🔐 LOGIN TOKEN DEBUG');
            print(
              'Access Token: ${responseData['access_token'].substring(0, 20)}...',
            );
            print(
              'Refresh Token: ${responseData['refresh_token'].substring(0, 20)}...',
            );
            print(
              'Access Token Length: ${responseData['access_token'].length}',
            );
            print(
              'Refresh Token Length: ${responseData['refresh_token'].length}',
            );

            await _authStorage.saveTokens(
              accessToken: responseData['access_token'],
              refreshToken: responseData['refresh_token'],
            );

            // Verify tokens were saved
            final savedAccessToken = await _authStorage.getAccessToken();
            final savedRefreshToken = await _authStorage.getRefreshToken();
            print('✅ Tokens saved to secure storage');
            print(
              'Saved Access Token: ${savedAccessToken?.substring(0, 20)}...',
            );
            print(
              'Saved Refresh Token: ${savedRefreshToken?.substring(0, 20)}...',
            );
            print(
              'Match Access: ${savedAccessToken == responseData['access_token']}',
            );
            print(
              'Match Refresh: ${savedRefreshToken == responseData['refresh_token']}',
            );
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

            // Save user data
            if (responseData['user'] != null) {
              final user = responseData['user'];
              if (user['id'] != null && user['email'] != null) {
                await _authStorage.saveUserData(
                  userId: user['id'],
                  email: user['email'],
                  name: user['name'],
                );
              }
            }

            print('✅ Login successful - Persistent login enabled (90 days)');

            // Register FCM token after successful login
            try {
              await NotificationService.instance.registerTokenAfterLogin();
            } catch (e) {
              print('⚠️ Failed to register FCM token: $e');
              // Don't block login flow if FCM registration fails
            }

            // Navigate to dashboard
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              SmoothPageRoute(page: const DashboardPage()),
            );
          } else {
            _showErrorDialog('Response tidak lengkap dari server');
          }
        } else {
          _showErrorDialog(data['message'] ?? 'Login gagal');
        }
      } else {
        final error = jsonDecode(response.body);
        final message = (error['message'] ?? 'Login gagal').toString();
        final requiresVerification = error['errors'] is Map
            ? (error['errors']['requires_verification'] == true)
            : false;

        if (response.statusCode == 403 && requiresVerification) {
          final email = _emailController.text.trim();
          if (email.isNotEmpty) {
            await _authStorage.savePendingVerificationEmail(email);
          }

          if (!mounted) return;
          Navigator.push(
            context,
            SmoothPageRoute(
              page: OtpVerificationPage(email: email, isFromRegistration: true),
            ),
          );
          return;
        }

        _showErrorDialog(message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // App Icon
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 80,
                  height: 80,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 5),
                // App Name
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // Tagline
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Login Card
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Text
                      Text(
                        l10n.welcomeBack,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.email,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.emailHint,
                              hintStyle: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.password,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.passwordHint,
                              hintStyle: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(page: const ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Login Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.login,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.secondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(page: const RegisterPage()),
                              );
                            },
                            child: Text(
                              l10n.register,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
