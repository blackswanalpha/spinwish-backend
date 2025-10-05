import 'package:flutter/material.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/payment_history_service.dart';
import 'package:spinwishapp/utils/payment_error_handler.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PaymentType? _selectedType;
  PaymentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      setState(() => _isLoading = true);
      
      final payments = await PaymentHistoryService.getPaymentHistory();
      final sortedPayments = PaymentHistoryService.sortByDateDescending(payments);
      
      setState(() {
        _payments = sortedPayments;
        _filteredPayments = sortedPayments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        PaymentErrorHandler.showErrorSnackBar(
          context,
          e,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadPaymentHistory,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Payment> filtered = List.from(_payments);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = PaymentHistoryService.searchPayments(filtered, _searchQuery);
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = PaymentHistoryService.filterByType(filtered, _selectedType!);
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = PaymentHistoryService.filterByStatus(filtered, _selectedStatus!);
    }

    setState(() {
      _filteredPayments = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type filter
            DropdownButtonFormField<PaymentType?>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Payment Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...PaymentType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(PaymentHistoryService.getPaymentTypeDisplayName(type)),
                )),
              ],
              onChanged: (value) => _selectedType = value,
            ),
            const SizedBox(height: 16),
            // Status filter
            DropdownButtonFormField<PaymentStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...PaymentStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(PaymentHistoryService.getPaymentStatusDisplayName(status)),
                )),
              ],
              onChanged: (value) => _selectedStatus = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search payments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),

          // Payment statistics
          if (!_isLoading && _payments.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildStatistics(),
            ),

          const SizedBox(height: 16),

          // Payment list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPaymentHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = _filteredPayments[index];
                            return _buildPaymentCard(payment);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = PaymentHistoryService.getPaymentStatistics(_payments);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Total Payments', '${stats['totalPayments']}'),
            _buildStatItem('Completed', '${stats['completedPayments']}'),
            _buildStatItem('Total Amount', PaymentHistoryService.formatAmount(stats['totalAmount'])),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedType != null || _selectedStatus != null
                ? 'No payments match your filters'
                : 'No payments yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedType != null || _selectedStatus != null
                ? 'Try adjusting your search or filters'
                : 'Your payment history will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final theme = Theme.of(context);
    final statusColor = Color(int.parse(
      PaymentHistoryService.getStatusColorHex(payment.status).substring(1),
      radix: 16,
    ) + 0xFF000000);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getPaymentIcon(payment.type),
            color: statusColor,
          ),
        ),
        title: Text(
          PaymentHistoryService.getPaymentTypeDisplayName(payment.type),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.description ?? 'No description'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    PaymentHistoryService.getPaymentStatusDisplayName(payment.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(payment.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          PaymentHistoryService.formatAmount(payment.amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        onTap: () => _showPaymentDetails(payment),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.songRequest:
        return Icons.music_note;
      case PaymentType.tip:
        return Icons.favorite;
      case PaymentType.subscription:
        return Icons.subscriptions;
      case PaymentType.other:
        return Icons.payment;
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

  void _showPaymentDetails(Payment payment) {
    // TODO: Navigate to payment details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment details for ${payment.id}'),
      ),
    );
  }
}
