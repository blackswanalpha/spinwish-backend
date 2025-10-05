import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spinwishapp/services/profile_service.dart';

class AboutSpinWishScreen extends StatefulWidget {
  const AboutSpinWishScreen({super.key});

  @override
  State<AboutSpinWishScreen> createState() => _AboutSpinWishScreenState();
}

class _AboutSpinWishScreenState extends State<AboutSpinWishScreen> {
  String _appVersion = '';
  String _buildNumber = '';
  Map<String, dynamic> _appInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appInfo = await ProfileService.getAppInfo();
      
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
          _appInfo = appInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
          _buildNumber = '1';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4))
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLegalSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          'Terms of Service',
          'Read our terms and conditions',
          Icons.description,
          onTap: () => _launchUrl('https://spinwish.com/terms'),
        ),
        
        _buildInfoCard(
          'Privacy Policy',
          'Learn how we protect your data',
          Icons.privacy_tip,
          onTap: () => _launchUrl('https://spinwish.com/privacy'),
        ),
        
        _buildInfoCard(
          'Open Source Licenses',
          'Third-party software licenses',
          Icons.code,
          onTap: () => _showLicenses(),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect With Us',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          'Website',
          'Visit our official website',
          Icons.language,
          onTap: () => _launchUrl('https://spinwish.com'),
        ),
        
        _buildInfoCard(
          'Twitter',
          'Follow us @SpinWishApp',
          Icons.alternate_email,
          onTap: () => _launchUrl('https://twitter.com/SpinWishApp'),
        ),
        
        _buildInfoCard(
          'Instagram',
          'Follow us @spinwishapp',
          Icons.camera_alt,
          onTap: () => _launchUrl('https://instagram.com/spinwishapp'),
        ),
        
        _buildInfoCard(
          'Discord',
          'Join our community',
          Icons.chat,
          onTap: () => _launchUrl('https://discord.gg/spinwish'),
        ),
      ],
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'SpinWish',
      applicationVersion: _appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About SpinWish',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo and Info
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.music_note, color: Colors.white, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SpinWish',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Connect. Request. Enjoy.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version $_appVersion ($_buildNumber)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // App Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SpinWish is the ultimate platform for music lovers and DJs to connect. '
                      'Request your favorite songs, discover new music, tip talented DJs, and '
                      'be part of an amazing musical community.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // App Info
                  Text(
                    'App Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    'Version',
                    '$_appVersion ($_buildNumber)',
                    Icons.info,
                  ),
                  
                  _buildInfoCard(
                    'Release Date',
                    _appInfo['releaseDate'] ?? 'December 2024',
                    Icons.calendar_today,
                  ),
                  
                  _buildInfoCard(
                    'Developer',
                    'SpinWish Team',
                    Icons.code,
                  ),
                  
                  _buildInfoCard(
                    'Platform',
                    'iOS & Android',
                    Icons.phone_android,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Legal Section
                  _buildLegalSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Social Section
                  _buildSocialSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Copyright
                  Center(
                    child: Text(
                      '© 2024 SpinWish. All rights reserved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
