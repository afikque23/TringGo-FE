import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/model/content_model.dart';
import '../../../core/services/content_service.dart';
import '../../../l10n/app_localizations.dart';

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

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
                    'terms',
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
                          _buildFooter(context),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(context),
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
                        _buildSection6(context),
                        const SizedBox(height: 16),
                        _buildSection7(context),
                        const SizedBox(height: 16),
                        _buildSection8(context),
                        const SizedBox(height: 16),
                        _buildSection9(context),
                        const SizedBox(height: 16),
                        _buildContactSection(context),
                        const SizedBox(height: 16),
                        _buildFooter(context),
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
          : l10n.termsAndConditions;

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
          icon: Icons.description_outlined,
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
                      l10n.termsAndConditions,
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
                      l10n.effectiveSince30Jan2026,
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
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_outlined, size: 24, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeToMotoTracker,
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
                  l10n.termsWelcomeDesc,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.85),
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
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section1AcceptanceTitle,
      children: [
        _buildParagraph(context, l10n.acceptanceIntro),
        const SizedBox(height: 12),
        _buildBulletList(context, [
          l10n.ageRequirement,
          l10n.legalCapacity,
          l10n.accurateInfo,
          l10n.complyWithLaws,
        ]),
      ],
    );
  }

  Widget _buildSection2(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.person_outline,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section2UserAccountTitle,
      children: [
        _buildSubsectionTitle(context, l10n.accountResponsibility),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.accountSecurityResponsibility,
          l10n.dontShareCredentials,
          l10n.reportSuspiciousActivity,
          l10n.noLiabilityForNegligence,
        ]),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, l10n.dataAccuracy),
        const SizedBox(height: 8),
        _buildParagraph(context, l10n.dataAccuracyDesc),
      ],
    );
  }

  Widget _buildSection3(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section3ServiceUseTitle,
      children: [
        _buildSubsectionTitle(context, l10n.permittedUse),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.permittedUseItem1,
          l10n.permittedUseItem2,
          l10n.permittedUseItem3,
          l10n.permittedUseItem4,
        ]),
        const SizedBox(height: 16),
        _buildSubsectionTitle(context, l10n.serviceLimitations),
        const SizedBox(height: 8),
        _buildParagraph(context, l10n.asIsProvision),
        const SizedBox(height: 8),
        _buildBulletList(context, [
          l10n.limitationItem1,
          l10n.limitationItem2,
          l10n.limitationItem3,
          l10n.limitationItem4,
        ]),
      ],
    );
  }

  Widget _buildSection4(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.block,
      iconColor: const Color(0xFFFF6467),
      title: l10n.section4ProhibitedTitle,
      children: [
        _buildParagraph(context, l10n.prohibitedIntro, isWhite: true),
        const SizedBox(height: 12),
        _buildBulletList(context, [
          l10n.prohibitedItem1,
          l10n.prohibitedItem2,
          l10n.prohibitedItem3,
          l10n.prohibitedItem4,
          l10n.prohibitedItem5,
          l10n.prohibitedItem6,
          l10n.prohibitedItem7,
        ]),
      ],
    );
  }

  Widget _buildSection5(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFFFB900),
      title: l10n.section5GpsLocationTitle,
      children: [
        _buildBulletList(context, [
          l10n.gpsItem1,
          l10n.gpsItem2,
          l10n.gpsItem3,
          l10n.gpsItem4,
          l10n.gpsItem5,
        ]),
      ],
    );
  }

  Widget _buildSection6(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.menu_book_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section6IntellectualPropertyTitle,
      children: [
        _buildParagraph(context, l10n.intellectualPropertyDesc1),
        const SizedBox(height: 12),
        _buildParagraph(context, l10n.intellectualPropertyDesc2, isWhite: true),
      ],
    );
  }

  Widget _buildSection7(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.error_outline,
      iconColor: const Color(0xFFFF6467),
      title: l10n.section7LiabilityLimitTitle,
      children: [
        _buildParagraph(context, l10n.liabilityIntro),
        const SizedBox(height: 12),
        _buildBulletList(context, [
          l10n.liabilityItem1,
          l10n.liabilityItem2,
          l10n.liabilityItem3,
          l10n.liabilityItem4,
          l10n.liabilityItem5,
        ]),
      ],
    );
  }

  Widget _buildSection8(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.warning_outlined,
      iconColor: const Color(0xFFFFB900),
      title: l10n.section8SuspensionTitle,
      children: [
        _buildParagraph(context, l10n.suspensionIntro),
        const SizedBox(height: 12),
        _buildBulletList(context, [
          l10n.suspensionItem1,
          l10n.suspensionItem2,
          l10n.suspensionItem3,
          l10n.suspensionItem4,
        ]),
      ],
    );
  }

  Widget _buildSection9(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      context,
      icon: Icons.menu_book_outlined,
      iconColor: const Color(0xFF6B7C4F),
      title: l10n.section9ChangesTitle,
      children: [_buildParagraph(context, l10n.changesDesc)],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.legalQuestionsTitle,
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
            l10n.legalContactIntro,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withOpacity(0.85),
              height: 1.64,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.legalEmail,
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

  Widget _buildFooter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.termsFooter1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 1.33,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.termsFooter2,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
                Icon(icon, size: 20, color: iconColor),
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

  Widget _buildParagraph(
    BuildContext context,
    String text, {
    bool isWhite = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isWhite ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        height: 1.64,
      ),
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
