import 'package:json_annotation/json_annotation.dart';

part 'tip_model.g.dart';

@JsonSerializable()
class TipModel {
  final int id;
  final String title;
  final String description;
  final TipAuthor author;
  final TipVehicle vehicle;
  final TipDifficulty? difficulty;
  final TipStats stats;
  @JsonKey(defaultValue: <TipTag>[])
  final List<TipTag> tags;
  final List<TipTool>? tools;
  final List<TipStep>? steps;
  @JsonKey(name: 'maintenance_interval')
  final TipMaintenanceInterval? maintenanceInterval;
  @JsonKey(name: 'important_notes')
  final String? importantNotes;
  final List<String>? hashtags;
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;
  @JsonKey(name: 'is_copyable', defaultValue: false)
  final bool isCopyable;
  @JsonKey(defaultValue: 'published')
  final String status;
  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;
  @JsonKey(name: 'is_bookmarked', defaultValue: false)
  final bool isBookmarked;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  TipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.vehicle,
    this.difficulty,
    required this.stats,
    required this.tags,
    this.tools,
    this.steps,
    this.maintenanceInterval,
    this.importantNotes,
    this.hashtags,
    this.estimatedTime,
    required this.isCopyable,
    required this.status,
    required this.isLiked,
    required this.isBookmarked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    final rawMaintenanceInterval =
        normalized['maintenance_interval'] ?? normalized['maintenanceInterval'];

    normalized['maintenance_interval'] =
        TipMaintenanceInterval.normalizeRawJson(
          rawMaintenanceInterval,
          parentJson: normalized,
        );

    return _$TipModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$TipModelToJson(this);
}

@JsonSerializable()
class TipAuthor {
  final int id;
  final String name;
  @JsonKey(name: 'avatar_emoji')
  final String? avatarEmoji;
  @JsonKey(name: 'avatar')
  final String? avatarUrl;
  final TipBadge? badge;
  final String? bio;
  final TipAuthorStats? stats;

  TipAuthor({
    required this.id,
    required this.name,
    this.avatarEmoji,
    this.avatarUrl,
    this.badge,
    this.bio,
    this.stats,
  });

  factory TipAuthor.fromJson(Map<String, dynamic> json) =>
      _$TipAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$TipAuthorToJson(this);
}

@JsonSerializable()
class TipBadge {
  final String name;
  final String icon;
  final String color;

  TipBadge({required this.name, required this.icon, required this.color});

  factory TipBadge.fromJson(Map<String, dynamic> json) =>
      _$TipBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$TipBadgeToJson(this);
}

@JsonSerializable()
class TipAuthorStats {
  @JsonKey(name: 'tips_count')
  final int tipsCount;
  @JsonKey(name: 'followers_count')
  final int followersCount;

  TipAuthorStats({required this.tipsCount, required this.followersCount});

  factory TipAuthorStats.fromJson(Map<String, dynamic> json) =>
      _$TipAuthorStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TipAuthorStatsToJson(this);
}

@JsonSerializable()
class TipVehicle {
  final String brand;
  final String model;
  final int year;
  @JsonKey(name: 'riding_style')
  final String ridingStyle;

  TipVehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.ridingStyle,
  });

  factory TipVehicle.fromJson(Map<String, dynamic> json) =>
      _$TipVehicleFromJson(json);
  Map<String, dynamic> toJson() => _$TipVehicleToJson(this);
}

@JsonSerializable()
class TipDifficulty {
  final String level;
  final String color;
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;

  TipDifficulty({required this.level, required this.color, this.estimatedTime});

  factory TipDifficulty.fromJson(Map<String, dynamic> json) =>
      _$TipDifficultyFromJson(json);
  Map<String, dynamic> toJson() => _$TipDifficultyToJson(this);
}

@JsonSerializable()
class TipStats {
  final double rating;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'bookmarks_count')
  final int bookmarksCount;
  @JsonKey(name: 'shares_count')
  final int sharesCount;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'success_percentage')
  final int successPercentage;

  TipStats({
    required this.rating,
    required this.likesCount,
    required this.bookmarksCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.successPercentage,
  });

  factory TipStats.fromJson(Map<String, dynamic> json) =>
      _$TipStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TipStatsToJson(this);
}

@JsonSerializable()
class TipTag {
  final int id;
  final String name;
  final String type;
  final String color;
  final String? icon;

  TipTag({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.icon,
  });

  factory TipTag.fromJson(Map<String, dynamic> json) => _$TipTagFromJson(json);
  Map<String, dynamic> toJson() => _$TipTagToJson(this);
}

@JsonSerializable()
class TipTool {
  final int? id;
  final String name;
  @JsonKey(name: 'is_optional', defaultValue: false)
  final bool isOptional;

  TipTool({this.id, required this.name, required this.isOptional});

  factory TipTool.fromJson(Map<String, dynamic> json) =>
      _$TipToolFromJson(json);
  Map<String, dynamic> toJson() => _$TipToolToJson(this);
}

@JsonSerializable()
class TipStep {
  @JsonKey(name: 'step_number')
  final int? stepNumber;
  final String title;
  final String description;

  TipStep({this.stepNumber, required this.title, required this.description});

  factory TipStep.fromJson(Map<String, dynamic> json) =>
      _$TipStepFromJson(json);
  Map<String, dynamic> toJson() => _$TipStepToJson(this);
}

@JsonSerializable()
class TipMaintenanceInterval {
  @JsonKey(name: 'distance_km')
  final int? distanceKm;
  @JsonKey(name: 'time_months')
  final int? timeMonths;
  final String? description;

  TipMaintenanceInterval({this.distanceKm, this.timeMonths, this.description});

  factory TipMaintenanceInterval.fromJson(Map<String, dynamic> json) {
    final normalized = normalizeRawJson(json) ?? <String, dynamic>{};

    return TipMaintenanceInterval(
      distanceKm: _tryParseInt(normalized['distance_km']),
      timeMonths: _tryParseInt(normalized['time_months']),
      description: normalized['description']?.toString(),
    );
  }

  static Map<String, dynamic>? normalizeRawJson(
    dynamic raw, {
    Map<String, dynamic>? parentJson,
  }) {
    final parent = parentJson ?? const <String, dynamic>{};
    Map<String, dynamic> source = <String, dynamic>{};

    if (raw is Map<String, dynamic>) {
      source = Map<String, dynamic>.from(raw);
    } else if (raw is Map) {
      source = raw.map((key, value) => MapEntry(key.toString(), value));
    }

    int? distanceKm = _tryParseInt(
      source['distance_km'] ??
          source['distanceKm'] ??
          source['distance'] ??
          parent['distance_km'] ??
          parent['interval_distance_km'] ??
          parent['interval_km'],
    );

    int? timeMonths = _tryParseInt(
      source['time_months'] ??
          source['timeMonths'] ??
          source['month'] ??
          source['months'] ??
          parent['time_months'] ??
          parent['interval_months'],
    );

    final intervalTypeRaw =
        source['interval_type'] ??
        source['intervalType'] ??
        parent['interval_type'] ??
        parent['intervalType'];
    final intervalType = intervalTypeRaw?.toString().toLowerCase();

    final intervalValue = _tryParseInt(
      source['interval_value'] ??
          source['intervalValue'] ??
          parent['interval_value'] ??
          parent['intervalValue'],
    );

    if (intervalValue != null) {
      if (distanceKm == null &&
          (intervalType == null ||
              intervalType == 'distance' ||
              intervalType == 'mileage' ||
              intervalType == 'km' ||
              intervalType == 'both')) {
        distanceKm = intervalValue;
      }

      if (timeMonths == null &&
          (intervalType == 'time' ||
              intervalType == 'month' ||
              intervalType == 'months')) {
        timeMonths = intervalValue;
      }
    }

    if (raw is num) {
      distanceKm ??= raw.toInt();
    } else if (raw is String) {
      distanceKm ??= _tryParseInt(raw);
    }

    final description =
        source['description']?.toString() ??
        parent['maintenance_interval_description']?.toString();

    if (distanceKm == null && timeMonths == null && description == null) {
      return null;
    }

    return {
      'distance_km': distanceKm,
      'time_months': timeMonths,
      'description': description,
    };
  }

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.isEmpty) return null;
      return int.tryParse(digitsOnly);
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_km': distanceKm,
      'time_months': timeMonths,
      'description': description,
    };
  }
}

// Request models for creating/updating tips
@JsonSerializable()
class CreateTipRequest {
  final String title;
  final String description;
  final TipVehicle vehicle;
  final String? difficulty;
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;
  final List<TipTool> tools;
  final List<TipStep> steps;
  @JsonKey(name: 'maintenance_interval')
  final TipMaintenanceInterval? maintenanceInterval;
  @JsonKey(name: 'important_notes')
  final String? importantNotes;
  final List<String>? hashtags;
  @JsonKey(name: 'is_copyable')
  final bool isCopyable;

  CreateTipRequest({
    required this.title,
    required this.description,
    required this.vehicle,
    this.difficulty,
    this.estimatedTime,
    required this.tools,
    required this.steps,
    this.maintenanceInterval,
    this.importantNotes,
    this.hashtags,
    required this.isCopyable,
  });

  factory CreateTipRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTipRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTipRequestToJson(this);
}

@JsonSerializable()
class TipActionRequest {
  final String action;

  TipActionRequest({required this.action});

  factory TipActionRequest.fromJson(Map<String, dynamic> json) =>
      _$TipActionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TipActionRequestToJson(this);
}

@JsonSerializable()
class TipShareRequest {
  final String platform;

  TipShareRequest({required this.platform});

  factory TipShareRequest.fromJson(Map<String, dynamic> json) =>
      _$TipShareRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TipShareRequestToJson(this);
}

@JsonSerializable()
class TipUseTemplateRequest {
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  @JsonKey(name: 'schedule_type')
  final String scheduleType;
  @JsonKey(name: 'interval_type')
  final String? intervalType;
  @JsonKey(name: 'interval_value')
  final int? intervalValue;
  @JsonKey(name: 'start_date')
  final String? startDate;
  final String? notes;

  TipUseTemplateRequest({
    required this.vehicleId,
    required this.scheduleType,
    this.intervalType,
    this.intervalValue,
    this.startDate,
    this.notes,
  });

  factory TipUseTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$TipUseTemplateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TipUseTemplateRequestToJson(this);
}

// Response models
@JsonSerializable()
class TipsListResponse {
  final bool success;
  final String message;
  final TipsListData data;

  TipsListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TipsListResponse.fromJson(Map<String, dynamic> json) =>
      _$TipsListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TipsListResponseToJson(this);
}

@JsonSerializable()
class TipsListData {
  @JsonKey(defaultValue: <TipModel>[])
  final List<TipModel> tips;
  final PaginationData pagination;

  TipsListData({required this.tips, required this.pagination});

  factory TipsListData.fromJson(Map<String, dynamic> json) =>
      _$TipsListDataFromJson(json);
  Map<String, dynamic> toJson() => _$TipsListDataToJson(this);
}

@JsonSerializable()
class PaginationData {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'items_per_page')
  final int itemsPerPage;
  @JsonKey(name: 'has_next', defaultValue: false)
  final bool hasNext;
  @JsonKey(name: 'has_prev', defaultValue: false)
  final bool hasPrev;

  PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) =>
      _$PaginationDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationDataToJson(this);
}

@JsonSerializable()
class TipDetailResponse {
  final bool success;
  final String message;
  final TipModel data;

  TipDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TipDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$TipDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TipDetailResponseToJson(this);
}

class TipCreateResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  TipCreateResponse({required this.success, required this.message, this.data});

  factory TipCreateResponse.fromJson(Map<String, dynamic> json) {
    return TipCreateResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Permintaan berhasil diproses',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }
}
