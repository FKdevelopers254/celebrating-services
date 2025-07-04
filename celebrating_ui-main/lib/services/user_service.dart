import '../services/api_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class UserService {
  static Future<String> login(String username, String password) async {
    final response = await ApiService.post(
        'auth/login',
        {
      'username': username,
      'password': password,
        },
        (json) => json['token'] as String);
    return response;
  }

  static Future<User> register(User user) async {
    final response = await ApiService.post(
        'auth/register', user.toJson(), (json) => User.fromJson(json));
    return response;
  }

  static Future<User> fetchUser(String userId, {required String token}) async {
    final response = await ApiService.fetchOne(
      'users/$userId',
      (json) => User.fromJson(json),
      token: token,
    );
    return response;
  }
}
