import 'package:json_annotation/json_annotation.dart';

part 'location_point.g.dart';

@JsonSerializable()
class LocationPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed; // in m/s
  final double accuracy;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPointToJson(this);

  @override
  String toString() {
    return 'LocationPoint(lat: $latitude, lng: $longitude, speed: ${speed.toStringAsFixed(2)} m/s)';
  }
}
