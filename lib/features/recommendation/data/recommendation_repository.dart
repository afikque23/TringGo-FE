import '../models/home_insight_dto.dart';
import '../models/meta_dto.dart';
import '../models/scores_dto.dart';
import '../models/service_recommendation_dto.dart';
import 'recommendation_api_client.dart';

class RecommendationRepository {
  RecommendationRepository({RecommendationApiClient? apiClient})
    : _apiClient = apiClient ?? RecommendationApiClient();

  final RecommendationApiClient _apiClient;

  Future<({ScoresDto data, MetaDto meta})> fetchScores(int motorId) async {
    final res = await _apiClient.getScores(motorId);
    return (data: res.data, meta: res.meta);
  }

  Future<({HomeInsightDto data, MetaDto meta})> fetchHomeInsight(
    int motorId,
  ) async {
    final res = await _apiClient.getHomeInsight(motorId);
    return (data: res.data, meta: res.meta);
  }

  Future<({ServiceRecommendationDto data, MetaDto meta})>
  fetchServiceRecommendation(int motorId) async {
    final res = await _apiClient.getServiceRecommendation(motorId);
    return (data: res.data, meta: res.meta);
  }
}
