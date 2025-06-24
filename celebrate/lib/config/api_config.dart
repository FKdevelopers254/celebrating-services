import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // Base configuration
  static const bool useHttps = false; // Set to true for production
  static const String host = 'localhost'; // Change for production
  static const int gatewayPort = 8080; // API Gateway port

  static String get baseUrl =>
      '${useHttps ? 'https' : 'http'}://$host:$gatewayPort';

  // Auth Service (8081)
  static const String authPrefix = '/api/auth';
  static String get loginUrl => '$baseUrl$authPrefix/login';
  static String get registerUrl => '$baseUrl$authPrefix/register';
  static String get refreshTokenUrl => '$baseUrl$authPrefix/refresh';

  // User Service (8082)
  static const String userPrefix =
      '/api/api/users'; // Note the double /api prefix
  static String get userProfileUrl => '$baseUrl$userPrefix/profile';
  static String get updateProfileUrl => '$baseUrl$userPrefix/profile';
  static String getUserByIdUrl(String userId) => '$baseUrl$userPrefix/$userId';
  static String getUserByUsernameUrl(String username) =>
      '$baseUrl$userPrefix/username/$username';

  // Post Service (8083)
  static const String postPrefix = '/api/v1/posts';
  static String get postsUrl => '$baseUrl$postPrefix';
  static String createPostUrl(String userId) => '$baseUrl$postPrefix';
  static String getUserPostsUrl(String userId) =>
      '$baseUrl$postPrefix/user/$userId';
  static String getPostByIdUrl(String postId) => '$baseUrl$postPrefix/$postId';

  // Search Service (8084)
  static const String searchPrefix = '/api/search';
  static String get searchUrl => '$baseUrl$searchPrefix';
  static String get searchIndexUrl => '$baseUrl$searchPrefix/index';

  // News Feed Service (8085)
  static const String feedPrefix = '/api/feed';
  static String get feedUrl => '$baseUrl$feedPrefix';
  static String get feedPostsUrl => '$baseUrl$feedPrefix/posts';

  // Messaging Service (8086)
  static const String messagePrefix = '/api/v1/messages';
  static String get messagesUrl => '$baseUrl$messagePrefix';
  static String get conversationsUrl => '$baseUrl$messagePrefix/conversations';

  // Notification Service (8087)
  static const String notificationPrefix = '/api/v1/notifications';
  static String get notificationsUrl => '$baseUrl$notificationPrefix';
  static String markNotificationReadUrl(String notificationId) =>
      '$baseUrl$notificationPrefix/$notificationId/read';
  static String get markAllNotificationsReadUrl =>
      '$baseUrl$notificationPrefix/read-all';

  // Rating & Review Service (8088)
  static const String reviewPrefix = '/api/reviews';
  static String get reviewsUrl => '$baseUrl$reviewPrefix';
  static String getPostReviewsUrl(String postId) =>
      '$baseUrl$reviewPrefix/post/$postId';

  // Moderation Service (8089)
  static const String moderationPrefix = '/api/moderation/reports';
  static String get reportsUrl => '$baseUrl$moderationPrefix';

  // Awards Service (8090)
  static const String awardsPrefix = '/api/awards';
  static String get awardsUrl => '$baseUrl$awardsPrefix';
  static String get achievementsUrl => '$baseUrl$awardsPrefix/achievements';
  static String getUserAwardsUrl(String userId) =>
      '$baseUrl$awardsPrefix/user/$userId';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // CORS headers (for web)
  static Map<String, String> get corsHeaders => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization',
      };

  static Map<String, String> getAuthenticatedHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}
