import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/model/vehicle_model.dart';
import '../../../../core/services/tracking_api_service.dart';
import '../../../../core/services/vehicle_service.dart';
import 'trip_summary_page.dart';

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
    this.currentVehicle,
  });

  final int vehicleId;
  final String vehicleName;

  /// Kendaraan aktif — diteruskan ke TripSummaryPage untuk pre-fill parameter default
  final VehicleModel? currentVehicle;

  @override
  State<GpsTrackingActivePage> createState() => _GpsTrackingActivePageState();
}

class _GpsTrackingActivePageState extends State<GpsTrackingActivePage> {
  static const _bg = Color(0xFF0A0A0A);
  static const _card = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);

  final MapController _mapController = MapController();
  Timer? _timer;

  bool _isTracking = false;
  double _distanceKm = 0;
  int _durationSec = 0;
  int _speedKph = 0;
  double _avgSpeedKph = 0;
  int _maxSpeedKph = 0;
  DateTime? _startTime;

  // IoT Status
  String _iotStatus =
      'unknown'; // 'online' | 'unstable' | 'offline' | 'unknown'
  int? _iotSecondsAgo;
  bool _gpsReady = false;

  bool get _isIotOnline {
    if (_iotStatus != 'online') return false;
    if (_iotSecondsAgo == null) return false;
    return _iotSecondsAgo! <= 15;
  }

  bool get _canStartTracking => _isIotOnline && _gpsReady;

  String get _iotStatusLabel {
    if (_iotStatus == 'online' && !_gpsReady)
      return 'IoT Online • Mencari GPS Fix';
    if (_iotStatus == 'online') return 'IoT Online';
    if (_iotStatus == 'unstable') return 'Tidak Stabil';
    if (_iotStatus == 'offline') return 'IoT Offline';
    return 'Mendeteksi...';
  }

  String _deriveIotStatus(int? secondsAgo) {
    if (secondsAgo == null) return 'unknown';
    if (secondsAgo <= 15) return 'online';
    if (secondsAgo <= 60) return 'unstable';
    return 'offline';
  }

  int? _normalizeSecondsAgo(int? secondsAgo) {
    if (secondsAgo == null) return null;
    // Nilai negatif menandakan clock skew/server time mismatch, jangan dianggap online.
    if (secondsAgo < 0) return null;
    return secondsAgo;
  }

  int? _extractSecondsAgo(Map<String, dynamic> latestData) {
    final rawSecondsAgo = (latestData['seconds_ago'] as num?)?.toInt();
    final normalized = _normalizeSecondsAgo(rawSecondsAgo);
    if (normalized != null) return normalized;

    // Fallback: hitung dari `received_at` agar tahan terhadap bug diff waktu backend.
    final receivedAtRaw = latestData['received_at']?.toString();
    if (receivedAtRaw == null || receivedAtRaw.isEmpty) {
      return null;
    }

    try {
      final receivedAt = DateTime.parse(receivedAtRaw).toUtc();
      final nowUtc = DateTime.now().toUtc();
      final diff = nowUtc.difference(receivedAt).inSeconds;

      // Jika masih negatif kecil karena jitter clock, clamp ke 0.
      if (diff < 0 && diff.abs() <= 10) return 0;
      if (diff < 0) return null;
      return diff;
    } catch (_) {
      return null;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  List<RoutePoint> _sanitizeRestoredRoute(List<RoutePoint> points) {
    if (points.length <= 2) return points;

    const minUsefulStepMeters = 2.0;
    const maxReasonableSpeedKph = 180.0;
    const maxJumpNoTimeMeters = 800.0;

    final cleaned = <RoutePoint>[points.first];

    for (var i = 1; i < points.length; i++) {
      final candidate = points[i];
      final prev = cleaned.last;

      final meters = _haversineMeters(
        prev.lat,
        prev.lng,
        candidate.lat,
        candidate.lng,
      );

      if (meters < minUsefulStepMeters) {
        continue;
      }

      final dtSeconds = (candidate.timestampMs - prev.timestampMs) ~/ 1000;

      if (dtSeconds <= 0) {
        if (meters > maxJumpNoTimeMeters) {
          continue;
        }
        cleaned.add(candidate);
        continue;
      }

      final speedKph = (meters / dtSeconds) * 3.6;
      if (speedKph > maxReasonableSpeedKph && meters > 120) {
        continue;
      }

      cleaned.add(candidate);
    }

    return cleaned;
  }

  // Koordinat awal (Semarang)
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

        if (status.isTracking && status.activeTripId != null) {
          await _restoreActiveTripState(status.activeTripId!);
        }

        // Fetch lokasi terakhir dari IoT segera setelah halaman dibuka (walau belum tracking/Start)
        await _fetchLatestLocationData();

        // Tetap polling status IoT meski belum tracking agar indikator tidak stale.
        _startPolling();
      }
    } catch (e) {
      debugPrint('Error check tracking status: $e');
    }
  }

  Future<void> _restoreActiveTripState(int tripId) async {
    try {
      final trip = await TrackingApiService.getTripById(tripId);
      if (!mounted) return;

      final startAtRaw = trip['start_at']?.toString();
      final startAt = startAtRaw != null && startAtRaw.isNotEmpty
          ? DateTime.tryParse(startAtRaw)?.toLocal()
          : null;

      final distanceMetersRaw = trip['distance_meters'];
      final distanceKm = distanceMetersRaw is num
          ? distanceMetersRaw.toDouble() / 1000.0
          : (trip['distance_km'] is num
                ? (trip['distance_km'] as num).toDouble()
                : 0.0);

      final avgSpeedRaw = trip['avg_speed_kph'];
      final maxSpeedRaw = trip['max_speed_kph'];

      final pointsRaw = trip['points'];
      final restoredPoints = <RoutePoint>[];
      if (pointsRaw is List) {
        final parsedRows =
            <({int index, int? sequence, DateTime recordedAt, RoutePoint point})>[];

        for (var i = 0; i < pointsRaw.length; i++) {
          final item = pointsRaw[i];
          if (item is! Map) continue;
          final point = Map<String, dynamic>.from(item);
          final lat = _toDouble(point['latitude']);
          final lng = _toDouble(point['longitude']);
          if (lat == null || lng == null) continue;
          if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
          if (lat == 0.0 && lng == 0.0) continue;

          final recordedAt =
              _toDateTime(point['recorded_at']) ?? startAt ?? DateTime.now();

          parsedRows.add((
            index: i,
            sequence: _toInt(point['sequence']),
            recordedAt: recordedAt,
            point: RoutePoint(
              lat: lat,
              lng: lng,
              speedKph: _toInt(point['speed_kph']) ?? 0,
              timestampMs: recordedAt.millisecondsSinceEpoch,
            ),
          ));
        }

        parsedRows.sort((a, b) {
          final aSeq = a.sequence;
          final bSeq = b.sequence;
          if (aSeq != null && bSeq != null && aSeq != bSeq) {
            return aSeq.compareTo(bSeq);
          }
          final byTime = a.recordedAt.compareTo(b.recordedAt);
          if (byTime != 0) return byTime;
          return a.index.compareTo(b.index);
        });

        restoredPoints.addAll(
          _sanitizeRestoredRoute(parsedRows.map((e) => e.point).toList()),
        );
        }
      }

      setState(() {
        _startTime = startAt;
        if (_startTime != null) {
          _durationSec = DateTime.now().difference(_startTime!).inSeconds;
        }
        _distanceKm = distanceKm;
        _avgSpeedKph = avgSpeedRaw is num
            ? avgSpeedRaw.toDouble()
            : _avgSpeedKph;
        _maxSpeedKph = maxSpeedRaw is num ? maxSpeedRaw.toInt() : _maxSpeedKph;
        if (restoredPoints.isNotEmpty) {
          _routePoints
            ..clear()
            ..addAll(restoredPoints);
          final lastPoint = restoredPoints.last;
          _currentLocation = LatLng(lastPoint.lat, lastPoint.lng);
        }
      });
    } catch (e) {
      debugPrint('Error restore active trip state: $e');
    }
  }

  Future<void> _fetchLatestLocationData() async {
    try {
      final latestData = await TrackingApiService.getLatestLocation(
        widget.vehicleId,
      );

      if (!mounted) return;

      // Jika payload kosong/gagal, turunkan status agar tidak "stuck online".
      if (latestData == null) {
        setState(() {
          _iotStatus = 'unknown';
          _iotSecondsAgo = null;
          _gpsReady = false;
        });
        return;
      }

      // Derive status murni dari heartbeat recency agar tidak false online.
      final secondsAgo = _extractSecondsAgo(latestData);
      final normalizedStatus = _deriveIotStatus(secondsAgo);
      final gpsReady = latestData['gps_ready'] == true;

      setState(() {
        _iotStatus = normalizedStatus;
        _iotSecondsAgo = secondsAgo;
        _gpsReady = gpsReady;
      });

      final latRaw = latestData['latitude'];
      final lngRaw = latestData['longitude'];
      final newLat = latRaw is num ? latRaw.toDouble() : null;
      final newLng = lngRaw is num ? lngRaw.toDouble() : null;

      // Tidak ada koordinat: cukup update status saja.
      if (newLat == null || newLng == null) {
        return;
      }

      final currentSpeed = (latestData['speed_kph'] as num?)?.toInt() ?? 0;

      setState(() {
        _speedKph = currentSpeed;
        _maxSpeedKph = max(_maxSpeedKph, currentSpeed);
        _currentLocation = LatLng(newLat, newLng);

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
    } catch (e) {
      debugPrint('Error get latest location: $e');
      if (mounted) {
        setState(() {
          _iotStatus = 'unknown';
          _iotSecondsAgo = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi timer 1 detik untuk UI dan polling 5 detik ke backend
  void _startPolling() {
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

      // Saat tracking: polling 5 detik. Saat idle: polling 10 detik.
      final shouldPoll = _isTracking
          ? (timer.tick % 5 == 0)
          : (timer.tick % 10 == 0);
      if (shouldPoll) {
        await _fetchLatestLocationData();
      }
    });
  }

  Future<bool> _refreshAndValidateIotBeforeStart() async {
    try {
      final latestData = await TrackingApiService.getLatestLocation(
        widget.vehicleId,
      );
      if (latestData == null) {
        if (mounted) {
          setState(() {
            _iotStatus = 'unknown';
            _iotSecondsAgo = null;
            _gpsReady = false;
          });
        }
        return false;
      }

      final secondsAgo = _extractSecondsAgo(latestData);
      final normalizedStatus = _deriveIotStatus(secondsAgo);
      final gpsReady = latestData['gps_ready'] == true;
      if (mounted) {
        setState(() {
          _iotStatus = normalizedStatus;
          _iotSecondsAgo = secondsAgo;
          _gpsReady = gpsReady;
        });
      }

      return normalizedStatus == 'online' && gpsReady;
    } catch (_) {
      if (mounted) {
        setState(() {
          _iotStatus = 'unknown';
          _iotSecondsAgo = null;
          _gpsReady = false;
        });
      }
      return false;
    }
  }

  Future<void> _startTracking() async {
    try {
      final iotReady = await _refreshAndValidateIotBeforeStart();
      if (!iotReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'IoT belum online. Nyalakan perangkat lalu coba lagi.',
              ),
            ),
          );
        }
        return;
      }

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
          // Jangan seed titik awal dari _currentLocation, agar tidak menyimpan
          // koordinat stale ketika GPS belum benar-benar fix sebelumnya.
          _routePoints.clear();
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
                'Hentikan',
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
        clientDistanceKm: _distanceKm,
        clientAvgSpeedKph: _avgSpeedKph,
        clientMaxSpeedKph: _maxSpeedKph,
        clientDurationSec: _durationSec,
        clientRoutePoints: _routePoints
            .map(
              (p) => {
                'lat': p.lat,
                'lng': p.lng,
                'speed_kph': p.speedKph,
                'timestamp': p.timestampMs,
              },
            )
            .toList(),
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

    // Gunakan summary dari backend jika tersedia, fallback ke kalkulasi lokal.
    // Jika backend mengembalikan distance = 0 (TripPoints tidak tersimpan),
    // gunakan kalkulasi lokal dari polling kecepatan sebagai fallback.
    final summary = tripSummary?['summary'] as Map<String, dynamic>?;

    final summaryDistance = summary != null ? summary['distance_km'] : null;
    final tripDistanceMeters = tripSummary?['distance_meters'];
    final backendDistKm = summaryDistance is num
        ? summaryDistance.toDouble()
        : (tripDistanceMeters is num
              ? tripDistanceMeters.toDouble() / 1000
              : null);

    // Pakai backend jika nilainya > 0, fallback ke lokal jika 0 atau null
    final bool useBackend = backendDistKm != null && backendDistKm > 0;

    final distKm = (useBackend ? backendDistKm : _distanceKm).toStringAsFixed(
      2,
    );

    final summaryDuration = summary != null
        ? summary['duration_minutes']
        : null;
    final summaryAvgSpeed = summary != null ? summary['avg_speed_kph'] : null;
    final summaryMaxSpeed = summary != null ? summary['max_speed_kph'] : null;

    final durMin = useBackend && summaryDuration != null
        ? (summaryDuration is num
              ? summaryDuration.round().toString()
              : int.tryParse(summaryDuration.toString())?.toString() ??
                    summaryDuration.toString())
        : (_durationSec ~/ 60).toString();

    final avgKph = useBackend && summaryAvgSpeed is num
        ? summaryAvgSpeed.toStringAsFixed(1)
        : _avgSpeedKph.toStringAsFixed(1);

    final maxKph = useBackend && summaryMaxSpeed != null
        ? summaryMaxSpeed.toString()
        : _maxSpeedKph.toString();

    // elevation & odometer hanya dari backend
    final elevationGainRaw = summary != null
        ? summary['elevation_gain_m']
        : null;
    final elevationGainM = elevationGainRaw is num
        ? elevationGainRaw.toInt()
        : null;
    final newOdometer = useBackend && summary != null
        ? summary['new_odometer']
        : null;
    final tripPointsCountRaw = summary != null
        ? summary['trip_points_count']
        : null;
    final tripPointsCount = tripPointsCountRaw is num
        ? tripPointsCountRaw.toInt()
        : int.tryParse(tripPointsCountRaw?.toString() ?? '');
    final usedClientDistance =
        summary != null && summary['used_client_distance'] == true;

    final tripData = {
      'vehicle': widget.vehicleName,
      'distanceValue': distKm,
      'durationMinutes': durMin,
      'averageSpeedKph': avgKph,
      'maxSpeedKph': maxKph,
      'elevationGainM': elevationGainM,
      'newOdometer': newOdometer,
      'tripPointsCount': tripPointsCount,
      'usedClientDistance': usedClientDistance,
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

    // Ambil vehicle terkini dari service untuk pre-fill parameter default
    _navigateToSummary(tripData);
  }

  Future<void> _navigateToSummary(Map<String, dynamic> tripData) async {
    VehicleModel? currentVehicle;
    try {
      currentVehicle = await VehicleService().getVehicleById(widget.vehicleId);
    } catch (_) {
      // Jika gagal fetch, pakai currentVehicle dari widget (bisa null)
      currentVehicle = widget.currentVehicle;
    }

    if (!mounted) return;

    // Push ke TripSummaryPage, lalu pop hasil ke dashboard
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TripSummaryPage(
          tripData: tripData,
          vehicleId: widget.vehicleId,
          vehicleName: widget.vehicleName,
          currentVehicle: currentVehicle,
        ),
      ),
    );

    if (mounted) {
      // Pop tracking page juga, bawa result ke dashboard
      Navigator.of(context).pop(result ?? tripData);
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

  @override
  Widget build(BuildContext context) {
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                              Text(
                                'AKTIF',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: Color(0xFF8FA06A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isTracking) const SizedBox(height: 8),
                      // Indikator IoT Online/Offline
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                              _iotSecondsAgo == null
                                  ? _iotStatusLabel
                                  : '$_iotStatusLabel (${_iotSecondsAgo}s)',
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
                          // Disable START jika IoT belum online atau GPS belum fix.
                          onPressed: _isTracking
                              ? _confirmStopTracking
                              : !_canStartTracking
                              ? null
                              : _startTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking
                                ? Colors.redAccent
                                : !_canStartTracking
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
                                : !_isIotOnline
                                ? 'IoT Offline'
                                : !_gpsReady
                                ? 'Menunggu GPS Fix'
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
