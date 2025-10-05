import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const MethodChannel _channel = MethodChannel('location_service');

  // Location state
  LocationData? _currentLocation;
  bool _isLocationEnabled = false;
  bool _hasLocationPermission = false;
  bool _isLocationServiceRunning = false;
  StreamSubscription<LocationData>? _locationSubscription;

  // Privacy settings
  bool _isDiscoverable = false;
  double _discoveryRadius = 5.0; // km
  bool _shareExactLocation = false;
  bool _onlyShowWhenLive = true;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get isLocationServiceRunning => _isLocationServiceRunning;
  bool get isDiscoverable => _isDiscoverable;
  double get discoveryRadius => _discoveryRadius;
  bool get shareExactLocation => _shareExactLocation;
  bool get onlyShowWhenLive => _onlyShowWhenLive;

  /// Initialize location service
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      _isLocationEnabled = result['isLocationEnabled'] ?? false;
      _hasLocationPermission = result['hasPermission'] ?? false;

      if (_hasLocationPermission && _isLocationEnabled) {
        await _getCurrentLocation();
      }

      notifyListeners();
      return _hasLocationPermission && _isLocationEnabled;
    } catch (e) {
      debugPrint('Failed to initialize location service: $e');
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final result = await _channel.invokeMethod('requestPermission');
      _hasLocationPermission = result['granted'] ?? false;

      if (_hasLocationPermission) {
        await _checkLocationEnabled();
        if (_isLocationEnabled) {
          await _getCurrentLocation();
        }
      }

      notifyListeners();
      return _hasLocationPermission;
    } catch (e) {
      debugPrint('Failed to request location permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> _checkLocationEnabled() async {
    try {
      final result = await _channel.invokeMethod('isLocationEnabled');
      _isLocationEnabled = result ?? false;
      return _isLocationEnabled;
    } catch (e) {
      debugPrint('Failed to check location enabled: $e');
      return false;
    }
  }

  /// Get current location
  Future<LocationData?> _getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod('getCurrentLocation');
      if (result != null) {
        _currentLocation = LocationData.fromMap(result);
        notifyListeners();
        return _currentLocation;
      }
    } catch (e) {
      debugPrint('Failed to get current location: $e');
    }
    return null;
  }

  /// Start location tracking
  Future<bool> startLocationTracking() async {
    if (!_hasLocationPermission || !_isLocationEnabled) {
      return false;
    }

    try {
      await _channel.invokeMethod('startLocationTracking');
      _isLocationServiceRunning = true;

      // Start listening for location updates
      _locationSubscription = _getLocationStream().listen((location) {
        _currentLocation = location;
        notifyListeners();
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to start location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    try {
      await _channel.invokeMethod('stopLocationTracking');
      _isLocationServiceRunning = false;
      _locationSubscription?.cancel();
      _locationSubscription = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to stop location tracking: $e');
    }
  }

  /// Get location stream (simulated for now)
  Stream<LocationData> _getLocationStream() async* {
    while (_isLocationServiceRunning) {
      await Future.delayed(const Duration(seconds: 10));
      if (_currentLocation != null) {
        // Simulate small location changes
        final random = Random();
        final latChange = (random.nextDouble() - 0.5) * 0.001;
        final lngChange = (random.nextDouble() - 0.5) * 0.001;

        yield LocationData(
          latitude: _currentLocation!.latitude + latChange,
          longitude: _currentLocation!.longitude + lngChange,
          accuracy: _currentLocation!.accuracy,
          timestamp: DateTime.now(),
        );
      }
    }
  }

  /// Update discovery settings
  Future<void> updateDiscoverySettings({
    bool? isDiscoverable,
    double? discoveryRadius,
    bool? shareExactLocation,
    bool? onlyShowWhenLive,
  }) async {
    if (isDiscoverable != null) _isDiscoverable = isDiscoverable;
    if (discoveryRadius != null) _discoveryRadius = discoveryRadius;
    if (shareExactLocation != null) _shareExactLocation = shareExactLocation;
    if (onlyShowWhenLive != null) _onlyShowWhenLive = onlyShowWhenLive;

    // Save settings to backend
    try {
      await _channel.invokeMethod('updateDiscoverySettings', {
        'isDiscoverable': _isDiscoverable,
        'discoveryRadius': _discoveryRadius,
        'shareExactLocation': _shareExactLocation,
        'onlyShowWhenLive': _onlyShowWhenLive,
      });
    } catch (e) {
      debugPrint('Failed to update discovery settings: $e');
    }

    notifyListeners();
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get formatted distance string
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Get nearby DJs based on current location
  Future<List<NearbyDJ>> getNearbyDJs() async {
    if (_currentLocation == null) {
      throw Exception('Location not available');
    }

    try {
      final result = await _channel.invokeMethod('getNearbyDJs', {
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'radius': _discoveryRadius,
      });

      if (result != null && result is List) {
        return result.map((djData) => NearbyDJ.fromMap(djData)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Failed to get nearby DJs: $e');
      return [];
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      await _channel.invokeMethod('openLocationSettings');
    } catch (e) {
      debugPrint('Failed to open location settings: $e');
    }
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class NearbyDJ {
  final String id;
  final String name;
  final String profileImage;
  final double latitude;
  final double longitude;
  final double distance;
  final bool isLive;
  final String? currentSessionId;
  final String? currentSessionTitle;
  final int listenerCount;
  final List<String> genres;
  final String? clubName;
  final bool shareExactLocation;

  NearbyDJ({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.isLive,
    this.currentSessionId,
    this.currentSessionTitle,
    required this.listenerCount,
    required this.genres,
    this.clubName,
    required this.shareExactLocation,
  });

  factory NearbyDJ.fromMap(Map<String, dynamic> map) {
    return NearbyDJ(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      distance: map['distance']?.toDouble() ?? 0.0,
      isLive: map['isLive'] ?? false,
      currentSessionId: map['currentSessionId'],
      currentSessionTitle: map['currentSessionTitle'],
      listenerCount: map['listenerCount'] ?? 0,
      genres: List<String>.from(map['genres'] ?? []),
      clubName: map['clubName'],
      shareExactLocation: map['shareExactLocation'] ?? false,
    );
  }
}
