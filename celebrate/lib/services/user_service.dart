import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/celebrity_profile.dart';
import '../utils/constants.dart';
import '../AuthService.dart';

class UserService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get user by username
  Future<User> getUserByUsername(String username) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/username/$username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? bio,
    String? location,
    bool? isPrivate,
  }) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['fullName'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (location != null) updateData['location'] = location;
      if (isPrivate != null) updateData['isPrivate'] = isPrivate;

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/users/$userId/profile-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['profileImageUrl'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get all celebrities
  Future<List<User>> getAllCelebrities() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/celebrities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get celebrities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get celebrities: $e');
    }
  }

  // Search celebrities
  Future<List<User>> searchCelebrities(String query) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/celebrities/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search celebrities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search celebrities: $e');
    }
  }

  // Get celebrity profile
  Future<CelebrityProfile> getCelebrityProfile(String userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/celebrity-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return CelebrityProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to get celebrity profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get celebrity profile: $e');
    }
  }

  // Update celebrity profile
  Future<CelebrityProfile> updateCelebrityProfile({
    required String userId,
    String? stageName,
    List<String>? professions,
    List<String>? majorAchievements,
    List<String>? notableProjects,
    List<String>? collaborations,
    String? netWorth,
  }) async {
    try {
      final token = await AuthService.getToken();

      final Map<String, dynamic> updateData = {};
      if (stageName != null) updateData['stageName'] = stageName;
      if (professions != null) updateData['professions'] = professions;
      if (majorAchievements != null)
        updateData['majorAchievements'] = majorAchievements;
      if (notableProjects != null)
        updateData['notableProjects'] = notableProjects;
      if (collaborations != null) updateData['collaborations'] = collaborations;
      if (netWorth != null) updateData['netWorth'] = netWorth;

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/celebrity-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return CelebrityProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to update celebrity profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update celebrity profile: $e');
    }
  }

  // Get user's posts
  Future<List<UserPost>> getUserPosts() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/search?q=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Follow user
  Future<bool> followUser(int userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$userId/follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to follow user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  // Unfollow user
  Future<bool> unfollowUser(int userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId/follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to unfollow user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // Get user's followers
  Future<List<User>> getFollowers(int userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/followers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get followers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  // Get user's following
  Future<List<User>> getFollowing(int userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/following'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get following: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }
}
