import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/enhanced_queue_service.dart';

class EnhancedRequestQueueWidget extends StatefulWidget {
  const EnhancedRequestQueueWidget({super.key});

  @override
  State<EnhancedRequestQueueWidget> createState() => _EnhancedRequestQueueWidgetState();
}

class _EnhancedRequestQueueWidgetState extends State<EnhancedRequestQueueWidget> {
  final EnhancedQueueService _queueService = EnhancedQueueService();
  Map<String, Object> _queueStats = {};
  bool _showStatistics = false;

  @override
  void initState() {
    super.initState();
    _loadQueueStatistics();
  }

  Future<void> _loadQueueStatistics() async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final stats = await sessionService.getQueueStatistics();
    setState(() {
      _queueStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SessionService>(
      builder: (context, sessionService, child) {
        final pendingRequests = sessionService.requestQueue
            .where((request) => request.status == RequestStatus.pending)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, pendingRequests.length),
            if (_showStatistics) _buildStatistics(theme),
            const SizedBox(height: 16),
            if (pendingRequests.isEmpty)
              _buildEmptyState(theme)
            else
              Expanded(
                child: _buildReorderableQueue(context, theme, pendingRequests, sessionService),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, int queueLength) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Priority Queue ($queueLength)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadQueueStatistics,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Queue',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showStatistics = !_showStatistics;
                });
              },
              icon: Icon(_showStatistics ? Icons.analytics : Icons.analytics_outlined),
              tooltip: 'Toggle Statistics',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(ThemeData theme) {
    if (_queueStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue Analytics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Total Value',
                  '\$${_queueStats['totalQueueValue'] ?? 0.0}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Avg Tip',
                  '\$${_queueStats['averageTipAmount'] ?? 0.0}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Avg Wait',
                  '${_queueStats['averageWaitTime'] ?? 0.0}m',
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  theme,
                  'Oldest',
                  '${_queueStats['oldestRequestAge'] ?? 0}m',
                  Icons.schedule,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No pending requests',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Requests will appear here ordered by priority',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableQueue(
    BuildContext context,
    ThemeData theme,
    List<Request> requests,
    SessionService sessionService,
  ) {
    return ReorderableListView.builder(
      itemCount: requests.length,
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        // Create new order
        final reorderedRequests = List<Request>.from(requests);
        final item = reorderedRequests.removeAt(oldIndex);
        reorderedRequests.insert(newIndex, item);

        // Extract request IDs in new order
        final requestIds = reorderedRequests.map((r) => r.id).toList();

        // Update queue order
        final success = await sessionService.reorderQueue(requestIds);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Queue reordered successfully')),
          );
          _loadQueueStatistics(); // Refresh stats
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reorder queue')),
          );
        }
      },
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildEnhancedRequestCard(
          context,
          theme,
          request,
          sessionService,
          index,
        );
      },
    );
  }

  Widget _buildEnhancedRequestCard(
    BuildContext context,
    ThemeData theme,
    Request request,
    SessionService sessionService,
    int index,
  ) {
    final priorityScore = sessionService.calculatePriorityScore(request);
    final estimatedWait = sessionService.getEstimatedWaitTime(index + 1);
    
    return Card(
      key: ValueKey(request.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with position and priority
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priorityScore).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: _getPriorityColor(priorityScore),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${priorityScore.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(priorityScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Song info and tip amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Song Request',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${request.songId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    '\$${request.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Wait time and message
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Est. wait: ${estimatedWait.inMinutes}m ${estimatedWait.inSeconds % 60}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (request.message != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      request.message!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => sessionService.rejectRequest(request.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => sessionService.acceptRequest(request.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  Color _getPriorityColor(double score) {
    if (score >= 8.0) return Colors.red;
    if (score >= 6.0) return Colors.orange;
    if (score >= 4.0) return Colors.blue;
    return Colors.grey;
  }
}
