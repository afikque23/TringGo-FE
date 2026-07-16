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
  @JsonKey(name: 'kapasitas_cc')
  final String? kapasitasCc;
  final String? transmisi;
  final int odometer;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'user_id')
  final int? userId;
  // Parameter default untuk kalkulasi jadwal servis
  @JsonKey(name: 'default_beban')
  final String? defaultBeban;
  @JsonKey(name: 'default_penumpang')
  final bool? defaultPenumpang;
  @JsonKey(name: 'default_gaya_berkendara')
  final String? defaultGayaBerkendara;
  @JsonKey(name: 'default_kondisi_jalan')
  final String? defaultKondisiJalan;
  @JsonKey(name: 'default_medan')
  final String? defaultMedan;
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
    this.kapasitasCc,
    this.transmisi,
    required this.odometer,
    this.isPrimary = false,
    this.deviceId,
    this.userId,
    this.defaultBeban,
    this.defaultPenumpang,
    this.defaultGayaBerkendara,
    this.defaultKondisiJalan,
    this.defaultMedan,
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
    String? kapasitasCc,
    String? transmisi,
    int? odometer,
    bool? isPrimary,
    Object? deviceId = _sentinel,
    int? userId,
    String? defaultBeban,
    bool? defaultPenumpang,
    String? defaultGayaBerkendara,
    String? defaultKondisiJalan,
    String? defaultMedan,
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
      kapasitasCc: kapasitasCc ?? this.kapasitasCc,
      transmisi: transmisi ?? this.transmisi,
      odometer: odometer ?? this.odometer,
      isPrimary: isPrimary ?? this.isPrimary,
      deviceId: deviceId == _sentinel ? this.deviceId : deviceId as String?,
      userId: userId ?? this.userId,
      defaultBeban: defaultBeban ?? this.defaultBeban,
      defaultPenumpang: defaultPenumpang ?? this.defaultPenumpang,
      defaultGayaBerkendara:
          defaultGayaBerkendara ?? this.defaultGayaBerkendara,
      defaultKondisiJalan: defaultKondisiJalan ?? this.defaultKondisiJalan,
      defaultMedan: defaultMedan ?? this.defaultMedan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Sentinel untuk membedakan null eksplisit vs tidak di-pass (untuk copyWith deviceId)
const _sentinel = Object();
