import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../widget/bottom_navbar.dart';
import '../widget/page_transition.dart';
import 'edit_profil.dart';
import 'notifikasi/notifikasi_setting.dart';
import 'privasi_keamanan/privasi_dan_keamanan.dart';
import 'preferensi_aplikasi/preferensi_aplikasi.dart';
import 'bantuan_dukungan/bantuan_dukungan.dart';
import 'tentang/tentang.dart';
import '../auth/login_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.signOut,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            l10n.signOutConfirm,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to login page and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  SmoothPageRoute(page: const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(
                l10n.signOut,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileHeaderTitle,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profileHeaderSubtitle,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 16),
                    _buildStatsCard(context),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context),
                    const SizedBox(height: 16),
                    _buildDangerZoneCard(context),
                    const SizedBox(height: 16),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(24.65, 24.65, 24.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Info
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmad Rifai',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      'ahmad.rifai@example.com',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Edit Profile Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const EditProfilPage()),
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.editProfile,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTitle,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context: context,
                icon: Icons.motorcycle_outlined,
                value: '2',
                label: l10n.statMotor,
              ),
              _buildStatItem(
                context: context,
                icon: Icons.route_outlined,
                value: '3000',
                label: l10n.statTrip,
              ),
              _buildStatItem(
                context: context,
                icon: Icons.speed_outlined,
                value: '97000',
                label: l10n.statTotalKm,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 24, color: colorScheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: l10n.notificationSettings,
            subtitle: l10n.manageNotifications,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const NotifikasiSettingPage()),
              );
            },
          ),
          _buildDivider(context),
          _buildSettingItem(
            context: context,
            icon: Icons.security_outlined,
            title: l10n.privacySecurity,
            subtitle: l10n.accountPrivacySecurity,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const PrivasiDanKeamananPage()),
              );
            },
          ),
          _buildDivider(context),
          _buildSettingItem(
            context: context,
            icon: Icons.tune_outlined,
            title: l10n.appPreferences,
            subtitle: l10n.displayLanguageUnits,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const PreferensiAplikasiPage()),
              );
            },
          ),
          _buildDivider(context),
          _buildSettingItem(
            context: context,
            icon: Icons.help_outline,
            title: l10n.helpSupport,
            subtitle: l10n.faqContactSupport,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const BantuanDukunganPage()),
              );
            },
          ),
          _buildDivider(context),
          _buildSettingItem(
            context: context,
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.appVersionInfo,
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const TentangPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 0.65,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.outlineVariant,
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dangerZone,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dangerZoneDescription,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          // Logout Button
          GestureDetector(
            onTap: () {
              _showLogoutConfirmation(context);
            },
            child: Container(
              height: 49,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.5),
                  width: 0.65,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_outlined,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.signOut,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.error,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.footerAppName,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.33,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.footerCopyright,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            height: 1.33,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
