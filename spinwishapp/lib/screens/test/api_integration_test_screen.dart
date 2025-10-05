import 'package:flutter/material.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/services/favorites_service.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/services/dj_api_service.dart';
import 'package:spinwishapp/services/song_api_service.dart';
import 'package:spinwishapp/utils/api_state_manager.dart';

import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/song.dart';

class ApiIntegrationTestScreen extends StatefulWidget {
  const ApiIntegrationTestScreen({super.key});

  @override
  State<ApiIntegrationTestScreen> createState() =>
      _ApiIntegrationTestScreenState();
}

class _ApiIntegrationTestScreenState extends State<ApiIntegrationTestScreen>
    with ApiStateManagerMixin {
  late final ApiStateManager<User> _userStateManager;
  late final ListApiStateManager<DJ> _djsStateManager;
  late final ListApiStateManager<Song> _songsStateManager;
  late final ListApiStateManager<FavoriteItem> _favoritesStateManager;
  late final ListApiStateManager<PlaySongResponse> _requestsStateManager;

  final List<String> _testResults = [];
  bool _isRunningTests = false;

  @override
  void initState() {
    super.initState();
    _userStateManager = getStateManager<User>('user');
    _djsStateManager = getListStateManager<DJ>('djs');
    _songsStateManager = getListStateManager<Song>('songs');
    _favoritesStateManager = getListStateManager<FavoriteItem>('favorites');
    _requestsStateManager = getListStateManager<PlaySongResponse>('requests');

    // Add listeners for state changes
    _userStateManager.addListener(_onStateChanged);
    _djsStateManager.addListener(_onStateChanged);
    _songsStateManager.addListener(_onStateChanged);
    _favoritesStateManager.addListener(_onStateChanged);
    _requestsStateManager.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunningTests ? null : _runAllTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Test Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunningTests ? null : _runAllTests,
                    child: _isRunningTests
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Running Tests...'),
                            ],
                          )
                        : const Text('Run All Tests'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _clearResults,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Test Results
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTestSection('Authentication Tests', [
                  _buildTestButton(
                      'Test Current User', _testCurrentUser, _userStateManager),
                  _buildTestButton(
                      'Test User Authentication', _testAuthentication, null),
                ]),
                _buildTestSection('Data Loading Tests', [
                  _buildTestButton('Load DJs', _testLoadDJs, _djsStateManager),
                  _buildTestButton(
                      'Load Songs', _testLoadSongs, _songsStateManager),
                ]),
                _buildTestSection('Favorites Tests', [
                  _buildTestButton('Load Favorites', _testLoadFavorites,
                      _favoritesStateManager),
                  _buildTestButton(
                      'Add/Remove Favorite DJ', _testFavoriteOperations, null),
                ]),
                _buildTestSection('Requests Tests', [
                  _buildTestButton('Load My Requests', _testLoadRequests,
                      _requestsStateManager),
                  _buildTestButton(
                      'Create Song Request', _testCreateRequest, null),
                ]),
                const SizedBox(height: 24),
                _buildResultsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
      String title, VoidCallback onPressed, ApiStateManager? stateManager) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isRunningTests ? null : onPressed,
              child: Text(title),
            ),
          ),
          const SizedBox(width: 12),
          if (stateManager != null) _buildStateIndicator(stateManager),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(ApiStateManager stateManager) {
    if (stateManager.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (stateManager.hasError) {
      return const Icon(Icons.error, color: Colors.red, size: 20);
    } else if (stateManager.hasData) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    return const SizedBox(width: 20);
  }

  Widget _buildResultsSection() {
    if (_testResults.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              Text('No test results yet. Run some tests to see results here.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._testResults.map((result) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        result.startsWith('✅')
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            result.startsWith('✅') ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(result,
                              style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    await _testAuthentication();
    await _testCurrentUser();
    await _testLoadDJs();
    await _testLoadSongs();
    await _testLoadFavorites();
    await _testLoadRequests();
    await _testFavoriteOperations();
    await _testCreateRequest();

    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _testAuthentication() async {
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      _addResult(
          '✅ Authentication check: ${isAuthenticated ? 'Authenticated' : 'Not authenticated'}');
    } catch (e) {
      _addResult('❌ Authentication test failed: $e');
    }
  }

  Future<void> _testCurrentUser() async {
    await _userStateManager.execute(() async {
      final user = await AuthService.getCurrentUser(forceRefresh: true);
      if (user != null) {
        _addResult('✅ Current user loaded: ${user.name} (${user.email})');
        return user;
      } else {
        throw Exception('No current user found');
      }
    });
  }

  Future<void> _testLoadDJs() async {
    await _djsStateManager.execute(() async {
      final djs = await DJApiService.getAllDJs();
      _addResult('✅ DJs loaded: ${djs.length} DJs found');
      return djs;
    });
  }

  Future<void> _testLoadSongs() async {
    await _songsStateManager.execute(() async {
      final songs = await SongApiService.getAllSongs();
      _addResult('✅ Songs loaded: ${songs.length} songs found');
      return songs;
    });
  }

  Future<void> _testLoadFavorites() async {
    await _favoritesStateManager.execute(() async {
      final favorites = await FavoritesService.getAllFavorites();
      _addResult('✅ Favorites loaded: ${favorites.length} favorites found');
      return favorites;
    });
  }

  Future<void> _testLoadRequests() async {
    await _requestsStateManager.execute(() async {
      final requests = await UserRequestsService.getMyRequests();
      _addResult('✅ Requests loaded: ${requests.length} requests found');
      return requests;
    });
  }

  Future<void> _testFavoriteOperations() async {
    try {
      if (_djsStateManager.hasData && _djsStateManager.data!.isNotEmpty) {
        final firstDJ = _djsStateManager.data!.first;

        // Test adding favorite
        await FavoritesService.addFavoriteDJ(firstDJ);
        _addResult('✅ Added DJ to favorites: ${firstDJ.name}');

        // Test checking if favorite
        final isFavorite = await FavoritesService.isDJFavorite(firstDJ.id);
        _addResult('✅ DJ favorite status: $isFavorite');

        // Test removing favorite
        await FavoritesService.removeFavoriteDJ(firstDJ.id);
        _addResult('✅ Removed DJ from favorites: ${firstDJ.name}');
      } else {
        _addResult('❌ No DJs available for favorite operations test');
      }
    } catch (e) {
      _addResult('❌ Favorite operations test failed: $e');
    }
  }

  Future<void> _testCreateRequest() async {
    try {
      if (_djsStateManager.hasData &&
          _djsStateManager.data!.isNotEmpty &&
          _songsStateManager.hasData &&
          _songsStateManager.data!.isNotEmpty) {
        final firstDJ = _djsStateManager.data!.first;
        final firstSong = _songsStateManager.data!.first;

        final request = await UserRequestsService.requestSong(
          djId: firstDJ.id,
          songId: firstSong.id,
          tipAmount: 5.0,
          message: 'Test request from API integration test',
        );

        _addResult('✅ Song request created: ${request.id}');
      } else {
        _addResult('❌ No DJs or songs available for request test');
      }
    } catch (e) {
      _addResult('❌ Create request test failed: $e');
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults
          .add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }
}
