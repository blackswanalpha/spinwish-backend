import 'package:flutter/material.dart';
import 'package:spinwishapp/services/earnings_api_service.dart';

enum TransactionType { tip, request, payout, refund }

enum TransactionStatus { completed, pending, failed, cancelled }

class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final DateTime timestamp;
  final String? description;
  final String? sessionId;
  final String? listenerId;
  final String? listenerName;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.description,
    this.sessionId,
    this.listenerId,
    this.listenerName,
  });
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Tips', 'Requests', 'Payouts'];

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load tip payments and request payments from backend
      final tipPayments = await EarningsApiService.getCurrentDJTipHistory();
      final requestPayments =
          await EarningsApiService.getCurrentDJRequestHistory();

      // Convert to Transaction objects
      final transactions = <Transaction>[];

      // Add tip transactions
      for (final tip in tipPayments) {
        transactions.add(Transaction(
          id: tip.id,
          type: TransactionType.tip,
          status: TransactionStatus.completed,
          amount: tip.amount,
          timestamp: tip.transactionDate,
          description: 'Tip from ${tip.payerName}',
          listenerId: tip.phoneNumber,
          listenerName: tip.payerName,
        ));
      }

      // Add request transactions
      for (final request in requestPayments) {
        transactions.add(Transaction(
          id: request.id,
          type: TransactionType.request,
          status: TransactionStatus.completed,
          amount: request.amount,
          timestamp: request.transactionDate,
          description: 'Song request payment from ${request.payerName}',
          listenerId: request.phoneNumber,
          listenerName: request.payerName,
        ));
      }

      // Sort by timestamp (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: ${e.toString()}';
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
          'Transaction History',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(theme)
              : Column(
                  children: [
                    // Filter section
                    _buildFilterSection(theme),

                    // Transaction list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: _getFilteredTransactions().isEmpty
                            ? _buildEmptyState(theme)
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _getFilteredTransactions().length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionCard(
                                    theme,
                                    _getFilteredTransactions()[index],
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(ThemeData theme, Transaction transaction) {
    final isPositive = transaction.amount > 0;
    final color = _getTransactionColor(transaction.type, theme);
    final icon = _getTransactionIcon(transaction.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTransactionTitle(transaction),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (transaction.description != null)
                    Text(
                      transaction.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatTimestamp(transaction.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      _buildStatusChip(theme, transaction.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, TransactionStatus status) {
    Color color;
    String text;

    switch (status) {
      case TransactionStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case TransactionStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case TransactionStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case TransactionStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No transactions found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your transaction history will appear here',
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

  List<Transaction> _getFilteredTransactions() {
    if (_selectedFilter == 'All') {
      return _transactions;
    }

    TransactionType? filterType;
    switch (_selectedFilter) {
      case 'Tips':
        filterType = TransactionType.tip;
        break;
      case 'Requests':
        filterType = TransactionType.request;
        break;
      case 'Payouts':
        filterType = TransactionType.payout;
        break;
    }

    return _transactions.where((t) => t.type == filterType).toList();
  }

  Color _getTransactionColor(TransactionType type, ThemeData theme) {
    switch (type) {
      case TransactionType.tip:
        return Colors.pink;
      case TransactionType.request:
        return theme.colorScheme.primary;
      case TransactionType.payout:
        return Colors.green;
      case TransactionType.refund:
        return Colors.orange;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.tip:
        return Icons.favorite;
      case TransactionType.request:
        return Icons.queue_music;
      case TransactionType.payout:
        return Icons.account_balance_wallet;
      case TransactionType.refund:
        return Icons.undo;
    }
  }

  String _getTransactionTitle(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.tip:
        return 'Tip from ${transaction.listenerName ?? 'Listener'}';
      case TransactionType.request:
        return 'Song Request from ${transaction.listenerName ?? 'Listener'}';
      case TransactionType.payout:
        return 'Payout';
      case TransactionType.refund:
        return 'Refund';
    }
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
              'Error Loading Transactions',
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
              onPressed: _loadTransactions,
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
