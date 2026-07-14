// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  tipeMotor: json['tipe_motor'] as String?,
  kapasitasCc: json['kapasitas_cc'] as String?,
  transmisi: json['transmisi'] as String?,
  odometer: (json['odometer'] as num).toInt(),
  isPrimary: json['is_primary'] as bool? ?? false,
  deviceId: json['device_id'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'tipe_motor': instance.tipeMotor,
      'kapasitas_cc': instance.kapasitasCc,
      'transmisi': instance.transmisi,
      'odometer': instance.odometer,
      'is_primary': instance.isPrimary,
      'device_id': instance.deviceId,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
