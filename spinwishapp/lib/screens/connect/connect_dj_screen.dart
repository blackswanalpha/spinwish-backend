import 'package:flutter/material.dart';
import 'package:spinwishapp/screens/listener/connect_screen.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/club.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/dj_api_service.dart';

import 'package:spinwishapp/theme.dart';

class ConnectDJScreen extends StatefulWidget {
  const ConnectDJScreen({super.key});

  @override
  State<ConnectDJScreen> createState() => _ConnectDJScreenState();
}

class _ConnectDJScreenState extends State<ConnectDJScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _contentController;
  late Animation<double> _scanAnimation;
  late Animation<double> _contentAnimation;

  bool _isScanning = true;
  List<DJ> _nearbyDJs = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startScanning();
  }

  void _initializeAnimations() {
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    _scanController.repeat();
  }

  void _startScanning() async {
    // Simulate scanning for nearby DJs
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      try {
        // Load live DJs from API
        final liveDJs = await DJApiService.getLiveDJs();

        setState(() {
          _isScanning = false;
          _nearbyDJs = liveDJs;
        });
      } catch (e) {
        setState(() {
          _isScanning = false;
          _nearbyDJs = [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to find nearby DJs: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      _scanController.stop();
      _contentController.forward();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect to DJ',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: const ConnectScreen(),
      ),
    );
  }

  Widget _buildNearbyDJCard(
    ThemeData theme,
    DJ dj,
    Club? club,
    Session? session,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _connectToDJ(dj),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // DJ Avatar
                Hero(
                  tag: 'connect-dj-${dj.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dj.isLive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(
                                0.3,
                              ),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: dj.profileImage.isNotEmpty
                          ? Image.network(
                              dj.profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // DJ Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dj.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (dj.isLive) _buildLiveIndicator(theme),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (club != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                club.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: theme.colorScheme.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dj.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (session != null) ...[
                            Icon(
                              Icons.people,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${session.listeners} listening',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Connect Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryGradientStart,
                        theme.colorScheme.primaryGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Connect',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryGradientStart,
            theme.colorScheme.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No DJs found nearby',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try moving closer to a participating venue',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isScanning = true;
                _nearbyDJs.clear();
              });
              _scanController.repeat();
              _startScanning();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _connectToDJ(DJ dj) {
    // Show connection success and navigate to DJ detail or session
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.success,
            ),
            const SizedBox(width: 8),
            const Text('Connected!'),
          ],
        ),
        content: Text(
          'You\'re now connected to ${dj.name}. You can start requesting songs!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to main screen
              // Navigate to DJ detail or session screen
            },
            child: const Text('View DJ'),
          ),
        ],
      ),
    );
  }
}
