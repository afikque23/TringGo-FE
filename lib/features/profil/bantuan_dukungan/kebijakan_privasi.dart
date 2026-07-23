import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/model/content_model.dart';
import '../../../core/services/content_service.dart';
import '../../../l10n/app_localizations.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

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
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<DocumentSectionModel>>(
                  future: ContentService().getDocumentSections(
                    'privacy',
                    mergeAll: true,
                  ),
                  builder: (context, snapshot) {
                    final dynamicSections = snapshot.data ?? const [];
                    if (dynamicSections.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildDynamicDocumentSections(
                            context,
                            dynamicSections,
                          ),
                          const SizedBox(height: 16),
                          _buildContactSection(context),
                          const SizedBox(height: 16),
                          _buildFooter(),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommitmentSection(context),
                        const SizedBox(height: 16),
                        _buildSection1(context),
                        const SizedBox(height: 16),
                        _buildSection2(context),
                        const SizedBox(height: 16),
                        _buildSection3(context),
                        const SizedBox(height: 16),
                        _buildSection4(context),
                        const SizedBox(height: 16),
                        _buildSection5(context),
                        const SizedBox(height: 16),
                        _buildContactSection(context),
                        const SizedBox(height: 16),
                        _buildFooter(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicDocumentSections(
    BuildContext context,
    List<DocumentSectionModel> sections,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return sections.map((section) {
      final title = section.title.isNotEmpty
          ? section.title
          : l10n.privacyPolicy;

      final children = <Widget>[];

      for (final paragraph in section.paragraphs) {
        children.add(_buildParagraph(context, paragraph));
        children.add(const SizedBox(height: 12));
      }
      if (children.isNotEmpty) {
        children.removeLast();
      }

      if (section.bullets.isNotEmpty) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: 12));
        }
        children.add(_buildBulletList(context, section.bullets));
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildSectionContainer(
          context,
          icon: Icons.shield_outlined,
          iconColor: colorScheme.primary,
          title: title,
          children: children,
        ),
      );
    }).toList();
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacyPolicy,
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
                      l10n.lastUpdated30Jan2026,
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
      ),
    );
  }

  Widget _buildCommitmentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 24, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ourPrivacyCommitment,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.privacyCommitmentDesc,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.64,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection1(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.storage_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section1Title,
      children: [
        _buildSubsectionTitle(context, l10n.accountInfoSubtitle),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.accountInfoItem1,
          l10n.accountInfoItem2,
          l10n.accountInfoItem3,
        ]),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, l10n.vehicleDataSubtitle),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.vehicleDataItem1,
          l10n.vehicleDataItem2,
          l10n.vehicleDataItem3,
        ]),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, l10n.tripLocationDataSubtitle),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.tripLocationItem1,
          l10n.tripLocationItem2,
          l10n.tripLocationItem3,
        ]),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, l10n.maintenanceHistorySubtitle),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.maintenanceItem1,
          l10n.maintenanceItem2,
          l10n.maintenanceItem3,
        ]),
      ],
    );
  }

  Widget _buildSection2(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.settings_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section2Title,
      children: [
        _buildInfoItem(
          context,
          title: l10n.personalizationTitle,
          description: l10n.personalizationDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.maintenancePredictionTitle,
          description: l10n.maintenancePredictionDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.notificationsAlertsTitle,
          description: l10n.notificationsAlertsDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.serviceImprovementTitle,
          description: l10n.serviceImprovementDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.securityTitle,
          description: l10n.securityDesc,
        ),
      ],
    );
  }

  Widget _buildSection3(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.lock_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section3Title,
      children: [
        _buildInfoItem(
          context,
          title: l10n.encryptionTitle,
          description: l10n.encryptionDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.localStorageTitle,
          description: l10n.localStorageDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.limitedAccessTitle,
          description: l10n.limitedAccessDesc,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: l10n.regularAuditTitle,
          description: l10n.regularAuditDesc,
        ),
      ],
    );
  }

  Widget _buildSection4(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionContainer(
      context,
      icon: Icons.share_outlined,
      iconColor: colorScheme.primary,
      title: '4. Pembagian Data',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Kami TIDAK akan membagikan data Anda kepada pihak ketiga untuk tujuan komersial, iklan, atau pemasaran tanpa izin eksplisit Anda.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, 'Pengecualian:'),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          'Jika diwajibkan oleh hukum atau perintah pengadilan',
          'Dengan vendor analytics (data anonim untuk statistik)',
          'Dengan persetujuan eksplisit Anda untuk integrasi pihak ketiga',
        ]),
      ],
    );
  }

  Widget _buildSection5(BuildContext context) {
    return _buildSectionContainer(
      context,
      icon: Icons.verified_user_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: '5. Hak Anda',
      children: [
        _buildInfoItem(
          context,
          title: 'Akses Data:',
          description:
              'Anda dapat mengunduh semua data Anda kapan saja melalui menu "Export Data".',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: 'Koreksi:',
          description:
              'Update atau perbaiki informasi pribadi Anda langsung di aplikasi.',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: 'Penghapusan:',
          description:
              'Hapus akun dan semua data terkait secara permanen melalui "Hapus Akun".',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          title: 'Opt-out:',
          description:
              'Nonaktifkan tracking, analytics, atau notifikasi kapan saja.',
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📧 Hubungi Kami',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, hubungi:',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.64,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'privacy@tringgo.id',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.primary,
              height: 1.64,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '© 2026 TringGo. Kebijakan ini dapat diperbarui sewaktu-waktu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 1.33,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Anda akan diberi tahu melalui email jika ada perubahan signifikan.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.64,
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            height: 1.64,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.64,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.64,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.64,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
