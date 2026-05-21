import '../utils/json_utils.dart';

class MetaDto {
  final bool fromCache;
  final String? generatedAtRaw;

  const MetaDto({required this.fromCache, required this.generatedAtRaw});

  factory MetaDto.fromJson(Map<String, dynamic> json) {
    return MetaDto(
      fromCache: JsonUtils.asBool(json['from_cache']),
      generatedAtRaw: JsonUtils.asNullableString(json['generated_at']),
    );
  }

  static const empty = MetaDto(fromCache: false, generatedAtRaw: null);
}
