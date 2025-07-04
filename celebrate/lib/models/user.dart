class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String? bio;
  final String? location;
  final String? profileImageUrl;
  final bool isPrivate;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats? stats;
  final CelebrityProfile? celebrityProfile;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.bio,
    this.location,
    this.profileImageUrl,
    this.isPrivate = false,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.celebrityProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      bio: json['bio'],
      location: json['location'],
      profileImageUrl: json['profileImageUrl'],
      isPrivate: json['isPrivate'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      celebrityProfile: json['celebrityProfile'] != null
          ? CelebrityProfile.fromJson(json['celebrityProfile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'bio': bio,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'isPrivate': isPrivate,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (stats != null) 'stats': stats!.toJson(),
      if (celebrityProfile != null)
        'celebrityProfile': celebrityProfile!.toJson(),
    };
  }
}

class UserStats {
  final String userId;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final DateTime updatedAt;

  UserStats({
    required this.userId,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      postsCount: json['postsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserPost {
  final int id;
  final String title;
  final String content;
  final String celebrationType;
  final List<String> mediaUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  UserPost({
    required this.id,
    required this.title,
    required this.content,
    required this.celebrationType,
    required this.mediaUrls,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      celebrationType: json['celebrationType'],
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'celebrationType': celebrationType,
      'mediaUrls': mediaUrls,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
