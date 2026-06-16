import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/tracking_api_service.dart';
import '../../../../l10n/app_localizations.dart';

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
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);

  final MapController _mapController = MapController();
  final Random _random = Random();
  Timer? _timer;

  bool _isTracking = false;
  double _distanceKm = 0;
  int _durationSec = 0;
  int _speedKph = 0;
  double _avgSpeedKph = 0;
  int _maxSpeedKph = 0;
  DateTime? _startTime;

  // IoT Status
  String _iotStatus = 'unknown'; // 'online' | 'unstable' | 'offline' | 'unknown'
  int? _iotSecondsAgo;

  // Data BMP280
  double? _baroRelAltM;
  double? _temperatureC;

  // Koordinat awal (misal: Semarang)
  LatLng _currentLocation = const LatLng(-6.9535, 110.4388);
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

        // Fetch lokasi terakhir dari IoT segera setelah halaman dibuka (walau belum tracking/Start)
        await _fetchLatestLocationData();

        if (_isTracking) {
          _startPolling();
        }
      }
    } catch (e) {
      debugPrint('Error check tracking status: $e');
    }
  }

  Future<void> _fetchLatestLocationData() async {
    try {
      final latestData = await TrackingApiService.getLatestLocation(
        widget.vehicleId,
      );

      if (latestData != null && mounted) {
        final newLat = (latestData['latitude'] as num).toDouble();
        final newLng = (latestData['longitude'] as num).toDouble();
        final currentSpeed = (latestData['speed_kph'] as num?)?.toInt() ?? 0;

        // Baca IoT status dari response backend
        final iotStatus = latestData['iot_status'] as String? ?? 'unknown';
        final secondsAgo = (latestData['seconds_ago'] as num?)?.toInt();

        // Baca data BMP280
        final baroAlt = (latestData['baro_rel_alt_m'] as num?)?.toDouble();
        final tempC = (latestData['temperature_c'] as num?)?.toDouble();

        setState(() {
          _speedKph = currentSpeed;
          _maxSpeedKph = max(_maxSpeedKph, currentSpeed);
          _currentLocation = LatLng(newLat, newLng);
          _iotStatus = iotStatus;
          _iotSecondsAgo = secondsAgo;
          _baroRelAltM = baroAlt;
          _temperatureC = tempC;

          if (_isTracking) {
            final distanceDelta = (currentSpeed / 3600.0) * 5;
            _distanceKm += distanceDelta;

            if (_durationSec > 0) {
              _avgSpeedKph = (_distanceKm / _durationSec) * 3600.0;
            }

            _routePoints.add(
              RoutePoint(
                lat: newLat,
                lng: newLng,
                speedKph: currentSpeed,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }
        });

        _mapController.move(_currentLocation, _mapController.camera.zoom);
      }
    } catch (e) {
      debugPrint('Error get latest location: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi timer 1 detik untuk UI dan polling 5 detik ke backend
  void _startPolling() {
    _startTime ??= DateTime.now();
    _timer?.cancel();

    // Lakukan fetch sekali langsung agar tidak perlu menunggu 5 detik pertama
    _fetchLatestLocationData();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      if (_isTracking && _startTime != null) {
        setState(() {
          _durationSec = DateTime.now().difference(_startTime!).inSeconds;
        });
      }

      // Polling setiap 5 detik sesuai pengiriman MQTT backend
      if (timer.tick % 5 == 0) {
        await _fetchLatestLocationData();
      }
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
          _speedKph = 0;
          _avgSpeedKph = 0;
          _maxSpeedKph = 0;
          _startTime = DateTime.now();
          _routePoints
            ..clear()
            ..add(
              RoutePoint(
                lat: _currentLocation.latitude,
                lng: _currentLocation.longitude,
                speedKph: 0,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        });

        _startPolling();
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

  Future<void> _confirmStopTracking() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hentikan Tracking?',
            style: TextStyle(color: Colors.white, fontFamily: 'Arial'),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghentikan tracking? Riwayat perjalanan saat ini akan otomatis disimpan.',
            style: TextStyle(color: Colors.white70, fontFamily: 'Arial'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontFamily: 'Arial'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hentikan & Simpan',
                style: TextStyle(color: Colors.white, fontFamily: 'Arial'),
              ),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      await _stopTracking();
    }
  }

  Future<void> _stopTracking() async {
    _timer?.cancel();

    try {
      final tripSummary = await TrackingApiService.stopTracking(
        widget.vehicleId,
      );

      if (mounted) {
        setState(() {
          _isTracking = false;
          _speedKph = 0;
        });

        // Kembalikan TripData ke halaman sebelumnya menggunakan summary backend
        _returnTripData(tripSummary: tripSummary);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTracking = false;
          _speedKph = 0;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error hentikan tracking: $e')));

        // Tetap kembali menggunakan data lokal jika API error
        _returnTripData();
      }
    }
  }

  void _returnTripData({Map<String, dynamic>? tripSummary}) {
    final endTime = DateTime.now();
    final stTime = _startTime ?? endTime;

    // Gunakan summary dari backend jika tersedia, fallback ke kalkulasi lokal
    final summary = tripSummary?['summary'] as Map<String, dynamic>?;

    final distKm = summary?['distance_km'] != null
        ? (summary!['distance_km'] as num).toStringAsFixed(2)
        : tripSummary != null && tripSummary['distance_meters'] != null
            ? ((tripSummary['distance_meters'] as num) / 1000).toStringAsFixed(2)
            : _distanceKm.toStringAsFixed(2);

    final durMin = summary?['duration_minutes'] != null
        ? summary!['duration_minutes'].toString()
        : tripSummary != null && tripSummary['duration_minutes'] != null
            ? tripSummary['duration_minutes'].toString()
            : (_durationSec ~/ 60).toString();

    final avgKph = summary?['avg_speed_kph'] != null
        ? (summary!['avg_speed_kph'] as num).toStringAsFixed(1)
        : _avgSpeedKph.toStringAsFixed(1);

    final maxKph = summary?['max_speed_kph'] != null
        ? summary!['max_speed_kph'].toString()
        : _maxSpeedKph.toString();

    final elevationGainM = summary?['elevation_gain_m'] as int?;
    final ambientTempAvg = summary?['ambient_temp_avg'];
    final newOdometer = summary?['new_odometer'];

    final tripData = {
      'vehicle': widget.vehicleName,
      'distanceValue': distKm,
      'durationMinutes': durMin,
      'averageSpeedKph': avgKph,
      'maxSpeedKph': maxKph,
      'elevationGainM': elevationGainM,
      'ambientTempAvg': ambientTempAvg,
      'newOdometer': newOdometer,
      'startTime':
          '${stTime.hour.toString().padLeft(2, '0')}:${stTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'routePoints': _routePoints
          .map((p) => {'lat': p.lat, 'lng': p.lng})
          .toList(),
      if (_routePoints.isNotEmpty) ...{
        'startLat': _routePoints.first.lat,
        'startLng': _routePoints.first.lng,
        'endLat': _routePoints.last.lat,
        'endLng': _routePoints.last.lng,
      },
    };

    Navigator.of(context).pop(tripData);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final points = _routePoints.map((p) => LatLng(p.lat, p.lng)).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // 1. Peta Layar Penuh
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  // CartoDB Voyager Style
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.motorcycle_management',
                ),
                PolylineLayer(
                  polylines: [
                    if (points.length > 1)
                      Polyline(
                        points: points,
                        strokeWidth: 5.0,
                        color: Colors.blueAccent,
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.motorcycle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Tombol Back
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: _card.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),

            // 3. IoT Status Indicator — kanan atas (selalu tampil)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Indikator tracking AKTIF
                      if (_isTracking)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2A1A).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _green.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PulseDot(),
                              SizedBox(width: 8),
                              Text('AKTIF', style: TextStyle(fontFamily: 'Arial', color: Color(0xFF8FA06A), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (_isTracking) const SizedBox(height: 8),
                      // Indikator IoT Online/Offline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _iotStatus == 'online'
                                ? _green
                                : _iotStatus == 'unstable'
                                    ? Colors.orange
                                    : Colors.redAccent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _iotStatus == 'online'
                                    ? _green
                                    : _iotStatus == 'unstable'
                                        ? Colors.orange
                                        : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _iotStatus == 'online'
                                  ? 'IoT Online'
                                  : _iotStatus == 'unstable'
                                      ? 'Tidak Stabil'
                                      : _iotStatus == 'offline'
                                          ? 'IoT Offline'
                                          : 'Mendeteksi...',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: _iotStatus == 'online'
                                    ? const Color(0xFF8FA06A)
                                    : _iotStatus == 'unstable'
                                        ? Colors.orange
                                        : Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Overlay Data & Tombol Bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kecepatan Utama
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _isTracking ? _speedKph.toString() : '0',
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'km/h',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Color(0xFF9CA3AF),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Jarak dan Durasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Jarak',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _distanceKm.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'km',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(width: 1, height: 40, color: _border),
                          Column(
                            children: [
                              const Text(
                                'Waktu',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(_durationSec),
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                       // Tombol START/STOP
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          // Disable START jika IoT offline atau unknown
                          onPressed: _isTracking
                              ? _confirmStopTracking
                              : (_iotStatus == 'offline' || _iotStatus == 'unknown')
                                  ? null
                                  : _startTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking
                                ? Colors.redAccent
                                : (_iotStatus == 'offline' || _iotStatus == 'unknown')
                                    ? const Color(0xFF3A3A3A)
                                    : _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isTracking
                                ? 'STOP'
                                : (_iotStatus == 'offline' || _iotStatus == 'unknown')
                                    ? 'IoT Offline'
                                    : 'START',
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
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
            width: 8,
            height: 8,
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
