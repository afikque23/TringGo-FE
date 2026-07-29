import 'package:flutter/material.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';

class RegistrationSuccessPage extends StatefulWidget {
  final String email;

  const RegistrationSuccessPage({super.key, required this.email});

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
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
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    if (mounted) {
      // TODO: Navigate to Dashboard
      // For now, pop all routes
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
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
              const Spacer(flex: 2),
              // Content
              Column(
                children: [
                  // Success Icon
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
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success Message
                  Column(
                    children: [
                      Text(
                        l10n.registrationSuccess,
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
                      // Welcome message
                      Text(
                        l10n.welcomeTo(widget.email),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.625,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Feature Cards
                  Column(
                    children: [
                      _buildFeatureCard(
                        l10n.featureGPSTracking,
                        l10n.featureGPSTrackingDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        l10n.featureSmartReminder,
                        l10n.featureSmartReminderDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        l10n.featureRidingAnalysis,
                        l10n.featureRidingAnalysisDesc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Dashboard Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _navigateToDashboard,
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
                            l10n.goToDashboard,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF6B7C4F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
          ),
        ],
      ),
    );
  }
}
