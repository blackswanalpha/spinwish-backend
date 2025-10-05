import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spinwishapp/services/session_service.dart';
import 'package:spinwishapp/services/session_image_service.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/utils/error_handler.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  final _clubNameController = TextEditingController();
  final _sessionTitleController = TextEditingController();
  final _sessionDescriptionController = TextEditingController();
  final _clubAddressController = TextEditingController();

  SessionType _selectedSessionType = SessionType.club;
  final List<String> _selectedGenres = [];
  double _minTipAmount = 5.0;
  bool _isLoading = false;

  // Image picker
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableGenres = [
    'House',
    'Techno',
    'Electronic',
    'Hip Hop',
    'R&B',
    'Pop',
    'Rock',
    'Jazz',
    'Reggae',
    'Latin',
    'Afrobeats',
    'Dancehall',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Session',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionTypeSelector(theme),
              const SizedBox(height: 24),
              _buildBasicInfoSection(theme),
              const SizedBox(height: 24),
              _buildImagePicker(theme),
              const SizedBox(height: 24),
              if (_selectedSessionType == SessionType.club) ...[
                _buildClubInfoSection(theme),
                const SizedBox(height: 24),
              ],
              _buildGenresSection(theme),
              const SizedBox(height: 24),
              _buildSettingsSection(theme),
              const SizedBox(height: 32),
              _buildCreateButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Type',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSessionTypeCard(
                theme,
                SessionType.club,
                'Club Session',
                'Perform at a physical venue',
                Icons.location_on,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSessionTypeCard(
                theme,
                SessionType.online,
                'Online Session',
                'Stream from anywhere',
                Icons.wifi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionTypeCard(
    ThemeData theme,
    SessionType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedSessionType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSessionType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sessionNameController,
          decoration: const InputDecoration(
            labelText: 'Session Name *',
            hintText: 'Enter a unique name for your session',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Session name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sessionTitleController,
          decoration: const InputDecoration(
            labelText: 'Session Title *',
            hintText: 'What will you be playing?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Session title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sessionDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe your session...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Image (Optional)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add an eye-catching image to make your session stand out',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to add session image',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPEG, PNG, GIF, or WebP (Max 10MB)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);

        // Validate image file
        try {
          SessionImageService.validateImageFile(imageFile);
          setState(() {
            _selectedImage = imageFile;
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid image: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildClubInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Club Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _clubNameController,
          decoration: const InputDecoration(
            labelText: 'Club Name *',
            hintText: 'Enter the club name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_selectedSessionType == SessionType.club &&
                (value == null || value.trim().isEmpty)) {
              return 'Club name is required for club sessions';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _clubAddressController,
          decoration: const InputDecoration(
            labelText: 'Club Address *',
            hintText: 'Enter the club address',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) {
            if (_selectedSessionType == SessionType.club &&
                (value == null || value.trim().isEmpty)) {
              return 'Club address is required for club sessions';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenresSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Music Genres',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select the genres you\'ll be playing (at least one required)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
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
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(
                0.2,
              ),
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
        if (_selectedGenres.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one genre',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Minimum Tip Amount',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '\$${_minTipAmount.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _minTipAmount,
          min: 1.0,
          max: 20.0,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              _minTipAmount = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one genre')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );

      // Create the session
      final session = await sessionService.startSession(
        djId: 'current_dj_id', // TODO: Get from AuthService
        type: _selectedSessionType,
        title: _sessionTitleController.text.trim(),
        description: _sessionDescriptionController.text.trim(),
        genres: _selectedGenres,
        clubName: _selectedSessionType == SessionType.club
            ? _clubNameController.text.trim()
            : null,
        clubAddress: _selectedSessionType == SessionType.club
            ? _clubAddressController.text.trim()
            : null,
        minTipAmount: _minTipAmount,
      );

      // Upload image if selected
      if (_selectedImage != null) {
        try {
          await SessionImageService.uploadSessionImage(
            session.id,
            _selectedImage!,
          );
        } catch (imageError) {
          // Log image upload error but don't fail the session creation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Session created but image upload failed: ${imageError.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedImage != null
                  ? 'Session created with image successfully!'
                  : 'Session created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e is Exception ? e : Exception(e.toString()),
          userMessage: 'Failed to create session. Please try again.',
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
    _sessionNameController.dispose();
    _clubNameController.dispose();
    _sessionTitleController.dispose();
    _sessionDescriptionController.dispose();
    _clubAddressController.dispose();
    super.dispose();
  }
}
