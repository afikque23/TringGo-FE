import 'package:flutter/material.dart';

import '../state/recommendation_home_insight_notifier.dart';
import '../widgets/fuzzy_scores_section.dart';
import '../widgets/meta_info_row.dart';
import '../widgets/priority_badge.dart';

class RecommendationHomeInsightScreen extends StatefulWidget {
  const RecommendationHomeInsightScreen({super.key, required this.motorId});

  final int motorId;

  @override
  State<RecommendationHomeInsightScreen> createState() =>
      _RecommendationHomeInsightScreenState();
}

class _RecommendationHomeInsightScreenState
    extends State<RecommendationHomeInsightScreen> {
  late final RecommendationHomeInsightNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = RecommendationHomeInsightNotifier();
    _notifier.load(widget.motorId);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Home Insight',
          style: TextStyle(fontFamily: 'Arial'),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => _notifier.refresh(widget.motorId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_notifier.errorMessage != null)
                    _ErrorCard(
                      message: _notifier.errorMessage!,
                      onRetry: () => _notifier.load(widget.motorId),
                    ),

                  const _SectionTitle(title: 'Wawasan Pintar'),
                  const SizedBox(height: 10),
                  _buildWawasanList(context),

                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Insight Sistem'),
                  const SizedBox(height: 10),
                  _buildInsightSistem(context),

                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Skor Fuzzy'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FuzzyScoresSection(fuzzyScores: _notifier.fuzzyScores),
                        const SizedBox(height: 12),
                        MetaInfoRow(meta: _notifier.effectiveMeta),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWawasanList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _notifier.homeInsight?.wawasanPintar ?? const [];

    if (_notifier.isLoadingInsight && items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Belum ada wawasan pintar saat ini.',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.judul,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: item.prioritas),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.isi,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInsightSistem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final insight = _notifier.homeInsight?.insightSistem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: insight == null
          ? Text(
              'Insight sistem belum tersedia.',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight.isi,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Coba lagi',
              style: TextStyle(fontFamily: 'Arial', color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
