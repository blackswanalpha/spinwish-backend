import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/models/play_song_response.dart';
import 'package:spinwishapp/services/websocket_service.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/services/auth_service.dart';

class RealTimeRequestService extends ChangeNotifier {
  static final RealTimeRequestService _instance =
      RealTimeRequestService._internal();
  factory RealTimeRequestService() => _instance;
  RealTimeRequestService._internal() {
    _initializeWebSocketListeners();
  }

  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription? _requestUpdateSubscription;

  // Request state
  List<PlaySongResponse> _djRequests = [];
  List<PlaySongResponse> _userRequests = [];
  Map<String, int> _requestCounts = {};
  bool _isConnected = false;

  // Getters
  List<PlaySongResponse> get djRequests => List.unmodifiable(_djRequests);
  List<PlaySongResponse> get userRequests => List.unmodifiable(_userRequests);
  Map<String, int> get requestCounts => Map.unmodifiable(_requestCounts);
  bool get isConnected => _isConnected;

  // Filtered getters
  List<PlaySongResponse> get pendingDJRequests =>
      _djRequests.where((r) => r.status == false).toList(); // false = pending

  List<PlaySongResponse> get acceptedDJRequests => _djRequests
      .where((r) => r.status == true)
      .toList(); // true = accepted/played

  List<PlaySongResponse> get pendingUserRequests =>
      _userRequests.where((r) => r.status == false).toList();

  List<PlaySongResponse> get acceptedUserRequests =>
      _userRequests.where((r) => r.status == true).toList();

  /// Initialize WebSocket listeners for real-time request updates
  void _initializeWebSocketListeners() {
    _requestUpdateSubscription = _webSocketService.requestUpdates.listen(
      (request) {
        _handleRealTimeRequestUpdate(request);
      },
    );

    // Listen to WebSocket connection status
    _webSocketService.addListener(_onWebSocketStatusChanged);
  }

  /// Handle WebSocket connection status changes
  void _onWebSocketStatusChanged() {
    final wasConnected = _isConnected;
    _isConnected = _webSocketService.isConnected;

    if (_isConnected && !wasConnected) {
      // Reconnected - refresh data
      _refreshAllRequests();
    }

    notifyListeners();
  }

  /// Handle real-time request updates from WebSocket
  void _handleRealTimeRequestUpdate(Request request) {
    // Convert Request to PlaySongResponse format
    final playSongResponse = _convertRequestToPlaySongResponse(request);

    // Update DJ requests if current user is the DJ
    _updateDJRequestsList(playSongResponse);

    // Update user requests if current user is the requester
    _updateUserRequestsList(playSongResponse);

    // Update request counts
    _updateRequestCounts(playSongResponse);

    notifyListeners();
  }

  /// Convert Request model to PlaySongResponse format
  PlaySongResponse _convertRequestToPlaySongResponse(Request request) {
    return PlaySongResponse(
      id: request.id,
      djName: '', // Not available in Request model
      clientName: '', // Not available in Request model
      status: request.status == RequestStatus.ACCEPTED ||
          request.status == RequestStatus.PLAYED,
      createdAt: request.timestamp, // Using timestamp as createdAt
      updatedAt: null, // Not available in Request model
      songResponse: null, // Not available in Request model
    );
  }

  /// Update DJ requests list
  void _updateDJRequestsList(PlaySongResponse request) {
    final existingIndex = _djRequests.indexWhere((r) => r.id == request.id);

    if (existingIndex != -1) {
      // Update existing request
      _djRequests[existingIndex] = request;
    } else {
      // Add new request at the beginning (most recent first)
      _djRequests.insert(0, request);
    }

    // Keep only the most recent 100 requests to prevent memory issues
    if (_djRequests.length > 100) {
      _djRequests = _djRequests.take(100).toList();
    }
  }

  /// Update user requests list
  void _updateUserRequestsList(PlaySongResponse request) {
    final existingIndex = _userRequests.indexWhere((r) => r.id == request.id);

    if (existingIndex != -1) {
      // Update existing request
      _userRequests[existingIndex] = request;
    } else {
      // Add new request at the beginning (most recent first)
      _userRequests.insert(0, request);
    }

    // Keep only the most recent 100 requests to prevent memory issues
    if (_userRequests.length > 100) {
      _userRequests = _userRequests.take(100).toList();
    }
  }

  /// Update request counts for statistics
  void _updateRequestCounts(PlaySongResponse request) {
    final djId = request.djName; // Using djName as identifier for now
    if (djId.isNotEmpty) {
      _requestCounts[djId] = (_requestCounts[djId] ?? 0) + 1;
    }
  }

  /// Connect to real-time request updates
  Future<void> connect() async {
    try {
      await _webSocketService.connect();

      // Subscribe to request updates for current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null) {
        if (currentUser.role == 'DJ') {
          _webSocketService.subscribeToRequests(currentUser.id);
        }
        // Users automatically get updates for their own requests
      }

      // Load initial data
      await _refreshAllRequests();
    } catch (e) {
      debugPrint('Failed to connect to real-time request service: $e');
    }
  }

  /// Disconnect from real-time request updates
  Future<void> disconnect() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null && currentUser.role == 'DJ') {
        _webSocketService.unsubscribeFromRequests(currentUser.id);
      }

      await _webSocketService.disconnect();
    } catch (e) {
      debugPrint('Failed to disconnect from real-time request service: $e');
    }
  }

  /// Refresh all requests from API
  Future<void> _refreshAllRequests() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) return;

      // Load DJ requests if user is a DJ
      if (currentUser.role == 'DJ') {
        _djRequests = await UserRequestsService.getDJRequests();
      }

      // Load user's own requests
      _userRequests = await UserRequestsService.getMyRequests();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh requests: $e');
    }
  }

  /// Accept a request (DJ only)
  Future<void> acceptRequest(String requestId) async {
    try {
      final updatedRequest = await UserRequestsService.acceptRequest(requestId);

      // Update local state immediately for better UX
      _updateDJRequestsList(updatedRequest);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to accept request: ${e.toString()}');
    }
  }

  /// Reject a request (DJ only)
  Future<void> rejectRequest(String requestId) async {
    try {
      final updatedRequest = await UserRequestsService.rejectRequest(requestId);

      // Update local state immediately for better UX
      _updateDJRequestsList(updatedRequest);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to reject request: ${e.toString()}');
    }
  }

  /// Mark request as done/played (DJ only)
  Future<void> markRequestAsDone(String requestId) async {
    try {
      final updatedRequest =
          await UserRequestsService.markRequestAsDone(requestId);

      // Update local state immediately for better UX
      _updateDJRequestsList(updatedRequest);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to mark request as done: ${e.toString()}');
    }
  }

  /// Get request statistics
  Map<String, dynamic> getRequestStatistics() {
    final totalRequests = _djRequests.length;
    final pendingRequests = pendingDJRequests.length;
    final acceptedRequests = acceptedDJRequests.length;
    final totalEarnings = 0.0; // Amount not available in PlaySongResponse

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'acceptedRequests': acceptedRequests,
      'totalEarnings': totalEarnings,
      'averageRequestAmount':
          totalRequests > 0 ? totalEarnings / totalRequests : 0.0,
    };
  }

  /// Clear all local data
  void clearData() {
    _djRequests.clear();
    _userRequests.clear();
    _requestCounts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _requestUpdateSubscription?.cancel();
    _webSocketService.removeListener(_onWebSocketStatusChanged);
    disconnect();
    super.dispose();
  }
}
