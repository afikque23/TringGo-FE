import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/model/service_schedule_model.dart';
import '../../../core/model/vehicle_model.dart';
import '../../../core/services/service_schedule_service.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/utils/app_theme.dart';
import '../../widget/page_transition.dart';
import 'edit_jadwal.dart';

class DetailJadwalPage extends StatefulWidget {
  final ServiceScheduleModel schedule;
  final String status;
  final Color statusColor;
  final String kmRemaining;
  final String currentKm;
  final String targetKm;
  final int percentage;

  const DetailJadwalPage({
    super.key,
    required this.schedule,
    required this.status,
    required this.statusColor,
    required this.kmRemaining,
    required this.currentKm,
    required this.targetKm,
    required this.percentage,
  });

  @override
  State<DetailJadwalPage> createState() => _DetailJadwalPageState();
}

class _DetailJadwalPageState extends State<DetailJadwalPage> {
  final _scheduleService = ServiceScheduleService();
  final _vehicleService = VehicleService();
  bool _isDeleting = false;
  bool _isCompleting = false;
  VehicleModel? _primaryVehicle;

  // Dynamic schedule data
  late String _status;
  late Color _statusColor;
  late String _kmRemaining;
  late String _currentKm;
  late String _targetKm;
  late int _percentage;
  late Color _progressColor;
  int _calculatedInterval = 0; // Store calculated interval for display

  @override
  void initState() {
    super.initState();
    // Initialize with passed parameters
    _status = widget.status;
    _statusColor = widget.statusColor;
    _kmRemaining = widget.kmRemaining;
    _currentKm = widget.currentKm;
    _targetKm = widget.targetKm;
    _percentage = widget.percentage;
    _progressColor = widget.statusColor;
    _calculatedInterval = widget.schedule.intervalValue; // Initialize
    _loadVehicleAndRecalculate();
  }

  Future<void> _loadVehicleAndRecalculate() async {
    try {
      final vehicle = await _vehicleService.getPrimaryVehicle();
      if (mounted) {
        setState(() {
          _primaryVehicle = vehicle;
        });
        _recalculateScheduleData();
      }
    } catch (e) {
      // Error loading vehicle, just continue with initial values
    }
  }

  void _recalculateScheduleData() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.schedule.intervalType == 'mileage') {
      final currentKm = _primaryVehicle?.odometer ?? 0;
      final nextKm = widget.schedule.nextServiceMileage ?? 0;
      final lastKm =
          widget.schedule.lastServiceMileage ??
          (nextKm - widget.schedule.intervalValue);

      // Fallback: If intervalValue is 0 or null, calculate from next - last
      var intervalValue = widget.schedule.intervalValue;
      if (intervalValue == 0 && nextKm > 0 && lastKm >= 0) {
        intervalValue = nextKm - lastKm;
        print(
          '⚠️ intervalValue was 0, calculated from next-last: $intervalValue km',
        );
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 SCHEDULE CALCULATION DEBUG (Jarak)');
      print('Schedule ID: ${widget.schedule.id}');
      print('Current KM: $currentKm');
      print('Last Service KM: $lastKm');
      print('Next Service KM: $nextKm');
      print('Interval Value: $intervalValue km');
      print('Traveled Since Last: ${currentKm - lastKm} km');

      // Calculate remaining km
      final kmRemaining = nextKm - currentKm;

      // Calculate how much has been traveled since last service
      final traveledSinceLastService = currentKm - lastKm;

      // Calculate percentage (progress toward next service)
      final percentage = intervalValue > 0
          ? ((traveledSinceLastService / intervalValue) * 100)
                .clamp(0, 100)
                .toInt()
          : 0;

      print('Percentage: $percentage%');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Determine status based on remaining km
      String status;
      Color statusColor;
      Color progressColor;

      if (kmRemaining <= 0) {
        status = l10n.urgent;
        statusColor = colorScheme.error;
        progressColor = colorScheme.error;
      } else if (kmRemaining <= intervalValue * 0.2) {
        status = l10n.soon;
        statusColor = colorScheme.warning;
        progressColor = colorScheme.warning;
      } else {
        status = l10n.good;
        statusColor = colorScheme.primary;
        progressColor = colorScheme.primary;
      }

      setState(() {
        _status = status;
        _statusColor = statusColor;
        _kmRemaining = kmRemaining.toString();
        _currentKm = currentKm.toString();
        _targetKm = nextKm.toString();
        _percentage = percentage;
        _progressColor = progressColor;
        _calculatedInterval = intervalValue; // Save calculated interval
      });
    } else {
      // Time-based schedule
      final nextDate = widget.schedule.nextServiceDate;
      final now = DateTime.now();
      final daysRemaining = nextDate != null
          ? nextDate.difference(now).inDays
          : 0;

      // Calculate interval in days if not provided
      var intervalDays = widget.schedule.intervalValue;
      if (intervalDays == 0 && nextDate != null) {
        final lastDate = widget.schedule.lastServiceDate;
        if (lastDate != null) {
          intervalDays = nextDate.difference(lastDate).inDays;
          print(
            '⚠️ intervalDays was 0, calculated from dates: $intervalDays days',
          );
        }
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 SCHEDULE CALCULATION DEBUG (Waktu)');
      print('Schedule ID: ${widget.schedule.id}');
      print('Current Date: $now');
      print('Next Service Date: $nextDate');
      print('Interval Value: $intervalDays days');
      print('Days Remaining: $daysRemaining');

      // Calculate days since last service
      final lastDate =
          widget.schedule.lastServiceDate ??
          (nextDate != null
              ? nextDate.subtract(Duration(days: intervalDays))
              : now);
      final daysSinceLastService = now.difference(lastDate).inDays;

      // Calculate percentage
      final percentage = intervalDays > 0
          ? ((daysSinceLastService / intervalDays) * 100).clamp(0, 100).toInt()
          : 0;

      print('Days Since Last Service: $daysSinceLastService');
      print('Percentage: $percentage%');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      String status;
      Color statusColor;
      Color progressColor;

      if (daysRemaining <= 0) {
        status = l10n.urgent;
        statusColor = colorScheme.error;
        progressColor = colorScheme.error;
      } else if (daysRemaining <= intervalDays * 0.2) {
        status = l10n.soon;
        statusColor = colorScheme.warning;
        progressColor = colorScheme.warning;
      } else {
        status = l10n.good;
        statusColor = colorScheme.primary;
        progressColor = colorScheme.primary;
      }

      setState(() {
        _status = status;
        _statusColor = statusColor;
        _kmRemaining = daysRemaining.toString();
        _currentKm = now.toString().split(' ')[0];
        _targetKm = nextDate?.toString().split(' ')[0] ?? '-';
        _percentage = percentage;
        _progressColor = progressColor;
        _calculatedInterval = intervalDays; // Save calculated interval
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final title = widget.schedule.serviceName ?? l10n.serviceSchedule;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
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
                              l10n.serviceScheduleDetail,
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
                      // Edit button
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            SmoothPageRoute(
                              page: EditJadwalPage(schedule: widget.schedule),
                            ),
                          );
                          if (result == true && mounted) {
                            // Reload vehicle and recalculate before going back
                            await _loadVehicleAndRecalculate();
                            // Schedule was updated, go back to refresh list
                            Navigator.pop(context, true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      // Delete button
                      GestureDetector(
                        onTap: _isDeleting
                            ? null
                            : () => _showDeleteDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline,
                            size: 24,
                            color: _isDeleting
                                ? colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  )
                                : colorScheme.error,
                          ),
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    _buildStatusCard(context),
                    const SizedBox(height: 16),
                    _buildProgressCard(context),
                    const SizedBox(height: 16),
                    _buildDetailCard(context),
                    const SizedBox(height: 16),
                    _buildCompleteServiceButton(context),
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

  Widget _buildCompleteServiceButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isCompleting ? null : _showCompleteServiceDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isCompleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          _isCompleting ? 'Menyimpan...' : 'Tandai Sudah Servis',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showCompleteServiceDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final odometerController = TextEditingController(
      text:
          (_primaryVehicle?.odometer ?? widget.schedule.lastServiceMileage ?? 0)
              .toString(),
    );
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
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Konfirmasi Servis',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal servis',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: colorScheme.onSurfaceVariant,
                        ),
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
                              color: colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: colorScheme.onSurface,
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

      await _completeSchedule(
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

  Future<void> _completeSchedule({
    required DateTime performedAt,
    required int odometer,
    String? serviceProvider,
    String? notes,
  }) async {
    if (widget.schedule.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID jadwal tidak valid.')));
      return;
    }

    setState(() => _isCompleting = true);
    try {
      await _scheduleService.completeSchedule(
        scheduleId: widget.schedule.id!,
        performedAt: performedAt,
        odometer: odometer,
        serviceProvider: serviceProvider,
        notes: notes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Servis berhasil dicatat. Jadwal berikutnya diperbarui.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan servis: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Widget _buildStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isTimeBased = widget.schedule.intervalType == 'time';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _status,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _statusColor,
              height: 1.43,
            ),
          ),
          Text(
            isTimeBased
                ? '$_kmRemaining hari lagi'
                : '$_kmRemaining ${l10n.kmRemaining}',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isTimeBased = widget.schedule.intervalType == 'time';

    // Use calculated interval if available, otherwise fallback to schedule's interval
    final displayInterval = _calculatedInterval > 0
        ? _calculatedInterval
        : widget.schedule.intervalValue;

    final interval = isTimeBased
        ? 'Setiap $displayInterval bulan'
        : 'Setiap $displayInterval km';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progress,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTimeBased ? 'Tanggal Sekarang' : l10n.currentOdometer,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTimeBased ? _currentKm : '$_currentKm km',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                      height: 1.56,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isTimeBased ? 'Target Tanggal' : l10n.serviceTarget,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTimeBased ? _targetKm : '$_targetKm km',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                      height: 1.56,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _percentage / 100,
                  minHeight: 12,
                  backgroundColor: colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_percentage% ${l10n.towardNextService}',
                textAlign: TextAlign.center,
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.serviceInterval,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.43,
                  ),
                ),
                Text(
                  interval,
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
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final lastService =
        widget.schedule.lastServiceDate?.toString().split(' ')[0] ?? '-';
    final reminder = widget.schedule.reminderEnabled
        ? l10n.activeReminder
        : 'Tidak Aktif';
    final notes = widget.schedule.notes ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.detail,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context: context,
            icon: Icons.schedule_outlined,
            label: l10n.lastService,
            value: lastService,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context: context,
            icon: Icons.notifications_outlined,
            label: l10n.reminder,
            value: reminder,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notes,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: TextStyle(
                          fontFamily: 'Arial',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 4),
              Text(
                value,
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
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteSchedule,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            l10n.deleteScheduleConfirm,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteSchedule();
              },
              child: Text(
                l10n.delete,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSchedule() async {
    if (widget.schedule.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID jadwal tidak valid'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      await _scheduleService.deleteSchedule(widget.schedule.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal berhasil dihapus'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Go back to list page with refresh signal
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
