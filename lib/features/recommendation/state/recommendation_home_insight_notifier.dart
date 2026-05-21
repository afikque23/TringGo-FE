import 'package:flutter/foundation.dart';

import '../data/recommendation_api_client.dart';
import '../data/recommendation_repository.dart';
import '../models/home_insight_dto.dart';
import '../models/meta_dto.dart';

class RecommendationHomeInsightNotifier extends ChangeNotifier {
  RecommendationHomeInsightNotifier({RecommendationRepository? repository})
    : _repository = repository ?? RecommendationRepository();

  final RecommendationRepository _repository;

  bool isLoadingScores = false;
  bool isLoadingInsight = false;
  String? errorMessage;

  Map<String, double> fuzzyScores = const {};
  MetaDto scoresMeta = MetaDto.empty;

  HomeInsightDto? homeInsight;
  MetaDto insightMeta = MetaDto.empty;

  bool _isDisposed = false;
  int _loadSeq = 0;

  void _safeNotify() {
    if (_isDisposed) return;
    notifyListeners();
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
    isLoadingInsight = true;
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
      final insightRes = await _repository.fetchHomeInsight(motorId);
      if (_isDisposed || seq != _loadSeq) return;
      homeInsight = insightRes.data;
      insightMeta = insightRes.meta;
      if (homeInsight?.fuzzyScores.isNotEmpty == true) {
        fuzzyScores = homeInsight!.fuzzyScores;
      }
    } on ApiException catch (e) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = e.message;
    } catch (_) {
      if (_isDisposed || seq != _loadSeq) return;
      errorMessage = 'Gagal memuat home insight';
    } finally {
      if (!_isDisposed && seq == _loadSeq) {
        isLoadingInsight = false;
        _safeNotify();
      }
    }
  }

  Future<void> refresh(int motorId) async {
    await load(motorId);
  }

  MetaDto get effectiveMeta {
    if (insightMeta.generatedAtRaw != null || insightMeta.fromCache) {
      return insightMeta;
    }
    return scoresMeta;
  }
}
