import 'recommendation_priority.dart';
import 'service_recommendation_dto.dart';
import '../utils/json_utils.dart';

class WawasanPintarItemDto {
  final String judul;
  final String isi;
  final RecommendationPriority prioritas;

  const WawasanPintarItemDto({
    required this.judul,
    required this.isi,
    required this.prioritas,
  });

  factory WawasanPintarItemDto.fromJson(Map<String, dynamic> json) {
    return WawasanPintarItemDto(
      judul: JsonUtils.asString(json['judul'], fallback: '-'),
      isi: JsonUtils.asString(json['isi'], fallback: ''),
      prioritas: parseRecommendationPriority(
        JsonUtils.asNullableString(json['prioritas']),
      ),
    );
  }
}

class InsightSistemDto {
  final String label;
  final String isi;

  const InsightSistemDto({required this.label, required this.isi});

  factory InsightSistemDto.fromJson(Map<String, dynamic> json) {
    return InsightSistemDto(
      label: JsonUtils.asString(json['label'], fallback: ''),
      isi: JsonUtils.asString(json['isi'], fallback: ''),
    );
  }
}

class HomeInsightDto {
  final List<WawasanPintarItemDto> wawasanPintar;
  final InsightSistemDto? insightSistem;
  final Map<String, double> fuzzyScores;
  final Map<String, String> fuzzyStatuses;
  final MonitoredSummaryDto monitoredSummary;

  const HomeInsightDto({
    required this.wawasanPintar,
    required this.insightSistem,
    required this.fuzzyScores,
    required this.fuzzyStatuses,
    required this.monitoredSummary,
  });

  factory HomeInsightDto.fromJson(Map<String, dynamic> json) {
    final wawasan = JsonUtils.asList(json['wawasan_pintar'])
        .map((e) => JsonUtils.asMap(e))
        .map(WawasanPintarItemDto.fromJson)
        .toList();

    final insightRaw = json['insight_sistem'];
    final insightMap = JsonUtils.asMap(insightRaw);
    final insight = insightRaw == null || insightMap.isEmpty
        ? null
        : InsightSistemDto.fromJson(insightMap);
    final statusesRaw = JsonUtils.asMap(json['fuzzy_statuses']);
    final fuzzyStatuses = <String, String>{};
    for (final entry in statusesRaw.entries) {
      final value = JsonUtils.asNullableString(entry.value);
      if (value != null && value.trim().isNotEmpty) {
        fuzzyStatuses[entry.key] = value.trim().toLowerCase();
      }
    }
    final monitoredSummaryRaw = JsonUtils.asMap(json['monitored_summary']);

    return HomeInsightDto(
      wawasanPintar: wawasan,
      insightSistem: insight,
      fuzzyScores: JsonUtils.asStringDoubleMap(json['fuzzy_scores']),
      fuzzyStatuses: fuzzyStatuses,
      monitoredSummary: monitoredSummaryRaw.isEmpty
          ? const MonitoredSummaryDto.empty()
          : MonitoredSummaryDto.fromJson(monitoredSummaryRaw),
    );
  }
}
