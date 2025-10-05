import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/club.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/models/tip.dart';
import 'package:spinwishapp/models/payment.dart';

import 'package:spinwishapp/screens/payment/payment_screen.dart';

class TipDJScreen extends StatefulWidget {
  final DJ dj;
  final Session session;

  const TipDJScreen({
    super.key,
    required this.dj,
    required this.session,
  });

  @override
  State<TipDJScreen> createState() => _TipDJScreenState();
}

class _TipDJScreenState extends State<TipDJScreen> {
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  double? selectedAmount;
  bool isAnonymous = false;
  bool isCustomAmount = false;

  final List<TipPreset> tipPresets = [
    const TipPreset(amount: 5.0, label: 'Coffee', emoji: '☕'),
    const TipPreset(amount: 10.0, label: 'Good Vibes', emoji: '🎵'),
    const TipPreset(amount: 20.0, label: 'Great Set', emoji: '🔥'),
    const TipPreset(amount: 50.0, label: 'Amazing!', emoji: '⭐'),
    const TipPreset(amount: 100.0, label: 'Legendary', emoji: '👑'),
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectPresetAmount(double amount) {
    setState(() {
      selectedAmount = amount;
      isCustomAmount = false;
      _customAmountController.clear();
    });
    HapticFeedback.lightImpact();
  }

  void _selectCustomAmount() {
    setState(() {
      isCustomAmount = true;
      selectedAmount = null;
    });
  }

  void _updateCustomAmount(String value) {
    final amount = double.tryParse(value);
    setState(() {
      selectedAmount = amount;
    });
  }

  void _proceedToPayment() {
    if (selectedAmount == null || selectedAmount! < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid tip amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          type: PaymentType.tip,
          amount: selectedAmount!,
          description: 'Tip for ${widget.dj.name}',
          metadata: {
            'djId': widget.dj.id,
            'sessionId': widget.session.id,
            'djName': widget.dj.name, // Add djName for M-Pesa payment
            'message': _messageController.text.trim(),
            'isAnonymous': isAnonymous,
          },
        ),
      ),
    ).then((result) {
      if (mounted && result == true) {
        // Payment successful, go back
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Create placeholder club data since we don't have API endpoints yet
    final club = widget.dj.clubId.isNotEmpty
        ? Club(
            id: widget.dj.clubId,
            name: 'Club Name',
            location: 'Location',
            address: 'Address',
            description: 'Description',
            imageUrl: '',
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip DJ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DJ Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.dj.profileImage,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.dj.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                club?.name ?? 'Unknown Club',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.dj.rating.toString(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.dj.followers}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Currently Live',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.session.listeners} listeners',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tip Amount Selection
            Text(
              'Choose Tip Amount',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Preset amounts
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tipPresets.length,
              itemBuilder: (context, index) {
                final preset = tipPresets[index];
                final isSelected =
                    selectedAmount == preset.amount && !isCustomAmount;

                return GestureDetector(
                  onTap: () => _selectPresetAmount(preset.amount),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          preset.emoji ?? '💰',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.formattedAmount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          preset.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary.withOpacity(0.8)
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Custom amount
            GestureDetector(
              onTap: _selectCustomAmount,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCustomAmount
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCustomAmount
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.2),
                    width: isCustomAmount ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: isCustomAmount
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isCustomAmount
                          ? TextField(
                              controller: _customAmountController,
                              onChanged: _updateCustomAmount,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Enter custom amount',
                                border: InputBorder.none,
                                prefixText: 'KSH ',
                              ),
                              autofocus: true,
                            )
                          : Text(
                              'Custom Amount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Text(
              'Add a Message (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Let the DJ know you appreciate their work...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 3,
              maxLength: 150,
            ),

            const SizedBox(height: 16),

            // Anonymous option
            Row(
              children: [
                Checkbox(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      isAnonymous = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Send tip anonymously',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedAmount != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tip Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'KSH ${selectedAmount!.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAmount != null && selectedAmount! >= 1.0
                      ? _proceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedAmount != null
                        ? 'Send Tip (\$${selectedAmount!.toStringAsFixed(2)})'
                        : 'Select Amount to Continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
