import 'package:flutter/material.dart';

import '../utils/text_utils.dart';

class FuzzyScoresSection extends StatelessWidget {
  const FuzzyScoresSection({super.key, required this.fuzzyScores});

  final Map<String, double> fuzzyScores;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final entries = fuzzyScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    if (entries.isEmpty) {
      return Text(
        'Belum ada skor fuzzy.',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    TextUtils.snakeToTitleCase(entry.key),
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  entry.value.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
