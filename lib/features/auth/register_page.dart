import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'otp_verification_page.dart';
import '../widget/page_transition.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/api_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _passwordStrength = -1; // -1: not show, 0: weak, 1: medium, 2: strong

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = -1; // Not show indicator
      } else if (password.length < 6) {
        _passwordStrength = 0; // Weak (red)
      } else if (password.length < 10) {
        _passwordStrength = 1; // Medium (yellow)
      } else {
        _passwordStrength = 2; // Strong (green)
      }
    });
  }

  String _passwordStrengthText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_passwordStrength) {
      case 0:
        return '${l10n.passwordStrength}: ${l10n.weak}';
      case 1:
        return '${l10n.passwordStrength}: ${l10n.medium}';
      case 2:
        return '${l10n.passwordStrength}: ${l10n.strong}';
      default:
        return '${l10n.passwordStrength}: ${l10n.weak}';
    }
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrength) {
      case 0:
        return const Color(0xFFEF4444); // Red
      case 1:
        return const Color(0xFFF0B100); // Yellow
      case 2:
        return const Color(0xFF6B7C4F); // Green
      default:
        return const Color(0xFFEF4444);
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorDialog('Semua field harus diisi');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Password dan konfirmasi password tidak sama');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = ApiConfig.registerUrl;
      print('🌐 Calling URL: $url'); // Debug log

      final requestBody = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };
      print('📤 Request body: $requestBody'); // Debug log

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}'); // Debug log
      print('📥 Response body: ${response.body}'); // Debug log

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registrasi berhasil, arahkan ke OTP verification
        Navigator.push(
          context,
          SmoothPageRoute(
            page: OtpVerificationPage(
              email: _emailController.text,
              isFromRegistration: true,
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      print('❌ Error: $e'); // Debug log
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
        child: Column(
          children: [
            // Static Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // App Icon
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 80,
                    height: 80,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 6),
                  // Page Title
                  Text(
                    l10n.register,
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
                    l10n.joinToday,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  children: [
                    // Register Card
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
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: l10n.name,
                            hint: l10n.name,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: l10n.email,
                            hint: 'email.anda@contoh.com',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          _buildPasswordField(
                            controller: _passwordController,
                            label: l10n.password,
                            hint: 'Masukkan kata sandi',
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          // Password Strength Indicator
                          _buildPasswordStrengthIndicator(),
                          const SizedBox(height: 16),
                          // Confirm Password Field
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: l10n.confirmPassword,
                            hint: 'Ketik ulang kata sandi anda',
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Register Button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      l10n.register,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: colorScheme.secondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.login,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.65,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.65,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.65,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.65,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
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
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    // Only show when password is not empty
    if (_passwordStrength == -1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (_passwordStrength + 1) / 3,
            child: Container(
              decoration: BoxDecoration(
                color: _passwordStrengthColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Strength Text and Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _passwordStrengthText(context),
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.33,
                color: _passwordStrengthColor,
              ),
            ),
            Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
                  width: 24,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index <= _passwordStrength
                        ? _passwordStrengthColor
                        : Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
