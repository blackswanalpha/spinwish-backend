import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';

class SessionComparisonWidget extends StatefulWidget {
  final List<Session> sessions;

  const SessionComparisonWidget({
    super.key,
    required this.sessions,
  });

  @override
  State<SessionComparisonWidget> createState() => _SessionComparisonWidgetState();
}

class _SessionComparisonWidgetState extends State<SessionComparisonWidget> {
  String _selectedPeriod = 'week';
  final List<String> _periods = ['week', 'month', 'quarter'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparisonData = _getComparisonData();

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
          // Header with period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Comparison',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _periods.map((period) {
                    final isSelected = period == _selectedPeriod;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          period.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected 
                                ? theme.colorScheme.onPrimary 
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (comparisonData != null) ...[
            // Comparison metrics
            _buildComparisonMetrics(theme, comparisonData),
            
            const SizedBox(height: 20),
            
            // Detailed breakdown
            _buildDetailedBreakdown(theme, comparisonData),
          ] else ...[
            _buildInsufficientDataMessage(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonMetrics(ThemeData theme, Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricComparison(
            theme,
            'Earnings',
            data['current']['earnings'],
            data['previous']['earnings'],
            '\$',
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricComparison(
            theme,
            'Sessions',
            data['current']['sessions'],
            data['previous']['sessions'],
            '',
            Icons.play_circle_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricComparison(
            theme,
            'Avg Listeners',
            data['current']['avgListeners'],
            data['previous']['avgListeners'],
            '',
            Icons.people,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricComparison(
    ThemeData theme,
    String label,
    double currentValue,
    double previousValue,
    String prefix,
    IconData icon,
  ) {
    final change = previousValue > 0 ? ((currentValue - previousValue) / previousValue) * 100 : 0.0;
    final isPositive = change >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$prefix${currentValue.toStringAsFixed(prefix == '\$' ? 2 : 0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: changeColor,
              ),
              const SizedBox(width: 2),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(ThemeData theme, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildBreakdownRow(theme, 'Current Period', data['current']),
              const Divider(height: 24),
              _buildBreakdownRow(theme, 'Previous Period', data['previous']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(ThemeData theme, String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBreakdownItem('Sessions', '${data['sessions']}'),
            _buildBreakdownItem('Earnings', '\$${data['earnings'].toStringAsFixed(2)}'),
            _buildBreakdownItem('Requests', '${data['requests']}'),
            _buildBreakdownItem('Avg Duration', '${data['avgDuration'].toStringAsFixed(0)}m'),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
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

  Widget _buildInsufficientDataMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Not enough data for comparison',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more sessions to see performance comparisons',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getComparisonData() {
    if (widget.sessions.length < 2) return null;

    final now = DateTime.now();
    DateTime currentStart, previousStart, previousEnd;

    switch (_selectedPeriod) {
      case 'week':
        currentStart = now.subtract(const Duration(days: 7));
        previousStart = now.subtract(const Duration(days: 14));
        previousEnd = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        currentStart = DateTime(now.year, now.month - 1, now.day);
        previousStart = DateTime(now.year, now.month - 2, now.day);
        previousEnd = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        currentStart = DateTime(now.year, now.month - 3, now.day);
        previousStart = DateTime(now.year, now.month - 6, now.day);
        previousEnd = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        return null;
    }

    final currentSessions = widget.sessions
        .where((s) => s.startTime.isAfter(currentStart))
        .toList();
    
    final previousSessions = widget.sessions
        .where((s) => s.startTime.isAfter(previousStart) && s.startTime.isBefore(previousEnd))
        .toList();

    if (currentSessions.isEmpty && previousSessions.isEmpty) return null;

    return {
      'current': _calculatePeriodMetrics(currentSessions),
      'previous': _calculatePeriodMetrics(previousSessions),
    };
  }

  Map<String, dynamic> _calculatePeriodMetrics(List<Session> sessions) {
    if (sessions.isEmpty) {
      return {
        'sessions': 0,
        'earnings': 0.0,
        'requests': 0,
        'avgListeners': 0.0,
        'avgDuration': 0.0,
      };
    }

    final totalEarnings = sessions.fold<double>(0.0, (sum, s) => 
        sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0));
    
    final totalRequests = sessions.fold<int>(0, (sum, s) => sum + (s.totalRequests ?? 0));
    
    final totalListeners = sessions.fold<int>(0, (sum, s) => sum + (s.listenerCount ?? 0));
    final avgListeners = totalListeners / sessions.length;
    
    final completedSessions = sessions.where((s) => s.endTime != null).toList();
    final totalDuration = completedSessions.fold<int>(0, (sum, s) => 
        sum + s.endTime!.difference(s.startTime).inMinutes);
    final avgDuration = completedSessions.isNotEmpty ? totalDuration / completedSessions.length : 0.0;

    return {
      'sessions': sessions.length,
      'earnings': totalEarnings,
      'requests': totalRequests,
      'avgListeners': avgListeners,
      'avgDuration': avgDuration,
    };
  }
}
