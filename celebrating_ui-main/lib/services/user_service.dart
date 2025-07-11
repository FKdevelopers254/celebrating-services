import '../services/api_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'package:flutter/material.dart';

class UserService {
  static Future<String> oldlogin(String username, String password) async {
    final response = await ApiService.post('auth/login', {
      'username': username,
      'password': password,
    }, (json) => json['token'] as String);
    return response;
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await ApiService.post('auth/login', {
        'username': username,
        'password': password,
      }, (json) => json);
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  static Future<Map<String, dynamic>> register(User user) async {
    final response = await ApiService.post(
      'auth/register',
      user.toJson(),
      (json) => json,
        );
    return response;
  }

  static Future<User> fetchUser(
    String userId, {
    required String token,
    required BuildContext context,
  }) async {
    final response = await ApiService.fetchOne(
      'users/$userId',
      (json) => User.fromJson(json),
      token: token,
      context: context,
    );
    return response;
  }

  static Future<User> fetchUserByUsername(
    String username, {
    required String token,
    required BuildContext context,
  }) async {
    final response = await ApiService.fetchOne(
      'users/username/$username',
      (json) => User.fromJson(json),
      token: token,
      context: context,
    );
    return response;
  }
}
