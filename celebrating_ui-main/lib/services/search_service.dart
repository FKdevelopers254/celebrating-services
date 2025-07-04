import '../models/user.dart';
import '../models/flick.dart';
import '../models/post.dart';
import '../models/audio_post.dart';
import '../services/api_service.dart';

class SearchService {
  static Future<List<User>> searchUsers(String query,
      {required String token}) async {
    final response = await ApiService.fetchList(
      'users/search?query=$query',
      (json) => User.fromJson(json),
      token: token,
    );
    return response;
  }

  static Future<List<Flick>> searchFlicks(String query,
      {required String token}) async {
    final response = await ApiService.fetchList(
      'flicks/search?query=$query',
      (json) => Flick.fromJson(json),
      token: token,
    );
    return response;
  }

  static Future<List<Post>> searchPostsByLocation(String locationQuery,
      {required String token}) async {
    final response = await ApiService.fetchList(
      'posts/search?location=$locationQuery',
      (json) => Post.fromJson(json),
      token: token,
    );
    return response;
  }

  static Future<List<AudioPost>> searchAudio(String query,
      {required String token}) async {
    final response = await ApiService.fetchList(
      'audio/search?query=$query',
      (json) => AudioPost.fromJson(json),
      token: token,
    );
    return response;
  }
}
