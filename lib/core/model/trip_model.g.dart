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
  source: json['source'] as String? ?? 'gps',
  kondisiLaluLintas: json['kondisi_lalu_lintas'] as String?,
  medan: json['medan'] as String?,
  gayaBerkendara: json['gaya_berkendara'] as String?,
  beban: json['beban'] as String?,
  adaPenumpang: json['ada_penumpang'] as bool?,
  elevationGain: (json['elevation_gain'] as num?)?.toInt(),
  idleTimeMinutes: (json['idle_time_minutes'] as num?)?.toInt(),
  roughRoadCount: (json['rough_road_count'] as num?)?.toInt() ?? 0,
  hardAccelerationCount:
      (json['hard_acceleration_count'] as num?)?.toInt() ?? 0,
  hardBrakingCount: (json['hard_braking_count'] as num?)?.toInt() ?? 0,
  isCalibrated: json['is_calibrated'] as bool? ?? false,
  serviceScoreFactor: (json['service_score_factor'] as num?)?.toDouble() ?? 1.0,
  notes: json['notes'] as String?,
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
  'source': instance.source,
  'kondisi_lalu_lintas': instance.kondisiLaluLintas,
  'medan': instance.medan,
  'gaya_berkendara': instance.gayaBerkendara,
  'beban': instance.beban,
  'ada_penumpang': instance.adaPenumpang,
  'elevation_gain': instance.elevationGain,
  'idle_time_minutes': instance.idleTimeMinutes,
  'rough_road_count': instance.roughRoadCount,
  'hard_acceleration_count': instance.hardAccelerationCount,
  'hard_braking_count': instance.hardBrakingCount,
  'is_calibrated': instance.isCalibrated,
  'service_score_factor': instance.serviceScoreFactor,
  'notes': instance.notes,
};
