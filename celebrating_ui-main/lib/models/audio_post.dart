import '../models/user.dart';

class AudioMedia {
  final String url;
  final String type; // e.g. 'mp3', 'aac', etc.
  final Duration? duration;

  AudioMedia({required this.url, required this.type, this.duration});

  factory AudioMedia.fromJson(Map<String, dynamic> json) => AudioMedia(
        url: json['url'] as String,
        type: json['type'] as String,
        duration: json['duration'] != null
            ? Duration(seconds: json['duration'])
            : null,
      );
}

class AudioPost {
  final String id;
  final String title;
  final String description;
  final AudioMedia audio;
  final String thumbnailUrl;
  final User from;
  final DateTime timestamp;
  final int initialRating;
  final List<String> categories;
  final List<String> hashtags;
  final List likes;
  final List comments;
  final String location;

  AudioPost({
    required this.id,
    required this.title,
    required this.description,
    required this.audio,
    required this.thumbnailUrl,
    required this.from,
    required this.timestamp,
    this.initialRating = 0,
    required this.categories,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.location,
  });

  factory AudioPost.fromJson(Map<String, dynamic> json) => AudioPost(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        audio: AudioMedia.fromJson(json['audio'] as Map<String, dynamic>),
        thumbnailUrl: json['thumbnailUrl'] as String,
        from: User.fromJson(json['from'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
        initialRating: json['initialRating'] as int? ?? 0,
        categories: (json['categories'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        hashtags: (json['hashtags'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        likes: json['likes'] as List? ?? [],
        comments: json['comments'] as List? ?? [],
        location: json['location'] as String,
      );
}
