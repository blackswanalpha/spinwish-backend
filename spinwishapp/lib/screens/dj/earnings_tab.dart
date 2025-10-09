import 'package:flutter/material.dart';
import 'package:spinwishapp/screens/dj/earnings/transaction_screen.dart';
import 'package:spinwishapp/screens/dj/earnings/payout_settings_screen.dart';
import 'package:spinwishapp/screens/dj/earnings/tips_analysis_screen.dart';
import 'package:spinwishapp/screens/dj/earnings/request_payout_dialog.dart';
import 'package:spinwishapp/screens/dj/request_payments_screen.dart';
import 'package:spinwishapp/services/dj_api_service.dart';
import 'package:spinwishapp/services/earnings_api_service.dart';
import 'package:spinwishapp/models/dj.dart';

class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  String selectedPeriod = 'This Month';
  final List<String> periods = ['Today', 'This Week', 'This Month', 'All Time'];

  DJ? currentDJ;
  DJStats? djStats;
  EarningsSummary? earningsSummary;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final dj = await DJApiService.getCurrentDJProfile();
      if (dj != null) {
        final stats = await DJApiService.getDJStats(dj.id);

        // Try to load earnings data from the new API
        EarningsSummary? earnings;
        try {
          earnings = await EarningsApiService.getCurrentDJEarningsSummary(
            period: selectedPeriod.toLowerCase().replaceAll(' ', ''),
          );
        } catch (e) {
          // Earnings API might not be available yet, continue without it
          debugPrint('Earnings API not available: $e');
        }

        setState(() {
          currentDJ = dj;
          djStats = stats;
          earningsSummary = earnings;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Unable to load DJ profile';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load earnings data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedPeriod,
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
              // Reload data for selected period
              _loadEarningsData();
            },
            itemBuilder: (context) => periods
                .map(
                  (period) => PopupMenuItem(value: period, child: Text(period)),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedPeriod,
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState(theme)
              : RefreshIndicator(
                  onRefresh: _loadEarningsData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Earnings Overview
                        _buildEarningsOverview(theme),
                        const SizedBox(height: 24),

                        // Revenue Breakdown
                        _buildRevenueBreakdown(theme),
                        const SizedBox(height: 24),

                        // Quick Actions
                        _buildQuickActions(theme),
                        const SizedBox(height: 24),

                        // Payout Section
                        _buildPayoutSection(theme),
                        const SizedBox(height: 24),

                        // Request and Tips Analysis
                        _buildRequestTipsSection(theme),
                        const SizedBox(height: 24),

                        // Transaction History
                        _buildTransactionHistory(theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEarningsOverview(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            earningsSummary != null
                ? 'KSH ${earningsSummary!.totalEarnings.toStringAsFixed(2)}'
                : djStats != null
                    ? 'KSH ${djStats!.totalEarnings.toStringAsFixed(2)}'
                    : 'KSH 0.00',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earningsSummary != null
                          ? 'KSH ${earningsSummary!.availableForPayout.toStringAsFixed(2)}'
                          : 'KSH 0.00',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earningsSummary != null
                          ? 'KSH ${earningsSummary!.pendingAmount.toStringAsFixed(2)}'
                          : 'KSH 0.00',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RequestPaymentsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.payment, size: 20),
                label: const Text('View Payments'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TransactionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 20),
                label: const Text('Transactions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRevenueCard(
                theme,
                'Tips',
                earningsSummary != null
                    ? 'KSH ${earningsSummary!.totalTips.toStringAsFixed(2)}'
                    : 'KSH 0.00',
                Icons.favorite,
                Colors.pink,
                earningsSummary != null && earningsSummary!.totalEarnings > 0
                    ? (earningsSummary!.totalTips /
                            earningsSummary!.totalEarnings *
                            100)
                        .round()
                    : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRevenueCard(
                theme,
                'Song Requests',
                earningsSummary != null
                    ? 'KSH ${earningsSummary!.totalRequests.toStringAsFixed(2)}'
                    : 'KSH 0.00',
                Icons.queue_music,
                theme.colorScheme.primary,
                earningsSummary != null && earningsSummary!.totalEarnings > 0
                    ? (earningsSummary!.totalRequests /
                            earningsSummary!.totalEarnings *
                            100)
                        .round()
                    : 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(
    ThemeData theme,
    String title,
    String amount,
    IconData icon,
    Color color,
    int percentage,
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
                '$percentage%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildPayoutSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payout Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PayoutSettingsScreen(),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Available for payout: KSH ${earningsSummary?.availableForPayout.toStringAsFixed(2) ?? "0.00"}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (earningsSummary?.availableForPayout ?? 0.0) > 0
                  ? () {
                      _showPayoutDialog(theme);
                    }
                  : null,
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Request Payout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Payouts are processed within 1-3 business days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTipsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Request & Tips Analysis',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TipsAnalysisScreen(),
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard(
                      theme,
                      'Tips This Month',
                      '0', // TODO: Get from earnings API
                      Icons.favorite,
                      Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticsCard(
                      theme,
                      'Requests Played',
                      djStats != null ? '${djStats!.totalRequests}' : '0',
                      Icons.queue_music,
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard(
                      theme,
                      'Avg. Tip Amount',
                      'KSH 0.00', // TODO: Get from earnings API
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnalyticsCard(
                      theme,
                      'Top Supporter',
                      'N/A', // TODO: Get from earnings API
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Transaction History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your earnings and payouts will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPayoutDialog(ThemeData theme) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RequestPayoutDialog(
        availableAmount: earningsSummary?.availableForPayout ?? 0.0,
      ),
    );

    // Reload earnings data if payout was successful
    if (result == true) {
      _loadEarningsData();
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
              'Error Loading Earnings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An unknown error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEarningsData,
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
}
