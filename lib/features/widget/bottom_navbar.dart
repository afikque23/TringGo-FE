import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'page_transition.dart';
import '../dashboard/dashboard.dart';
import '../servis/service.dart';
import '../tips_perawatan/tips_perawatan.dart';
import '../profil/profil_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: const Color(0xFF1A1A1A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        height: 84,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          border: Border(
            top: BorderSide(color: Color(0xFF000000), width: 0.65),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  0,
                  'assets/icon/icon_home.png',
                  l10n.home,
                ),
                _buildNavItem(
                  context,
                  1,
                  'assets/icon/Icon_servis.png',
                  l10n.service,
                ),
                _buildNavItem(context, 2, 'assets/icon/Icon_tips.png', 'Tips'),
                _buildNavItem(
                  context,
                  3,
                  'assets/icon/ikon_profil.png',
                  l10n.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (selectedIndex == index) return; // Already on this page

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const DashboardPage();
        break;
      case 1:
        targetPage = const MaintenancePage();
        break;
      case 2:
        targetPage = const TipsPerawatanPage();
        break;
      case 3:
        targetPage = const ProfilPage();
        break;
      default:
        return;
    }

    // Pop all routes and push new one
    Navigator.of(
      context,
    ).pushAndRemoveUntil(SmoothPageRoute(page: targetPage), (route) => false);
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconPath,
    String label,
  ) {
    final bool isActive = selectedIndex == index;
    const Color activeColor = Color(0xFF6B7C4F);
    const Color inactiveColor = Color(0xFF99A1AF);

    return Flexible(
      child: InkWell(
        onTap: () => _handleNavigation(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: isActive ? activeColor : inactiveColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
