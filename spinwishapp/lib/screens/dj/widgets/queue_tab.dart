import 'package:flutter/material.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/utils/design_system.dart';

/// Queue Tab - Displays approved song requests in play order
class QueueTab extends StatefulWidget {
  final String sessionId;

  const QueueTab({
    super.key,
    required this.sessionId,
  });

  @override
  State<QueueTab> createState() => _QueueTabState();
}

class _QueueTabState extends State<QueueTab> {
  List<PlaySongResponse> _queueItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);

    try {
      final queue = await UserRequestsService.getSessionQueue(widget.sessionId);
      setState(() {
        _queueItems = queue;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading queue: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load queue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsPlayed(String requestId) async {
    try {
      // TODO: Implement mark as played API call
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song marked as played'),
            backgroundColor: Colors.green,
          ),
        );
        _loadQueue();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as played: $e'),
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

    if (_queueItems.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _loadQueue,
      child: ListView.builder(
        padding: SpinWishDesignSystem.paddingMD,
        itemCount: _queueItems.length,
        itemBuilder: (context, index) {
          final isCurrentlyPlaying = index == 0;
          return _buildQueueItem(
            theme,
            _queueItems[index],
            index + 1,
            isCurrentlyPlaying,
          );
        },
      ),
    );
  }

  Widget _buildQueueItem(
    ThemeData theme,
    PlaySongResponse request,
    int position,
    bool isCurrentlyPlaying,
  ) {
    final song = request.songResponse?.first;

    return Container(
      margin: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        gradient: isCurrentlyPlaying
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              )
            : null,
        color: isCurrentlyPlaying ? null : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
        border: Border.all(
          color: isCurrentlyPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isCurrentlyPlaying ? 2 : 1,
        ),
        boxShadow: isCurrentlyPlaying
            ? SpinWishDesignSystem.glowMD(theme.colorScheme.primary)
            : SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
      ),
      child: Padding(
        padding: SpinWishDesignSystem.paddingMD,
        child: Column(
          children: [
            Row(
              children: [
                // Queue Position
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isCurrentlyPlaying
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: isCurrentlyPlaying
                        ? null
                        : theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCurrentlyPlaying
                        ? const Icon(Icons.play_arrow, color: Colors.white)
                        : Text(
                            '#$position',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SpinWishDesignSystem.gapHorizontalMD,

                // Song Artwork
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(SpinWishDesignSystem.radiusSM),
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
                      if (isCurrentlyPlaying)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpinWishDesignSystem.spaceSM,
                            vertical: SpinWishDesignSystem.spaceXS,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                                SpinWishDesignSystem.radiusFull),
                          ),
                          child: Text(
                            'NOW PLAYING',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      if (isCurrentlyPlaying)
                        SpinWishDesignSystem.gapVerticalXS,
                      Text(
                        song?.title ?? 'Unknown Song',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song?.artist ?? 'Unknown Artist',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SpinWishDesignSystem.gapVerticalMD,

            // Request Details
            Row(
              children: [
                Icon(Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                SpinWishDesignSystem.gapHorizontalXS,
                Text(
                  request.clientName,
                  style: theme.textTheme.bodySmall,
                ),
                SpinWishDesignSystem.gapHorizontalMD,
                Icon(Icons.monetization_on, size: 16, color: Colors.green),
                SpinWishDesignSystem.gapHorizontalXS,
                Text(
                  'KSH ${request.amount?.toStringAsFixed(2) ?? '0.00'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isCurrentlyPlaying)
                  ElevatedButton.icon(
                    onPressed: () => _markAsPlayed(request.id),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark Played'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpinWishDesignSystem.spaceMD,
                        vertical: SpinWishDesignSystem.spaceSM,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SpinWishDesignSystem.gapVerticalMD,
          Text(
            'Queue is empty',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Text(
            'Approved song requests will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
