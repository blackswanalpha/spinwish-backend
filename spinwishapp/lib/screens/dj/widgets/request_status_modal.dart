import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:intl/intl.dart';

/// Glassmorphism modal for managing song request status
class RequestStatusModal extends StatefulWidget {
  final PlaySongResponse request;
  final VoidCallback onStatusChanged;

  const RequestStatusModal({
    super.key,
    required this.request,
    required this.onStatusChanged,
  });

  @override
  State<RequestStatusModal> createState() => _RequestStatusModalState();
}

class _RequestStatusModalState extends State<RequestStatusModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    setState(() => _isProcessing = true);

    try {
      await UserRequestsService.acceptRequest(widget.request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! Song added to queue.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onStatusChanged();
        _closeModal();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept request: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request?'),
        content: const Text(
          'Are you sure you want to reject this request? The tip will be refunded to the requester.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await UserRequestsService.rejectRequest(widget.request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected. Tip refunded.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onStatusChanged();
        _closeModal();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject request: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleMarkAsPlayed() async {
    setState(() => _isProcessing = true);

    try {
      await UserRequestsService.markRequestAsDone(widget.request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request marked as played!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onStatusChanged();
        _closeModal();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as played: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final song = widget.request.songResponse?.first;
    final isApproved = widget.request.status;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _closeModal,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping modal
                child: Container(
                  margin: SpinWishDesignSystem.paddingLG,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SpinWishDesignSystem.radiusLG),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.surface.withOpacity(0.9),
                              theme.colorScheme.surface.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                              SpinWishDesignSystem.radiusLG),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: SpinWishDesignSystem.shadow2XL(
                            theme.colorScheme.shadow,
                          ),
                        ),
                        child: _isProcessing
                            ? _buildLoadingState(theme)
                            : _buildContent(theme, song, isApproved),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingXL,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SpinWishDesignSystem.gapVerticalMD,
          Text(
            'Processing...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, dynamic song, bool isApproved) {
    return SingleChildScrollView(
      child: Padding(
        padding: SpinWishDesignSystem.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Song Request',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _closeModal,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surfaceContainer.withOpacity(0.5),
                  ),
                ),
              ],
            ),

            SpinWishDesignSystem.gapVerticalLG,

            // Song artwork and info
            _buildSongInfo(theme, song),

            SpinWishDesignSystem.gapVerticalLG,

            // Requester info
            _buildRequesterInfo(theme),

            SpinWishDesignSystem.gapVerticalLG,

            // Status badge
            _buildStatusBadge(theme, isApproved),

            if (widget.request.message != null &&
                widget.request.message!.isNotEmpty) ...[
              SpinWishDesignSystem.gapVerticalMD,
              _buildMessage(theme),
            ],

            SpinWishDesignSystem.gapVerticalXL,

            // Action buttons
            _buildActionButtons(theme, isApproved),
          ],
        ),
      ),
    );
  }

  Widget _buildSongInfo(ThemeData theme, dynamic song) {
    return Container(
      padding: SpinWishDesignSystem.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(SpinWishDesignSystem.radiusSM),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),

          SpinWishDesignSystem.gapHorizontalMD,

          // Song details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song?.title ?? 'Unknown Song',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SpinWishDesignSystem.gapVerticalXS,
                Text(
                  song?.artist ?? 'Unknown Artist',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (song?.album != null) ...[
                  SpinWishDesignSystem.gapVerticalXS,
                  Text(
                    song!.album!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequesterInfo(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Requested by',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                widget.request.clientName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Row(
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: Colors.green,
                size: 20,
              ),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Tip Amount',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                'KSh ${widget.request.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Requested at',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(widget.request.createdAt),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isApproved) {
    final statusColor = isApproved ? Colors.green : Colors.orange;
    final statusText = isApproved ? 'APPROVED' : 'PENDING';
    final statusIcon = isApproved ? Icons.check_circle : Icons.pending;

    return Container(
      padding: SpinWishDesignSystem.paddingMD,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          SpinWishDesignSystem.gapHorizontalSM,
          Text(
            statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              SpinWishDesignSystem.gapHorizontalXS,
              Text(
                'Message',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Text(
            widget.request.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isApproved) {
    if (isApproved) {
      // Show only "Mark as Played" button for approved requests
      return ElevatedButton.icon(
        onPressed: _handleMarkAsPlayed,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Mark as Played'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: SpinWishDesignSystem.spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
          ),
        ),
      );
    }

    // Show Accept and Reject buttons for pending requests
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleReject,
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              padding: const EdgeInsets.symmetric(
                vertical: SpinWishDesignSystem.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SpinWishDesignSystem.radiusSM),
              ),
            ),
          ),
        ),
        SpinWishDesignSystem.gapHorizontalMD,
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _handleAccept,
            icon: const Icon(Icons.check),
            label: const Text('Accept & Add to Queue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: SpinWishDesignSystem.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SpinWishDesignSystem.radiusSM),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

