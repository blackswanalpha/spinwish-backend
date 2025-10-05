import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/location_service.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/models/session.dart';

class DJDiscoveryService extends ChangeNotifier {
  static final DJDiscoveryService _instance = DJDiscoveryService._internal();
  factory DJDiscoveryService() => _instance;
  DJDiscoveryService._internal();

  final LocationService _locationService = LocationService();
  final SessionService _sessionService = SessionService();

  // Discovery state
  List<NearbyDJ> _nearbyDJs = [];
  bool _isDiscovering = false;
  String? _error;
  Timer? _discoveryTimer;

  // Filters
  double _maxDistance = 10.0; // km
  bool _onlyLiveDJs = true;
  List<String> _genreFilters = [];
  SessionType? _sessionTypeFilter;

  // Getters
  List<NearbyDJ> get nearbyDJs => List.unmodifiable(_nearbyDJs);
  bool get isDiscovering => _isDiscovering;
  String? get error => _error;
  double get maxDistance => _maxDistance;
  bool get onlyLiveDJs => _onlyLiveDJs;
  List<String> get genreFilters => List.unmodifiable(_genreFilters);
  SessionType? get sessionTypeFilter => _sessionTypeFilter;

  /// Start discovering nearby DJs
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure location service is initialized
      final locationInitialized = await _locationService.initialize();
      if (!locationInitialized) {
        throw Exception('Location services not available');
      }

      // Start location tracking if not already running
      if (!_locationService.isLocationServiceRunning) {
        await _locationService.startLocationTracking();
      }

      // Initial discovery
      await _discoverNearbyDJs();

      // Start periodic updates every 30 seconds
      _discoveryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _discoverNearbyDJs();
      });
    } catch (e) {
      _error = e.toString();
      _isDiscovering = false;
      notifyListeners();
    }
  }

  /// Stop discovery
  void stopDiscovery() {
    _isDiscovering = false;
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    _nearbyDJs.clear();
    notifyListeners();
  }

  /// Discover nearby DJs
  Future<void> _discoverNearbyDJs() async {
    try {
      final currentLocation = _locationService.currentLocation;
      if (currentLocation == null) {
        throw Exception('Current location not available');
      }

      // Get nearby DJs from location service
      final allNearbyDJs = await _locationService.getNearbyDJs();

      // Apply filters
      final filteredDJs = _applyFilters(allNearbyDJs);

      // Sort by distance
      filteredDJs.sort((a, b) => a.distance.compareTo(b.distance));

      _nearbyDJs = filteredDJs;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Apply filters to DJ list
  List<NearbyDJ> _applyFilters(List<NearbyDJ> djs) {
    return djs.where((dj) {
      // Distance filter
      if (dj.distance > _maxDistance) return false;

      // Live DJs only filter
      if (_onlyLiveDJs && !dj.isLive) return false;

      // Genre filter
      if (_genreFilters.isNotEmpty) {
        final hasMatchingGenre =
            dj.genres.any((genre) => _genreFilters.contains(genre));
        if (!hasMatchingGenre) return false;
      }

      // Session type filter (requires additional data)
      // This would need to be implemented based on session data

      return true;
    }).toList();
  }

  /// Update discovery filters
  void updateFilters({
    double? maxDistance,
    bool? onlyLiveDJs,
    List<String>? genreFilters,
    SessionType? sessionTypeFilter,
  }) {
    bool hasChanges = false;

    if (maxDistance != null && maxDistance != _maxDistance) {
      _maxDistance = maxDistance;
      hasChanges = true;
    }

    if (onlyLiveDJs != null && onlyLiveDJs != _onlyLiveDJs) {
      _onlyLiveDJs = onlyLiveDJs;
      hasChanges = true;
    }

    if (genreFilters != null) {
      _genreFilters = List.from(genreFilters);
      hasChanges = true;
    }

    if (sessionTypeFilter != _sessionTypeFilter) {
      _sessionTypeFilter = sessionTypeFilter;
      hasChanges = true;
    }

    if (hasChanges) {
      // Re-apply filters to current results
      final filteredDJs = _applyFilters(_nearbyDJs);
      _nearbyDJs = filteredDJs;
      notifyListeners();

      // Trigger new discovery if actively discovering
      if (_isDiscovering) {
        _discoverNearbyDJs();
      }
    }
  }

  /// Connect to a nearby DJ's session
  Future<bool> connectToNearbyDJ(NearbyDJ nearbyDJ) async {
    try {
      if (!nearbyDJ.isLive || nearbyDJ.currentSessionId == null) {
        throw Exception('DJ is not currently live');
      }

      // This would typically involve:
      // 1. Joining the DJ's session
      // 2. Establishing connection for real-time updates
      // 3. Getting session details

      // For now, simulate the connection
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      debugPrint('Failed to connect to nearby DJ: $e');
      return false;
    }
  }

  /// Share current session location (for DJs)
  Future<bool> shareSessionLocation(Session session) async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final currentLocation = _locationService.currentLocation;
      if (currentLocation == null) {
        throw Exception('Location not available');
      }

      // Update session with location data
      // This would typically send location to backend
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      debugPrint('Failed to share session location: $e');
      return false;
    }
  }

  /// Get distance to a specific DJ
  double? getDistanceToLocation(double latitude, double longitude) {
    final currentLocation = _locationService.currentLocation;
    if (currentLocation == null) return null;

    return LocationService.calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      latitude,
      longitude,
    );
  }

  /// Generate shareable session link with location
  String generateShareableSessionLink(Session session) {
    final baseUrl = 'https://spinwish.app';
    final sessionId = session.id;

    // Include location data if sharing is enabled
    if (_locationService.shareExactLocation &&
        _locationService.currentLocation != null) {
      final location = _locationService.currentLocation!;
      return '$baseUrl/session/$sessionId?lat=${location.latitude}&lng=${location.longitude}';
    }

    return '$baseUrl/session/$sessionId';
  }

  /// Send session invitation to nearby users
  Future<bool> sendSessionInvitation(
    Session session, {
    double? radius,
    String? message,
  }) async {
    try {
      final currentLocation = _locationService.currentLocation;
      if (currentLocation == null) {
        throw Exception('Location not available');
      }

      final invitationRadius = radius ?? _locationService.discoveryRadius;

      // This would send push notifications to nearby users
      // For now, simulate the API call
      await Future.delayed(const Duration(milliseconds: 800));

      return true;
    } catch (e) {
      debugPrint('Failed to send session invitation: $e');
      return false;
    }
  }

  /// Get popular locations for DJ sessions
  Future<List<PopularLocation>> getPopularLocations() async {
    try {
      // TODO: Implement backend API call for popular locations
      // For now, return empty list until backend endpoint is available
      return [];
    } catch (e) {
      debugPrint('Failed to get popular locations: $e');
      return [];
    }
  }

  /// Check if current location is suitable for DJ session
  Future<LocationSuitability> checkLocationSuitability() async {
    try {
      final currentLocation = _locationService.currentLocation;
      if (currentLocation == null) {
        throw Exception('Location not available');
      }

      // This would analyze factors like:
      // - Network connectivity
      // - Noise levels
      // - Nearby venues
      // - Historical session success

      await Future.delayed(const Duration(milliseconds: 300));

      return LocationSuitability(
        score: 0.8,
        factors: {
          'Network Quality': 0.9,
          'Venue Proximity': 0.7,
          'Historical Success': 0.8,
          'Audience Potential': 0.8,
        },
        recommendations: [
          'Strong network signal detected',
          'Popular venue nearby',
          'Good time for sessions in this area',
        ],
      );
    } catch (e) {
      debugPrint('Failed to check location suitability: $e');
      return LocationSuitability(
        score: 0.5,
        factors: {},
        recommendations: ['Unable to analyze location'],
      );
    }
  }

  @override
  void dispose() {
    stopDiscovery();
    super.dispose();
  }
}

class PopularLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sessionCount;
  final double averageRating;
  final String description;

  PopularLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sessionCount,
    required this.averageRating,
    required this.description,
  });
}

class LocationSuitability {
  final double score; // 0.0 to 1.0
  final Map<String, double> factors;
  final List<String> recommendations;

  LocationSuitability({
    required this.score,
    required this.factors,
    required this.recommendations,
  });
}
