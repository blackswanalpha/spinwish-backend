# Session Image Upload Implementation Guide

## Overview
This document provides a comprehensive guide for the image upload and viewing functionality implemented for DJ sessions in the SpinWish application.

## Architecture Summary

### Technology Stack
- **Frontend**: Flutter mobile application
- **Backend**: Java Spring Boot REST API
- **Database**: PostgreSQL (production) / H2 (development)
- **Authentication**: JWT-based with role-based access control
- **File Storage**: Local file system with organized directories

---

## Backend Implementation

### 1. Database Schema Changes

#### Session Entity Updates
Added two new fields to the `Session` entity:
- `imageUrl` (String): Stores the relative path to the session image
- `thumbnailUrl` (String): Stores the relative path to the thumbnail (currently same as imageUrl)

**File**: `backend/src/main/java/com/spinwish/backend/entities/Session.java`

```java
@Column(name = "image_url")
private String imageUrl;

@Column(name = "thumbnail_url")
private String thumbnailUrl;
```

### 2. Image Upload Service

#### SessionService Enhancements
**File**: `backend/src/main/java/com/spinwish/backend/services/SessionService.java`

**Key Features**:
- **Directory Management**: Automatically creates `uploads/session-images` directory on startup
- **Image Validation**: 
  - Maximum file size: 10MB
  - Supported formats: JPEG, PNG, GIF, WebP
  - Security checks to prevent directory traversal attacks
- **UUID-based Filenames**: Prevents filename conflicts and enhances security
- **Image Upload Method**: `uploadSessionImage(UUID sessionId, MultipartFile imageFile)`
- **Image Deletion Method**: `deleteSessionImage(UUID sessionId)`

**Validation Rules**:
```java
- File size: Max 10MB
- Content types: image/jpeg, image/jpg, image/png, image/gif, image/webp
- File extensions: .jpg, .jpeg, .png, .gif, .webp
- Path security: Prevents directory traversal attacks
```

### 3. REST API Endpoints

#### SessionController Endpoints
**File**: `backend/src/main/java/com/spinwish/backend/controllers/SessionController.java`

**Upload Session Image**:
```
POST /api/v1/sessions/{sessionId}/upload-image
Content-Type: multipart/form-data
Authorization: Bearer {JWT_TOKEN}

Parameters:
- image: MultipartFile (required)

Response: Updated Session object with imageUrl and thumbnailUrl
```

**Delete Session Image**:
```
DELETE /api/v1/sessions/{sessionId}/image
Authorization: Bearer {JWT_TOKEN}

Response: Updated Session object with null imageUrl and thumbnailUrl
```

### 4. File Serving

#### FileController Updates
**File**: `backend/src/main/java/com/spinwish/backend/controllers/FileController.java`

**Serve Session Images**:
```
GET /uploads/session-images/{filename}

Response: Image file with appropriate content type
```

### 5. Security Configuration

#### SecurityConfig Updates
**File**: `backend/src/main/java/com/spinwish/backend/security/SecurityConfig.java`

**Public Endpoints** (No authentication required):
- `GET /api/v1/sessions` - View all sessions
- `GET /api/v1/sessions/**` - View session details
- `GET /uploads/**` - View all uploaded images

**Protected Endpoints** (JWT authentication required):
- `POST /api/v1/sessions/{sessionId}/upload-image` - Upload session image (DJ only)
- `DELETE /api/v1/sessions/{sessionId}/image` - Delete session image (DJ only)

---

## Frontend Implementation

### 1. Model Updates

#### Session Model
**File**: `spinwishapp/lib/models/session.dart`

Added fields:
```dart
final String? imageUrl;
final String? thumbnailUrl;
```

Updated methods:
- `fromJson()` - Parses imageUrl and thumbnailUrl from API response
- `fromApiResponse()` - Handles backend API response format
- `copyWith()` - Includes imageUrl and thumbnailUrl parameters
- `toJson()` - Serializes imageUrl and thumbnailUrl

#### DJSession Model
**File**: `spinwishapp/lib/models/dj_session.dart`

Same updates as Session model for consistency.

### 2. Image Upload Service

#### SessionImageService
**File**: `spinwishapp/lib/services/session_image_service.dart`

**Key Methods**:

1. **uploadSessionImage(String sessionId, File imageFile)**
   - Uploads image using multipart/form-data
   - Returns updated Session object
   - Handles authentication automatically

2. **deleteSessionImage(String sessionId)**
   - Deletes session image
   - Returns updated Session object

3. **getSessionImageUrl(String? imageUrl)**
   - Converts relative URLs to absolute URLs
   - Handles both relative and absolute URLs

4. **validateImageFile(File imageFile)**
   - Validates file existence
   - Checks file size (max 10MB)
   - Validates file extension

**Usage Example**:
```dart
import 'package:spinwishapp/services/session_image_service.dart';
import 'dart:io';

// Upload image
try {
  File imageFile = File('/path/to/image.jpg');
  SessionImageService.validateImageFile(imageFile);
  Session updatedSession = await SessionImageService.uploadSessionImage(
    sessionId,
    imageFile,
  );
  print('Image uploaded: ${updatedSession.imageUrl}');
} catch (e) {
  print('Upload failed: $e');
}

// Delete image
try {
  Session updatedSession = await SessionImageService.deleteSessionImage(sessionId);
  print('Image deleted');
} catch (e) {
  print('Delete failed: $e');
}

// Get full image URL
String? fullUrl = await SessionImageService.getSessionImageUrl(session.imageUrl);
```

### 3. UI Integration Guide

#### Adding Image Upload to Create Session Screen

**Step 1**: Add required imports
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spinwishapp/services/session_image_service.dart';
```

**Step 2**: Add state variables
```dart
File? _selectedImage;
final ImagePicker _picker = ImagePicker();
```

**Step 3**: Add image picker method
```dart
Future<void> _pickImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  
  if (image != null) {
    final imageFile = File(image.path);
    try {
      SessionImageService.validateImageFile(imageFile);
      setState(() {
        _selectedImage = imageFile;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid image: $e')),
      );
    }
  }
}
```

**Step 4**: Add image preview widget
```dart
Widget _buildImagePicker(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Session Image (Optional)',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add session image',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}
```

**Step 5**: Upload image after session creation
```dart
Future<void> _createSession() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    // Create session first
    final session = await sessionService.startSession(
      title: _sessionTitleController.text,
      description: _sessionDescriptionController.text,
      // ... other parameters
    );
    
    // Upload image if selected
    if (_selectedImage != null) {
      await SessionImageService.uploadSessionImage(
        session.id,
        _selectedImage!,
      );
    }
    
    // Navigate back or show success
    Navigator.pop(context);
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Displaying Session Images

**Using EnhancedImageViewer** (if available):
```dart
EnhancedImageViewer(
  imageUrl: session.imageUrl,
  heroTag: 'session_${session.id}',
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
  placeholder: Container(
    color: Colors.grey[300],
    child: Icon(Icons.music_note, size: 48),
  ),
)
```

**Using NetworkImage**:
```dart
FutureBuilder<String?>(
  future: SessionImageService.getSessionImageUrl(session.imageUrl),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return Image.network(
        snapshot.data!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image),
          );
        },
      );
    }
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.music_note, size: 48),
    );
  },
)
```

---

## Testing Guide

### Backend Testing

#### 1. Test Image Upload (Using cURL)

```bash
# First, create a session and get the session ID
# Then upload an image:

curl -X POST \
  http://localhost:8080/api/v1/sessions/{SESSION_ID}/upload-image \
  -H "Authorization: Bearer {YOUR_JWT_TOKEN}" \
  -F "image=@/path/to/your/image.jpg"
```

#### 2. Test Image Retrieval

```bash
# Get session details to see imageUrl
curl -X GET \
  http://localhost:8080/api/v1/sessions/{SESSION_ID}

# Access the image directly
curl -X GET \
  http://localhost:8080/uploads/session-images/{FILENAME}
```

#### 3. Test Image Deletion

```bash
curl -X DELETE \
  http://localhost:8080/api/v1/sessions/{SESSION_ID}/image \
  -H "Authorization: Bearer {YOUR_JWT_TOKEN}"
```

### Frontend Testing

#### 1. Test Image Upload Flow
1. Log in as a DJ user
2. Navigate to Create Session screen
3. Fill in session details
4. Tap on image picker area
5. Select an image from gallery
6. Verify image preview appears
7. Create the session
8. Verify image is uploaded successfully

#### 2. Test Image Display
1. Navigate to sessions list
2. Verify session images are displayed
3. Tap on a session to view details
4. Verify full-size image is displayed

#### 3. Test Image Deletion
1. Navigate to session edit screen
2. Tap delete image button
3. Verify image is removed
4. Verify placeholder is shown

---

## Error Handling

### Backend Errors

| Error Code | Description | Solution |
|------------|-------------|----------|
| 400 | Invalid image file | Check file format and size |
| 401 | Unauthorized | Verify JWT token is valid |
| 404 | Session not found | Verify session ID exists |
| 413 | File too large | Reduce image size to under 10MB |
| 500 | Server error | Check server logs |

### Frontend Errors

| Error | Description | Solution |
|-------|-------------|----------|
| File not found | Image file doesn't exist | Verify file path |
| Invalid format | Unsupported image format | Use JPEG, PNG, GIF, or WebP |
| File too large | Image exceeds 10MB | Compress or resize image |
| Network error | Cannot reach server | Check network connection |

---

## Best Practices

### Image Optimization
1. **Resize images** before upload (recommended: 1920x1080 max)
2. **Compress images** to reduce file size (recommended: 85% quality)
3. **Use appropriate formats**: JPEG for photos, PNG for graphics

### Security
1. **Always validate** images on both client and server
2. **Use JWT authentication** for upload/delete operations
3. **Sanitize filenames** to prevent directory traversal
4. **Limit file sizes** to prevent DoS attacks

### Performance
1. **Cache images** on the client side
2. **Use thumbnails** for list views
3. **Lazy load** images in scrollable lists
4. **Implement progressive loading** for large images

---

## Future Enhancements

1. **Image Compression**: Automatically compress images on upload
2. **Thumbnail Generation**: Generate optimized thumbnails
3. **Cloud Storage**: Migrate to AWS S3 or similar service
4. **Image Cropping**: Allow users to crop images before upload
5. **Multiple Images**: Support multiple images per session
6. **Image Filters**: Apply filters and effects to images
7. **CDN Integration**: Use CDN for faster image delivery

---

## Troubleshooting

### Images Not Uploading
1. Check JWT token is valid and not expired
2. Verify user has DJ role
3. Check file size is under 10MB
4. Verify file format is supported
5. Check server logs for errors

### Images Not Displaying
1. Verify imageUrl is not null
2. Check network connectivity
3. Verify image file exists on server
4. Check file permissions on server
5. Verify base URL is correct

### Permission Denied
1. Verify user is authenticated
2. Check user has DJ role for uploads
3. Verify JWT token includes correct claims
4. Check session belongs to the DJ

---

## API Reference

### Upload Session Image
```
POST /api/v1/sessions/{sessionId}/upload-image
```

**Headers**:
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**Parameters**:
- `image`: File (required) - Image file to upload

**Response** (200 OK):
```json
{
  "id": "uuid",
  "title": "Session Title",
  "imageUrl": "/uploads/session-images/uuid.jpg",
  "thumbnailUrl": "/uploads/session-images/uuid.jpg",
  ...
}
```

### Delete Session Image
```
DELETE /api/v1/sessions/{sessionId}/image
```

**Headers**:
- `Authorization: Bearer {token}`

**Response** (200 OK):
```json
{
  "id": "uuid",
  "title": "Session Title",
  "imageUrl": null,
  "thumbnailUrl": null,
  ...
}
```

### Get Session Image
```
GET /uploads/session-images/{filename}
```

**Response** (200 OK):
- Content-Type: image/jpeg | image/png | image/gif | image/webp
- Body: Image binary data

---

## Conclusion

This implementation provides a complete solution for DJ session image management, including:
- ✅ Secure image upload with validation
- ✅ Image storage and retrieval
- ✅ Role-based access control
- ✅ Comprehensive error handling
- ✅ Easy-to-use Flutter service
- ✅ RESTful API design

The system is production-ready and follows industry best practices for security, performance, and maintainability.

