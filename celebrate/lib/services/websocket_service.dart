import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final Duration _heartbeatInterval = const Duration(seconds: 30);
  final Duration _reconnectDelay = const Duration(seconds: 5);
  final Function(dynamic)? onMessage;
  final String userId;
  final String type; // 'notifications' or 'chat'
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  WebSocketService({
    required this.userId,
    required this.type,
    this.onMessage,
  });

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    final wsUrl = type == 'notifications'
        ? ApiConstants.notificationWsUrl(userId)
        : ApiConstants.chatWsUrl(userId);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _reconnectAttempts = 0;

      _channel?.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnect();
        },
      );

      _startHeartbeat();
    } catch (e) {
      print('WebSocket connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleMessage(dynamic message) {
    if (message == 'pong') {
      // Heartbeat response
      return;
    }

    try {
      final decodedMessage = jsonDecode(message);
      onMessage?.call(decodedMessage);
    } catch (e) {
      print('Error decoding message: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        sendMessage('ping');
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay, () {
        _reconnectAttempts++;
        connect();
      });
    }
  }

  void sendMessage(dynamic message) {
    if (!_isConnected) {
      print('WebSocket not connected');
      return;
    }

    try {
      final encodedMessage = message is String ? message : jsonEncode(message);
      _channel?.sink.add(encodedMessage);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void disconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
  }
}
