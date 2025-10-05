import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/icon_manager.dart';
import 'package:spinwishapp/utils/design_system.dart';

/// Icon Showcase Screen
/// 
/// Demonstrates the SpinWish Icon Management System
/// Shows all available icons in both Material and HugeIcons variants
class IconShowcaseScreen extends StatefulWidget {
  const IconShowcaseScreen({super.key});

  @override
  State<IconShowcaseScreen> createState() => _IconShowcaseScreenState();
}

class _IconShowcaseScreenState extends State<IconShowcaseScreen> {
  IconSet _currentIconSet = SpinWishIcons.currentIconSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Icon Showcase',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Icon Set Switcher
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<IconSet>(
                value: _currentIconSet,
                onChanged: (IconSet? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentIconSet = newValue;
                      SpinWishIcons.setIconSet(newValue);
                    });
                  }
                },
                items: IconSet.values.map((IconSet iconSet) {
                  return DropdownMenuItem<IconSet>(
                    value: iconSet,
                    child: Text(
                      iconSet == IconSet.material ? 'Material' : 'HugeIcons',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor: theme.colorScheme.primaryContainer,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            _buildInfoCard(theme),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Navigation Icons
            _buildIconSection(
              theme,
              'Navigation Icons',
              [
                _IconItem('Home', SpinWishIcons.home),
                _IconItem('Sessions', SpinWishIcons.sessions),
                _IconItem('DJs', SpinWishIcons.djs),
                _IconItem('Music', SpinWishIcons.music),
                _IconItem('Requests', SpinWishIcons.requests),
                _IconItem('Profile', SpinWishIcons.profile),
              ],
            ),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Action Icons
            _buildIconSection(
              theme,
              'Action Icons',
              [
                _IconItem('Edit', SpinWishIcons.edit),
                _IconItem('Settings', SpinWishIcons.settings),
                _IconItem('Search', SpinWishIcons.search),
                _IconItem('Filter', SpinWishIcons.filter),
                _IconItem('Download', SpinWishIcons.download),
                _IconItem('Logout', SpinWishIcons.logout),
              ],
            ),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Media Controls
            _buildIconSection(
              theme,
              'Media Controls',
              [
                _IconItem('Play', SpinWishIcons.play),
                _IconItem('Pause', SpinWishIcons.pause),
                _IconItem('Stop', SpinWishIcons.stop),
                _IconItem('Next', SpinWishIcons.skipNext),
                _IconItem('Previous', SpinWishIcons.skipPrevious),
                _IconItem('Volume', SpinWishIcons.volume),
                _IconItem('Mute', SpinWishIcons.volumeMute),
              ],
            ),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Status & Category Icons
            _buildIconSection(
              theme,
              'Status & Category',
              [
                _IconItem('Trending', SpinWishIcons.trending),
                _IconItem('Diamond', SpinWishIcons.diamond),
                _IconItem('Colorize', SpinWishIcons.colorize),
                _IconItem('Rocket', SpinWishIcons.rocket),
                _IconItem('Sun', SpinWishIcons.sun),
                _IconItem('Snowflake', SpinWishIcons.snowflake),
                _IconItem('Eco', SpinWishIcons.eco),
                _IconItem('Sparkles', SpinWishIcons.sparkles),
              ],
            ),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Social & Interaction
            _buildIconSection(
              theme,
              'Social & Interaction',
              [
                _IconItem('Favorite', SpinWishIcons.favorite),
                _IconItem('Share', SpinWishIcons.share),
                _IconItem('Comment', SpinWishIcons.comment),
                _IconItem('Location', SpinWishIcons.location),
                _IconItem('Notifications', SpinWishIcons.notifications),
              ],
            ),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Utility Icons
            _buildIconSection(
              theme,
              'Utility Icons',
              [
                _IconItem('Add', SpinWishIcons.add),
                _IconItem('Remove', SpinWishIcons.remove),
                _IconItem('Close', SpinWishIcons.close),
                _IconItem('Check', SpinWishIcons.check),
                _IconItem('Chevron Right', SpinWishIcons.chevronRight),
                _IconItem('Arrow Forward', SpinWishIcons.arrowForward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                SpinWishIcons.sparkles,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: SpinWishDesignSystem.spaceSM),
              Text(
                'SpinWish Icon System',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Text(
            'Currently using: ${_currentIconSet == IconSet.material ? 'Material Icons' : 'HugeIcons'}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceXS),
          Text(
            'Switch between icon sets using the dropdown above. All icons automatically update throughout the app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSection(ThemeData theme, String title, List<_IconItem> icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpinWishDesignSystem.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: SpinWishDesignSystem.spaceSM,
            mainAxisSpacing: SpinWishDesignSystem.spaceSM,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final iconItem = icons[index];
            return _buildIconCard(theme, iconItem);
          },
        ),
      ],
    );
  }

  Widget _buildIconCard(ThemeData theme, _IconItem iconItem) {
    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceSM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconItem.iconData,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceXS),
          Text(
            iconItem.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _IconItem {
  final String name;
  final IconData iconData;

  _IconItem(this.name, this.iconData);
}
