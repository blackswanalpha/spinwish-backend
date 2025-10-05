import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/session_history_service.dart';
import 'package:spinwishapp/widgets/session_history_card.dart';
import 'package:spinwishapp/widgets/session_history_filters.dart';
import 'package:spinwishapp/widgets/session_analytics_dashboard.dart';
import 'package:spinwishapp/widgets/session_performance_chart.dart';
import 'package:spinwishapp/widgets/session_insights_widget.dart';
import 'package:spinwishapp/widgets/session_comparison_widget.dart';
import 'package:spinwishapp/widgets/session_goals_widget.dart';
import 'package:spinwishapp/widgets/session_export_dialog.dart';
import 'package:spinwishapp/widgets/session_search_delegate.dart';
import 'package:spinwishapp/screens/dj/session_detail_screen.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showFilters = false;
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Defer data loading until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final historyService =
        Provider.of<SessionHistoryService>(context, listen: false);
    await historyService.loadSessionHistory();

    // Load analytics
    final analytics = await historyService.getSessionAnalytics();
    if (mounted) {
      setState(() {
        _analytics = analytics;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session History',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<SessionHistoryService>(
            builder: (context, historyService, child) {
              return IconButton(
                onPressed: historyService.hasData
                    ? () {
                        showSearch(
                          context: context,
                          delegate: SessionSearchDelegate(
                              sessions: historyService.allSessions),
                        );
                      }
                    : null,
                icon: const Icon(Icons.search),
                tooltip: 'Search Sessions',
              );
            },
          ),
          Consumer<SessionHistoryService>(
            builder: (context, historyService, child) {
              return IconButton(
                onPressed: historyService.hasData
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => SessionExportDialog(
                            sessions: historyService.filteredSessions,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.download),
                tooltip: 'Export Data',
              );
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sessions', icon: Icon(Icons.history)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Consumer<SessionHistoryService>(
        builder: (context, historyService, child) {
          return Column(
            children: [
              // Filters (collapsible)
              if (_showFilters) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SessionHistoryFilters(
                    currentFilter: historyService.currentFilter,
                    currentSort: historyService.currentSort,
                    onFilterChanged: historyService.applyFilter,
                    onSortChanged: historyService.applySortBy,
                  ),
                ),
              ],

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSessionsList(historyService),
                    _buildAnalyticsView(historyService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionsList(SessionHistoryService historyService) {
    if (historyService.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (historyService.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load session history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              historyService.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (historyService.filteredSessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyService.filteredSessions.length,
        itemBuilder: (context, index) {
          final session = historyService.filteredSessions[index];
          return SessionHistoryCard(
            session: session,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionDetailScreen(session: session),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsView(SessionHistoryService historyService) {
    if (historyService.isLoading || _analytics == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (historyService.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Goals
          if (historyService.allSessions.length >= 3) ...[
            SessionGoalsWidget(sessions: historyService.allSessions),
            const SizedBox(height: 24),
          ],

          // Insights
          if (historyService.allSessions.length >= 5) ...[
            SessionInsightsWidget(sessions: historyService.allSessions),
            const SizedBox(height: 24),
          ],

          // Comparison
          if (historyService.allSessions.length >= 4) ...[
            SessionComparisonWidget(sessions: historyService.allSessions),
            const SizedBox(height: 24),
          ],

          // Performance Charts
          SessionPerformanceChart(
            sessions: historyService.allSessions,
            title: 'Earnings Trend',
            metric: 'earnings',
          ),

          const SizedBox(height: 24),

          SessionPerformanceChart(
            sessions: historyService.allSessions,
            title: 'Listener Engagement',
            metric: 'listeners',
          ),

          const SizedBox(height: 24),

          // Analytics Dashboard
          SessionAnalyticsDashboard(analytics: _analytics!),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first session to see it here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Session'),
          ),
        ],
      ),
    );
  }
}
