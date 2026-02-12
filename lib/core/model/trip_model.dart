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

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

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

  @override
  String toString() {
    return 'TripModel(id: $id, distance: ${totalDistance.toStringAsFixed(2)} km, duration: $formattedDuration, status: $status)';
  }
}
