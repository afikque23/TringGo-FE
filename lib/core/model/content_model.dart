import 'dart:convert';

class ContentModel {
  final int id;
  final String title;
  final String slug;
  final String type;
  final dynamic body;
  final String status;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.body,
    required this.status,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    final rawBody = json['body'];
    dynamic decodedBody = rawBody;

    if (rawBody is String) {
      final trimmed = rawBody.trim();
      if (trimmed.isNotEmpty) {
        try {
          decodedBody = jsonDecode(trimmed);
        } catch (_) {
          decodedBody = rawBody;
        }
      }
    }

    return ContentModel(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      body: decodedBody,
      status: (json['status'] ?? '').toString(),
      order: _asInt(json['order']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

class FaqItemModel {
  final String question;
  final String answer;

  const FaqItemModel({required this.question, required this.answer});

  static FaqItemModel? tryFromDynamic(dynamic item) {
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final question = (map['question'] ?? map['q'] ?? map['title'] ?? '')
          .toString()
          .trim();
      final answer =
          (map['answer'] ?? map['a'] ?? map['content'] ?? map['body'] ?? '')
              .toString()
              .trim();
      if (question.isEmpty) return null;
      return FaqItemModel(question: question, answer: answer);
    }

    if (item is String) {
      final question = item.trim();
      if (question.isEmpty) return null;
      return FaqItemModel(question: question, answer: '');
    }

    return null;
  }
}

class GuideSectionModel {
  final String title;
  final List<GuideTopicModel> topics;

  const GuideSectionModel({required this.title, required this.topics});

  static GuideSectionModel? tryFromDynamic(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item);
    final title = (map['title'] ?? '').toString().trim();
    if (title.isEmpty) return null;

    final rawTopics = map['topics'];
    final topics = <GuideTopicModel>[];
    if (rawTopics is List) {
      for (final rawTopic in rawTopics) {
        final topic = GuideTopicModel.tryFromDynamic(rawTopic);
        if (topic != null) topics.add(topic);
      }
    }

    if (topics.isEmpty) return null;
    return GuideSectionModel(title: title, topics: topics);
  }
}

class GuideTopicModel {
  final String title;
  final String description;

  const GuideTopicModel({required this.title, required this.description});

  static GuideTopicModel? tryFromDynamic(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item);
    final title = (map['title'] ?? '').toString().trim();
    final description =
        (map['description'] ?? map['desc'] ?? map['content'] ?? '')
            .toString()
            .trim();
    if (title.isEmpty && description.isEmpty) return null;
    return GuideTopicModel(title: title, description: description);
  }
}

class DocumentSectionModel {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  const DocumentSectionModel({
    required this.title,
    required this.paragraphs,
    required this.bullets,
  });

  static List<DocumentSectionModel> parse(dynamic body) {
    if (body == null) return const [];

    final sections = <DocumentSectionModel>[];

    void addSection({
      required String title,
      List<String>? paragraphs,
      List<String>? bullets,
    }) {
      final normalizedTitle = title.trim();
      final normalizedParagraphs = (paragraphs ?? const <String>[])
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final normalizedBullets = (bullets ?? const <String>[])
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (normalizedTitle.isEmpty &&
          normalizedParagraphs.isEmpty &&
          normalizedBullets.isEmpty) {
        return;
      }

      sections.add(
        DocumentSectionModel(
          title: normalizedTitle,
          paragraphs: normalizedParagraphs,
          bullets: normalizedBullets,
        ),
      );
    }

    if (body is String) {
      addSection(title: '', paragraphs: [body]);
      return sections;
    }

    if (body is Map) {
      _parseSectionMap(body, addSection);
      return sections;
    }

    if (body is List) {
      for (final item in body) {
        if (item is String) {
          addSection(title: '', paragraphs: [item]);
          continue;
        }
        if (item is Map) {
          _parseSectionMap(item, addSection);
        }
      }
      return sections;
    }

    addSection(title: '', paragraphs: [body.toString()]);
    return sections;
  }

  static void _parseSectionMap(
    Map<dynamic, dynamic> raw,
    void Function({
      required String title,
      List<String>? paragraphs,
      List<String>? bullets,
    })
    addSection,
  ) {
    final map = Map<String, dynamic>.from(raw);

    final title = (map['title'] ?? map['section'] ?? map['heading'] ?? '')
        .toString();

    final paragraphs = <String>[];
    final bullets = <String>[];

    final content =
        map['content'] ??
        map['body'] ??
        map['text'] ??
        map['description'] ??
        map['desc'];

    if (content is String) {
      paragraphs.add(content);
    } else if (content is List) {
      for (final item in content) {
        if (item == null) continue;
        bullets.add(item.toString());
      }
    }

    final rawParagraphs = map['paragraphs'];
    if (rawParagraphs is List) {
      for (final item in rawParagraphs) {
        if (item == null) continue;
        paragraphs.add(item.toString());
      }
    }

    final rawBullets = map['bullets'] ?? map['items'] ?? map['points'];
    if (rawBullets is List) {
      for (final item in rawBullets) {
        if (item == null) continue;
        bullets.add(item.toString());
      }
    }

    addSection(title: title, paragraphs: paragraphs, bullets: bullets);
  }
}
