import 'recommendation_priority.dart';
import '../utils/json_utils.dart';

class MonitoredSummaryDto {
  final int total;
  final int critical;
  final int warning;
  final int normal;

  const MonitoredSummaryDto({
    required this.total,
    required this.critical,
    required this.warning,
    required this.normal,
  });

  const MonitoredSummaryDto.empty()
    : total = 0,
      critical = 0,
      warning = 0,
      normal = 0;

  factory MonitoredSummaryDto.fromJson(Map<String, dynamic> json) {
    return MonitoredSummaryDto(
      total: JsonUtils.asNullableInt(json['total']) ?? 0,
      critical: JsonUtils.asNullableInt(json['critical']) ?? 0,
      warning: JsonUtils.asNullableInt(json['warning']) ?? 0,
      normal: JsonUtils.asNullableInt(json['normal']) ?? 0,
    );
  }
}

class RekomendasiKomponenItemDto {
  final String komponen;
  final RecommendationPriority prioritas;
  final String saran;
  final String estimasiWaktu;
  final int? componentConfigId;
  final int? scheduleId;
  final double? jarakSejakServisKm;
  final double? hinggaServisBerikutnyaKm;
  final double? targetServisKm;
  final String? statusFuzzy;
  final bool isServiceDue;

  const RekomendasiKomponenItemDto({
    required this.komponen,
    required this.prioritas,
    required this.saran,
    required this.estimasiWaktu,
    required this.componentConfigId,
    required this.scheduleId,
    required this.jarakSejakServisKm,
    required this.hinggaServisBerikutnyaKm,
    required this.targetServisKm,
    required this.statusFuzzy,
    required this.isServiceDue,
  });

  factory RekomendasiKomponenItemDto.fromJson(Map<String, dynamic> json) {
    return RekomendasiKomponenItemDto(
      komponen: JsonUtils.asString(json['komponen'], fallback: '-'),
      prioritas: parseRecommendationPriority(
        JsonUtils.asNullableString(json['prioritas']),
      ),
      saran: JsonUtils.asString(json['saran'], fallback: ''),
      estimasiWaktu: JsonUtils.asString(json['estimasi_waktu'], fallback: ''),
      componentConfigId: JsonUtils.asNullableInt(json['component_config_id']),
      scheduleId: JsonUtils.asNullableInt(json['schedule_id']),
      jarakSejakServisKm: JsonUtils.asNullableDouble(
        json['jarak_sejak_servis_km'],
      ),
      hinggaServisBerikutnyaKm: JsonUtils.asNullableDouble(
        json['hingga_servis_berikutnya_km'],
      ),
      targetServisKm: JsonUtils.asNullableDouble(json['target_servis_km']),
      statusFuzzy: JsonUtils.asNullableString(json['status_fuzzy']),
      isServiceDue: JsonUtils.asBool(json['is_service_due']),
    );
  }
}

class ServiceRecommendationDto {
  final String? ringkasanKondisi;
  final List<RekomendasiKomponenItemDto> rekomendasiKomponen;
  final String? tipsMandiri;
  final MonitoredSummaryDto monitoredSummary;

  const ServiceRecommendationDto({
    required this.ringkasanKondisi,
    required this.rekomendasiKomponen,
    required this.tipsMandiri,
    required this.monitoredSummary,
  });

  factory ServiceRecommendationDto.fromJson(Map<String, dynamic> json) {
    final rekom = JsonUtils.asList(json['rekomendasi_komponen'])
        .map((e) => JsonUtils.asMap(e))
        .map(RekomendasiKomponenItemDto.fromJson)
        .toList();

    final monitoredSummaryRaw = JsonUtils.asMap(json['monitored_summary']);

    return ServiceRecommendationDto(
      ringkasanKondisi: JsonUtils.asNullableString(json['ringkasan_kondisi']),
      rekomendasiKomponen: rekom,
      tipsMandiri: JsonUtils.asNullableString(json['tips_mandiri']),
      monitoredSummary: monitoredSummaryRaw.isEmpty
          ? const MonitoredSummaryDto.empty()
          : MonitoredSummaryDto.fromJson(monitoredSummaryRaw),
    );
  }
}
