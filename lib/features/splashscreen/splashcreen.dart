import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/onboarding_page.dart';
import '../widget/page_transition.dart';
import 'splash_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SplashAnimation _animation;

  @override
  void initState() {
    super.initState();

    final controller = SplashAnimationMixin.createController(this);
    _animation = SplashAnimation(controller: controller);

    _animation.start();

    // Navigasi setelah 5 detik
    Future.delayed(SplashAnimationMixin.delayBeforeNavigation, () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(SmoothPageRoute(page: const OnboardingPage()));
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // CENTER CONTENT
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _buildLogo(context),
                    const SizedBox(height: 40),
                    _buildTitle(context),
                    const SizedBox(height: 70),
                    _buildLoading(context),
                  ],
                ),
              ),

              // VERSION
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGO =================

  Widget _buildLogo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double greenCircleSize = 120;
    const double iconSize = 80;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow
          Container(
            width: greenCircleSize,
            height: greenCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.30),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),

          // Outer ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
                width: 3,
              ),
            ),
          ),

          // Second ring (sama ukuran green circle)
          Container(
            width: greenCircleSize,
            height: greenCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.45),
                width: 3,
              ),
            ),
          ),

          // Green circle + Icon (KEDUANYA MEMANTUL BERSAMA)
          AnimatedBuilder(
            animation: _animation.controller,
            builder: (_, __) {
              return Transform.translate(
                offset: Offset(0, _animation.bounce.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Green solid circle
                    Container(
                      width: greenCircleSize,
                      height: greenCircleSize,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Icon
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Image.asset(
                        'assets/images/motorcycle_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================

  Widget _buildTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Moto',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Tracker',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'MAINTENANCE & TRACKING',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 0.7,
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  // ================= LOADING =================

  Widget _buildLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Dot(),
            SizedBox(width: 8),
            _Dot(),
            SizedBox(width: 8),
            _Dot(),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          l10n.preparing,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ================= DOT =================

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
      ),
    );
  }
}
