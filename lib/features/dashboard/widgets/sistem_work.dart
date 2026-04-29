import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/model/content_model.dart';
import '../../../core/services/content_service.dart';
import '../../../l10n/app_localizations.dart';

class SistemWorkPage extends StatefulWidget {
  const SistemWorkPage({super.key});

  @override
  State<SistemWorkPage> createState() => _SistemWorkPageState();
}

class _SistemWorkPageState extends State<SistemWorkPage> {
  late final Future<List<DocumentSectionModel>> _systemInfoFuture;

  @override
  void initState() {
    super.initState();
    _systemInfoFuture = ContentService().getDocumentSections('system_info');
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

  List<_TitleDesc> _pickNTitleDesc(
    List<_TitleDesc> primary,
    List<_TitleDesc> fallback,
    int n,
  ) {
    final picked = <_TitleDesc>[];
    picked.addAll(primary.where((e) => e.title.trim().isNotEmpty));
    picked.addAll(fallback.where((e) => e.title.trim().isNotEmpty));
    return picked.take(n).toList(growable: false);
  }

  List<Map<String, String>> _parseHighlights(DocumentSectionModel section) {
    final raw = <String>[...section.bullets];
    if (raw.isEmpty) return const [];

    final highlights = <Map<String, String>>[];
    for (final item in raw) {
      final pair = _splitTitleDesc(item);
      if (pair.title.isEmpty || pair.description.isEmpty) continue;
      highlights.add({'text': pair.title, 'detail': ' ${pair.description}'});
    }
    return highlights;
  }

  _SystemInfoDynamicText _extractSystemInfo(
    BuildContext context,
    List<DocumentSectionModel> sections,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final fallback = _SystemInfoDynamicText.fallback(context);
    if (sections.isEmpty) return fallback;

    // Convention (by index):
    // 0 header, 1 adaptive card, 2 data analysis, 3 workflow title,
    // 4-7 workflow steps (1-4), 8 technical note, 9 reference.

    String? headerTitle;
    String? headerSubtitle;
    if (sections.isNotEmpty) {
      headerTitle = sections[0].title.isNotEmpty ? sections[0].title : null;
      final p = sections[0].paragraphs;
      if (p.isNotEmpty) headerSubtitle = p.first;
    }

    String? adaptiveTitle;
    String? adaptiveDesc;
    if (sections.length >= 2) {
      adaptiveTitle = sections[1].title.isNotEmpty ? sections[1].title : null;
      final p = sections[1].paragraphs;
      if (p.isNotEmpty) adaptiveDesc = p.join('\n\n');
    }

    String? dataTitle;
    List<_TitleDesc> dataCards = const [];
    if (sections.length >= 3) {
      final s = sections[2];
      dataTitle = s.title.isNotEmpty ? s.title : null;
      final rawItems = <String>[...s.bullets];
      if (rawItems.isEmpty) rawItems.addAll(s.paragraphs);
      dataCards = rawItems
          .map(_splitTitleDesc)
          .where((e) => e.title.isNotEmpty)
          .toList();
    }

    String? workflowTitle;
    if (sections.length >= 4) {
      workflowTitle = sections[3].title.isNotEmpty ? sections[3].title : null;
    }

    final steps = <_WorkflowStepText>[];
    for (var i = 0; i < 4; i++) {
      final sectionIndex = 4 + i;
      final fallbackStep = fallback.workflowSteps[i];

      if (sections.length > sectionIndex) {
        final s = sections[sectionIndex];
        final title = s.title.isNotEmpty ? s.title : fallbackStep.title;
        final description = s.paragraphs.isNotEmpty
            ? s.paragraphs.join('\n\n')
            : fallbackStep.description;
        final highlights = (i == 0)
            ? _parseHighlights(s)
            : const <Map<String, String>>[];

        steps.add(
          _WorkflowStepText(
            number: fallbackStep.number,
            title: title,
            description: description,
            highlights: highlights.isNotEmpty
                ? highlights
                : fallbackStep.highlights,
          ),
        );
      } else {
        steps.add(fallbackStep);
      }
    }

    String? technicalTitle;
    String? technicalDesc;
    if (sections.length >= 9) {
      final s = sections[8];
      technicalTitle = s.title.isNotEmpty ? s.title : null;
      if (s.paragraphs.isNotEmpty) {
        technicalDesc = s.paragraphs.join('\n\n');
      }
    }

    String? reference;
    if (sections.length >= 10) {
      final s = sections[9];
      if (s.paragraphs.isNotEmpty) {
        reference = s.paragraphs.join('\n\n');
      } else if (s.bullets.isNotEmpty) {
        reference = s.bullets.join('\n');
      } else if (s.title.isNotEmpty) {
        reference = s.title;
      }
    }

    final fallbackDataCards = <_TitleDesc>[
      _TitleDesc(title: l10n.mileageData, description: l10n.mileageDataDesc),
      _TitleDesc(
        title: l10n.lastServiceTime,
        description: l10n.lastServiceTimeDesc,
      ),
      _TitleDesc(
        title: l10n.usageFrequency,
        description: l10n.usageFrequencyDesc,
      ),
      _TitleDesc(
        title: l10n.maintenanceHistory,
        description: l10n.maintenanceHistoryDesc,
      ),
    ];
    final normalizedDataCards = _pickNTitleDesc(
      dataCards,
      fallbackDataCards,
      4,
    );

    return fallback.copyWith(
      headerTitle: headerTitle,
      headerSubtitle: headerSubtitle,
      adaptiveTitle: adaptiveTitle,
      adaptiveDesc: adaptiveDesc,
      dataTitle: dataTitle,
      dataCards: normalizedDataCards,
      workflowTitle: workflowTitle,
      workflowSteps: steps,
      technicalTitle: technicalTitle,
      technicalDesc: technicalDesc,
      reference: reference,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<DocumentSectionModel>>(
      future: _systemInfoFuture,
      builder: (context, snapshot) {
        final sections = snapshot.data ?? const <DocumentSectionModel>[];
        final dynamicText = _extractSystemInfo(context, sections);
        final statusBarIconBrightness =
            colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: statusBarIconBrightness,
          ),
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            body: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.surface,
                        width: 0.65,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dynamicText.headerTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dynamicText.headerSubtitle,
                                  style: TextStyle(
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
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adaptive System Card
                        _buildAdaptiveSystemCard(
                          context,
                          title: dynamicText.adaptiveTitle,
                          description: dynamicText.adaptiveDesc,
                        ),
                        const SizedBox(height: 24),
                        // Data Analysis Section
                        _buildDataAnalysisSection(
                          context,
                          sectionTitle: dynamicText.dataTitle,
                          cards: dynamicText.dataCards,
                        ),
                        const SizedBox(height: 24),
                        // System Workflow Section
                        _buildSystemWorkflowSection(
                          context,
                          sectionTitle: dynamicText.workflowTitle,
                          steps: dynamicText.workflowSteps,
                        ),
                        const SizedBox(height: 24),
                        // Technical Note
                        _buildTechnicalNote(
                          context,
                          title: dynamicText.technicalTitle,
                          description: dynamicText.technicalDesc,
                        ),
                        const SizedBox(height: 16),
                        // Reference
                        _buildReference(context, text: dynamicText.reference),
                        const SizedBox(height: 24),
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

  Widget _buildAdaptiveSystemCard(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 1.67),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.62,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataAnalysisSection(
    BuildContext context, {
    required String sectionTitle,
    required List<_TitleDesc> cards,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              sectionTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDataCard(
          context,
          icon: Icons.route_outlined,
          title: cards[0].title,
          description: cards[0].description,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.schedule_outlined,
          title: cards[1].title,
          description: cards[1].description,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.speed_outlined,
          title: cards[2].title,
          description: cards[2].description,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.history_outlined,
          title: cards[3].title,
          description: cards[3].description,
        ),
      ],
    );
  }

  Widget _buildDataCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.62,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemWorkflowSection(
    BuildContext context, {
    required String sectionTitle,
    required List<_WorkflowStepText> steps,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings_suggest_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              sectionTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: steps[0].number,
          title: steps[0].title,
          description: steps[0].description,
          highlights: steps[0].highlights,
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: steps[1].number,
          title: steps[1].title,
          description: steps[1].description,
          highlights: steps[1].highlights,
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: steps[2].number,
          title: steps[2].title,
          description: steps[2].description,
          highlights: steps[2].highlights,
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: steps[3].number,
          title: steps[3].title,
          description: steps[3].description,
          highlights: steps[3].highlights,
        ),
      ],
    );
  }

  Widget _buildWorkflowStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required List<Map<String, String>> highlights,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onPrimary,
                  height: 1.33,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                if (highlights.isEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.62,
                    ),
                  )
                else
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.62,
                      ),
                      children: [
                        TextSpan(text: description),
                        ...highlights.expand(
                          (highlight) => [
                            TextSpan(
                              text: highlight['text']!,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                            TextSpan(text: highlight['detail']!),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalNote(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
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
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.primary,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.62,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReference(BuildContext context, {required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.62,
        ),
      ),
    );
  }
}

class _TitleDesc {
  final String title;
  final String description;

  const _TitleDesc({required this.title, required this.description});
}

class _WorkflowStepText {
  final String number;
  final String title;
  final String description;
  final List<Map<String, String>> highlights;

  const _WorkflowStepText({
    required this.number,
    required this.title,
    required this.description,
    required this.highlights,
  });
}

class _SystemInfoDynamicText {
  final String headerTitle;
  final String headerSubtitle;
  final String adaptiveTitle;
  final String adaptiveDesc;
  final String dataTitle;
  final List<_TitleDesc> dataCards;
  final String workflowTitle;
  final List<_WorkflowStepText> workflowSteps;
  final String technicalTitle;
  final String technicalDesc;
  final String reference;

  const _SystemInfoDynamicText({
    required this.headerTitle,
    required this.headerSubtitle,
    required this.adaptiveTitle,
    required this.adaptiveDesc,
    required this.dataTitle,
    required this.dataCards,
    required this.workflowTitle,
    required this.workflowSteps,
    required this.technicalTitle,
    required this.technicalDesc,
    required this.reference,
  });

  factory _SystemInfoDynamicText.fallback(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SystemInfoDynamicText(
      headerTitle: l10n.howSystemWorks,
      headerSubtitle: l10n.transparencyAlgorithm,
      adaptiveTitle: l10n.adaptiveSystemTitle,
      adaptiveDesc: l10n.adaptiveSystemDesc,
      dataTitle: l10n.dataAnalyzed,
      dataCards: <_TitleDesc>[
        _TitleDesc(title: l10n.mileageData, description: l10n.mileageDataDesc),
        _TitleDesc(
          title: l10n.lastServiceTime,
          description: l10n.lastServiceTimeDesc,
        ),
        _TitleDesc(
          title: l10n.usageFrequency,
          description: l10n.usageFrequencyDesc,
        ),
        _TitleDesc(
          title: l10n.maintenanceHistory,
          description: l10n.maintenanceHistoryDesc,
        ),
      ],
      workflowTitle: l10n.howSystemWorksTitle,
      workflowSteps: <_WorkflowStepText>[
        _WorkflowStepText(
          number: '1',
          title: l10n.usageClassification,
          description: l10n.usageClassificationDesc,
          highlights: <Map<String, String>>[
            {'text': l10n.light, 'detail': l10n.lightUsageDetail},
            {'text': l10n.normal, 'detail': l10n.normalUsageDetail},
            {'text': l10n.heavy, 'detail': l10n.heavyUsageDetail},
          ],
        ),
        _WorkflowStepText(
          number: '2',
          title: l10n.intervalAdjustment,
          description: l10n.intervalAdjustmentDesc,
          highlights: const <Map<String, String>>[],
        ),
        _WorkflowStepText(
          number: '3',
          title: l10n.trendDetection,
          description: l10n.trendDetectionDesc,
          highlights: const <Map<String, String>>[],
        ),
        _WorkflowStepText(
          number: '4',
          title: l10n.contextualRecommendations,
          description: l10n.contextualRecommendationsDesc,
          highlights: const <Map<String, String>>[],
        ),
      ],
      technicalTitle: l10n.technicalNote,
      technicalDesc: l10n.technicalNoteDesc,
      reference: l10n.reference,
    );
  }

  _SystemInfoDynamicText copyWith({
    String? headerTitle,
    String? headerSubtitle,
    String? adaptiveTitle,
    String? adaptiveDesc,
    String? dataTitle,
    List<_TitleDesc>? dataCards,
    String? workflowTitle,
    List<_WorkflowStepText>? workflowSteps,
    String? technicalTitle,
    String? technicalDesc,
    String? reference,
  }) {
    return _SystemInfoDynamicText(
      headerTitle: headerTitle ?? this.headerTitle,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      adaptiveTitle: adaptiveTitle ?? this.adaptiveTitle,
      adaptiveDesc: adaptiveDesc ?? this.adaptiveDesc,
      dataTitle: dataTitle ?? this.dataTitle,
      dataCards: dataCards ?? this.dataCards,
      workflowTitle: workflowTitle ?? this.workflowTitle,
      workflowSteps: workflowSteps ?? this.workflowSteps,
      technicalTitle: technicalTitle ?? this.technicalTitle,
      technicalDesc: technicalDesc ?? this.technicalDesc,
      reference: reference ?? this.reference,
    );
  }
}
