import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/tracking_api_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../riwayat_trip/riwayat_trip.dart';

class RoutePoint {
  const RoutePoint({
    required this.lat,
    required this.lng,
    required this.speedKph,
    required this.timestampMs,
  });

  final double lat;
  final double lng;
  final int speedKph;
  final int timestampMs;
}

class _TripSummary {
  const _TripSummary({
    required this.distanceKm,
    required this.durationSec,
    required this.avgSpeedKph,
    required this.maxSpeedKph,
  });

  final double distanceKm;
  final int durationSec;
  final double avgSpeedKph;
  final int maxSpeedKph;
}

class GpsTrackingActivePage extends StatefulWidget {
  const GpsTrackingActivePage({
    super.key,
    required this.vehicleId,
    this.vehicleName = 'My Ninja',
  });

  final int vehicleId;
  final String vehicleName;

  @override
  State<GpsTrackingActivePage> createState() => _GpsTrackingActivePageState();
}

class _GpsTrackingActivePageState extends State<GpsTrackingActivePage> {
  static const _bg = Color(0xFF0A0A0A);
  static const _card = Color(0xFF1A1A1A);
  static const _mapBg = Color(0xFF0F0F0F);
  static const _border = Color(0xFF2A2A2A);
  static const _muted = Color(0xFF9CA3AF);
  static const _muted2 = Color(0xFF6B7280);
  static const _green = Color(0xFF6B7C4F);
  static const _greenSoft = Color(0xFF8FA06A);
  static const _greenLight = Color(0xFFA3B87A);
  static const _greenDark = Color(0xFF4A5C30);

  final Random _random = Random();
  Timer? _timer;

  bool _isTracking = false;
  double _distanceKm = 0;
  int _durationSec = 0;
  int _speedKph = 0;
  double _avgSpeedKph = 0;
  int _maxSpeedKph = 0;
  double _currentLat = -6.2088;
  double _currentLng = 106.8456;
  final List<RoutePoint> _routePoints = <RoutePoint>[];

  @override
  void initState() {
    super.initState();
    _checkTrackingStatus();
  }

  Future<void> _checkTrackingStatus() async {
    try {
      final status = await TrackingApiService.checkStatus(widget.vehicleId);
      if (mounted) {
        setState(() {
          _isTracking = status.isTracking;
        });
        if (_isTracking) {
          // Lanjutkan timer jika sudah tracking
          _startLocalTimer();
        }
      }
    } catch (e) {
      debugPrint('Error check tracking status: $e');
    }
  }

  int _nextSpeed(int prev) {
    final change = (_random.nextDouble() - 0.5) * 12;
    final next = (prev == 0 ? 35 : prev) + change;
    return next.round().clamp(0, 80);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _durationSec += 1;

        final nextSpeed = _nextSpeed(_speedKph);
        _speedKph = nextSpeed;
        _maxSpeedKph = max(_maxSpeedKph, nextSpeed);

        final latDelta = (_random.nextDouble() - 0.5) * 0.0008;
        final lngDelta = (_random.nextDouble() - 0.5) * 0.0008;
        _currentLat += latDelta;
        _currentLng += lngDelta;

        _distanceKm += nextSpeed / 3600.0;
        if (_durationSec > 0) {
          _avgSpeedKph = (_distanceKm / _durationSec) * 3600.0;
        }

        _routePoints.add(
          RoutePoint(
            lat: _currentLat,
            lng: _currentLng,
            speedKph: nextSpeed,
            timestampMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      });
    });
  }

  Future<void> _startTracking() async {
    try {
      final success = await TrackingApiService.startTracking(widget.vehicleId);
      if (success && mounted) {
        setState(() {
          _isTracking = true;
          _distanceKm = 0;
          _durationSec = 0;
          _speedKph = 35;
          _avgSpeedKph = 0;
          _maxSpeedKph = 35;
          _routePoints
            ..clear()
            ..add(
              RoutePoint(
                lat: _currentLat,
                lng: _currentLng,
                speedKph: 35,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        });

        _startLocalTimer();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tracking dimulai')));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tracking gagal dimulai, mungkin trip masih aktif.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSummary() {
    final summary = _TripSummary(
      distanceKm: double.parse(_distanceKm.toStringAsFixed(2)),
      durationSec: _durationSec,
      avgSpeedKph: double.parse(_avgSpeedKph.toStringAsFixed(1)),
      maxSpeedKph: _maxSpeedKph,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.fromBorderSide(BorderSide(color: _border)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Perjalanan Selesai',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vehicleName,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.route_outlined,
                          title: summary.distanceKm.toStringAsFixed(2),
                          subtitle: 'Jarak (km)',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.access_time,
                          title: _formatDuration(summary.durationSec),
                          subtitle: 'Durasi',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.speed,
                          title: summary.avgSpeedKph.toStringAsFixed(1),
                          subtitle: 'Rata-rata (km/h)',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.trending_up,
                          title: summary.maxSpeedKph.toString(),
                          subtitle: 'Maks (km/h)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: _border),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RiwayatTripPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text(
                        'Lihat Riwayat Trip',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _border),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Dashboard',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _stopTracking() async {
    _timer?.cancel();

    try {
      final tripSummary = await TrackingApiService.stopTracking(
        widget.vehicleId,
      );

      // Update local stats from API response jika dibutuhkan
      // double apiDistanceKm = tripSummary['total_distance'] != null ? tripSummary['total_distance'].toDouble() : _distanceKm;
      // int apiDurationMin = tripSummary['duration_minutes'] != null ? tripSummary['duration_minutes'] : (_durationSec ~/ 60);

      if (mounted) {
        setState(() {
          _isTracking = false;
          _speedKph = 0;
        });
        _showSummary();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking berhasil dihentikan')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTracking = false;
          _speedKph = 0;
        });
        _showSummary();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error hentikan tracking: $e')));
      }
    }
  }

  static String _formatDuration(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hrs > 0) {
      return '$hrs:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String _speedLabel(int spd) {
    if (spd < 20) return 'Pelan';
    if (spd < 40) return 'Sedang';
    if (spd < 60) return 'Cepat';
    return 'Sangat Cepat';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                title: l10n.liveTracking,
                subtitle: widget.vehicleName,
                isTracking: _isTracking,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_isTracking) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _SpeedPanel(
                            speedKph: _speedKph,
                            maxSpeedKph: _maxSpeedKph,
                            label: _speedLabel(_speedKph),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _MapCard(
                          isTracking: _isTracking,
                          routePoints: _routePoints,
                          currentLat: _currentLat,
                          currentLng: _currentLng,
                          onStartStop: _isTracking
                              ? _stopTracking
                              : _startTracking,
                          startStopLabel: _isTracking
                              ? 'Akhiri Perjalanan'
                              : 'Mulai Tracking',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: _StatsGrid(
                          distanceKm: _distanceKm,
                          durationText: _formatDuration(_durationSec),
                          avgSpeedKph: _avgSpeedKph,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.isTracking,
    required this.onBack,
  });

  static const _green = Color(0xFF6B7C4F);
  static const _bg = Color(0xFF0A0A0A);

  final String title;
  final String subtitle;
  final bool isTracking;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onBack,
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left, color: _green, size: 28),
                    SizedBox(width: 2),
                    Text(
                      'Kembali',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: _green,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTracking)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      _PulseDot(),
                      SizedBox(width: 8),
                      Text(
                        'AKTIF',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: Color(0xFF8FA06A),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 64),
            ],
          ),
          IgnorePointer(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF6B7C4F),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _SpeedPanel extends StatelessWidget {
  const _SpeedPanel({
    required this.speedKph,
    required this.maxSpeedKph,
    required this.label,
  });

  static const _card = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);

  final int speedKph;
  final int maxSpeedKph;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kecepatan Saat Ini',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        speedKph.toString(),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'km/h',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A1A),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _green.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: Color(0xFF8FA06A),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Maks',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    maxSpeedKph.toString(),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'km/h',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 6,
              color: const Color(0xFF1F1F1F),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (speedKph / 80).clamp(0.0, 1.0),
                  child: Container(color: _green),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF4B5563),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '40',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF4B5563),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '80 km/h',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF4B5563),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.isTracking,
    required this.routePoints,
    required this.currentLat,
    required this.currentLng,
    required this.onStartStop,
    required this.startStopLabel,
  });

  static const _card = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _mapBg = Color(0xFF0F0F0F);
  static const _green = Color(0xFF6B7C4F);
  static const _greenLight = Color(0xFFA3B87A);
  static const _greenSoft = Color(0xFF8FA06A);

  final bool isTracking;
  final List<RoutePoint> routePoints;
  final double currentLat;
  final double currentLng;
  final VoidCallback onStartStop;
  final String startStopLabel;

  @override
  Widget build(BuildContext context) {
    final canDrawRoute = isTracking && routePoints.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: _green),
                      SizedBox(width: 8),
                      Text(
                        'Peta Rute',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (isTracking)
                    const Row(
                      children: [
                        Icon(Icons.network_cell, size: 16, color: _green),
                        SizedBox(width: 6),
                        Text(
                          'GPS Terhubung',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: _greenSoft,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 256,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: _mapBg,
                      child: CustomPaint(
                        painter: _MapGridPainter(),
                        foregroundPainter: canDrawRoute
                            ? _RoutePainter(
                                points: routePoints,
                                glowColor: _green,
                                lineColor: _greenLight,
                              )
                            : null,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  if (!canDrawRoute)
                    const Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.navigation_outlined,
                              size: 32,
                              color: Color(0xFF374151),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mulai tracking untuk melihat rute',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: Color(0xFF4B5563),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isTracking)
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Row(
                        children: [
                          _CoordBlock(
                            label: 'Lintang',
                            value: '${currentLat.toStringAsFixed(6)}°',
                          ),
                          const SizedBox(width: 16),
                          _CoordBlock(
                            label: 'Bujur',
                            value: '${currentLng.toStringAsFixed(6)}°',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStartStop,
                  icon: Icon(
                    isTracking ? Icons.square : Icons.navigation_outlined,
                    size: 16,
                    color: isTracking ? Colors.white : Colors.white,
                  ),
                  label: Text(
                    startStopLabel,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isTracking
                        ? const Color(0xFF0A0A0A)
                        : _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isTracking ? _border : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordBlock extends StatelessWidget {
  const _CoordBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: Color(0xFF4B5563),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Courier New',
            color: Color(0xFF8FA06A),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.distanceKm,
    required this.durationText,
    required this.avgSpeedKph,
  });

  final double distanceKm;
  final String durationText;
  final double avgSpeedKph;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.route_outlined,
            value: distanceKm.toStringAsFixed(2),
            label: 'Jarak (km)',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.access_time,
            value: durationText,
            label: 'Waktu',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.speed,
            value: avgSpeedKph.toStringAsFixed(1),
            label: 'Rata-rata',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  static const _card = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _green),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const _bg = Color(0xFF0A0A0A);
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _green),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 1;

    for (int i = 1; i <= 9; i++) {
      final y = size.height * (i / 10);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (int i = 1; i <= 9; i++) {
      final x = size.width * (i / 10);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.points,
    required this.glowColor,
    required this.lineColor,
  });

  final List<RoutePoint> points;
  final Color glowColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = points.length <= 30
        ? points
        : points.sublist(points.length - 30);
    if (pts.length < 2) return;

    final minLat = pts.map((p) => p.lat).reduce(min);
    final maxLat = pts.map((p) => p.lat).reduce(max);
    final minLng = pts.map((p) => p.lng).reduce(min);
    final maxLng = pts.map((p) => p.lng).reduce(max);
    final latRange = (maxLat - minLat) == 0 ? 0.001 : (maxLat - minLat);
    final lngRange = (maxLng - minLng) == 0 ? 0.001 : (maxLng - minLng);

    Offset mapPt(RoutePoint p) {
      const w = 400.0;
      const h = 256.0;
      final x = 20 + ((p.lng - minLng) / lngRange) * 360;
      final y = 236 - ((p.lat - minLat) / latRange) * 216;
      return Offset(x / w * size.width, y / h * size.height);
    }

    final offsets = pts.map(mapPt).toList(growable: false);

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }

    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    final start = offsets.first;
    final end = offsets.last;

    final startFill = Paint()..color = const Color(0xFF4A5C30);
    final startStroke = Paint()
      ..color = const Color(0xFF6B7C4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(start, 4, startFill);
    canvas.drawCircle(start, 4, startStroke);

    canvas.drawCircle(
      end,
      9,
      Paint()..color = const Color(0xFF6B7C4F).withValues(alpha: 0.2),
    );
    canvas.drawCircle(end, 5, Paint()..color = const Color(0xFF6B7C4F));
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
