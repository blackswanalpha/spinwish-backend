# Testing Guide for New SpinWish Features

## Quick Testing Checklist

### 1. Session Creation Navigation ✅

**Test Case 1: Club Session Creation**
- [ ] Open SpinWish app as a DJ
- [ ] Navigate to Sessions tab
- [ ] Tap "Club Session" option
- [ ] Fill in all required fields (name, club name, address, genres)
- [ ] Set minimum tip amount
- [ ] Tap "Create Session"
- [ ] **Expected:** Automatically redirected to Live Session Screen
- [ ] **Expected:** See session analytics, tabs, and controls
- [ ] **Expected:** Green success notification appears

**Test Case 2: Online Session Creation**
- [ ] Open SpinWish app as a DJ
- [ ] Navigate to Sessions tab
- [ ] Tap "Online Session" option
- [ ] **Expected:** Session starts immediately
- [ ] **Expected:** Automatically redirected to Live Session Screen
- [ ] **Expected:** Green success notification: "Online session started successfully!"

---

### 2. Share Functionality ✅

**Test Case 3: Copy Session Link**
- [ ] Start a live session (club or online)
- [ ] Tap the share icon (top right of Live Session Screen)
- [ ] Tap "Copy Link"
- [ ] **Expected:** Modal closes
- [ ] **Expected:** Green notification: "Session link copied to clipboard!"
- [ ] Open notes app and paste
- [ ] **Expected:** Link format: `https://spinwish.app/session/{session-id}`

**Test Case 4: Share to Social Media**
- [ ] Start a live session
- [ ] Tap the share icon
- [ ] Tap "Share to Social Media"
- [ ] **Expected:** Native share dialog opens
- [ ] **Expected:** Share text includes:
  - 🎵 emoji and title
  - Session title and description
  - Session type (Club/Online)
  - Genres list
  - Session link
  - Hashtags (#SpinWish #LiveDJ #Music)
- [ ] Select an app (WhatsApp, Twitter, etc.)
- [ ] **Expected:** Text is properly formatted in selected app

**Test Case 5: QR Code Dialog**
- [ ] Start a live session
- [ ] Tap the share icon
- [ ] Tap "Show QR Code"
- [ ] **Expected:** Dialog appears with QR code placeholder
- [ ] **Expected:** Shows session ID
- [ ] Tap "Copy Link Instead"
- [ ] **Expected:** Link copied to clipboard
- [ ] **Expected:** Green notification appears

---

### 3. WebSocket Real-time Updates ✅

**Test Case 6: Real-time Song Request Notification**

**Setup:**
- Device A: DJ account with live session
- Device B: Listener account

**Steps:**
- [ ] Device A: Start a live session
- [ ] Device A: Navigate to Live Session Screen
- [ ] Device A: Stay on "Requests" tab
- [ ] Device B: Join the session
- [ ] Device B: Submit a song request with tip
- [ ] **Expected (Device A):** Green notification appears: "New song request received!"
- [ ] **Expected (Device A):** Request appears in list immediately (no refresh needed)
- [ ] **Expected (Device A):** Analytics update automatically

**Test Case 7: WebSocket Connection Stability**
- [ ] Start a live session
- [ ] Navigate to Live Session Screen
- [ ] Submit 3-5 song requests from another device
- [ ] **Expected:** All requests appear immediately
- [ ] Put app in background for 30 seconds
- [ ] Bring app to foreground
- [ ] Submit another request from another device
- [ ] **Expected:** Request still appears immediately (auto-reconnect works)

**Test Case 8: Fallback Mechanism**
- [ ] Start a live session
- [ ] Turn off WiFi/mobile data
- [ ] **Expected:** Orange notification: "Real-time updates may be delayed"
- [ ] Turn on WiFi/mobile data
- [ ] Submit a request from another device
- [ ] **Expected:** Request appears (connection restored)

**Test Case 9: Auto-refresh in Song Requests Tab**
- [ ] Start a live session
- [ ] Navigate to "Requests" tab
- [ ] Wait 30 seconds without any activity
- [ ] **Expected:** Tab auto-refreshes (fallback mechanism)
- [ ] Submit a request from another device
- [ ] **Expected:** Request appears within 30 seconds even if WebSocket fails

---

### 4. Currency Display (KSh) ✅

**Test Case 10: Create Session Currency Display**
- [ ] Navigate to create session screen
- [ ] Scroll to "Session Settings" section
- [ ] Look at "Minimum Tip Amount" label
- [ ] **Expected:** Shows "KSh 5" (not "$5")
- [ ] Move slider to different values (1, 10, 15, 20)
- [ ] **Expected:** All values show "KSh" prefix
- [ ] **Expected:** Format: "KSh {amount}" (e.g., "KSh 10")

**Test Case 11: Currency Consistency**
- [ ] Check other screens with currency display
- [ ] Verify tip amounts in requests show "KSh"
- [ ] Verify earnings show "KSh"
- [ ] **Note:** Most other screens already use "KSh" - this fix was specific to create session

---

## Integration Testing

### End-to-End Flow Test

**Complete DJ Session Flow:**
1. [ ] Login as DJ
2. [ ] Create a club session with all details
3. [ ] **Verify:** Redirected to Live Session Screen
4. [ ] **Verify:** Currency shows "KSh" in session settings
5. [ ] Tap share icon
6. [ ] Copy session link
7. [ ] **Verify:** Link copied successfully
8. [ ] Share to social media
9. [ ] **Verify:** Share dialog opens with formatted text
10. [ ] From another device, join session and submit request
11. [ ] **Verify:** Request appears immediately on DJ screen
12. [ ] **Verify:** Green notification appears
13. [ ] Accept the request
14. [ ] **Verify:** Request status updates in real-time
15. [ ] Submit 5 more requests from different devices
16. [ ] **Verify:** All appear in real-time without refresh
17. [ ] Put app in background for 1 minute
18. [ ] Bring to foreground
19. [ ] Submit another request
20. [ ] **Verify:** Still works (auto-reconnect successful)

---

## Performance Testing

### WebSocket Performance
- [ ] Start session with 10+ concurrent listeners
- [ ] Have all listeners submit requests simultaneously
- [ ] **Expected:** All requests appear within 2-3 seconds
- [ ] **Expected:** No UI lag or freezing
- [ ] **Expected:** Analytics update smoothly

### Memory Leak Check
- [ ] Start a live session
- [ ] Keep it running for 30 minutes
- [ ] Submit requests periodically
- [ ] Navigate between tabs frequently
- [ ] **Expected:** No memory leaks
- [ ] **Expected:** App remains responsive
- [ ] **Expected:** WebSocket connection remains stable

---

## Error Handling Testing

### Network Interruption
- [ ] Start live session
- [ ] Turn off internet
- [ ] **Expected:** Orange notification about delayed updates
- [ ] Turn on internet
- [ ] **Expected:** Connection restores automatically
- [ ] **Expected:** No crash or error

### Share Failure
- [ ] Start live session
- [ ] Tap share to social media
- [ ] Cancel the share dialog
- [ ] **Expected:** No error, returns to app normally
- [ ] Try sharing with no internet
- [ ] **Expected:** Appropriate error message

### Session Creation Failure
- [ ] Try creating session with invalid data
- [ ] **Expected:** Validation errors shown
- [ ] **Expected:** No navigation until successful
- [ ] Create session successfully
- [ ] **Expected:** Navigate to Live Session Screen

---

## Browser/Platform Testing

### Android
- [ ] Test all features on Android device
- [ ] Verify share dialog uses Android native share
- [ ] Verify notifications appear correctly
- [ ] Verify WebSocket works on mobile data

### iOS
- [ ] Test all features on iOS device
- [ ] Verify share dialog uses iOS native share
- [ ] Verify notifications appear correctly
- [ ] Verify WebSocket works on mobile data

### Web
- [ ] Test all features on web browser
- [ ] Verify share uses Web Share API or fallback
- [ ] Verify WebSocket uses WSS protocol
- [ ] Verify notifications work in browser

---

## Known Limitations

1. **QR Code**: Currently shows placeholder - actual QR generation not implemented
2. **Deep Links**: Session links don't open app directly yet
3. **Push Notifications**: Background notifications not implemented
4. **Offline Mode**: App requires internet for real-time features

---

## Troubleshooting

### Issue: Requests not appearing in real-time
**Solution:**
1. Check internet connection
2. Verify WebSocket connection status
3. Wait for auto-reconnect (5 seconds)
4. Fallback auto-refresh will work within 30 seconds

### Issue: Share not working
**Solution:**
1. Ensure share_plus package is installed (`flutter pub get`)
2. Check platform permissions
3. Try "Copy Link" as alternative

### Issue: Navigation not working after session creation
**Solution:**
1. Verify session was created successfully
2. Check for error messages
3. Ensure LiveSessionScreen import is correct

### Issue: Currency still showing $
**Solution:**
1. Verify you're on the create session screen
2. Clear app cache and restart
3. Check if changes were deployed

---

## Success Criteria

All features are working correctly if:
- ✅ Session creation navigates to Live Session Screen
- ✅ Share functionality works on all platforms
- ✅ Real-time updates appear within 2-3 seconds
- ✅ Currency displays as "KSh" in create session
- ✅ No crashes or errors during normal usage
- ✅ WebSocket auto-reconnects after interruption
- ✅ Fallback mechanisms work when WebSocket fails

---

## Reporting Issues

When reporting issues, please include:
1. Device/Platform (Android/iOS/Web)
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Screenshots/screen recordings
6. Error messages from console

---

**Last Updated:** 2025-10-08
**Version:** 1.0.0
**Status:** Ready for Testing

