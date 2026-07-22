import 'package:flutter/foundation.dart';

import '../data/recommendation_api_client.dart';
import '../data/recommendation_repository.dart';
import '../models/meta_dto.dart';
import '../models/service_recommendation_dto.dart';

class RecommendationServiceNotifier extends ChangeNotifier {
  RecommendationServiceNotifier({RecommendationRepository? repository})
    : _repository = repository ?? RecommendationRepository();

  final RecommendationRepository _repository;

  bool isLoadingScores = false;
  bool isLoadingRecommendation = false;
  String? errorMessage;

  Map<String, double> fuzzyScores = const {};
  MetaDto scoresMeta = MetaDto.empty;

  ServiceRecommendationDto? recommendation;
  MetaDto recommendationMeta = MetaDto.empty;

  bool _isDisposed = false;
  int _loadSeq = 0;

  void _safeNotify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> completeFuzzyService({
    required int motorId,
    required String componentName,
    required DateTime performedAt,
    int? odometer,
    String? serviceProvider,
    String? notes,
    bool refreshAfter = true,
  }) async {
    try {
      await _repository.completeFuzzyService(
        motorId: motorId,
        componentName: componentName,
        performedAt: performedAt,
        odometer: odometer,
        serviceProvider: serviceProvider,
        notes: notes,
      );
      if (refreshAfter) {
        // Refresh data after marking complete
        await refresh(motorId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeFuzzyServicesBulk({
    required int motorId,
    required List<
      ({
        String componentName,
        DateTime performedAt,
        int? odometer,
        String? serviceProvider,
        String? notes,
      })
    >
    entries,
  }) async {
    for (final entry in entries) {
      await completeFuzzyService(
        motorId: motorId,
        componentName: entry.componentName,
        performedAt: entry.performedAt,
        odometer: entry.odometer,
        serviceProvider: entry.serviceProvider,
        notes: entry.notes,
        refreshAfter: false,
      );
    }

    await refresh(motorId);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> load(int motorId) async {
    final int seq = ++_loadSeq;
    errorMessage = null;
    isLoadingScores = true;
    isLoadingRecommendation = true;
    _safeNotify();

    try {
      final scoresRes = await _repository.fetchScores(motorId);
      if (_isDisposed || seq != _loadSeq) return;
      fuzzyScores = scoresRes.data.fuzzyScores;
      scoresMeta = scoresRes.meta;
    } on ApiException catch (e) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = e.message;
    } catch (_) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = 'Gagal memuat skor fuzzy';
    } finally {
      if (!_isDisposed && seq == _loadSeq) {
        isLoadingScores = false;
        _safeNotify();
      }
    }

    try {
      final recRes = await _repository.fetchServiceRecommendation(motorId);
      if (_isDisposed || seq != _loadSeq) return;
      recommendation = recRes.data;
      recommendationMeta = recRes.meta;
    } on ApiException catch (e) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = e.message;
    } catch (_) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = 'Gagal memuat rekomendasi servis';
    } finally {
      if (!_isDisposed && seq == _loadSeq) {
        isLoadingRecommendation = false;
        _safeNotify();
      }
    }
  }

  Future<void> refresh(int motorId) async {
    await load(motorId);
  }

  MetaDto get effectiveMeta {
    if (recommendationMeta.generatedAtRaw != null ||
        recommendationMeta.fromCache) {
      return recommendationMeta;
    }
    return scoresMeta;
  }
}
