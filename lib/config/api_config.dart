class ApiConfig {
  static const String serverIP = '41.89.64.12';
  static const int apiGatewayPort = 8080;

  // Base URLs
  static const String baseUrl = 'http://$serverIP:$apiGatewayPort/api';
  static const String wsBaseUrl = 'ws://$serverIP:$apiGatewayPort/api';

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  static const String registerUrl = '$baseUrl/auth/register';
  static const String refreshTokenUrl = '$baseUrl/auth/refresh';

  // User endpoints
  static const String userProfileUrl = '$baseUrl/users/profile';
  static const String updateProfileUrl = '$baseUrl/users/profile/update';
  static const String followUserUrl = '$baseUrl/users/follow';
  static const String unfollowUserUrl = '$baseUrl/users/unfollow';

  // Post endpoints
  static const String createPostUrl = '$baseUrl/posts/create';
  static const String feedUrl = '$baseUrl/posts/feed';
  static const String likePostUrl = '$baseUrl/posts/like';
  static const String commentUrl = '$baseUrl/posts/comment';

  // Messaging endpoints
  static const String chatListUrl = '$baseUrl/messages/chats';
  static const String wsMessagingUrl = '$wsBaseUrl/messages/ws';

  // Notification endpoints
  static const String notificationsUrl = '$baseUrl/notifications';
  static const String wsNotificationsUrl = '$wsBaseUrl/notifications/ws';

  // Search endpoints
  static const String searchUrl = '$baseUrl/search';

  // Rating & Review endpoints
  static const String ratingUrl = '$baseUrl/ratings';
  static const String reviewUrl = '$baseUrl/reviews';

  // News Feed endpoints
  static const String newsFeedUrl = '$baseUrl/news-feed';
  static const String trendingUrl = '$baseUrl/news-feed/trending';

  // Award endpoints
  static const String awardsUrl = '$baseUrl/awards';
  static const String achievementsUrl = '$baseUrl/awards/achievements';

  // Headers
  static Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
