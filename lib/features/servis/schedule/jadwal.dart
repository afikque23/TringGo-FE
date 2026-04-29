import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../widget/bottom_navbar.dart';
import '../../widget/page_transition.dart';
import 'detail_jadwal.dart';
import '../history/riwayat_service.dart';
import 'tambah_jadwal.dart';
import '../../../core/services/service_schedule_service.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/model/service_schedule_model.dart';
import '../../../core/model/vehicle_model.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final int _selectedIndex = 1; // Service tab is active
  final _scheduleService = ServiceScheduleService();
  final _vehicleService = VehicleService();

  List<ServiceScheduleModel> _schedules = [];
  VehicleModel? _primaryVehicle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);

    try {
      // Load primary vehicle first to get current mileage
      final vehicle = await _vehicleService.getPrimaryVehicle();

      // Get schedules filtered by vehicle ID
      final schedules = vehicle != null
          ? await _scheduleService.getAllSchedules(vehicleId: vehicle.id)
          : <ServiceScheduleModel>[];

      if (mounted) {
        setState(() {
          _primaryVehicle = vehicle;
          _schedules = schedules;
          _isLoading = false;
        });

        // Check service reminders when refreshing schedule page
        if (vehicle != null) {
          try {
            await _scheduleService.checkReminders(
              vehicle.id!,
              vehicle.odometer,
            );
          } catch (e) {
            print('⚠️ Failed to check reminders on schedule refresh: $e');
            // Don't fail the page load if reminder check fails
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jadwal: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header with tabs
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.service,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTabButton(l10n.overview, false),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.schedule, true),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.history, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadSchedules,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Column(
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 12),
                            _buildAddScheduleButton(),
                            if (_schedules.isEmpty) ...[
                              const SizedBox(height: 48),
                              Text(
                                'Belum ada jadwal servis',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ] else
                              ..._schedules.map((schedule) {
                                final data = _calculateScheduleData(schedule);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: _buildServiceItem(
                                    schedule: schedule,
                                    icon: _getServiceIcon(
                                      schedule.serviceName ?? 'Unknown',
                                    ),
                                    title:
                                        schedule.serviceName ??
                                        'Unknown Service',
                                    hasIntervalBadge:
                                        data['hasCustomInterval'] as bool,
                                    status: data['status'] as String,
                                    statusColor: data['statusColor'] as Color,
                                    kmRemaining: data['remaining'] as String,
                                    nextValue: data['nextValue'] as String,
                                    currentValue:
                                        data['currentValue'] as String,
                                    percentage: data['percentage'] as int,
                                    progressColor:
                                        data['progressColor'] as Color,
                                    isTimeBased:
                                        schedule.intervalType == 'time',
                                  ),
                                );
                              }),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex),
      ),
    );
  }

  Map<String, dynamic> _calculateScheduleData(ServiceScheduleModel schedule) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (schedule.intervalType == 'mileage') {
      final currentKm = _primaryVehicle?.odometer ?? 0;
      final nextKm = schedule.nextServiceMileage ?? 0;
      final lastKm =
          schedule.lastServiceMileage ?? (nextKm - schedule.intervalValue);

      // Fallback: If intervalValue is 0 or null, calculate from next - last
      var intervalValue = schedule.intervalValue;
      if (intervalValue == 0 && nextKm > 0 && lastKm >= 0) {
        intervalValue = nextKm - lastKm;
      }

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

      return {
        'status': status,
        'statusColor': statusColor,
        'remaining': kmRemaining.toString(),
        'nextValue': nextKm.toString(),
        'currentValue': currentKm.toString(),
        'percentage': percentage,
        'progressColor': progressColor,
        'hasCustomInterval': schedule.notes?.contains('disesuaikan') ?? false,
      };
    } else {
      // Time-based schedule
      final nextDate = schedule.nextServiceDate;
      final now = DateTime.now();
      final daysRemaining = nextDate != null
          ? nextDate.difference(now).inDays
          : 0;

      // Calculate interval in days if not provided
      var intervalDays = schedule.intervalValue;
      if (intervalDays == 0 && nextDate != null) {
        final lastDate = schedule.lastServiceDate;
        if (lastDate != null) {
          intervalDays = nextDate.difference(lastDate).inDays;
        }
      }

      // Calculate days since last service
      final lastDate =
          schedule.lastServiceDate ??
          (nextDate != null
              ? nextDate.subtract(Duration(days: intervalDays))
              : now);
      final daysSinceLastService = now.difference(lastDate).inDays;

      // Calculate percentage
      final percentage = intervalDays > 0
          ? ((daysSinceLastService / intervalDays) * 100).clamp(0, 100).toInt()
          : 0;

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

      return {
        'status': status,
        'statusColor': statusColor,
        'remaining': daysRemaining.toString(),
        'nextValue': nextDate?.toString().split(' ')[0] ?? '-',
        'currentValue': now.toString().split(' ')[0],
        'percentage': percentage,
        'progressColor': progressColor,
        'hasCustomInterval': schedule.notes?.contains('disesuaikan') ?? false,
      };
    }
  }

  IconData _getServiceIcon(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('oli') || lower.contains('oil')) {
      return Icons.oil_barrel_outlined;
    } else if (lower.contains('rem') || lower.contains('brake')) {
      return Icons.cached;
    } else if (lower.contains('rantai') ||
        lower.contains('chain') ||
        lower.contains('sprocket')) {
      return Icons.settings_outlined;
    } else if (lower.contains('ban') || lower.contains('tire')) {
      return Icons.multiline_chart;
    } else if (lower.contains('busi') || lower.contains('spark')) {
      return Icons.bolt_outlined;
    } else {
      return Icons.build_outlined;
    }
  }

  Widget _buildTabButton(String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    if (label == l10n.overview) {
      icon = Icons.info_outline;
    } else if (label == l10n.schedule) {
      icon = Icons.schedule_outlined;
    } else if (label == l10n.history) {
      icon = Icons.history;
    } else {
      icon = Icons.info_outline;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (label == l10n.overview) {
            // Navigate back to Overview page
            Navigator.pop(context);
          } else if (label == l10n.history) {
            // Navigate to History page
            Navigator.push(
              context,
              SmoothPageRoute(page: const RiwayatServicePage()),
            );
          }
          // Schedule is already active
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isActive ? Colors.white : colorScheme.secondary,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l10n.schedulePrediction,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.secondary,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required ServiceScheduleModel schedule,
    required IconData icon,
    required String title,
    required bool hasIntervalBadge,
    required String status,
    required Color statusColor,
    required String kmRemaining,
    required String nextValue,
    required String currentValue,
    required int percentage,
    required Color progressColor,
    required bool isTimeBased,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Format tampilan berbeda untuk jarak vs waktu
    final remainingText = isTimeBased
        ? '$kmRemaining hari lagi'
        : '$kmRemaining ${l10n.kmRemaining}';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          SmoothPageRoute(
            page: DetailJadwalPage(
              schedule: schedule,
              status: status,
              statusColor: statusColor,
              kmRemaining: kmRemaining,
              currentKm: currentValue,
              targetKm: nextValue,
              percentage: percentage,
            ),
          ),
        );

        // Reload schedules if changes were made
        if (result == true) {
          _loadSchedules();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.65,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (hasIntervalBadge) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.4),
                                  width: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.intervalAdjusted,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.primary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: statusColor,
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '• $remainingText',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.secondary,
                                height: 1.33,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Next service info (KM or Date)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.next,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTimeBased ? nextValue : '$nextValue km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTimeBased
                          ? '${l10n.currently}: $currentValue'
                          : '${l10n.currently}: $currentValue km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddScheduleButton() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          SmoothPageRoute(page: const TambahJadwalPage()),
        );

        // Reload schedules if a new schedule was added
        if (result == true) {
          _loadSchedules();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.65,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              l10n.addMaintenanceSchedule,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
