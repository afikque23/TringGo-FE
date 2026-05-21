enum RecommendationPriority { critical, warning, normal, unknown }

RecommendationPriority parseRecommendationPriority(String? raw) {
  final normalized = (raw ?? '').trim().toLowerCase();
  switch (normalized) {
    case 'critical':
      return RecommendationPriority.critical;
    case 'warning':
      return RecommendationPriority.warning;
    case 'normal':
      return RecommendationPriority.normal;
    default:
      return RecommendationPriority.unknown;
  }
}
