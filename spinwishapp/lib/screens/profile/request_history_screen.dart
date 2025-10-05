import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spinwishapp/models/request_history.dart';
import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/theme.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<RequestHistoryItem> _historyItems = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  RequestHistoryFilter _currentFilter = RequestHistoryFilter();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _isLoading = true;
      });
    }

    try {
      final items = await ProfileService.getRequestHistory(
        page: _currentPage,
        limit: 20,
        filter: _currentFilter.hasActiveFilters ? _currentFilter : null,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _historyItems = items;
          } else {
            _historyItems.addAll(items);
          }
          _hasMoreData = items.length == 20;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });

        // Show more user-friendly error messages
        String errorMessage = 'Failed to load request history';
        if (e.toString().contains('not yet implemented') ||
            e.toString().contains('NOT_IMPLEMENTED')) {
          errorMessage = 'Request history feature is coming soon!';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Please check your internet connection and try again';
        } else if (e.toString().contains('server')) {
          errorMessage = 'Server error. Please try again later';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadHistory(refresh: true),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadHistory();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _debounceSearch();
  }

  Timer? _searchDebounce;
  void _debounceSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadHistory(refresh: true);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          _loadHistory(refresh: true);
        },
      ),
    );
  }

  Widget _buildHistoryItem(RequestHistoryItem item) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(item.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(item.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                item.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.statusDisplayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(item.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(item.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: item.amount != null
            ? Text(
                item.formattedAmount,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
      ),
    );
  }

  IconData _getTypeIcon(RequestHistoryType type) {
    switch (type) {
      case RequestHistoryType.songRequest:
        return Icons.music_note;
      case RequestHistoryType.tip:
        return Icons.favorite;
      case RequestHistoryType.payment:
        return Icons.payment;
      case RequestHistoryType.subscription:
        return Icons.subscriptions;
      case RequestHistoryType.refund:
        return Icons.money_off;
    }
  }

  Color _getStatusColor(RequestHistoryStatus status) {
    switch (status) {
      case RequestHistoryStatus.pending:
        return SpinWishColors.warning;
      case RequestHistoryStatus.accepted:
      case RequestHistoryStatus.played:
        return SpinWishColors.success;
      case RequestHistoryStatus.rejected:
      case RequestHistoryStatus.cancelled:
      case RequestHistoryStatus.expired:
        return SpinWishColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request History',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
                if (_currentFilter.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer,
              ),
            ),
          ),

          // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _historyItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadHistory(refresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              _historyItems.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _historyItems.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildHistoryItem(_historyItems[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 60,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No History Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _currentFilter.hasActiveFilters
                  ? 'Try adjusting your search or filters.'
                  : 'Your request history will appear here once you start making song requests.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && !_currentFilter.hasActiveFilters) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildFeatureItem(
                          theme,
                          Icons.music_note,
                          'Requests',
                          'Track requests',
                        ),
                        const SizedBox(width: 8),
                        _buildFeatureItem(
                          theme,
                          Icons.favorite,
                          'Tips',
                          'View tip history',
                        ),
                        const SizedBox(width: 8),
                        _buildFeatureItem(
                          theme,
                          Icons.payment,
                          'Payments',
                          'Monitor transactions',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      ThemeData theme, IconData icon, String title, String description) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final RequestHistoryFilter currentFilter;
  final Function(RequestHistoryFilter) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RequestHistoryFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Filter History',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Type Filter
          Text(
            'Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RequestHistoryType.values.map((type) {
              final isSelected = _filter.type == type;
              return FilterChip(
                label: Text(type.toString().split('.').last),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filter = _filter.copyWith(
                      type: selected ? type : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Status Filter
          Text(
            'Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RequestHistoryStatus.values.map((status) {
              final isSelected = _filter.status == status;
              return FilterChip(
                label: Text(status.toString().split('.').last),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filter = _filter.copyWith(
                      status: selected ? status : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filter = RequestHistoryFilter();
                    });
                    widget.onFilterChanged(_filter);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterChanged(_filter);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
