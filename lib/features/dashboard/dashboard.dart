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
import '../servis/schedule/jadwal.dart';
import '../servis/schedule/tambah_jadwal.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/app_theme.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/model/vehicle_model.dart';
import '../../core/model/service_schedule_model.dart';
import '../../core/services/notification_api_service.dart';
import '../../core/services/service_schedule_service.dart';
import '../../core/services/tracking_api_service.dart';
import '../../core/services/trip_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../recommendation/screens/recommendation_service_screen.dart';
import '../recommendation/state/recommendation_home_insight_notifier.dart';
import '../recommendation/widgets/meta_info_row.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final int _selectedIndex = 0;
  final _vehicleService = VehicleService();
  final _scheduleService = ServiceScheduleService();
  VehicleModel? _primaryVehicle;
  bool _isLoadingVehicle = true;
  bool _isTrackingActive = false;
  Map<String, dynamic> _serviceMetrics = {};
  bool _isLoadingMetrics = true;
  int _unreadNotificationCount = 0;

  // Weekly Trend State
  double _thisWeekDistance = 0.0;
  double _lastWeekDistance = 0.0;
  bool _isLoadingTrends = true;

  late final RecommendationHomeInsightNotifier _homeInsightNotifier;
  List<ServiceScheduleModel> _dashboardSchedules = [];
  bool _isLoadingSchedules = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeInsightNotifier = RecommendationHomeInsightNotifier();
    _loadPrimaryVehicle();
    _loadServiceMetrics();
    _loadUnreadCount();
    _loadDashboardSchedules();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeInsightNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTrackingStatus();
    }
  }

  Future<void> _refreshTrackingStatus() async {
    final motorId = _primaryVehicle?.id;
    if (motorId == null) {
      if (mounted) {
        setState(() => _isTrackingActive = false);
      }
      return;
    }

    try {
      final status = await TrackingApiService.checkStatus(motorId);
      if (!mounted) return;
      setState(() {
        _isTrackingActive = status.isTracking;
      });
    } catch (e) {
      print('Failed to refresh tracking status: $e');
      if (!mounted) return;
      setState(() {
        _isTrackingActive = false;
      });
    }
  }

  Future<void> _loadDashboardSchedules() async {
    try {
      final schedules = await _scheduleService.getAllSchedules();
      if (mounted) {
        setState(() {
          _dashboardSchedules = schedules;
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      print('Failed to load dashboard schedules: $e');
      if (mounted) {
        setState(() => _isLoadingSchedules = false);
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationApiService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      print('Failed to load unread count: $e');
    }
  }

  void _setupNotificationListener() {
    // Listen for new notifications while app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 New notification received: ${message.notification?.title}');
      // Reload unread count when new notification arrives
      _loadUnreadCount();
    });
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

        final motorId = vehicle?.id;
        if (motorId != null) {
          _homeInsightNotifier.load(motorId);
          _refreshTrackingStatus();
          _loadWeeklyTrends(motorId);
        } else {
          setState(() {
            _isTrackingActive = false;
          });
        }

        // Check service reminders after loading vehicle on app startup
        if (vehicle != null) {
          try {
            await ServiceScheduleService().checkReminders(
              vehicle.id!,
              vehicle.odometer,
            );
          } catch (e) {
            print('⚠️ Failed to check reminders on startup: $e');
            // Don't fail the app startup if reminder check fails
          }
        }
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

  Future<void> _loadWeeklyTrends(int vehicleId) async {
    try {
      if (mounted) setState(() => _isLoadingTrends = true);
      final tripService = TripService();
      final allTrips = await tripService.getAllTrips(
        vehicleId: vehicleId.toString(),
      );

      final now = DateTime.now();
      // Asumsikan minggu dimulai dari Senin (1) hingga Minggu (7)
      final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfThisWeekDate = DateTime(
        startOfThisWeek.year,
        startOfThisWeek.month,
        startOfThisWeek.day,
      );

      final startOfLastWeekDate = startOfThisWeekDate.subtract(
        const Duration(days: 7),
      );
      final endOfLastWeekDate = startOfThisWeekDate.subtract(
        const Duration(milliseconds: 1),
      );

      double thisWeekDist = 0;
      double lastWeekDist = 0;

      for (var trip in allTrips) {
        if (trip.status != 'completed' && trip.status != 'stopped') continue;

        final tripDate = trip.startTime;
        if (tripDate.isAfter(startOfThisWeekDate) ||
            tripDate.isAtSameMomentAs(startOfThisWeekDate)) {
          thisWeekDist += trip.totalDistance;
        } else if (tripDate.isAfter(startOfLastWeekDate) &&
            tripDate.isBefore(endOfLastWeekDate)) {
          lastWeekDist += trip.totalDistance;
        }
      }

      if (mounted) {
        setState(() {
          _thisWeekDistance = thisWeekDist;
          _lastWeekDistance = lastWeekDist;
          _isLoadingTrends = false;
        });
      }
    } catch (e) {
      print('Failed to load weekly trends: $e');
      if (mounted) setState(() => _isLoadingTrends = false);
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
                                    ? Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        child: SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      )
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
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _primaryVehicle?.title ??
                                                      'Belum ada kendaraan',
                                                  style: TextStyle(
                                                    fontFamily: 'Arial',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 18,
                                                color: colorScheme.secondary
                                                    .withAlpha(180),
                                              ),
                                            ],
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            SmoothPageRoute(page: const NotificationPage()),
                          );
                          // Reload count after returning from notification page
                          _loadUnreadCount();
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
                            if (_unreadNotificationCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _unreadNotificationCount > 99
                                          ? '99+'
                                          : '$_unreadNotificationCount',
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 11,
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
                        // Start Tracking Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _primaryVehicle == null
                                ? null
                                : () async {
                                    await Navigator.push(
                                      context,
                                      SmoothPageRoute(
                                        page: GpsTrackingPage(
                                          vehicleId: _primaryVehicle!.id!,
                                          vehicleName: _primaryVehicle!.title,
                                          currentVehicle: _primaryVehicle,
                                        ),
                                      ),
                                    );

                                    // Saat kembali dari halaman tracking, sinkronkan lagi status tombol.
                                    await _refreshTrackingStatus();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryVehicle == null
                                  ? colorScheme.surfaceContainerHighest
                                  : (_isTrackingActive
                                        ? colorScheme.error
                                        : colorScheme.primary),
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
                                  _isTrackingActive
                                      ? Icons.stop_circle_outlined
                                      : Icons.location_on,
                                  size: 24,
                                  color: _primaryVehicle == null
                                      ? colorScheme.onSurfaceVariant
                                      : Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    _primaryVehicle == null
                                        ? 'Tambah kendaraan terlebih dahulu'
                                        : (_isTrackingActive
                                              ? 'Sedang Melacak'
                                              : l10n.startTracking),
                                    textAlign: TextAlign.center,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Monitored Components Card
                        AnimatedBuilder(
                          animation: _homeInsightNotifier,
                          builder: (context, _) {
                            final motorId = _primaryVehicle?.id;
                            final insight = _homeInsightNotifier.homeInsight;
                            final summary = insight?.monitoredSummary;

                            int criticalCount = summary?.critical ?? 0;
                            int warningCount = summary?.warning ?? 0;
                            int normalCount = summary?.normal ?? 0;
                            int totalComponents = summary?.total ?? 0;

                            if (totalComponents <= 0) {
                              totalComponents =
                                  insight?.fuzzyScores.length ?? 0;
                            }

                            if (criticalCount + warningCount + normalCount ==
                                    0 &&
                                (insight?.fuzzyStatuses.isNotEmpty ?? false)) {
                              for (final status
                                  in insight!.fuzzyStatuses.values) {
                                if (status == 'critical') {
                                  criticalCount++;
                                } else if (status == 'warning') {
                                  warningCount++;
                                } else {
                                  normalCount++;
                                }
                              }
                            }

                            return Container(
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
                                        Icons.tune,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '$totalComponents Komponen Sedang Dipantau',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
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
                                  else if (_homeInsightNotifier
                                          .isLoadingInsight &&
                                      (insight == null ||
                                          insight.fuzzyScores.isEmpty))
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status komponen berdasarkan fuzzy monitoring saat ini.',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.6,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildMonitoringStatChip(
                                                label: 'Critical',
                                                value: criticalCount,
                                                color: colorScheme.error,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildMonitoringStatChip(
                                                label: 'Warning',
                                                value: warningCount,
                                                color: colorScheme.warning,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildMonitoringStatChip(
                                                label: 'Normal',
                                                value: normalCount,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    SmoothPageRoute(
                                                      page:
                                                          RecommendationServiceScreen(
                                                            motorId: motorId,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Cek Sekarang',
                                                  style: TextStyle(
                                                    fontFamily: 'Arial',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    SmoothPageRoute(
                                                      page: const JadwalPage(),
                                                    ),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  side: BorderSide(
                                                    color: colorScheme.outline,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Buat Reminder',
                                                  style: TextStyle(
                                                    fontFamily: 'Arial',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        MetaInfoRow(
                                          meta: _homeInsightNotifier
                                              .effectiveMeta,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
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
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      SmoothPageRoute(
                                        page: const TambahJarakPage(),
                                      ),
                                    );
                                    // Reload data if manual distance was added successfully
                                    if (result == true && mounted) {
                                      _loadPrimaryVehicle();
                                      _loadServiceMetrics();
                                    }
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
                                      _isLoadingTrends
                                          ? '...'
                                          : '${(_thisWeekDistance / DateTime.now().weekday).toStringAsFixed(1)} km',
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
                                      _isLoadingTrends
                                          ? '...'
                                          : '${_thisWeekDistance.toStringAsFixed(1)} km',
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
                                          page: StatistikMingguanPage(
                                            vehicleId: _primaryVehicle!.id
                                                .toString(),
                                            vehicleName: _primaryVehicle!.title,
                                          ),
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
                                        _isLoadingTrends
                                            ? '...'
                                            : '${_lastWeekDistance.toStringAsFixed(1)} km',
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
                                        widthFactor: _isLoadingTrends
                                            ? 0
                                            : (_lastWeekDistance > 0
                                                  ? 1.0
                                                  : 0.0),
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colorScheme.onSurfaceVariant
                                                .withAlpha((255 * 0.6).round()),
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
                                        _isLoadingTrends
                                            ? '...'
                                            : '${_thisWeekDistance.toStringAsFixed(1)} km',
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
                                        widthFactor: _isLoadingTrends
                                            ? 0
                                            : (_thisWeekDistance > 0 &&
                                                      _thisWeekDistance >=
                                                          _lastWeekDistance
                                                  ? 1.0
                                                  : (_lastWeekDistance > 0
                                                        ? _thisWeekDistance /
                                                              _lastWeekDistance
                                                        : 0.0)),
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
                                      _isLoadingTrends
                                          ? '...'
                                          : '${_thisWeekDistance.toStringAsFixed(1)} km',
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

                        // Insight Sistem + Skor Fuzzy (Sistem Rekomendasi)
                        AnimatedBuilder(
                          animation: _homeInsightNotifier,
                          builder: (context, _) {
                            final motorId = _primaryVehicle?.id;
                            final insight =
                                _homeInsightNotifier.homeInsight?.insightSistem;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Insight Sistem',
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
                                      child: Text(
                                        l10n.howSystemWorks,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    17,
                                    17,
                                    17,
                                    16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                      width: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: motorId == null
                                      ? Text(
                                          'Pilih kendaraan untuk melihat insight sistem.',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.67,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        )
                                      : insight == null
                                      ? Text(
                                          'Insight sistem belum tersedia.',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.67,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              insight.label,
                                              style: TextStyle(
                                                fontFamily: 'Arial',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                height: 1.43,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              insight.isi,
                                              style: TextStyle(
                                                fontFamily: 'Arial',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                height: 1.67,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),

                              ],
                            );
                          },
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
                fontSize: 10,
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

  Widget _buildMonitoringStatChip({
    required String label,
    required int value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.65),
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
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
