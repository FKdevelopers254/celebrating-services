import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/flick.dart';
import '../models/post.dart';
import '../models/audio_post.dart';
import '../services/api_service.dart';

class SearchService {
  static Future<List<User>> searchUsers(
    String query, {
    required String token,
  }) async {
    try {
      return await ApiService.fetchList(
        'users/search?query=$query',
        (json) => User.fromJson(json),
        token: token,
      );
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        final response = await http.get(
          Uri.parse(
            'http://localhost:8082/api/users/celebrities/search?query=$query',
          ),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          return data.map((e) => User.fromJson(e)).toList();
        } else {
          throw Exception(
            'Failed to load users from user-service: \\${response.statusCode} \\${response.body}',
          );
        }
      }
      rethrow;
    }
  }

  static Future<List<Flick>> searchFlicks(
    String query, {
    required String token,
  }) async {
    try {
      return await ApiService.fetchList(
        'flicks/search?query=$query',
        (json) => Flick.fromJson(json),
        token: token,
      );
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        final response = await http.get(
          Uri.parse('http://localhost:8085/api/flicks/search?query=$query'),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          return data.map((e) => Flick.fromJson(e)).toList();
        } else {
          throw Exception(
            'Failed to load flicks from flick-service: \\${response.statusCode} \\${response.body}',
          );
        }
      }
      rethrow;
    }
  }

  static Future<List<Post>> searchPostsByLocation(
    String locationQuery, {
    required String token,
  }) async {
    try {
      return await ApiService.fetchList(
        'posts/search?location=$locationQuery',
        (json) => Post.fromJson(json),
        token: token,
      );
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        final response = await http.get(
          Uri.parse(
            'http://localhost:8083/api/posts/search?location=$locationQuery',
          ),
          headers: {'Content-Type': 'application/json'},
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

  static Future<List<AudioPost>> searchAudio(
    String query, {
    required String token,
  }) async {
    try {
      return await ApiService.fetchList(
        'audio/search?query=$query',
        (json) => AudioPost.fromJson(json),
        token: token,
      );
    } catch (e) {
      // If you have a dedicated audio microservice, add fallback here as well
      rethrow;
    }
  }
}
