import 'package:flutter/material.dart';

import '../state/recommendation_service_notifier.dart';
import '../widgets/meta_info_row.dart';
import '../widgets/priority_badge.dart';

class RecommendationServiceScreen extends StatefulWidget {
  const RecommendationServiceScreen({super.key, required this.motorId});

  final int motorId;

  @override
  State<RecommendationServiceScreen> createState() =>
      _RecommendationServiceScreenState();
}

class _RecommendationServiceScreenState
    extends State<RecommendationServiceScreen> {
  late final RecommendationServiceNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = RecommendationServiceNotifier();
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
          'Rekomendasi Servis',
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

                  const _SectionTitle(title: 'Ringkasan Kondisi'),
                  const SizedBox(height: 10),
                  _buildRingkasanCard(context),

                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Rekomendasi Komponen'),
                  const SizedBox(height: 10),
                  _buildRekomendasiKomponenList(context),

                  const SizedBox(height: 16),
                  if ((_notifier.recommendation?.tipsMandiri ?? '')
                      .trim()
                      .isNotEmpty) ...[
                    const _SectionTitle(title: 'Tips Mandiri'),
                    const SizedBox(height: 10),
                    _buildTipsMandiri(context),
                    const SizedBox(height: 16),
                  ],

                  MetaInfoRow(meta: _notifier.effectiveMeta),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRingkasanCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ringkasan = _notifier.recommendation?.ringkasanKondisi;
    final text = (ringkasan == null || ringkasan.trim().isEmpty)
        ? 'Ringkasan kondisi belum tersedia.'
        : ringkasan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
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

  Widget _buildRekomendasiKomponenList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _notifier.recommendation?.rekomendasiKomponen ?? const [];

    if (_notifier.isLoadingRecommendation && items.isEmpty) {
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
          'Belum ada rekomendasi komponen.',
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
                        item.komponen,
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
                  item.saran,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 0.65,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.estimasiWaktu.isEmpty ? '-' : item.estimasiWaktu,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTipsMandiri(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tips = _notifier.recommendation?.tipsMandiri ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        tips,
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
