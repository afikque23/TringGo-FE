import 'package:flutter/material.dart';

import '../models/meta_dto.dart';

class MetaInfoRow extends StatelessWidget {
  const MetaInfoRow({super.key, required this.meta});

  final MetaDto meta;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final generatedAt = meta.generatedAtRaw;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Spacer(),
        if (meta.fromCache)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
            ),
            child: Text(
              'Cache',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
