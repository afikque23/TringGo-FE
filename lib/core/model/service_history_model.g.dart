// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  'manual_reminder_enabled': instance.manualReminderEnabled,
  'reminder_interval_km': instance.reminderIntervalKm,
};
