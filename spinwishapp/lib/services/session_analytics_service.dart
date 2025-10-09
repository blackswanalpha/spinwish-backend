import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/session_analytics.dart';
import 'package:spinwishapp/services/api_service.dart';

class SessionAnalyticsService extends ChangeNotifier {
  SessionAnalytics? _currentAnalytics;
  bool _isLoading = false;
  String? _error;

  SessionAnalytics? get currentAnalytics => _currentAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch analytics for a specific session
  Future<SessionAnalytics?> fetchSessionAnalytics(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getJson(
        '/sessions/$sessionId/analytics',
        includeAuth: true,
      );

      _currentAnalytics = SessionAnalytics.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return _currentAnalytics;
    } catch (e) {
      _error = 'Failed to fetch session analytics: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching session analytics: $e');
      return null;
    }
  }

  /// Refresh current analytics
  Future<void> refreshAnalytics() async {
    if (_currentAnalytics != null) {
      await fetchSessionAnalytics(_currentAnalytics!.sessionId);
    }
  }

  /// Clear current analytics
  void clearAnalytics() {
    _currentAnalytics = null;
    _error = null;
    notifyListeners();
  }

  /// Get pending requests for a session
  /// Note: Use UserRequestsService.getPendingRequestsBySession() instead for typed responses
  Future<List<Map<String, dynamic>>> getPendingRequests(
      String sessionId) async {
    try {
      final response = await ApiService.get(
        '/api/v1/requests/session/$sessionId/pending',
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      return [];
    }
  }

  /// Get approved queue for a session
  /// Note: Use UserRequestsService.getSessionQueue() instead for typed responses
  Future<List<Map<String, dynamic>>> getSessionQueue(String sessionId) async {
    try {
      final response = await ApiService.get(
        '/api/v1/requests/session/$sessionId/queue',
        includeAuth: true,
      );

      final data = ApiService.handleResponse(response);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching session queue: $e');
      return [];
    }
  }

  /// Calculate estimated wait time for a queue position
  String getEstimatedWaitTime(int queuePosition, {int avgSongDuration = 3}) {
    final minutes = queuePosition * avgSongDuration;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}
