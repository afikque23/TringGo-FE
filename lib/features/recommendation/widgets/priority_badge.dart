import 'package:flutter/material.dart';

import '../models/recommendation_priority.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final RecommendationPriority priority;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (label, color) = switch (priority) {
      RecommendationPriority.critical => ('Critical', colorScheme.error),
      RecommendationPriority.warning => ('Warning', colorScheme.tertiary),
      RecommendationPriority.normal => ('Normal', colorScheme.primary),
      RecommendationPriority.unknown => ('Normal', colorScheme.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}
