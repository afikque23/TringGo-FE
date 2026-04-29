import 'dart:convert';

import '../model/content_model.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  final _apiClient = ApiClient();

  static const String _publicContentsPath = '/public/contents';

  Future<List<ContentModel>> getPublishedContentsByType(String type) async {
    final endpoint = '$_publicContentsPath/$type';
    final response = await _apiClient
        .get(endpoint)
        .timeout(ApiConfig.connectTimeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load content ($type): ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final items = _extractContentItems(decoded, typeKey: type);

    final contents = <ContentModel>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        contents.add(ContentModel.fromJson(item));
      } else if (item is Map) {
        contents.add(ContentModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    contents.sort((a, b) {
      final byOrder = a.order.compareTo(b.order);
      if (byOrder != 0) return byOrder;
      final aUpdated = a.updatedAt ?? a.createdAt;
      final bUpdated = b.updatedAt ?? b.createdAt;
      if (aUpdated == null || bUpdated == null) return 0;
      return bUpdated.compareTo(aUpdated);
    });

    return contents;
  }

  Future<ContentModel?> getFirstPublishedContentByType(String type) async {
    final list = await getPublishedContentsByType(type);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<List<FaqItemModel>> getFaqItems() async {
    final contents = await getPublishedContentsByType('faq');
    if (contents.isEmpty) return const [];

    // Prefer the canonical FAQ slug if present (per backend docs)
    final preferred = contents.where((c) => c.slug == 'faq').toList();
    final ordered = preferred.isNotEmpty ? preferred : contents;

    final items = <FaqItemModel>[];
    for (final content in ordered) {
      final body = content.body;

      if (body is List) {
        for (final item in body) {
          final parsed = FaqItemModel.tryFromDynamic(item);
          if (parsed != null) items.add(parsed);
        }
        continue;
      }

      // Fallback: if body is map with "items" or similar
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        final rawItems = map['items'] ?? map['faq'] ?? map['data'];
        if (rawItems is List) {
          for (final item in rawItems) {
            final parsed = FaqItemModel.tryFromDynamic(item);
            if (parsed != null) items.add(parsed);
          }
        }
      }
    }

    return items;
  }

  Future<List<GuideSectionModel>> getGuideSections() async {
    final contents = await getPublishedContentsByType('guide');
    if (contents.isEmpty) return const [];

    final sections = <GuideSectionModel>[];

    for (final content in contents) {
      final body = content.body;

      // 1) Native guide format: [{title, topics:[{title, description}]}]
      final parsedNative = _parseGuideSectionsNative(body);
      if (parsedNative.isNotEmpty) {
        sections.addAll(parsedNative);
        continue;
      }

      // 2) Backend recommended format: [{section|title, content, items}]
      final docSections = DocumentSectionModel.parse(body);
      if (docSections.isEmpty) continue;
      sections.addAll(_convertDocumentSectionsToGuide(content, docSections));
    }

    return sections;
  }

  Future<List<DocumentSectionModel>> getDocumentSections(
    String type, {
    bool mergeAll = false,
  }) async {
    if (!mergeAll) {
      final content = await getFirstPublishedContentByType(type);
      if (content == null) return const [];
      return DocumentSectionModel.parse(content.body);
    }

    final contents = await getPublishedContentsByType(type);
    if (contents.isEmpty) return const [];

    final merged = <DocumentSectionModel>[];
    for (final content in contents) {
      final parsed = DocumentSectionModel.parse(content.body);
      if (parsed.isNotEmpty) merged.addAll(parsed);
    }
    return merged;
  }

  List<GuideSectionModel> _parseGuideSectionsNative(dynamic body) {
    if (body is List) {
      final sections = <GuideSectionModel>[];
      for (final item in body) {
        final section = GuideSectionModel.tryFromDynamic(item);
        if (section != null) sections.add(section);
      }
      return sections;
    }

    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final rawSections = map['sections'] ?? map['items'] ?? map['data'];
      if (rawSections is List) {
        final sections = <GuideSectionModel>[];
        for (final item in rawSections) {
          final section = GuideSectionModel.tryFromDynamic(item);
          if (section != null) sections.add(section);
        }
        return sections;
      }
    }

    return const <GuideSectionModel>[];
  }

  List<GuideSectionModel> _convertDocumentSectionsToGuide(
    ContentModel content,
    List<DocumentSectionModel> docSections,
  ) {
    final sections = <GuideSectionModel>[];

    for (final doc in docSections) {
      final sectionTitle = doc.title.isNotEmpty ? doc.title : content.title;

      final topics = <GuideTopicModel>[];

      if (doc.bullets.isNotEmpty) {
        for (final bullet in doc.bullets) {
          final pair = _splitTitleDesc(bullet);
          final title = pair.item1.trim();
          final description = pair.item2.trim();
          if (title.isEmpty && description.isEmpty) continue;
          topics.add(GuideTopicModel(title: title, description: description));
        }
      } else if (doc.paragraphs.isNotEmpty) {
        // Minimal fallback: represent paragraph(s) as a single topic.
        topics.add(
          GuideTopicModel(
            title: sectionTitle,
            description: doc.paragraphs.join('\n\n').trim(),
          ),
        );
      }

      if (sectionTitle.isEmpty || topics.isEmpty) continue;
      sections.add(GuideSectionModel(title: sectionTitle, topics: topics));
    }

    return sections;
  }

  ({String item1, String item2}) _splitTitleDesc(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return (item1: '', item2: '');

    for (final sep in const [' - ', ' – ', ' — ', ':', '•']) {
      final idx = text.indexOf(sep);
      if (idx <= 0) continue;
      final left = text.substring(0, idx).trim();
      final right = text.substring(idx + sep.length).trim();
      if (left.isNotEmpty && right.isNotEmpty) {
        return (item1: left, item2: right);
      }
    }

    return (item1: text, item2: '');
  }

  List<dynamic> _extractContentItems(dynamic decoded, {String? typeKey}) {
    if (decoded is Map) {
      final root = Map<String, dynamic>.from(decoded);
      final data = root['data'];

      if (data is List) return data;

      if (data is Map) {
        final dataMap = Map<String, dynamic>.from(data);

        // Some APIs group by type even on /{type} endpoints:
        // { data: { "faq": [ ... ] } }
        if (typeKey != null) {
          final byType = dataMap[typeKey];
          if (byType is List) return byType;
        }

        // Common REST shapes
        final candidates = <String>[
          'contents',
          'items',
          'results',
          'rows',
          'data',
        ];

        for (final key in candidates) {
          final value = dataMap[key];
          if (value is List) return value;
        }
      }

      // Some APIs might return list at root
      final contents = root['contents'];
      if (contents is List) return contents;

      // Another grouped shape at root:
      // { "faq": [ ... ] }
      if (typeKey != null) {
        final byType = root[typeKey];
        if (byType is List) return byType;
      }
    }

    if (decoded is List) {
      return decoded;
    }

    return const <dynamic>[];
  }
}
