import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/enhanced_queue_service.dart';

class QueueAnalyticsWidget extends StatefulWidget {
  const QueueAnalyticsWidget({super.key});

  @override
  State<QueueAnalyticsWidget> createState() => _QueueAnalyticsWidgetState();
}

class _QueueAnalyticsWidgetState extends State<QueueAnalyticsWidget> {
  final EnhancedQueueService _queueService = EnhancedQueueService();
  Map<String, Object> _queueStats = {};
  Map<String, dynamic> _healthMetrics = {};
  List<String> _popularSongs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      final sessionService = Provider.of<SessionService>(context, listen: false);
      
      // Load queue statistics
      _queueStats = await sessionService.getQueueStatistics();
      
      // Load health metrics
      _healthMetrics = _queueService.getQueueHealthMetrics();
      
      // Load popular songs
      _popularSongs = _queueService.getPopularSongs(limit: 10);
      
    } catch (e) {
      debugPrint('Failed to load analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildHealthOverview(theme),
              const SizedBox(height: 16),
              _buildStatisticsGrid(theme),
              const SizedBox(height: 16),
              _buildPopularSongs(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Queue Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        IconButton(
          onPressed: _loadAnalytics,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Analytics',
        ),
      ],
    );
  }

  Widget _buildHealthOverview(ThemeData theme) {
    final health = _healthMetrics['health'] ?? 'unknown';
    final healthColor = _getHealthColor(health);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: healthColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: healthColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getHealthIcon(health),
            color: healthColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Queue Health: ${health.toUpperCase()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthDescription(health),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMetricCard(
              theme,
              'Queue Length',
              '${_queueStats['queueLength'] ?? 0}',
              Icons.queue,
              Colors.blue,
            ),
            _buildMetricCard(
              theme,
              'Total Value',
              '\$${_queueStats['totalQueueValue'] ?? 0.0}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildMetricCard(
              theme,
              'Avg Tip',
              '\$${_queueStats['averageTipAmount'] ?? 0.0}',
              Icons.trending_up,
              Colors.orange,
            ),
            _buildMetricCard(
              theme,
              'Avg Wait',
              '${_queueStats['averageWaitTime'] ?? 0.0}m',
              Icons.access_time,
              Colors.purple,
            ),
            _buildMetricCard(
              theme,
              'Fairness Score',
              '${((_healthMetrics['fairnessScore'] ?? 0.0) * 100).toInt()}%',
              Icons.balance,
              Colors.teal,
            ),
            _buildMetricCard(
              theme,
              'Tip Variance',
              '${(_healthMetrics['tipVariance'] ?? 0.0).toStringAsFixed(1)}',
              Icons.show_chart,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSongs(ThemeData theme) {
    if (_popularSongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Songs',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularSongs.length,
            itemBuilder: (context, index) {
              final songId = _popularSongs[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Song ${index + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      songId.substring(0, 8),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthIcon(String health) {
    switch (health.toLowerCase()) {
      case 'excellent':
        return Icons.check_circle;
      case 'good':
        return Icons.thumb_up;
      case 'fair':
        return Icons.warning;
      case 'poor':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getHealthDescription(String health) {
    switch (health.toLowerCase()) {
      case 'excellent':
        return 'Queue is running smoothly with optimal performance';
      case 'good':
        return 'Queue is performing well with minor issues';
      case 'fair':
        return 'Queue has some performance issues that need attention';
      case 'poor':
        return 'Queue has significant issues requiring immediate action';
      default:
        return 'Queue health status unknown';
    }
  }
}
