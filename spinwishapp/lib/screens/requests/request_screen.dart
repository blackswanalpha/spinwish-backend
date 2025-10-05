import 'package:flutter/material.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/widgets/request_card.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Pending',
    'Accepted',
    'Played',
    'Rejected'
  ];

  List<Request> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load requests from API when endpoint is available
      // For now, use empty list
      final requests = <Request>[];

      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allRequests = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Request> _getFilteredRequests() {
    List<Request> requests = List.from(_allRequests);

    if (_selectedFilter != 'All') {
      final status = RequestStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == _selectedFilter.toLowerCase(),
      );
      requests = requests.where((r) => r.status == status).toList();
    }

    // Sort by timestamp (newest first)
    requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return requests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Requests',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard(context, 'Total Spent', '\$23.50',
                          Icons.payment, theme.colorScheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(context, 'Songs Played', '5',
                          Icons.music_note, theme.colorScheme.secondary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(context, 'In Queue', '2',
                          Icons.queue, theme.colorScheme.tertiary)),
                ],
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      filter,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              },
            ),
          ),

          // Requests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];

                            // Create placeholder data since we don't have API endpoints yet
                            final song = Song(
                              id: request.songId,
                              title: 'Song Title',
                              artist: 'Artist Name',
                              album: 'Album',
                              genre: 'Genre',
                              duration: 180,
                              artworkUrl: '',
                              baseRequestPrice: request.amount,
                              popularity: 50,
                              isExplicit: false,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RequestCard(
                                request: request,
                                song: song,
                                dj: null, // No DJ data available
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // Quick Request FAB
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "request_screen_fab",
        onPressed: () {
          // Navigate to catalogue or active sessions
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Browse music catalogue to make a new request'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        label: const Text('New Request'),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.queue_music_outlined,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No Requests Yet'
                : 'No $_selectedFilter Requests',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Start requesting songs from your favorite DJs'
                : 'Try changing the filter or make a new request',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to catalogue
            },
            icon: Icon(Icons.library_music, color: theme.colorScheme.onPrimary),
            label: Text(
              'Browse Music',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
