import 'package:flutter/material.dart';
import 'package:spinwishapp/models/dj.dart';
// Removed sample_data import - using API data now
import 'package:spinwishapp/screens/djs/dj_detail_screen.dart';

class DJCard extends StatefulWidget {
  final DJ dj;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const DJCard({
    super.key,
    required this.dj,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<DJCard> createState() => _DJCardState();
}

class _DJCardState extends State<DJCard> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load user's favorite DJs from API
    _isFollowing = false; // Default to not following
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? 'Following ${widget.dj.name}'
              : 'Unfollowed ${widget.dj.name}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Create placeholder club data since we don't have API endpoints yet
    final club = widget.dj.clubId.isNotEmpty ? 'Club Name' : null;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainer.withOpacity(0.8),
            ],
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DJDetailScreen(dj: widget.dj),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image and Live Status
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(widget.dj.profileImage),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                        child: widget.dj.profileImage.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),

                      // Live indicator
                      if (widget.dj.isLive)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSecondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Follow button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: _toggleFollow,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isFollowing
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface.withOpacity(
                                      0.9,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFollowing
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              size: 16,
                              color: _isFollowing
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // DJ Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.dj.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.dj.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Club name
                  if (club != null)
                    Text(
                      'at $club',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),

                  // Genres
                  Flexible(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: widget.dj.genres
                          .take(2)
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                genre,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  // Followers count
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatFollowers(widget.dj.followers)} followers',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}k';
    }
    return followers.toString();
  }
}
