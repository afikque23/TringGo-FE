// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
  id: json['id'] as String,
  motorcycleName: json['motorcycleName'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  totalDistance: (json['totalDistance'] as num).toDouble(),
  duration: (json['duration'] as num).toInt(),
  averageSpeed: (json['averageSpeed'] as num).toDouble(),
  maxSpeed: (json['maxSpeed'] as num).toDouble(),
  points: (json['points'] as List<dynamic>)
      .map((e) => LocationPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
);

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
  'id': instance.id,
  'motorcycleName': instance.motorcycleName,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'totalDistance': instance.totalDistance,
  'duration': instance.duration,
  'averageSpeed': instance.averageSpeed,
  'maxSpeed': instance.maxSpeed,
  'points': instance.points.map((e) => e.toJson()).toList(),
  'status': instance.status,
};
