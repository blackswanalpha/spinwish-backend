import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:spinwishapp/models/live_event.dart';
import 'package:spinwishapp/utils/design_system.dart';

class TopLiveEventsWidget extends StatefulWidget {
  final List<LiveEvent> liveEvents;
  final Function(LiveEvent)? onEventTap;

  const TopLiveEventsWidget({
    super.key,
    required this.liveEvents,
    this.onEventTap,
  });

  @override
  State<TopLiveEventsWidget> createState() => _TopLiveEventsWidgetState();
}

class _TopLiveEventsWidgetState extends State<TopLiveEventsWidget> {
  String _selectedGenre = 'All';

  final List<String> _availableGenres = [
    'All',
    'House',
    'Techno',
    'Electronic',
    'Hip Hop',
    'R&B',
    'Pop',
    'Rock',
    'Jazz',
    'Reggae',
    'Afrobeats',
    'Amapiano',
    'Latin',
  ];

  List<LiveEvent> get _filteredEvents {
    if (_selectedGenre == 'All') {
      return widget.liveEvents;
    }
    return widget.liveEvents.where((event) {
      // Assuming LiveEvent has genres property - if not, this would need to be adapted
      // For now, we'll return all events as the filtering logic would depend on the actual LiveEvent model
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEvents = _filteredEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genre Pills Section
        _buildGenrePills(theme),

        const SizedBox(height: SpinWishDesignSystem.spaceLG),

        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpinWishDesignSystem.spaceMD),
          child: Row(
            children: [
              Text(
                'DJ\'s Live Now',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpinWishDesignSystem.spaceMD),

        // Horizontal Scrollable Events
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: SpinWishDesignSystem.spaceMD),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < filteredEvents.length - 1
                      ? SpinWishDesignSystem.spaceMD
                      : 0,
                ),
                child: _buildEventCard(context, theme, event),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenrePills(ThemeData theme) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: SpinWishDesignSystem.spaceMD),
        itemCount: _availableGenres.length,
        itemBuilder: (context, index) {
          final genre = _availableGenres[index];
          final isSelected = _selectedGenre == genre;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _availableGenres.length - 1
                  ? SpinWishDesignSystem.spaceSM
                  : 0,
            ),
            child: _buildGenrePill(theme, genre, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildGenrePill(ThemeData theme, String genre, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGenre = genre;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE91E63), // Pink
                    Color(0xFFAD1457), // Darker pink
                  ],
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surface.withOpacity(0.1),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.1)
                    : theme.colorScheme.surface.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(SpinWishDesignSystem.radiusFull),
              ),
              child: Text(
                genre,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, ThemeData theme, LiveEvent event) {
    return GestureDetector(
      onTap: () => widget.onEventTap?.call(event),
      child: Column(
        children: [
          // Circular Profile Image with Gradient Background
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: event.backgroundColors.isNotEmpty
                    ? event.backgroundColors
                    : [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: event.backgroundColors.isNotEmpty
                      ? event.backgroundColors.first.withOpacity(0.3)
                      : theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: event.profileImage.isNotEmpty
                      ? Image.network(
                          event.profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(theme, event),
                        )
                      : _buildDefaultAvatar(theme, event),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // DJ Name
          SizedBox(
            width: 80,
            child: Text(
              event.djName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 1),

          // Viewer Count
          Text(
            '${event.formattedViewerCount} viewers',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme, LiveEvent event) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: event.backgroundColors.isNotEmpty
              ? event.backgroundColors
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
