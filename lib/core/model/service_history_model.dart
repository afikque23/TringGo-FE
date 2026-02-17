import 'package:json_annotation/json_annotation.dart';

part 'service_history_model.g.dart';

@JsonSerializable()
class ServiceHistoryModel {
  final int? id;
  @JsonKey(name: 'vehicle_id')
  final int? vehicleId;
  @JsonKey(name: 'service_type')
  final String serviceName;
  @JsonKey(name: 'performed_at')
  final DateTime serviceDate;
  @JsonKey(name: 'odometer')
  final int mileage;
  final double? cost;
  final String? currency;
  @JsonKey(name: 'service_provider')
  final String? workshopName;
  @JsonKey(name: 'receipt_url')
  final String? receiptImage;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Computed property - not from JSON
  int? get serviceTypeId => null;
  String? get workshopLocation => null;

  ServiceHistoryModel({
    this.id,
    this.vehicleId,
    required this.serviceName,
    required this.serviceDate,
    required this.mileage,
    this.cost,
    this.currency,
    this.workshopName,
    this.receiptImage,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceHistoryModelToJson(this);

  ServiceHistoryModel copyWith({
    int? id,
    int? vehicleId,
    String? serviceName,
    DateTime? serviceDate,
    int? mileage,
    double? cost,
    String? currency,
    String? workshopName,
    String? receiptImage,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceName: serviceName ?? this.serviceName,
      serviceDate: serviceDate ?? this.serviceDate,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      workshopName: workshopName ?? this.workshopName,
      receiptImage: receiptImage ?? this.receiptImage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
