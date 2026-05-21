class TextUtils {
  TextUtils._();

  static String snakeToTitleCase(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;

    final words = trimmed
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return trimmed;

    return words
        .map(
          (w) => w.length <= 1
              ? w.toUpperCase()
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
