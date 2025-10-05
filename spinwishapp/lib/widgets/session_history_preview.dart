import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/services/session_history_service.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/widgets/session_insights_widget.dart';
import 'package:spinwishapp/screens/dj/session_detail_screen.dart';

class SessionHistoryPreview extends StatefulWidget {
  const SessionHistoryPreview({super.key});

  @override
  State<SessionHistoryPreview> createState() => _SessionHistoryPreviewState();
}

class _SessionHistoryPreviewState extends State<SessionHistoryPreview> {
  @override
  void initState() {
    super.initState();
    // Load session history when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyService =
          Provider.of<SessionHistoryService>(context, listen: false);
      if (!historyService.hasData) {
        historyService.loadSessionHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer<SessionHistoryService>(
              builder: (context, historyService, child) {
                return TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/session-history');
                  },
                  icon: const Icon(Icons.history),
                  label: Text(historyService.hasData
                      ? 'View All (${historyService.allSessions.length})'
                      : 'View All'),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<SessionHistoryService>(
          builder: (context, historyService, child) {
            if (historyService.isLoading) {
              return _buildLoadingState(theme);
            }

            if (historyService.error != null) {
              return _buildErrorState(theme, historyService.error!);
            }

            if (!historyService.hasData) {
              return _buildEmptyState(theme);
            }

            return _buildSessionsList(
                theme, historyService.allSessions.take(3).toList());
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading session history...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Provider.of<SessionHistoryService>(context, listen: false)
                  .loadSessionHistory(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first session to see it here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(ThemeData theme, List<Session> sessions) {
    return Column(
      children: [
        // Quick stats row
        _buildQuickStats(theme, sessions),

        const SizedBox(height: 16),

        // Insights (if enough data)
        if (sessions.length >= 5) ...[
          SessionInsightsWidget(sessions: sessions),
          const SizedBox(height: 16),
        ],

        // Recent sessions list
        ...sessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSessionCard(theme, session),
            )),

        if (sessions.length >= 3) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/session-history');
            },
            child: const Text('View more sessions'),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme, List<Session> sessions) {
    final totalEarnings =
        sessions.fold<double>(0.0, (sum, s) => sum + (s.totalEarnings ?? 0.0));
    final totalRequests =
        sessions.fold<int>(0, (sum, s) => sum + (s.totalRequests ?? 0));
    final avgListeners = sessions.isNotEmpty
        ? (sessions.fold<int>(0, (sum, s) => sum + (s.listenerCount ?? 0)) /
                sessions.length)
            .round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, 'Earnings',
              '\$${totalEarnings.toStringAsFixed(0)}', Icons.attach_money),
          _buildStatItem(
              theme, 'Requests', totalRequests.toString(), Icons.queue_music),
          _buildStatItem(
              theme, 'Avg Listeners', avgListeners.toString(), Icons.people),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, String label, String value, IconData icon) {
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
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

  Widget _buildSessionCard(ThemeData theme, Session session) {
    final duration = _calculateDuration(session);
    final earnings =
        (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailScreen(session: session),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Session type icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(theme, session.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(session.type),
                color: _getTypeColor(theme, session.type),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd • HH:mm').format(session.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${earnings.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDuration(Session session) {
    if (session.endTime == null) {
      return 'Ongoing';
    }

    final duration = session.endTime!.difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.club:
        return Icons.location_on;
      case SessionType.online:
        return Icons.wifi;
    }
  }

  Color _getTypeColor(ThemeData theme, SessionType type) {
    switch (type) {
      case SessionType.club:
        return theme.colorScheme.secondary;
      case SessionType.online:
        return theme.colorScheme.primary;
    }
  }
}
