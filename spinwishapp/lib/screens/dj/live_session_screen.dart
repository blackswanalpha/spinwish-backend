import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/session_analytics_service.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/websocket_service.dart';
import 'package:spinwishapp/services/real_time_request_service.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:spinwishapp/screens/dj/widgets/analytics_card.dart';
import 'package:spinwishapp/screens/dj/widgets/session_details_tab.dart';
import 'package:spinwishapp/screens/dj/widgets/song_requests_tab.dart';
import 'package:spinwishapp/screens/dj/widgets/queue_tab.dart';
import 'package:spinwishapp/screens/dj/widgets/playlist_tab.dart';
import 'package:spinwishapp/screens/dj/widgets/earnings_tab.dart';

/// Comprehensive Live Session screen for DJs
/// Displays real-time analytics, song requests, queue, and earnings
class LiveSessionScreen extends StatefulWidget {
  final Session session;

  const LiveSessionScreen({
    super.key,
    required this.session,
  });

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SessionAnalyticsService _analyticsService;
  late WebSocketService _webSocketService;
  late RealTimeRequestService _realTimeRequestService;
  Timer? _refreshTimer;
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;
  StreamSubscription? _sessionUpdateSubscription;
  StreamSubscription? _requestUpdateSubscription;
  StreamSubscription? _tipUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _analyticsService = SessionAnalyticsService();
    _webSocketService = WebSocketService();
    _realTimeRequestService = RealTimeRequestService();
    _loadInitialData();
    _startRefreshTimer();
    _startSessionTimer();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _sessionTimer?.cancel();
    _sessionUpdateSubscription?.cancel();
    _requestUpdateSubscription?.cancel();
    _tipUpdateSubscription?.cancel();
    super.dispose();
  }

  void _loadInitialData() {
    _analyticsService.fetchSessionAnalytics(widget.session.id);
  }

  void _initializeWebSocket() async {
    try {
      // Connect to WebSocket if not already connected
      if (!_webSocketService.isConnected) {
        await _webSocketService.connect();
      }

      // Subscribe to session updates
      _webSocketService.subscribeToSession(widget.session.id);

      // Subscribe to tip updates
      _webSocketService.subscribeToTips(widget.session.id);

      // Listen to session updates
      _sessionUpdateSubscription = _webSocketService.sessionUpdates.listen(
        (updatedSession) {
          if (mounted && updatedSession.id == widget.session.id) {
            // Refresh analytics when session updates
            _analyticsService.refreshAnalytics();
            setState(() {});
          }
        },
        onError: (error) {
          debugPrint('Session update error: $error');
        },
      );

      // Connect real-time request service
      await _realTimeRequestService.connect();

      // Listen to request updates
      _requestUpdateSubscription = _webSocketService.requestUpdates.listen(
        (request) {
          if (mounted && request.sessionId == widget.session.id) {
            // Refresh analytics when new request arrives
            _analyticsService.refreshAnalytics();

            // Show notification for new request
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New song request received!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onError: (error) {
          debugPrint('Request update error: $error');
        },
      );

      // Listen to tip updates
      _tipUpdateSubscription = _webSocketService.tipUpdates.listen(
        (tip) {
          if (mounted && tip.sessionId == widget.session.id) {
            // Refresh analytics when new tip arrives
            _analyticsService.refreshAnalytics();

            // Show notification for new tip
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '💰 New tip received: KSH ${tip.amount.toStringAsFixed(0)}!'),
                backgroundColor: Colors.purple,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onError: (error) {
          debugPrint('Tip update error: $error');
        },
      );

      debugPrint('WebSocket initialized for session: ${widget.session.id}');
    } catch (e) {
      debugPrint('Failed to initialize WebSocket: $e');
      // Show error to user but don't block the UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Real-time updates may be delayed'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _startRefreshTimer() {
    // Refresh analytics every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _analyticsService.refreshAnalytics();
      }
    });
  }

  void _startSessionTimer() {
    // Calculate initial duration
    _sessionDuration = DateTime.now().difference(widget.session.startTime);

    // Update timer every second
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionDuration =
              DateTime.now().difference(widget.session.startTime);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _stopSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Session'),
        content: const Text(
          'Are you sure you want to stop this session? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop Session'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final sessionService =
            Provider.of<SessionService>(context, listen: false);
        await sessionService.endSession();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session stopped successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to stop session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareSession() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: SpinWishDesignSystem.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Session',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SpinWishDesignSystem.gapVerticalLG,
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR Code'),
              subtitle: const Text('Generate QR code for easy joining'),
              onTap: () {
                Navigator.pop(context);
                _showQRCodeDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              subtitle: const Text('Copy session link to clipboard'),
              onTap: () {
                Navigator.pop(context);
                _copySessionLink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to Social Media'),
              subtitle: const Text('Share via apps and social media'),
              onTap: () {
                Navigator.pop(context);
                _shareToSocialMedia();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copySessionLink() {
    final sessionLink = widget.session.shareableLink ??
        'https://spinwish.app/session/${widget.session.id}';

    Clipboard.setData(ClipboardData(text: sessionLink));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session link copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToSocialMedia() async {
    final sessionLink = widget.session.shareableLink ??
        'https://spinwish.app/session/${widget.session.id}';

    final shareText = '''
🎵 Join my live DJ session on SpinWish!

${widget.session.title}
${widget.session.description ?? ''}

Session Type: ${widget.session.type == SessionType.club ? '🏢 Club Session' : '🌐 Online Session'}
${widget.session.genres.isNotEmpty ? 'Genres: ${widget.session.genres.join(', ')}' : ''}

🔗 Join here: $sessionLink

#SpinWish #LiveDJ #Music
''';

    try {
      await Share.share(
        shareText,
        subject: 'Join my SpinWish DJ Session',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_2,
              size: 200,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'QR Code generation coming soon!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Session ID: ${widget.session.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copySessionLink();
            },
            child: const Text('Copy Link Instead'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _analyticsService,
      child: Scaffold(
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            // Analytics Cards Section
            _buildAnalyticsSection(theme),

            SpinWishDesignSystem.gapVerticalMD,

            // Tab Bar
            _buildTabBar(theme),

            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.session.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _shareSession,
          icon: const Icon(Icons.share),
          tooltip: 'Share Session',
        ),
        IconButton(
          onPressed: () {
            // TODO: Open session settings
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Session Settings',
        ),
        IconButton(
          onPressed: _stopSession,
          icon: const Icon(Icons.stop_circle, color: Colors.red),
          tooltip: 'Stop Session',
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(ThemeData theme) {
    return Consumer<SessionAnalyticsService>(
      builder: (context, service, child) {
        if (service.isLoading && service.currentAnalytics == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(SpinWishDesignSystem.spaceLG),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final analytics = service.currentAnalytics;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: SpinWishDesignSystem.paddingHorizontalMD,
          child: Row(
            children: [
              AnalyticsCard(
                title: 'Session Earnings',
                mainValue:
                    'KSH ${analytics?.totalEarnings.toStringAsFixed(2) ?? '0.00'}',
                icon: Icons.monetization_on,
                color: Colors.green,
                subMetrics: [
                  SubMetric(
                    label: 'Tips',
                    value:
                        'KSH ${analytics?.totalTips.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.favorite,
                  ),
                  SubMetric(
                    label: 'Requests',
                    value:
                        'KSH ${analytics?.totalRequestPayments.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.music_note,
                  ),
                  SubMetric(
                    label: 'Per Hour',
                    value:
                        'KSH ${analytics?.earningsPerHour.toStringAsFixed(2) ?? '0.00'}/hr',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
              SpinWishDesignSystem.gapHorizontalMD,
              AnalyticsCard(
                title: 'Song Requests',
                mainValue: '${analytics?.totalRequests ?? 0}',
                icon: Icons.queue_music,
                color: Colors.purple,
                subMetrics: [
                  SubMetric(
                    label: 'Pending',
                    value: '${analytics?.pendingRequests ?? 0}',
                    icon: Icons.pending,
                    badge: analytics?.pendingRequests ?? 0,
                  ),
                  SubMetric(
                    label: 'Accepted',
                    value: '${analytics?.acceptedRequests ?? 0}',
                    icon: Icons.check_circle,
                  ),
                  SubMetric(
                    label: 'Acceptance Rate',
                    value:
                        '${analytics?.acceptanceRate.toStringAsFixed(1) ?? '0.0'}%',
                    icon: Icons.percent,
                  ),
                ],
              ),
              SpinWishDesignSystem.gapHorizontalMD,
              AnalyticsCard(
                title: 'Session Duration',
                mainValue: _formatDuration(_sessionDuration),
                icon: Icons.timer,
                color: Colors.orange,
                subMetrics: [
                  SubMetric(
                    label: 'Started',
                    value:
                        DateFormat('h:mm a').format(widget.session.startTime),
                    icon: Icons.access_time,
                  ),
                  SubMetric(
                    label: 'Listeners',
                    value: '${analytics?.activeListeners ?? 0}',
                    icon: Icons.people,
                  ),
                  SubMetric(
                    label: 'Requests/Hr',
                    value:
                        '${analytics?.requestsPerHour.toStringAsFixed(1) ?? '0.0'}',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Details',
          ),
          Tab(
            icon: Icon(Icons.music_note),
            text: 'Requests',
          ),
          Tab(
            icon: Icon(Icons.queue_music),
            text: 'Queue',
          ),
          Tab(
            icon: Icon(Icons.playlist_play),
            text: 'Playlist',
          ),
          Tab(
            icon: Icon(Icons.attach_money),
            text: 'Earnings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        SessionDetailsTab(session: widget.session),
        SongRequestsTab(sessionId: widget.session.id),
        QueueTab(sessionId: widget.session.id),
        PlaylistTab(sessionId: widget.session.id),
        EarningsTab(sessionId: widget.session.id),
      ],
    );
  }
}
