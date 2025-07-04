import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/like.dart';
import '../utils/constants.dart';
import '../AuthService.dart';

class PostService {
  static const String baseUrl = ApiConstants.baseUrl;
  WebSocketChannel? _channel;

  // Create a new post
  Future<Post> createPost({
    required String title,
    required String content,
    required CelebrationType celebrationType,
    List<String> mediaUrls = const [],
    bool isPrivate = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      // If there are media URLs that are local paths, upload them first
      List<String> uploadedMediaUrls = [];
      for (String mediaUrl in mediaUrls) {
        if (mediaUrl.startsWith('file://') || !mediaUrl.startsWith('http')) {
          final uploadedUrl = await _uploadMedia(mediaUrl, token!);
          uploadedMediaUrls.add(uploadedUrl);
        } else {
          uploadedMediaUrls.add(mediaUrl);
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'content': content,
          'celebrationType': celebrationType.toString().split('.').last,
          'mediaUrls': uploadedMediaUrls,
          'isPrivate': isPrivate,
        }),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Upload media for a post
  Future<String> _uploadMedia(String mediaPath, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/posts/upload-media'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('media', mediaPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['mediaUrl'];
      } else {
        throw Exception('Failed to upload media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  // Get post by ID
  Future<Post> getPost(String id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Get user's posts
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get recent posts with pagination
  Future<List<Post>> getRecentPosts({int page = 0, int size = 20}) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get recent posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get recent posts: $e');
    }
  }

  // Get posts by celebration type
  Future<List<Post>> getPostsByCelebrationType(CelebrationType type) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/type/${type.toString().split('.').last}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Add comment to a post
  Future<Comment> addComment(String postId, String content) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Get post comments
  Future<List<Comment>> getPostComments(String postId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Like a post
  Future<Like> likePost(String postId) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 201) {
        return Like.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to like post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to unlike post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  // Get post likes
  Future<List<Like>> getPostLikes(String postId) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$postId/likes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Like.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get likes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get likes: $e');
    }
  }

  // Connect to WebSocket for real-time updates
  void connectToWebSocket(Function(Post) onPostReceived) async {
    final token = await AuthService.getToken();
    final wsUrl = baseUrl.replaceFirst('http', 'ws');

    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws/posts?token=$token'),
    );

    _channel!.stream.listen(
      (message) {
        final post = Post.fromJson(jsonDecode(message));
        onPostReceived(post);
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Try to reconnect after a delay
        Future.delayed(const Duration(seconds: 5), () {
          connectToWebSocket(onPostReceived);
        });
      },
      onDone: () {
        print('WebSocket connection closed');
        // Try to reconnect after a delay
        Future.delayed(const Duration(seconds: 5), () {
          connectToWebSocket(onPostReceived);
        });
      },
    );
  }

  // Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  // Get posts by hashtag
  Future<List<Post>> getPostsByHashtag(String hashtag) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/hashtag/$hashtag'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }
}
