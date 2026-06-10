import 'package:flutter/material.dart';

import '../utils/text_utils.dart';

class FuzzyScoresSection extends StatelessWidget {
  const FuzzyScoresSection({super.key, required this.fuzzyScores});

  final Map<String, double> fuzzyScores;

  String _translateComponent(String key) {
    switch (key) {
      case 'engine_oil':
        return 'Oli Mesin';
      case 'tires':
        return 'Ban';
      case 'air_filter':
        return 'Filter Udara';
      case 'spark_plug':
        return 'Busi';
      case 'battery':
        return 'Aki';
      case 'brake':
        return 'Rem';
      case 'cvt_belt':
        return 'CVT/Belt';
      case 'cvt_roller':
        return 'Roller CVT';
      case 'final_drive_oil':
        return 'Oli Gardan';
      case 'chain':
        return 'Rantai';
      case 'clutch':
        return 'Kopling';
      default:
        // Coba bersihkan suffix ID jika ada (contoh: engine_oil_12 -> engine_oil)
        final cleanKey = key.replaceAll(RegExp(r'_\d+$'), '');
        if (cleanKey != key) {
          return _translateComponent(cleanKey);
        }
        return TextUtils.snakeToTitleCase(key);
    }
  }

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
                    _translateComponent(entry.key),
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
