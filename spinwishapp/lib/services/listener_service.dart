import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:spinwishapp/models/dj_session.dart';

class ListenerService extends ChangeNotifier {
  static final ListenerService _instance = ListenerService._internal();
  factory ListenerService() => _instance;
  ListenerService._internal();

  // Discovery state
  List<DJSession> _availableSessions = [];
  DJSession? _connectedSession;
  bool _isDiscovering = false;
  Timer? _discoveryTimer;

  // Getters
  List<DJSession> get availableSessions =>
      List.unmodifiable(_availableSessions);
  DJSession? get connectedSession => _connectedSession;
  bool get isDiscovering => _isDiscovering;
  bool get isConnected => _connectedSession != null;

  // Start discovering available DJ sessions
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    notifyListeners();

    // Simulate API call to discover sessions
    await Future.delayed(const Duration(milliseconds: 500));

    // Load available sessions from API
    await _loadAvailableSessions();

    // Start periodic updates
    _discoveryTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateAvailableSessions();
    });

    notifyListeners();
  }

  // Stop discovering sessions
  void stopDiscovery() {
    _isDiscovering = false;
    _discoveryTimer?.cancel();
    _availableSessions.clear();
    notifyListeners();
  }

  // Connect to a DJ session
  Future<bool> connectToSession(String sessionId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final session = _availableSessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      _connectedSession = session;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Disconnect from current session
  Future<void> disconnectFromSession() async {
    if (_connectedSession == null) return;

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    _connectedSession = null;
    notifyListeners();
  }

  // Send a song request
  Future<bool> sendSongRequest({
    required String songId,
    required double tipAmount,
    String? message,
  }) async {
    if (_connectedSession == null) return false;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, this would send the request to the backend
      // and the DJ would receive it in their request queue

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get session by shareable link
  Future<DJSession?> getSessionByLink(String link) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Extract session ID from link
      final sessionId = link.split('/').last;

      // Find session in available sessions or fetch from API
      final session = _availableSessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      return session;
    } catch (e) {
      return null;
    }
  }

  // Load available sessions from API
  Future<void> _loadAvailableSessions() async {
    try {
      // TODO: Replace with actual API call when session endpoint is available
      // For now, use empty list
      _availableSessions = [];
      notifyListeners();
    } catch (e) {
      _availableSessions = [];
      notifyListeners();
    }
  }

  // Update available sessions (simulate real-time changes)
  void _updateAvailableSessions() {
    if (_availableSessions.isEmpty) return;

    final random = Random();

    // Randomly update listener counts
    for (int i = 0; i < _availableSessions.length; i++) {
      final session = _availableSessions[i];
      final change = random.nextInt(5) - 2; // -2 to +2 change
      final newCount = (session.listenerCount + change).clamp(1, 100);

      _availableSessions[i] = session.copyWith(
        listenerCount: newCount,
        totalRequests: session.totalRequests + (random.nextBool() ? 1 : 0),
      );
    }

    // Occasionally add or remove a session
    if (random.nextDouble() < 0.1) {
      if (_availableSessions.length > 2 && random.nextBool()) {
        // Remove a session
        _availableSessions.removeAt(random.nextInt(_availableSessions.length));
      } else if (_availableSessions.length < 8) {
        // Add a new session
        _loadAvailableSessions();
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _discoveryTimer?.cancel();
    super.dispose();
  }
}
