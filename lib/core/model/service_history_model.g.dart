// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHistoryModel _$ServiceHistoryModelFromJson(Map<String, dynamic> json) =>
    ServiceHistoryModel(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? 0,
      serviceTypeId: (json['service_type_id'] as num?)?.toInt(),
      serviceName: json['service_type'] as String,
      serviceDate: DateTime.parse(json['performed_at'] as String),
      odometer: (json['odometer'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      serviceProvider: json['service_provider'] as String?,
      notes: json['notes'] as String?,
      receiptUrl: json['receipt_url'] as String?,
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
      'service_type': instance.serviceName,
      'performed_at': instance.serviceDate.toIso8601String(),
      'odometer': instance.odometer,
      'cost': instance.cost,
      'currency': instance.currency,
      'service_provider': instance.serviceProvider,
      'notes': instance.notes,
      'receipt_url': instance.receiptUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
