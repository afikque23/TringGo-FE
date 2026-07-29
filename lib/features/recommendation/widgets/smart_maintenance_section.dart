import 'package:flutter/material.dart';

import '../models/home_insight_dto.dart';

class SmartMaintenanceSection extends StatelessWidget {
  const SmartMaintenanceSection({super.key, required this.smartMaintenance});

  final SmartMaintenanceDto smartMaintenance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (smartMaintenance.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Smart Maintenance',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        if (smartMaintenance.prediksiServis.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            smartMaintenance.prediksiServis,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (smartMaintenance.fokusKomponen.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Fokus Komponen:',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: smartMaintenance.fokusKomponen.map((komponen) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 0.65,
                  ),
                ),
                child: Text(
                  komponen,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (smartMaintenance.saranAdaptif.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 15,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    smartMaintenance.saranAdaptif,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
