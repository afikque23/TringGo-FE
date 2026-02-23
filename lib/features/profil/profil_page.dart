import 'package:flutter/material.dart';
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
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/model/user_profile_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  UserProfileModel? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await ProfileService().getProfile();

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

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
                // Store the navigator and close confirmation dialog
                final navigator = Navigator.of(context);
                navigator.pop(); // Close confirmation dialog

                try {
                  print('🔓 Starting logout process...');

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  // Unregister FCM token before logout (with timeout)
                  try {
                    await NotificationService.instance
                        .unregisterToken()
                        .timeout(const Duration(seconds: 5));
                    print('✅ FCM token unregistered');
                  } catch (e) {
                    print('⚠️ Failed to unregister FCM token: $e');
                    // Continue with logout even if unregister fails
                  }

                  // Clear authentication data (calls logout API and clears tokens)
                  await ApiClient().logout();
                  print('✅ Auth tokens cleared');

                  // Navigate to login page and remove all routes (including loading dialog)
                  // Using the stored navigator to ensure we're using the correct context
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );

                  print('✅ Logout successful - Navigated to login page');
                } catch (e) {
                  print('⚠️ Logout error: $e');

                  // Even if API fails, still navigate to login
                  // This will also remove the loading dialog
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
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

  /// Test refresh token mechanism (DEBUG)
  Future<void> _testRefreshToken() async {
    final colorScheme = Theme.of(context).colorScheme;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🧪 MANUAL REFRESH TOKEN TEST');

      // Get current tokens from storage
      final authStorage = ApiClient().authStorage;
      final currentAccessToken = await authStorage.getAccessToken();
      final currentRefreshToken = await authStorage.getRefreshToken();

      print(
        'Current Access Token: ${currentAccessToken?.substring(0, 30) ?? 'NULL'}...',
      );
      print(
        'Current Refresh Token: ${currentRefreshToken?.substring(0, 30) ?? 'NULL'}...',
      );

      // Try to make a request that will trigger refresh
      print('Making API request to trigger refresh...');
      final apiClient = ApiClient();
      final response = await apiClient.get('/profile');

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Request successful (token refreshed if needed)');
      } else {
        print('❌ Request failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }

      // Get tokens after refresh attempt
      final newAccessToken = await authStorage.getAccessToken();
      final newRefreshToken = await authStorage.getRefreshToken();

      print('After Request:');
      print('Access Token: ${newAccessToken?.substring(0, 30) ?? 'NULL'}...');
      print('Refresh Token: ${newRefreshToken?.substring(0, 30) ?? 'NULL'}...');
      print('Token Changed: ${currentAccessToken != newAccessToken}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            response.statusCode == 200 ? '✅ Test Success' : '❌ Test Failed',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Code: ${response.statusCode}',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Token Changed: ${currentAccessToken != newAccessToken}',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check console logs for details',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Test error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '❌ Test Error',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.error,
            ),
          ),
          content: Text(
            e.toString(),
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                    // DEBUG: Test Refresh Token
                    _buildMenuModalItem(
                      context: context,
                      icon: Icons.bug_report_outlined,
                      title: '🔧 Test Refresh Token (Debug)',
                      onTap: () {
                        Navigator.pop(context);
                        _testRefreshToken();
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

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text(
            _error ?? 'Failed to load profile',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Avatar
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: _profile!.avatar == null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(100),
            image: _profile!.avatar != null
                ? DecorationImage(
                    image: NetworkImage(_profile!.avatar!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profile!.avatar == null
              ? Center(
                  child: Text(
                    _profile!.initials,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          _profile!.name,
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
          _profile!.email,
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
    final l10n = AppLocalizations.of(context)!;

    final totalVehicles = _profile?.stats.totalVehicles.toString() ?? '-';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatColumn(context, totalVehicles, l10n.statMotor),
        const SizedBox(width: 32),
        _buildStatColumn(context, '4', 'Template'),
        const SizedBox(width: 32),
        _buildStatColumn(context, '161', 'Likes'),
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
        onTap: () async {
          final result = await Navigator.push(
            context,
            SmoothPageRoute(page: const EditProfilPage()),
          );

          // Refresh profile if updated
          if (result != null && result is UserProfileModel) {
            setState(() {
              _profile = result;
            });
          }
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
