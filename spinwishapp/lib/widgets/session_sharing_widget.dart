import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/location_service.dart';
import 'package:spinwishapp/services/dj_discovery_service.dart';
import 'package:spinwishapp/models/session.dart';

class SessionSharingWidget extends StatefulWidget {
  final Session session;

  const SessionSharingWidget({
    super.key,
    required this.session,
  });

  @override
  State<SessionSharingWidget> createState() => _SessionSharingWidgetState();
}

class _SessionSharingWidgetState extends State<SessionSharingWidget> {
  bool _isSharing = false;
  double _invitationRadius = 5.0;
  String _customMessage = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
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
          // Header
          Row(
            children: [
              Icon(
                Icons.share_location,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Share Session',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Session info
          _buildSessionInfo(theme),

          const SizedBox(height: 20),

          // Sharing options
          _buildSharingOptions(theme),

          const SizedBox(height: 20),

          // Location invitation
          _buildLocationInvitation(theme),

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
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
          Text(
            widget.session.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.session.type == SessionType.club
                    ? Icons.location_on
                    : Icons.wifi,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                widget.session.type == SessionType.club
                    ? 'Club Session'
                    : 'Online Session',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
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

  Widget _buildSharingOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sharing Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Share link
        _buildShareOption(
          theme,
          'Share Link',
          'Copy session link to clipboard',
          Icons.link,
          () => _shareSessionLink(),
        ),

        const SizedBox(height: 8),

        // Share with location
        Consumer<LocationService>(
          builder: (context, locationService, child) {
            return _buildShareOption(
              theme,
              'Share with Location',
              locationService.currentLocation != null
                  ? 'Include your current location'
                  : 'Location not available',
              Icons.location_on,
              locationService.currentLocation != null
                  ? () => _shareWithLocation()
                  : null,
            );
          },
        ),

        const SizedBox(height: 8),

        // QR Code
        _buildShareOption(
          theme,
          'QR Code',
          'Generate QR code for easy joining',
          Icons.qr_code,
          () => _showQRCode(),
        ),
      ],
    );
  }

  Widget _buildShareOption(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
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
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : Icon(
              Icons.block,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildLocationInvitation(ThemeData theme) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        if (!locationService.isDiscoverable) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Nearby Listeners',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Send invitation to listeners within radius:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Radius slider
            Text(
              '${_invitationRadius.toStringAsFixed(1)} km',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Slider(
              value: _invitationRadius,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              onChanged: (value) {
                setState(() {
                  _invitationRadius = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Custom message
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a personal message (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 2,
              onChanged: (value) {
                _customMessage = value;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Consumer2<LocationService, DJDiscoveryService>(
      builder: (context, locationService, discoveryService, child) {
        return Column(
          children: [
            // Send invitation button
            if (locationService.isDiscoverable) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing
                      ? null
                      : () => _sendLocationInvitation(discoveryService),
                  icon: _isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSharing ? 'Sending...' : 'Send Invitation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Share session button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareSessionLink(),
                icon: const Icon(Icons.share),
                label: const Text('Share Session Link'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareSessionLink() {
    final discoveryService =
        Provider.of<DJDiscoveryService>(context, listen: false);
    final shareableLink =
        discoveryService.generateShareableSessionLink(widget.session);

    Clipboard.setData(ClipboardData(text: shareableLink));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session link copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareWithLocation() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final discoveryService =
        Provider.of<DJDiscoveryService>(context, listen: false);

    if (locationService.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final shareableLink =
        discoveryService.generateShareableSessionLink(widget.session);
    final location = locationService.currentLocation!;

    final shareText = '''
🎵 Join my live DJ session!

${widget.session.title}

📍 Location: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}
🔗 Link: $shareableLink

#SpinWish #LiveDJ #Music
''';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session details with location copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQRCode() {
    // This would show a QR code dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code feature coming soon!'),
      ),
    );
  }

  void _sendLocationInvitation(DJDiscoveryService discoveryService) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final success = await discoveryService.sendSessionInvitation(
        widget.session,
        radius: _invitationRadius,
        message: _customMessage.isNotEmpty ? _customMessage : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent to nearby listeners!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send invitation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}
