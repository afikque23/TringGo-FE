import '../utils/json_utils.dart';

class ScoresDto {
  final Map<String, double> fuzzyScores;

  const ScoresDto({required this.fuzzyScores});

  factory ScoresDto.fromJson(Map<String, dynamic> json) {
    return ScoresDto(
      fuzzyScores: JsonUtils.asStringDoubleMap(json['fuzzy_scores']),
    );
  }
}
