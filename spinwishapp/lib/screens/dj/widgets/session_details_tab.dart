import 'package:flutter/material.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:intl/intl.dart';

/// Session Details Tab - Displays comprehensive session information
class SessionDetailsTab extends StatelessWidget {
  final Session session;

  const SessionDetailsTab({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh session data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: SpinWishDesignSystem.paddingMD,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Status Badge
            _buildStatusBadge(theme),

            SpinWishDesignSystem.gapVerticalLG,

            // Session Title and Description
            _buildSessionInfo(theme),

            SpinWishDesignSystem.gapVerticalLG,

            // Session Details Cards
            _buildDetailsCard(
              theme,
              'Session Information',
              Icons.info_outline,
              [
                _DetailRow(
                    'Type',
                    session.type == SessionType.club ? 'Club' : 'Online',
                    Icons.category),
                _DetailRow(
                    'Club ID', session.clubId ?? 'N/A', Icons.location_on),
                _DetailRow(
                    'Started',
                    DateFormat('MMM dd, yyyy h:mm a').format(session.startTime),
                    Icons.access_time),
                _DetailRow(
                    'Status', _getStatusText(session.status), Icons.circle),
              ],
            ),

            SpinWishDesignSystem.gapVerticalMD,

            // Genre Tags
            if (session.genres.isNotEmpty) _buildGenreTags(theme),

            SpinWishDesignSystem.gapVerticalMD,

            // Currently Playing (Placeholder)
            _buildCurrentlyPlaying(theme),

            SpinWishDesignSystem.gapVerticalMD,

            // Engagement Metrics
            _buildEngagementMetrics(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpinWishDesignSystem.spaceMD,
        vertical: SpinWishDesignSystem.spaceSM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
        boxShadow: SpinWishDesignSystem.glowMD(Colors.red),
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
          SpinWishDesignSystem.gapHorizontalSM,
          Text(
            'LIVE SESSION',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (session.description != null && session.description!.isNotEmpty) ...[
          SpinWishDesignSystem.gapVerticalSM,
          Text(
            session.description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsCard(
    ThemeData theme,
    String title,
    IconData icon,
    List<_DetailRow> details,
  ) {
    return Container(
      padding: SpinWishDesignSystem.paddingLG,
      decoration: SpinWishDesignSystem.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalMD,
          ...details.map((detail) => Padding(
                padding:
                    const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceSM),
                child: Row(
                  children: [
                    Icon(
                      detail.icon,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SpinWishDesignSystem.gapHorizontalSM,
                    Text(
                      detail.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      detail.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGenreTags(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SpinWishDesignSystem.gapVerticalSM,
        Wrap(
          spacing: SpinWishDesignSystem.spaceSM,
          runSpacing: SpinWishDesignSystem.spaceSM,
          children: session.genres
              .map((genre) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpinWishDesignSystem.spaceMD,
                      vertical: SpinWishDesignSystem.spaceSM,
                    ),
                    decoration: SpinWishDesignSystem.chipDecoration(theme),
                    child: Text(
                      genre,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCurrentlyPlaying(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: theme.colorScheme.primary),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Currently Playing',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalMD,
          Row(
            children: [
              // Placeholder for album artwork
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(SpinWishDesignSystem.radiusMD),
                ),
                child: Icon(
                  Icons.music_note,
                  size: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              SpinWishDesignSystem.gapHorizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No song playing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SpinWishDesignSystem.gapVerticalXS,
                    Text(
                      'Start playing from queue or playlist',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingLG,
      decoration: SpinWishDesignSystem.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: theme.colorScheme.primary),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Engagement Metrics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(theme, Icons.people, '0', 'Listeners'),
              _buildMetricItem(theme, Icons.music_note, '0', 'Requests'),
              _buildMetricItem(theme, Icons.favorite, '0', 'Tips'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 32),
        SpinWishDesignSystem.gapVerticalSM,
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
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

  /// Helper method to convert SessionStatus enum to readable string
  String _getStatusText(SessionStatus status) {
    switch (status) {
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
}

class _DetailRow {
  final String label;
  final String value;
  final IconData icon;

  _DetailRow(this.label, this.value, this.icon);
}
