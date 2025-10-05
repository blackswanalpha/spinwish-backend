import 'package:flutter/material.dart';
import 'package:spinwishapp/models/dj_session.dart';
import 'package:spinwishapp/utils/design_system.dart';

class SessionCardCompact extends StatelessWidget {
  final DJSession session;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const SessionCardCompact({
    super.key,
    required this.session,
    this.onTap,
    this.onJoin,
  });

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.live:
        return Colors.red;
      case SessionStatus.preparing:
        return Colors.orange;
      case SessionStatus.ended:
        return Colors.grey;
      case SessionStatus.paused:
        return Colors.amber;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.live:
        return 'LIVE';
      case SessionStatus.preparing:
        return 'STARTING';
      case SessionStatus.ended:
        return 'ENDED';
      case SessionStatus.paused:
        return 'PAUSED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Session Avatar
                    _buildSessionAvatar(theme),

                    const SizedBox(width: SpinWishDesignSystem.spaceMD),

                    // Session Info
                    Expanded(
                      child: _buildSessionInfo(theme),
                    ),

                    // Status Badge
                    _buildStatusBadge(theme),
                  ],
                ),

                const SizedBox(height: SpinWishDesignSystem.spaceMD),

                // Session Details
                _buildSessionDetails(theme),

                const SizedBox(height: SpinWishDesignSystem.spaceMD),

                // Action Button
                if (session.status == SessionStatus.live && onJoin != null)
                  _buildJoinButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionAvatar(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
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
        session.type == SessionType.club ? Icons.nightlife : Icons.radio,
        color: theme.colorScheme.onPrimary,
        size: 20,
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Title
        Text(
          session.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // DJ Name (if available)
        Text(
          'DJ Session', // You might want to add DJ name to the model
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final statusColor = _getStatusColor(session.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(session.status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSessionDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (session.description?.isNotEmpty == true)
          Text(
            session.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: SpinWishDesignSystem.spaceSM),

        // Session Stats
        Row(
          children: [
            // Time
            Icon(
              Icons.access_time,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(session.startTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(width: SpinWishDesignSystem.spaceMD),

            // Listeners
            Icon(
              Icons.people,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${session.listenerCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(width: SpinWishDesignSystem.spaceMD),

            // Type
            Icon(
              session.type == SessionType.club ? Icons.location_on : Icons.wifi,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              session.type == SessionType.club ? 'Club' : 'Online',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),

        // Genres
        if (session.genres.isNotEmpty) ...[
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: session.genres.take(3).map((genre) {
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
      ],
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onJoin,
        icon: const Icon(Icons.headphones, size: 18),
        label: const Text('Join Session'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
          ),
        ),
      ),
    );
  }
}
