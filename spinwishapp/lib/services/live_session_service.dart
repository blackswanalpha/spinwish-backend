import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/dj_session.dart';
import 'package:spinwishapp/services/dj_api_service.dart';
import 'package:spinwishapp/services/session_api_service.dart';

import 'package:spinwishapp/models/session.dart' as backend_session;

class LiveSessionService extends ChangeNotifier {
  static final LiveSessionService _instance = LiveSessionService._internal();
  factory LiveSessionService() => _instance;
  LiveSessionService._internal() {
    _startLiveSessionSimulation();
  }

  final List<DJSession> _liveSessions = [];
  Timer? _sessionUpdateTimer;
  final math.Random _random = math.Random();

  List<DJSession> get liveSessions => List.unmodifiable(_liveSessions);
  int get liveSessionCount => _liveSessions.length;

  // Get live sessions filtered by genre
  List<DJSession> getLiveSessionsByGenre(String genre) {
    if (genre == 'All') return _liveSessions;
    return _liveSessions
        .where((session) => session.genres.contains(genre))
        .toList();
  }

  // Get live sessions by location (for club sessions)
  List<DJSession> getLiveSessionsByLocation(String location) {
    return _liveSessions.where((session) {
      if (session.type == SessionType.online) return false;
      // In a real app, you'd check the club's location
      return true; // For now, return all club sessions
    }).toList();
  }

  // Get trending live sessions (by listener count)
  List<DJSession> getTrendingLiveSessions() {
    final sorted = List<DJSession>.from(_liveSessions);
    sorted.sort((a, b) => b.listenerCount.compareTo(a.listenerCount));
    return sorted.take(5).toList();
  }

  // Get recently started sessions
  List<DJSession> getRecentLiveSessions() {
    final sorted = List<DJSession>.from(_liveSessions);
    sorted.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(5).toList();
  }

  // Get top live sessions by listener count
  List<DJSession> getTopLiveSessions() {
    final sorted = List<DJSession>.from(_liveSessions);
    sorted.sort((a, b) => b.listenerCount.compareTo(a.listenerCount));
    return sorted.take(10).toList(); // Return top 10 for the circular cards
  }

  // Join a live session as a listener
  Future<bool> joinSession(String sessionId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final sessionIndex = _liveSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) return false;

      // Increment listener count
      final session = _liveSessions[sessionIndex];
      _liveSessions[sessionIndex] = session.copyWith(
        listenerCount: session.listenerCount + 1,
      );

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Leave a live session
  Future<bool> leaveSession(String sessionId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      final sessionIndex = _liveSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) return false;

      // Decrement listener count
      final session = _liveSessions[sessionIndex];
      _liveSessions[sessionIndex] = session.copyWith(
        listenerCount: math.max(0, session.listenerCount - 1),
      );

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Search live sessions
  List<DJSession> searchLiveSessions(String query) {
    if (query.isEmpty) return _liveSessions;

    final lowerQuery = query.toLowerCase();
    return _liveSessions.where((session) {
      return session.title.toLowerCase().contains(lowerQuery) ||
          session.description?.toLowerCase().contains(lowerQuery) == true ||
          session.genres.any(
            (genre) => genre.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  // Get session by ID
  DJSession? getSessionById(String sessionId) {
    try {
      return _liveSessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  // Add a new live session (called when DJ starts a session)
  void addLiveSession(DJSession session) {
    if (!_liveSessions.any((s) => s.id == session.id)) {
      _liveSessions.add(session);
      notifyListeners();
    }
  }

  // Remove a live session (called when DJ ends a session)
  void removeLiveSession(String sessionId) {
    _liveSessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  // Update an existing live session
  void updateLiveSession(DJSession updatedSession) {
    final index = _liveSessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      _liveSessions[index] = updatedSession;
      notifyListeners();
    }
  }

  // Start simulation of live sessions for demo purposes
  void _startLiveSessionSimulation() {
    // Create some initial live sessions
    _createInitialLiveSessions();

    // Update sessions periodically
    _sessionUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateLiveSessionsSimulation();
    });
  }

  Future<void> _createInitialLiveSessions() async {
    try {
      _liveSessions.clear();

      // Load real live sessions from backend
      final liveSessions = await SessionApiService.getLiveSessions();

      // Convert backend sessions to DJSession models
      for (final session in liveSessions) {
        try {
          // Get DJ info for the session
          final dj = await DJApiService.getDJById(session.djId);
          if (dj != null) {
            final djSession = DJSession(
              id: session.id,
              djId: session.djId,
              clubId: session.clubId,
              type: session.type == backend_session.SessionType.online
                  ? SessionType.online
                  : SessionType.club,
              status: SessionStatus.live,
              title: session.title,
              description: session.description,
              startTime: session.startTime,
              listenerCount: session.listenerCount ?? 0,
              requestQueue: const [], // Will be loaded separately if needed
              totalEarnings: session.totalEarnings ?? 0.0,
              totalTips: session.totalTips ?? 0.0,
              totalRequests: session.totalRequests ?? 0,
              acceptedRequests: session.acceptedRequests ?? 0,
              rejectedRequests: 0, // Not available in backend session
              isAcceptingRequests: session.isAcceptingRequests ?? true,
              minTipAmount: 5.0, // Default minimum tip amount
              genres: session.genres ?? [],
              shareableLink: session.shareableLink,
              imageUrl: session.imageUrl,
              thumbnailUrl: session.thumbnailUrl,
            );
            _liveSessions.add(djSession);
          }
        } catch (e) {
          debugPrint('Error processing session ${session.id}: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading live sessions: $e');
      _liveSessions.clear();
      notifyListeners();
    }
  }

  // This method is no longer needed as we use real backend data

  void _updateLiveSessionsSimulation() {
    // Randomly update listener counts and other dynamic data
    for (int i = 0; i < _liveSessions.length; i++) {
      final session = _liveSessions[i];

      // Simulate listener count changes
      final listenerChange = _random.nextInt(21) - 10; // -10 to +10
      final newListenerCount = math.max(
        0,
        session.listenerCount + listenerChange,
      );

      // Simulate earnings changes
      final earningsIncrease = _random.nextDouble() * 20;

      _liveSessions[i] = session.copyWith(
        listenerCount: newListenerCount,
        totalEarnings: session.totalEarnings + earningsIncrease,
        totalRequests: session.totalRequests + (_random.nextBool() ? 1 : 0),
      );
    }

    // Note: Session addition/removal now handled by real backend data
    // No longer simulating session changes

    notifyListeners();
  }

  // Removed unused mock data generation methods

  @override
  void dispose() {
    _sessionUpdateTimer?.cancel();
    super.dispose();
  }
}
