# SpinWish DJ Portal Testing Guide

## Quick Start Testing

### Backend API Tests (Postman/cURL)

#### 1. Get Session Analytics
```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{sessionId}/analytics" \
  -H "Authorization: Bearer {jwt_token}"
```

#### 2. Get Pending Requests
```bash
curl -X GET "http://localhost:8080/api/v1/requests/session/{sessionId}/pending" \
  -H "Authorization: Bearer {jwt_token}"
```

#### 3. Get Session Queue
```bash
curl -X GET "http://localhost:8080/api/v1/requests/session/{sessionId}/queue" \
  -H "Authorization: Bearer {jwt_token}"
```

### Frontend Manual Tests

#### Test DJ Request Management Screen
1. Login as DJ and start a session
2. Have listeners create 3-5 song requests
3. Navigate to session requests screen
4. Verify pending requests appear with all details
5. Accept 2 requests and verify they move to approved tab
6. Reject 1 request and confirm refund processed
7. Check queue positions are sequential (#1, #2)

#### Test Listener Queue View
1. Login as listener and join a live session
2. Navigate to session detail → Queue tab
3. Verify approved requests appear in order
4. Check queue positions display correctly
5. Verify empty state when no approved requests

#### Test Session Metrics Display
1. View sessions list as listener
2. Verify each session card shows:
   - Listener count
   - Total requests
   - Total earnings
3. Join a session and return to list
4. Verify metrics updated

## Critical Test Cases

### TC1: Request Approval Flow
**Steps:**
1. Create request with 100 KSH tip
2. DJ accepts request
3. Verify session earnings increased by 100
4. Check request appears in queue with position #1

**Expected:** All statistics update correctly, no errors

### TC2: Request Rejection Flow
**Steps:**
1. Create request with 50 KSH tip
2. DJ rejects request
3. Verify refund processed
4. Check session earnings unchanged

**Expected:** Refund successful, statistics accurate

### TC3: Analytics Accuracy
**Steps:**
1. Create 10 requests (accept 7, reject 3)
2. Fetch session analytics
3. Verify calculations:
   - totalRequests = 10
   - acceptedRequests = 7
   - rejectedRequests = 3
   - acceptanceRate = 70%

**Expected:** All metrics mathematically correct

## Testing Checklist

### Backend ✅
- [ ] Analytics endpoint returns correct data
- [ ] Pending requests filter works
- [ ] Queue ordering is correct
- [ ] Session stats update on create
- [ ] Session stats update on accept
- [ ] Session stats update on reject
- [ ] Earnings calculations accurate
- [ ] WebSocket broadcasts work

### Frontend ✅
- [ ] Request management screen displays
- [ ] Accept/reject buttons work
- [ ] Queue tab shows positions
- [ ] Session list shows metrics
- [ ] Empty states display
- [ ] Pull to refresh works
- [ ] Error messages appear

### Integration ✅
- [ ] End-to-end request flow works
- [ ] Real-time updates propagate
- [ ] Payment refunds process
- [ ] No race conditions
- [ ] Data consistency maintained

## Known Issues / Notes

- Session statistics are calculated in real-time from database queries
- Queue positions are based on `createdAt` timestamp
- WebSocket updates may have slight delay (< 1 second)
- Large request volumes (100+) may need pagination

## Next Steps

1. Run all test cases documented above
2. Fix any bugs discovered
3. Perform load testing with 100+ concurrent requests
4. Test on multiple devices (iOS/Android)
5. Verify production deployment readiness

