import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../models/driver.dart';

class WebSocketService {
  static const String wsUrl = 'wss://app.cabisync.com';
  
  WebSocketChannel? _channel;
  final Map<String, StreamController> _controllers = {};
  String? _authToken;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect(String token) async {
    _authToken = token;
    
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$token'),
      );

      _isConnected = true;
      print('✅ WebSocket connected');

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
    } catch (e) {
      print('❌ WebSocket connection error: $e');
      _isConnected = false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = data['event'] as String;
      final payload = data['data'] as Map<String, dynamic>;

      print('📨 WebSocket message: $event');

      final controller = _controllers[event];
      if (controller != null && !controller.isClosed) {
        controller.add(payload);
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
    }
  }

  void _handleError(error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
  }

  void _handleDone() {
    print('🔌 WebSocket connection closed');
    _isConnected = false;
    
    if (_authToken != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected) {
          print('🔄 Attempting to reconnect WebSocket...');
          connect(_authToken!);
        }
      });
    }
  }

  Stream<DriverLocation> listenToDriverLocation(int bookingId) {
    final event = 'booking.$bookingId.driver-location';
    
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController<DriverLocation>.broadcast();
    }

    return (_controllers[event] as StreamController<DriverLocation>)
        .stream
        .map((data) => DriverLocation.fromJson(data as Map<String, dynamic>));
  }

  Stream<Map<String, dynamic>> listenToBookingStatus(int bookingId) {
    final event = 'booking.$bookingId.status';
    
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController<Map<String, dynamic>>.broadcast();
    }

    return (_controllers[event] as StreamController<Map<String, dynamic>>).stream;
  }

  Stream<Map<String, dynamic>> listenToChatMessages(int bookingId) {
    final event = 'booking.$bookingId.chat';
    
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController<Map<String, dynamic>>.broadcast();
    }

    return (_controllers[event] as StreamController<Map<String, dynamic>>).stream;
  }

  void sendMessage(String event, Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      final message = jsonEncode({
        'event': event,
        'data': data,
      });
      _channel!.sink.add(message);
    } else {
      print('❌ WebSocket not connected. Cannot send message.');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    
    for (var controller in _controllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _controllers.clear();
    
    _isConnected = false;
    _authToken = null;
    print('🔌 WebSocket disconnected');
  }

  void subscribeToChannel(String channel) {
    sendMessage('subscribe', {'channel': channel});
  }

  void unsubscribeFromChannel(String channel) {
    sendMessage('unsubscribe', {'channel': channel});
  }
}
