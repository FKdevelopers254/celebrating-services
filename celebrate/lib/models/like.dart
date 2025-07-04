class Like {
  final String? id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  // Additional fields for UI display
  final String? userName;
  final String? userProfileImage;

  Like({
    this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    this.userName,
    this.userProfileImage,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (userProfileImage != null) 'userProfileImage': userProfileImage,
    };
  }
}
