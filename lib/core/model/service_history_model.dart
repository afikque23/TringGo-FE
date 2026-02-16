import 'package:json_annotation/json_annotation.dart';

part 'service_history_model.g.dart';

@JsonSerializable()
class ServiceHistoryModel {
  final int? id;
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  @JsonKey(name: 'service_type_id')
  final int? serviceTypeId;
  @JsonKey(name: 'service_name')
  final String serviceName;
  @JsonKey(name: 'service_date')
  final DateTime serviceDate;
  final int mileage;
  final double cost;
  @JsonKey(name: 'workshop_name')
  final String? workshopName;
  @JsonKey(name: 'workshop_location')
  final String? workshopLocation;
  final String? notes;
  @JsonKey(name: 'receipt_image')
  final String? receiptImage;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ServiceHistoryModel({
    this.id,
    required this.vehicleId,
    this.serviceTypeId,
    required this.serviceName,
    required this.serviceDate,
    required this.mileage,
    required this.cost,
    this.workshopName,
    this.workshopLocation,
    this.notes,
    this.receiptImage,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceHistoryModelToJson(this);

  ServiceHistoryModel copyWith({
    int? id,
    int? vehicleId,
    int? serviceTypeId,
    String? serviceName,
    DateTime? serviceDate,
    int? mileage,
    double? cost,
    String? workshopName,
    String? workshopLocation,
    String? notes,
    String? receiptImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceName: serviceName ?? this.serviceName,
      serviceDate: serviceDate ?? this.serviceDate,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      workshopName: workshopName ?? this.workshopName,
      workshopLocation: workshopLocation ?? this.workshopLocation,
      notes: notes ?? this.notes,
      receiptImage: receiptImage ?? this.receiptImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
