import 'dart:convert';

Map<String, dynamic>? tryDecodeJsonMap(String? source) {
  if (source == null) {
    return null;
  }

  final trimmed = source.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    return null;
  }

  return null;
}
