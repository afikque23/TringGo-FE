import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../widget/bottom_navbar.dart';
import '../widget/page_transition.dart';
import 'schedule/jadwal.dart';
import 'history/riwayat_service.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/services/service_schedule_service.dart';
import '../../core/model/vehicle_model.dart';
import '../../core/model/service_schedule_model.dart';
import '../recommendation/screens/recommendation_service_screen.dart';
import '../recommendation/state/recommendation_service_notifier.dart';
import '../recommendation/widgets/meta_info_row.dart';
import '../recommendation/widgets/priority_badge.dart';

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
  bool _isLoading = true;
  Map<String, dynamic> _usagePattern = {};
  bool _isLoadingPattern = true;

  late final RecommendationServiceNotifier _recommendationNotifier;

  @override
  void initState() {
    super.initState();
    _recommendationNotifier = RecommendationServiceNotifier();
    _loadData();
    _loadUsagePattern();
  }

  @override
  void dispose() {
    _recommendationNotifier.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await _loadData();
    final motorId = _primaryVehicle?.id;
    if (motorId != null) {
      await _recommendationNotifier.refresh(motorId);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final vehicle = await _vehicleService.getPrimaryVehicle();

      // Get schedules filtered by vehicle ID
      final schedules = vehicle != null
          ? await _scheduleService.getAllSchedules(vehicleId: vehicle.id)
          : <ServiceScheduleModel>[];

      if (mounted) {
        setState(() {
          _primaryVehicle = vehicle;
          _isLoading = false;
        });
      }

      final motorId = vehicle?.id;
      if (motorId != null) {
        _recommendationNotifier.load(motorId);
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
                      onRefresh: _refreshAll,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Column(
                          children: [
                            _buildInfoCard(),
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


  Widget _buildRecommendationsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _recommendationNotifier,
      builder: (context, _) {
        final motorId = _primaryVehicle?.id;
        final data = _recommendationNotifier.recommendation;
        final ringkasan = data?.ringkasanKondisi;
        final rekom = data?.rekomendasiKomponen ?? const [];
        final hasTips = (data?.tipsMandiri ?? '').trim().isNotEmpty;
        final error = _recommendationNotifier.errorMessage;

        return GestureDetector(
          onTap: motorId == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                      page: RecommendationServiceScreen(motorId: motorId),
                    ),
                  );
                },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sistem Rekomendasi Servis',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.43,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (motorId == null)
                  Text(
                    'Pilih kendaraan untuk melihat rekomendasi.',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (_recommendationNotifier.isLoadingRecommendation &&
                    (data == null || rekom.isEmpty))
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (error != null && (data == null || rekom.isEmpty))
                  Text(
                    error,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                      color: colorScheme.error,
                    ),
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 0.65,
                      ),
                    ),
                    child: Text(
                      (ringkasan == null || ringkasan.trim().isEmpty)
                          ? 'Ringkasan kondisi belum tersedia.'
                          : ringkasan,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.67,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (rekom.isEmpty)
                    Text(
                      'Belum ada rekomendasi servis saat ini.',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.67,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final item in rekom)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 1.43,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PriorityBadge(priority: item.prioritas),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.saran,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.67,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (item.estimasiWaktu.trim().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Estimasi: ${item.estimasiWaktu}',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.67,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (hasTips) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Tips tersedia (lihat detail)',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  MetaInfoRow(meta: _recommendationNotifier.effectiveMeta),
                ],
              ],
            ),
          ),
        );
      },
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
