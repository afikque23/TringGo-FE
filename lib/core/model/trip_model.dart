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
  final String status; // 'active', 'completed'

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
            double speedKph,
            LocationPoint point,
          })
        >[];

    for (final raw in pointsJson) {
      if (raw is! Map) continue;
      final pointJson = Map<String, dynamic>.from(raw);

      final lat = _toDouble(pointJson['latitude']) ?? 0.0;
      final lng = _toDouble(pointJson['longitude']) ?? 0.0;
      final speedKph = _toDouble(pointJson['speed_kph']) ?? 0.0;
      final recordedAt =
          _parseDateTimeOrNull(pointJson['recorded_at']) ?? startAt;
      final sequence = _toInt(pointJson['sequence']);

      parsedPoints.add((
        sequence: sequence,
        recordedAt: recordedAt,
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
      return a.recordedAt.compareTo(b.recordedAt);
    });

    final speedsKph = parsedPoints.map((e) => e.speedKph).toList();
    final points = parsedPoints.map((e) => e.point).toList();

    final avgSpeed = speedsKph.isEmpty
        ? 0.0
        : speedsKph.reduce((a, b) => a + b) / speedsKph.length;
    final maxSpeed = speedsKph.isEmpty
        ? 0.0
        : speedsKph.reduce((a, b) => a > b ? a : b);

    final distanceKm =
        _toDouble(json['distance_km']) ??
        ((_toDouble(json['distance_meters']) ?? 0.0) / 1000.0);

    final durationMinutes = _toInt(json['duration_minutes']);
    final durationSeconds = durationMinutes != null ? durationMinutes * 60 : 0;

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

  // Create a new trip
  factory TripModel.createNew({
    required String motorcycleName,
    required LocationPoint startPoint,
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
    );
  }

  // Copy with method for updates
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
    return 'TripModel(id: $id, distance: ${totalDistance.toStringAsFixed(2)} km, duration: $formattedDuration, status: $status)';
  }
}
