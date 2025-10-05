import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionAnalyticsDashboard extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const SessionAnalyticsDashboard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Cards
        _buildOverviewCards(context),

        const SizedBox(height: 24),

        // Performance Trends
        _buildPerformanceTrends(context),

        const SizedBox(height: 24),

        // Monthly Breakdown
        _buildMonthlyBreakdown(context),

        const SizedBox(height: 24),

        // Genre Analysis
        _buildGenreAnalysis(context),

        const SizedBox(height: 24),

        // Best Performing Session
        if (analytics['bestPerformingSession'] != null)
          _buildBestPerformingSession(context),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          context,
          'Total Revenue',
          '\$${(analytics['totalEarnings'] as double).toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.green,
          subtitle: 'All time earnings',
        ),
        _buildOverviewCard(
          context,
          'Avg per Session',
          '\$${(analytics['averageEarningsPerSession'] as double).toStringAsFixed(2)}',
          Icons.attach_money,
          theme.colorScheme.primary,
          subtitle: 'Average earnings',
        ),
        _buildOverviewCard(
          context,
          'Total Sessions',
          '${analytics['totalSessions']}',
          Icons.play_circle_outline,
          Colors.blue,
          subtitle: '${analytics['completedSessions']} completed',
        ),
        _buildOverviewCard(
          context,
          'Total Listeners',
          '${analytics['totalListeners']}',
          Icons.people,
          Colors.orange,
          subtitle: 'Across all sessions',
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTrends(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Insights',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Key Metrics
          _buildInsightRow(
            context,
            'Session Success Rate',
            '${((analytics['completedSessions'] as int) / (analytics['totalSessions'] as int) * 100).toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.green,
          ),
          _buildInsightRow(
            context,
            'Request Acceptance Rate',
            '${analytics['totalRequests'] > 0 ? ((analytics['acceptedRequests'] ?? 0) / analytics['totalRequests'] * 100).toStringAsFixed(1) : 0}%',
            Icons.thumb_up,
            Colors.blue,
          ),
          _buildInsightRow(
            context,
            'Average Session Duration',
            '${(analytics['averageSessionDuration'] as num).round()} minutes',
            Icons.access_time,
            Colors.orange,
          ),
          _buildInsightRow(
            context,
            'Club vs Online Ratio',
            '${analytics['clubSessions']}:${analytics['onlineSessions']}',
            Icons.location_on,
            theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final monthlyData = analytics['monthlyBreakdown'] as Map<String, dynamic>;

    if (monthlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Performance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Monthly data list
          ...monthlyData.entries.take(6).map((entry) {
            final monthKey = entry.key;
            final data = entry.value as Map<String, dynamic>;
            final monthName = _formatMonthKey(monthKey);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMonthlyMetric(
                          context, 'Sessions', '${data['sessions']}'),
                      _buildMonthlyMetric(context, 'Earnings',
                          '\$${(data['earnings'] as double).toStringAsFixed(0)}'),
                      _buildMonthlyMetric(
                          context, 'Requests', '${data['requests']}'),
                      _buildMonthlyMetric(
                          context, 'Listeners', '${data['listeners']}'),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
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

  Widget _buildGenreAnalysis(BuildContext context) {
    final theme = Theme.of(context);
    final genreData = analytics['genreBreakdown'] as Map<String, int>;

    if (genreData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort genres by frequency
    final sortedGenres = genreData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Genres',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Genre bars
          ...sortedGenres.take(5).map((entry) {
            final genre = entry.key;
            final count = entry.value;
            final maxCount = sortedGenres.first.value;
            final percentage = count / maxCount;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        genre,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$count sessions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBestPerformingSession(BuildContext context) {
    final theme = Theme.of(context);
    final bestSession = analytics['bestPerformingSession'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Best Performing Session',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            bestSession['title'] ?? 'Untitled Session',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBestSessionMetric(
                context,
                'Earned',
                '\$${(bestSession['totalEarnings'] ?? 0.0).toStringAsFixed(2)}',
                Icons.attach_money,
              ),
              const SizedBox(width: 24),
              _buildBestSessionMetric(
                context,
                'Listeners',
                '${bestSession['listenerCount'] ?? 0}',
                Icons.people,
              ),
              const SizedBox(width: 24),
              _buildBestSessionMetric(
                context,
                'Requests',
                '${bestSession['totalRequests'] ?? 0}',
                Icons.queue_music,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestSessionMetric(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
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
        ),
      ],
    );
  }

  String _formatMonthKey(String monthKey) {
    try {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return monthKey;
    }
  }
}
