import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class SistemWorkPage extends StatelessWidget {
  const SistemWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
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
                  bottom: BorderSide(color: colorScheme.surface, width: 0.65),
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
                              l10n.howSystemWorks,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.transparencyAlgorithm,
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
                    _buildAdaptiveSystemCard(context),
                    const SizedBox(height: 24),
                    // Data Analysis Section
                    _buildDataAnalysisSection(context),
                    const SizedBox(height: 24),
                    // System Workflow Section
                    _buildSystemWorkflowSection(context),
                    const SizedBox(height: 24),
                    // Technical Note
                    _buildTechnicalNote(context),
                    const SizedBox(height: 16),
                    // Reference
                    _buildReference(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveSystemCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.adaptiveSystemTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  l10n.adaptiveSystemDesc,
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

  Widget _buildDataAnalysisSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
              l10n.dataAnalyzed,
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
          title: l10n.mileageData,
          description: l10n.mileageDataDesc,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.schedule_outlined,
          title: l10n.lastServiceTime,
          description: l10n.lastServiceTimeDesc,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.speed_outlined,
          title: l10n.usageFrequency,
          description: l10n.usageFrequencyDesc,
        ),
        const SizedBox(height: 12),
        _buildDataCard(
          context,
          icon: Icons.history_outlined,
          title: l10n.maintenanceHistory,
          description: l10n.maintenanceHistoryDesc,
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

  Widget _buildSystemWorkflowSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
              l10n.howSystemWorksTitle,
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
          number: '1',
          title: l10n.usageClassification,
          description: l10n.usageClassificationDesc,
          highlights: [
            {'text': l10n.light, 'detail': l10n.lightUsageDetail},
            {'text': l10n.normal, 'detail': l10n.normalUsageDetail},
            {'text': l10n.heavy, 'detail': l10n.heavyUsageDetail},
          ],
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: '2',
          title: l10n.intervalAdjustment,
          description: l10n.intervalAdjustmentDesc,
          highlights: [],
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: '3',
          title: l10n.trendDetection,
          description: l10n.trendDetectionDesc,
          highlights: [],
        ),
        const SizedBox(height: 16),
        _buildWorkflowStep(
          context,
          number: '4',
          title: l10n.contextualRecommendations,
          description: l10n.contextualRecommendationsDesc,
          highlights: [],
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

  Widget _buildTechnicalNote(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.technicalNote,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.primary,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.technicalNoteDesc,
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

  Widget _buildReference(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l10n.reference,
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
