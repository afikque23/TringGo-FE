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
  bool _isBackfillSubmitting = false;

  bool _isMileageVariableKey(String key) {
    final normalized = key.trim().toLowerCase();
    return normalized == 'jarak' ||
        normalized == 'jarak_tempuh' ||
        normalized == 'mileage' ||
        normalized == 'distance_since_service_km' ||
        normalized == 'distance';
  }

  bool _requiresOdometerForItem(RekomendasiKomponenItemDto item) {
    return item.requiredVariables.any((v) => _isMileageVariableKey(v.key));
  }

  bool _selectionRequiresOdometer(
    List<RekomendasiKomponenItemDto> items,
    Set<String> selectedNames,
  ) {
    return items.any(
      (item) =>
          selectedNames.contains(item.komponen) &&
          _requiresOdometerForItem(item),
    );
  }


  Color _statusBadgeColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'critical':
        return colorScheme.error;
      case 'warning':
        return const Color(0xFFE6A700);
      case 'normal':
        return colorScheme.primary;
      default:
        return colorScheme.secondary;
    }
  }

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

  Widget _buildVariableProgress(
    ComponentVariableRequirementDto variable,
    ColorScheme colorScheme,
  ) {
    final currentValue = variable.value is num
        ? (variable.value as num).toDouble()
        : 0.0;
    final maxThreshold =
        variable.criticalThreshold ?? variable.warningThreshold;
    double progress = 0.0;
    if (maxThreshold != null && maxThreshold > 0) {
      progress = (currentValue / maxThreshold).clamp(0.0, 1.0);
    }

    final statusColor = _statusBadgeColor(
      variable.statusByThreshold,
      colorScheme,
    );

    String statusMessage;
    switch (variable.statusByThreshold.toLowerCase()) {
      case 'critical':
        statusMessage = '⚠️ Sudah waktunya diservis';
        break;
      case 'warning':
        statusMessage = '🔔 Mulai perlu diperhatikan';
        break;
      default:
        if (variable.toWarning != null && variable.toWarning! > 0) {
          statusMessage =
              '✅ Masih aman (${variable.formattedToWarning})';
        } else {
          statusMessage = '✅ Kondisi baik';
        }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                variable.label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              Text(
                variable.formattedValue,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            statusMessage,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              color: statusColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompleteServiceDialog(
    RekomendasiKomponenItemDto item,
  ) async {
    final requiresOdometer = _requiresOdometerForItem(item);
    final odometerController = TextEditingController();
    final notesController = TextEditingController();
    final serviceProviderController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? validationMessage;

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
                            context: dialogContext,
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
                        decoration: InputDecoration(
                          labelText: requiresOdometer
                              ? 'Angka speedometer saat servis (km) *'
                              : 'Angka speedometer saat servis (km)',
                          helperText:
                              'Lihat angka di speedometer motor saat diservis. Contoh: jika tertera 8.450 km, isi 8450',
                          border: const OutlineInputBorder(),
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
                      if (validationMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          validationMessage!,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
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
                      final rawOdometer = odometerController.text.trim();
                      final odometerValue = rawOdometer.isEmpty
                          ? null
                          : int.tryParse(rawOdometer);
                      if (requiresOdometer && odometerValue == null) {
                        setDialogState(() {
                          validationMessage =
                              'Angka speedometer wajib diisi untuk komponen ini.';
                        });
                        return;
                      }
                      if (odometerValue != null && odometerValue < 0) {
                        setDialogState(() {
                          validationMessage = 'Odometer harus angka >= 0';
                        });
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
        odometer: payload['odometer'] as int?,
        serviceProvider: payload['serviceProvider'] as String?,
        notes: payload['notes'] as String?,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 400), () {
        odometerController.dispose();
        notesController.dispose();
        serviceProviderController.dispose();
      });
    }
  }

  Future<void> _completeFuzzyService({
    required String komponen,
    required DateTime performedAt,
    int? odometer,
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

  Future<void> _showBackfillOnboardingDialog(
    List<RekomendasiKomponenItemDto> items,
  ) async {
    final selectedNames = <String>{};
    final odometerController = TextEditingController();
    final notesController = TextEditingController();
    final serviceProviderController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? validationMessage;

    try {
      final payload = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final needsOdometer = _selectionRequiresOdometer(
                items,
                selectedNames,
              );

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Isi Riwayat Servis Awal',
                  style: TextStyle(fontFamily: 'Arial', fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Centang komponen yang sudah pernah kamu servis sebelumnya, lalu isi tanggal dan posisi speedometer saat itu.',
                        style: TextStyle(fontFamily: 'Arial', fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        final checked = selectedNames.contains(item.komponen);
                        return CheckboxListTile(
                          value: checked,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.komponen,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            _requiresOdometerForItem(item)
                                ? 'Perlu tahu posisi speedometer saat itu.'
                                : 'Tidak perlu posisi speedometer.',
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 11,
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedNames.add(item.komponen);
                              } else {
                                selectedNames.remove(item.komponen);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const Text(
                        'Tanggal servis',
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
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
                        decoration: InputDecoration(
                          labelText: needsOdometer
                              ? 'Angka speedometer saat servis (km) *'
                              : 'Angka speedometer saat servis (km)',
                          helperText:
                              'Isi angka yang tertera di speedometer motor saat itu.',
                          border: const OutlineInputBorder(),
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
                      if (validationMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          validationMessage!,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
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
                      if (selectedNames.isEmpty) {
                        setDialogState(() {
                          validationMessage = 'Pilih minimal satu komponen.';
                        });
                        return;
                      }

                      final rawOdometer = odometerController.text.trim();
                      final odometerValue = rawOdometer.isEmpty
                          ? null
                          : int.tryParse(rawOdometer);

                      if (needsOdometer && odometerValue == null) {
                        setDialogState(() {
                          validationMessage =
                              'Angka speedometer wajib diisi untuk komponen yang dipilih.';
                        });
                        return;
                      }

                      if (odometerValue != null && odometerValue < 0) {
                        setDialogState(() {
                          validationMessage = 'Odometer harus angka >= 0';
                        });
                        return;
                      }

                      Navigator.pop(dialogContext, {
                        'selectedNames': selectedNames.toList(),
                        'performedAt': selectedDate,
                        'odometer': odometerValue,
                        'serviceProvider': serviceProviderController.text
                            .trim(),
                        'notes': notesController.text.trim(),
                      });
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (payload == null) return;

      final selectedNamesFromPayload = (payload['selectedNames'] as List)
          .map((e) => e.toString())
          .toSet();
      final performedAt = payload['performedAt'] as DateTime;
      final sharedOdometer = payload['odometer'] as int?;
      final serviceProvider = payload['serviceProvider'] as String?;
      final notes = payload['notes'] as String?;

      final selectedItems = items
          .where((item) => selectedNamesFromPayload.contains(item.komponen))
          .toList();

      if (selectedItems.isEmpty) return;

      setState(() {
        _isBackfillSubmitting = true;
        for (final item in selectedItems) {
          _completingComponentNames.add(item.komponen);
        }
      });

      final entries = selectedItems.map((item) {
        return (
          componentName: item.komponen,
          performedAt: performedAt,
          odometer: sharedOdometer,
          serviceProvider: (serviceProvider?.trim().isEmpty ?? true)
              ? null
              : serviceProvider?.trim(),
          notes: (notes?.trim().isEmpty ?? true) ? null : notes?.trim(),
        );
      }).toList();

      await _notifier.completeFuzzyServicesBulk(
        motorId: widget.motorId,
        entries: entries,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Riwayat servis awal berhasil disimpan untuk ${selectedItems.length} komponen.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan backfill: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBackfillSubmitting = false;
          _completingComponentNames.clear();
        });
      }
      Future.delayed(const Duration(milliseconds: 400), () {
        odometerController.dispose();
        notesController.dispose();
        serviceProviderController.dispose();
      });
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
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(title: 'Rekomendasi Komponen'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _isBackfillSubmitting
                            ? null
                            : () {
                                final items =
                                    _notifier
                                        .recommendation
                                        ?.rekomendasiKomponen ??
                                    const <RekomendasiKomponenItemDto>[];
                                if (items.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Belum ada komponen untuk backfill.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _showBackfillOnboardingDialog(items);
                              },
                        icon: _isBackfillSubmitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.playlist_add_check, size: 16),
                        label: Text(
                          _isBackfillSubmitting
                              ? 'Menyimpan...'
                              : 'Isi Riwayat Servis Awal',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                if (item.requiredVariables.isNotEmpty) ...[
                  const Divider(height: 20, thickness: 0.65),
                  ...item.requiredVariables.map(
                    (variable) =>
                        _buildVariableProgress(variable, colorScheme),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isBackfillSubmitting
                        ? null
                        : () => _showCompleteServiceDialog(item),
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
