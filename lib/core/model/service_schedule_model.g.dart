// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceScheduleModel _$ServiceScheduleModelFromJson(
  Map<String, dynamic> json,
) => ServiceScheduleModel(
  id: (json['id'] as num?)?.toInt(),
  vehicleId: (json['vehicle_id'] as num).toInt(),
  serviceTypeId: (json['service_type_id'] as num?)?.toInt(),
  serviceName: json['service_name'] as String?,
  intervalType: json['interval_type'] as String,
  intervalValue: (json['interval_value'] as num).toInt(),
  lastServiceMileage: (json['last_service_mileage'] as num?)?.toInt(),
  lastServiceDate: json['last_service_date'] == null
      ? null
      : DateTime.parse(json['last_service_date'] as String),
  nextServiceMileage: (json['next_service_mileage'] as num?)?.toInt(),
  nextServiceDate: json['next_service_date'] == null
      ? null
      : DateTime.parse(json['next_service_date'] as String),
  reminderThreshold: (json['reminder_threshold'] as num?)?.toInt(),
  reminderEnabled: json['reminder_enabled'] as bool? ?? true,
  notes: json['notes'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ServiceScheduleModelToJson(
  ServiceScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicle_id': instance.vehicleId,
  'service_type_id': instance.serviceTypeId,
  'service_name': instance.serviceName,
  'interval_type': instance.intervalType,
  'interval_value': instance.intervalValue,
  'last_service_mileage': instance.lastServiceMileage,
  'last_service_date': instance.lastServiceDate?.toIso8601String(),
  'next_service_mileage': instance.nextServiceMileage,
  'next_service_date': instance.nextServiceDate?.toIso8601String(),
  'reminder_threshold': instance.reminderThreshold,
  'reminder_enabled': instance.reminderEnabled,
  'notes': instance.notes,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
