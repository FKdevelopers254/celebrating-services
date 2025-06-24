import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:celebrate/models/user.dart';

class AuthService extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();
  String? _token;
  String? _role;
  String? _userId;
  DateTime? _tokenExpiry;

  AuthService() : super(); // Call the parent constructor

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  bool get isAuthenticated {
    return _token != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now());
  }

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
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  // Login method with improved error handling
  Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
      print('Attempting login to: $uri'); // Debug log

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (kIsWeb) 'mode': 'no-cors',
      };

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

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
    } on http.ClientException catch (e) {
      print('Network error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
        'error': e.toString()
      };
    } catch (e) {
      print('Unexpected error: $e'); // Debug log
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString()
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');
      print('Attempting registration to: $uri'); // Debug log

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (kIsWeb) 'mode': 'no-cors',
      };

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(userData),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
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
      print('Registration error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString()
      };
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/auth/refresh');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
        if (kIsWeb) 'mode': 'no-cors',
      };

      final response = await _client.post(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleAuthResponse(data);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
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

  Future<void> logout() async {
    await setToken(null);
    await setRole(null);
    await setUserId(null);
    _tokenExpiry = null;
    await storage.delete(key: 'token_expiry');
    notifyListeners();
  }
}
