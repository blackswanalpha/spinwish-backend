import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spinwishapp/models/user.dart';
import 'package:spinwishapp/services/profile_service.dart';
import 'package:spinwishapp/services/auth_service.dart';
import 'package:spinwishapp/widgets/animated_button.dart';
import 'package:spinwishapp/widgets/animated_text_field.dart';
import 'package:spinwishapp/widgets/enhanced_image_viewer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  File? _selectedImage;
  String? _profileImageUrl;
  User? _currentUser;
  List<String> _selectedGenres = [];

  final List<String> _availableGenres = [
    'Pop',
    'Rock',
    'Hip Hop',
    'R&B',
    'Country',
    'Electronic',
    'Jazz',
    'Classical',
    'Reggae',
    'Blues',
    'Folk',
    'Punk',
    'Metal',
    'Alternative',
    'Indie',
    'Funk',
    'Soul',
    'Gospel',
    'Latin',
    'World',
    'Ambient',
    'House',
    'Techno',
    'Dubstep'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // Load current user from auth service
      final user = await AuthService.getCurrentUser();

      setState(() {
        _currentUser = user;
        _nameController.text = _currentUser?.name ?? '';
        _emailController.text = _currentUser?.email ?? '';
        _profileImageUrl = _currentUser?.profileImage;
        _selectedGenres = List.from(_currentUser?.favoriteGenres ?? []);
      });

      // Add listeners to detect changes
      _nameController.addListener(_onFieldChanged);
      _emailController.addListener(_onFieldChanged);
      _bioController.addListener(_onFieldChanged);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  bool _validateImageFile(File imageFile) {
    // Check file size (max 5MB)
    const int maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (imageFile.lengthSync() > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image size must be less than 5MB'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return false;
    }

    // Check file extension
    final String fileName = imageFile.path.toLowerCase();
    final List<String> allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp'
    ];

    bool hasValidExtension =
        allowedExtensions.any((ext) => fileName.endsWith(ext));
    if (!hasValidExtension) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please select a valid image file (JPG, PNG, GIF, or WebP)'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Profile Picture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    context,
                    'Camera',
                    Icons.camera_alt,
                    () async {
                      Navigator.pop(context);
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        final imageFile = File(image.path);
                        if (_validateImageFile(imageFile)) {
                          setState(() {
                            _selectedImage = imageFile;
                            _hasChanges = true;
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceButton(
                    context,
                    'Gallery',
                    Icons.photo_library,
                    () async {
                      Navigator.pop(context);
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        final imageFile = File(image.path);
                        if (_validateImageFile(imageFile)) {
                          setState(() {
                            _selectedImage = imageFile;
                            _hasChanges = true;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        try {
          imageUrl = await ProfileService.uploadProfileImage(_selectedImage!);
        } catch (uploadError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to upload image: ${uploadError.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Update profile
      final updatedUser = await ProfileService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: imageUrl,
        favoriteGenres: _selectedGenres,
      );

      // TODO: Update user profile via API when endpoint is available
      // For now, just update local state

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update profile';
        if (e.toString().contains('Failed to upload profile image')) {
          errorMessage = 'Failed to upload image. Please try again.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveProfile,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : EnhancedImageViewer(
                                    imageUrl:
                                        _profileImageUrl?.isNotEmpty == true
                                            ? _profileImageUrl
                                            : null,
                                    heroTag: 'edit_profile_image',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: Container(
                                      width: 120,
                                      height: 120,
                                      color: theme.colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change photo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              AnimatedTextField(
                controller: _nameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AnimatedTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Favorite Genres Section
              Text(
                'Favorite Genres',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableGenres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(genre);
                        } else {
                          _selectedGenres.remove(genre);
                        }
                        _hasChanges = true;
                      });
                    },
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  text: 'Save Changes',
                  onPressed: _hasChanges ? _saveProfile : null,
                  isLoading: _isLoading,
                  icon: Icons.save,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
