import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'page_transition.dart';
import '../dashboard/dashboard.dart';
import '../servis/service.dart';
import '../profil/profil_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness:
            colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, 'assets/icon/icon_home.png', l10n.home),
              _buildNavItem(
                context,
                1,
                'assets/icon/Icon_servis.png',
                l10n.service,
              ),
              _buildNavItem(
                context,
                2,
                'assets/icon/ikon_profil.png',
                l10n.profile,
              ),
            ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () => _handleNavigation(context, index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: isActive ? colorScheme.primary : colorScheme.secondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isActive ? colorScheme.primary : colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
