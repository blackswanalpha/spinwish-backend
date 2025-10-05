import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';

class SessionExportService {
  static const MethodChannel _channel = MethodChannel('session_export');

  /// Export sessions to CSV format
  static String exportToCSV(List<Session> sessions) {
    if (sessions.isEmpty) return '';

    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln([
      'Session ID',
      'Title',
      'Type',
      'Status',
      'Start Time',
      'End Time',
      'Duration (minutes)',
      'Total Earnings',
      'Total Tips',
      'Listener Count',
      'Total Requests',
      'Accepted Requests',
      'Rejected Requests',
      'Genres',
      'Club ID',
      'Description',
      'Shareable Link',
    ].map(_escapeCsvField).join(','));

    // CSV Data
    for (final session in sessions) {
      final duration = session.endTime != null
          ? session.endTime!.difference(session.startTime).inMinutes
          : 0;

      buffer.writeln([
        session.id,
        session.title,
        session.type.name,
        session.status.name,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(session.startTime),
        session.endTime != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(session.endTime!)
            : '',
        duration.toString(),
        (session.totalEarnings ?? 0.0).toStringAsFixed(2),
        (session.totalTips ?? 0.0).toStringAsFixed(2),
        (session.listenerCount ?? 0).toString(),
        (session.totalRequests ?? 0).toString(),
        (session.acceptedRequests ?? 0).toString(),
        (session.rejectedRequests ?? 0).toString(),
        session.genres.join('; '),
        session.clubId ?? '',
        session.description ?? '',
        session.shareableLink ?? '',
      ].map(_escapeCsvField).join(','));
    }

    return buffer.toString();
  }

  /// Export sessions to JSON format
  static String exportToJSON(List<Session> sessions) {
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'total_sessions': sessions.length,
      'sessions': sessions
          .map((session) => {
                'id': session.id,
                'title': session.title,
                'type': session.type.name,
                'status': session.status.name,
                'start_time': session.startTime.toIso8601String(),
                'end_time': session.endTime?.toIso8601String(),
                'duration_minutes':
                    session.endTime?.difference(session.startTime).inMinutes,
                'earnings': {
                  'total_earnings': session.totalEarnings ?? 0.0,
                  'total_tips': session.totalTips ?? 0.0,
                  'combined_total': (session.totalEarnings ?? 0.0) +
                      (session.totalTips ?? 0.0),
                },
                'engagement': {
                  'listener_count': session.listenerCount ?? 0,
                  'total_requests': session.totalRequests ?? 0,
                  'accepted_requests': session.acceptedRequests ?? 0,
                  'rejected_requests': session.rejectedRequests ?? 0,
                  'request_acceptance_rate': (session.totalRequests ?? 0) > 0
                      ? ((session.acceptedRequests ?? 0) /
                              (session.totalRequests ?? 0) *
                              100)
                          .round()
                      : 0,
                },
                'details': {
                  'genres': session.genres,
                  'club_id': session.clubId,
                  'description': session.description,
                  'shareable_link': session.shareableLink,
                  'is_accepting_requests': session.isAcceptingRequests,
                  'min_tip_amount': session.minTipAmount,
                },
              })
          .toList(),
      'summary': _generateSummary(sessions),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Generate analytics summary for export
  static Map<String, dynamic> _generateSummary(List<Session> sessions) {
    if (sessions.isEmpty) {
      return {
        'total_sessions': 0,
        'total_earnings': 0.0,
        'total_tips': 0.0,
        'total_listeners': 0,
        'total_requests': 0,
        'average_session_duration': 0,
        'most_popular_genres': [],
        'session_types': {'CLUB': 0, 'ONLINE': 0},
        'session_statuses': {
          'PREPARING': 0,
          'LIVE': 0,
          'PAUSED': 0,
          'ENDED': 0
        },
      };
    }

    final totalEarnings =
        sessions.fold<double>(0.0, (sum, s) => sum + (s.totalEarnings ?? 0.0));
    final totalTips =
        sessions.fold<double>(0.0, (sum, s) => sum + (s.totalTips ?? 0.0));
    final totalListeners =
        sessions.fold<int>(0, (sum, s) => sum + (s.listenerCount ?? 0));
    final totalRequests =
        sessions.fold<int>(0, (sum, s) => sum + (s.totalRequests ?? 0));

    // Calculate average duration
    final completedSessions = sessions.where((s) => s.endTime != null).toList();
    final totalDuration = completedSessions.fold<int>(
        0, (sum, s) => sum + s.endTime!.difference(s.startTime).inMinutes);
    final avgDuration = completedSessions.isNotEmpty
        ? totalDuration / completedSessions.length
        : 0.0;

    // Genre popularity
    final genreCounts = <String, int>{};
    for (final session in sessions) {
      for (final genre in session.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }
    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Session type counts
    final typeCounts = <String, int>{};
    for (final session in sessions) {
      typeCounts[session.type.name] = (typeCounts[session.type.name] ?? 0) + 1;
    }

    // Session status counts
    final statusCounts = <String, int>{};
    for (final session in sessions) {
      statusCounts[session.status.name] =
          (statusCounts[session.status.name] ?? 0) + 1;
    }

    return {
      'total_sessions': sessions.length,
      'total_earnings': totalEarnings,
      'total_tips': totalTips,
      'combined_earnings': totalEarnings + totalTips,
      'total_listeners': totalListeners,
      'total_requests': totalRequests,
      'average_session_duration': avgDuration.round(),
      'average_earnings_per_session': sessions.isNotEmpty
          ? (totalEarnings + totalTips) / sessions.length
          : 0.0,
      'average_listeners_per_session':
          sessions.isNotEmpty ? totalListeners / sessions.length : 0.0,
      'most_popular_genres': sortedGenres
          .take(5)
          .map((e) => {
                'genre': e.key,
                'count': e.value,
                'percentage': (e.value / sessions.length * 100).round(),
              })
          .toList(),
      'session_types': {
        'CLUB': typeCounts['CLUB'] ?? 0,
        'ONLINE': typeCounts['ONLINE'] ?? 0,
      },
      'session_statuses': {
        'PREPARING': statusCounts['PREPARING'] ?? 0,
        'LIVE': statusCounts['LIVE'] ?? 0,
        'PAUSED': statusCounts['PAUSED'] ?? 0,
        'ENDED': statusCounts['ENDED'] ?? 0,
      },
      'date_range': {
        'earliest_session': sessions.isNotEmpty
            ? sessions
                .map((s) => s.startTime)
                .reduce((a, b) => a.isBefore(b) ? a : b)
                .toIso8601String()
            : null,
        'latest_session': sessions.isNotEmpty
            ? sessions
                .map((s) => s.startTime)
                .reduce((a, b) => a.isAfter(b) ? a : b)
                .toIso8601String()
            : null,
      },
    };
  }

  /// Export session analytics report
  static String exportAnalyticsReport(List<Session> sessions) {
    final buffer = StringBuffer();
    final summary = _generateSummary(sessions);

    buffer.writeln('SESSION ANALYTICS REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln();

    buffer.writeln('OVERVIEW');
    buffer.writeln('-' * 20);
    buffer.writeln('Total Sessions: ${summary['total_sessions']}');
    buffer.writeln(
        'Total Earnings: \$${(summary['total_earnings'] as double).toStringAsFixed(2)}');
    buffer.writeln(
        'Total Tips: \$${(summary['total_tips'] as double).toStringAsFixed(2)}');
    buffer.writeln(
        'Combined Revenue: \$${(summary['combined_earnings'] as double).toStringAsFixed(2)}');
    buffer.writeln('Total Listeners: ${summary['total_listeners']}');
    buffer.writeln('Total Requests: ${summary['total_requests']}');
    buffer.writeln();

    buffer.writeln('AVERAGES');
    buffer.writeln('-' * 20);
    buffer.writeln(
        'Avg Session Duration: ${summary['average_session_duration']} minutes');
    buffer.writeln(
        'Avg Earnings per Session: \$${(summary['average_earnings_per_session'] as double).toStringAsFixed(2)}');
    buffer.writeln(
        'Avg Listeners per Session: ${(summary['average_listeners_per_session'] as double).toStringAsFixed(1)}');
    buffer.writeln();

    buffer.writeln('SESSION TYPES');
    buffer.writeln('-' * 20);
    final types = summary['session_types'] as Map<String, dynamic>;
    for (final entry in types.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    buffer.writeln();

    buffer.writeln('TOP GENRES');
    buffer.writeln('-' * 20);
    final genres = summary['most_popular_genres'] as List<dynamic>;
    for (final genre in genres) {
      buffer.writeln(
          '${genre['genre']}: ${genre['count']} sessions (${genre['percentage']}%)');
    }
    buffer.writeln();

    if (summary['date_range']['earliest_session'] != null) {
      buffer.writeln('DATE RANGE');
      buffer.writeln('-' * 20);
      buffer.writeln(
          'Earliest Session: ${summary['date_range']['earliest_session']}');
      buffer.writeln(
          'Latest Session: ${summary['date_range']['latest_session']}');
    }

    return buffer.toString();
  }

  /// Save export data to device (platform-specific implementation needed)
  static Future<bool> saveToDevice(
      String data, String filename, String mimeType) async {
    try {
      final result = await _channel.invokeMethod('saveFile', {
        'data': data,
        'filename': filename,
        'mimeType': mimeType,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to save file: ${e.message}');
      return false;
    }
  }

  /// Share export data (platform-specific implementation needed)
  static Future<bool> shareData(
      String data, String filename, String mimeType) async {
    try {
      final result = await _channel.invokeMethod('shareFile', {
        'data': data,
        'filename': filename,
        'mimeType': mimeType,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to share file: ${e.message}');
      return false;
    }
  }

  /// Escape CSV field to handle commas, quotes, and newlines
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Generate filename with timestamp
  static String generateFilename(String prefix, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$timestamp.$extension';
  }
}
