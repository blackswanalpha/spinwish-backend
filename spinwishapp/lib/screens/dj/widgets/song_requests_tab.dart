import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spinwishapp/services/user_requests_service.dart';
import 'package:spinwishapp/services/real_time_request_service.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:intl/intl.dart';
import 'package:spinwishapp/screens/dj/widgets/request_status_modal.dart';

enum RequestFilter { all, pending, approved, rejected }

/// Song Requests Tab - Shows all song requests with filtering
class SongRequestsTab extends StatefulWidget {
  final String sessionId;

  const SongRequestsTab({
    super.key,
    required this.sessionId,
  });

  @override
  State<SongRequestsTab> createState() => _SongRequestsTabState();
}

class _SongRequestsTabState extends State<SongRequestsTab> {
  List<PlaySongResponse> _allRequests = [];
  RequestFilter _selectedFilter = RequestFilter.all;
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'time'; // time, tip, status
  late RealTimeRequestService _realTimeRequestService;
  StreamSubscription? _requestUpdateSubscription;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _realTimeRequestService = RealTimeRequestService();
    _loadRequests();
    _setupRealTimeUpdates();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _requestUpdateSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealTimeUpdates() {
    // Listen to real-time request updates
    _realTimeRequestService.addListener(_onRealTimeUpdate);
  }

  void _onRealTimeUpdate() {
    // Refresh requests when real-time update occurs
    if (mounted) {
      _loadRequests();
    }
  }

  void _startAutoRefresh() {
    // Auto-refresh every 30 seconds as a fallback
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadRequests();
      }
    });
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final requests =
          await UserRequestsService.getRequestsBySession(widget.sessionId);
      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<PlaySongResponse> get _filteredRequests {
    var filtered = _allRequests;

    // Apply filter
    switch (_selectedFilter) {
      case RequestFilter.pending:
        filtered = filtered.where((r) => !r.status).toList();
        break;
      case RequestFilter.approved:
        filtered = filtered.where((r) => r.status).toList();
        break;
      case RequestFilter.rejected:
        // Assuming rejected requests are marked differently
        // For now, we'll show empty list
        filtered = [];
        break;
      case RequestFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final songName = r.songResponse?.first.title.toLowerCase() ?? '';
        final artistName = r.songResponse?.first.artist.toLowerCase() ?? '';
        final requesterName = r.clientName.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return songName.contains(query) ||
            artistName.contains(query) ||
            requesterName.contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'tip':
        filtered.sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
        break;
      case 'status':
        filtered.sort((a, b) => a.status == b.status ? 0 : (a.status ? 1 : -1));
        break;
      case 'time':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search and Filter Section
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
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by song, artist, or requester...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SpinWishDesignSystem.radiusSM),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),

              SpinWishDesignSystem.gapVerticalMD,

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(theme, 'All', RequestFilter.all),
                    SpinWishDesignSystem.gapHorizontalSM,
                    _buildFilterChip(theme, 'Pending', RequestFilter.pending),
                    SpinWishDesignSystem.gapHorizontalSM,
                    _buildFilterChip(theme, 'Approved', RequestFilter.approved),
                    SpinWishDesignSystem.gapHorizontalSM,
                    _buildFilterChip(theme, 'Rejected', RequestFilter.rejected),
                    SpinWishDesignSystem.gapHorizontalLG,
                    // Sort Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpinWishDesignSystem.spaceMD,
                        vertical: SpinWishDesignSystem.spaceSM,
                      ),
                      decoration: SpinWishDesignSystem.chipDecoration(theme),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.sort, size: 18),
                        items: const [
                          DropdownMenuItem(
                              value: 'time', child: Text('By Time')),
                          DropdownMenuItem(value: 'tip', child: Text('By Tip')),
                          DropdownMenuItem(
                              value: 'status', child: Text('By Status')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Requests List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRequests.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: SpinWishDesignSystem.paddingMD,
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(
                              theme, _filteredRequests[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, RequestFilter filter) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpinWishDesignSystem.spaceMD,
          vertical: SpinWishDesignSystem.spaceSM,
        ),
        decoration:
            SpinWishDesignSystem.chipDecoration(theme, isSelected: isSelected),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(ThemeData theme, PlaySongResponse request) {
    final song = request.songResponse?.first;
    final statusColor = request.status ? Colors.green : Colors.orange;
    final statusText = request.status ? 'APPROVED' : 'PENDING';

    return GestureDetector(
      onTap: () => _showRequestModal(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
        padding: SpinWishDesignSystem.paddingMD,
        decoration: SpinWishDesignSystem.cardDecoration(theme).copyWith(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Song Artwork Placeholder
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

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpinWishDesignSystem.spaceSM,
                    vertical: SpinWishDesignSystem.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(SpinWishDesignSystem.radiusFull),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                const Icon(Icons.monetization_on,
                    size: 16, color: Colors.green),
                SpinWishDesignSystem.gapHorizontalXS,
                Text(
                  'KSh ${request.amount?.toStringAsFixed(2) ?? '0.00'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('h:mm a').format(request.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            if (request.message != null && request.message!.isNotEmpty) ...[
              SpinWishDesignSystem.gapVerticalSM,
              Container(
                padding: SpinWishDesignSystem.paddingSM,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
                  borderRadius:
                      BorderRadius.circular(SpinWishDesignSystem.radiusSM),
                ),
                child: Text(
                  request.message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Quick Action Buttons
            SpinWishDesignSystem.gapVerticalMD,
            _buildQuickActions(theme, request),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, PlaySongResponse request) {
    if (request.status) {
      // Show "Mark as Played" for approved requests
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleMarkAsPlayed(request),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Mark as Played'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: BorderSide(color: Colors.blue.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(
              vertical: SpinWishDesignSystem.spaceSM,
            ),
          ),
        ),
      );
    }

    // Show Accept and Reject for pending requests
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleReject(request),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(
                vertical: SpinWishDesignSystem.spaceSM,
              ),
            ),
          ),
        ),
        SpinWishDesignSystem.gapHorizontalSM,
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _handleAccept(request),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: SpinWishDesignSystem.spaceSM,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRequestModal(PlaySongResponse request) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RequestStatusModal(
        request: request,
        onStatusChanged: () {
          _loadRequests();
        },
      ),
    );
  }

  Future<void> _handleAccept(PlaySongResponse request) async {
    try {
      await UserRequestsService.acceptRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! Song added to queue.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _handleReject(PlaySongResponse request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request?'),
        content: Text(
          'Reject "${request.songResponse?.first.title ?? 'this song'}"? The tip will be refunded.',
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

    try {
      await UserRequestsService.rejectRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected. Tip refunded.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _handleMarkAsPlayed(PlaySongResponse request) async {
    try {
      await UserRequestsService.markRequestAsDone(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request marked as played!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SpinWishDesignSystem.gapVerticalMD,
          Text(
            'No requests found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SpinWishDesignSystem.gapVerticalSM,
          Text(
            'Requests will appear here when listeners make them',
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
