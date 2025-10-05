import 'package:flutter/material.dart';
import 'package:spinwishapp/services/earnings_api_service.dart';

class TipData {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String? message;
  final String listenerId;
  final String listenerName;
  final String? sessionId;

  TipData({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.message,
    required this.listenerId,
    required this.listenerName,
    this.sessionId,
  });
}

class RequestData {
  final String id;
  final String songTitle;
  final String artist;
  final double amount;
  final DateTime timestamp;
  final String listenerId;
  final String listenerName;
  final bool wasPlayed;
  final String? sessionId;

  RequestData({
    required this.id,
    required this.songTitle,
    required this.artist,
    required this.amount,
    required this.timestamp,
    required this.listenerId,
    required this.listenerName,
    required this.wasPlayed,
    this.sessionId,
  });
}

class TipsAnalysisScreen extends StatefulWidget {
  const TipsAnalysisScreen({super.key});

  @override
  State<TipsAnalysisScreen> createState() => _TipsAnalysisScreenState();
}

class _TipsAnalysisScreenState extends State<TipsAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time'
  ];

  List<TipData> _tips = [];
  List<RequestData> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load tip payments from backend
      final tipPayments = await EarningsApiService.getCurrentDJTipHistory();
      final requestPayments =
          await EarningsApiService.getCurrentDJRequestHistory();

      // Convert to TipData objects
      final tips = tipPayments
          .map((tip) => TipData(
                id: tip.id,
                amount: tip.amount,
                timestamp: tip.transactionDate,
                message: 'Tip from ${tip.payerName}',
                listenerId: tip.phoneNumber,
                listenerName: tip.payerName,
                sessionId: null, // Session ID not available in tip payment
              ))
          .toList();

      // Convert to RequestData objects
      final requests = requestPayments
          .map((request) => RequestData(
                id: request.id,
                songTitle:
                    'Song Request', // Song title not available in payment data
                artist: 'Unknown Artist',
                amount: request.amount,
                timestamp: request.transactionDate,
                listenerId: request.phoneNumber,
                listenerName: request.payerName,
                wasPlayed: true, // Assume played if payment was processed
                sessionId: null,
              ))
          .toList();

      setState(() {
        _tips = tips;
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tips & Requests Analysis',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadData(); // Reload data for new period
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tips'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(theme)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(theme),
                    _buildTipsTab(theme),
                    _buildRequestsTab(theme),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    final totalTips = _tips.fold<double>(0, (sum, tip) => sum + tip.amount);
    final totalRequests =
        _requests.fold<double>(0, (sum, req) => sum + req.amount);
    final totalEarnings = totalTips + totalRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Total Earnings',
                  '\$${totalEarnings.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Tips Received',
                  '${_tips.length}',
                  Icons.favorite,
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Requests Played',
                  '${_requests.where((r) => r.wasPlayed).length}',
                  Icons.queue_music,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Avg. Tip',
                  '\$${_tips.isNotEmpty ? (totalTips / _tips.length).toStringAsFixed(2) : '0.00'}',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top supporters
          _buildTopSupportersSection(theme),
          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivitySection(theme),
        ],
      ),
    );
  }

  Widget _buildTipsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return _buildTipCard(theme, tip);
      },
    );
  }

  Widget _buildRequestsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _buildRequestCard(theme, request);
      },
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSupportersSection(ThemeData theme) {
    // Combine tips and requests to find top supporters
    final Map<String, double> supporterTotals = {};
    final Map<String, String> supporterNames = {};

    for (final tip in _tips) {
      supporterTotals[tip.listenerId] =
          (supporterTotals[tip.listenerId] ?? 0) + tip.amount;
      supporterNames[tip.listenerId] = tip.listenerName;
    }

    for (final request in _requests) {
      supporterTotals[request.listenerId] =
          (supporterTotals[request.listenerId] ?? 0) + request.amount;
      supporterNames[request.listenerId] = request.listenerName;
    }

    final topSupporters = supporterTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Supporters',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...topSupporters.take(5).map((entry) {
          final name = supporterNames[entry.key] ?? 'Unknown';
          final amount = entry.value;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(name),
            trailing: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivitySection(ThemeData theme) {
    // Combine and sort recent tips and requests
    final List<dynamic> recentActivity = [
      ..._tips.map((tip) => {'type': 'tip', 'data': tip}),
      ..._requests.map((req) => {'type': 'request', 'data': req}),
    ];

    recentActivity.sort((a, b) {
      final aTime = a['type'] == 'tip'
          ? (a['data'] as TipData).timestamp
          : (a['data'] as RequestData).timestamp;
      final bTime = b['type'] == 'tip'
          ? (b['data'] as TipData).timestamp
          : (b['data'] as RequestData).timestamp;
      return bTime.compareTo(aTime);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recentActivity.take(5).map((activity) {
          if (activity['type'] == 'tip') {
            return _buildTipCard(theme, activity['data'] as TipData);
          } else {
            return _buildRequestCard(theme, activity['data'] as RequestData);
          }
        }),
      ],
    );
  }

  Widget _buildTipCard(ThemeData theme, TipData tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.withOpacity(0.1),
          child: const Icon(Icons.favorite, color: Colors.pink),
        ),
        title: Text('Tip from ${tip.listenerName}'),
        subtitle: tip.message != null ? Text(tip.message!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${tip.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              _formatTimestamp(tip.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(ThemeData theme, RequestData request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.queue_music, color: theme.colorScheme.primary),
        ),
        title: Text('${request.songTitle} - ${request.artist}'),
        subtitle: Text('Requested by ${request.listenerName}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${request.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  request.wasPlayed ? Icons.check_circle : Icons.pending,
                  size: 12,
                  color: request.wasPlayed ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  request.wasPlayed ? 'Played' : 'Pending',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: request.wasPlayed ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
