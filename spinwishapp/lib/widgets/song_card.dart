import 'package:flutter/material.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/services/favorites_service.dart';
import 'package:spinwishapp/utils/design_system.dart';

class SongCard extends StatefulWidget {
  final Song song;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;
  final VoidCallback? onRequest;

  const SongCard({
    super.key,
    required this.song,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    this.onRequest,
  });

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    if (widget.showFavoriteButton && !widget.isFavorite) {
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await FavoritesService.isSongFavorite(widget.song.id);
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    } catch (e) {
      // Ignore error, keep default state
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newFavoriteStatus =
          await FavoritesService.toggleSongFavorite(widget.song);

      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
          _isLoading = false;
        });

        widget.onFavoriteToggle?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus
                  ? '${widget.song.title} added to favorites'
                  : '${widget.song.title} removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
            child: Row(
              children: [
                // Album Art
                _buildAlbumArt(theme),

                const SizedBox(width: SpinWishDesignSystem.spaceMD),

                // Song Info
                Expanded(
                  child: _buildSongInfo(theme),
                ),

                // Actions
                _buildActions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        ),
      ),
      child: widget.song.artworkUrl.isNotEmpty
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(SpinWishDesignSystem.radiusSM),
              child: Image.network(
                widget.song.artworkUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAlbumArt(theme),
              ),
            )
          : _buildDefaultAlbumArt(theme),
    );
  }

  Widget _buildDefaultAlbumArt(ThemeData theme) {
    return Icon(
      Icons.music_note,
      color: theme.colorScheme.onPrimary,
      size: 24,
    );
  }

  Widget _buildSongInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Song Title
        Text(
          widget.song.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // Artist
        Text(
          widget.song.artist,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // Genre and Duration
        Row(
          children: [
            Text(
              widget.song.genre,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' • ${_formatDuration(widget.song.duration)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Price
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'KSH ${widget.song.baseRequestPrice.toStringAsFixed(0)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: SpinWishDesignSystem.spaceSM),

        // Request Button
        if (widget.onRequest != null)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onRequest,
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
            ),
          ),

        if (widget.onRequest != null)
          const SizedBox(width: SpinWishDesignSystem.spaceSM),

        // Favorite Button
        if (widget.showFavoriteButton)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isFavorite
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: _isFavorite
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _toggleFavorite,
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 14,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
