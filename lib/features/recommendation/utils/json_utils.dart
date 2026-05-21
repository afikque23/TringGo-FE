class JsonUtils {
  JsonUtils._();

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static List<dynamic> asList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  static String? asNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return null;
  }

  static String asString(dynamic value, {String fallback = ''}) {
    return asNullableString(value) ?? fallback;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    if (value is num) return value != 0;
    return fallback;
  }

  static int? asNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? asNullableDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, double> asStringDoubleMap(dynamic value) {
    final map = asMap(value);
    final out = <String, double>{};
    for (final entry in map.entries) {
      final key = entry.key;
      final parsed = asNullableDouble(entry.value);
      if (parsed != null && parsed.isFinite) {
        out[key] = parsed;
      }
    }
    return out;
  }
}
