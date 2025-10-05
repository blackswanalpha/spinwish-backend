import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/screens/dj/session_detail_screen.dart';

class SessionSearchDelegate extends SearchDelegate<Session?> {
  final List<Session> sessions;

  SessionSearchDelegate({required this.sessions});

  @override
  String get searchFieldLabel => 'Search sessions...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _getSearchResults();

    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final session = results[index];
        return _buildSessionSearchResult(context, session);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSearchSuggestions(context);
    }

    final results = _getSearchResults();

    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final session = results[index];
        return _buildSessionSearchResult(context, session);
      },
    );
  }

  List<Session> _getSearchResults() {
    if (query.isEmpty) return [];

    final searchQuery = query.toLowerCase();

    return sessions.where((session) {
      // Search in title
      if (session.title.toLowerCase().contains(searchQuery)) return true;

      // Search in description
      if (session.description != null &&
          session.description!.toLowerCase().contains(searchQuery)) return true;

      // Search in genres
      if (session.genres
          .any((genre) => genre.toLowerCase().contains(searchQuery))) {
        return true;
      }

      // Search in club ID
      if (session.clubId != null &&
          session.clubId!.toLowerCase().contains(searchQuery)) return true;

      // Search in session type
      if (session.type.name.toLowerCase().contains(searchQuery)) return true;

      // Search in status
      if (session.status.name.toLowerCase().contains(searchQuery)) return true;

      // Search by date
      final dateStr =
          DateFormat('MMM dd yyyy').format(session.startTime).toLowerCase();
      if (dateStr.contains(searchQuery)) return true;

      return false;
    }).toList();
  }

  Widget _buildSessionSearchResult(BuildContext context, Session session) {
    final theme = Theme.of(context);
    final earnings =
        (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);
    final duration = _calculateDuration(session);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(theme, session.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(session.type),
            color: _getTypeColor(theme, session.type),
            size: 20,
          ),
        ),
        title: Text(
          session.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${earnings.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${session.listenerCount ?? 0} listeners',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  duration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(theme, session.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(session.status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(theme, session.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          close(context, session);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailScreen(session: session),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for session titles, genres, or dates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final theme = Theme.of(context);

    // Generate search suggestions based on session data
    final suggestions = _generateSearchSuggestions();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Search Suggestions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...suggestions.map((suggestion) => ListTile(
              leading: Icon(
                suggestion['icon'],
                color: theme.colorScheme.primary,
              ),
              title: Text(suggestion['title']),
              subtitle: Text(suggestion['subtitle']),
              onTap: () {
                query = suggestion['query'];
                showResults(context);
              },
            )),
      ],
    );
  }

  List<Map<String, dynamic>> _generateSearchSuggestions() {
    final suggestions = <Map<String, dynamic>>[];

    // Recent sessions
    suggestions.add({
      'title': 'Recent sessions',
      'subtitle': 'Sessions from the last 7 days',
      'query': DateFormat('MMM yyyy').format(DateTime.now()),
      'icon': Icons.schedule,
    });

    // Popular genres
    final genreCounts = <String, int>{};
    for (final session in sessions) {
      for (final genre in session.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    final topGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final genre in topGenres.take(3)) {
      suggestions.add({
        'title': '${genre.key} sessions',
        'subtitle': '${genre.value} sessions found',
        'query': genre.key,
        'icon': Icons.music_note,
      });
    }

    // Session types
    suggestions.addAll([
      {
        'title': 'Club sessions',
        'subtitle': 'Sessions performed at venues',
        'query': 'club',
        'icon': Icons.location_on,
      },
      {
        'title': 'Online sessions',
        'subtitle': 'Virtual streaming sessions',
        'query': 'online',
        'icon': Icons.wifi,
      },
    ]);

    return suggestions;
  }

  String _calculateDuration(Session session) {
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

  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.club:
        return Icons.location_on;
      case SessionType.online:
        return Icons.wifi;
    }
  }

  Color _getTypeColor(ThemeData theme, SessionType type) {
    switch (type) {
      case SessionType.club:
        return theme.colorScheme.secondary;
      case SessionType.online:
        return theme.colorScheme.primary;
    }
  }

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

  Color _getStatusColor(ThemeData theme, SessionStatus status) {
    switch (status) {
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
