enum PostStatus { ACTIVE, DELETED, HIDDEN, REPORTED }

enum CelebrationType {
  BIRTHDAY,
  ANNIVERSARY,
  ACHIEVEMENT,
  AWARD,
  MILESTONE,
  OTHER
}

class Post {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final CelebrationType celebrationType;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PostStatus status;
  final int likesCount;
  final int commentsCount;
  final bool isPrivate;

  final String? authorName;
  final String? authorProfileImage;
  final bool? isLikedByCurrentUser;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.celebrationType,
    this.mediaUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.status = PostStatus.ACTIVE,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPrivate = false,
    this.authorName,
    this.authorProfileImage,
    this.isLikedByCurrentUser,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      celebrationType: CelebrationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['celebrationType'],
        orElse: () => CelebrationType.OTHER,
      ),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: PostStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PostStatus.ACTIVE,
      ),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isPrivate: json['isPrivate'] ?? false,
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      isLikedByCurrentUser: json['isLikedByCurrentUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'celebrationType': celebrationType.toString().split('.').last,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isPrivate': isPrivate,
      if (authorName != null) 'authorName': authorName,
      if (authorProfileImage != null) 'authorProfileImage': authorProfileImage,
      if (isLikedByCurrentUser != null)
        'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }
}
