import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static Future<List<Post>> getUserPosts(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8083/api/posts/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user posts');
    }
  }
}
