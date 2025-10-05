import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/api_service.dart';

class SessionApiService {
  static const String _baseEndpoint = '/sessions';

  /// Create a new session
  static Future<Session> createSession(Session session) async {
    try {
      final response = await ApiService.postJson(
        _baseEndpoint,
        session.toJson(),
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to create session: ${e.toString()}');
    }
  }

  /// Get session by ID
  static Future<Session> getSessionById(String sessionId) async {
    try {
      final response = await ApiService.getJson(
        '$_baseEndpoint/$sessionId',
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to fetch session: ${e.toString()}');
    }
  }

  /// Get all sessions
  static Future<List<Session>> getAllSessions() async {
    try {
      final response = await ApiService.get(_baseEndpoint, includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch sessions: ${e.toString()}');
    }
  }

  /// Get sessions by DJ ID
  static Future<List<Session>> getSessionsByDjId(String djId) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/dj/$djId',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch DJ sessions: ${e.toString()}');
    }
  }

  /// Get active sessions (LIVE or PREPARING status)
  static Future<List<Session>> getActiveSessions() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/active',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch active sessions: ${e.toString()}');
    }
  }

  /// Get live sessions
  static Future<List<Session>> getLiveSessions() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/live',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch live sessions: ${e.toString()}');
    }
  }

  /// Get sessions accepting requests
  static Future<List<Session>> getSessionsAcceptingRequests() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/accepting-requests',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException(
          'Failed to fetch sessions accepting requests: ${e.toString()}');
    }
  }

  /// Start a session (change status to LIVE)
  static Future<Session> startSession(String sessionId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/start',
        {},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to start session: ${e.toString()}');
    }
  }

  /// End a session (change status to ENDED)
  static Future<Session> endSession(String sessionId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/end',
        {},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to end session: ${e.toString()}');
    }
  }

  /// Pause a session (change status to PAUSED)
  static Future<Session> pauseSession(String sessionId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/pause',
        {},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to pause session: ${e.toString()}');
    }
  }

  /// Resume a session (change status to LIVE)
  static Future<Session> resumeSession(String sessionId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/resume',
        {},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to resume session: ${e.toString()}');
    }
  }

  /// Update session details
  static Future<Session> updateSession(
      String sessionId, Session session) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId',
        session.toJson(),
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to update session: ${e.toString()}');
    }
  }

  /// Delete a session
  static Future<void> deleteSession(String sessionId) async {
    try {
      await ApiService.delete(
        '$_baseEndpoint/$sessionId',
        includeAuth: true,
      );
    } catch (e) {
      throw ApiException('Failed to delete session: ${e.toString()}');
    }
  }

  /// Get sessions by status
  static Future<List<Session>> getSessionsByStatus(SessionStatus status) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/status/${status.name}',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch sessions by status: ${e.toString()}');
    }
  }

  /// Get sessions by type
  static Future<List<Session>> getSessionsByType(SessionType type) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/type/${type.name}',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch sessions by type: ${e.toString()}');
    }
  }

  /// Toggle session request acceptance
  static Future<Session> toggleRequestAcceptance(
      String sessionId, bool acceptingRequests) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/toggle-requests',
        {'isAcceptingRequests': acceptingRequests},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException(
          'Failed to toggle request acceptance: ${e.toString()}');
    }
  }

  /// Update session minimum tip amount
  static Future<Session> updateMinTipAmount(
      String sessionId, double minTipAmount) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$sessionId/min-tip',
        {'minTipAmount': minTipAmount},
        includeAuth: true,
      );
      return Session.fromApiResponse(response);
    } catch (e) {
      throw ApiException(
          'Failed to update minimum tip amount: ${e.toString()}');
    }
  }

  /// Get sessions by date range
  static Future<List<Session>> getSessionsByDateRange(
      String startDate, String endDate) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/date-range?startDate=$startDate&endDate=$endDate',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException(
          'Failed to fetch sessions by date range: ${e.toString()}');
    }
  }

  /// Get today's live sessions
  static Future<List<Session>> getTodaysLiveSessions() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/today/live',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((sessionData) =>
                Session.fromApiResponse(sessionData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException(
          'Failed to fetch today\'s live sessions: ${e.toString()}');
    }
  }
}
