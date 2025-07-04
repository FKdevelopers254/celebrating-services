import '../models/comment.dart';
import '../models/like.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../models/post.dart';

class FeedService {
  static Future<List<Post>> getFeed({required String token}) async {
    final response = await ApiService.fetchList(
      'posts/feed',
      (json) => Post.fromJson(json),
      token: token,
    );
    return response;
  }
}
