import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../models/home_insight_dto.dart';
import '../models/meta_dto.dart';
import '../models/scores_dto.dart';
import '../models/service_recommendation_dto.dart';
import '../utils/json_utils.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiResult<T> {
  final T data;
  final MetaDto meta;

  const ApiResult({required this.data, required this.meta});
}

/// NOTE: Project ini sudah punya `ApiClient` (http) dengan auto refresh token 1x.
/// Untuk menjaga konsistensi dan memenuhi acceptance criteria (refresh 1x lalu retry),
/// client ini memakai `ApiClient` tersebut.
class RecommendationApiClient {
  RecommendationApiClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResult<ScoresDto>> getScores(int motorId) async {
    final res = await _apiClient.get('/motors/$motorId/scores');
    return _parseResponse(res.statusCode, res.body, (dataJson) {
      return ScoresDto.fromJson(JsonUtils.asMap(dataJson));
    });
  }

  Future<ApiResult<HomeInsightDto>> getHomeInsight(int motorId) async {
    final res = await _apiClient.get('/motors/$motorId/home-insight');
    return _parseResponse(res.statusCode, res.body, (dataJson) {
      return HomeInsightDto.fromJson(JsonUtils.asMap(dataJson));
    });
  }

  Future<ApiResult<ServiceRecommendationDto>> getServiceRecommendation(
    int motorId,
  ) async {
    final res = await _apiClient.get('/motors/$motorId/service-recommendation');
    return _parseResponse(res.statusCode, res.body, (dataJson) {
      return ServiceRecommendationDto.fromJson(JsonUtils.asMap(dataJson));
    });
  }

  Future<void> completeFuzzyService({
    required int motorId,
    required String componentName,
    required DateTime performedAt,
    int? odometer,
    String? serviceProvider,
    String? notes,
  }) async {
    final payload = {
      'component_name': componentName,
      'performed_at': performedAt.toIso8601String().split('T')[0],
      if (odometer != null) 'odometer': odometer,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      if (notes != null) 'notes': notes,
    };
    final res = await _apiClient.post(
      '/motors/$motorId/fuzzy-service-complete',
      body: payload,
    );
    _parseResponse(res.statusCode, res.body, (dataJson) => null);
  }

  ApiResult<T> _parseResponse<T>(
    int statusCode,
    String body,
    T Function(dynamic dataJson) dataParser,
  ) {
    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw ApiException(
        statusCode: statusCode,
        message: 'Response tidak valid dari server',
      );
    }

    final root = JsonUtils.asMap(decoded);
    final success = JsonUtils.asBool(
      root['success'],
      fallback: statusCode >= 200 && statusCode < 300,
    );
    final message = JsonUtils.asString(
      root['message'],
      fallback: 'Terjadi kesalahan',
    );
    final errors = JsonUtils.asMap(root['errors']);

    if (statusCode < 200 || statusCode >= 300 || !success) {
      throw ApiException(
        statusCode: statusCode,
        message: message.isNotEmpty ? message : 'Request gagal',
        errors: errors.isEmpty ? null : errors,
      );
    }

    final dataJson = root['data'];
    final metaJson = JsonUtils.asMap(root['meta']);
    final meta = metaJson.isEmpty ? MetaDto.empty : MetaDto.fromJson(metaJson);
    final data = dataParser(dataJson);
    return ApiResult<T>(data: data, meta: meta);
  }
}
