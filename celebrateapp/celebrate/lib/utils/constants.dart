class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8080'; // API Gateway URL
  static const String authServiceUrl =
      'http://localhost:8081'; // Direct Auth Service URL (if needed)
  static const String userServiceUrl =
      'http://localhost:8082'; // Direct User Service URL (if needed)

  // Auth Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshTokenEndpoint = '/api/auth/refresh';
  static const String validateTokenEndpoint = '/api/auth/validate';
  static const String resetPasswordRequestEndpoint =
      '/api/auth/password/reset-request';
  static const String resetPasswordEndpoint = '/api/auth/password/reset';

  // User Endpoints
  static const String userProfileEndpoint = '/api/users/profile';
  static const String updateProfileEndpoint = '/api/users/profile/update';
  static const String userPreferencesEndpoint = '/api/users/preferences';

  // Token Configuration
  static const int tokenRefreshThreshold = 5 * 60; // 5 minutes in seconds
  static const Duration sessionTimeout = Duration(hours: 24);

  // Request Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Error Messages
  static const String connectionError =
      'Connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication failed. Please log in again.';
  static const String validationError =
      'Please check your input and try again.';
}
