import '../models/comment.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class CommentService {
  static Future<Comment> postComment({
    required String postId,
    required String content,
    required User user,
    String? token,
    Comment? replyingTo,
  }) async {
    final response = await ApiService.post(
      'posts/$postId/comments',
      {
        'content': content.trim(),
        'userId': user.id,
        if (replyingTo != null) 'replyTo': replyingTo.id,
      },
      (json) => Comment.fromJson(json),
      token: token,
    );
    return response;
  }
}
