# SpinWish Icon System Usage Guide

## Overview

The SpinWish Icon System provides a centralized, consistent way to manage icons across the entire application. It supports both Material Icons and HugeIcons, allowing for easy switching between icon sets while maintaining semantic meaning.

## Features

- **Dual Icon Set Support**: Switch between Material Icons and HugeIcons
- **Semantic Naming**: Icons are named by function, not appearance
- **Consistent API**: Same interface regardless of icon set
- **Easy Integration**: Drop-in replacement for existing icon usage
- **Type Safety**: Full Dart type checking and IDE support

## Installation

The system is already set up in the project with:
- `hugeicons: ^0.0.11` dependency added to pubspec.yaml
- Icon manager located at `lib/utils/icon_manager.dart`

## Basic Usage

### 1. Import the Icon Manager

```dart
import 'package:spinwishapp/utils/icon_manager.dart';
```

### 2. Use SpinWishIcons Instead of Icons

**Before:**
```dart
Icon(Icons.home)
Icon(Icons.settings)
IconButton(icon: Icon(Icons.search), onPressed: () {})
```

**After:**
```dart
Icon(SpinWishIcons.home)
Icon(SpinWishIcons.settings)
IconButton(icon: Icon(SpinWishIcons.search), onPressed: () {})
```

### 3. Switch Icon Sets

```dart
// Set to Material Icons
SpinWishIcons.setIconSet(IconSet.material);

// Set to HugeIcons
SpinWishIcons.setIconSet(IconSet.hugeicons);

// Check current icon set
IconSet current = SpinWishIcons.currentIconSet;
```

## Available Icon Categories

### Navigation Icons
- `SpinWishIcons.home` - Home/dashboard
- `SpinWishIcons.sessions` - Radio/sessions
- `SpinWishIcons.djs` - Headphones/DJs
- `SpinWishIcons.music` - Music library
- `SpinWishIcons.requests` - Music requests/playlist
- `SpinWishIcons.profile` - User profile

### Action Icons
- `SpinWishIcons.edit` - Edit/modify
- `SpinWishIcons.settings` - Settings/configuration
- `SpinWishIcons.search` - Search functionality
- `SpinWishIcons.filter` - Filter/sort
- `SpinWishIcons.download` - Download content
- `SpinWishIcons.logout` - Sign out

### Media Controls
- `SpinWishIcons.play` - Play media
- `SpinWishIcons.pause` - Pause media
- `SpinWishIcons.stop` - Stop media
- `SpinWishIcons.skipNext` - Next track
- `SpinWishIcons.skipPrevious` - Previous track
- `SpinWishIcons.volume` - Volume control
- `SpinWishIcons.volumeMute` - Mute audio

### Status & Category Icons
- `SpinWishIcons.trending` - Trending/popular
- `SpinWishIcons.diamond` - Premium/elegant
- `SpinWishIcons.colorize` - Colorful/vibrant
- `SpinWishIcons.rocket` - Fast/futuristic
- `SpinWishIcons.sun` - Warm themes
- `SpinWishIcons.snowflake` - Cool themes
- `SpinWishIcons.eco` - Natural/eco
- `SpinWishIcons.sparkles` - Magical/mystical

### Social & Interaction
- `SpinWishIcons.favorite` - Like/favorite
- `SpinWishIcons.share` - Share content
- `SpinWishIcons.comment` - Comments/feedback
- `SpinWishIcons.location` - Location/GPS
- `SpinWishIcons.notifications` - Alerts/notifications

### Utility Icons
- `SpinWishIcons.add` - Add/create new
- `SpinWishIcons.remove` - Remove/delete
- `SpinWishIcons.close` - Close/cancel
- `SpinWishIcons.check` - Confirm/success
- `SpinWishIcons.chevronRight` - Navigation arrow
- `SpinWishIcons.arrowForward` - Forward navigation

## Integration Examples

### Bottom Navigation Bar
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(SpinWishIcons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(SpinWishIcons.sessions),
      label: 'Sessions',
    ),
    // ... more items
  ],
)
```

### App Bar Actions
```dart
AppBar(
  actions: [
    IconButton(
      icon: Icon(SpinWishIcons.search),
      onPressed: () => showSearch(),
    ),
    IconButton(
      icon: Icon(SpinWishIcons.filter),
      onPressed: () => showFilters(),
    ),
  ],
)
```

### List Tiles
```dart
ListTile(
  leading: Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(SpinWishIcons.settings),
  ),
  title: Text('Settings'),
  trailing: Icon(SpinWishIcons.chevronRight),
)
```

### Media Player
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: Icon(SpinWishIcons.skipPrevious),
      onPressed: previousTrack,
    ),
    IconButton(
      icon: Icon(isPlaying ? SpinWishIcons.pause : SpinWishIcons.play),
      onPressed: togglePlayPause,
    ),
    IconButton(
      icon: Icon(SpinWishIcons.skipNext),
      onPressed: nextTrack,
    ),
  ],
)
```

## Best Practices

### 1. Use Semantic Names
Always use the semantic name rather than the visual appearance:
```dart
// Good
Icon(SpinWishIcons.sessions)  // Represents radio/sessions functionality

// Avoid
Icon(Icons.radio)  // Describes visual appearance
```

### 2. Consistent Icon Sizing
Use consistent sizing across similar UI elements:
```dart
// Navigation icons
Icon(SpinWishIcons.home, size: 24)

// Action buttons
Icon(SpinWishIcons.edit, size: 20)

// Large feature icons
Icon(SpinWishIcons.music, size: 48)
```

### 3. Icon Set Switching
Implement icon set switching in settings or developer options:
```dart
class IconSettingsWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<IconSet>(
      value: SpinWishIcons.currentIconSet,
      onChanged: (IconSet? newSet) {
        if (newSet != null) {
          SpinWishIcons.setIconSet(newSet);
          // Trigger UI rebuild
        }
      },
      items: IconSet.values.map((set) => 
        DropdownMenuItem(
          value: set,
          child: Text(set == IconSet.material ? 'Material' : 'HugeIcons'),
        ),
      ).toList(),
    );
  }
}
```

### 4. Theme Integration
Icons automatically respect theme colors, but you can customize:
```dart
Icon(
  SpinWishIcons.favorite,
  color: theme.colorScheme.primary,
  size: 24,
)
```

## Migration Guide

### Replacing Existing Icons

1. **Find and Replace**: Search for `Icons.` and replace with `SpinWishIcons.`
2. **Update Imports**: Add `import 'package:spinwishapp/utils/icon_manager.dart';`
3. **Check Mappings**: Ensure the semantic mapping is correct
4. **Test Both Sets**: Verify icons work with both Material and HugeIcons

### Example Migration
```dart
// Before
import 'package:flutter/material.dart';

IconButton(
  icon: Icon(Icons.settings),
  onPressed: openSettings,
)

// After
import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/icon_manager.dart';

IconButton(
  icon: Icon(SpinWishIcons.settings),
  onPressed: openSettings,
)
```

## Demo Screens

Two demo screens are available to explore the icon system:

1. **Icon Showcase** (`lib/screens/demo/icon_showcase_screen.dart`)
   - View all available icons
   - Switch between icon sets in real-time
   - Organized by category

2. **Integration Example** (`lib/screens/demo/icon_integration_example.dart`)
   - Practical usage examples
   - Common UI patterns
   - Best practices demonstration

## Extending the System

To add new icons:

1. Add the icon to `SpinWishIcons` class
2. Map both Material and HugeIcons variants
3. Use semantic naming
4. Update this documentation
5. Add to demo screens

```dart
static IconData get newIcon => _getIcon(
  material: Icons.material_icon,
  materialOutlined: Icons.material_icon_outlined,
  huge: HugeIcons.strokeRoundedHugeIcon,
);
```
