import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/services/websocket_service.dart';
import 'package:spinwishapp/services/smart_queue_service.dart';

/// Enhanced queue service with priority ordering, position management, and smart features
class EnhancedQueueService extends ChangeNotifier {
  static final EnhancedQueueService _instance =
      EnhancedQueueService._internal();
  factory EnhancedQueueService() => _instance;
  EnhancedQueueService._internal();

  final WebSocketService _webSocketService = WebSocketService();
  final SmartQueueService _smartQueueService = SmartQueueService();

  // Queue state
  List<Request> _priorityQueue = [];
  Map<String, Object> _queueStatistics = {};
  Map<String, bool> _duplicateCache = {};
  bool _isLoading = false;
  String? _error;

  // Configuration
  static const double _tipWeight = 0.7;
  static const double _timeWeight = 0.3;
  static const double _maxTimeBonus = 10.0;
  static const int _maxWaitMinutes = 60;

  // Getters
  List<Request> get priorityQueue => List.unmodifiable(_priorityQueue);
  Map<String, Object> get queueStatistics => Map.unmodifiable(_queueStatistics);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Request> get pendingRequests =>
      _priorityQueue.where((r) => r.status == RequestStatus.pending).toList();

  List<Request> get acceptedRequests =>
      _priorityQueue.where((r) => r.status == RequestStatus.accepted).toList();

  /// Initialize the enhanced queue service
  Future<void> initialize() async {
    try {
      await _webSocketService.connect();
      _setupWebSocketListeners();
    } catch (e) {
      _error = 'Failed to initialize queue service: $e';
      notifyListeners();
    }
  }

  /// Setup WebSocket listeners for real-time updates
  void _setupWebSocketListeners() {
    _webSocketService.addListener(() {
      if (_webSocketService.isConnected) {
        _refreshQueue();
      }
    });
  }

  /// Load DJ's priority queue
  Future<void> loadPriorityQueue(String djId) async {
    _setLoading(true);
    try {
      final response = await ApiService.getJson(
        '/requests/queue/$djId/priority',
        includeAuth: true,
      );

      if (response is List) {
        _priorityQueue = (response as List)
            .map((item) => _convertToRequest(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final List<dynamic> dataList = response['data'] as List;
        _priorityQueue = dataList
            .map((item) => _convertToRequest(item as Map<String, dynamic>))
            .toList();

        // Update queue positions based on priority
        _updateLocalQueuePositions();

        _error = null;
      }
    } catch (e) {
      _error = 'Failed to load priority queue: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate priority score for a request (client-side validation)
  double calculatePriorityScore(Request request) {
    // Tip amount component (normalized to 0-10 scale)
    double tipScore = min(request.amount, 10.0);

    // Time decay component
    int minutesWaiting = DateTime.now().difference(request.timestamp).inMinutes;
    double timeBonus =
        min(minutesWaiting / _maxWaitMinutes * _maxTimeBonus, _maxTimeBonus);

    return (tipScore * _tipWeight) + (timeBonus * _timeWeight);
  }

  /// Update local queue positions based on priority scores
  void _updateLocalQueuePositions() {
    // Sort by priority score (higher score = higher priority)
    _priorityQueue.sort((a, b) =>
        calculatePriorityScore(b).compareTo(calculatePriorityScore(a)));

    // Update positions
    for (int i = 0; i < _priorityQueue.length; i++) {
      _priorityQueue[i] = Request(
        id: _priorityQueue[i].id,
        userId: _priorityQueue[i].userId,
        sessionId: _priorityQueue[i].sessionId,
        songId: _priorityQueue[i].songId,
        status: _priorityQueue[i].status,
        amount: _priorityQueue[i].amount,
        timestamp: _priorityQueue[i].timestamp,
        message: _priorityQueue[i].message,
        queuePosition: i + 1,
      );
    }
  }

  /// Manually reorder queue (drag and drop)
  Future<bool> reorderQueue(String djId, List<String> requestIds) async {
    try {
      final response = await ApiService.putJson(
        '/requests/queue/$djId/reorder',
        {'requestIds': requestIds},
        includeAuth: true,
      );

      if (response is List) {
        _priorityQueue = (response as List)
            .map((item) => _convertToRequest(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final List<dynamic> dataList = response['data'] as List;
        _priorityQueue = dataList
            .map((item) => _convertToRequest(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to reorder queue: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check for duplicate songs (using smart queue service)
  Future<bool> isDuplicateSong(String djId, String songId) async {
    return await _smartQueueService.isDuplicateSong(djId, songId);
  }

  /// Load queue statistics
  Future<void> loadQueueStatistics(String djId) async {
    try {
      final response = await ApiService.getJson(
        '/requests/queue/$djId/statistics',
        includeAuth: true,
      );

      _queueStatistics = Map<String, Object>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load queue statistics: $e');
    }
  }

  /// Get estimated wait time for a position (using smart queue service)
  Duration getEstimatedWaitTime(int queuePosition) {
    if (queuePosition <= 1) return Duration.zero;

    final queueBefore = _priorityQueue.take(queuePosition - 1).toList();
    return _smartQueueService.getEstimatedWaitTime(queueBefore);
  }

  /// Get queue position for a request
  int? getQueuePosition(String requestId) {
    final request = _priorityQueue.firstWhere(
      (r) => r.id == requestId,
      orElse: () => Request(
        id: '',
        userId: '',
        sessionId: '',
        songId: '',
        status: RequestStatus.pending,
        amount: 0.0,
        timestamp: DateTime.now(),
      ),
    );
    return request.id.isNotEmpty ? request.queuePosition : null;
  }

  /// Refresh queue data
  Future<void> _refreshQueue() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser != null && currentUser.role == 'DJ') {
      await loadPriorityQueue(currentUser.id);
      await loadQueueStatistics(currentUser.id);
    }
  }

  /// Convert API response to Request model
  Request _convertToRequest(Map<String, dynamic> json) {
    return Request(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['clientId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      songId: json['songId'] ?? '',
      status: _parseRequestStatus(json['status']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.tryParse(json['timestamp'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
      message: json['message'],
      queuePosition: json['queuePosition'],
    );
  }

  /// Parse request status from API response
  RequestStatus _parseRequestStatus(dynamic status) {
    if (status is String) {
      switch (status.toUpperCase()) {
        case 'PENDING':
          return RequestStatus.pending;
        case 'ACCEPTED':
          return RequestStatus.accepted;
        case 'REJECTED':
          return RequestStatus.rejected;
        case 'PLAYED':
          return RequestStatus.played;
        default:
          return RequestStatus.pending;
      }
    } else if (status is int) {
      return RequestStatus
          .values[status.clamp(0, RequestStatus.values.length - 1)];
    }
    return RequestStatus.pending;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get popular songs
  List<String> getPopularSongs({int limit = 5}) {
    return _smartQueueService.getPopularSongs(limit: limit);
  }

  /// Get recently requested songs
  List<String> getRecentlyRequestedSongs({int limit = 5}) {
    return _smartQueueService.getRecentlyRequestedSongs(limit: limit);
  }

  /// Suggest optimal queue position
  int suggestOptimalPosition(double tipAmount, {bool considerFairness = true}) {
    return _smartQueueService.suggestOptimalPosition(
      _priorityQueue,
      tipAmount,
      considerFairness: considerFairness,
    );
  }

  /// Detect tip war
  bool detectTipWar({Duration window = const Duration(minutes: 5)}) {
    return _smartQueueService.detectTipWar(_priorityQueue, window: window);
  }

  /// Get queue health metrics
  Map<String, dynamic> getQueueHealthMetrics() {
    return _smartQueueService.getQueueHealthMetrics(_priorityQueue);
  }

  /// Track song request for analytics
  void trackSongRequest(String songId) {
    _smartQueueService.trackSongRequest(songId);
  }

  /// Clear cache
  void clearCache() {
    _duplicateCache.clear();
    _smartQueueService.clearCaches();
  }

  @override
  void dispose() {
    _webSocketService.removeListener(() {});
    super.dispose();
  }
}
