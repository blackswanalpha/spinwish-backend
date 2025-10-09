import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/models/tip.dart';

class WebSocketService extends ChangeNotifier {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Event streams
  final StreamController<Session> _sessionUpdateController =
      StreamController<Session>.broadcast();
  final StreamController<Request> _requestUpdateController =
      StreamController<Request>.broadcast();
  final StreamController<Tip> _tipUpdateController =
      StreamController<Tip>.broadcast();
  final StreamController<Map<String, dynamic>> _generalUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  Stream<Session> get sessionUpdates => _sessionUpdateController.stream;
  Stream<Request> get requestUpdates => _requestUpdateController.stream;
  Stream<Tip> get tipUpdates => _tipUpdateController.stream;
  Stream<Map<String, dynamic>> get generalUpdates =>
      _generalUpdateController.stream;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Get WebSocket URL based on API base URL
      final wsUrl = await _getWebSocketUrl();

      // Use WebSocketChannel.connect for better platform compatibility
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
      );

      // Send authentication after connection
      _channel!.sink.add(jsonEncode({
        'type': 'auth',
        'token': token,
      }));

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      debugPrint('WebSocket connected to: $wsUrl');
      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    await _subscription?.cancel();
    await _channel?.sink.close();

    _subscription = null;
    _channel = null;

    debugPrint('WebSocket disconnected');
    notifyListeners();
  }

  /// Subscribe to session updates
  void subscribeToSession(String sessionId) {
    if (!_isConnected) return;

    final message = {
      'type': 'subscribe',
      'topic': 'session',
      'sessionId': sessionId,
    };

    _sendMessage(message);
  }

  /// Unsubscribe from session updates
  void unsubscribeFromSession(String sessionId) {
    if (!_isConnected) return;

    final message = {
      'type': 'unsubscribe',
      'topic': 'session',
      'sessionId': sessionId,
    };

    _sendMessage(message);
  }

  /// Subscribe to request updates for a DJ
  void subscribeToRequests(String djId) {
    if (!_isConnected) return;

    final message = {
      'type': 'subscribe',
      'topic': 'requests',
      'djId': djId,
    };

    _sendMessage(message);
  }

  /// Unsubscribe from request updates
  void unsubscribeFromRequests(String djId) {
    if (!_isConnected) return;

    final message = {
      'type': 'unsubscribe',
      'topic': 'requests',
      'djId': djId,
    };

    _sendMessage(message);
  }

  /// Subscribe to tip updates for a session
  void subscribeToTips(String sessionId) {
    if (!_isConnected) return;

    final message = {
      'type': 'subscribe',
      'topic': 'tips',
      'sessionId': sessionId,
    };

    _sendMessage(message);
  }

  /// Unsubscribe from tip updates
  void unsubscribeFromTips(String sessionId) {
    if (!_isConnected) return;

    final message = {
      'type': 'unsubscribe',
      'topic': 'tips',
      'sessionId': sessionId,
    };

    _sendMessage(message);
  }

  /// Send a message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) return;

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Failed to send WebSocket message: $e');
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final topic = data['topic'] as String?;

      switch (topic) {
        case 'session':
          _handleSessionUpdate(data);
          break;
        case 'requests':
          _handleRequestUpdate(data);
          break;
        case 'tips':
          _handleTipUpdate(data);
          break;
        case 'heartbeat':
          _handleHeartbeat(data);
          break;
        default:
          _generalUpdateController.add(data);
      }
    } catch (e) {
      debugPrint('Failed to parse WebSocket message: $e');
    }
  }

  /// Handle session update messages
  void _handleSessionUpdate(Map<String, dynamic> data) {
    try {
      final sessionData = data['session'] as Map<String, dynamic>?;
      if (sessionData != null) {
        final session = Session.fromApiResponse(sessionData);
        _sessionUpdateController.add(session);
      }
    } catch (e) {
      debugPrint('Failed to handle session update: $e');
    }
  }

  /// Handle request update messages
  void _handleRequestUpdate(Map<String, dynamic> data) {
    try {
      final requestData = data['request'] as Map<String, dynamic>?;
      if (requestData != null) {
        final request = Request.fromJson(requestData);
        _requestUpdateController.add(request);
      }
    } catch (e) {
      debugPrint('Failed to handle request update: $e');
    }
  }

  /// Handle tip update messages
  void _handleTipUpdate(Map<String, dynamic> data) {
    try {
      final tipData = data['tip'] as Map<String, dynamic>?;
      if (tipData != null) {
        final tip = Tip.fromJson(tipData);
        _tipUpdateController.add(tip);
      }
    } catch (e) {
      debugPrint('Failed to handle tip update: $e');
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(Map<String, dynamic> data) {
    // Respond to heartbeat to keep connection alive
    _sendMessage({
      'type': 'heartbeat_response',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _heartbeatTimer?.cancel();
    notifyListeners();
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      debugPrint('Attempting to reconnect (attempt $_reconnectAttempts)');
      connect();
    });
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  /// Get WebSocket URL based on API base URL
  Future<String> _getWebSocketUrl() async {
    final apiUrl = await ApiService.getBaseUrl();
    // Convert HTTP URL to WebSocket URL
    final wsUrl = apiUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('/api/v1', '/ws');

    return wsUrl;
  }

  @override
  void dispose() {
    disconnect();
    _sessionUpdateController.close();
    _requestUpdateController.close();
    _generalUpdateController.close();
    super.dispose();
  }
}
