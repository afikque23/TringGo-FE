import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/model/content_model.dart';
import '../../../core/services/content_service.dart';
import '../../../l10n/app_localizations.dart';

class TentangPage extends StatefulWidget {
  const TentangPage({super.key});

  @override
  State<TentangPage> createState() => _TentangPageState();
}

class _TentangPageState extends State<TentangPage> {
  late final Future<List<DocumentSectionModel>> _aboutFuture;

  @override
  void initState() {
    super.initState();
    _aboutFuture = ContentService().getDocumentSections('about');
  }

  String _normalizeText(String raw) {
    var value = raw;
    value = value.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    return value.trim();
  }

  bool _isLikelyVersionOrBuildLine(String text) {
    final value = text.trim();
    if (value.isEmpty) return false;
    return RegExp(r'\b(version|build)\b', caseSensitive: false).hasMatch(value);
  }

  bool _isLikelyTaglineLine(String text) {
    final value = text.trim().toLowerCase();
    return value == 'your smart motorcycle companion';
  }

  String? _stripIrrelevantLines(String? text) {
    if (text == null) return null;
    final normalized = _normalizeText(text);
    if (normalized.isEmpty) return null;

    final lines = normalized
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !_isLikelyVersionOrBuildLine(e))
        .where((e) => !_isLikelyTaglineLine(e))
        .toList();

    if (lines.isEmpty) return null;
    return lines.join('\n');
  }

  String? _pickBestAboutDescription(List<DocumentSectionModel> sections) {
    if (sections.isEmpty) return null;

    final candidates = <String>[];
    for (final section in sections) {
      if (section.paragraphs.isEmpty) continue;
      final joined = section.paragraphs.map(_normalizeText).join('\n\n');
      final cleaned = _stripIrrelevantLines(joined);
      if (cleaned != null && cleaned.isNotEmpty) {
        candidates.add(cleaned);
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  _TitleDesc _splitTitleDesc(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return const _TitleDesc(title: '', description: '');

    const separators = <String>[' - ', ' — ', ': ', ' : '];
    for (final sep in separators) {
      final idx = value.indexOf(sep);
      if (idx > 0) {
        final title = value.substring(0, idx).trim();
        final desc = value.substring(idx + sep.length).trim();
        return _TitleDesc(title: title, description: desc);
      }
    }

    return _TitleDesc(title: value, description: '');
  }

  List<_TitleDesc> _pick3TitleDesc(
    List<_TitleDesc> primary,
    List<_TitleDesc> fallback,
  ) {
    final picked = <_TitleDesc>[];
    picked.addAll(primary.where((e) => e.title.trim().isNotEmpty));
    picked.addAll(fallback.where((e) => e.title.trim().isNotEmpty));
    return picked.take(3).toList(growable: false);
  }

  List<String> _pick3Strings(List<String> primary, List<String> fallback) {
    final picked = <String>[];
    picked.addAll(primary.map((e) => e.trim()).where((e) => e.isNotEmpty));
    picked.addAll(fallback.map((e) => e.trim()).where((e) => e.isNotEmpty));
    return picked.take(3).toList(growable: false);
  }

  _AboutDynamicText _extractAboutDynamicText(
    BuildContext context,
    List<DocumentSectionModel> sections,
  ) {
    final fallback = _AboutDynamicText.empty();
    if (sections.isEmpty) return fallback;

    String? aboutTitle;
    String? aboutDescription;

    String? featuresTitle;
    List<_TitleDesc> features = const [];

    String? valuesTitle;
    List<_TitleDesc> values = const [];

    String? teamTitle;
    List<_TitleDesc> teamMembers = const [];

    String? socialTitle;
    List<String> socialLinks = const [];

    String? madeWithLoveSubtitle;
    String? copyright;

    // Convention (by index):
    // 0 about, 1 features, 2 values, 3 team, 4 social, 5 made-with-love, 6 footer
    if (sections.isNotEmpty) {
      final s = sections[0];
      aboutTitle = s.title.isNotEmpty ? s.title : null;
      // About description: pick best paragraph block across sections,
      // while stripping tagline/version/build lines.
      aboutDescription = _pickBestAboutDescription(sections);
    }

    if (sections.length >= 2) {
      final s = sections[1];
      featuresTitle = s.title.isNotEmpty ? s.title : null;
      // Features should be a list, not a long paragraph.
      // Prefer bullets; if using paragraphs, only accept 'Title - Description' format.
      final rawItems = <String>[...s.bullets];
      final fromParagraphs = rawItems.isEmpty;
      if (fromParagraphs) rawItems.addAll(s.paragraphs);

      features = rawItems
          .map(_normalizeText)
          .map(_splitTitleDesc)
          .where((e) => e.title.isNotEmpty)
          .where((e) => !fromParagraphs || e.description.trim().isNotEmpty)
          .toList();
    }

    if (sections.length >= 3) {
      final s = sections[2];
      valuesTitle = s.title.isNotEmpty ? s.title : null;
      final rawItems = <String>[...s.bullets];
      final fromParagraphs = rawItems.isEmpty;
      if (fromParagraphs) rawItems.addAll(s.paragraphs);
      values = rawItems
          .map(_normalizeText)
          .map(_splitTitleDesc)
          .where((e) => e.title.isNotEmpty)
          .where((e) => !fromParagraphs || e.description.trim().isNotEmpty)
          .toList();
    }

    if (sections.length >= 4) {
      final s = sections[3];
      teamTitle = s.title.isNotEmpty ? s.title : null;
      final rawItems = <String>[...s.bullets];
      final fromParagraphs = rawItems.isEmpty;
      if (fromParagraphs) rawItems.addAll(s.paragraphs);
      teamMembers = rawItems
          .map(_normalizeText)
          .map(_splitTitleDesc)
          .where((e) => e.title.isNotEmpty)
          .where((e) => !fromParagraphs || e.description.trim().isNotEmpty)
          .toList();
    }

    if (sections.length >= 5) {
      final s = sections[4];
      socialTitle = s.title.isNotEmpty ? s.title : null;
      final rawItems = <String>[...s.bullets];
      if (rawItems.isEmpty) rawItems.addAll(s.paragraphs);
      socialLinks = rawItems
          .map(_normalizeText)
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (sections.length >= 6) {
      final s = sections[5];
      if (s.paragraphs.isNotEmpty) {
        madeWithLoveSubtitle = _normalizeText(s.paragraphs.first);
      } else if (s.bullets.isNotEmpty) {
        madeWithLoveSubtitle = _normalizeText(s.bullets.first);
      }
    }

    if (sections.length >= 7) {
      final s = sections[6];
      if (s.paragraphs.isNotEmpty) {
        copyright = _normalizeText(s.paragraphs.first);
      } else if (s.bullets.isNotEmpty) {
        copyright = _normalizeText(s.bullets.first);
      }
    }

    return fallback.copyWith(
      aboutTitle: aboutTitle,
      aboutDescription: aboutDescription,
      featuresTitle: featuresTitle,
      features: features,
      valuesTitle: valuesTitle,
      values: values,
      teamTitle: teamTitle,
      teamMembers: teamMembers,
      socialTitle: socialTitle,
      socialLinks: socialLinks,
      madeWithLoveSubtitle: madeWithLoveSubtitle,
      copyright: copyright,
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
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: FutureBuilder<List<DocumentSectionModel>>(
                  future: _aboutFuture,
                  builder: (context, snapshot) {
                    final sections =
                        snapshot.data ?? const <DocumentSectionModel>[];
                    final dynamicText = _extractAboutDynamicText(
                      context,
                      sections,
                    );

                    return Column(
                      children: [
                        // App Branding
                        _buildBrandingCard(context),
                        const SizedBox(height: 16),
                        // About App Section
                        _buildAboutAppSection(context, dynamicText),
                        const SizedBox(height: 16),
                        // Features Section
                        _buildFeaturesSection(context, dynamicText),
                        const SizedBox(height: 16),
                        // Values Section
                        _buildValuesSection(context, dynamicText),
                        const SizedBox(height: 16),
                        // Version Info Section
                        _buildVersionInfoSection(context),
                        const SizedBox(height: 16),
                        // Team Section
                        _buildTeamSection(context, dynamicText),
                        const SizedBox(height: 16),
                        // Social Media Section
                        _buildSocialMediaSection(context, dynamicText),
                        const SizedBox(height: 16),
                        // Made with Love Card
                        _buildMadeWithLoveCard(context, dynamicText),
                        const SizedBox(height: 16),
                        // Footer
                        _buildFooter(context, dynamicText),
                        const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildAboutAppSection(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = dynamicText.aboutTitle ?? 'Tentang Aplikasi';
    final description =
        dynamicText.aboutDescription ??
        'MotoTracker adalah aplikasi manajemen sepeda motor yang dirancang khusus untuk membantu Anda merawat, melacak, dan mengoptimalkan kinerja kendaraan. Dengan teknologi GPS dan pengingat service otomatis, kami memastikan motor Anda selalu dalam kondisi prima.';
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
                title,
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
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionTitle = dynamicText.featuresTitle ?? 'Fitur Unggulan';
    final fallbackFeatures = <_TitleDesc>[
      const _TitleDesc(
        title: 'GPS Tracking',
        description: 'Lacak setiap perjalanan dengan presisi GPS',
      ),
      const _TitleDesc(
        title: 'Smart Maintenance',
        description: 'Pengingat service otomatis dan prediktif',
      ),
      const _TitleDesc(
        title: 'Multi Kendaraan',
        description: 'Kelola semua motor Anda dalam satu aplikasi',
      ),
    ];
    final features = _pick3TitleDesc(dynamicText.features, fallbackFeatures);

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
                      sectionTitle,
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
                  title: features[0].title,
                  description: features[0].description,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.build_outlined,
                  title: features[1].title,
                  description: features[1].description,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.motorcycle_outlined,
                  title: features[2].title,
                  description: features[2].description,
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

  Widget _buildValuesSection(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionTitle = dynamicText.valuesTitle ?? 'Nilai Kami';
    final fallbackValues = <_TitleDesc>[
      const _TitleDesc(
        title: 'Pengembangan',
        description: 'Dibangun dengan teknologi terkini',
      ),
      const _TitleDesc(
        title: 'Passion',
        description: 'Dibuat oleh dan untuk pecinta motor',
      ),
      const _TitleDesc(
        title: 'Indonesia',
        description: 'Dikembangkan untuk komunitas Indonesia',
      ),
    ];
    final values = _pick3TitleDesc(dynamicText.values, fallbackValues);

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
                      sectionTitle,
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
                  title: values[0].title,
                  description: values[0].description,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: values[1].title,
                  description: values[1].description,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  context,
                  icon: Icons.language_outlined,
                  title: values[2].title,
                  description: values[2].description,
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

  Widget _buildTeamSection(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionTitle = dynamicText.teamTitle ?? 'Tim Kami';
    final fallbackMembers = <_TitleDesc>[
      const _TitleDesc(title: 'Product Designer', description: 'UI/UX Team'),
      const _TitleDesc(title: 'Developer', description: 'Engineering Team'),
      const _TitleDesc(title: 'Data Analyst', description: 'Analytics Team'),
    ];
    final members = _pick3TitleDesc(dynamicText.teamMembers, fallbackMembers);
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
                      sectionTitle,
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
                  title: members[0].title,
                  subtitle: members[0].description,
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context,
                  title: members[1].title,
                  subtitle: members[1].description,
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context,
                  title: members[2].title,
                  subtitle: members[2].description,
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

  Widget _buildSocialMediaSection(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final sectionTitle = dynamicText.socialTitle ?? l10n.followUs;
    final fallbackLinks = <String>[
      '@mototracker.id',
      '@mototracker',
      'github.com/mototracker',
    ];
    final links = _pick3Strings(dynamicText.socialLinks, fallbackLinks);
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
                      sectionTitle,
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
                  text: links[0],
                  onTap: () {
                    // TODO: Open Instagram
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialMediaItem(
                  context,
                  icon: Icons.alternate_email,
                  text: links[1],
                  onTap: () {
                    // TODO: Open Twitter
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialMediaItem(
                  context,
                  icon: Icons.code,
                  text: links[2],
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

  Widget _buildMadeWithLoveCard(
    BuildContext context,
    _AboutDynamicText dynamicText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final subtitle =
        dynamicText.madeWithLoveSubtitle ??
        'Untuk komunitas pengendara motor Indonesia 🇮🇩';
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
            subtitle,
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

  Widget _buildFooter(BuildContext context, _AboutDynamicText dynamicText) {
    final l10n = AppLocalizations.of(context)!;
    final copyright =
        dynamicText.copyright ?? '© 2026 MotoTracker. All rights reserved.';
    return Column(
      children: [
        Text(
          copyright,
          style: const TextStyle(
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

class _TitleDesc {
  final String title;
  final String description;

  const _TitleDesc({required this.title, required this.description});
}

class _AboutDynamicText {
  final String? aboutTitle;
  final String? aboutDescription;
  final String? featuresTitle;
  final List<_TitleDesc> features;
  final String? valuesTitle;
  final List<_TitleDesc> values;
  final String? teamTitle;
  final List<_TitleDesc> teamMembers;
  final String? socialTitle;
  final List<String> socialLinks;
  final String? madeWithLoveSubtitle;
  final String? copyright;

  const _AboutDynamicText({
    required this.aboutTitle,
    required this.aboutDescription,
    required this.featuresTitle,
    required this.features,
    required this.valuesTitle,
    required this.values,
    required this.teamTitle,
    required this.teamMembers,
    required this.socialTitle,
    required this.socialLinks,
    required this.madeWithLoveSubtitle,
    required this.copyright,
  });

  factory _AboutDynamicText.empty() => const _AboutDynamicText(
    aboutTitle: null,
    aboutDescription: null,
    featuresTitle: null,
    features: <_TitleDesc>[],
    valuesTitle: null,
    values: <_TitleDesc>[],
    teamTitle: null,
    teamMembers: <_TitleDesc>[],
    socialTitle: null,
    socialLinks: <String>[],
    madeWithLoveSubtitle: null,
    copyright: null,
  );

  _AboutDynamicText copyWith({
    String? aboutTitle,
    String? aboutDescription,
    String? featuresTitle,
    List<_TitleDesc>? features,
    String? valuesTitle,
    List<_TitleDesc>? values,
    String? teamTitle,
    List<_TitleDesc>? teamMembers,
    String? socialTitle,
    List<String>? socialLinks,
    String? madeWithLoveSubtitle,
    String? copyright,
  }) {
    return _AboutDynamicText(
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutDescription: aboutDescription ?? this.aboutDescription,
      featuresTitle: featuresTitle ?? this.featuresTitle,
      features: features ?? this.features,
      valuesTitle: valuesTitle ?? this.valuesTitle,
      values: values ?? this.values,
      teamTitle: teamTitle ?? this.teamTitle,
      teamMembers: teamMembers ?? this.teamMembers,
      socialTitle: socialTitle ?? this.socialTitle,
      socialLinks: socialLinks ?? this.socialLinks,
      madeWithLoveSubtitle: madeWithLoveSubtitle ?? this.madeWithLoveSubtitle,
      copyright: copyright ?? this.copyright,
    );
  }
}
