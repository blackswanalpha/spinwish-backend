import 'package:flutter/material.dart';
import 'package:spinwishapp/services/dj_discovery_service.dart';
import 'package:spinwishapp/models/session.dart';

class DiscoveryFiltersWidget extends StatefulWidget {
  final DJDiscoveryService discoveryService;
  final VoidCallback? onFiltersChanged;

  const DiscoveryFiltersWidget({
    super.key,
    required this.discoveryService,
    this.onFiltersChanged,
  });

  @override
  State<DiscoveryFiltersWidget> createState() => _DiscoveryFiltersWidgetState();
}

class _DiscoveryFiltersWidgetState extends State<DiscoveryFiltersWidget> {
  final List<String> _availableGenres = [
    'House',
    'Techno',
    'Hip Hop',
    'R&B',
    'Pop',
    'Rock',
    'Jazz',
    'Reggae',
    'Electronic',
    'Latin',
    'Country',
    'Classical',
    'Funk',
    'Soul',
    'Disco'
  ];

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
          // Header
          Row(
            children: [
              Icon(
                Icons.tune,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Discovery Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Distance Filter
          _buildDistanceFilter(theme),

          const SizedBox(height: 20),

          // Live DJs Only
          _buildLiveOnlyFilter(theme),

          const SizedBox(height: 20),

          // Session Type Filter
          _buildSessionTypeFilter(theme),

          const SizedBox(height: 20),

          // Genre Filters
          _buildGenreFilters(theme),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance: ${widget.discoveryService.maxDistance.toStringAsFixed(1)} km',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.discoveryService.maxDistance,
          min: 0.5,
          max: 50.0,
          divisions: 99,
          label: '${widget.discoveryService.maxDistance.toStringAsFixed(1)} km',
          onChanged: (value) {
            widget.discoveryService.updateFilters(maxDistance: value);
            widget.onFiltersChanged?.call();
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.5 km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '50 km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveOnlyFilter(ThemeData theme) {
    return SwitchListTile(
      title: const Text('Live DJs Only'),
      subtitle: const Text('Show only DJs who are currently performing'),
      value: widget.discoveryService.onlyLiveDJs,
      onChanged: (value) {
        widget.discoveryService.updateFilters(onlyLiveDJs: value);
        widget.onFiltersChanged?.call();
      },
      contentPadding: EdgeInsets.zero,
      activeColor: theme.colorScheme.primary,
    );
  }

  Widget _buildSessionTypeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Type',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('All Types'),
                selected: widget.discoveryService.sessionTypeFilter == null,
                onSelected: (selected) {
                  if (selected) {
                    widget.discoveryService
                        .updateFilters(sessionTypeFilter: null);
                    widget.onFiltersChanged?.call();
                  }
                },
                backgroundColor: theme.colorScheme.surfaceContainer,
                selectedColor: theme.colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('Club'),
                selected: widget.discoveryService.sessionTypeFilter ==
                    SessionType.club,
                onSelected: (selected) {
                  widget.discoveryService.updateFilters(
                    sessionTypeFilter: selected ? SessionType.club : null,
                  );
                  widget.onFiltersChanged?.call();
                },
                backgroundColor: theme.colorScheme.surfaceContainer,
                selectedColor: theme.colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('Online'),
                selected: widget.discoveryService.sessionTypeFilter ==
                    SessionType.online,
                onSelected: (selected) {
                  widget.discoveryService.updateFilters(
                    sessionTypeFilter: selected ? SessionType.online : null,
                  );
                  widget.onFiltersChanged?.call();
                },
                backgroundColor: theme.colorScheme.surfaceContainer,
                selectedColor: theme.colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        if (widget.discoveryService.genreFilters.isNotEmpty) ...[
          // Selected genres
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.discoveryService.genreFilters
                .map((genre) => Chip(
                      label: Text(genre),
                      onDeleted: () {
                        final updatedGenres = List<String>.from(
                            widget.discoveryService.genreFilters);
                        updatedGenres.remove(genre);
                        widget.discoveryService
                            .updateFilters(genreFilters: updatedGenres);
                        widget.onFiltersChanged?.call();
                      },
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      deleteIconColor: theme.colorScheme.onPrimaryContainer,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Add genre button
        OutlinedButton.icon(
          onPressed: () => _showGenreSelector(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Genre'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showGenreSelector(BuildContext context) {
    final theme = Theme.of(context);
    final availableGenres = _availableGenres
        .where((genre) => !widget.discoveryService.genreFilters.contains(genre))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Genres'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableGenres.isEmpty
              ? const Text('All genres are already selected')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableGenres
                      .map((genre) => FilterChip(
                            label: Text(genre),
                            onSelected: (selected) {
                              if (selected) {
                                final updatedGenres = List<String>.from(
                                    widget.discoveryService.genreFilters);
                                updatedGenres.add(genre);
                                widget.discoveryService
                                    .updateFilters(genreFilters: updatedGenres);
                                widget.onFiltersChanged?.call();
                                Navigator.of(context).pop();
                              }
                            },
                            backgroundColor: theme.colorScheme.surfaceContainer,
                            selectedColor: theme.colorScheme.primaryContainer,
                          ))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    widget.discoveryService.updateFilters(
      maxDistance: 10.0,
      onlyLiveDJs: true,
      genreFilters: [],
      sessionTypeFilter: null,
    );
    widget.onFiltersChanged?.call();
  }
}

class DiscoveryStatsWidget extends StatelessWidget {
  final DJDiscoveryService discoveryService;

  const DiscoveryStatsWidget({
    super.key,
    required this.discoveryService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nearbyCount = discoveryService.nearbyDJs.length;
    final liveCount =
        discoveryService.nearbyDJs.where((dj) => dj.isLive).length;

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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            'Nearby DJs',
            nearbyCount.toString(),
            Icons.people,
          ),
          _buildStatItem(
            theme,
            'Live Now',
            liveCount.toString(),
            Icons.radio,
            color: Colors.green,
          ),
          _buildStatItem(
            theme,
            'Max Distance',
            '${discoveryService.maxDistance.toStringAsFixed(1)}km',
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final statColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Icon(
          icon,
          color: statColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: statColor,
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
}
