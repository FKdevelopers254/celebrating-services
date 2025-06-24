import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/constants.dart';
import 'auth_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  final http.Client _client = http.Client();
  WebSocketChannel? _channel;
  final AuthService _authService;
  Function(NotificationModel)? _onNotificationReceived;

  NotificationService(this._authService);

  Future<List<NotificationModel>> getNotifications(
      {int page = 0, int size = 20}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/notifications').replace(
            queryParameters: {
              'page': page.toString(),
              'size': size.toString()
            }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('Failed to get unread count');
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  void connectToWebSocket(Function(NotificationModel) onNotificationReceived) {
    if (_authService.token == null) return;

    _onNotificationReceived = onNotificationReceived;
    final wsUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws');

    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws/notifications?token=${_authService.token}'),
    );

    _channel!.stream.listen(
      (message) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(message));
          _onNotificationReceived?.call(notification);
        } catch (e) {
          print('Error handling notification: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Try to reconnect after a delay
        Future.delayed(const Duration(seconds: 5), () {
          connectToWebSocket(onNotificationReceived);
        });
      },
      onDone: () {
        print('WebSocket connection closed');
        // Try to reconnect after a delay
        Future.delayed(const Duration(seconds: 5), () {
          connectToWebSocket(onNotificationReceived);
        });
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _onNotificationReceived = null;
  }

  void dispose() {
    disconnect();
    _client.close();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/api/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
