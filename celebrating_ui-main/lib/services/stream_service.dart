import '../models/stream_category.dart';
import '../models/live_stream.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class StreamService {
  static Future<List<StreamCategory>> getCategories(
      {required String token}) async {
    final response = await ApiService.fetchList(
      'stream/categories',
      (json) => StreamCategory.fromJson(json),
      token: token,
    );
    return response;
  }

  static Future<List<LiveStream>> getStreams({required String token}) async {
    final response = await ApiService.fetchList(
      'streams',
      (json) => LiveStream.fromJson(json),
      token: token,
    );
    return response;
  }
}
