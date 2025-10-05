import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:spinwishapp/screens/favorites/favorite_djs_screen.dart';
import 'package:spinwishapp/screens/search/search_screen.dart';

class SessionsHeaderWidget extends StatefulWidget {
  const SessionsHeaderWidget({super.key});

  @override
  State<SessionsHeaderWidget> createState() => _SessionsHeaderWidgetState();
}

class _SessionsHeaderWidgetState extends State<SessionsHeaderWidget> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getFirstName() {
    if (_currentUser?.name.isNotEmpty == true) {
      return _currentUser!.name.split(' ').first;
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      child: Row(
        children: [
          // User Profile Photo
          _buildProfilePhoto(theme),

          const SizedBox(width: SpinWishDesignSystem.spaceMD),

          // Welcome Section
          Expanded(
            child: _buildWelcomeSection(theme),
          ),

          const SizedBox(width: SpinWishDesignSystem.spaceMD),

          // Action Buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: SpinWishDesignSystem.shadowMD(theme.colorScheme.primary),
      ),
      child: ClipOval(
        child: _currentUser?.profileImage.isNotEmpty == true
            ? Image.network(
                _currentUser!.profileImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(theme),
              )
            : _buildDefaultAvatar(theme),
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: theme.colorScheme.onPrimary,
        size: 30,
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Hi, ${_getFirstName()}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Search Button
        _buildModernActionButton(
          theme,
          icon: Icons.search_rounded,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          iconColor: theme.colorScheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
        ),

        const SizedBox(width: SpinWishDesignSystem.spaceSM),

        // Favorites Button
        _buildModernActionButton(
          theme,
          icon: Icons.favorite_rounded,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.withOpacity(0.1),
              Colors.red.withOpacity(0.1),
            ],
          ),
          iconColor: Colors.pink.shade400,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoriteDJsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
    ThemeData theme, {
    required IconData icon,
    required Gradient gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.surface,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: iconColor.withOpacity(0.2),
          highlightColor: iconColor.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 1.2,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
