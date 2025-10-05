import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/services/api_service.dart';

/// Smart queue service for duplicate detection, time estimation, and intelligent suggestions
class SmartQueueService extends ChangeNotifier {
  static final SmartQueueService _instance = SmartQueueService._internal();
  factory SmartQueueService() => _instance;
  SmartQueueService._internal();

  // Cache for duplicate detection
  final Map<String, bool> _duplicateCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Song duration cache (in minutes)
  final Map<String, double> _songDurations = {};
  
  // Popular songs tracking
  final Map<String, int> _songRequestCounts = {};
  final Map<String, DateTime> _lastRequestTimes = {};

  // Configuration
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const double _defaultSongDuration = 3.5; // minutes
  static const int _maxSuggestions = 5;

  /// Check if a song is already in the DJ's queue
  Future<bool> isDuplicateSong(String djId, String songId) async {
    final cacheKey = '${djId}_$songId';
    
    // Check cache first
    if (_duplicateCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _duplicateCache[cacheKey]!;
      }
    }

    try {
      final response = await ApiService.getJson(
        '/requests/queue/$djId/duplicate-check?songId=$songId',
        includeAuth: true,
      );

      final isDuplicate = response['isDuplicate'] ?? false;
      
      // Cache the result
      _duplicateCache[cacheKey] = isDuplicate;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return isDuplicate;
    } catch (e) {
      debugPrint('Failed to check duplicate song: $e');
      return false;
    }
  }

  /// Get estimated wait time based on queue position and song durations
  Duration getEstimatedWaitTime(List<Request> queueBefore, {String? songId}) {
    double totalMinutes = 0.0;
    
    for (final request in queueBefore) {
      final duration = getSongDuration(request.songId);
      totalMinutes += duration;
    }
    
    // Add current song duration if provided
    if (songId != null) {
      totalMinutes += getSongDuration(songId);
    }
    
    return Duration(minutes: totalMinutes.round());
  }

  /// Get song duration (with caching and estimation)
  double getSongDuration(String songId) {
    // Check cache first
    if (_songDurations.containsKey(songId)) {
      return _songDurations[songId]!;
    }
    
    // Use default duration and try to fetch real duration
    _fetchSongDuration(songId);
    return _defaultSongDuration;
  }

  /// Fetch song duration from API (async)
  Future<void> _fetchSongDuration(String songId) async {
    try {
      // This would typically call a music API like Spotify, Apple Music, etc.
      // For now, we'll simulate with random durations
      final random = Random();
      final duration = 2.5 + (random.nextDouble() * 3.0); // 2.5 to 5.5 minutes
      
      _songDurations[songId] = duration;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch song duration for $songId: $e');
    }
  }

  /// Track song request for popularity analytics
  void trackSongRequest(String songId) {
    _songRequestCounts[songId] = (_songRequestCounts[songId] ?? 0) + 1;
    _lastRequestTimes[songId] = DateTime.now();
    notifyListeners();
  }

  /// Get popular songs based on request frequency
  List<String> getPopularSongs({int limit = _maxSuggestions}) {
    final sortedSongs = _songRequestCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSongs
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get recently requested songs
  List<String> getRecentlyRequestedSongs({int limit = _maxSuggestions}) {
    final sortedSongs = _lastRequestTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSongs
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Suggest optimal queue insertion position based on tip amount and fairness
  int suggestOptimalPosition(
    List<Request> currentQueue,
    double tipAmount, {
    bool considerFairness = true,
  }) {
    if (currentQueue.isEmpty) return 0;
    
    // Find position based on tip amount
    int tipBasedPosition = 0;
    for (int i = 0; i < currentQueue.length; i++) {
      if (tipAmount > currentQueue[i].amount) {
        tipBasedPosition = i;
        break;
      }
      tipBasedPosition = i + 1;
    }
    
    if (!considerFairness) {
      return tipBasedPosition;
    }
    
    // Apply fairness algorithm - prevent same user from dominating queue
    final now = DateTime.now();
    int fairnessAdjustment = 0;
    
    // Check for recent requests from same user in nearby positions
    for (int i = max(0, tipBasedPosition - 2); 
         i < min(currentQueue.length, tipBasedPosition + 3); 
         i++) {
      final request = currentQueue[i];
      final timeSinceRequest = now.difference(request.timestamp);
      
      // If there's a recent request from same user, push position back slightly
      if (timeSinceRequest.inMinutes < 10) {
        fairnessAdjustment++;
      }
    }
    
    return min(currentQueue.length, tipBasedPosition + fairnessAdjustment);
  }

  /// Detect potential queue manipulation (tip wars)
  bool detectTipWar(List<Request> recentRequests, {Duration window = const Duration(minutes: 5)}) {
    if (recentRequests.length < 3) return false;
    
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    // Get requests within the time window
    final windowRequests = recentRequests
        .where((r) => r.timestamp.isAfter(windowStart))
        .toList();
    
    if (windowRequests.length < 3) return false;
    
    // Check for rapid tip escalation
    windowRequests.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    int escalations = 0;
    for (int i = 1; i < windowRequests.length; i++) {
      if (windowRequests[i].amount > windowRequests[i - 1].amount * 1.5) {
        escalations++;
      }
    }
    
    // If more than 50% of requests show significant tip escalation, it's likely a tip war
    return escalations > windowRequests.length * 0.5;
  }

  /// Get queue health metrics
  Map<String, dynamic> getQueueHealthMetrics(List<Request> queue) {
    if (queue.isEmpty) {
      return {
        'health': 'excellent',
        'averageWaitTime': 0.0,
        'tipVariance': 0.0,
        'fairnessScore': 1.0,
        'duplicateRisk': 0.0,
      };
    }
    
    // Calculate average wait time
    double totalWaitMinutes = 0.0;
    for (int i = 0; i < queue.length; i++) {
      totalWaitMinutes += getEstimatedWaitTime(queue.take(i).toList()).inMinutes;
    }
    final averageWait = totalWaitMinutes / queue.length;
    
    // Calculate tip variance
    final tips = queue.map((r) => r.amount).toList();
    final averageTip = tips.reduce((a, b) => a + b) / tips.length;
    final variance = tips.map((tip) => pow(tip - averageTip, 2)).reduce((a, b) => a + b) / tips.length;
    
    // Calculate fairness score (based on time distribution)
    final now = DateTime.now();
    final waitTimes = queue.map((r) => now.difference(r.timestamp).inMinutes).toList();
    final maxWait = waitTimes.isNotEmpty ? waitTimes.reduce(max) : 0;
    final fairnessScore = maxWait > 0 ? 1.0 - (maxWait / 60.0).clamp(0.0, 1.0) : 1.0;
    
    // Determine overall health
    String health = 'excellent';
    if (averageWait > 15 || variance > 25 || fairnessScore < 0.7) {
      health = 'poor';
    } else if (averageWait > 10 || variance > 15 || fairnessScore < 0.8) {
      health = 'fair';
    } else if (averageWait > 7 || variance > 10 || fairnessScore < 0.9) {
      health = 'good';
    }
    
    return {
      'health': health,
      'averageWaitTime': averageWait,
      'tipVariance': variance,
      'fairnessScore': fairnessScore,
      'duplicateRisk': _calculateDuplicateRisk(queue),
    };
  }

  /// Calculate duplicate risk based on song patterns
  double _calculateDuplicateRisk(List<Request> queue) {
    if (queue.length < 2) return 0.0;
    
    final songIds = queue.map((r) => r.songId).toList();
    final uniqueSongs = songIds.toSet();
    
    // Risk increases as we have fewer unique songs relative to total requests
    return 1.0 - (uniqueSongs.length / songIds.length);
  }

  /// Clear all caches
  void clearCaches() {
    _duplicateCache.clear();
    _cacheTimestamps.clear();
    _songDurations.clear();
    notifyListeners();
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'duplicateCache': _duplicateCache.length,
      'songDurations': _songDurations.length,
      'popularSongs': _songRequestCounts.length,
    };
  }
}
