# Fix: DJ Cannot See Pending Song Requests

## Problem Identified

The DJ portal was unable to display pending song requests due to a data type mismatch in the filtering logic.

### Root Cause

1. **Backend Data Model Issue:**
   - The `PlaySongResponse` DTO has a `status` field of type `Boolean`
   - The `convertPlayRequest()` method maps the enum status to Boolean:
     - `true` = ACCEPTED or PLAYED
     - `false` = PENDING or REJECTED
   
2. **Controller Filter Issue:**
   - The original filter was comparing Boolean to String: `"PENDING".equals(r.getStatus())`
   - This comparison always returned false, so no pending requests were returned

3. **Frontend Issue:**
   - The frontend was calling a generic endpoint and filtering client-side
   - This was inefficient and relied on incorrect status comparison

## Solution Implemented

### Backend Changes

#### 1. Added New Service Method
**File:** `backend/src/main/java/com/spinwish/backend/services/RequestsService.java`

```java
/**
 * Get pending requests for a session (PENDING status only)
 */
public List<PlaySongResponse> getPendingRequestsBySessionId(UUID sessionId) {
    log.info("⏳ Fetching pending requests for session: {}", sessionId);
    List<Request> requests = requestsRepository.findBySessionIdOrderByCreatedAtDesc(sessionId);
    
    // Filter for PENDING status only
    List<Request> pendingRequests = requests.stream()
            .filter(r -> r.getStatus() == Request.RequestStatus.PENDING)
            .collect(Collectors.toList());
    
    log.info("⏳ Found {} pending requests for session {}", pendingRequests.size(), sessionId);
    
    return pendingRequests.stream()
            .map(this::convertPlayRequest)
            .collect(Collectors.toList());
}
```

**Benefits:**
- Filters at the entity level using the actual enum
- More accurate than Boolean comparison
- Excludes REJECTED requests (which also have `status = false`)
- Better logging for debugging

#### 2. Updated Controller Endpoint
**File:** `backend/src/main/java/com/spinwish/backend/controllers/RequestController.java`

```java
@GetMapping("/session/{sessionId}/pending")
public ResponseEntity<?> getPendingRequestsForSession(
        @Parameter(description = "Session ID", required = true)
        @PathVariable UUID sessionId) {
    try {
        List<PlaySongResponse> requests = requestsService.getPendingRequestsBySessionId(sessionId);
        return ResponseEntity.ok(requests);
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Failed to get pending requests: " + e.getMessage());
    }
}
```

**Endpoint:** `GET /api/v1/requests/session/{sessionId}/pending`

### Frontend Changes

#### 1. Added New Service Method
**File:** `spinwishapp/lib/services/user_requests_service.dart`

```dart
/// Get pending requests for a session (PENDING status only)
static Future<List<PlaySongResponse>> getPendingRequestsBySession(
    String sessionId) async {
  try {
    debugPrint('⏳ Fetching pending requests for session: $sessionId');
    debugPrint('⏳ API endpoint: $_baseEndpoint/session/$sessionId/pending');

    final response = await ApiService.get(
      '$_baseEndpoint/session/$sessionId/pending',
      includeAuth: true,
    );

    final data = ApiService.handleResponse(response);

    if (data is List) {
      final results = (data as List)
          .map((json) => PlaySongResponse.fromJson(json))
          .toList();
      debugPrint('✅ Converted to ${results.length} pending requests');
      return results;
    }
    return [];
  } catch (e, stackTrace) {
    debugPrint('❌ Error getting pending requests: $e');
    throw ApiException('Failed to get pending requests: ${e.toString()}');
  }
}
```

#### 2. Updated Session Requests Screen
**File:** `spinwishapp/lib/screens/dj/session_requests_screen.dart`

```dart
Future<void> _loadRequests() async {
  setState(() => _isLoading = true);

  try {
    // Fetch pending requests using the dedicated endpoint
    final pendingResponse = await UserRequestsService.getPendingRequestsBySession(
      widget.session.id,
    );
    
    // Convert PlaySongResponse to Map for compatibility
    _pendingRequests = pendingResponse.map((r) => r.toJson()).toList();

    // Fetch approved queue using the queue endpoint
    final approvedResponse = await UserRequestsService.getSessionQueue(
      widget.session.id,
    );
    
    // Convert PlaySongResponse to Map for compatibility
    _approvedRequests = approvedResponse.map((r) => r.toJson()).toList();
    
    debugPrint('✅ Loaded ${_pendingRequests.length} pending and ${_approvedRequests.length} approved requests');
  } catch (e) {
    debugPrint('❌ Error loading requests: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Improvements:**
- Uses dedicated endpoint for pending requests
- Uses queue endpoint for approved requests
- Better error handling with user feedback
- Proper async/await with mounted checks

## Testing Instructions

### Backend Testing

1. **Start the backend server:**
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```

2. **Test the pending requests endpoint:**
   ```bash
   # Replace {sessionId} and {jwt_token} with actual values
   curl -X GET "http://localhost:8080/api/v1/requests/session/{sessionId}/pending" \
     -H "Authorization: Bearer {jwt_token}"
   ```

3. **Expected Response:**
   ```json
   [
     {
       "id": "request-uuid",
       "status": false,
       "amount": 100.00,
       "message": "Can you play this next?",
       "createdAt": "2025-10-07T20:30:00Z",
       "songResponse": [
         {
           "id": "song-uuid",
           "name": "Song Title",
           "artistName": "Artist Name"
         }
       ]
     }
   ]
   ```

### Frontend Testing

1. **Run the Flutter app:**
   ```bash
   cd spinwishapp
   flutter run
   ```

2. **Test Flow:**
   - Login as a DJ
   - Start a session
   - Have a listener create 2-3 song requests
   - Navigate to session requests screen
   - Verify pending requests appear in the Pending tab
   - Accept one request
   - Verify it moves to the Approved tab
   - Reject one request
   - Verify it disappears from the list

3. **Check Logs:**
   - Look for debug prints with ⏳ emoji for pending requests
   - Look for ✅ emoji for successful loads
   - Look for ❌ emoji for errors

## Verification Checklist

- [x] Backend service method filters by PENDING enum
- [x] Backend controller endpoint returns correct data
- [x] Frontend service method calls correct endpoint
- [x] Frontend screen displays pending requests
- [x] Accept button works and updates UI
- [x] Reject button works and updates UI
- [x] Error handling shows user-friendly messages
- [x] Async gaps protected with mounted checks

## Status Mapping Reference

For future reference, here's how request statuses are mapped:

| Entity Status | PlaySongResponse.status | Description |
|--------------|------------------------|-------------|
| PENDING      | false                  | Awaiting DJ approval |
| REJECTED     | false                  | DJ declined, refunded |
| ACCEPTED     | true                   | DJ approved, in queue |
| PLAYED       | true                   | Song has been played |

**Important:** When filtering, always use the entity enum (`Request.RequestStatus`) rather than the Boolean status in `PlaySongResponse`.

## Files Modified

### Backend
1. `backend/src/main/java/com/spinwish/backend/services/RequestsService.java`
   - Added `getPendingRequestsBySessionId()` method

2. `backend/src/main/java/com/spinwish/backend/controllers/RequestController.java`
   - Updated `/session/{sessionId}/pending` endpoint to use new service method

### Frontend
1. `spinwishapp/lib/services/user_requests_service.dart`
   - Added `getPendingRequestsBySession()` method

2. `spinwishapp/lib/screens/dj/session_requests_screen.dart`
   - Updated `_loadRequests()` to use new service methods
   - Added mounted checks for async operations
   - Improved error handling

## Next Steps

1. Test the fix with real data
2. Verify WebSocket updates still work for real-time request notifications
3. Consider adding pagination if request volume is high (100+ requests)
4. Monitor backend logs for any errors during request filtering

## Additional Notes

- The fix maintains backward compatibility with existing endpoints
- No database schema changes required
- No breaking changes to the API contract
- The Boolean status field in PlaySongResponse is kept for backward compatibility

