import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/session_api_service.dart';
import 'package:spinwishapp/widgets/session_export_dialog.dart';
import 'package:spinwishapp/screens/dj/live_session_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;

  const SessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SessionShareDialog(session: session),
              );
            },
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context),

            const SizedBox(height: 24),

            // Performance Metrics
            _buildPerformanceMetrics(context),

            const SizedBox(height: 24),

            // Session Details
            _buildSessionDetails(context),

            const SizedBox(height: 24),

            // Genres
            if (session.genres.isNotEmpty) ...[
              _buildGenresSection(context),
              const SizedBox(height: 24),
            ],

            // Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final duration = _calculateDuration();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor(theme).withOpacity(0.1),
            _getTypeColor(theme).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTypeColor(theme).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTypeColor(theme).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(),
                  size: 16,
                  color: _getTypeColor(theme),
                ),
                const SizedBox(width: 4),
                Text(
                  session.type == SessionType.club
                      ? 'Club Session'
                      : 'Online Session',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getTypeColor(theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            session.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          if (session.description != null &&
              session.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              session.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Date and Duration
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(session.startTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Time Range
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('HH:mm').format(session.startTime)} - ${session.endTime != null ? DateFormat('HH:mm').format(session.endTime!) : 'Ongoing'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    final theme = Theme.of(context);
    final earnings =
        (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMetricCard(
              context,
              'Total Earnings',
              'KSH ${earnings.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildMetricCard(
              context,
              'Listeners',
              '${session.listenerCount ?? 0}',
              Icons.people,
              theme.colorScheme.primary,
            ),
            _buildMetricCard(
              context,
              'Requests',
              '${session.totalRequests ?? 0}',
              Icons.queue_music,
              Colors.orange,
            ),
            _buildMetricCard(
              context,
              'Tips',
              'KSH ${(session.totalTips ?? 0.0).toStringAsFixed(2)}',
              Icons.favorite,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                  context, 'Status', _getStatusText(), _getStatusColor(theme)),
              _buildDetailRow(context, 'Session ID', session.id),
              _buildDetailRow(context, 'DJ ID', session.djId),
              if (session.clubId != null)
                _buildDetailRow(context, 'Club ID', session.clubId!),
              _buildDetailRow(context, 'Accepting Requests',
                  session.isAcceptingRequests == true ? 'Yes' : 'No'),
              if (session.minTipAmount != null)
                _buildDetailRow(context, 'Min Tip Amount',
                    'KSH ${session.minTipAmount!.toStringAsFixed(2)}'),
              _buildDetailRow(context, 'Accepted Requests',
                  '${session.acceptedRequests ?? 0}'),
              _buildDetailRow(context, 'Rejected Requests',
                  '${session.rejectedRequests ?? 0}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      [Color? valueColor]) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: session.genres
              .map(
                (genre) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Session Button (show for LIVE or PREPARING sessions)
        if (session.status == SessionStatus.live ||
            session.status == SessionStatus.preparing) ...[
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveSessionScreen(session: session),
                ),
              );
            },
            icon: const Icon(Icons.live_tv),
            label: const Text('View Live Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Stop Session Button (only show for LIVE sessions)
        if (session.status == SessionStatus.live) ...[
          ElevatedButton.icon(
            onPressed: () => _showStopSessionDialog(context),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (session.shareableLink != null) ...[
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SessionShareDialog(session: session),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SessionExportDialog(sessions: [session]),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Export Data'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  void _showStopSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Session'),
          content: const Text(
            'Are you sure you want to stop this live session? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _stopSession(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop Session'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _stopSession(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call API to end session
      await SessionApiService.endSession(session.id);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session stopped successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop session: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
