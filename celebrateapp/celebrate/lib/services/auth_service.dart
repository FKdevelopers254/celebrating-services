import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;
  String? _role;
  String? _userId;
  String? _username;
  String? _email;
  bool _isAuthenticated = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get role => _role;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize the service
  Future<void> init() async {
    _accessToken = await storage.read(key: 'access_token');
    _refreshToken = await storage.read(key: 'refresh_token');
    _role = await storage.read(key: 'user_role');
    _userId = await storage.read(key: 'user_id');
    _username = await storage.read(key: 'username');
    _email = await storage.read(key: 'email');
    _isAuthenticated = _accessToken != null;
    notifyListeners();

    // If we have a refresh token but no access token, try to refresh
    if (_refreshToken != null && _accessToken == null) {
      await refreshAccessToken();
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': identifier.contains('@') ? identifier : null,
          'username': !identifier.contains('@') ? identifier : null,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleAuthResponse(data);
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Connection error. Please check your internet connection.',
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleAuthResponse(data);
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'error': 'Connection error. Please check your internet connection.',
      };
    }
  }

  // Refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleAuthResponse(data);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  // Handle authentication response
  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    await storage.write(key: 'access_token', value: data['accessToken']);
    await storage.write(key: 'refresh_token', value: data['refreshToken']);
    await storage.write(key: 'user_role', value: data['role']);
    await storage.write(key: 'user_id', value: data['userId'].toString());
    await storage.write(key: 'username', value: data['username']);
    await storage.write(key: 'email', value: data['email']);

    _accessToken = data['accessToken'];
    _refreshToken = data['refreshToken'];
    _role = data['role'];
    _userId = data['userId'].toString();
    _username = data['username'];
    _email = data['email'];
    _isAuthenticated = true;

    notifyListeners();
  }

  // Clear all auth data (logout)
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_role');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'username');
    await storage.delete(key: 'email');

    _accessToken = null;
    _refreshToken = null;
    _role = null;
    _userId = null;
    _username = null;
    _email = null;
    _isAuthenticated = false;

    notifyListeners();
  }

  // Get headers for authenticated requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Check if token is expired and refresh if needed
  Future<bool> ensureValidToken() async {
    if (_accessToken == null) return false;

    // Try to use the current token
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/validate'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Token validation error: $e');
    }

    // If we get here, try to refresh the token
    return await refreshAccessToken();
  }
}
