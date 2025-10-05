import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spinwishapp/screens/profile/send_feedback_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I request a song?',
      answer: 'To request a song, find an active DJ session, browse their available songs, select the song you want, and submit your request with payment. The DJ will see your request and can choose to play it.',
    ),
    FAQItem(
      question: 'How do I tip a DJ?',
      answer: 'You can tip a DJ by going to their profile or during a live session. Click the tip button, enter the amount you want to tip, and confirm the payment.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept credit cards, debit cards, PayPal, Apple Pay, and Google Pay. You can manage your payment methods in the Profile > Payment Methods section.',
    ),
    FAQItem(
      question: 'How do I become a DJ on SpinWish?',
      answer: 'To become a DJ, go to the DJ section in the app and complete the DJ registration process. You\'ll need to provide some basic information and verify your account.',
    ),
    FAQItem(
      question: 'Can I cancel a song request?',
      answer: 'You can cancel a song request before it\'s accepted by the DJ. Once accepted, cancellation depends on the DJ\'s policy. Refunds are processed according to our refund policy.',
    ),
    FAQItem(
      question: 'How do I follow my favorite DJs?',
      answer: 'Visit a DJ\'s profile and tap the follow button. You\'ll receive notifications when they go live and can easily find their sessions.',
    ),
    FAQItem(
      question: 'What if I have issues with payment?',
      answer: 'If you experience payment issues, check your payment method details first. If the problem persists, contact our support team with your transaction details.',
    ),
    FAQItem(
      question: 'How do I change my notification settings?',
      answer: 'Go to Profile > Notification Settings to customize which notifications you receive and how you receive them (push, email, or SMS).',
    ),
    FAQItem(
      question: 'Is my personal information secure?',
      answer: 'Yes, we take your privacy seriously. We use industry-standard encryption and security measures to protect your personal and payment information.',
    ),
    FAQItem(
      question: 'How do I delete my account?',
      answer: 'To delete your account, go to Profile > Settings > Account Settings and select "Delete Account". This action is permanent and cannot be undone.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._faqItems.map((item) => _buildFAQItem(item)),
            
            const SizedBox(height: 24),
            
            // Contact Section
            _buildContactSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Send Feedback',
                  Icons.feedback,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SendFeedbackScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Contact Us',
                  Icons.email,
                  () => _launchEmail(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Live Chat',
                  Icons.chat,
                  () => _showLiveChatInfo(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Call Support',
                  Icons.phone,
                  () => _launchPhone(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Still Need Help?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildContactItem(
            'Email Support',
            'support@spinwish.com',
            Icons.email,
            () => _launchEmail(),
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(
            'Phone Support',
            '+1 (555) 123-4567',
            Icons.phone,
            () => _launchPhone(),
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(
            'Support Hours',
            'Mon-Fri: 9AM-6PM EST',
            Icons.schedule,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@spinwish.com',
      query: 'subject=SpinWish Support Request',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone app')),
        );
      }
    }
  }

  void _showLiveChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat is available Monday through Friday, 9AM-6PM EST. '
          'For immediate assistance outside these hours, please send us an email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
