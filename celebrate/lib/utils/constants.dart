class ApiConstants {
  // API Base URLs
  static const bool isProduction = false;
  static const String host = isProduction ? 'localhost' : 'localhost';
  static const int gatewayPort = 8080;
  static const String baseUrl = 'http://localhost:8080';
  static const String wsBaseUrl = 'ws://$host:$gatewayPort';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String refreshTokenKey = 'refresh_token';

  // WebSocket Endpoints
  static String notificationWsUrl(String userId) =>
      '$wsBaseUrl/ws/notifications/$userId';
  static String chatWsUrl(String userId) => '$wsBaseUrl/ws/chat/$userId';

  // API Versions
  static const String apiV1 = '/api/v1';
  static const String apiPrefix = '/api';

  // Service Ports
  static const int authServicePort = 8081;
  static const int userServicePort = 8082;
  static const int postServicePort = 8083;
  static const int searchServicePort = 8084;
  static const int feedServicePort = 8085;
  static const int messagingServicePort = 8086;
  static const int notificationServicePort = 8087;
  static const int reviewServicePort = 8088;
  static const int moderationServicePort = 8089;
  static const int awardsServicePort = 8090;

  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Error Messages
  static const String networkError =
      'Network error occurred. Please check your connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String authError = 'Authentication error. Please login again.';
  static const String unknownError = 'An unknown error occurred.';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logout successful';
  static const String profileUpdateSuccess = 'Profile updated successfully';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String invalidEmail = 'Invalid email format';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Content Types
  static const String postType = 'post';
  static const String eventType = 'event';
  static const String celebrationType = 'celebration';

  // User Types
  static const String regularUser = 'USER';
  static const String celebrityUser = 'CELEBRITY';
  static const String adminUser = 'ADMIN';

  // WebSocket Events
  static const String newsFeedUpdated = 'NEWS_FEED_UPDATED';
  static const String likeUpdated = 'LIKE_UPDATED';
  static const String commentAdded = 'COMMENT_ADDED';
  static const String messageReceived = 'MESSAGE_RECEIVED';
  static const String notificationReceived = 'NOTIFICATION_RECEIVED';

  // Cache Keys
  static const String userProfileKey = 'user_profile';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // New endpoints
  static const String authServiceUrl = 'http://localhost:8081';
  static const String userServiceUrl = 'http://localhost:8082';
  static const String postServiceUrl = 'http://localhost:8084';

  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshTokenEndpoint = '/api/auth/refresh';

  // User endpoints
  static const String usersEndpoint = '/api/users';
  static const String celebritiesEndpoint = '/api/users/celebrities';
  static const String celebritySearchEndpoint = '/api/users/celebrities/search';
  static const String celebrityProfileEndpoint =
      '/api/users/{userId}/celebrity-profile';

  // Post endpoints
  static const String postsEndpoint = '/api/posts';
  static const String userPostsEndpoint = '/api/posts/user/{userId}';
  static const String postCommentsEndpoint = '/api/posts/{postId}/comments';
  static const String postLikesEndpoint = '/api/posts/{postId}/like';
  static const String postsByTypeEndpoint = '/api/posts/type/{celebrationType}';

  // WebSocket endpoints
  static const String postsWebSocketEndpoint = '/ws/posts';
  static const String notificationsWebSocketEndpoint = '/ws/notifications';
}
