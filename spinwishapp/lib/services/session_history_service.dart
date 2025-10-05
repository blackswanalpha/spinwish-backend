import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/session_api_service.dart';
import 'package:spinwishapp/services/auth_service.dart';

enum SessionHistoryFilter {
  all,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
  club,
  online,
  ended,
  paused,
}

enum SessionSortBy {
  dateNewest,
  dateOldest,
  earnings,
  duration,
  listeners,
  requests,
}

class SessionHistoryService extends ChangeNotifier {
  static final SessionHistoryService _instance =
      SessionHistoryService._internal();
  factory SessionHistoryService() => _instance;
  SessionHistoryService._internal();

  // Session history state
  List<Session> _allSessions = [];
  List<Session> _filteredSessions = [];
  SessionHistoryFilter _currentFilter = SessionHistoryFilter.all;
  SessionSortBy _currentSort = SessionSortBy.dateNewest;
  bool _isLoading = false;
  String? _error;

  // Analytics cache
  Map<String, dynamic>? _analyticsCache;
  DateTime? _lastAnalyticsUpdate;

  // Getters
  List<Session> get allSessions => List.unmodifiable(_allSessions);
  List<Session> get filteredSessions => List.unmodifiable(_filteredSessions);
  SessionHistoryFilter get currentFilter => _currentFilter;
  SessionSortBy get currentSort => _currentSort;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _allSessions.isNotEmpty;

  /// Load session history for current DJ
  Future<void> loadSessionHistory({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get all sessions for the current DJ
      _allSessions = await SessionApiService.getSessionsByDjId(currentUser.id);

      // Sort sessions by date (newest first) by default
      _allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      // Apply current filter and sort
      _applyFilterAndSort();

      // Clear analytics cache to force recalculation
      _analyticsCache = null;
      _lastAnalyticsUpdate = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load session history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply filter to sessions
  void applyFilter(SessionHistoryFilter filter) {
    _currentFilter = filter;
    _applyFilterAndSort();
    notifyListeners();
  }

  /// Apply sort to sessions
  void applySortBy(SessionSortBy sortBy) {
    _currentSort = sortBy;
    _applyFilterAndSort();
    notifyListeners();
  }

  /// Apply both filter and sort
  void _applyFilterAndSort() {
    // Apply filter
    _filteredSessions = _filterSessions(_allSessions, _currentFilter);

    // Apply sort
    _filteredSessions = _sortSessions(_filteredSessions, _currentSort);
  }

  /// Filter sessions based on criteria
  List<Session> _filterSessions(
      List<Session> sessions, SessionHistoryFilter filter) {
    final now = DateTime.now();

    switch (filter) {
      case SessionHistoryFilter.all:
        return sessions;

      case SessionHistoryFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return sessions.where((s) => s.startTime.isAfter(weekStart)).toList();

      case SessionHistoryFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return sessions.where((s) => s.startTime.isAfter(monthStart)).toList();

      case SessionHistoryFilter.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 1);
        return sessions
            .where((s) =>
                s.startTime.isAfter(lastMonthStart) &&
                s.startTime.isBefore(lastMonthEnd))
            .toList();

      case SessionHistoryFilter.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        return sessions.where((s) => s.startTime.isAfter(yearStart)).toList();

      case SessionHistoryFilter.club:
        return sessions.where((s) => s.type == SessionType.club).toList();

      case SessionHistoryFilter.online:
        return sessions.where((s) => s.type == SessionType.online).toList();

      case SessionHistoryFilter.ended:
        return sessions.where((s) => s.status == SessionStatus.ended).toList();

      case SessionHistoryFilter.paused:
        return sessions.where((s) => s.status == SessionStatus.paused).toList();
    }
  }

  /// Sort sessions based on criteria
  List<Session> _sortSessions(List<Session> sessions, SessionSortBy sortBy) {
    final sortedSessions = List<Session>.from(sessions);

    switch (sortBy) {
      case SessionSortBy.dateNewest:
        sortedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;

      case SessionSortBy.dateOldest:
        sortedSessions.sort((a, b) => a.startTime.compareTo(b.startTime));
        break;

      case SessionSortBy.earnings:
        sortedSessions.sort((a, b) =>
            (b.totalEarnings ?? 0.0).compareTo(a.totalEarnings ?? 0.0));
        break;

      case SessionSortBy.duration:
        sortedSessions.sort((a, b) {
          final aDuration = a.endTime?.difference(a.startTime).inMinutes ?? 0;
          final bDuration = b.endTime?.difference(b.startTime).inMinutes ?? 0;
          return bDuration.compareTo(aDuration);
        });
        break;

      case SessionSortBy.listeners:
        sortedSessions.sort(
            (a, b) => (b.listenerCount ?? 0).compareTo(a.listenerCount ?? 0));
        break;

      case SessionSortBy.requests:
        sortedSessions.sort(
            (a, b) => (b.totalRequests ?? 0).compareTo(a.totalRequests ?? 0));
        break;
    }

    return sortedSessions;
  }

  /// Get session analytics
  Future<Map<String, dynamic>> getSessionAnalytics(
      {bool forceRefresh = false}) async {
    // Return cached analytics if available and not expired
    if (_analyticsCache != null &&
        _lastAnalyticsUpdate != null &&
        !forceRefresh &&
        DateTime.now().difference(_lastAnalyticsUpdate!).inMinutes < 30) {
      return _analyticsCache!;
    }

    // Ensure we have session data
    if (_allSessions.isEmpty) {
      await loadSessionHistory();
    }

    // Calculate analytics
    _analyticsCache = _calculateAnalytics(_allSessions);
    _lastAnalyticsUpdate = DateTime.now();

    return _analyticsCache!;
  }

  /// Calculate comprehensive session analytics
  Map<String, dynamic> _calculateAnalytics(List<Session> sessions) {
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalEarnings': 0.0,
        'totalTips': 0.0,
        'totalRequests': 0,
        'totalListeners': 0,
        'averageSessionDuration': 0,
        'averageEarningsPerSession': 0.0,
        'averageRequestsPerSession': 0.0,
        'averageListenersPerSession': 0.0,
        'clubSessions': 0,
        'onlineSessions': 0,
        'completedSessions': 0,
        'totalSessionTime': 0,
        'bestPerformingSession': null,
        'recentTrend': 'stable',
        'monthlyBreakdown': <String, dynamic>{},
        'genreBreakdown': <String, int>{},
      };
    }

    final totalSessions = sessions.length;
    final totalEarnings =
        sessions.fold<double>(0.0, (sum, s) => sum + (s.totalEarnings ?? 0.0));
    final totalTips =
        sessions.fold<double>(0.0, (sum, s) => sum + (s.totalTips ?? 0.0));
    final totalRequests =
        sessions.fold<int>(0, (sum, s) => sum + (s.totalRequests ?? 0));
    final totalListeners =
        sessions.fold<int>(0, (sum, s) => sum + (s.listenerCount ?? 0));

    final clubSessions =
        sessions.where((s) => s.type == SessionType.club).length;
    final onlineSessions =
        sessions.where((s) => s.type == SessionType.online).length;
    final completedSessions =
        sessions.where((s) => s.status == SessionStatus.ended).length;

    // Calculate total session time in minutes
    final totalSessionTime = sessions.fold<int>(0, (sum, s) {
      if (s.endTime != null) {
        return sum + s.endTime!.difference(s.startTime).inMinutes;
      }
      return sum;
    });

    // Find best performing session (by earnings)
    Session? bestSession;
    double bestEarnings = 0.0;
    for (final session in sessions) {
      final earnings = session.totalEarnings ?? 0.0;
      if (earnings > bestEarnings) {
        bestEarnings = earnings;
        bestSession = session;
      }
    }

    // Calculate monthly breakdown
    final monthlyBreakdown = <String, dynamic>{};
    for (final session in sessions) {
      final monthKey =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}';
      if (!monthlyBreakdown.containsKey(monthKey)) {
        monthlyBreakdown[monthKey] = {
          'sessions': 0,
          'earnings': 0.0,
          'requests': 0,
          'listeners': 0,
        };
      }
      monthlyBreakdown[monthKey]['sessions']++;
      monthlyBreakdown[monthKey]['earnings'] += session.totalEarnings ?? 0.0;
      monthlyBreakdown[monthKey]['requests'] += session.totalRequests ?? 0;
      monthlyBreakdown[monthKey]['listeners'] += session.listenerCount ?? 0;
    }

    // Calculate genre breakdown
    final genreBreakdown = <String, int>{};
    for (final session in sessions) {
      for (final genre in session.genres) {
        genreBreakdown[genre] = (genreBreakdown[genre] ?? 0) + 1;
      }
    }

    return {
      'totalSessions': totalSessions,
      'totalEarnings': totalEarnings,
      'totalTips': totalTips,
      'totalRequests': totalRequests,
      'totalListeners': totalListeners,
      'averageSessionDuration':
          totalSessions > 0 ? totalSessionTime / totalSessions : 0,
      'averageEarningsPerSession':
          totalSessions > 0 ? totalEarnings / totalSessions : 0.0,
      'averageRequestsPerSession':
          totalSessions > 0 ? totalRequests / totalSessions : 0.0,
      'averageListenersPerSession':
          totalSessions > 0 ? totalListeners / totalSessions : 0.0,
      'clubSessions': clubSessions,
      'onlineSessions': onlineSessions,
      'completedSessions': completedSessions,
      'totalSessionTime': totalSessionTime,
      'bestPerformingSession': bestSession,
      'monthlyBreakdown': monthlyBreakdown,
      'genreBreakdown': genreBreakdown,
    };
  }

  /// Get sessions for a specific time period
  List<Session> getSessionsForPeriod(DateTime start, DateTime end) {
    return _allSessions
        .where((session) =>
            session.startTime.isAfter(start) && session.startTime.isBefore(end))
        .toList();
  }

  /// Get session by ID
  Session? getSessionById(String sessionId) {
    try {
      return _allSessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data
  void clearData() {
    _allSessions.clear();
    _filteredSessions.clear();
    _analyticsCache = null;
    _lastAnalyticsUpdate = null;
    _error = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadSessionHistory(forceRefresh: true);
  }
}
