// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHistoryModel _$ServiceHistoryModelFromJson(Map<String, dynamic> json) =>
    ServiceHistoryModel(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num).toInt(),
      serviceTypeId: (json['service_type_id'] as num?)?.toInt(),
      serviceName: json['service_name'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      mileage: (json['mileage'] as num).toInt(),
      cost: (json['cost'] as num).toDouble(),
      workshopName: json['workshop_name'] as String?,
      workshopLocation: json['workshop_location'] as String?,
      notes: json['notes'] as String?,
      receiptImage: json['receipt_image'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ServiceHistoryModelToJson(
  ServiceHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicle_id': instance.vehicleId,
  'service_type_id': instance.serviceTypeId,
  'service_name': instance.serviceName,
  'service_date': instance.serviceDate.toIso8601String(),
  'mileage': instance.mileage,
  'cost': instance.cost,
  'workshop_name': instance.workshopName,
  'workshop_location': instance.workshopLocation,
  'notes': instance.notes,
  'receipt_image': instance.receiptImage,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
