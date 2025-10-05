import 'dart:convert';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/services/api_service.dart';

class DJApiService {
  // Get all DJs
  static Future<List<DJ>> getAllDJs() async {
    try {
      final response = await ApiService.get('/djs', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch DJs: ${e.toString()}');
    }
  }

  // Get DJ by ID
  static Future<DJ?> getDJById(String djId) async {
    try {
      final response = await ApiService.get('/djs/$djId', includeAuth: true);
      final data = ApiService.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return DJ.fromApiResponse(data);
      }
      throw ApiException(
          'Invalid response format: Expected object, got ${data.runtimeType}');
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      throw ApiException('Failed to fetch DJ: ${e.toString()}');
    }
  }

  // Get live DJs
  static Future<List<DJ>> getLiveDJs() async {
    try {
      final response = await ApiService.get('/djs/live', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch live DJs: ${e.toString()}');
    }
  }

  // Get DJs by genre
  static Future<List<DJ>> getDJsByGenre(String genre) async {
    try {
      final response =
          await ApiService.get('/djs/genre/$genre', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch DJs by genre: ${e.toString()}');
    }
  }

  // Get top rated DJs
  static Future<List<DJ>> getTopRatedDJs({int limit = 10}) async {
    try {
      final response = await ApiService.get('/djs/top-rated?limit=$limit',
          includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch top rated DJs: ${e.toString()}');
    }
  }

  // Get most followed DJs
  static Future<List<DJ>> getMostFollowedDJs({int limit = 10}) async {
    try {
      final response = await ApiService.get('/djs/most-followed?limit=$limit',
          includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch most followed DJs: ${e.toString()}');
    }
  }

  // Search DJs by name
  static Future<List<DJ>> searchDJsByName(String name) async {
    try {
      final response =
          await ApiService.get('/djs/search/$name', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((djData) => DJ.fromApiResponse(djData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to search DJs: ${e.toString()}');
    }
  }

  // Get DJ statistics
  static Future<DJStats> getDJStats(String djId) async {
    try {
      final response =
          await ApiService.get('/djs/$djId/stats', includeAuth: true);
      final data = ApiService.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return DJStats.fromJson(data);
      }
      throw ApiException(
          'Invalid response format: Expected object, got ${data.runtimeType}');
    } catch (e) {
      throw ApiException('Failed to fetch DJ stats: ${e.toString()}');
    }
  }

  // Get current user's DJ profile (if they are a DJ)
  static Future<DJ?> getCurrentDJProfile() async {
    try {
      // Use the dedicated endpoint for current DJ profile
      final response = await ApiService.get('/djs/me', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is Map<String, dynamic>) {
        return DJ.fromApiResponse(data);
      }
      throw ApiException(
          'Invalid response format: Expected object, got ${data.runtimeType}');
    } catch (e) {
      if (e.toString().contains('Current user is not a DJ')) {
        return null; // User is not a DJ, return null instead of throwing
      }
      throw ApiException('Failed to fetch current DJ profile: ${e.toString()}');
    }
  }

  // Update DJ profile
  static Future<DJ> updateDJProfile(
      String djId, Map<String, dynamic> profileData) async {
    try {
      final response = await ApiService.put('/djs/$djId/profile', profileData);
      return DJ.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to update DJ profile: ${e.toString()}');
    }
  }

  // Set DJ live status
  static Future<DJ> setDJLiveStatus(String djId, bool isLive) async {
    try {
      final response = await ApiService.put('/djs/$djId/live/$isLive', {});
      return DJ.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to update DJ live status: ${e.toString()}');
    }
  }

  // Follow DJ
  static Future<DJ> followDJ(String djId) async {
    try {
      final response = await ApiService.postJson('/djs/$djId/follow', {});
      return DJ.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to follow DJ: ${e.toString()}');
    }
  }

  // Unfollow DJ
  static Future<DJ> unfollowDJ(String djId) async {
    try {
      final response = await ApiService.postJson('/djs/$djId/unfollow', {});
      return DJ.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to unfollow DJ: ${e.toString()}');
    }
  }
}

// DJ Statistics model
class DJStats {
  final int totalSessions;
  final double totalEarnings;
  final int totalRequests;
  final double averageRating;
  final int followers;
  final int songsPlayed;

  DJStats({
    required this.totalSessions,
    required this.totalEarnings,
    required this.totalRequests,
    required this.averageRating,
    required this.followers,
    required this.songsPlayed,
  });

  factory DJStats.fromJson(Map<String, dynamic> json) {
    return DJStats(
      totalSessions: json['totalSessions'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      totalRequests: json['totalRequests'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      followers: json['followers'] ?? 0,
      songsPlayed: json['songsPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalEarnings': totalEarnings,
      'totalRequests': totalRequests,
      'averageRating': averageRating,
      'followers': followers,
      'songsPlayed': songsPlayed,
    };
  }
}
