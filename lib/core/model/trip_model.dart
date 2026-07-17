import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';
import 'location_point.dart';

part 'trip_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TripModel {
  final String id;
  final String motorcycleName;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance; // in kilometers
  final int duration; // in seconds
  final double averageSpeed; // in km/h
  final double maxSpeed; // in km/h
  final List<LocationPoint> points;
  final String status; // 'active', 'completed', 'paused'

  // Sumber data
  final String source; // 'gps' atau 'manual'

  // Parameter konteks (auto-detect GPS / kalibrasi manual)
  @JsonKey(name: 'kondisi_lalu_lintas')
  final String? kondisiLaluLintas; // 'macet', 'sedang', 'lancar'
  final String? medan; // 'datar', 'berbukit', 'campuran'
  @JsonKey(name: 'gaya_berkendara')
  final String? gayaBerkendara; // 'pelan', 'normal', 'agresif'

  // Parameter manual
  final String? beban; // 'ringan', 'sedang', 'berat'
  @JsonKey(name: 'ada_penumpang')
  final bool? adaPenumpang;

  // Data sensor GPS tambahan
  @JsonKey(name: 'elevation_gain')
  final int? elevationGain; // meters
  @JsonKey(name: 'idle_time_minutes')
  final int? idleTimeMinutes;
  @JsonKey(name: 'rough_road_count')
  final int roughRoadCount;
  @JsonKey(name: 'hard_acceleration_count')
  final int hardAccelerationCount;
  @JsonKey(name: 'hard_braking_count')
  final int hardBrakingCount;

  // Kalibrasi & scoring
  @JsonKey(name: 'is_calibrated')
  final bool isCalibrated;
  @JsonKey(name: 'service_score_factor')
  final double serviceScoreFactor;

  final String? notes;

  TripModel({
    required this.id,
    required this.motorcycleName,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.duration,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.points,
    required this.status,
    this.source = 'gps',
    this.kondisiLaluLintas,
    this.medan,
    this.gayaBerkendara,
    this.beban,
    this.adaPenumpang,
    this.elevationGain,
    this.idleTimeMinutes,
    this.roughRoadCount = 0,
    this.hardAccelerationCount = 0,
    this.hardBrakingCount = 0,
    this.isCalibrated = false,
    this.serviceScoreFactor = 1.0,
    this.notes,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  /// Parse Trip dari backend `/trips` (Trip History) response.
  ///
  /// Backend shape (per docs):
  /// - `id` (int)
  /// - `vehicle` (object) and/or `vehicle_id`
  /// - `start_at`, `end_at`
  /// - `distance_km` (nullable) or `distance_meters`
  /// - `duration_minutes` (nullable)
  /// - `points` array with `latitude`,`longitude`,`speed_kph`,`recorded_at`
  factory TripModel.fromBackendJson(Map<String, dynamic> json) {
    final vehicle = (json['vehicle'] is Map)
        ? Map<String, dynamic>.from(json['vehicle'] as Map)
        : const <String, dynamic>{};

    final startAt = _parseDateTimeOrNull(json['start_at']) ?? DateTime.now();
    final endAt = _parseDateTimeOrNull(json['end_at']);

    final pointsJson = (json['points'] is List)
        ? (json['points'] as List)
        : const <dynamic>[];

    final parsedPoints =
        <
          ({
            int? sequence,
            DateTime recordedAt,
            int sourceIndex,
            double speedKph,
            LocationPoint point,
          })
        >[];

    for (var i = 0; i < pointsJson.length; i++) {
      final raw = pointsJson[i];
      if (raw is! Map) continue;
      final pointJson = Map<String, dynamic>.from(raw);

      final lat = _toDouble(pointJson['latitude']);
      final lng = _toDouble(pointJson['longitude']);
      if (lat == null || lng == null) continue;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
      if (lat == 0.0 && lng == 0.0) continue;

      final speedKph = _toDouble(pointJson['speed_kph']) ?? 0.0;
      final recordedAt =
          _parseDateTimeOrNull(pointJson['recorded_at']) ?? startAt;
      final sequence = _toInt(pointJson['sequence']);

      parsedPoints.add((
        sequence: sequence,
        recordedAt: recordedAt,
        sourceIndex: i,
        speedKph: speedKph,
        point: LocationPoint(
          latitude: lat,
          longitude: lng,
          altitude: 0.0,
          speed: speedKph / 3.6, // m/s
          accuracy: 0.0,
          timestamp: recordedAt,
        ),
      ));
    }

    // Ensure route order is deterministic: prefer `sequence`, then `recorded_at`.
    parsedPoints.sort((a, b) {
      final aSeq = a.sequence;
      final bSeq = b.sequence;
      if (aSeq != null && bSeq != null && aSeq != bSeq) {
        return aSeq.compareTo(bSeq);
      }
      final byTime = a.recordedAt.compareTo(b.recordedAt);
      if (byTime != 0) return byTime;
      return a.sourceIndex.compareTo(b.sourceIndex);
    });

    final speedsKph = parsedPoints
        .map((e) => e.speedKph)
        .where((v) => v > 0)
        .toList();
    final points = _sanitizeRoutePoints(
      parsedPoints.map((e) => e.point).toList(),
    );

    final avgSpeedFromPoints = speedsKph.isEmpty
        ? 0.0
        : speedsKph.reduce((a, b) => a + b) / speedsKph.length;
    final maxSpeedFromPoints = speedsKph.isEmpty
        ? 0.0
        : speedsKph.reduce((a, b) => a > b ? a : b);

    final backendAvgSpeed = _toDouble(json['avg_speed_kph']);
    final backendMaxSpeed = _toDouble(json['max_speed_kph']);

    final avgSpeed = (backendAvgSpeed != null && backendAvgSpeed > 0)
        ? backendAvgSpeed
        : avgSpeedFromPoints;
    final maxSpeed = (backendMaxSpeed != null && backendMaxSpeed > 0)
        ? backendMaxSpeed
        : maxSpeedFromPoints;

    final backendDistanceKm =
        _toDouble(json['distance_km']) ??
        ((_toDouble(json['distance_meters']) ?? 0.0) / 1000.0);
    final pointsDistanceKm = _calculateDistanceKmFromPoints(points);
    final distanceKm = backendDistanceKm > 0
        ? backendDistanceKm
        : pointsDistanceKm;

    final durationMinutes = _toInt(json['duration_minutes']);
    final durationSeconds = (durationMinutes != null && durationMinutes > 0)
        ? durationMinutes * 60
        : (endAt != null
              ? math.max(endAt.difference(startAt).inSeconds, 0)
              : 0);

    final vehicleTitle = vehicle['title']?.toString();
    final vehicleModel = vehicle['model']?.toString();
    final motorcycleName = (vehicleTitle != null && vehicleTitle.isNotEmpty)
        ? vehicleTitle
        : (vehicleModel != null && vehicleModel.isNotEmpty)
        ? vehicleModel
        : 'Motor';

    return TripModel(
      id: json['id']?.toString() ?? '',
      motorcycleName: motorcycleName,
      startTime: startAt,
      endTime: endAt,
      totalDistance: distanceKm,
      duration: durationSeconds,
      averageSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      points: points,
      status: endAt == null ? 'active' : 'completed',
    );
  }

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  static DateTime? _parseDateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) {
      return value.toLocal();
    }
    final text = value.toString();
    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {
      return null;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _calculateDistanceKmFromPoints(List<LocationPoint> points) {
    if (points.length < 2) return 0.0;

    var totalMeters = 0.0;
    for (var i = 1; i < points.length; i++) {
      totalMeters += _haversineMeters(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }

    return totalMeters / 1000.0;
  }

  static double _haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degToRad(double degree) => degree * (math.pi / 180.0);

  // Hapus titik duplikat/noise agar polyline riwayat lebih stabil.
  static List<LocationPoint> _sanitizeRoutePoints(List<LocationPoint> points) {
    if (points.length <= 2) return points;

    const minUsefulStepMeters = 2.0;
    const maxReasonableSpeedKph = 180.0;
    const maxJumpNoTimeMeters = 800.0;

    final cleaned = <LocationPoint>[points.first];

    for (var i = 1; i < points.length; i++) {
      final candidate = points[i];
      final prev = cleaned.last;

      final meters = _haversineMeters(
        prev.latitude,
        prev.longitude,
        candidate.latitude,
        candidate.longitude,
      );

      if (meters < minUsefulStepMeters) {
        continue;
      }

      final dtSeconds = candidate.timestamp
          .difference(prev.timestamp)
          .inSeconds;

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

  // Create a new trip
  factory TripModel.createNew({
    required String motorcycleName,
    required LocationPoint startPoint,
    String? beban,
    bool? adaPenumpang,
  }) {
    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      motorcycleName: motorcycleName,
      startTime: DateTime.now(),
      endTime: null,
      totalDistance: 0.0,
      duration: 0,
      averageSpeed: 0.0,
      maxSpeed: 0.0,
      points: [startPoint],
      status: 'active',
      source: 'gps',
      beban: beban,
      adaPenumpang: adaPenumpang,
    );
  }

  // Create a manual trip entry
  factory TripModel.createManual({
    required String motorcycleName,
    required DateTime startTime,
    required DateTime endTime,
    required double totalDistance,
    String? kondisiLaluLintas,
    String? medan,
    String? gayaBerkendara,
    String? beban,
    bool? adaPenumpang,
    String? notes,
  }) {
    final durationSec = endTime.difference(startTime).inSeconds;
    final avgSpeed = durationSec > 0
        ? (totalDistance / (durationSec / 3600))
        : 0.0;

    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      motorcycleName: motorcycleName,
      startTime: startTime,
      endTime: endTime,
      totalDistance: totalDistance,
      duration: durationSec,
      averageSpeed: avgSpeed,
      maxSpeed: 0.0,
      points: [],
      status: 'completed',
      source: 'manual',
      kondisiLaluLintas: kondisiLaluLintas,
      medan: medan,
      gayaBerkendara: gayaBerkendara,
      beban: beban,
      adaPenumpang: adaPenumpang,
      notes: notes,
    );
  }

  // Copy with method for updates & kalibrasi
  TripModel copyWith({
    String? id,
    String? motorcycleName,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    int? duration,
    double? averageSpeed,
    double? maxSpeed,
    List<LocationPoint>? points,
    String? status,
    String? source,
    String? kondisiLaluLintas,
    String? medan,
    String? gayaBerkendara,
    String? beban,
    bool? adaPenumpang,
    int? elevationGain,
    int? idleTimeMinutes,
    int? roughRoadCount,
    int? hardAccelerationCount,
    int? hardBrakingCount,
    bool? isCalibrated,
    double? serviceScoreFactor,
    String? notes,
  }) {
    return TripModel(
      id: id ?? this.id,
      motorcycleName: motorcycleName ?? this.motorcycleName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      duration: duration ?? this.duration,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      points: points ?? this.points,
      status: status ?? this.status,
      source: source ?? this.source,
      kondisiLaluLintas: kondisiLaluLintas ?? this.kondisiLaluLintas,
      medan: medan ?? this.medan,
      gayaBerkendara: gayaBerkendara ?? this.gayaBerkendara,
      beban: beban ?? this.beban,
      adaPenumpang: adaPenumpang ?? this.adaPenumpang,
      elevationGain: elevationGain ?? this.elevationGain,
      idleTimeMinutes: idleTimeMinutes ?? this.idleTimeMinutes,
      roughRoadCount: roughRoadCount ?? this.roughRoadCount,
      hardAccelerationCount:
          hardAccelerationCount ?? this.hardAccelerationCount,
      hardBrakingCount: hardBrakingCount ?? this.hardBrakingCount,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      serviceScoreFactor: serviceScoreFactor ?? this.serviceScoreFactor,
      notes: notes ?? this.notes,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// End time for UI purposes.
  /// If backend sends `end_at=null` (ongoing trip), we still want a sensible
  /// end time based on the last point.
  DateTime get endTimeForDisplay {
    if (endTime != null) return endTime!;
    if (points.isNotEmpty) return points.last.timestamp;
    return startTime;
  }

  @override
  String toString() {
    return 'TripModel(id: $id, distance: ${totalDistance.toStringAsFixed(2)} km, '
        'duration: $formattedDuration, status: $status, source: $source)';
  }
}
