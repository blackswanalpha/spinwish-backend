import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/icon_manager.dart';
import 'package:spinwishapp/utils/design_system.dart';

/// Example showing how to integrate SpinWishIcons into existing screens
/// 
/// This demonstrates:
/// 1. Replacing hardcoded Material Icons with SpinWishIcons
/// 2. Using the icon system in different UI components
/// 3. Best practices for icon usage
class IconIntegrationExample extends StatefulWidget {
  const IconIntegrationExample({super.key});

  @override
  State<IconIntegrationExample> createState() => _IconIntegrationExampleState();
}

class _IconIntegrationExampleState extends State<IconIntegrationExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Icon Integration Example',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // BEFORE: IconButton(icon: Icon(Icons.search), ...)
          // AFTER: Using SpinWishIcons
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: Icon(SpinWishIcons.search),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: Icon(SpinWishIcons.filter),
            tooltip: 'Filter',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(SpinWishIcons.settings),
                  title: const Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(SpinWishIcons.logout),
                  title: const Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Profile Card with Icons
            _buildProfileCard(theme),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Example 2: Action Cards
            _buildActionCards(theme),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Example 3: Media Player Controls
            _buildMediaControls(theme),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Example 4: Settings List
            _buildSettingsList(theme),
            
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            
            // Example 5: Social Actions
            _buildSocialActions(theme),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(SpinWishIcons.add),
        tooltip: 'Add New',
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              SpinWishIcons.profile,
              size: 30,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: SpinWishDesignSystem.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'DJ & Music Producer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(SpinWishIcons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(ThemeData theme) {
    final actions = [
      _ActionItem('Sessions', SpinWishIcons.sessions, Colors.blue),
      _ActionItem('Music Library', SpinWishIcons.music, Colors.green),
      _ActionItem('Requests', SpinWishIcons.requests, Colors.orange),
      _ActionItem('Analytics', SpinWishIcons.trending, Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpinWishDesignSystem.spaceMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: SpinWishDesignSystem.spaceSM,
            mainAxisSpacing: SpinWishDesignSystem.spaceSM,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(theme, action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(ThemeData theme, _ActionItem action) {
    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            action.icon,
            size: 32,
            color: action.color,
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Text(
            action.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Now Playing',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(SpinWishIcons.skipPrevious),
                iconSize: 32,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(SpinWishIcons.play),
                iconSize: 48,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(SpinWishIcons.skipNext),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceMD),
          Row(
            children: [
              Icon(SpinWishIcons.volume, size: 20),
              Expanded(
                child: Slider(
                  value: 0.7,
                  onChanged: (value) {},
                ),
              ),
              Icon(SpinWishIcons.favorite, size: 20),
              const SizedBox(width: SpinWishDesignSystem.spaceSM),
              Icon(SpinWishIcons.share, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(ThemeData theme) {
    final settings = [
      _SettingItem('Notifications', SpinWishIcons.notifications),
      _SettingItem('Privacy', SpinWishIcons.settings),
      _SettingItem('Location', SpinWishIcons.location),
      _SettingItem('Download Settings', SpinWishIcons.download),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpinWishDesignSystem.spaceMD),
        ...settings.map((setting) => ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              setting.icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(setting.title),
          trailing: Icon(SpinWishIcons.chevronRight),
          onTap: () {},
        )),
      ],
    );
  }

  Widget _buildSocialActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSocialButton(theme, SpinWishIcons.favorite, 'Like', Colors.red),
          _buildSocialButton(theme, SpinWishIcons.comment, 'Comment', Colors.blue),
          _buildSocialButton(theme, SpinWishIcons.share, 'Share', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSocialButton(ThemeData theme, IconData icon, String label, Color color) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(SpinWishIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(SpinWishIcons.sessions),
          label: 'Sessions',
        ),
        BottomNavigationBarItem(
          icon: Icon(SpinWishIcons.music),
          label: 'Music',
        ),
        BottomNavigationBarItem(
          icon: Icon(SpinWishIcons.profile),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    // Implementation for search
  }

  void _showFilterDialog(BuildContext context) {
    // Implementation for filter
  }

  void _showAddDialog(BuildContext context) {
    // Implementation for add
  }

  void _handleMenuAction(String action) {
    // Handle menu actions
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;

  _ActionItem(this.title, this.icon, this.color);
}

class _SettingItem {
  final String title;
  final IconData icon;

  _SettingItem(this.title, this.icon);
}
