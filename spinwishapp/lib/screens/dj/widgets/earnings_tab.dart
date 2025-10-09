import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/session_analytics_service.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:intl/intl.dart';

/// Earnings Tab - Detailed earnings breakdown for the session
class EarningsTab extends StatefulWidget {
  final String sessionId;

  const EarningsTab({
    super.key,
    required this.sessionId,
  });

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  // Placeholder transaction data - replace with actual API call
  final List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      // TODO: Implement transactions API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  void _exportReport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SessionAnalyticsService>(
      builder: (context, analyticsService, child) {
        final analytics = analyticsService.currentAnalytics;

        return RefreshIndicator(
          onRefresh: () async {
            await analyticsService.refreshAnalytics();
            await _loadTransactions();
          },
          child: SingleChildScrollView(
            padding: SpinWishDesignSystem.paddingMD,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(theme, analytics),

                SpinWishDesignSystem.gapVerticalLG,

                // Earnings Timeline (Placeholder)
                _buildEarningsTimeline(theme),

                SpinWishDesignSystem.gapVerticalLG,

                // Transaction List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _exportReport,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                SpinWishDesignSystem.gapVerticalMD,

                // Transactions List
                if (_transactions.isEmpty)
                  _buildEmptyTransactions(theme)
                else
                  ..._transactions.map((transaction) =>
                      _buildTransactionItem(theme, transaction)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(ThemeData theme, dynamic analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Total Earnings',
            'KSH ${analytics?.totalEarnings.toStringAsFixed(2) ?? '0.00'}',
            Icons.monetization_on,
            Colors.green,
          ),
        ),
        SpinWishDesignSystem.gapHorizontalMD,
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Total Tips',
            'KSH ${analytics?.totalTips.toStringAsFixed(2) ?? '0.00'}',
            Icons.favorite,
            Colors.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: SpinWishDesignSystem.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SpinWishDesignSystem.gapVerticalMD,
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTimeline(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingLG,
      decoration: SpinWishDesignSystem.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: theme.colorScheme.primary),
              SpinWishDesignSystem.gapHorizontalSM,
              Text(
                'Earnings Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SpinWishDesignSystem.gapVerticalLG,
          // Placeholder for chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 60,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  SpinWishDesignSystem.gapVerticalSM,
                  Text(
                    'Chart visualization coming soon',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(ThemeData theme, Map<String, dynamic> transaction) {
    final isRequest = transaction['type'] == 'Request';
    final color = isRequest ? Colors.blue : Colors.pink;
    final icon = isRequest ? Icons.music_note : Icons.favorite;

    return Container(
      margin: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
      padding: SpinWishDesignSystem.paddingMD,
      decoration: SpinWishDesignSystem.cardDecoration(theme),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpinWishDesignSystem.spaceSM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SpinWishDesignSystem.gapHorizontalMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['type'] ?? 'Unknown',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'From ${transaction['from'] ?? 'Unknown'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (transaction['song'] != null)
                  Text(
                    transaction['song'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KSH ${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(
                  transaction['timestamp'] ?? DateTime.now(),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(ThemeData theme) {
    return Container(
      padding: SpinWishDesignSystem.paddingXL,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            SpinWishDesignSystem.gapVerticalMD,
            Text(
              'No transactions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SpinWishDesignSystem.gapVerticalSM,
            Text(
              'Transactions will appear here as you receive tips and requests',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

