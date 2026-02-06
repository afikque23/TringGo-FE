import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class PrivasiDanKeamananPage extends StatefulWidget {
  const PrivasiDanKeamananPage({super.key});

  @override
  State<PrivasiDanKeamananPage> createState() => _PrivasiDanKeamananPageState();
}

class _PrivasiDanKeamananPageState extends State<PrivasiDanKeamananPage> {
  // Privacy Settings
  bool _shareLocation = true;
  bool _shareTripData = false;
  bool _analyticsUsage = true;

  // Account Security
  bool _twoFactorAuth = false;

  void _showDeleteAccountConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteAccount,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.error,
            ),
          ),
          content: Text(
            l10n.deleteAccountConfirm,
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
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
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
                // TODO: Implement delete account logic
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Fitur hapus akun akan segera tersedia',
                    ),
                    backgroundColor: colorScheme.error,
                  ),
                );
              },
              child: Text(
                l10n.deleteAccount,
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

  void _changePassword() {
    // TODO: Navigate to change password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ubah password akan segera tersedia'),
        backgroundColor: Color(0xFF6B7C4F),
      ),
    );
  }

  void _manageActiveSessions() {
    // TODO: Navigate to active sessions page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur kelola sesi aktif akan segera tersedia'),
        backgroundColor: Color(0xFF6B7C4F),
      ),
    );
  }

  void _downloadMyData() {
    // TODO: Implement download data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memproses unduhan data Anda...'),
        backgroundColor: Color(0xFF6B7C4F),
      ),
    );
  }

  void _clearCache() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.clearCache,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            l10n.clearCacheConfirm,
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
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
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
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cache berhasil dihapus'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
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
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Privacy Settings Section
                    _buildPrivacySettingsSection(),
                    const SizedBox(height: 16),
                    // Account Security Section
                    _buildAccountSecuritySection(),
                    const SizedBox(height: 16),
                    // Data Management Section
                    _buildDataManagementSection(),
                    const SizedBox(height: 16),
                    // Danger Zone
                    _buildDangerZone(),
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

  Widget _buildHeader() {
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
                    l10n.privacySecurity,
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
                    'Lindungi akun dan data Anda',
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
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
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
                      Icons.lock_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.privacySettings,
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
          // Items
          _buildToggleItem(
            title: l10n.shareLocation,
            subtitle: l10n.shareLocationDesc,
            value: _shareLocation,
            onChanged: (value) => setState(() => _shareLocation = value),
            showDivider: true,
          ),
          _buildToggleItem(
            title: l10n.shareTripData,
            subtitle: l10n.shareTripDataDesc,
            value: _shareTripData,
            onChanged: (value) => setState(() => _shareTripData = value),
            showDivider: true,
          ),
          _buildToggleItem(
            title: l10n.analyticsUsage,
            subtitle: l10n.analyticsUsageDesc,
            value: _analyticsUsage,
            onChanged: (value) => setState(() => _analyticsUsage = value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSecuritySection() {
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
                      Icons.shield_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.accountSecurity,
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
          // Items
          _buildToggleItem(
            title: l10n.twoFactorAuth,
            subtitle: l10n.twoFactorAuthDesc,
            value: _twoFactorAuth,
            onChanged: (value) => setState(() => _twoFactorAuth = value),
            showDivider: true,
          ),
          _buildActionItem(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            subtitle: l10n.changePasswordDesc,
            onTap: _changePassword,
            showDivider: true,
          ),
          _buildActionItem(
            icon: Icons.devices_outlined,
            title: l10n.activeSessions,
            subtitle: l10n.activeSessionsDesc,
            onTap: _manageActiveSessions,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
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
                      Icons.storage_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.dataManagement,
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
          // Items
          _buildActionItem(
            icon: Icons.download_outlined,
            title: l10n.downloadMyData,
            subtitle: l10n.downloadMyDataDesc,
            onTap: _downloadMyData,
            showDivider: true,
          ),
          _buildActionItem(
            icon: Icons.delete_outline,
            title: l10n.clearCache,
            subtitle: l10n.clearCacheDesc,
            onTap: _clearCache,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Text
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
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.67,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Toggle Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colorScheme.onPrimary,
              activeTrackColor: colorScheme.primary,
              inactiveThumbColor: colorScheme.onSurface,
              inactiveTrackColor: colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.65,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Text
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
              const SizedBox(width: 16),
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, size: 20, color: colorScheme.error),
              const SizedBox(width: 8),
              Text(
                l10n.dangerZone,
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
          const SizedBox(height: 4),
          Text(
            'Tindakan ini tidak dapat dibatalkan',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          // Delete Account Button
          GestureDetector(
            onTap: _showDeleteAccountConfirmation,
            child: Container(
              height: 49,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.5),
                  width: 0.65,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.deleteAccount,
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
}
