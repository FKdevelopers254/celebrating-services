import '../models/audio_post.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AudioService {
  static Future<List<AudioPost>> fetchAudioPosts(
      {required String token}) async {
    final response = await ApiService.fetchList(
      'audio-posts',
      (json) => AudioPost.fromJson(json),
      token: token,
    );
    return response;
  }
}
