import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  final storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();
  String? _token;
  String? _role;
  String? _userId;
  DateTime? _tokenExpiry;
  bool _isAuthenticated = false;

  AuthService._internal();

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize the service
  Future<void> init() async {
    try {
      _token = await storage.read(key: ApiConstants.authTokenKey);
      _role = await storage.read(key: ApiConstants.userRoleKey);
      _userId = await storage.read(key: ApiConstants.userIdKey);
      final expiryStr = await storage.read(key: 'token_expiry');
      if (expiryStr != null) {
        _tokenExpiry = DateTime.parse(expiryStr);
      }
      _isAuthenticated = _token != null &&
          _tokenExpiry != null &&
          _tokenExpiry!.isAfter(DateTime.now());
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String identifier, String password,
      {String role = 'USER'}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              if (identifier.contains('@'))
                'email': identifier
              else
                'username': identifier,
              'password': password,
              'role': role.toUpperCase(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _handleAuthResponse(responseData);
        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'error': responseData
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleAuthResponse(data);
        return {
          'success': true,
          'message': 'Registration successful',
          'data': data
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
          'error': error
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }

  // Handle auth response
  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    await setToken(data['token']);
    await setRole(data['role']);
    await setUserId(data['userId'].toString());
    if (data['expiresIn'] != null) {
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expiresIn']));
      await storage.write(
          key: 'token_expiry', value: _tokenExpiry!.toIso8601String());
    }
    _isAuthenticated = true;
    notifyListeners();
  }

  // Token management
  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await storage.write(key: ApiConstants.authTokenKey, value: token);
    } else {
      await storage.delete(key: ApiConstants.authTokenKey);
    }
    notifyListeners();
  }

  Future<void> setRole(String? role) async {
    _role = role;
    if (role != null) {
      await storage.write(key: ApiConstants.userRoleKey, value: role);
    } else {
      await storage.delete(key: ApiConstants.userRoleKey);
    }
    notifyListeners();
  }

  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (userId != null) {
      await storage.write(key: ApiConstants.userIdKey, value: userId);
    } else {
      await storage.delete(key: ApiConstants.userIdKey);
    }
    notifyListeners();
  }

  // Clear token and role (logout)
  Future<void> logout() async {
    try {
      await storage.delete(key: ApiConstants.authTokenKey);
      await storage.delete(key: ApiConstants.userRoleKey);
      await storage.delete(key: ApiConstants.userIdKey);
      await storage.delete(key: 'token_expiry');
      _token = null;
      _role = null;
      _userId = null;
      _tokenExpiry = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    await init(); // This will properly update the isAuthenticated state
    notifyListeners();
  }
}
