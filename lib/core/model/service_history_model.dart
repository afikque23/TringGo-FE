import 'package:json_annotation/json_annotation.dart';

part 'service_history_model.g.dart';

@JsonSerializable(createFactory: false)
class ServiceHistoryModel {
  final int? id;
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  @JsonKey(name: 'service_type_id')
  final int? serviceTypeId;
  @JsonKey(name: 'service_type')
  final String serviceName;
  @JsonKey(name: 'performed_at')
  final DateTime serviceDate;
  final int? odometer;
  final double? cost;
  final String? currency;
  @JsonKey(name: 'service_provider')
  final String? serviceProvider;
  final String? notes;
  @JsonKey(name: 'receipt_url')
  final String? receiptUrl;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // (no computed properties)

  ServiceHistoryModel({
    this.id,
    this.vehicleId,
    required this.serviceName,
    required this.serviceDate,
    this.odometer,
    this.cost,
    this.currency,
    this.serviceProvider,
    this.notes,
    this.receiptUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    // Handle service_type - it's a string in the API response
    String serviceName = 'Unknown Service';
    if (json['service_type'] != null) {
      if (json['service_type'] is String) {
        serviceName = json['service_type'] as String;
      } else if (json['service_type'] is Map) {
        // Backward compatibility: handle nested service_type object
        serviceName = json['service_type']['name'] as String;
      }
    }

    // Parse performed_at date
    DateTime serviceDate;
    try {
      serviceDate = DateTime.parse(json['performed_at'] as String);
    } catch (e) {
      // Fallback to current date if parsing fails
      serviceDate = DateTime.now();
    }

    return ServiceHistoryModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
        vehicleId: json['vehicle_id'] != null
          ? (json['vehicle_id'] as num).toInt()
          : 0,
        serviceTypeId: json['service_type_id'] != null
          ? (json['service_type_id'] as num).toInt()
          : null,
        serviceName: serviceName,
        serviceDate: serviceDate,
        odometer: json['odometer'] != null
          ? (json['odometer'] as num).toInt()
          : null,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? 'IDR',
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
  }

  Map<String, dynamic> toJson() => _$ServiceHistoryModelToJson(this);

  ServiceHistoryModel copyWith({
    int? id,
    int? vehicleId,
    String? serviceName,
    DateTime? serviceDate,
    int? odometer,
    double? cost,
    String? currency,
<<<<<<< HEAD
    String? serviceProvider,
    String? notes,
    String? receiptUrl,
=======
    String? workshopName,
    String? receiptImage,
    String? notes,
>>>>>>> 22e009ef7836e42850c49ce646c3d245a089ae7b
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceName: serviceName ?? this.serviceName,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
<<<<<<< HEAD
      serviceProvider: serviceProvider ?? this.serviceProvider,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
=======
      workshopName: workshopName ?? this.workshopName,
      receiptImage: receiptImage ?? this.receiptImage,
      notes: notes ?? this.notes,
>>>>>>> 22e009ef7836e42850c49ce646c3d245a089ae7b
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
