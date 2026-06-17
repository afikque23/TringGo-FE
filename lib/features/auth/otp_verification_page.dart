import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'change_password_page.dart';
import 'registration_success_page.dart';
import '../widget/page_transition.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/api_config.dart';
import '../../core/services/auth_storage.dart';
import '../../core/services/notification_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool
  isFromRegistration; // true = dari register, false = dari forgot password

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isFromRegistration = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isOtpComplete = false;
  bool _isLoading = false;
  bool _isResending = false;
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 300; // Reset to 5 minutes
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _checkOtpComplete() {
    setState(() {
      _isOtpComplete = _otpControllers.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isFromRegistration) {
        // Flow: Register → Verify OTP with backend → Registration Success
        final requestBody = {
          'email': widget.email,
          'otp': _otpCode,
          'type': 'email_verification',
        };

        print('🔍 DEBUG OTP Verification (Registration):');
        print('URL: ${ApiConfig.verifyEmailUrl}');
        print('Type: email_verification');
        print('Email: ${widget.email}');
        print('OTP: $_otpCode');
        print('Body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          Uri.parse(ApiConfig.verifyEmailUrl),
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode(requestBody),
        );

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body)['data'];

          // Save tokens from response
          if (responseData != null && responseData['access_token'] != null) {
            final authStorage = AuthStorage();

            // Save tokens
            await authStorage.saveTokens(
              accessToken: responseData['access_token'],
              refreshToken: responseData['refresh_token'],
            );

            // Save user data
            if (responseData['user'] != null) {
              final user = responseData['user'];
              if (user['id'] != null && user['email'] != null) {
                await authStorage.saveUserData(
                  userId: user['id'],
                  email: user['email'],
                  name: user['name'],
                );
              }
            }

            print('✅ Tokens saved after email verification');

            // Register FCM token after successful verification and login
            try {
              await NotificationService.instance.registerTokenAfterLogin();
            } catch (e) {
              print('⚠️ Failed to register FCM token: $e');
              // Don't block flow if FCM registration fails
            }
          }

          // Navigate to success page
          Navigator.pushReplacement(
            context,
            SmoothPageRoute(page: RegistrationSuccessPage(email: widget.email)),
          );
        } else {
          final error = jsonDecode(response.body);
          _showErrorDialog(error['message'] ?? 'OTP tidak valid');
        }
      } else {
        // Flow: Forgot Password → OTP input → Change Password (OTP verified at reset password endpoint)
        print('🔍 Forgot Password Flow: Navigate to Change Password with OTP');
        print('Email: ${widget.email}');
        print('OTP: $_otpCode');

        if (!mounted) return;

        Navigator.push(
          context,
          SmoothPageRoute(
            page: ChangePasswordPage(email: widget.email, otp: _otpCode),
          ),
        );
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

  Future<void> _handleResendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final type = widget.isFromRegistration
          ? 'email_verification'
          : 'password_reset';
      final requestBody = {'email': widget.email, 'type': type};

      print('🔄 DEBUG Resend OTP:');
      print('URL: ${ApiConfig.resendOtpUrl}');
      print('Type: $type');
      print('Email: ${widget.email}');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiConfig.resendOtpUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        _startTimer(); // Reset timer when OTP is resent
        _showSuccessDialog('OTP berhasil dikirim ulang');
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Gagal mengirim ulang OTP');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 16),
                // Page Title
                Text(
                  l10n.otpVerification,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  l10n.enterOTPCode,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
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
                      // Description
                      Text(
                        l10n.otpSentTo(widget.email),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // OTP Input Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                width: 48,
                                height: 56,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: colorScheme.surface,
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
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                  _checkOtpComplete();
                                },
                                onTap: () {
                                  // Clear the field when tapped
                                  _otpControllers[index].clear();
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                      const SizedBox(height: 16),
                      // Countdown Timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _remainingSeconds > 60
                              ? colorScheme.primaryContainer
                              : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: _remainingSeconds > 60
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _remainingSeconds > 0
                                  ? 'Kode berakhir dalam $_timerText'
                                  : 'Kode telah kedaluwarsa',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _remainingSeconds > 60
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.didntReceiveCode,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _isResending ? null : _handleResendOtp,
                            child: _isResending
                                ? const SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.resend,
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
                      const SizedBox(height: 8),
                      // Verify Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              (_isOtpComplete &&
                                  !_isLoading &&
                                  _remainingSeconds > 0)
                              ? _handleVerifyOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor: colorScheme.primary
                                .withOpacity(0.5),
                            disabledForegroundColor: colorScheme.onPrimary,
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
                                  l10n.verifyAndContinue,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Back Button
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Kembali',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
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
