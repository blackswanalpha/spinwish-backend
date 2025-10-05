import 'package:flutter/material.dart';
import 'package:spinwishapp/services/session_history_service.dart';

class SessionHistoryFilters extends StatelessWidget {
  final SessionHistoryFilter currentFilter;
  final SessionSortBy currentSort;
  final Function(SessionHistoryFilter) onFilterChanged;
  final Function(SessionSortBy) onSortChanged;

  const SessionHistoryFilters({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          Text(
            'Filter by',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SessionHistoryFilter.values.map((filter) {
              final isSelected = filter == currentFilter;
              return FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(filter);
                  }
                },
                backgroundColor: theme.colorScheme.surfaceContainer,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Sort Section
          Text(
            'Sort by',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SessionSortBy.values.map((sort) {
              final isSelected = sort == currentSort;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSortIcon(sort),
                      size: 16,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(_getSortLabel(sort)),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onSortChanged(sort);
                  }
                },
                backgroundColor: theme.colorScheme.surfaceContainer,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(SessionHistoryFilter filter) {
    switch (filter) {
      case SessionHistoryFilter.all:
        return 'All';
      case SessionHistoryFilter.thisWeek:
        return 'This Week';
      case SessionHistoryFilter.thisMonth:
        return 'This Month';
      case SessionHistoryFilter.lastMonth:
        return 'Last Month';
      case SessionHistoryFilter.thisYear:
        return 'This Year';
      case SessionHistoryFilter.club:
        return 'Club Sessions';
      case SessionHistoryFilter.online:
        return 'Online Sessions';
      case SessionHistoryFilter.ended:
        return 'Completed';
      case SessionHistoryFilter.paused:
        return 'Paused';
    }
  }

  String _getSortLabel(SessionSortBy sort) {
    switch (sort) {
      case SessionSortBy.dateNewest:
        return 'Newest First';
      case SessionSortBy.dateOldest:
        return 'Oldest First';
      case SessionSortBy.earnings:
        return 'Earnings';
      case SessionSortBy.duration:
        return 'Duration';
      case SessionSortBy.listeners:
        return 'Listeners';
      case SessionSortBy.requests:
        return 'Requests';
    }
  }

  IconData _getSortIcon(SessionSortBy sort) {
    switch (sort) {
      case SessionSortBy.dateNewest:
        return Icons.arrow_downward;
      case SessionSortBy.dateOldest:
        return Icons.arrow_upward;
      case SessionSortBy.earnings:
        return Icons.attach_money;
      case SessionSortBy.duration:
        return Icons.access_time;
      case SessionSortBy.listeners:
        return Icons.people;
      case SessionSortBy.requests:
        return Icons.queue_music;
    }
  }
}

class SessionHistoryQuickStats extends StatelessWidget {
  final Map<String, dynamic> analytics;

  const SessionHistoryQuickStats({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(
                context,
                'Total Sessions',
                analytics['totalSessions'].toString(),
                Icons.play_circle_outline,
                theme.colorScheme.primary,
              ),
              _buildStatCard(
                context,
                'Total Earnings',
                '\$${(analytics['totalEarnings'] as double).toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Avg Duration',
                '${(analytics['averageSessionDuration'] as num).round()}m',
                Icons.access_time,
                theme.colorScheme.secondary,
              ),
              _buildStatCard(
                context,
                'Total Requests',
                analytics['totalRequests'].toString(),
                Icons.queue_music,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
