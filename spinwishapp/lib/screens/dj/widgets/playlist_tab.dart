import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/design_system.dart';

/// Playlist Tab - Shows DJ's curated playlist for the session
class PlaylistTab extends StatefulWidget {
  final String sessionId;

  const PlaylistTab({
    super.key,
    required this.sessionId,
  });

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  bool _isLoading = false;
  String _searchQuery = '';
  
  // Placeholder data - replace with actual API call
  final List<Map<String, dynamic>> _playlistSongs = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement playlist API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading playlist: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playSong(String songId) async {
    try {
      // TODO: Implement play song API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song started playing'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play song: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToQueue(String songId) async {
    try {
      // TODO: Implement add to queue API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song added to queue'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to queue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_playlistSongs.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Search Bar
        Container(
          padding: SpinWishDesignSystem.paddingMD,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search playlist...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Playlist Info
        Container(
          padding: SpinWishDesignSystem.paddingMD,
          child: Row(
            children: [
              Icon(Icons.playlist_play, color: theme.colorScheme.primary),
              SpinWishDesignSystem.gapHorizontalSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Playlist',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_playlistSongs.length} songs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Songs List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPlaylist,
            child: ListView.builder(
              padding: SpinWishDesignSystem.paddingMD,
              itemCount: _playlistSongs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(theme, _playlistSongs[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongItem(ThemeData theme, Map<String, dynamic> song) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
      padding: SpinWishDesignSystem.paddingMD,
      decoration: SpinWishDesignSystem.cardDecoration(theme),
      child: Row(
        children: [
          // Song Artwork
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
            ),
            child: Icon(
              Icons.music_note,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),

          SpinWishDesignSystem.gapHorizontalMD,

          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title'] ?? 'Unknown Song',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song['artist'] ?? 'Unknown Artist',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song['duration'] ?? '0:00',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          IconButton(
            onPressed: () => _playSong(song['id']),
            icon: const Icon(Icons.play_circle_filled),
            color: theme.colorScheme.primary,
            tooltip: 'Play Now',
          ),
          IconButton(
            onPressed: () => _addToQueue(song['id']),
            icon: const Icon(Icons.add_to_queue),
            color: theme.colorScheme.secondary,
            tooltip: 'Add to Queue',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SpinWishDesignSystem.gapVerticalMD,
          Text(
            'No playlist selected',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Text(
            'Select a playlist to play songs from',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SpinWishDesignSystem.gapVerticalLG,
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open playlist selection dialog
            },
            icon: const Icon(Icons.playlist_add),
            label: const Text('Select Playlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: SpinWishDesignSystem.spaceLG,
                vertical: SpinWishDesignSystem.spaceMD,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

