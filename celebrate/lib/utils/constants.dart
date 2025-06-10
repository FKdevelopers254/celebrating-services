class ApiConstants {
  static const String serverIP = '197.254.53.252';
  static const int apiGatewayPort = 2323;
  static const String baseUrl = 'http://$serverIP:$apiGatewayPort';

  // News Feed Types
  static const String postType = 'post';
  static const String eventType = 'event';
  static const String celebrationType = 'celebration';

  // Author Types
  static const String regularAuthor = 'regular';
  static const String celebrityAuthor = 'celebrity';

  // WebSocket Events
  static const String newsFeedUpdated = 'NEWS_FEED_UPDATED';
  static const String likeUpdated = 'LIKE_UPDATED';
  static const String commentAdded = 'COMMENT_ADDED';
  static const String messageReceived = 'MESSAGE_RECEIVED';
  static const String notificationReceived = 'NOTIFICATION_RECEIVED';

  // Cache Keys
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';

  // API Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
