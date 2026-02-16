import 'package:json_annotation/json_annotation.dart';

part 'service_schedule_model.g.dart';

@JsonSerializable()
class ServiceScheduleModel {
  final int? id;
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  @JsonKey(name: 'service_type_id')
  final int? serviceTypeId;
  @JsonKey(name: 'service_name')
  final String? serviceName;
  @JsonKey(name: 'interval_type')
  final String intervalType; // 'mileage' or 'time'
  @JsonKey(name: 'interval_value')
  final int intervalValue;
  @JsonKey(name: 'last_service_mileage')
  final int? lastServiceMileage;
  @JsonKey(name: 'last_service_date')
  final DateTime? lastServiceDate;
  @JsonKey(name: 'next_service_mileage')
  final int? nextServiceMileage;
  @JsonKey(name: 'next_service_date')
  final DateTime? nextServiceDate;
  @JsonKey(name: 'reminder_threshold')
  final int? reminderThreshold;
  @JsonKey(name: 'reminder_enabled')
  final bool reminderEnabled;
  final String? notes;
  final String? status; // 'upcoming', 'due', 'overdue'
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ServiceScheduleModel({
    this.id,
    required this.vehicleId,
    this.serviceTypeId,
    this.serviceName,
    required this.intervalType,
    required this.intervalValue,
    this.lastServiceMileage,
    this.lastServiceDate,
    this.nextServiceMileage,
    this.nextServiceDate,
    this.reminderThreshold,
    this.reminderEnabled = true,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceScheduleModelToJson(this);

  ServiceScheduleModel copyWith({
    int? id,
    int? vehicleId,
    int? serviceTypeId,
    String? serviceName,
    String? intervalType,
    int? intervalValue,
    int? lastServiceMileage,
    DateTime? lastServiceDate,
    int? nextServiceMileage,
    DateTime? nextServiceDate,
    int? reminderThreshold,
    bool? reminderEnabled,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceScheduleModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceName: serviceName ?? this.serviceName,
      intervalType: intervalType ?? this.intervalType,
      intervalValue: intervalValue ?? this.intervalValue,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      reminderThreshold: reminderThreshold ?? this.reminderThreshold,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
