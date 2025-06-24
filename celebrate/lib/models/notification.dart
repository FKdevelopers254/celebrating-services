class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? targetId;
  final String? targetType;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.targetId,
    this.targetType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'targetId': targetId,
      'targetType': targetType,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Notification types
  static const String postLike = 'like';
  static const String postComment = 'comment';
  static const String newFollower = 'follow';
  static const String mention = 'mention';
  static const String directMessage = 'message';
  static const String rating = 'rating';
  static const String systemNotice = 'system';

  // Helper methods
  bool get isPostRelated => type == postLike || type == postComment;
  bool get isUserRelated => type == newFollower || type == mention;
  bool get isDirectMessage => type == directMessage;
  bool get isRating => type == rating;
  bool get isSystem => type == systemNotice;

  String get notificationIcon {
    switch (type) {
      case postLike:
        return 'assets/icons/like.png';
      case postComment:
        return 'assets/icons/comment.png';
      case newFollower:
        return 'assets/icons/follow.png';
      case mention:
        return 'assets/icons/mention.png';
      case directMessage:
        return 'assets/icons/message.png';
      case rating:
        return 'assets/icons/star.png';
      case systemNotice:
        return 'assets/icons/system.png';
      default:
        return 'assets/icons/notification.png';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? targetId,
    String? targetType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          message == other.message &&
          type == other.type &&
          isRead == other.isRead;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      message.hashCode ^
      type.hashCode ^
      isRead.hashCode;
}
