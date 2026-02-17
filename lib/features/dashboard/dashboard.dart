import 'package:flutter/material.dart';
import 'widgets/sistem_work.dart';
import '../widget/bottom_navbar.dart';
import '../widget/page_transition.dart';
import 'widgets/tambah_jarak.dart';
import 'widgets/tracking/gps_tracking_page.dart';
import 'widgets/riwayat_trip/riwayat_trip.dart';
import 'widgets/tren_mingguan/statistik_mingguan.dart';
import 'widgets/tambah_motor/list_motor.dart';
import '../notification/notification_page.dart';
import '../servis/service.dart';
import '../servis/schedule/tambah_jadwal.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/model/vehicle_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final int _selectedIndex = 0;
  final _vehicleService = VehicleService();
  VehicleModel? _primaryVehicle;
  bool _isLoadingVehicle = true;
  Map<String, dynamic> _serviceMetrics = {};
  bool _isLoadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadPrimaryVehicle();
    _loadServiceMetrics();
  }

  Future<void> _loadPrimaryVehicle() async {
    try {
      // Debug: Print auth info first
      await _vehicleService.debugPrintAuthInfo();

      final vehicle = await _vehicleService.getPrimaryVehicle();
      if (mounted) {
        setState(() {
          _primaryVehicle = vehicle;
          _isLoadingVehicle = false;
        });
      }
    } catch (e) {
      print('Failed to load primary vehicle: $e');
      if (mounted) {
        setState(() {
          _isLoadingVehicle = false;
        });
      }
    }
  }

  Future<void> _loadServiceMetrics() async {
    try {
      final metrics = await _vehicleService.getServiceMetrics();
      if (mounted) {
        setState(() {
          _serviceMetrics = metrics;
          _isLoadingMetrics = false;
        });
      }
    } catch (e) {
      print('Failed to load service metrics: $e');
      if (mounted) {
        setState(() {
          _isLoadingMetrics = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Fixed Header Section
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                15,
                24,
                16,
              ), // 👈 kecilkan atas
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  // Top Header with Vehicle Info and Notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Vehicle Info
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              SmoothPageRoute(page: const ListMotorPage()),
                            );
                            // Reload vehicle if changed
                            if (result == true) {
                              _loadPrimaryVehicle();
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: _isLoadingVehicle
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.activeVehicle,
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              color: colorScheme.secondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _primaryVehicle?.title ??
                                                'Belum ada kendaraan',
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 24,
                                              fontWeight: FontWeight.w400,
                                              height: 1.33,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _primaryVehicle != null
                                                ? '${_primaryVehicle!.make} ${_primaryVehicle!.model} • ${_primaryVehicle!.year}'
                                                : 'Tap untuk menambahkan',
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              color: colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notification Bell
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const NotificationPage()),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: colorScheme.onSurface,
                                size: 24,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Odometer Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentOdometer,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _primaryVehicle != null
                                ? '${_primaryVehicle!.odometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km'
                                : '0 km',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Vehicle Status Card
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Status Header
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      page: const MaintenancePage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.goodCondition,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: colorScheme.secondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Service Info
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.distanceSinceService,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        _isLoadingMetrics
                                            ? '...'
                                            : '${_serviceMetrics['distance_since_service'] ?? 0} km',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.untilNextService,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        _isLoadingMetrics
                                            ? '...'
                                            : '${_serviceMetrics['distance_until_next_service'] ?? 0} km',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Progress Bar
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.42, // 950/(950+1550)
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Start Tracking Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _primaryVehicle == null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(
                                        page: const GpsTrackingPage(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryVehicle == null
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.primary,
                              disabledBackgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              elevation: 0,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 24,
                                  color: _primaryVehicle == null
                                      ? colorScheme.onSurfaceVariant
                                      : Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _primaryVehicle == null
                                      ? 'Tambah kendaraan terlebih dahulu'
                                      : l10n.startTracking,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.56,
                                    color: _primaryVehicle == null
                                        ? colorScheme.onSurfaceVariant
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Manual Distance Card
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.manualDistance,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.manualDistanceDesc,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.67,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(
                                        page: const TambahJarakPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.manualDistance,
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statistics Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.dailyAverage,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.33,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '11.1 km',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.show_chart,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.thisWeekProgress,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.33,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '78.0 km',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Smart Insights Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.smartInsights,
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  20,
                                  0,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.car_repair,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.checkOilLevel,
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.oilCheckReminder,
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              height: 1.67,
                                              color: colorScheme.secondary,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Actions
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                l10n.quickActions,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.add_circle_outline,
                                    label: l10n.addSchedule,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SmoothPageRoute(
                                          page: const TambahJadwalPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.history,
                                    label: l10n.tripHistory,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SmoothPageRoute(
                                          page: const RiwayatTripPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.directions_bike,
                                    label: l10n.switchVehicle,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SmoothPageRoute(
                                          page: const ListMotorPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Weekly Trend Card
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.weeklyTrend,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        SmoothPageRoute(
                                          page: const StatistikMingguanPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l10n.viewDetails,
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Last Week Progress
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.lastWeek,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                      Text(
                                        '0.0 km',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: 0.15,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // This Week Progress
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.thisWeek,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                      Text(
                                        '78.0 km',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Summary
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  16,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.thisWeekYouRode,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '78.0 km',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        height: 1.43,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // System Insights
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.smartInsights,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(
                                        page: const SistemWorkPage(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        l10n.howSystemWorks,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.fromLTRB(17, 17, 17, 1),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.analytics_outlined,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.usageBasedMaintenance,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.usageBasedMaintenanceDesc,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.67,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.generatedFromAnalysis,
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            letterSpacing: 0.25,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.33,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
