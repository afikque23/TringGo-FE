// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipModel _$TipModelFromJson(Map<String, dynamic> json) => TipModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  author: TipAuthor.fromJson(json['author'] as Map<String, dynamic>),
  vehicle: TipVehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
  difficulty: json['difficulty'] == null
      ? null
      : TipDifficulty.fromJson(json['difficulty'] as Map<String, dynamic>),
  stats: TipStats.fromJson(json['stats'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => TipTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => TipTool.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>?)
      ?.map((e) => TipStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  maintenanceInterval: json['maintenance_interval'] == null
      ? null
      : TipMaintenanceInterval.fromJson(
          json['maintenance_interval'] as Map<String, dynamic>,
        ),
  importantNotes: json['important_notes'] as String?,
  hashtags: (json['hashtags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedTime: json['estimated_time'] as String?,
  isCopyable: json['is_copyable'] as bool? ?? false,
  status: json['status'] as String? ?? 'published',
  isLiked: json['is_liked'] as bool? ?? false,
  isBookmarked: json['is_bookmarked'] as bool? ?? false,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$TipModelToJson(TipModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'author': instance.author,
  'vehicle': instance.vehicle,
  'difficulty': instance.difficulty,
  'stats': instance.stats,
  'tags': instance.tags,
  'tools': instance.tools,
  'steps': instance.steps,
  'maintenance_interval': instance.maintenanceInterval,
  'important_notes': instance.importantNotes,
  'hashtags': instance.hashtags,
  'estimated_time': instance.estimatedTime,
  'is_copyable': instance.isCopyable,
  'status': instance.status,
  'is_liked': instance.isLiked,
  'is_bookmarked': instance.isBookmarked,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

TipAuthor _$TipAuthorFromJson(Map<String, dynamic> json) => TipAuthor(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  avatarEmoji: json['avatar_emoji'] as String?,
  avatarUrl: json['avatar'] as String?,
  badge: json['badge'] == null
      ? null
      : TipBadge.fromJson(json['badge'] as Map<String, dynamic>),
  bio: json['bio'] as String?,
  stats: json['stats'] == null
      ? null
      : TipAuthorStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TipAuthorToJson(TipAuthor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_emoji': instance.avatarEmoji,
  'avatar': instance.avatarUrl,
  'badge': instance.badge,
  'bio': instance.bio,
  'stats': instance.stats,
};

TipBadge _$TipBadgeFromJson(Map<String, dynamic> json) => TipBadge(
  name: json['name'] as String,
  icon: json['icon'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$TipBadgeToJson(TipBadge instance) => <String, dynamic>{
  'name': instance.name,
  'icon': instance.icon,
  'color': instance.color,
};

TipAuthorStats _$TipAuthorStatsFromJson(Map<String, dynamic> json) =>
    TipAuthorStats(
      tipsCount: (json['tips_count'] as num).toInt(),
      followersCount: (json['followers_count'] as num).toInt(),
    );

Map<String, dynamic> _$TipAuthorStatsToJson(TipAuthorStats instance) =>
    <String, dynamic>{
      'tips_count': instance.tipsCount,
      'followers_count': instance.followersCount,
    };

TipVehicle _$TipVehicleFromJson(Map<String, dynamic> json) => TipVehicle(
  brand: json['brand'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  ridingStyle: json['riding_style'] as String,
);

Map<String, dynamic> _$TipVehicleToJson(TipVehicle instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'model': instance.model,
      'year': instance.year,
      'riding_style': instance.ridingStyle,
    };

TipDifficulty _$TipDifficultyFromJson(Map<String, dynamic> json) =>
    TipDifficulty(
      level: json['level'] as String,
      color: json['color'] as String,
      estimatedTime: json['estimated_time'] as String?,
    );

Map<String, dynamic> _$TipDifficultyToJson(TipDifficulty instance) =>
    <String, dynamic>{
      'level': instance.level,
      'color': instance.color,
      'estimated_time': instance.estimatedTime,
    };

TipStats _$TipStatsFromJson(Map<String, dynamic> json) => TipStats(
  rating: (json['rating'] as num).toDouble(),
  likesCount: (json['likes_count'] as num).toInt(),
  bookmarksCount: (json['bookmarks_count'] as num).toInt(),
  sharesCount: (json['shares_count'] as num).toInt(),
  viewsCount: (json['views_count'] as num).toInt(),
  successPercentage: (json['success_percentage'] as num).toInt(),
);

Map<String, dynamic> _$TipStatsToJson(TipStats instance) => <String, dynamic>{
  'rating': instance.rating,
  'likes_count': instance.likesCount,
  'bookmarks_count': instance.bookmarksCount,
  'shares_count': instance.sharesCount,
  'views_count': instance.viewsCount,
  'success_percentage': instance.successPercentage,
};

TipTag _$TipTagFromJson(Map<String, dynamic> json) => TipTag(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  type: json['type'] as String,
  color: json['color'] as String,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$TipTagToJson(TipTag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'color': instance.color,
  'icon': instance.icon,
};

TipTool _$TipToolFromJson(Map<String, dynamic> json) => TipTool(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  isOptional: json['is_optional'] as bool? ?? false,
);

Map<String, dynamic> _$TipToolToJson(TipTool instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'is_optional': instance.isOptional,
};

TipStep _$TipStepFromJson(Map<String, dynamic> json) => TipStep(
  stepNumber: (json['step_number'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$TipStepToJson(TipStep instance) => <String, dynamic>{
  'step_number': instance.stepNumber,
  'title': instance.title,
  'description': instance.description,
};

TipMaintenanceInterval _$TipMaintenanceIntervalFromJson(
  Map<String, dynamic> json,
) => TipMaintenanceInterval(
  distanceKm: (json['distance_km'] as num?)?.toInt(),
  timeMonths: (json['time_months'] as num?)?.toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$TipMaintenanceIntervalToJson(
  TipMaintenanceInterval instance,
) => <String, dynamic>{
  'distance_km': instance.distanceKm,
  'time_months': instance.timeMonths,
  'description': instance.description,
};

CreateTipRequest _$CreateTipRequestFromJson(Map<String, dynamic> json) =>
    CreateTipRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      vehicle: TipVehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      difficulty: json['difficulty'] as String?,
      estimatedTime: json['estimated_time'] as String?,
      tools: (json['tools'] as List<dynamic>)
          .map((e) => TipTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => TipStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      maintenanceInterval: json['maintenance_interval'] == null
          ? null
          : TipMaintenanceInterval.fromJson(
              json['maintenance_interval'] as Map<String, dynamic>,
            ),
      importantNotes: json['important_notes'] as String?,
      hashtags: (json['hashtags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isCopyable: json['is_copyable'] as bool,
    );

Map<String, dynamic> _$CreateTipRequestToJson(CreateTipRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'vehicle': instance.vehicle,
      'difficulty': instance.difficulty,
      'estimated_time': instance.estimatedTime,
      'tools': instance.tools,
      'steps': instance.steps,
      'maintenance_interval': instance.maintenanceInterval,
      'important_notes': instance.importantNotes,
      'hashtags': instance.hashtags,
      'is_copyable': instance.isCopyable,
    };

TipActionRequest _$TipActionRequestFromJson(Map<String, dynamic> json) =>
    TipActionRequest(action: json['action'] as String);

Map<String, dynamic> _$TipActionRequestToJson(TipActionRequest instance) =>
    <String, dynamic>{'action': instance.action};

TipShareRequest _$TipShareRequestFromJson(Map<String, dynamic> json) =>
    TipShareRequest(platform: json['platform'] as String);

Map<String, dynamic> _$TipShareRequestToJson(TipShareRequest instance) =>
    <String, dynamic>{'platform': instance.platform};

TipUseTemplateRequest _$TipUseTemplateRequestFromJson(
  Map<String, dynamic> json,
) => TipUseTemplateRequest(
  vehicleId: (json['vehicle_id'] as num).toInt(),
  scheduleType: json['schedule_type'] as String,
  intervalType: json['interval_type'] as String?,
  intervalValue: (json['interval_value'] as num?)?.toInt(),
  startDate: json['start_date'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$TipUseTemplateRequestToJson(
  TipUseTemplateRequest instance,
) => <String, dynamic>{
  'vehicle_id': instance.vehicleId,
  'schedule_type': instance.scheduleType,
  'interval_type': instance.intervalType,
  'interval_value': instance.intervalValue,
  'start_date': instance.startDate,
  'notes': instance.notes,
};

TipsListResponse _$TipsListResponseFromJson(Map<String, dynamic> json) =>
    TipsListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TipsListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TipsListResponseToJson(TipsListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TipsListData _$TipsListDataFromJson(Map<String, dynamic> json) => TipsListData(
  tips:
      (json['tips'] as List<dynamic>?)
          ?.map((e) => TipModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pagination: PaginationData.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TipsListDataToJson(TipsListData instance) =>
    <String, dynamic>{'tips': instance.tips, 'pagination': instance.pagination};

PaginationData _$PaginationDataFromJson(Map<String, dynamic> json) =>
    PaginationData(
      currentPage: (json['current_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalItems: (json['total_items'] as num).toInt(),
      itemsPerPage: (json['items_per_page'] as num).toInt(),
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
    );

Map<String, dynamic> _$PaginationDataToJson(PaginationData instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'total_items': instance.totalItems,
      'items_per_page': instance.itemsPerPage,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };

TipDetailResponse _$TipDetailResponseFromJson(Map<String, dynamic> json) =>
    TipDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TipModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TipDetailResponseToJson(TipDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
