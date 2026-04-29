import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../widget/bottom_navbar.dart';
import '../widget/page_transition.dart';
import 'schedule/jadwal.dart';
import 'history/riwayat_service.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/services/service_schedule_service.dart';
import '../../core/model/vehicle_model.dart';
import '../../core/model/service_schedule_model.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final int _selectedIndex = 1; // Service tab is active
  final _vehicleService = VehicleService();
  final _scheduleService = ServiceScheduleService();

  VehicleModel? _primaryVehicle;
  List<ServiceScheduleModel> _schedules = [];
  bool _isLoading = true;
  Map<String, dynamic> _usagePattern = {};
  bool _isLoadingPattern = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUsagePattern();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final vehicle = await _vehicleService.getPrimaryVehicle();
      final schedules = await _scheduleService.getAllSchedules();

      if (mounted) {
        setState(() {
          _primaryVehicle = vehicle;
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUsagePattern() async {
    setState(() => _isLoadingPattern = true);

    try {
      final pattern = await _vehicleService.getUsagePattern();

      if (mounted) {
        setState(() {
          _usagePattern = pattern;
          _isLoadingPattern = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPattern = false);
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
                        _buildTabButton(l10n.overview, true),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.schedule, false),
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
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Column(
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 16),
                            _buildInfoCard(),
                            const SizedBox(height: 16),
                            _buildStatsRow(),
                            const SizedBox(height: 16),
                            _buildRecommendationsCard(),
                            const SizedBox(height: 16),
                            _buildUsagePatternCard(),
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
          if (label == l10n.schedule) {
            // Navigate to Schedule page
            Navigator.push(context, SmoothPageRoute(page: const JadwalPage()));
          } else if (label == l10n.history) {
            // Navigate to History page
            Navigator.push(
              context,
              SmoothPageRoute(page: const RiwayatServicePage()),
            );
          }
          // Tab switching logic for other tabs
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

  Map<String, int> _calculateScheduleStatuses() {
    if (_schedules.isEmpty || _primaryVehicle == null) {
      return {'urgent': 0, 'soon': 0, 'good': 0};
    }

    int urgent = 0;
    int soon = 0;
    int good = 0;
    final currentOdometer = _primaryVehicle!.odometer;

    for (final schedule in _schedules) {
      if (schedule.intervalType == 'mileage') {
        final nextService = schedule.nextServiceMileage ?? 0;
        final remaining = nextService - currentOdometer;

        if (remaining <= 0) {
          urgent++;
        } else if (remaining <= 500) {
          soon++;
        } else {
          good++;
        }
      }
    }

    return {'urgent': urgent, 'soon': soon, 'good': good};
  }

  Widget _buildStatusCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final statuses = _calculateScheduleStatuses();
    final urgentCount = statuses['urgent'] ?? 0;
    final soonCount = statuses['soon'] ?? 0;
    final goodCount = statuses['good'] ?? 0;
    final totalSchedules = _schedules.length;

    // Calculate overall status
    String statusText;
    Color statusColor;
    double progressValue;

    if (urgentCount > 0) {
      statusText = l10n.urgent;
      statusColor = colorScheme.error;
      progressValue = 0.3;
    } else if (soonCount > 0) {
      statusText = l10n.soon;
      statusColor = colorScheme.warning;
      progressValue = 0.6;
    } else if (totalSchedules > 0) {
      statusText = l10n.good;
      statusColor = colorScheme.primary;
      progressValue = 0.85;
    } else {
      statusText = 'Belum ada data';
      statusColor = colorScheme.secondary;
      progressValue = 0.0;
    }

    final String statusSubtext = totalSchedules > 0
        ? 'Kondisi kendaraan ${(progressValue * 100).toInt()}%'
        : 'Belum ada jadwal perawatan';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.overallStatus,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.56,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                child: Icon(
                  urgentCount > 0
                      ? Icons.warning_amber_outlined
                      : totalSchedules > 0
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: statusColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: statusColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 12,
                  backgroundColor: colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusSubtext,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.secondary,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                l10n.urgent,
                urgentCount.toString(),
                colorScheme.error,
                Icons.warning_amber_outlined,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                l10n.soon,
                soonCount.toString(),
                colorScheme.warning,
                Icons.access_time,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                l10n.good,
                goodCount.toString(),
                colorScheme.primary,
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.65),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: color,
                height: 1.33,
              ),
            ),
          ],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutService,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aboutServiceDesc,
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
    );
  }

  Widget _buildStatsRow() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final statuses = _calculateScheduleStatuses();
    final totalComponents = _schedules.length;
    final needsAttention = (statuses['urgent'] ?? 0) + (statuses['soon'] ?? 0);

    return Row(
      children: [
        Expanded(
          child: Container(
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
                Text(
                  l10n.totalComponents,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalComponents.toString(),
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
                  l10n.monitored,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
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
                Text(
                  l10n.needsAttention,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  needsAttention.toString(),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: needsAttention > 0
                        ? colorScheme.warning
                        : colorScheme.primary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.item,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final statuses = _calculateScheduleStatuses();
    final urgentCount = statuses['urgent'] ?? 0;
    final soonCount = statuses['soon'] ?? 0;

    // Only show if there are no urgent/soon recommendations
    final bool hasSchedules = _schedules.isNotEmpty;
    if (urgentCount == 0 && soonCount == 0) {
      final IconData statusIcon = hasSchedules
          ? Icons.check_circle_outline
          : Icons.schedule_outlined;
      final Color statusIconColor = hasSchedules
          ? colorScheme.primary
          : colorScheme.secondary;
      final String statusMessage = hasSchedules
          ? 'Semua komponen dalam kondisi baik'
          : 'Belum ada jadwal perawatan yang dikonfigurasi';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusIconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusMessage,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recommendations,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 12),
          if (urgentCount > 0)
            _buildRecommendationItem(
              icon: Icons.warning_amber_outlined,
              color: colorScheme.error,
              title: l10n.urgentMaintenance,
              description: l10n.urgentMaintenanceDesc,
            ),
          if (urgentCount > 0 && soonCount > 0) const SizedBox(height: 8),
          if (soonCount > 0)
            _buildRecommendationItem(
              icon: Icons.access_time,
              color: colorScheme.warning,
              title: l10n.planMaintenance,
              description: l10n.planMaintenanceDesc,
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: color,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePatternCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final bool hasUsageData =
        !_isLoadingPattern &&
        ((_usagePattern['average_km_per_day'] ?? 0.0) > 0.0 ||
            (_usagePattern['weekly_km'] ?? 0.0) > 0.0);

    String usageIntensityText;
    String usageDescription;

    if (_isLoadingPattern) {
      usageIntensityText = '...';
      usageDescription = '';
    } else if (!hasUsageData) {
      usageIntensityText = 'Belum ada data';
      usageDescription =
          'Mulai berkendara untuk melihat analisis pola penggunaan Anda';
    } else {
      final avgKm = (_usagePattern['average_km_per_day'] ?? 0.0) is int
          ? (_usagePattern['average_km_per_day'] ?? 0.0).toDouble()
          : (_usagePattern['average_km_per_day'] ?? 0.0) as double;
      final intensity = _usagePattern['usage_intensity'] ?? 'light';
      if (intensity == 'heavy') {
        usageIntensityText = 'Penggunaan Berat';
        usageDescription =
            'Pola penggunaan berat Anda (rata-rata ${avgKm.toStringAsFixed(1)} km/hari) mempersingkat interval perawatan. Pantau kondisi kendaraan lebih sering.';
      } else if (intensity == 'moderate') {
        usageIntensityText = 'Penggunaan Sedang';
        usageDescription =
            'Pola penggunaan sedang Anda (rata-rata ${avgKm.toStringAsFixed(1)} km/hari) sesuai dengan interval perawatan standar.';
      } else {
        usageIntensityText = l10n.lightUsage;
        usageDescription =
            'Pola penggunaan ringan Anda (rata-rata ${avgKm.toStringAsFixed(1)} km/hari) memperpanjang interval perawatan.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.usagePatternSummary,
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
                      l10n.usagePatternDesc,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.1),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.3),
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usageIntensityText,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: hasUsageData
                              ? colorScheme.tertiary
                              : colorScheme.secondary,
                          height: 1.43,
                        ),
                      ),
                      if (usageDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          usageDescription,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface,
                            height: 1.62,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUsageStatBox(
                l10n.average,
                _isLoadingPattern
                    ? '...'
                    : '${_usagePattern['average_km_per_day'] ?? 0}',
                l10n.kmPerDay,
              ),
              const SizedBox(width: 12),
              _buildUsageStatBox(
                l10n.thisWeek,
                _isLoadingPattern
                    ? '...'
                    : '${(_usagePattern['weekly_km'] ?? 0).round()}',
                l10n.kmTotal,
              ),
              const SizedBox(width: 12),
              _buildUsageStatBox(
                l10n.odometer,
                _primaryVehicle != null
                    ? (_primaryVehicle!.odometer.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ))
                    : '0',
                l10n.km,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: Text(
              l10n.usagePatternFooter,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                height: 1.62,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatBox(String label, String value, String unit) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.secondary,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.56,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
