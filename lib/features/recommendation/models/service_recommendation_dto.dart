import 'recommendation_priority.dart';
import '../utils/json_utils.dart';

class RekomendasiKomponenItemDto {
  final String komponen;
  final RecommendationPriority prioritas;
  final String saran;
  final String estimasiWaktu;

  const RekomendasiKomponenItemDto({
    required this.komponen,
    required this.prioritas,
    required this.saran,
    required this.estimasiWaktu,
  });

  factory RekomendasiKomponenItemDto.fromJson(Map<String, dynamic> json) {
    return RekomendasiKomponenItemDto(
      komponen: JsonUtils.asString(json['komponen'], fallback: '-'),
      prioritas: parseRecommendationPriority(
        JsonUtils.asNullableString(json['prioritas']),
      ),
      saran: JsonUtils.asString(json['saran'], fallback: ''),
      estimasiWaktu: JsonUtils.asString(json['estimasi_waktu'], fallback: ''),
    );
  }
}

class ServiceRecommendationDto {
  final String? ringkasanKondisi;
  final List<RekomendasiKomponenItemDto> rekomendasiKomponen;
  final String? tipsMandiri;

  const ServiceRecommendationDto({
    required this.ringkasanKondisi,
    required this.rekomendasiKomponen,
    required this.tipsMandiri,
  });

  factory ServiceRecommendationDto.fromJson(Map<String, dynamic> json) {
    final rekom = JsonUtils.asList(json['rekomendasi_komponen'])
        .map((e) => JsonUtils.asMap(e))
        .map(RekomendasiKomponenItemDto.fromJson)
        .toList();

    return ServiceRecommendationDto(
      ringkasanKondisi: JsonUtils.asNullableString(json['ringkasan_kondisi']),
      rekomendasiKomponen: rekom,
      tipsMandiri: JsonUtils.asNullableString(json['tips_mandiri']),
    );
  }
}
