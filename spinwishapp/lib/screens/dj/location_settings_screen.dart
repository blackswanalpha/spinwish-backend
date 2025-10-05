import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/location_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location & Discovery',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<LocationService>(
        builder: (context, locationService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Status Card
                _buildLocationStatusCard(theme, locationService),

                const SizedBox(height: 24),

                // Discovery Settings
                _buildDiscoverySettings(theme, locationService),

                const SizedBox(height: 24),

                // Privacy Settings
                _buildPrivacySettings(theme, locationService),

                const SizedBox(height: 24),

                // Location Suitability
                _buildLocationSuitability(theme),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(theme, locationService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationStatusCard(
      ThemeData theme, LocationService locationService) {
    final hasPermission = locationService.hasLocationPermission;
    final isEnabled = locationService.isLocationEnabled;
    final currentLocation = locationService.currentLocation;

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    if (hasPermission && isEnabled && currentLocation != null) {
      statusColor = Colors.green;
      statusIcon = Icons.location_on;
      statusText = 'Location Active';
      statusDescription = 'Your location is being tracked for discovery';
    } else if (hasPermission && isEnabled) {
      statusColor = Colors.orange;
      statusIcon = Icons.location_searching;
      statusText = 'Getting Location';
      statusDescription = 'Searching for your current location...';
    } else if (hasPermission && !isEnabled) {
      statusColor = Colors.red;
      statusIcon = Icons.location_off;
      statusText = 'Location Disabled';
      statusDescription = 'Please enable location services in settings';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.location_disabled;
      statusText = 'Permission Required';
      statusDescription = 'Location permission is needed for discovery';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      statusDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lat: ${currentLocation.latitude.toStringAsFixed(4)}, '
                    'Lng: ${currentLocation.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscoverySettings(
      ThemeData theme, LocationService locationService) {
    return Container(
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
            'Discovery Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Make me discoverable
          SwitchListTile(
            title: const Text('Make me discoverable'),
            subtitle:
                const Text('Allow other users to find you when you\'re live'),
            value: locationService.isDiscoverable,
            onChanged: (value) {
              locationService.updateDiscoverySettings(isDiscoverable: value);
            },
            contentPadding: EdgeInsets.zero,
          ),

          if (locationService.isDiscoverable) ...[
            const SizedBox(height: 16),

            // Discovery radius
            Text(
              'Discovery Radius: ${locationService.discoveryRadius.toStringAsFixed(1)} km',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: locationService.discoveryRadius,
              min: 0.5,
              max: 50.0,
              divisions: 99,
              label: '${locationService.discoveryRadius.toStringAsFixed(1)} km',
              onChanged: (value) {
                locationService.updateDiscoverySettings(discoveryRadius: value);
              },
            ),

            const SizedBox(height: 16),

            // Only show when live
            SwitchListTile(
              title: const Text('Only show when live'),
              subtitle: const Text('Hide from discovery when not performing'),
              value: locationService.onlyShowWhenLive,
              onChanged: (value) {
                locationService.updateDiscoverySettings(
                    onlyShowWhenLive: value);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(
      ThemeData theme, LocationService locationService) {
    return Container(
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
              Icon(
                Icons.privacy_tip,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Share exact location
          SwitchListTile(
            title: const Text('Share exact location'),
            subtitle: const Text('Show precise location vs approximate area'),
            value: locationService.shareExactLocation,
            onChanged: (value) {
              locationService.updateDiscoverySettings(
                  shareExactLocation: value);
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your location data is only shared when you\'re discoverable and live',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSuitability(ThemeData theme) {
    return Container(
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
              Icon(
                Icons.analytics,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Analysis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Placeholder for location suitability analysis
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Analyzing current location...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: () => _analyzeLocation(),
            icon: const Icon(Icons.refresh),
            label: const Text('Analyze Location'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, LocationService locationService) {
    return Column(
      children: [
        if (!locationService.hasLocationPermission) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _requestLocationPermission(locationService),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_on),
              label: Text(_isLoading ? 'Requesting...' : 'Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (locationService.hasLocationPermission &&
            !locationService.isLocationEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => locationService.openLocationSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('Open Location Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLocationHelp(context),
            icon: const Icon(Icons.help_outline),
            label: const Text('Location Help'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestLocationPermission(
      LocationService locationService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await locationService.requestLocationPermission();

      if (mounted) {
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission granted!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _analyzeLocation() {
    // This would trigger location suitability analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location analysis feature coming soon!'),
      ),
    );
  }

  void _showLocationHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location & Discovery Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Enable location to be discoverable by nearby listeners'),
              Text('• Set your discovery radius to control visibility range'),
              Text('• Choose whether to share exact or approximate location'),
              Text('• Only show when live to maintain privacy'),
              SizedBox(height: 16),
              Text(
                'Privacy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                  '• Your location is only shared when you choose to be discoverable'),
              Text('• You can control the precision of location sharing'),
              Text('• Location data is encrypted and secure'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
