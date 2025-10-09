import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/live_session_service.dart';
import 'package:spinwishapp/services/session_api_service.dart';
import 'package:spinwishapp/models/dj_session.dart';
import 'package:spinwishapp/models/session.dart' as session_model;
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/club.dart';
import 'package:spinwishapp/models/live_event.dart';
import 'package:spinwishapp/screens/sessions/session_detail_screen.dart';
import 'package:spinwishapp/screens/djs/dj_detail_screen.dart';
import 'package:spinwishapp/services/dj_api_service.dart';

import 'package:spinwishapp/widgets/sessions_header_widget.dart';
import 'package:spinwishapp/widgets/top_live_events_widget.dart';
import 'package:spinwishapp/utils/design_system.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<session_model.Session> _todaysLiveSessions = [];
  bool _isLoadingTodaySessions = false;

  @override
  void initState() {
    super.initState();
    _loadTodaysLiveSessions();
  }

  Future<void> _loadTodaysLiveSessions() async {
    setState(() => _isLoadingTodaySessions = true);
    try {
      final sessions = await SessionApiService.getTodaysLiveSessions();
      setState(() {
        _todaysLiveSessions = sessions;
        _isLoadingTodaySessions = false;
      });
    } catch (e) {
      setState(() => _isLoadingTodaySessions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load today\'s sessions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show today's sessions only
    final sessionsToShow = _todaysLiveSessions;
    final sessionCount = _todaysLiveSessions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with user profile, greeting, and action buttons
            const SessionsHeaderWidget(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: SpinWishDesignSystem.spaceMD),

                    // Live Events Section
                    _buildLiveEventsSection(theme),

                    const SizedBox(height: SpinWishDesignSystem.spaceLG),

                    // Live Sessions Section
                    _buildLiveSessionsSection(
                        theme, sessionsToShow, sessionCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveEventsSection(ThemeData theme) {
    return Consumer<LiveSessionService>(
      builder: (context, liveSessionService, child) {
        final liveSessions = liveSessionService.getTopLiveSessions();

        // Convert DJSession to LiveEvent
        final liveEvents = liveSessions.map((djSession) {
          return LiveEvent(
            id: djSession.id,
            djName: _extractDJName(djSession.title),
            profileImage: '', // Will use default avatar with gradient
            viewerCount: djSession.listenerCount,
            backgroundColors: _getGradientForGenre(djSession.genres.isNotEmpty
                ? djSession.genres.first
                : 'Electronic'),
          );
        }).toList();

        return TopLiveEventsWidget(
          liveEvents: liveEvents,
          onEventTap: (event) {
            // Find the corresponding DJ session and navigate to DJ profile
            final djSession =
                liveSessions.firstWhere((session) => session.id == event.id);
            _navigateToDJProfile(djSession);
          },
        );
      },
    );
  }

  Widget _buildLiveSessionsSection(
      ThemeData theme, List<dynamic> sessionsToShow, int sessionCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpinWishDesignSystem.spaceMD),
          child: Row(
            children: [
              Text(
                'Todays Sessions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$sessionCount Today',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpinWishDesignSystem.spaceMD),

        // Sessions List
        _isLoadingTodaySessions
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            : sessionsToShow.isEmpty
                ? _buildEmptyState(context)
                : _buildSessionsList(sessionsToShow),
      ],
    );
  }

  Widget _buildSessionsList(List<dynamic> sessionsToShow) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      itemCount: sessionsToShow.length,
      itemBuilder: (context, index) {
        final sessionItem = sessionsToShow[index];

        if (sessionItem is session_model.Session) {
          // Handle regular Session objects
          return Padding(
            padding:
                const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
            child: _buildSessionCard(sessionItem),
          );
        } else if (sessionItem is DJSession) {
          // Handle DJSession objects
          return Padding(
            padding:
                const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
            child: _buildDJSessionCard(sessionItem),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radio_button_off,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: SpinWishDesignSystem.spaceMD),
            Text(
              'No live sessions right now',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: SpinWishDesignSystem.spaceSM),
            Text(
              'Check back later for live DJ sessions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(session_model.Session session) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainer.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
          onTap: () {
            // Navigate to session detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionDetailScreen(
                  session: session,
                  dj: DJ(
                    id: session.djId,
                    name: session.title, // Use session title as DJ name for now
                    bio: session.description ?? '',
                    profileImage: '',
                    clubId: session.clubId ?? '',
                    isLive: session.status == session_model.SessionStatus.live,
                    followers: 0,
                    genres: session.genres,
                    rating: 4.5,
                    instagramHandle: '',
                  ),
                  club: Club(
                    id: session.clubId ?? 'online',
                    name: session.type == session_model.SessionType.club
                        ? 'Club Session'
                        : 'Online Session',
                    location: session.type == session_model.SessionType.club
                        ? 'Physical Location'
                        : 'Virtual',
                    address: session.type == session_model.SessionType.club
                        ? 'Club Address'
                        : 'Virtual',
                    description: session.description ?? '',
                    imageUrl: '',
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(SpinWishDesignSystem.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Icon(
                        session.type == session_model.SessionType.club
                            ? Icons.nightlife
                            : Icons.radio,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: SpinWishDesignSystem.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: session.status ==
                                          session_model.SessionStatus.live
                                      ? Colors.red
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  session.status ==
                                          session_model.SessionStatus.live
                                      ? 'LIVE'
                                      : 'STARTING',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.people,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${session.listenerCount}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SpinWishDesignSystem.spaceMD),

                // Session Description
                if (session.description?.isNotEmpty == true) ...[
                  Text(
                    session.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SpinWishDesignSystem.spaceMD),
                ],

                // Session Metrics Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        theme,
                        Icons.queue_music,
                        '${session.totalRequests ?? 0}',
                        'Requests',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildMetricItem(
                        theme,
                        Icons.monetization_on,
                        'KSH ${(session.totalEarnings ?? 0.0).toStringAsFixed(0)}',
                        'Earnings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDJSessionCard(DJSession djSession) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainer.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
          onTap: () {
            // Navigate to DJ session detail - convert DJSession to Session
            final session = session_model.Session(
              id: djSession.id,
              djId: djSession.djId,
              clubId: djSession.clubId,
              type: djSession.type == SessionType.club
                  ? session_model.SessionType.club
                  : session_model.SessionType.online,
              status: djSession.status == SessionStatus.live
                  ? session_model.SessionStatus.live
                  : session_model.SessionStatus.preparing,
              title: djSession.title,
              description: djSession.description,
              startTime: djSession.startTime,
              endTime: djSession.endTime,
              listenerCount: djSession.listenerCount,
              requestQueue: djSession.requestQueue,
              totalEarnings: djSession.totalEarnings,
              totalTips: djSession.totalTips,
              totalRequests: djSession.totalRequests,
              acceptedRequests: djSession.acceptedRequests,
              rejectedRequests: djSession.rejectedRequests,
              isAcceptingRequests: djSession.isAcceptingRequests,
              minTipAmount: djSession.minTipAmount,
              genres: djSession.genres,
              shareableLink: djSession.shareableLink,
              currentSongId: djSession.currentSongId,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionDetailScreen(
                  session: session,
                  dj: DJ(
                    id: djSession.djId,
                    name:
                        djSession.title, // Use session title as DJ name for now
                    bio: djSession.description ?? '',
                    profileImage: '',
                    clubId: djSession.clubId ?? '',
                    isLive: djSession.status == SessionStatus.live,
                    followers: 0,
                    genres: djSession.genres,
                    rating: 4.5,
                    instagramHandle: '',
                  ),
                  club: Club(
                    id: djSession.clubId ?? 'online',
                    name: djSession.type == SessionType.club
                        ? 'Club Session'
                        : 'Online Session',
                    location: djSession.type == SessionType.club
                        ? 'Physical Location'
                        : 'Virtual',
                    address: djSession.type == SessionType.club
                        ? 'Club Address'
                        : 'Virtual',
                    description: djSession.description ?? '',
                    imageUrl: '',
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(SpinWishDesignSystem.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Icon(
                        djSession.type == SessionType.club
                            ? Icons.nightlife
                            : Icons.radio,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: SpinWishDesignSystem.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            djSession.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: djSession.status == SessionStatus.live
                                      ? Colors.red
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  djSession.status == SessionStatus.live
                                      ? 'LIVE'
                                      : 'STARTING',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.people,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${djSession.listenerCount}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SpinWishDesignSystem.spaceMD),

                // Session Description
                if (djSession.description?.isNotEmpty == true)
                  Text(
                    djSession.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                // Genres
                if (djSession.genres.isNotEmpty) ...[
                  const SizedBox(height: SpinWishDesignSystem.spaceSM),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: djSession.genres.take(3).map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: SpinWishDesignSystem.spaceMD),

                // Session Metrics Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        theme,
                        Icons.queue_music,
                        '${djSession.totalRequests}',
                        'Requests',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildMetricItem(
                        theme,
                        Icons.monetization_on,
                        'KSH ${djSession.totalEarnings.toStringAsFixed(0)}',
                        'Earnings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _extractDJName(String sessionTitle) {
    // Extract DJ name from session title (e.g., "DJ Mike Live" -> "DJ Mike")
    if (sessionTitle.contains(' Live')) {
      return sessionTitle.replaceAll(' Live', '');
    } else if (sessionTitle.contains(' - ')) {
      return sessionTitle.split(' - ').first;
    } else if (sessionTitle.contains(' Night with ')) {
      final parts = sessionTitle.split(' Night with ');
      return parts.length > 1 ? parts[1] : sessionTitle;
    }
    return sessionTitle;
  }

  List<Color> _getGradientForGenre(String genre) {
    switch (genre.toLowerCase()) {
      case 'house':
      case 'progressive':
        return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
      case 'techno':
        return [const Color(0xFF06B6D4), const Color(0xFF3B82F6)];
      case 'electronic':
      case 'edm':
        return [const Color(0xFFF59E0B), const Color(0xFFEF4444)];
      case 'hip hop':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'r&b':
        return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
      case 'pop':
      case 'electro pop':
        return [const Color(0xFFEC4899), const Color(0xFFF97316)];
      case 'trance':
      case 'uplifting':
        return [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)];
      case 'dubstep':
        return [const Color(0xFF1F2937), const Color(0xFF6B7280)];
      case 'trap':
      case 'bass':
        return [const Color(0xFFDC2626), const Color(0xFF7C2D12)];
      case 'future bass':
        return [const Color(0xFF06B6D4), const Color(0xFF10B981)];
      case 'dance':
        return [const Color(0xFFF59E0B), const Color(0xFFEC4899)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  void _navigateToDJProfile(DJSession djSession) async {
    try {
      // Try to get the real DJ from database
      final dj = await DJApiService.getDJById(djSession.djId);

      if (!mounted) return;

      if (dj != null) {
        // Navigate to DJ profile with real DJ data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DJDetailScreen(dj: dj),
          ),
        );
      } else {
        // Fallback: create DJ object from session data
        final fallbackDJ = DJ(
          id: djSession.djId,
          name: _extractDJName(djSession.title),
          bio: djSession.description ?? 'Professional DJ',
          profileImage: '',
          clubId: djSession.clubId ?? '',
          isLive: djSession.status == SessionStatus.live,
          followers: 0,
          genres: djSession.genres,
          rating: 4.5,
          instagramHandle: '',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DJDetailScreen(dj: fallbackDJ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Error fallback: show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Unable to load ${_extractDJName(djSession.title)}\'s profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
