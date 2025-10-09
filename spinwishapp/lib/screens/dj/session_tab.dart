import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/dj_api_service.dart';
import 'package:spinwishapp/models/session.dart' as session_model;
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/widgets/request_queue_widget.dart';
import 'package:spinwishapp/widgets/session_history_preview.dart';
import 'package:spinwishapp/widgets/session_sharing_widget.dart';
import 'package:spinwishapp/screens/dj/create_session_screen.dart';
import 'package:spinwishapp/screens/dj/location_settings_screen.dart';
import 'package:spinwishapp/screens/dj/live_session_screen.dart';

class SessionTab extends StatefulWidget {
  const SessionTab({super.key});

  @override
  State<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends State<SessionTab> {
  DJ? currentDJ;
  bool isLoadingDJ = true;
  String? djError;

  @override
  void initState() {
    super.initState();
    _loadCurrentDJ();
  }

  Future<void> _loadCurrentDJ() async {
    try {
      setState(() {
        isLoadingDJ = true;
        djError = null;
      });

      final dj = await DJApiService.getCurrentDJProfile();

      setState(() {
        currentDJ = dj;
        isLoadingDJ = false;
      });
    } catch (e) {
      setState(() {
        djError = 'Failed to load DJ profile: ${e.toString()}';
        isLoadingDJ = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SessionService>(
      builder: (context, sessionService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Session',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on),
                tooltip: 'Location Settings',
              ),
              if (sessionService.isSessionActive)
                IconButton(
                  onPressed: () => sessionService.endSession(),
                  icon: const Icon(Icons.stop),
                  tooltip: 'End Session',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!sessionService.isSessionActive) ...[
                  _buildStartSessionSection(theme, sessionService),
                ] else ...[
                  _buildActiveSessionSection(theme, sessionService),
                  const SizedBox(height: 24),
                  _buildRequestQueue(theme),
                ],
                const SizedBox(height: 24),
                _buildSessionHistory(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartSessionSection(
    ThemeData theme,
    SessionService sessionService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start New Session',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Session Type Selection
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Session Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Club Session Option
              _buildSessionTypeCard(
                theme,
                'Club Session',
                'Perform at a physical venue',
                Icons.location_on,
                () => _navigateToCreateSession(context),
              ),
              const SizedBox(height: 12),

              // Online Session Option
              _buildSessionTypeCard(
                theme,
                'Online Session',
                'Stream from anywhere',
                Icons.wifi,
                () => _startOnlineSession(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Connect Feature
        _buildConnectFeature(theme, sessionService),
      ],
    );
  }

  Widget _buildSessionTypeCard(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectFeature(ThemeData theme, SessionService sessionService) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_find, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Connect Feature',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Enable the Connect feature to allow listeners to discover your session and send requests.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Connect Status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: sessionService.isConnectEnabled,
                onChanged: (value) {
                  sessionService.toggleConnect(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
          if (sessionService.isConnectEnabled) ...[
            const SizedBox(height: 16),
            _buildSessionLinkSection(theme, sessionService),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionLinkSection(
    ThemeData theme,
    SessionService sessionService,
  ) {
    // Generate a shareable session link
    final sessionLink =
        'https://spinwish.com/session/${sessionService.currentSession?.id ?? 'demo'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Session Link',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sessionLink,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copySessionLink(sessionLink),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareSessionLink(sessionLink),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copySessionLink(sessionLink),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionSection(
    ThemeData theme,
    SessionService sessionService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Status Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${DateTime.now().difference(DateTime.now().subtract(const Duration(hours: 1))).inMinutes} min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSessionStat(
                      theme,
                      'Listeners',
                      '${sessionService.listenerCount}',
                      Icons.people,
                    ),
                  ),
                  Expanded(
                    child: _buildSessionStat(
                      theme,
                      'Requests',
                      '${sessionService.pendingRequestsCount}',
                      Icons.queue_music,
                    ),
                  ),
                  Expanded(
                    child: _buildSessionStat(
                      theme,
                      'Earnings',
                      'KSH ${sessionService.sessionEarnings.toStringAsFixed(2)}',
                      Icons.monetization_on,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Session Sharing
        if (sessionService.currentSession != null)
          SessionSharingWidget(session: sessionService.currentSession!),
      ],
    );
  }

  Widget _buildSessionStat(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestQueue(ThemeData theme) {
    return const SizedBox(
      height: 400, // Fixed height for the request queue
      child: RequestQueueWidget(),
    );
  }

  Widget _buildSessionHistory(ThemeData theme) {
    return const SessionHistoryPreview();
  }

  void _navigateToCreateSession(BuildContext context) {
    if (currentDJ == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DJ profile not loaded')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSessionScreen()),
    );
  }

  void _copySessionLink(String sessionLink) {
    Clipboard.setData(ClipboardData(text: sessionLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareSessionLink(String sessionLink) {
    // In a real app, you would use share_plus package or similar
    // For now, we'll just copy to clipboard and show a message
    Clipboard.setData(ClipboardData(text: sessionLink));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this link with your listeners:'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sessionLink,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Link has been copied to clipboard!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startOnlineSession(BuildContext context) async {
    if (currentDJ == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DJ profile not loaded')),
      );
      return;
    }

    final sessionService = Provider.of<SessionService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final session = await sessionService.startSession(
        djId: currentDJ!.id,
        type: session_model.SessionType.online,
        title: '${currentDJ!.name} - Online Session',
        description: 'Live streaming session by ${currentDJ!.name}',
        genres:
            currentDJ!.genres.isNotEmpty ? currentDJ!.genres : ['Electronic'],
      );

      // Navigate to LiveSessionScreen after successful session creation
      if (mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => LiveSessionScreen(session: session),
          ),
        );

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Online session started successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to start session: $e')),
        );
      }
    }
  }
}
