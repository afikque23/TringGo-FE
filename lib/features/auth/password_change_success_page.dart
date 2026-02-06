import 'package:flutter/material.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';

class PasswordChangeSuccessPage extends StatefulWidget {
  final String email;

  const PasswordChangeSuccessPage({super.key, required this.email});

  @override
  State<PasswordChangeSuccessPage> createState() =>
      _PasswordChangeSuccessPageState();
}

class _PasswordChangeSuccessPageState extends State<PasswordChangeSuccessPage> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      // Pop all routes and go back to login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Content
              Column(
                children: [
                  // Security Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7C4F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B7C4F).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success Message
                  Column(
                    children: [
                      Text(
                        l10n.passwordChangedSuccess,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description with email
                      Text(
                        l10n.passwordChangedFor(widget.email),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.625,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Anda dapat login menggunakan password baru Anda sekarang.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Security Tips Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7C4F).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF6B7C4F).withOpacity(0.3),
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF6B7C4F),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.securityTips,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTip(l10n.tipDontShare),
                              const SizedBox(height: 8),
                              _buildTip(l10n.tipUseUnique),
                              const SizedBox(height: 8),
                              _buildTip(l10n.tipEnable2FA),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7C4F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.backToLoginBtn,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Auto redirect text
                  Text(
                    l10n.autoRedirect(_countdown),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),

              // Bottom security text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: Color(0xFF6B7C4F),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.yourPasswordSecure,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      color: Color(0xFF6B7C4F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.33,
            color: Color(0xFF6B7C4F),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: Color(0xFFD1D5DC),
            ),
          ),
        ),
      ],
    );
  }
}
