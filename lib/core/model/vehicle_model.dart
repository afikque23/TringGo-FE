import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  final int? id;
  final String title;
  final String make;
  final String model;
  final int year;
  @JsonKey(name: 'tipe_motor')
  final String? tipeMotor;
  final int odometer;
  @JsonKey(name: 'license_plate')
  final String? licensePlate;
  final String? color;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  VehicleModel({
    this.id,
    required this.title,
    required this.make,
    required this.model,
    required this.year,
    this.tipeMotor,
    required this.odometer,
    this.licensePlate,
    this.color,
    this.isPrimary = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  VehicleModel copyWith({
    int? id,
    String? title,
    String? make,
    String? model,
    int? year,
    String? tipeMotor,
    int? odometer,
    String? licensePlate,
    String? color,
    bool? isPrimary,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      tipeMotor: tipeMotor ?? this.tipeMotor,
      odometer: odometer ?? this.odometer,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      isPrimary: isPrimary ?? this.isPrimary,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
