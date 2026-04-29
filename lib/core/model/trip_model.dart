import 'package:json_annotation/json_annotation.dart';
import 'location_point.dart';

part 'trip_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TripModel {
  final String id;
  final String motorcycleName;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance; // in kilometers
  final int duration; // in seconds
  final double averageSpeed; // in km/h
  final double maxSpeed; // in km/h
  final List<LocationPoint> points;
  final String status; // 'active', 'completed', 'paused'

  // Sumber data
  final String source; // 'gps' atau 'manual'

  // Parameter konteks (auto-detect GPS / kalibrasi manual)
  @JsonKey(name: 'kondisi_lalu_lintas')
  final String? kondisiLaluLintas; // 'macet', 'sedang', 'lancar'
  final String? medan; // 'datar', 'berbukit', 'campuran'
  @JsonKey(name: 'gaya_berkendara')
  final String? gayaBerkendara; // 'pelan', 'normal', 'agresif'

  // Parameter manual
  final String? beban; // 'ringan', 'sedang', 'berat'
  @JsonKey(name: 'ada_penumpang')
  final bool? adaPenumpang;

  // Data sensor GPS tambahan
  @JsonKey(name: 'elevation_gain')
  final int? elevationGain; // meters
  @JsonKey(name: 'idle_time_minutes')
  final int? idleTimeMinutes;
  @JsonKey(name: 'rough_road_count')
  final int roughRoadCount;
  @JsonKey(name: 'hard_acceleration_count')
  final int hardAccelerationCount;
  @JsonKey(name: 'hard_braking_count')
  final int hardBrakingCount;

  // Kalibrasi & scoring
  @JsonKey(name: 'is_calibrated')
  final bool isCalibrated;
  @JsonKey(name: 'service_score_factor')
  final double serviceScoreFactor;

  final String? notes;

  TripModel({
    required this.id,
    required this.motorcycleName,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.duration,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.points,
    required this.status,
    this.source = 'gps',
    this.kondisiLaluLintas,
    this.medan,
    this.gayaBerkendara,
    this.beban,
    this.adaPenumpang,
    this.elevationGain,
    this.idleTimeMinutes,
    this.roughRoadCount = 0,
    this.hardAccelerationCount = 0,
    this.hardBrakingCount = 0,
    this.isCalibrated = false,
    this.serviceScoreFactor = 1.0,
    this.notes,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  // Create a new GPS trip
  factory TripModel.createNew({
    required String motorcycleName,
    required LocationPoint startPoint,
    String? beban,
    bool? adaPenumpang,
  }) {
    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      motorcycleName: motorcycleName,
      startTime: DateTime.now(),
      endTime: null,
      totalDistance: 0.0,
      duration: 0,
      averageSpeed: 0.0,
      maxSpeed: 0.0,
      points: [startPoint],
      status: 'active',
      source: 'gps',
      beban: beban,
      adaPenumpang: adaPenumpang,
    );
  }

  // Create a manual trip entry
  factory TripModel.createManual({
    required String motorcycleName,
    required DateTime startTime,
    required DateTime endTime,
    required double totalDistance,
    String? kondisiLaluLintas,
    String? medan,
    String? gayaBerkendara,
    String? beban,
    bool? adaPenumpang,
    String? notes,
  }) {
    final durationSec = endTime.difference(startTime).inSeconds;
    final avgSpeed = durationSec > 0
        ? (totalDistance / (durationSec / 3600))
        : 0.0;

    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      motorcycleName: motorcycleName,
      startTime: startTime,
      endTime: endTime,
      totalDistance: totalDistance,
      duration: durationSec,
      averageSpeed: avgSpeed,
      maxSpeed: 0.0,
      points: [],
      status: 'completed',
      source: 'manual',
      kondisiLaluLintas: kondisiLaluLintas,
      medan: medan,
      gayaBerkendara: gayaBerkendara,
      beban: beban,
      adaPenumpang: adaPenumpang,
      notes: notes,
    );
  }

  // Copy with method for updates & kalibrasi
  TripModel copyWith({
    String? id,
    String? motorcycleName,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    int? duration,
    double? averageSpeed,
    double? maxSpeed,
    List<LocationPoint>? points,
    String? status,
    String? source,
    String? kondisiLaluLintas,
    String? medan,
    String? gayaBerkendara,
    String? beban,
    bool? adaPenumpang,
    int? elevationGain,
    int? idleTimeMinutes,
    int? roughRoadCount,
    int? hardAccelerationCount,
    int? hardBrakingCount,
    bool? isCalibrated,
    double? serviceScoreFactor,
    String? notes,
  }) {
    return TripModel(
      id: id ?? this.id,
      motorcycleName: motorcycleName ?? this.motorcycleName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      duration: duration ?? this.duration,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      points: points ?? this.points,
      status: status ?? this.status,
      source: source ?? this.source,
      kondisiLaluLintas: kondisiLaluLintas ?? this.kondisiLaluLintas,
      medan: medan ?? this.medan,
      gayaBerkendara: gayaBerkendara ?? this.gayaBerkendara,
      beban: beban ?? this.beban,
      adaPenumpang: adaPenumpang ?? this.adaPenumpang,
      elevationGain: elevationGain ?? this.elevationGain,
      idleTimeMinutes: idleTimeMinutes ?? this.idleTimeMinutes,
      roughRoadCount: roughRoadCount ?? this.roughRoadCount,
      hardAccelerationCount:
          hardAccelerationCount ?? this.hardAccelerationCount,
      hardBrakingCount: hardBrakingCount ?? this.hardBrakingCount,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      serviceScoreFactor: serviceScoreFactor ?? this.serviceScoreFactor,
      notes: notes ?? this.notes,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Label kondisi lalu lintas yang terjadi
  String get kondisiLaluLintasLabel {
    return switch (kondisiLaluLintas) {
      'macet' => '🔴 Macet',
      'sedang' => '🟡 Sedang',
      'lancar' => '🟢 Lancar',
      _ => '-',
    };
  }

  /// Label medan perjalanan
  String get medanLabel {
    return switch (medan) {
      'datar' => '🏙️ Datar',
      'campuran' => '🌄 Campuran',
      'berbukit' => '🏔️ Berbukit',
      _ => '-',
    };
  }

  @override
  String toString() {
    return 'TripModel(id: $id, distance: ${totalDistance.toStringAsFixed(2)} km, '
        'duration: $formattedDuration, status: $status, source: $source)';
  }
}
