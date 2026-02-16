import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:motorcycle_management/features/profil/tambah_tips_page.dart';
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
import '../../core/services/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedTabIndex = 0;

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
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                // Clear authentication data
                await AuthService().clearAuth();
                
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
            // Profile Header Section
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  _buildHeaderWithMenu(context),
                  const SizedBox(height: 8),
                  _buildProfileHeader(context),
                  const SizedBox(height: 16),
                  _buildStatsRow(context),
                  const SizedBox(height: 22),
                  _buildEditProfileButton(context),
                  const SizedBox(height: 16),
                  _buildCreateTipsButton(context),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            // Tabs
            _buildTabBar(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(children: [_buildTipsGrid(context)]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
      ),
    );
  }

  Widget _buildHeaderWithMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              // Show bottom sheet or navigate to settings
              _showMoreMenu(context);
            },
            icon: Icon(Icons.menu, color: colorScheme.onSurface, size: 24),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Menu Items
                Column(
                  children: [
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.notifications_outlined,
                      title: l10n.notificationSettings,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const NotifikasiSettingPage()),
                        );
                      },
                    ),
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.security_outlined,
                      title: l10n.privacySecurity,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const PrivasiDanKeamananPage()),
                        );
                      },
                    ),
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.tune_outlined,
                      title: l10n.appPreferences,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const PreferensiAplikasiPage()),
                        );
                      },
                    ),
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: l10n.helpSupport,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const BantuanDukunganPage()),
                        );
                      },
                    ),
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.info_outline,
                      title: l10n.about,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const TentangPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Logout Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context);
                  },
                  child: Container(
                    height: 57,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuModalItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 57,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Avatar
        Container(
          width: 96,
          height: 96,
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
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Name
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
        const SizedBox(height: 4),
        // Email
        Text(
          'ahmad.rifai@example.com',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatColumn(context, '2', l10n.statMotor),
        const SizedBox(width: 32),
        _buildStatColumn(context, '3', l10n.statTrip),
        const SizedBox(width: 32),
        _buildStatColumn(context, '97', l10n.statTotalKm),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
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

  Widget _buildEditProfileButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SmoothPageRoute(page: const EditProfilPage()),
          );
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              l10n.editProfile,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.65,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Template Saya',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _selectedTabIndex == 0
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      color: _selectedTabIndex == 0
                          ? colorScheme.primary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Disimpan',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _selectedTabIndex == 1
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      color: _selectedTabIndex == 1
                          ? colorScheme.primary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsGrid(BuildContext context) {
    final tips = [
      {
        'badge': 'Trending',
        'badgeColor': const Color(0xFFFF6467),
        'title': 'Cara Mudah Ganti Filter Udara PCX',
        'description': 'Panduan lengkap mengganti filter udara motor matic',
        'distance': '5000 km',
        'rating': '4.8',
        'likes': '42',
        'shares': '12',
      },
      {
        'badge': 'Terbukti',
        'badgeColor': const Color(0xFF6B7C4F),
        'title': 'Tips Hemat Bahan Bakar Motor Matic',
        'description': 'Trik berkendara hemat BBM untuk motor matic di per',
        'distance': '2000 km',
        'rating': '4.5',
        'likes': '28',
        'shares': '8',
      },
      {
        'badge': 'AI',
        'badgeColor': const Color(0xFFC27AFF),
        'title': 'Perawatan Ban Motor untuk Musim Hujan',
        'description': 'Cara merawat dan mengecek kondisi ban saat musim h',
        'distance': '3000 km',
        'rating': '4.7',
        'likes': '35',
        'shares': '15',
      },
      {
        'badge': 'Trending',
        'badgeColor': const Color(0xFFFF6467),
        'title': 'Optimasi Performa Mesin Sport 150cc',
        'description': 'Perawatan khusus untuk motor sport harian',
        'distance': '4000 km',
        'rating': '4.9',
        'likes': '56',
        'shares': '20',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return _buildTipCard(context, tips[index]);
      },
    );
  }

  Widget _buildTipCard(BuildContext context, Map<String, dynamic> tip) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.65, 12.65, 12.65, 12.65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (tip['badgeColor'] as Color).withValues(alpha: 0.2),
                border: Border.all(
                  color: (tip['badgeColor'] as Color).withValues(alpha: 0.3),
                  width: 0.65,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tip['badge'] == 'Trending'
                        ? Icons.trending_up
                        : tip['badge'] == 'AI'
                        ? Icons.auto_awesome
                        : Icons.verified,
                    size: 12,
                    color: tip['badgeColor'] as Color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tip['badge'] as String,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: tip['badgeColor'] as Color,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              tip['title'] as String,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.43,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              tip['description'] as String,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                height: 1.33,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Distance
            Row(
              children: [
                Icon(Icons.speed, size: 12, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  tip['distance'] as String,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.primary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stats
            Row(
              children: [
                Icon(Icons.star, size: 12, color: const Color(0xFFF0B100)),
                const SizedBox(width: 4),
                Text(
                  tip['rating'] as String,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.33,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.favorite_border,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  tip['likes'] as String,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.33,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.share_outlined,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  tip['shares'] as String,
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
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTipsButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SmoothPageRoute(page: const TambahTipsPage()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Buat Tips Perawatan',
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
    );
  }
}
