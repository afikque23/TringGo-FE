import 'package:json_annotation/json_annotation.dart';
import '../network/api_config.dart';

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

  // Manual reminder fields
  @JsonKey(name: 'manual_reminder_enabled')
  final bool? manualReminderEnabled;
  @JsonKey(name: 'reminder_interval_km')
  final int? reminderIntervalKm;

  // (no computed properties)

  ServiceHistoryModel({
    this.id,
    required this.vehicleId,
    this.serviceTypeId,
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
    this.manualReminderEnabled,
    this.reminderIntervalKm,
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

    // Convert relative receipt URL to full URL
    String? receiptUrl;
    if (json['receipt_url'] != null) {
      final rawUrl = json['receipt_url'] as String;
      if (rawUrl.isNotEmpty) {
        // If URL starts with '/', it's a relative path - add base URL
        if (rawUrl.startsWith('/')) {
          // Remove '/api/v1/motorcycle' from baseUrl to get the domain
          final baseUrlWithoutApi = ApiConfig.baseUrl.replaceAll(
            '/api/v1/motorcycle',
            '',
          );
          receiptUrl = '$baseUrlWithoutApi$rawUrl';
        } else if (!rawUrl.startsWith('http')) {
          // If no protocol, assume relative and add base
          final baseUrlWithoutApi = ApiConfig.baseUrl.replaceAll(
            '/api/v1/motorcycle',
            '',
          );
          receiptUrl = '$baseUrlWithoutApi/$rawUrl';
        } else {
          // Already a full URL
          receiptUrl = rawUrl;
        }
      }
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
      receiptUrl: receiptUrl,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      manualReminderEnabled: json['manual_reminder_enabled'] as bool?,
      reminderIntervalKm: json['reminder_interval_km'] != null
          ? (json['reminder_interval_km'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$ServiceHistoryModelToJson(this);

  ServiceHistoryModel copyWith({
    int? id,
    int? vehicleId,
    int? serviceTypeId,
    String? serviceName,
    DateTime? serviceDate,
    int? odometer,
    double? cost,
    String? currency,
    String? serviceProvider,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? manualReminderEnabled,
    int? reminderIntervalKm,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceName: serviceName ?? this.serviceName,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      manualReminderEnabled:
          manualReminderEnabled ?? this.manualReminderEnabled,
      reminderIntervalKm: reminderIntervalKm ?? this.reminderIntervalKm,
    );
  }
}
