import './user.dart';

import 'comment.dart';
import 'like.dart';

class Flick {
  final String id;
  final String thumbnail;
  final String flickUrl;
  final String title;
  final User creator;
  final DateTime timestamp;
  final int views;
  final Duration duration;
  final List<Like> likes; // List of users who liked the post
  final List<Comment> comments;
  final List<String> categories;
  final List<String> hashtags;
  final String location;
  final Map<String, int> userRatings; // userId -> rating

  Flick({
    required this.likes,
    required this.comments,
    required this.categories,
    required this.timestamp,
    required this.hashtags,
    required this.id,
    required this.thumbnail,
    required this.flickUrl,
    required this.title,
    required this.creator,
    required this.views,
    required this.duration,
    required this.location,
    this.userRatings = const {},
  });

  factory Flick.fromJson(Map<String, dynamic> json) => Flick(
        id: json['id'] as String,
        title: json['title'] as String,
        thumbnail: json['thumbnail'] as String,
        flickUrl: json['flickUrl'] as String,
        creator: User.fromJson(json['creator'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
        views: json['views'] as int,
        duration: Duration(seconds: json['duration'] as int),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        hashtags: (json['hashtags'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        location: json['location'] as String,
        likes: (json['likes'] as List<dynamic>)
            .map((e) => Like.fromJson(e as Map<String, dynamic>))
            .toList(),
        comments: (json['comments'] as List<dynamic>)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
        userRatings: json['userRatings'] != null
            ? Map<String, int>.from(json['userRatings'])
            : {},
      );
}
