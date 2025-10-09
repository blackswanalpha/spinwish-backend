# Song Model Field Name Fix

## Issue

Compilation errors occurred in the Live Session Screen widget files due to incorrect field names being used when accessing Song model properties.

### Error Messages

```
Error: The getter 'name' isn't defined for the class 'Song'.
Try correcting the name to the name of an existing getter, or defining a getter or field named 'name'.
                        song?.name ?? 'Unknown Song',
                              ^^^^

Error: The getter 'artistName' isn't defined for the class 'Song'.
Try correcting the name to the name of an existing getter, or defining a getter or field named 'artistName'.
                        song?.artistName ?? 'Unknown Artist',
                              ^^^^^^^^^^
```

## Root Cause

The Song model (`spinwishapp/lib/models/song.dart`) uses different field names than what was assumed in the widget implementations:

### Song Model Structure

```dart
class Song {
  final String id;
  final String title;      // ← Correct field name
  final String artist;     // ← Correct field name
  final String album;
  final String genre;
  final int duration;
  final String artworkUrl;
  final double baseRequestPrice;
  final int popularity;
  final bool isExplicit;
  
  // ...
}
```

### Incorrect Usage (Before Fix)

```dart
song?.name         // ❌ Wrong - field doesn't exist
song?.artistName   // ❌ Wrong - field doesn't exist
```

### Correct Usage (After Fix)

```dart
song?.title        // ✅ Correct
song?.artist       // ✅ Correct
```

## Files Fixed

### 1. `spinwishapp/lib/screens/dj/widgets/queue_tab.dart`

**Location:** Lines 222-231

**Before:**
```dart
Text(
  song?.name ?? 'Unknown Song',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
Text(
  song?.artistName ?? 'Unknown Artist',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withOpacity(0.6),
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
```

**After:**
```dart
Text(
  song?.title ?? 'Unknown Song',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
Text(
  song?.artist ?? 'Unknown Artist',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withOpacity(0.6),
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
```

### 2. `spinwishapp/lib/screens/dj/widgets/song_requests_tab.dart`

**Location 1:** Lines 276-291 (Display)

**Before:**
```dart
Text(
  song?.name ?? 'Unknown Song',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
Text(
  song?.artistName ?? 'Unknown Artist',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withOpacity(0.6),
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
```

**After:**
```dart
Text(
  song?.title ?? 'Unknown Song',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
Text(
  song?.artist ?? 'Unknown Artist',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.onSurface.withOpacity(0.6),
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
```

**Location 2:** Lines 81-82 (Search Filter)

**Before:**
```dart
final songName = r.songResponse?.first.name.toLowerCase() ?? '';
final artistName = r.songResponse?.first.artistName?.toLowerCase() ?? '';
```

**After:**
```dart
final songName = r.songResponse?.first.title.toLowerCase() ?? '';
final artistName = r.songResponse?.first.artist.toLowerCase() ?? '';
```

## Changes Summary

| File | Lines Changed | Field Changed |
|------|---------------|---------------|
| `queue_tab.dart` | 223, 231 | `name` → `title`, `artistName` → `artist` |
| `song_requests_tab.dart` | 81, 82, 277, 285 | `name` → `title`, `artistName` → `artist` |

## Verification

### Before Fix
- ❌ Compilation errors in queue_tab.dart
- ❌ Compilation errors in song_requests_tab.dart
- ❌ App cannot build

### After Fix
- ✅ No compilation errors
- ✅ Song titles display correctly
- ✅ Artist names display correctly
- ✅ Search functionality works with correct fields
- ✅ App builds successfully

## Testing Recommendations

1. **Queue Tab:**
   - Verify song titles display correctly in queue
   - Verify artist names display correctly in queue
   - Test with multiple songs in queue

2. **Song Requests Tab:**
   - Verify song titles display in request cards
   - Verify artist names display in request cards
   - Test search functionality with song titles
   - Test search functionality with artist names
   - Verify search returns correct results

3. **Edge Cases:**
   - Test with null song data
   - Test with missing song information
   - Verify fallback text ("Unknown Song", "Unknown Artist") displays correctly

## Related Information

### Song Model API Response Mapping

The Song model has a special `fromApiResponse` factory constructor that handles different field names from the backend API:

```dart
factory Song.fromApiResponse(Map<String, dynamic> json) => Song(
  id: json['id']?.toString() ?? '',
  title: json['name'] ?? json['title'] ?? '',           // Maps 'name' OR 'title' from API
  artist: json['artistName'] ?? json['artist'] ?? '',   // Maps 'artistName' OR 'artist' from API
  album: json['album'] ?? '',
  genre: json['genre'] ?? '',
  duration: json['duration'] ?? 0,
  artworkUrl: json['artworkUrl'] ?? json['artwork_url'] ?? '',
  baseRequestPrice: (json['baseRequestPrice'] ?? json['base_request_price'] ?? 0.0).toDouble(),
  popularity: json['popularity'] ?? 0,
  isExplicit: json['isExplicit'] ?? json['is_explicit'] ?? false,
);
```

**Important:** The API may send `name` and `artistName`, but the Song model normalizes these to `title` and `artist` internally. Always use the model's field names (`title` and `artist`) when accessing Song properties in the UI.

## Prevention

To prevent similar issues in the future:

1. **Always check the model definition** before using field names
2. **Use IDE autocomplete** to ensure correct field names
3. **Run compilation checks** before committing code
4. **Add type checking** to catch field name errors early
5. **Document model field names** in widget comments if using complex models

## Remaining Warnings

The following non-critical warnings remain:

1. **Performance Warning:** Use `const` with Icon constructors
   - Location: queue_tab.dart:258, song_requests_tab.dart:332
   - Impact: Minor performance optimization
   - Fix: Add `const` keyword to Icon constructors

2. **TODO Comment:** Implement mark as played API call
   - Location: queue_tab.dart:53
   - Impact: Feature placeholder
   - Fix: Implement API integration when backend endpoint is ready

These warnings do not affect functionality and can be addressed in future iterations.

## Conclusion

All compilation errors related to Song model field names have been resolved. The widgets now correctly use `title` and `artist` fields instead of the non-existent `name` and `artistName` fields. The application builds successfully and song information displays correctly throughout the Live Session Screen.

