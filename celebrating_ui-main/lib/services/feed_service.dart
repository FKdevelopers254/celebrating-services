import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../models/like.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../models/post.dart';

class FeedService {
  static Future<List<Post>> getFeed({required String token}) async {
    try {
      // Try via API Gateway
      return await ApiService.fetchList(
        'posts',
        (json) => Post.fromJson(json),
        token: token,
      );
    } catch (e) {
      // If unauthorized, fallback to post-service directly (no token)
      if (e.toString().contains('401') || e.toString().contains('403')) {
        final response = await http.get(
          Uri.parse('http://localhost:8083/api/posts'),
          headers: {
            'Content-Type': 'application/json',
            // No Authorization header
          },
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          return data.map((e) => Post.fromJson(e)).toList();
        } else {
          throw Exception(
            'Failed to load posts from post-service: \\${response.statusCode} \\${response.body}',
          );
        }
      }
      rethrow;
    }
  }
}
