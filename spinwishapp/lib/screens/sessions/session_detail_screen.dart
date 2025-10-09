import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/club.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/services/song_api_service.dart';
import 'package:spinwishapp/services/user_requests_service.dart'
    as request_service;
import 'package:spinwishapp/services/websocket_service.dart';
import 'package:spinwishapp/screens/requests/song_request_screen.dart';
import 'package:spinwishapp/screens/tips/tip_dj_screen.dart';

class SessionDetailScreen extends StatefulWidget {
  final Session session;
  final DJ dj;
  final Club club;
  final int initialTabIndex;

  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.dj,
    required this.club,
    this.initialTabIndex = 0,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Song? currentSong;
  List<Song> upcomingQueue = [];
  List<int?> queuePositions =
      []; // Store queue positions parallel to upcomingQueue
  List<Request> recentRequests = [];
  Map<String, Song> songCache = {}; // Cache for efficient song lookup
  bool isLoading = true;

  // WebSocket integration
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Request>? _requestUpdateSubscription;
  StreamSubscription<Session>? _sessionUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadSessionData();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cleanupWebSocket();
    super.dispose();
  }

  // Refresh data when returning to this screen
  void _refreshData() {
    _loadSessionData();
  }

  /// Initialize WebSocket connection and subscribe to updates
  Future<void> _initializeWebSocket() async {
    try {
      // Connect to WebSocket if not already connected
      if (!_webSocketService.isConnected) {
        await _webSocketService.connect();
      }

      // Subscribe to session updates
      _webSocketService.subscribeToSession(widget.session.id);

      // Listen for request updates
      _requestUpdateSubscription = _webSocketService.requestUpdates.listen(
        (updatedRequest) {
          _handleRequestUpdate(updatedRequest);
        },
        onError: (error) {
          debugPrint('Error receiving request update: $error');
        },
      );

      // Listen for session updates
      _sessionUpdateSubscription = _webSocketService.sessionUpdates.listen(
        (updatedSession) {
          _handleSessionUpdate(updatedSession);
        },
        onError: (error) {
          debugPrint('Error receiving session update: $error');
        },
      );

      debugPrint('✅ WebSocket initialized for session ${widget.session.id}');
    } catch (e) {
      debugPrint('❌ Failed to initialize WebSocket: $e');
    }
  }

  /// Cleanup WebSocket subscriptions
  void _cleanupWebSocket() {
    _requestUpdateSubscription?.cancel();
    _sessionUpdateSubscription?.cancel();
    _webSocketService.unsubscribeFromSession(widget.session.id);
    debugPrint('🧹 WebSocket cleaned up for session ${widget.session.id}');
  }

  /// Handle real-time request updates from WebSocket
  void _handleRequestUpdate(Request updatedRequest) {
    if (!mounted) return;

    // Only process updates for this session
    if (updatedRequest.sessionId != widget.session.id) return;

    setState(() {
      // Find and update the request in the list
      final index = recentRequests.indexWhere((r) => r.id == updatedRequest.id);

      if (index != -1) {
        // Update existing request
        recentRequests[index] = updatedRequest;

        // Show notification based on status change
        if (updatedRequest.status == RequestStatus.accepted) {
          _showStatusNotification('✅ Your request was accepted!', Colors.green);

          // Reload queue to reflect the accepted request
          _loadSessionData();
        } else if (updatedRequest.status == RequestStatus.rejected) {
          _showStatusNotification('❌ Your request was declined', Colors.red);
        }
      } else {
        // Add new request if not found
        recentRequests.insert(0, updatedRequest);
      }
    });

    debugPrint(
        '🔄 Request updated: ${updatedRequest.id} - ${updatedRequest.status}');
  }

  /// Handle real-time session updates from WebSocket
  void _handleSessionUpdate(Session updatedSession) {
    if (!mounted) return;

    // Only process updates for this session
    if (updatedSession.id != widget.session.id) return;

    setState(() {
      // Update current song if changed
      if (updatedSession.currentSongId != null &&
          updatedSession.currentSongId != currentSong?.id) {
        final newSong = songCache[updatedSession.currentSongId];
        if (newSong != null) {
          currentSong = newSong;
          _showStatusNotification(
              '🎵 Now playing: ${newSong.title}', Colors.blue);
        }
      }
    });

    debugPrint('🔄 Session updated: ${updatedSession.id}');
  }

  /// Show a status notification to the user
  void _showStatusNotification(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show full-screen image viewer
  void _showImageViewer(String imageUrl) {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _ImageViewerScreen(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _loadSessionData() async {
    setState(() => isLoading = true);

    try {
      // Load songs from API
      final songs = await SongApiService.getAllSongs();
      debugPrint('📀 Loaded ${songs.length} songs from API');

      // Load real requests for this session
      final requestResponses =
          await request_service.UserRequestsService.getRequestsBySession(
              widget.session.id);
      debugPrint(
          '📋 Loaded ${requestResponses.length} requests for session ${widget.session.id}');

      // Load queue (accepted requests ordered by queue position)
      final queueResponses =
          await request_service.UserRequestsService.getSessionQueue(
              widget.session.id);
      debugPrint(
          '🎵 Loaded ${queueResponses.length} queue items for session ${widget.session.id}');

      // Convert PlaySongResponse to Request model
      final requests = requestResponses.map((response) {
        // Determine status from response
        RequestStatus status;
        if (response.status) {
          status = RequestStatus.accepted;
        } else {
          status = RequestStatus.pending;
        }

        // Get song ID from response
        String songId = '';
        if (response.songResponse != null &&
            response.songResponse!.isNotEmpty) {
          songId = response.songResponse!.first.id;
        }

        return Request(
          id: response.id,
          userId: '', // Not available in PlaySongResponse
          sessionId: widget.session.id,
          songId: songId,
          status: status,
          amount: response.amount ?? 0.0,
          timestamp: response.createdAt,
          message: response.message,
          queuePosition: response.queuePosition,
        );
      }).toList();

      // Convert queue responses to Song list and extract queue positions
      final queue = <Song>[];
      final positions = <int?>[];
      for (var response in queueResponses) {
        if (response.songResponse != null &&
            response.songResponse!.isNotEmpty) {
          queue.add(response.songResponse!.first);
          positions.add(response.queuePosition);
        }
      }

      // Build song cache for efficient lookup
      final cache = <String, Song>{};
      for (var song in songs) {
        cache[song.id] = song;
      }
      // Add queue songs to cache
      for (var song in queue) {
        cache[song.id] = song;
      }

      setState(() {
        currentSong = widget.session.currentSongId != null && songs.isNotEmpty
            ? songs.firstWhere(
                (s) => s.id == widget.session.currentSongId,
                orElse: () => songs.first,
              )
            : null;
        upcomingQueue = queue;
        queuePositions = positions;
        recentRequests = requests;
        songCache = cache;
        isLoading = false;
      });

      debugPrint(
          '✅ State updated: ${recentRequests.length} requests, ${upcomingQueue.length} queue items');
    } catch (e) {
      debugPrint('❌ Error loading session data: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      setState(() {
        currentSong = null;
        upcomingQueue = [];
        queuePositions = [];
        recentRequests = [];
        songCache = {};
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load session data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildSessionInfo(theme),
            _buildCurrentlyPlaying(theme),
            _buildTabBar(theme),
            _buildTabContent(theme),
          ],
        ],
      ),
      bottomNavigationBar: isLoading ? null : _buildBottomActions(theme),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Make image tappable to view in full screen
            GestureDetector(
              onTap: () {
                if (widget.club.imageUrl.isNotEmpty) {
                  _showImageViewer(widget.club.imageUrl);
                } else if (widget.session.imageUrl != null &&
                    widget.session.imageUrl!.isNotEmpty) {
                  _showImageViewer(widget.session.imageUrl!);
                }
              },
              child: widget.club.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.club.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.nightlife,
                          size: 80,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : widget.session.imageUrl != null &&
                          widget.session.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.session.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.nightlife,
                              size: 80,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.nightlife,
                            size: 80,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.club.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'with ${widget.dj.name}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatCard(
              theme,
              Icons.people,
              '${widget.session.listeners}',
              'Listeners',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              Icons.queue_music,
              '${widget.session.upcomingRequests.length}',
              'In Queue',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              Icons.attach_money,
              'KSH ${widget.session.avgRequestPrice.toStringAsFixed(0)}',
              'Avg Request',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentlyPlaying(ThemeData theme) {
    if (currentSong == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Now Playing',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: currentSong!.artworkUrl.isNotEmpty
                      ? Image.network(
                          currentSong!.artworkUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.music_note,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.music_note,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong!.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong!.artist,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.6, // Simulate progress
                        backgroundColor:
                            theme.colorScheme.outline.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Queue'),
            Tab(text: 'Requests'),
            Tab(text: 'About'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildQueueTab(theme),
          _buildRequestsTab(theme),
          _buildAboutTab(theme),
        ],
      ),
    );
  }

  Widget _buildQueueTab(ThemeData theme) {
    if (upcomingQueue.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Queue is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accepted song requests will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingQueue.length,
      itemBuilder: (context, index) {
        final song = upcomingQueue[index];
        final queuePosition =
            queuePositions.length > index ? queuePositions[index] : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: song.artworkUrl.isNotEmpty
                  ? Image.network(
                      song.artworkUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: Text(
              '#${queuePosition ?? (index + 1)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab(ThemeData theme) {
    if (recentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No song requests yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentRequests.length,
      itemBuilder: (context, index) {
        final request = recentRequests[index];

        // Use song cache for efficient O(1) lookup
        Song song;
        if (request.songId.isNotEmpty &&
            songCache.containsKey(request.songId)) {
          song = songCache[request.songId]!;
        } else if (request.songId.isNotEmpty) {
          // Song not in cache, create placeholder
          song = Song(
            id: request.songId,
            title: 'Unknown Song',
            artist: 'Unknown Artist',
            album: '',
            genre: '',
            duration: 0,
            artworkUrl: '',
            baseRequestPrice: 0.0,
            popularity: 0,
            isExplicit: false,
          );
        } else {
          // No song ID
          song = Song(
            id: '',
            title: 'Unknown Song',
            artist: 'Unknown Artist',
            album: '',
            genre: '',
            duration: 0,
            artworkUrl: '',
            baseRequestPrice: 0.0,
            popularity: 0,
            isExplicit: false,
          );
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: song.artworkUrl.isNotEmpty
                  ? Image.network(
                      song.artworkUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            title: Text(song.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.artist),
                if (request.message != null && request.message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${request.message}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(request.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    if (request.queuePosition != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.queue_music,
                        size: 12,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#${request.queuePosition}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KSH ${request.amount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(theme, request.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(theme, 'DJ', widget.dj.name, Icons.headphones),
          _buildInfoSection(theme, 'Club', widget.club.name, Icons.nightlife),
          _buildInfoSection(
              theme, 'Address', widget.club.address, Icons.location_on),
          _buildInfoSection(
            theme,
            'Started',
            _formatTime(widget.session.startTime),
            Icons.access_time,
          ),
          const SizedBox(height: 16),
          Text(
            'Genres',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.dj.genres
                .map((genre) => Chip(
                      label: Text(genre),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Navigate to song request screen and wait for result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongRequestScreen(
                        session: widget.session,
                        dj: widget.dj,
                        club: widget.club,
                      ),
                    ),
                  );

                  // Refresh data if a request was made
                  if (result == true && mounted) {
                    _refreshData();
                  }
                },
                icon: const Icon(Icons.queue_music),
                label: const Text('Request Song'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TipDJScreen(
                        dj: widget.dj,
                        session: widget.session,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Tip DJ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(ThemeData theme, RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.played:
        return Colors.green;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.played:
        return 'Played';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

/// Full-screen image viewer with pinch-to-zoom and pan gestures
class _ImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  const _ImageViewerScreen({required this.imageUrl});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // Reset zoom
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom in to 2x at tap position
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              final currentScale =
                  _transformationController.value.getMaxScaleOnAxis();
              if (currentScale < 3.0) {
                _transformationController.value = Matrix4.identity()
                  ..scale(currentScale + 0.5);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              final currentScale =
                  _transformationController.value.getMaxScaleOnAxis();
              if (currentScale > 1.0) {
                _transformationController.value = Matrix4.identity()
                  ..scale(currentScale - 0.5);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
