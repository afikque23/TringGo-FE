import 'package:flutter/material.dart';

import '../models/service_recommendation_dto.dart';
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
  final Set<String> _completingComponentNames = <String>{};

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

  String _formatKm(double? km) {
    if (km == null) return '-';
    if (km >= 1000) return '${km.toStringAsFixed(0)} km';
    return '${km.toStringAsFixed(1)} km';
  }

  String _buildEstimasiText(RekomendasiKomponenItemDto item) {
    final raw = item.estimasiWaktu.trim();
    if (raw.isNotEmpty && raw != '-') {
      return raw;
    }

    final remainingKm = item.hinggaServisBerikutnyaKm;
    if (remainingKm == null) {
      return 'Estimasi belum tersedia';
    }
    if (remainingKm <= 0) {
      return 'Jatuh tempo sekarang';
    }
    if (remainingKm < 1) {
      return 'Kurang dari 1 km lagi';
    }
    return '${remainingKm.toStringAsFixed(0)} km lagi';
  }

  Future<void> _showCompleteServiceDialog(
    RekomendasiKomponenItemDto item,
  ) async {
    final odometerController = TextEditingController();
    final notesController = TextEditingController();
    final serviceProviderController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    try {
      final payload = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Tandai Sudah Servis',
                  style: TextStyle(fontFamily: 'Arial', fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.komponen,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tanggal servis',
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: odometerController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Odometer saat servis (km)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: serviceProviderController,
                        decoration: const InputDecoration(
                          labelText: 'Nama bengkel (opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final odometerValue = int.tryParse(
                        odometerController.text.trim(),
                      );
                      if (odometerValue == null || odometerValue < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Odometer harus angka >= 0'),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(dialogContext, {
                        'performedAt': selectedDate,
                        'odometer': odometerValue,
                        'serviceProvider': serviceProviderController.text
                            .trim(),
                        'notes': notesController.text.trim(),
                      });
                    },
                    child: const Text('Simpan Servis'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (payload == null) return;

      await _completeFuzzyService(
        komponen: item.komponen,
        performedAt: payload['performedAt'] as DateTime,
        odometer: payload['odometer'] as int,
        serviceProvider: payload['serviceProvider'] as String?,
        notes: payload['notes'] as String?,
      );
    } finally {
      odometerController.dispose();
      notesController.dispose();
      serviceProviderController.dispose();
    }
  }

  Future<void> _completeFuzzyService({
    required String komponen,
    required DateTime performedAt,
    required int odometer,
    String? serviceProvider,
    String? notes,
  }) async {
    if (_completingComponentNames.contains(komponen)) return;

    setState(() {
      _completingComponentNames.add(komponen);
    });

    try {
      await _notifier.completeFuzzyService(
        motorId: widget.motorId,
        componentName: komponen,
        performedAt: performedAt,
        odometer: odometer,
        serviceProvider: serviceProvider,
        notes: notes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Servis berhasil dicatat. Data rekomendasi diperbarui.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan servis: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _completingComponentNames.remove(komponen);
        });
      }
    }
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
                          _buildEstimasiText(item),
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
                const SizedBox(height: 8),
                Text(
                  'Jarak sejak servis: ${_formatKm(item.jarakSejakServisKm)}',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Hingga servis berikutnya: ${_formatKm(item.hinggaServisBerikutnyaKm)}',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteServiceDialog(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _completingComponentNames.contains(item.komponen)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 16),
                    label: Text(
                      _completingComponentNames.contains(item.komponen)
                          ? 'Menyimpan...'
                          : 'Tandai Sudah Servis',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
