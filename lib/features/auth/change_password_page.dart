import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'password_change_success_page.dart';
import '../widget/page_transition.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/api_config.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const ChangePasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonClicked = false;

  // Password requirements
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordRequirements);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordRequirements() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isFormValid {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumber &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.isNotEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isButtonClicked = true;
    });

    try {
      final requestBody = {
        'email': widget.email,
        'otp': widget.otp,
        'password': _newPasswordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      print('🔒 DEBUG Reset Password:');
      print('URL: ${ApiConfig.resetPasswordUrl}');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiConfig.resetPasswordUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          SmoothPageRoute(page: PasswordChangeSuccessPage(email: widget.email)),
        );
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isButtonClicked = false;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.createNewPassword,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.newPasswordDesc,
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
              const SizedBox(height: 32),

              // Email Container
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 0.65,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.forAccount,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newPassword,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 53,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
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
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.confirmNewPassword,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 53,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.confirmPasswordHint,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password Requirements
                  Container(
                    padding: const EdgeInsets.fromLTRB(17, 17, 17, 1),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.passwordRequirements,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRequirement(l10n.minLength, _hasMinLength),
                        const SizedBox(height: 8),
                        _buildRequirement(l10n.minUpperCase, _hasUpperCase),
                        const SizedBox(height: 8),
                        _buildRequirement(l10n.minLowerCase, _hasLowerCase),
                        const SizedBox(height: 8),
                        _buildRequirement(l10n.minNumber, _hasNumber),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              GestureDetector(
                onTap: _isFormValid ? _handleSubmit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isButtonClicked
                        ? colorScheme.primary
                        : _isFormValid
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: _isFormValid
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: _isButtonClicked
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Password Diubah',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.changePassword,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(
              color: isMet ? colorScheme.primary : colorScheme.outline,
              width: 2,
            ),
            color: isMet ? colorScheme.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: isMet
              ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: isMet ? colorScheme.onSurfaceVariant : colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
