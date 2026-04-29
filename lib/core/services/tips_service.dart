import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_config.dart';
import '../network/api_client.dart';
import '../model/tip_model.dart';
import 'auth_storage.dart';

class TipsService {
  // Singleton pattern
  static final TipsService _instance = TipsService._internal();
  factory TipsService() => _instance;
  TipsService._internal();

  final _apiClient = ApiClient();
  final _authStorage = AuthStorage();
  String? _deviceId;

  static const String _bookmarkedIdsKey = 'bookmarked_tip_ids';

  Future<Set<int>> _getLocalBookmarkIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_bookmarkedIdsKey) ?? [];
    return ids.map((e) => int.tryParse(e) ?? -1).where((e) => e >= 0).toSet();
  }

  Future<void> _setLocalBookmark(int tipId, bool isBookmarked) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_bookmarkedIdsKey) ?? []).toSet();
    if (isBookmarked) {
      ids.add(tipId.toString());
    } else {
      ids.remove(tipId.toString());
    }
    await prefs.setStringList(_bookmarkedIdsKey, ids.toList());
  }

  /// Get or generate device ID for guest mode
  // ignore: unused_element
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else {
        // Fallback for other platforms
        _deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('❌ Error getting device ID: $e');
      // Generate random fallback ID
      _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return _deviceId!;
  }

  /// Check if user is logged in
  Future<bool> _isLoggedIn() async {
    return await _authStorage.isLoggedIn();
  }

  TipsListResponse _parseTipsListResponse(
    dynamic rawResponse, {
    String fallbackMessage = 'Tips berhasil diambil',
  }) {
    if (rawResponse is! Map<String, dynamic>) {
      throw const FormatException('Invalid tips response format');
    }

    final normalized = _normalizeTipsListResponse(
      rawResponse,
      fallbackMessage: fallbackMessage,
    );

    return TipsListResponse.fromJson(normalized);
  }

  Map<String, dynamic> _normalizeTipsListResponse(
    Map<String, dynamic> root, {
    required String fallbackMessage,
  }) {
    final success = root['success'] is bool ? root['success'] as bool : true;
    final message = root['message']?.toString() ?? fallbackMessage;

    final rawData = root['data'];
    if (rawData is List) {
      return {
        'success': success,
        'message': message,
        'data': {
          'tips': rawData,
          'pagination': _buildDefaultPagination(rawData.length),
        },
      };
    }

    if (rawData is! Map<String, dynamic>) {
      return {
        'success': success,
        'message': message,
        'data': {
          'tips': const <dynamic>[],
          'pagination': _buildDefaultPagination(0),
        },
      };
    }

    final tips = _extractTipsList(rawData);
    final pagination = _extractPagination(rawData, tips.length);

    return {
      'success': success,
      'message': message,
      'data': {'tips': tips, 'pagination': pagination},
    };
  }

  List<dynamic> _extractTipsList(Map<String, dynamic> data) {
    const candidates = <String>[
      'tips',
      'items',
      'templates',
      'results',
      'rows',
      'list',
      'data',
    ];

    for (final key in candidates) {
      final value = data[key];
      if (value is List) {
        return value;
      }

      final fromStatusBuckets = _extractListFromStatusBuckets(value);
      if (fromStatusBuckets.isNotEmpty) {
        return fromStatusBuckets;
      }
    }

    for (final key in candidates) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        for (final nestedKey in candidates) {
          final nestedValue = value[nestedKey];
          if (nestedValue is List) {
            return nestedValue;
          }
        }

        final fromStatusBuckets = _extractListFromStatusBuckets(value);
        if (fromStatusBuckets.isNotEmpty) {
          return fromStatusBuckets;
        }
      }
    }

    final fromRootStatusBuckets = _extractListFromStatusBuckets(data);
    if (fromRootStatusBuckets.isNotEmpty) {
      return fromRootStatusBuckets;
    }

    return const <dynamic>[];
  }

  List<dynamic> _extractListFromStatusBuckets(dynamic value) {
    if (value is! Map) {
      return const <dynamic>[];
    }

    final combined = <dynamic>[];
    var hasBucketList = false;

    value.forEach((_, bucketValue) {
      if (bucketValue is List) {
        hasBucketList = true;
        combined.addAll(bucketValue);
      }
    });

    if (!hasBucketList) {
      return const <dynamic>[];
    }

    return combined;
  }

  Map<String, dynamic> _extractPagination(
    Map<String, dynamic> data,
    int itemCount,
  ) {
    final rawPagination = data['pagination'];
    if (rawPagination is Map<String, dynamic>) {
      final currentPage = _toInt(
        rawPagination['current_page'],
        fallback: _toInt(data['current_page'], fallback: 1),
      );
      final totalPages = _toInt(
        rawPagination['total_pages'],
        fallback: _toInt(data['last_page'], fallback: 1),
      );
      final totalItems = _toInt(
        rawPagination['total_items'],
        fallback: _toInt(data['total'], fallback: itemCount),
      );
      final itemsPerPage = _toInt(
        rawPagination['items_per_page'],
        fallback: _toInt(
          data['per_page'],
          fallback: itemCount == 0 ? 10 : itemCount,
        ),
      );

      final hasNext = _toBool(
        rawPagination['has_next'],
        fallback: currentPage < totalPages,
      );
      final hasPrev = _toBool(
        rawPagination['has_prev'],
        fallback: currentPage > 1,
      );

      return {
        'current_page': currentPage,
        'total_pages': totalPages,
        'total_items': totalItems,
        'items_per_page': itemsPerPage,
        'has_next': hasNext,
        'has_prev': hasPrev,
      };
    }

    final currentPage = _toInt(data['current_page'], fallback: 1);
    final totalPages = _toInt(
      data['total_pages'],
      fallback: _toInt(data['last_page'], fallback: 1),
    );
    final totalItems = _toInt(
      data['total_items'],
      fallback: _toInt(data['total'], fallback: itemCount),
    );
    final itemsPerPage = _toInt(
      data['items_per_page'],
      fallback: _toInt(
        data['per_page'],
        fallback: itemCount == 0 ? 10 : itemCount,
      ),
    );

    final hasNext = _toBool(
      data['has_next'],
      fallback: data['next_page_url'] != null ? true : currentPage < totalPages,
    );
    final hasPrev = _toBool(
      data['has_prev'],
      fallback: data['prev_page_url'] != null ? true : currentPage > 1,
    );

    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  Map<String, dynamic> _buildDefaultPagination(int itemCount) {
    return {
      'current_page': 1,
      'total_pages': 1,
      'total_items': itemCount,
      'items_per_page': itemCount == 0 ? 10 : itemCount,
      'has_next': false,
      'has_prev': false,
    };
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return fallback;
  }

  /// Get all tips.
  /// Uses `/tips` when authenticated and `/public/tips` for guest users.
  ///
  /// Query parameters:
  /// - [page]: Page number (default: 1)
  /// - [limit]: Items per page (default: 10, max: 50)
  /// - [search]: Search by title/description
  /// - [brand]: Filter by brand (comma-separated)
  /// - [difficulty]: Filter by difficulty (comma-separated)
  /// - [ridingStyle]: Filter by riding style
  /// - [tags]: Filter by tags (comma-separated)
  /// - [hashtags]: Filter by hashtags (comma-separated)
  /// - [sortBy]: Sort by (latest, popular, rating, relevance)
  /// - [userId]: Filter by user ID
  Future<TipsListResponse> getAllTips({
    int page = 1,
    int limit = 10,
    String? search,
    String? brand,
    String? difficulty,
    String? ridingStyle,
    String? tags,
    String? hashtags,
    String? sortBy,
    int? userId,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING TIPS FROM API');

      final isLoggedIn = await _isLoggedIn();
      final endpointPath = isLoggedIn ? ApiConfig.tips : ApiConfig.tipsPublic;
      print(
        '🔐 Mode: ${isLoggedIn ? 'authenticated (/tips)' : 'public (/public/tips)'}',
      );

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (brand != null && brand.isNotEmpty) {
        queryParams['brand'] = brand;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }
      if (ridingStyle != null && ridingStyle.isNotEmpty) {
        queryParams['riding_style'] = ridingStyle;
      }
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }
      if (hashtags != null && hashtags.isNotEmpty) {
        queryParams['hashtags'] = hashtags;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      if (userId != null) {
        queryParams['user_id'] = userId.toString();
      }

      // Build relative endpoint with query parameters
      final endpoint = Uri(
        path: endpointPath,
        queryParameters: queryParams,
      ).toString();

      print('📍 Endpoint: $endpoint');

      final response = await _apiClient
          .get(endpoint)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          final data = jsonData['data'];
          if (data is Map<String, dynamic>) {
            print('🧩 Response data keys: ${data.keys.join(', ')}');
          }
        }

        final parsedResponse = _parseTipsListResponse(jsonData);

        if (isLoggedIn && parsedResponse.data.tips.isEmpty && userId == null) {
          final fallbackUserId = await _authStorage.getUserId();
          if (fallbackUserId != null) {
            final fallbackParams = Map<String, String>.from(queryParams)
              ..['user_id'] = fallbackUserId.toString();
            final fallbackEndpoint = Uri(
              path: endpointPath,
              queryParameters: fallbackParams,
            ).toString();
            final fallbackResponse = await _apiClient
                .get(fallbackEndpoint)
                .timeout(ApiConfig.connectTimeout);
            if (fallbackResponse.statusCode == 200) {
              final fallbackParsed = _parseTipsListResponse(
                json.decode(fallbackResponse.body),
              );
              if (fallbackParsed.data.tips.isNotEmpty) {
                print(
                  '🔁 Applied getAllTips fallback: loaded tips by '
                  'user_id=$fallbackUserId '
                  '(${fallbackParsed.data.tips.length} items)',
                );
                return fallbackParsed;
              }
            }
          }
        }

        print(
          '✅ Tips loaded successfully (${parsedResponse.data.tips.length} items)',
        );
        return parsedResponse;
      } else {
        print('❌ Failed to load tips: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        throw Exception('Failed to load tips: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching tips: $e');
      rethrow;
    }
  }

  /// Get authenticated user's tips (includes all statuses)
  Future<TipsListResponse> getMyTips({
    int page = 1,
    int limit = 10,
    String? search,
    int? userId,
  }) async {
    if (!await _isLoggedIn()) {
      throw Exception('User must be logged in to access their tips');
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING MY TIPS');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (userId != null) {
        queryParams['user_id'] = userId.toString();
      }

      final endpoint = Uri(
        path: ApiConfig.tips,
        queryParameters: queryParams,
      ).toString();

      final response = await _apiClient
          .get(endpoint)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          final data = jsonData['data'];
          if (data is Map<String, dynamic>) {
            print('🧩 My tips response keys: ${data.keys.join(', ')}');
          }
        }
        var parsedResponse = _parseTipsListResponse(
          jsonData,
          fallbackMessage: 'Tips saya berhasil diambil',
        );

        if (parsedResponse.data.tips.isEmpty && userId == null) {
          final fallbackUserId = await _authStorage.getUserId();
          if (fallbackUserId != null) {
            final fallbackQueryParams = <String, String>{
              'page': page.toString(),
              'limit': limit.toString(),
              'user_id': fallbackUserId.toString(),
            };

            if (search != null && search.isNotEmpty) {
              fallbackQueryParams['search'] = search;
            }

            final fallbackEndpoint = Uri(
              path: ApiConfig.tips,
              queryParameters: fallbackQueryParams,
            ).toString();

            final fallbackResponse = await _apiClient
                .get(fallbackEndpoint)
                .timeout(ApiConfig.connectTimeout);

            if (fallbackResponse.statusCode == 200) {
              parsedResponse = _parseTipsListResponse(
                json.decode(fallbackResponse.body),
                fallbackMessage: 'Tips saya berhasil diambil',
              );

              if (parsedResponse.data.tips.isNotEmpty) {
                print(
                  '🔁 Applied getMyTips fallback: loaded tips by '
                  'user_id=$fallbackUserId '
                  '(${parsedResponse.data.tips.length} items)',
                );
              }
            }
          }
        }

        print(
          '✅ My tips loaded successfully '
          '(${parsedResponse.data.tips.length} items)',
        );
        return parsedResponse;
      } else {
        throw Exception('Failed to load my tips: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching my tips: $e');
      rethrow;
    }
  }

  /// Get tips bookmarked/saved by the authenticated user
  Future<List<TipModel>> getSavedTips({int limit = 50}) async {
    if (!await _isLoggedIn()) {
      throw Exception('User must be logged in to access saved tips');
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING SAVED TIPS');

      final savedIds = await _getLocalBookmarkIds();
      print('📋 Local bookmarked IDs: $savedIds');

      if (savedIds.isEmpty) {
        print('✅ No saved tips (local cache empty)');
        return [];
      }

      // Fetch each saved tip by ID (detail endpoint returns correct is_bookmarked)
      final futures = savedIds.map((id) async {
        try {
          final detail = await getTipById(id);
          // Sync local state from server
          await _setLocalBookmark(id, detail.data.isBookmarked);
          return detail.data.isBookmarked ? detail.data : null;
        } catch (_) {
          return null;
        }
      });

      final results = await Future.wait(futures);
      final saved = results.whereType<TipModel>().toList();
      print('✅ Saved tips loaded: ${saved.length} items');
      return saved;
    } catch (e) {
      print('❌ Error fetching saved tips: $e');
      rethrow;
    }
  }

  /// Get tip detail by ID (public endpoint)
  Future<TipDetailResponse> getTipById(int id) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 FETCHING TIP DETAIL (ID: $id)');

      final isLoggedIn = await _isLoggedIn();

      // Try authenticated endpoint first (supports all statuses including pending_review)
      if (isLoggedIn) {
        final authEndpoint = '${ApiConfig.tips}/$id';
        final authResponse = await _apiClient
            .get(authEndpoint)
            .timeout(ApiConfig.connectTimeout);

        print('📥 Response status: ${authResponse.statusCode}');

        if (authResponse.statusCode == 200) {
          final jsonData = json.decode(authResponse.body);
          print('✅ Tip detail loaded successfully');
          return TipDetailResponse.fromJson(jsonData);
        } else if (authResponse.statusCode == 404) {
          throw Exception('Tip not found');
        } else {
          throw Exception(
            'Failed to load tip detail: ${authResponse.statusCode}',
          );
        }
      }

      // Not logged in — fallback to public endpoint
      final endpoint = '${ApiConfig.tipsPublic}/$id';
      final response = await _apiClient
          .get(endpoint)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status (public): ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Tip detail loaded successfully (public)');
        return TipDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Tip not found');
      } else {
        throw Exception('Failed to load tip detail: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching tip detail: $e');
      rethrow;
    }
  }

  /// Create new tip (requires authentication)
  Future<TipCreateResponse> createTip(CreateTipRequest request) async {
    if (!await _isLoggedIn()) {
      throw Exception('User must be logged in to create tips');
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📝 CREATING NEW TIP');
      print('Title: ${request.title}');

      final requestJson = request.toJson();
      print('📦 Request Data:');
      print(json.encode(requestJson)); // Just for debug logging

      final response = await _apiClient
          .post(
            ApiConfig.tips,
            body: requestJson, // Pass object, not encoded string
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Tip created successfully');
        if (jsonData is Map<String, dynamic>) {
          return TipCreateResponse.fromJson(jsonData);
        }
        return TipCreateResponse(
          success: true,
          message: 'Tips berhasil dibuat',
        );
      } else {
        print('❌ Failed to create tip: ${response.statusCode}');
        print('📄 Response: ${response.body}');

        String errorMessage = 'Gagal membuat tips: ${response.statusCode}';

        // Parse error response agar pesan validasi backend tetap terbaca di UI
        try {
          final dynamic errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic>) {
            final backendMessage = errorData['message']?.toString();
            final backendErrors = errorData['errors'];

            if (backendErrors is Map && backendErrors.isNotEmpty) {
              final details = backendErrors.entries
                  .where(
                    (entry) => entry.value is List && entry.value.isNotEmpty,
                  )
                  .map((entry) => (entry.value as List).first.toString())
                  .join(' ')
                  .trim();

              if (details.isNotEmpty) {
                errorMessage = details;
              } else if (backendMessage != null && backendMessage.isNotEmpty) {
                errorMessage = backendMessage;
              }
            } else if (backendMessage != null && backendMessage.isNotEmpty) {
              errorMessage = backendMessage;
            }
          }
        } catch (_) {
          // Keep default message if response body is not JSON
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error creating tip: $e');
      rethrow;
    }
  }

  /// Update tip (requires authentication and ownership)
  Future<TipDetailResponse> updateTip(int id, CreateTipRequest request) async {
    if (!await _isLoggedIn()) {
      throw Exception('User must be logged in to update tips');
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✏️ UPDATING TIP (ID: $id)');

      final endpoint = '${ApiConfig.tips}/$id';
      final response = await _apiClient
          .put(
            endpoint,
            body: request.toJson(),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Tip updated successfully');
        return TipDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to update this tip');
      } else if (response.statusCode == 404) {
        throw Exception('Tip not found');
      } else {
        throw Exception('Failed to update tip: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating tip: $e');
      rethrow;
    }
  }

  /// Delete tip (requires authentication and ownership)
  Future<void> deleteTip(int id) async {
    if (!await _isLoggedIn()) {
      throw Exception('User must be logged in to delete tips');
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🗑️ DELETING TIP (ID: $id)');

      final endpoint = '${ApiConfig.tips}/$id';
      final response = await _apiClient
          .delete(endpoint)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Tip deleted successfully');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to delete this tip');
      } else if (response.statusCode == 404) {
        throw Exception('Tip not found');
      } else {
        throw Exception('Failed to delete tip: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting tip: $e');
      rethrow;
    }
  }

  /// Like or unlike a tip (supports guest mode)
  Future<Map<String, dynamic>> toggleLike(int id, bool isLike) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❤️ ${isLike ? "LIKING" : "UNLIKING"} TIP (ID: $id)');

      final endpoint = '${ApiConfig.tips}/$id/like';
      final request = TipActionRequest(action: isLike ? 'like' : 'unlike');

      final response = await _apiClient
          .post(
            endpoint,
            body: request.toJson(),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Like toggled successfully');
        print('📊 Like result data: ${jsonData['data']}');
        return (jsonData['data'] as Map<String, dynamic>?) ?? {};
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error toggling like: $e');
      rethrow;
    }
  }

  /// Bookmark or unbookmark a tip (supports guest mode)
  Future<Map<String, dynamic>> toggleBookmark(int id, bool isBookmark) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 ${isBookmark ? "BOOKMARKING" : "UNBOOKMARKING"} TIP (ID: $id)');

      final endpoint = '${ApiConfig.tips}/$id/bookmark';
      final request = TipActionRequest(
        action: isBookmark ? 'bookmark' : 'unbookmark',
      );

      final response = await _apiClient
          .post(
            endpoint,
            body: request.toJson(),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Bookmark toggled successfully');
        print('📊 Bookmark result data: ${jsonData['data']}');
        final data = (jsonData['data'] as Map<String, dynamic>?) ?? {};
        final isBookmarked = (data['is_bookmarked'] as bool?) ?? isBookmark;
        // Persist to local cache so getSavedTips can use it
        await _setLocalBookmark(id, isBookmarked);
        return data;
      } else {
        throw Exception('Failed to toggle bookmark: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error toggling bookmark: $e');
      rethrow;
    }
  }

  /// Track tip share (supports guest mode)
  Future<Map<String, dynamic>> shareTip(int id, String platform) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔗 TRACKING TIP SHARE (ID: $id, Platform: $platform)');

      final endpoint = '${ApiConfig.tips}/$id/share';
      final request = TipShareRequest(platform: platform);

      final response = await _apiClient
          .post(
            endpoint,
            body: request.toJson(),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Share tracked successfully');
        return jsonData['data'];
      } else {
        throw Exception('Failed to track share: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error tracking share: $e');
      rethrow;
    }
  }

  /// Rate a tip (requires authentication)
  Future<Map<String, dynamic>> rateTip(int id, int rating) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('⭐ RATING TIP (ID: $id, Rating: $rating)');

      final endpoint = '${ApiConfig.tips}/$id/rate';

      final response = await _apiClient
          .post(
            endpoint,
            body: {'rating': rating},
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Rating submitted successfully');
        return jsonData['data'];
      } else {
        throw Exception('Failed to rate tip: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error rating tip: $e');
      rethrow;
    }
  }

  /// Use tip as template to create service schedule (requires authentication)
  Future<Map<String, dynamic>> useAsTemplate(
    int id,
    TipUseTemplateRequest request,
  ) async {
    if (!await _isLoggedIn()) {
      throw Exception(
        'User must be logged in to create schedule from template',
      );
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📅 CREATING SCHEDULE FROM TIP TEMPLATE (ID: $id)');

      final endpoint = '${ApiConfig.tips}/$id/use-template';
      final response = await _apiClient
          .post(
            endpoint,
            body: request.toJson(),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Schedule created from template successfully');
        return jsonData['data'];
      } else {
        print('❌ Failed to create schedule: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        throw Exception(
          'Failed to create schedule from template: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error creating schedule from template: $e');
      rethrow;
    }
  }
}
