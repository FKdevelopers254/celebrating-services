// models/post.dart
import './user.dart';
import 'package:flutter/material.dart';
import 'comment.dart';
import 'like.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String celebrationType;
  final List<String> mediaUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final int? likesCount;
  final int? commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.celebrationType,
    required this.mediaUrls,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.likesCount,
    this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    celebrationType: json['celebrationType'] ?? '',
    mediaUrls:
        (json['mediaUrls'] ?? []) is List
            ? List<String>.from(json['mediaUrls'] ?? [])
            : [],
    createdAt:
        json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'])
                : null),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : (json['updated_at'] != null
                ? DateTime.tryParse(json['updated_at'])
                : null),
    status: json['status']?.toString(),
    likesCount: json['likesCount'] ?? '',
    commentsCount: json['commentsCount'] ?? '',
  );
}

class MediaItem {
  final String url;
  final String type; // 'image' or 'video'

  MediaItem({required this.url, required this.type});

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      MediaItem(url: json['url'] as String, type: json['type'] as String);
}
