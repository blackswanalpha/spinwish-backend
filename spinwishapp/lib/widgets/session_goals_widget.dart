import 'package:flutter/material.dart';
import 'package:spinwishapp/models/session.dart';

class SessionGoalsWidget extends StatefulWidget {
  final List<Session> sessions;

  const SessionGoalsWidget({
    super.key,
    required this.sessions,
  });

  @override
  State<SessionGoalsWidget> createState() => _SessionGoalsWidgetState();
}

class _SessionGoalsWidgetState extends State<SessionGoalsWidget> {
  // Default goals - in a real app, these would be stored in user preferences
  final Map<String, double> _goals = {
    'monthlyEarnings': 1000.0,
    'weeklyListeners': 500.0,
    'sessionDuration': 90.0, // minutes
    'requestAcceptance': 70.0, // percentage
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _calculateProgress();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Goals',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showGoalSettings(context),
                icon: Icon(
                  Icons.settings,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Adjust Goals',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Goals grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildGoalCard(
                theme,
                'Monthly Earnings',
                progress['monthlyEarnings']!,
                _goals['monthlyEarnings']!,
                '\$',
                Icons.attach_money,
                Colors.green,
              ),
              _buildGoalCard(
                theme,
                'Weekly Listeners',
                progress['weeklyListeners']!,
                _goals['weeklyListeners']!,
                '',
                Icons.people,
                Colors.blue,
              ),
              _buildGoalCard(
                theme,
                'Avg Session Length',
                progress['sessionDuration']!,
                _goals['sessionDuration']!,
                '',
                Icons.timer,
                Colors.orange,
                suffix: 'm',
              ),
              _buildGoalCard(
                theme,
                'Request Rate',
                progress['requestAcceptance']!,
                _goals['requestAcceptance']!,
                '',
                Icons.thumb_up,
                Colors.purple,
                suffix: '%',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Overall progress
          _buildOverallProgress(theme, progress),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    ThemeData theme,
    String title,
    double current,
    double goal,
    String prefix,
    IconData icon,
    Color color, {
    String suffix = '',
  }) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? color.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: isCompleted ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          Text(
            '$prefix${current.toStringAsFixed(prefix == '\$' ? 2 : 0)}$suffix',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          
          Text(
            'of $prefix${goal.toStringAsFixed(prefix == '\$' ? 2 : 0)}$suffix',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(ThemeData theme, Map<String, double> progress) {
    final completedGoals = progress.values.where((p) => p >= _goals.values.first).length;
    final totalGoals = _goals.length;
    final overallProgress = completedGoals / totalGoals;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedGoals/$totalGoals goals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          
          Text(
            _getMotivationalMessage(overallProgress),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateProgress() {
    final now = DateTime.now();
    
    // Monthly earnings (current month)
    final monthStart = DateTime(now.year, now.month, 1);
    final monthSessions = widget.sessions
        .where((s) => s.startTime.isAfter(monthStart))
        .toList();
    final monthlyEarnings = monthSessions.fold<double>(0.0, (sum, s) => 
        sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0));

    // Weekly listeners (last 7 days)
    final weekStart = now.subtract(const Duration(days: 7));
    final weekSessions = widget.sessions
        .where((s) => s.startTime.isAfter(weekStart))
        .toList();
    final weeklyListeners = weekSessions.fold<int>(0, (sum, s) => 
        sum + (s.listenerCount ?? 0)).toDouble();

    // Average session duration
    final completedSessions = widget.sessions.where((s) => s.endTime != null).toList();
    final avgDuration = completedSessions.isNotEmpty
        ? completedSessions.fold<int>(0, (sum, s) => 
            sum + s.endTime!.difference(s.startTime).inMinutes) / completedSessions.length
        : 0.0;

    // Request acceptance rate
    final sessionsWithRequests = widget.sessions.where((s) => (s.totalRequests ?? 0) > 0).toList();
    final totalRequests = sessionsWithRequests.fold<int>(0, (sum, s) => sum + (s.totalRequests ?? 0));
    final acceptedRequests = sessionsWithRequests.fold<int>(0, (sum, s) => sum + (s.acceptedRequests ?? 0));
    final requestAcceptance = totalRequests > 0 ? (acceptedRequests / totalRequests) * 100 : 0.0;

    return {
      'monthlyEarnings': monthlyEarnings,
      'weeklyListeners': weeklyListeners,
      'sessionDuration': avgDuration,
      'requestAcceptance': requestAcceptance,
    };
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) {
      return "🎉 Amazing! You've achieved all your goals!";
    } else if (progress >= 0.75) {
      return "🔥 You're so close! Keep pushing to reach all goals!";
    } else if (progress >= 0.5) {
      return "💪 Great progress! You're halfway to your goals!";
    } else if (progress >= 0.25) {
      return "🚀 Good start! Keep working towards your goals!";
    } else {
      return "🎯 Set your pace and work towards your goals!";
    }
  }

  void _showGoalSettings(BuildContext context) {
    // TODO: Implement goal settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goal settings coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
