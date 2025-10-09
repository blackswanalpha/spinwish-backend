import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/services/api_service.dart';

enum RequestStatus { pending, accepted, rejected, played }

class PlaySongRequest {
  final String djId;
  final String songId;
  final double amount;
  final String? message;
  final String? sessionId; // ✅ ADDED: Session ID for the request

  PlaySongRequest({
    required this.djId,
    required this.songId,
    required this.amount,
    this.message,
    this.sessionId, // ✅ ADDED: Session ID parameter
  });

  Map<String, dynamic> toJson() {
    return {
      'djId': djId,
      'songId': songId,
      'amount': amount,
      'message': message,
      'sessionId': sessionId, // ✅ ADDED: Include sessionId in JSON
    };
  }
}

class PlaySongResponse {
  final String id;
  final String djName;
  final String clientName;
  final bool status; // Backend sends Boolean, not enum
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Song>? songResponse;
  final double? amount;
  final String? message;
  final int? queuePosition;
  final String? sessionId;

  PlaySongResponse({
    required this.id,
    required this.djName,
    required this.clientName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.songResponse,
    this.amount,
    this.message,
    this.queuePosition,
    this.sessionId,
  });

  factory PlaySongResponse.fromJson(Map<String, dynamic> json) {
    return PlaySongResponse(
      id: json['id']?.toString() ?? '',
      djName: json['djName']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      status: json['status'] == true || json['status'] == 'true',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      songResponse: json['songResponse'] != null
          ? (json['songResponse'] as List)
              .map((s) => Song.fromApiResponse(s))
              .toList()
          : null,
      amount: json['amount']?.toDouble(),
      message: json['message']?.toString(),
      queuePosition: json['queuePosition'] as int?,
      sessionId: json['sessionId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'djName': djName,
      'clientName': clientName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'songResponse': songResponse?.map((s) => s.toJson()).toList(),
      'amount': amount,
      'message': message,
      'queuePosition': queuePosition,
      'sessionId': sessionId,
    };
  }
}

class UserRequestsService {
  static const String _baseEndpoint = '/requests';

  /// Create a new song request
  static Future<PlaySongResponse> createRequest(PlaySongRequest request) async {
    try {
      final response = await ApiService.postJson(
        _baseEndpoint,
        request.toJson(),
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to create request: ${e.toString()}');
    }
  }

  /// Get request by ID
  static Future<PlaySongResponse> getRequestById(String requestId) async {
    try {
      final response = await ApiService.getJson(
        '$_baseEndpoint/$requestId',
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to fetch request: ${e.toString()}');
    }
  }

  /// Get all requests (admin/DJ access)
  static Future<List<PlaySongResponse>> getAllRequests() async {
    try {
      final response = await ApiService.get(_baseEndpoint, includeAuth: true);
      final data = ApiService.handleResponse(response);
      if (data is List) {
        return data
            .map((item) =>
                PlaySongResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch all requests: ${e.toString()}');
    }
  }

  /// Update a request
  static Future<PlaySongResponse> updateRequest(
      String requestId, PlaySongRequest request) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$requestId',
        request.toJson(),
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to update request: ${e.toString()}');
    }
  }

  /// Delete a request
  static Future<void> deleteRequest(String requestId) async {
    try {
      await ApiService.delete('$_baseEndpoint/$requestId', includeAuth: true);
    } catch (e) {
      throw ApiException('Failed to delete request: ${e.toString()}');
    }
  }

  /// Mark request as done (DJ only)
  static Future<PlaySongResponse> markRequestAsDone(String requestId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$requestId/done',
        {},
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to mark request as done: ${e.toString()}');
    }
  }

  /// Accept a request (DJ only)
  static Future<PlaySongResponse> acceptRequest(String requestId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$requestId/accept',
        {},
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to accept request: ${e.toString()}');
    }
  }

  /// Reject a request (DJ only)
  static Future<PlaySongResponse> rejectRequest(String requestId) async {
    try {
      final response = await ApiService.putJson(
        '$_baseEndpoint/$requestId/reject',
        {},
        includeAuth: true,
      );
      return PlaySongResponse.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to reject request: ${e.toString()}');
    }
  }

  /// Get current user's requests
  static Future<List<PlaySongResponse>> getMyRequests() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/my-requests',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      if (data is List) {
        return data
            .map((item) =>
                PlaySongResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch user requests: ${e.toString()}');
    }
  }

  /// Get requests for current DJ
  static Future<List<PlaySongResponse>> getDJRequests() async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/dj-requests',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      if (data is List) {
        return data
            .map((item) =>
                PlaySongResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch DJ requests: ${e.toString()}');
    }
  }

  /// Get current user's requests by status
  static Future<List<PlaySongResponse>> getMyRequestsByStatus(
      RequestStatus status) async {
    try {
      final response = await ApiService.get(
        '$_baseEndpoint/my-requests/status/${status.toString().split('.').last}',
        includeAuth: true,
      );
      final data = ApiService.handleResponse(response);
      if (data is List) {
        return data
            .map((item) =>
                PlaySongResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch requests by status: ${e.toString()}');
    }
  }

  /// Get pending requests for current user
  static Future<List<PlaySongResponse>> getMyPendingRequests() async {
    return getMyRequestsByStatus(RequestStatus.pending);
  }

  /// Get accepted requests for current user
  static Future<List<PlaySongResponse>> getMyAcceptedRequests() async {
    return getMyRequestsByStatus(RequestStatus.accepted);
  }

  /// Get played requests for current user
  static Future<List<PlaySongResponse>> getMyPlayedRequests() async {
    return getMyRequestsByStatus(RequestStatus.played);
  }

  /// Get rejected requests for current user
  static Future<List<PlaySongResponse>> getMyRejectedRequests() async {
    return getMyRequestsByStatus(RequestStatus.rejected);
  }

  /// Create a song request with validation and payment processing
  static Future<PlaySongResponse> requestSong({
    required String djId,
    required String songId,
    required double tipAmount,
    String? message,
    String? sessionId,
  }) async {
    // Validate tip amount
    if (tipAmount <= 0) {
      throw ApiException('Tip amount must be greater than 0');
    }

    // Validate message length
    if (message != null && message.length > 500) {
      throw ApiException('Message cannot exceed 500 characters');
    }

    final request = PlaySongRequest(
      djId: djId,
      songId: songId,
      amount: tipAmount,
      message: message,
      sessionId: sessionId, // ✅ FIXED: Include sessionId in request
    );

    return createRequest(request);
  }

  /// Create a song request with payment integration
  static Future<Map<String, dynamic>> requestSongWithPayment({
    required String djId,
    required String songId,
    required double tipAmount,
    required String paymentMethod,
    String? message,
    String? sessionId,
  }) async {
    try {
      // First, create the request
      final request = await requestSong(
        djId: djId,
        songId: songId,
        tipAmount: tipAmount,
        message: message,
        sessionId: sessionId,
      );

      // Return request with payment metadata for frontend to process payment
      return {
        'request': request,
        'paymentRequired': true,
        'paymentMetadata': {
          'requestId': request.id,
          'djId': djId,
          'sessionId': sessionId,
          'songId': songId,
          'amount': tipAmount,
          'message': message,
          'paymentMethod': paymentMethod,
        }
      };
    } catch (e) {
      throw ApiException(
          'Failed to create request with payment: ${e.toString()}');
    }
  }

  /// Get request statistics for current user
  static Future<Map<String, int>> getMyRequestStats() async {
    try {
      final requests = await getMyRequests();
      final stats = <String, int>{
        'total': requests.length,
        'pending': 0,
        'accepted': 0,
        'played': 0,
        'rejected': 0,
      };

      for (final request in requests) {
        final statusKey =
            request.status.toString().split('.').last.toLowerCase();
        stats[statusKey] = (stats[statusKey] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw ApiException('Failed to fetch request statistics: ${e.toString()}');
    }
  }

  /// Get total amount spent on requests
  /// Note: Amount information is not available in the current response format
  static Future<double> getTotalAmountSpent() async {
    try {
      // TODO: Backend needs to include amount in PlaySongResponse
      return 0.0; // Placeholder until backend is updated
    } catch (e) {
      throw ApiException(
          'Failed to calculate total amount spent: ${e.toString()}');
    }
  }

  /// Get recent requests (last 10)
  static Future<List<PlaySongResponse>> getRecentRequests() async {
    try {
      final requests = await getMyRequests();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests.take(10).toList();
    } catch (e) {
      throw ApiException('Failed to fetch recent requests: ${e.toString()}');
    }
  }

  /// Get all requests for a specific session
  static Future<List<PlaySongResponse>> getRequestsBySession(
      String sessionId) async {
    try {
      debugPrint('🔍 Fetching requests for session: $sessionId');
      debugPrint('🔍 API endpoint: $_baseEndpoint/session/$sessionId');

      final response = await ApiService.get(
        '$_baseEndpoint/session/$sessionId',
        includeAuth: true,
      );

      debugPrint('🔍 Response status: ${response.statusCode}');
      debugPrint('🔍 Response body: ${response.body}');

      final data = ApiService.handleResponse(response);
      debugPrint('🔍 Parsed data type: ${data.runtimeType}');

      if (data is List) {
        debugPrint('🔍 Data is a List with ${data.length} items');
        final results = (data as List)
            .map((json) => PlaySongResponse.fromJson(json))
            .toList();
        debugPrint('✅ Converted to ${results.length} PlaySongResponse objects');
        return results;
      }
      debugPrint('⚠️ Data is not a List, returning empty');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting session requests: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ApiException('Failed to get session requests: ${e.toString()}');
    }
  }

  /// Get pending requests for a session (PENDING status only)
  static Future<List<PlaySongResponse>> getPendingRequestsBySession(
      String sessionId) async {
    try {
      debugPrint('⏳ Fetching pending requests for session: $sessionId');
      debugPrint('⏳ API endpoint: $_baseEndpoint/session/$sessionId/pending');

      final response = await ApiService.get(
        '$_baseEndpoint/session/$sessionId/pending',
        includeAuth: true,
      );

      debugPrint('⏳ Pending response status: ${response.statusCode}');
      debugPrint('⏳ Pending response body: ${response.body}');

      final data = ApiService.handleResponse(response);
      debugPrint('⏳ Parsed pending data type: ${data.runtimeType}');

      if (data is List) {
        debugPrint('⏳ Pending data is a List with ${data.length} items');
        final results = (data as List)
            .map((json) => PlaySongResponse.fromJson(json))
            .toList();
        debugPrint('✅ Converted to ${results.length} pending requests');
        return results;
      }
      debugPrint('⚠️ Pending data is not a List, returning empty');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting pending requests: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ApiException('Failed to get pending requests: ${e.toString()}');
    }
  }

  /// Get session queue (accepted requests ordered by queue position)
  static Future<List<PlaySongResponse>> getSessionQueue(
      String sessionId) async {
    try {
      debugPrint('🔍 Fetching queue for session: $sessionId');
      debugPrint('🔍 API endpoint: $_baseEndpoint/session/$sessionId/queue');

      final response = await ApiService.get(
        '$_baseEndpoint/session/$sessionId/queue',
        includeAuth: true,
      );

      debugPrint('🔍 Queue response status: ${response.statusCode}');
      debugPrint('🔍 Queue response body: ${response.body}');

      final data = ApiService.handleResponse(response);
      debugPrint('🔍 Parsed queue data type: ${data.runtimeType}');

      if (data is List) {
        debugPrint('🔍 Queue data is a List with ${data.length} items');
        final results = (data as List)
            .map((json) => PlaySongResponse.fromJson(json))
            .toList();
        debugPrint('✅ Converted to ${results.length} queue items');
        return results;
      }
      debugPrint('⚠️ Queue data is not a List, returning empty');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting session queue: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw ApiException('Failed to get session queue: ${e.toString()}');
    }
  }
}
