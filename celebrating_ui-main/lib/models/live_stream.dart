import 'stream_category.dart';
import 'user.dart';

class LiveStream {
  final String id;
  final String title;
  final String description;
  final User streamer;
  final String streamUrl;
  final String thumbnailUrl;
  final int viewerCount;
  final bool isLive;
  final DateTime startedAt;
  final List<StreamCategory> categories;
  final List<String> tags;
  final String language;
  final String location;

  LiveStream({
    required this.id,
    required this.title,
    required this.description,
    required this.streamer,
    required this.streamUrl,
    required this.thumbnailUrl,
    required this.viewerCount,
    required this.isLive,
    required this.startedAt,
    required this.categories,
    required this.tags,
    required this.language,
    required this.location,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) => LiveStream(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        streamer: User.fromJson(json['streamer'] as Map<String, dynamic>),
        streamUrl: json['streamUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        viewerCount: json['viewerCount'] as int,
        isLive: json['isLive'] as bool,
        startedAt: DateTime.parse(json['startedAt'] as String),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => StreamCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        language: json['language'] as String,
        location: json['location'] as String,
      );
}
