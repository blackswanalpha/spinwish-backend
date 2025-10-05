import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';

class SessionPerformanceChart extends StatelessWidget {
  final List<Session> sessions;
  final String title;
  final String metric; // 'earnings', 'listeners', 'requests', 'duration'

  const SessionPerformanceChart({
    super.key,
    required this.sessions,
    required this.title,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (sessions.isEmpty) {
      return _buildEmptyChart(theme);
    }

    final chartData = _prepareChartData();
    final maxValue = _getMaxValue(chartData);

    return Container(
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
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Chart
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final height = maxValue > 0 ? (data['value'] / maxValue) * 160 : 0.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        if (height > 20) ...[
                          Text(
                            _formatValue(data['value']),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        
                        // Bar
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _getMetricColor(theme),
                                _getMetricColor(theme).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Date label
                        Text(
                          data['label'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary stats
          _buildSummaryStats(theme, chartData),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.bar_chart,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(ThemeData theme, List<Map<String, dynamic>> chartData) {
    final values = chartData.map((d) => d['value'] as double).toList();
    final total = values.fold<double>(0, (sum, v) => sum + v);
    final average = values.isNotEmpty ? total / values.length : 0.0;
    final max = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, 'Total', _formatValue(total)),
          _buildStatItem(theme, 'Average', _formatValue(average)),
          _buildStatItem(theme, 'Best', _formatValue(max)),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getMetricColor(theme),
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

  List<Map<String, dynamic>> _prepareChartData() {
    // Group sessions by date and calculate metric values
    final Map<String, List<Session>> groupedSessions = {};
    
    for (final session in sessions) {
      final dateKey = DateFormat('MM/dd').format(session.startTime);
      groupedSessions[dateKey] ??= [];
      groupedSessions[dateKey]!.add(session);
    }

    // Convert to chart data
    final chartData = <Map<String, dynamic>>[];
    
    for (final entry in groupedSessions.entries) {
      final date = entry.key;
      final sessionsForDate = entry.value;
      double value = 0.0;

      switch (metric) {
        case 'earnings':
          value = sessionsForDate.fold<double>(0.0, (sum, s) => 
              sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0));
          break;
        case 'listeners':
          value = sessionsForDate.fold<double>(0.0, (sum, s) => 
              sum + (s.listenerCount ?? 0).toDouble());
          break;
        case 'requests':
          value = sessionsForDate.fold<double>(0.0, (sum, s) => 
              sum + (s.totalRequests ?? 0).toDouble());
          break;
        case 'duration':
          value = sessionsForDate.fold<double>(0.0, (sum, s) {
            if (s.endTime != null) {
              return sum + s.endTime!.difference(s.startTime).inMinutes.toDouble();
            }
            return sum;
          });
          break;
      }

      chartData.add({
        'label': date,
        'value': value,
        'sessions': sessionsForDate,
      });
    }

    // Sort by date and take last 10 entries
    chartData.sort((a, b) {
      final aDate = (a['sessions'] as List<Session>).first.startTime;
      final bDate = (b['sessions'] as List<Session>).first.startTime;
      return aDate.compareTo(bDate);
    });

    return chartData.take(10).toList();
  }

  double _getMaxValue(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return 0.0;
    return chartData.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b);
  }

  String _formatValue(double value) {
    switch (metric) {
      case 'earnings':
        return '\$${value.toStringAsFixed(0)}';
      case 'listeners':
        return value.toStringAsFixed(0);
      case 'requests':
        return value.toStringAsFixed(0);
      case 'duration':
        final hours = (value / 60).floor();
        final minutes = (value % 60).floor();
        if (hours > 0) {
          return '${hours}h ${minutes}m';
        }
        return '${minutes}m';
      default:
        return value.toStringAsFixed(1);
    }
  }

  Color _getMetricColor(ThemeData theme) {
    switch (metric) {
      case 'earnings':
        return Colors.green;
      case 'listeners':
        return theme.colorScheme.primary;
      case 'requests':
        return Colors.orange;
      case 'duration':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }
}

class SessionTrendIndicator extends StatelessWidget {
  final List<Session> sessions;
  final String metric;

  const SessionTrendIndicator({
    super.key,
    required this.sessions,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = _calculateTrend();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trend['isPositive'] 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trend['isPositive'] ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: trend['isPositive'] ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${trend['percentage'].toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: trend['isPositive'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateTrend() {
    if (sessions.length < 2) {
      return {'isPositive': true, 'percentage': 0.0};
    }

    // Compare last week vs previous week
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final recentSessions = sessions.where((s) => s.startTime.isAfter(lastWeek)).toList();
    final previousSessions = sessions.where((s) => 
        s.startTime.isAfter(twoWeeksAgo) && s.startTime.isBefore(lastWeek)).toList();

    final recentValue = _getMetricValue(recentSessions);
    final previousValue = _getMetricValue(previousSessions);

    if (previousValue == 0) {
      return {'isPositive': recentValue > 0, 'percentage': 0.0};
    }

    final percentage = ((recentValue - previousValue) / previousValue) * 100;
    return {'isPositive': percentage >= 0, 'percentage': percentage.abs()};
  }

  double _getMetricValue(List<Session> sessions) {
    switch (metric) {
      case 'earnings':
        return sessions.fold<double>(0.0, (sum, s) => 
            sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0));
      case 'listeners':
        return sessions.fold<double>(0.0, (sum, s) => 
            sum + (s.listenerCount ?? 0).toDouble());
      case 'requests':
        return sessions.fold<double>(0.0, (sum, s) => 
            sum + (s.totalRequests ?? 0).toDouble());
      case 'duration':
        return sessions.fold<double>(0.0, (sum, s) {
          if (s.endTime != null) {
            return sum + s.endTime!.difference(s.startTime).inMinutes.toDouble();
          }
          return sum;
        });
      default:
        return 0.0;
    }
  }
}
