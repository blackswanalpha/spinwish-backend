import 'package:flutter/material.dart';
import 'package:spinwishapp/services/location_service.dart';

class NearbyDJCard extends StatelessWidget {
  final NearbyDJ nearbyDJ;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  const NearbyDJCard({
    super.key,
    required this.nearbyDJ,
    this.onTap,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with DJ info and distance
              Row(
                children: [
                  // DJ Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: nearbyDJ.isLive
                            ? Colors.green
                            : theme.colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        nearbyDJ.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 24,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // DJ Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nearbyDJ.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nearbyDJ.isLive ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              nearbyDJ.isLive ? 'Live' : 'Offline',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: nearbyDJ.isLive ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Distance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LocationService.formatDistance(nearbyDJ.distance),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Session Info (if live)
              if (nearbyDJ.isLive && nearbyDJ.currentSessionTitle != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              nearbyDJ.currentSessionTitle!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          // Listeners
                          Icon(
                            Icons.people,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${nearbyDJ.listenerCount}',
                            style: theme.textTheme.bodySmall,
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Club name (if available)
                          if (nearbyDJ.clubName != null) ...[
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                nearbyDJ.clubName!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Genres
              if (nearbyDJ.genres.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: nearbyDJ.genres.take(3).map((genre) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      genre,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Action Buttons
              Row(
                children: [
                  // Connect Button
                  if (nearbyDJ.isLive) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConnect,
                        icon: const Icon(Icons.headphones, size: 18),
                        label: const Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // View Profile Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.person, size: 18),
                      label: const Text('Profile'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Location indicator
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showLocationInfo(context),
                    icon: Icon(
                      nearbyDJ.shareExactLocation 
                          ? Icons.location_on 
                          : Icons.location_city,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: nearbyDJ.shareExactLocation 
                        ? 'Exact location shared' 
                        : 'Approximate location',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Location Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distance: ${LocationService.formatDistance(nearbyDJ.distance)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              nearbyDJ.shareExactLocation
                  ? 'This DJ is sharing their exact location'
                  : 'This DJ is sharing their approximate location',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (nearbyDJ.clubName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Venue: ${nearbyDJ.clubName}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
