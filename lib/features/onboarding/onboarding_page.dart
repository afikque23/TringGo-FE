import 'package:flutter/material.dart';
import 'onboarding_1.dart';
import 'onboarding_2.dart';
import 'onboarding_3.dart';
import 'onboarding_4.dart';
import '../auth/login_page.dart';
import '../widget/page_transition.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(SmoothPageRoute(page: const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          Onboarding1(onNext: _goToNextPage, onSkip: _navigateToLogin),
          Onboarding2(
            onNext: _goToNextPage,
            onBack: _goToPreviousPage,
            onSkip: _navigateToLogin,
          ),
          Onboarding3(
            onNext: _goToNextPage,
            onBack: _goToPreviousPage,
            onSkip: _navigateToLogin,
          ),
          Onboarding4(
            onGetStarted: _navigateToLogin,
            onBack: _goToPreviousPage,
            onSkip: _navigateToLogin,
          ),
        ],
      ),
    );
  }
}
