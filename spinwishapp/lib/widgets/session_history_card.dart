import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';

class SessionHistoryCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionHistoryCard({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = _calculateDuration();
    final earnings = session.totalEarnings ?? 0.0;
    final tips = session.totalTips ?? 0.0;
    final requests = session.totalRequests ?? 0;
    final listeners = session.listenerCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Session Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(theme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(theme),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Session Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm')
                              .format(session.startTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    context,
                    Icons.access_time,
                    duration,
                    'Duration',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    Icons.people,
                    listeners.toString(),
                    'Listeners',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    Icons.queue_music,
                    requests.toString(),
                    'Requests',
                  ),
                  const Spacer(),
                  _buildEarningsChip(context, earnings + tips),
                ],
              ),

              // Genres (if any)
              if (session.genres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: session.genres
                      .take(3)
                      .map(
                        (genre) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            genre,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsChip(BuildContext context, double amount) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          Text(
            amount.toStringAsFixed(2),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
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

  IconData _getTypeIcon() {
    switch (session.type) {
      case SessionType.club:
        return Icons.location_on;
      case SessionType.online:
        return Icons.wifi;
    }
  }

  Color _getTypeColor(ThemeData theme) {
    switch (session.type) {
      case SessionType.club:
        return theme.colorScheme.secondary;
      case SessionType.online:
        return theme.colorScheme.primary;
    }
  }

  String _getStatusText() {
    switch (session.status) {
      case SessionStatus.preparing:
        return 'Preparing';
      case SessionStatus.live:
        return 'Live';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.ended:
        return 'Ended';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (session.status) {
      case SessionStatus.preparing:
        return Colors.orange;
      case SessionStatus.live:
        return Colors.green;
      case SessionStatus.paused:
        return Colors.amber;
      case SessionStatus.ended:
        return theme.colorScheme.onSurface.withOpacity(0.6);
    }
  }
}
