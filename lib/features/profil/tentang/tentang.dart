import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    // App Branding
                    _buildBrandingCard(context),
                    const SizedBox(height: 16),
                    // About App Section
                    _buildAboutAppSection(context),
                    const SizedBox(height: 16),
                    // Features Section
                    _buildFeaturesSection(context),
                    const SizedBox(height: 16),
                    // Values Section
                    _buildValuesSection(context),
                    const SizedBox(height: 16),
                    // Version Info Section
                    _buildVersionInfoSection(context),
                    const SizedBox(height: 16),
                    // Team Section
                    _buildTeamSection(context),
                    const SizedBox(height: 16),
                    // Social Media Section
                    _buildSocialMediaSection(context),
                    const SizedBox(height: 16),
                    // Made with Love Card
                    _buildMadeWithLoveCard(context),
                    const SizedBox(height: 16),
                    // Footer
                    _buildFooter(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                      height: 1.33,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    l10n.appVersionInfo,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF99A1AF),
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/icon/app_ikon.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App Name
          Text(
            'MotoTracker',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 8),
          // Tagline
          Text(
            'Your Smart Motorcycle Companion',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 16),
          // Version Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  height: 1.43,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  height: 1.43,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Build 2026.01.30',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  height: 1.43,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAppSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'MotoTracker adalah aplikasi manajemen sepeda motor yang dirancang khusus untuk membantu Anda merawat, melacak, dan mengoptimalkan kinerja kendaraan. Dengan teknologi GPS dan pengingat service otomatis, kami memastikan motor Anda selalu dalam kondisi prima.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.64,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fitur Unggulan',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Features List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  context,
                  icon: Icons.route_outlined,
                  title: 'GPS Tracking',
                  description: 'Lacak setiap perjalanan dengan presisi GPS',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.build_outlined,
                  title: 'Smart Maintenance',
                  description: 'Pengingat service otomatis dan prediktif',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.motorcycle_outlined,
                  title: 'Multi Kendaraan',
                  description: 'Kelola semua motor Anda dalam satu aplikasi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              Text(
                description,
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
      ],
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nilai Kami',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Values List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  context,
                  icon: Icons.code_outlined,
                  title: 'Pengembangan',
                  description: 'Dibangun dengan teknologi terkini',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'Passion',
                  description: 'Dibuat oleh dan untuk pecinta motor',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Indonesia',
                  description: 'Dikembangkan untuk komunitas Indonesia',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfoSection(BuildContext context) {
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
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Versi',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Version Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildVersionRow(context, l10n.appVersion, '1.0.0'),
                const SizedBox(height: 12),
                _buildVersionRow(context, l10n.buildNumber, '2026.01.30'),
                const SizedBox(height: 12),
                _buildVersionRow(context, l10n.lastUpdated, '30 Januari 2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.43,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tim Kami',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Team Members
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTeamMember(
                  context,
                  title: 'Product Designer',
                  subtitle: 'UI/UX Team',
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context,
                  title: 'Developer',
                  subtitle: 'Engineering Team',
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context,
                  title: 'Data Analyst',
                  subtitle: 'Analytics Team',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.43,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.motorcycle_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection(BuildContext context) {
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
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.followUs,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Social Media Links
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSocialMediaItem(
                  context,
                  icon: Icons.language,
                  text: '@mototracker.id',
                  onTap: () {
                    // TODO: Open Instagram
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialMediaItem(
                  context,
                  icon: Icons.alternate_email,
                  text: '@mototracker',
                  onTap: () {
                    // TODO: Open Twitter
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialMediaItem(
                  context,
                  icon: Icons.code,
                  text: 'github.com/mototracker',
                  onTap: () {
                    // TODO: Open GitHub
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMadeWithLoveCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.primary.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.madeWithLove,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Untuk komunitas pengendara motor Indonesia 🇮🇩',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const Text(
          '© 2026 MotoTracker. All rights reserved.',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 1.33,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Open Privacy Policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka kebijakan privasi...'),
                    backgroundColor: Color(0xFF6B7C4F),
                  ),
                );
              },
              child: Text(
                l10n.privacyPolicy,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A7282),
                  height: 1.33,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '•',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6A7282),
                height: 1.33,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                // TODO: Open Terms & Conditions
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka syarat & ketentuan...'),
                    backgroundColor: Color(0xFF6B7C4F),
                  ),
                );
              },
              child: Text(
                l10n.termsConditions,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A7282),
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
