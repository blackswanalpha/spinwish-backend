import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';

class SessionInsightsWidget extends StatelessWidget {
  final List<Session> sessions;

  const SessionInsightsWidget({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = _generateInsights();

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInsightCard(theme, insight),
              )),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme, Map<String, dynamic> insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight['icon'],
              color: insight['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (insight['action'] != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    if (sessions.isEmpty) return [];

    final insights = <Map<String, dynamic>>[];

    // Best performing day insight
    final bestDay = _getBestPerformingDay();
    if (bestDay != null) {
      insights.add({
        'title': 'Best Performance Day',
        'description':
            'Your ${bestDay['day']} sessions earn ${bestDay['percentage']}% more on average',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'action': 'schedule_more',
      });
    }

    // Peak hours insight
    final peakHour = _getPeakHour();
    if (peakHour != null) {
      insights.add({
        'title': 'Peak Engagement Hour',
        'description':
            'Sessions starting at ${peakHour['hour']}:00 get ${peakHour['listeners']} listeners on average',
        'icon': Icons.schedule,
        'color': Colors.blue,
        'action': 'optimize_timing',
      });
    }

    // Genre performance insight
    final topGenre = _getTopPerformingGenre();
    if (topGenre != null) {
      insights.add({
        'title': 'Top Genre',
        'description':
            '${topGenre['genre']} sessions generate ${topGenre['earnings']}% more revenue',
        'icon': Icons.music_note,
        'color': Colors.purple,
        'action': 'focus_genre',
      });
    }

    // Session length insight
    final optimalLength = _getOptimalSessionLength();
    if (optimalLength != null) {
      insights.add({
        'title': 'Optimal Session Length',
        'description':
            '${optimalLength['duration']} minute sessions have the highest listener retention',
        'icon': Icons.timer,
        'color': Colors.orange,
        'action': 'adjust_length',
      });
    }

    // Request acceptance insight
    final requestInsight = _getRequestAcceptanceInsight();
    if (requestInsight != null) {
      insights.add({
        'title': 'Request Strategy',
        'description': requestInsight['message'],
        'icon': Icons.queue_music,
        'color': requestInsight['color'],
        'action': 'adjust_requests',
      });
    }

    // Growth trend insight
    final growthTrend = _getGrowthTrend();
    if (growthTrend != null) {
      insights.add({
        'title': 'Growth Trend',
        'description': growthTrend['message'],
        'icon': growthTrend['icon'],
        'color': growthTrend['color'],
        'action': 'maintain_growth',
      });
    }

    return insights.take(4).toList(); // Limit to top 4 insights
  }

  Map<String, dynamic>? _getBestPerformingDay() {
    if (sessions.length < 5) return null;

    final dayEarnings = <String, List<double>>{};

    for (final session in sessions) {
      final day = DateFormat('EEEE').format(session.startTime);
      final earnings =
          (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);
      dayEarnings[day] ??= [];
      dayEarnings[day]!.add(earnings);
    }

    String? bestDay;
    double bestAverage = 0.0;
    double overallAverage = 0.0;
    int totalSessions = 0;

    // Calculate overall average
    for (final earnings in dayEarnings.values) {
      overallAverage += earnings.fold(0.0, (sum, e) => sum + e);
      totalSessions += earnings.length;
    }
    overallAverage = totalSessions > 0 ? overallAverage / totalSessions : 0.0;

    // Find best day
    for (final entry in dayEarnings.entries) {
      final average =
          entry.value.fold(0.0, (sum, e) => sum + e) / entry.value.length;
      if (average > bestAverage && entry.value.length >= 2) {
        bestAverage = average;
        bestDay = entry.key;
      }
    }

    if (bestDay != null && overallAverage > 0) {
      final percentage =
          ((bestAverage - overallAverage) / overallAverage * 100).round();
      if (percentage > 10) {
        return {
          'day': bestDay,
          'percentage': percentage,
        };
      }
    }

    return null;
  }

  Map<String, dynamic>? _getPeakHour() {
    if (sessions.length < 5) return null;

    final hourListeners = <int, List<int>>{};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      final listeners = session.listenerCount ?? 0;
      hourListeners[hour] ??= [];
      hourListeners[hour]!.add(listeners);
    }

    int? peakHour;
    double bestAverage = 0.0;

    for (final entry in hourListeners.entries) {
      if (entry.value.length >= 2) {
        final average =
            entry.value.fold(0, (sum, l) => sum + l) / entry.value.length;
        if (average > bestAverage) {
          bestAverage = average;
          peakHour = entry.key;
        }
      }
    }

    if (peakHour != null && bestAverage > 0) {
      return {
        'hour': peakHour,
        'listeners': bestAverage.round(),
      };
    }

    return null;
  }

  Map<String, dynamic>? _getTopPerformingGenre() {
    if (sessions.length < 3) return null;

    final genreEarnings = <String, List<double>>{};

    for (final session in sessions) {
      final earnings =
          (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);
      for (final genre in session.genres) {
        genreEarnings[genre] ??= [];
        genreEarnings[genre]!.add(earnings);
      }
    }

    String? topGenre;
    double bestAverage = 0.0;
    double overallAverage = 0.0;
    int totalSessions = 0;

    // Calculate overall average
    for (final earnings in genreEarnings.values) {
      overallAverage += earnings.fold(0.0, (sum, e) => sum + e);
      totalSessions += earnings.length;
    }
    overallAverage = totalSessions > 0 ? overallAverage / totalSessions : 0.0;

    // Find top genre
    for (final entry in genreEarnings.entries) {
      if (entry.value.length >= 2) {
        final average =
            entry.value.fold(0.0, (sum, e) => sum + e) / entry.value.length;
        if (average > bestAverage) {
          bestAverage = average;
          topGenre = entry.key;
        }
      }
    }

    if (topGenre != null && overallAverage > 0) {
      final percentage =
          ((bestAverage - overallAverage) / overallAverage * 100).round();
      if (percentage > 15) {
        return {
          'genre': topGenre,
          'earnings': percentage,
        };
      }
    }

    return null;
  }

  Map<String, dynamic>? _getOptimalSessionLength() {
    if (sessions.length < 5) return null;

    final completedSessions = sessions.where((s) => s.endTime != null).toList();
    if (completedSessions.length < 3) return null;

    // Group by duration ranges
    final durationGroups = <String, List<Session>>{};

    for (final session in completedSessions) {
      final duration = session.endTime!.difference(session.startTime).inMinutes;
      String group;

      if (duration < 30)
        group = '< 30';
      else if (duration < 60)
        group = '30-60';
      else if (duration < 90)
        group = '60-90';
      else if (duration < 120)
        group = '90-120';
      else
        group = '120+';

      durationGroups[group] ??= [];
      durationGroups[group]!.add(session);
    }

    String? optimalGroup;
    double bestListenerAverage = 0.0;

    for (final entry in durationGroups.entries) {
      if (entry.value.length >= 2) {
        final avgListeners =
            entry.value.fold(0, (sum, s) => sum + (s.listenerCount ?? 0)) /
                entry.value.length;
        if (avgListeners > bestListenerAverage) {
          bestListenerAverage = avgListeners;
          optimalGroup = entry.key;
        }
      }
    }

    if (optimalGroup != null) {
      return {
        'duration': optimalGroup,
      };
    }

    return null;
  }

  Map<String, dynamic>? _getRequestAcceptanceInsight() {
    final sessionsWithRequests =
        sessions.where((s) => (s.totalRequests ?? 0) > 0).toList();
    if (sessionsWithRequests.length < 3) return null;

    final totalRequests =
        sessionsWithRequests.fold(0, (sum, s) => sum + (s.totalRequests ?? 0));
    final acceptedRequests = sessionsWithRequests.fold(
        0, (sum, s) => sum + (s.acceptedRequests ?? 0));

    if (totalRequests == 0) return null;

    final acceptanceRate = (acceptedRequests / totalRequests * 100).round();

    if (acceptanceRate < 30) {
      return {
        'message':
            'Consider accepting more requests (${acceptanceRate}% rate) to boost engagement',
        'color': Colors.orange,
      };
    } else if (acceptanceRate > 80) {
      return {
        'message':
            'Great request engagement! ${acceptanceRate}% acceptance rate keeps listeners happy',
        'color': Colors.green,
      };
    }

    return null;
  }

  Map<String, dynamic>? _getGrowthTrend() {
    if (sessions.length < 6) return null;

    // Compare recent vs older sessions
    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final halfPoint = sortedSessions.length ~/ 2;
    final olderSessions = sortedSessions.take(halfPoint).toList();
    final recentSessions = sortedSessions.skip(halfPoint).toList();

    final olderAvgEarnings = olderSessions.fold(0.0,
            (sum, s) => sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0)) /
        olderSessions.length;
    final recentAvgEarnings = recentSessions.fold(0.0,
            (sum, s) => sum + (s.totalEarnings ?? 0.0) + (s.totalTips ?? 0.0)) /
        recentSessions.length;

    if (olderAvgEarnings > 0) {
      final growthPercentage =
          ((recentAvgEarnings - olderAvgEarnings) / olderAvgEarnings * 100)
              .round();

      if (growthPercentage > 20) {
        return {
          'message':
              'Excellent growth! Earnings up ${growthPercentage}% in recent sessions',
          'icon': Icons.trending_up,
          'color': Colors.green,
        };
      } else if (growthPercentage < -20) {
        return {
          'message':
              'Earnings down ${growthPercentage.abs()}%. Consider trying new strategies',
          'icon': Icons.trending_down,
          'color': Colors.red,
        };
      }
    }

    return null;
  }
}
