# Request Management Testing Guide

## Quick Test Scenarios

### Scenario 1: Accept a Pending Request (Quick Action)

**Steps:**
1. Start a live DJ session
2. Have a listener submit a song request with a tip
3. Navigate to "Requests" tab in Live Session screen
4. Locate the pending request (orange "PENDING" badge)
5. Tap the green "Accept" button on the request card

**Expected Results:**
- ✅ Green notification: "Request accepted! Song added to queue."
- ✅ Request status badge changes to green "APPROVED"
- ✅ Quick action button changes to "Mark as Played"
- ✅ Song appears in the Queue tab
- ✅ DJ earnings updated in analytics
- ✅ Real-time update sent to requester

---

### Scenario 2: Reject a Pending Request (Quick Action)

**Steps:**
1. Locate a pending request in the Requests tab
2. Tap the red "Reject" button on the request card
3. Confirmation dialog appears
4. Tap "Reject" to confirm

**Expected Results:**
- ✅ Confirmation dialog shows: "Reject Request? Tip will be refunded."
- ✅ Orange notification: "Request rejected. Tip refunded."
- ✅ Request removed from pending list or status updated
- ✅ Tip refunded to requester's account
- ✅ Real-time update sent to requester

**Cancel Test:**
- Tap "Cancel" in confirmation dialog
- ✅ Dialog closes, no action taken
- ✅ Request remains pending

---

### Scenario 3: View Request Details (Modal)

**Steps:**
1. Locate any request in the Requests tab
2. Tap anywhere on the request card (not on action buttons)
3. Glassmorphism modal opens

**Expected Results:**
- ✅ Modal opens with smooth scale and fade animation
- ✅ Glassmorphism effect visible (blurred background)
- ✅ Song details displayed:
  - Album artwork placeholder
  - Song title and artist
  - Album name (if available)
- ✅ Requester information displayed:
  - Requester name
  - Tip amount (KSh format)
  - Request timestamp
- ✅ Status badge shows current status
- ✅ Message displayed (if provided by requester)
- ✅ Action buttons appropriate for status:
  - Pending: "Reject" and "Accept & Add to Queue"
  - Approved: "Mark as Played"

---

### Scenario 4: Accept Request from Modal

**Steps:**
1. Open modal for a pending request
2. Tap "Accept & Add to Queue" button
3. Wait for processing

**Expected Results:**
- ✅ Loading indicator appears
- ✅ "Processing..." text shown
- ✅ Modal closes automatically after success
- ✅ Green notification appears
- ✅ Request list refreshes
- ✅ Request status updated to approved

---

### Scenario 5: Reject Request from Modal

**Steps:**
1. Open modal for a pending request
2. Tap "Reject" button
3. Confirmation dialog appears
4. Confirm rejection

**Expected Results:**
- ✅ Confirmation dialog appears over modal
- ✅ After confirmation, modal closes
- ✅ Orange notification appears
- ✅ Request list refreshes
- ✅ Request status updated or removed

---

### Scenario 6: Mark Request as Played

**Steps:**
1. Locate an approved request (green "APPROVED" badge)
2. Tap "Mark as Played" button (either on card or in modal)

**Expected Results:**
- ✅ Blue notification: "Request marked as played!"
- ✅ Request status updated to "PLAYED"
- ✅ Request may move to different filter category
- ✅ Analytics updated
- ✅ Real-time update sent

---

### Scenario 7: Close Modal

**Test A - Close Button:**
1. Open request modal
2. Tap X button in top-right corner

**Expected Results:**
- ✅ Modal closes with reverse animation
- ✅ Returns to requests list
- ✅ No status change

**Test B - Backdrop Tap:**
1. Open request modal
2. Tap outside the modal (on dark background)

**Expected Results:**
- ✅ Modal closes with reverse animation
- ✅ Returns to requests list
- ✅ No status change

---

### Scenario 8: Real-time Updates

**Setup:**
- Device A: DJ with live session
- Device B: Listener

**Steps:**
1. Device B: Submit a song request
2. Device A: Observe Requests tab

**Expected Results:**
- ✅ New request appears immediately (within 2-3 seconds)
- ✅ Green notification: "New song request received!"
- ✅ Request appears at top of list (sorted by time)
- ✅ No manual refresh needed

**Follow-up:**
1. Device A: Accept the request
2. Device B: Check request status

**Expected Results:**
- ✅ Device B sees status update to "Accepted"
- ✅ Device B receives notification
- ✅ Queue position shown (if applicable)

---

### Scenario 9: Filter and Search

**Test A - Filter by Status:**
1. Navigate to Requests tab
2. Tap "Pending" filter chip

**Expected Results:**
- ✅ Only pending requests shown
- ✅ Filter chip highlighted
- ✅ Count updates

3. Tap "Approved" filter chip

**Expected Results:**
- ✅ Only approved requests shown
- ✅ Previous filter deselected
- ✅ Count updates

**Test B - Search:**
1. Type song name in search bar
2. Observe filtered results

**Expected Results:**
- ✅ Results filter in real-time
- ✅ Matches song title, artist, or requester name
- ✅ Case-insensitive search

**Test C - Sort:**
1. Open sort dropdown
2. Select "By Tip"

**Expected Results:**
- ✅ Requests sorted by tip amount (highest first)
- ✅ Sort persists across filter changes

---

### Scenario 10: Error Handling

**Test A - Network Failure:**
1. Turn off internet connection
2. Try to accept a request

**Expected Results:**
- ✅ Red error notification appears
- ✅ Error message describes the issue
- ✅ Request status unchanged
- ✅ User can retry after reconnecting

**Test B - Invalid Request:**
1. Accept a request
2. Immediately try to accept it again (if possible)

**Expected Results:**
- ✅ Appropriate error message
- ✅ UI handles gracefully
- ✅ No crash or freeze

**Test C - Session Ended:**
1. End the DJ session
2. Try to manage a request

**Expected Results:**
- ✅ Error message or redirect
- ✅ User informed session is no longer active

---

### Scenario 11: Multiple Requests

**Steps:**
1. Have 5+ listeners submit requests
2. Observe Requests tab

**Expected Results:**
- ✅ All requests appear in list
- ✅ Scrollable list
- ✅ Performance remains smooth
- ✅ Real-time updates for all requests

**Batch Actions:**
1. Accept 3 requests in quick succession
2. Observe behavior

**Expected Results:**
- ✅ Each request processes independently
- ✅ Loading states prevent duplicate submissions
- ✅ All notifications appear
- ✅ List updates correctly

---

### Scenario 12: Edge Cases

**Test A - Request with No Message:**
1. Submit request without message
2. View in modal

**Expected Results:**
- ✅ Message section not displayed
- ✅ No error or blank space
- ✅ UI looks clean

**Test B - Request with Long Message:**
1. Submit request with 500-character message
2. View on card and in modal

**Expected Results:**
- ✅ Card shows truncated message (2 lines)
- ✅ Modal shows full message
- ✅ Text wraps properly

**Test C - Request with No Song Data:**
1. Request with missing song information
2. View in list and modal

**Expected Results:**
- ✅ Fallback text: "Unknown Song" / "Unknown Artist"
- ✅ No crash or error
- ✅ UI remains functional

---

## Performance Testing

### Load Testing
1. Create 50+ requests
2. Navigate to Requests tab
3. Scroll through list
4. Apply filters and search

**Expected Results:**
- ✅ Smooth scrolling (60 FPS)
- ✅ No lag when filtering
- ✅ Search results instant
- ✅ Memory usage stable

### Animation Performance
1. Open and close modal 10 times rapidly
2. Observe animation smoothness

**Expected Results:**
- ✅ Animations remain smooth
- ✅ No frame drops
- ✅ No memory leaks

---

## Accessibility Testing

### Screen Reader
1. Enable screen reader (TalkBack/VoiceOver)
2. Navigate through requests
3. Interact with buttons

**Expected Results:**
- ✅ All elements announced
- ✅ Button purposes clear
- ✅ Status changes announced

### Keyboard Navigation
1. Use keyboard to navigate (if applicable)
2. Tab through elements

**Expected Results:**
- ✅ Logical tab order
- ✅ Focus indicators visible
- ✅ All actions accessible

---

## Cross-Platform Testing

### Android
- [ ] Test on Android 10+
- [ ] Test on different screen sizes
- [ ] Test with different themes (light/dark)
- [ ] Verify glassmorphism effect

### iOS
- [ ] Test on iOS 13+
- [ ] Test on different iPhone models
- [ ] Test with different themes
- [ ] Verify glassmorphism effect

### Web
- [ ] Test on Chrome, Firefox, Safari
- [ ] Test responsive design
- [ ] Verify glassmorphism support
- [ ] Test keyboard shortcuts

---

## Regression Testing

After any changes, verify:
- [ ] Existing features still work
- [ ] No new bugs introduced
- [ ] Performance not degraded
- [ ] UI consistency maintained

---

## Bug Reporting Template

When reporting issues, include:

**Bug Title:** [Brief description]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Screenshots/Videos:**
[Attach if applicable]

**Environment:**
- Device: [e.g., iPhone 12, Pixel 5]
- OS Version: [e.g., iOS 15, Android 12]
- App Version: [e.g., 1.0.0]
- Network: [WiFi/Mobile Data]

**Additional Context:**
[Any other relevant information]

---

## Success Criteria

All features pass testing when:
- ✅ All functional tests pass
- ✅ No critical bugs found
- ✅ Performance meets standards (60 FPS)
- ✅ Error handling works correctly
- ✅ Real-time updates reliable
- ✅ UI/UX smooth and intuitive
- ✅ Accessibility requirements met
- ✅ Cross-platform compatibility verified

---

**Testing Status:** Ready for QA  
**Last Updated:** 2025-10-08  
**Version:** 1.0.0

