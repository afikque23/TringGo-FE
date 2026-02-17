// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHistoryModel _$ServiceHistoryModelFromJson(Map<String, dynamic> json) =>
    ServiceHistoryModel(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      serviceName: json['service_type'] as String,
      serviceDate: DateTime.parse(json['performed_at'] as String),
      mileage: (json['odometer'] as num).toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      workshopName: json['service_provider'] as String?,
      receiptImage: json['receipt_url'] as String?,
      notes: json['notes'] as String?,
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
  'service_type': instance.serviceName,
  'performed_at': instance.serviceDate.toIso8601String(),
  'odometer': instance.mileage,
  'cost': instance.cost,
  'currency': instance.currency,
  'service_provider': instance.workshopName,
  'receipt_url': instance.receiptImage,
  'notes': instance.notes,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
