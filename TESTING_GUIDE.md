# Song Request Approval Workflow - Testing Guide

## Prerequisites
- Backend server running on configured port
- Frontend app running (Flutter)
- M-Pesa sandbox credentials configured
- At least one DJ account and one user account

## Test Scenarios

### Scenario 1: Complete Approval Workflow

#### Setup
1. Login as a regular user
2. Find an active DJ session
3. Select a song to request

#### Steps
1. **Create Song Request**
   - Select a song from the available list
   - Enter tip amount (e.g., KSH 50)
   - Add optional message
   - Click "Request Song"
   
2. **Process Payment**
   - Complete M-Pesa STK Push payment
   - Verify payment success message
   - Check that request appears in DJ's pending queue

3. **DJ Approves Request**
   - Login as DJ
   - Navigate to Session tab
   - View pending requests
   - Click "Accept" on the request
   
4. **Verify Results**
   - ✅ Request status changes to "ACCEPTED"
   - ✅ Payment is captured (no refund)
   - ✅ DJ earnings increase by request amount
   - ✅ Request appears in accepted queue
   - ✅ User sees request status update

#### Expected Backend Logs
```
🎵 Creating request - Received amount: 50.0
✅ Request {id} accepted by DJ {username}. Payment captured for amount: KSH 50.0
```

#### Expected Database State
- Request status: `ACCEPTED`
- RequestsPayment record exists with correct amount
- No Refund record created
- DJ earnings include this payment

---

### Scenario 2: Complete Rejection Workflow

#### Setup
1. Login as a regular user
2. Find an active DJ session
3. Create a song request with payment

#### Steps
1. **Create Song Request**
   - Select a song
   - Enter tip amount (e.g., KSH 30)
   - Complete payment
   
2. **DJ Rejects Request**
   - Login as DJ
   - Navigate to Session tab
   - View pending requests
   - Click "Reject" on the request
   - Confirm rejection in dialog

3. **Verify Results**
   - ✅ Request status changes to "REJECTED"
   - ✅ Refund is automatically initiated
   - ✅ DJ earnings do NOT increase
   - ✅ User receives refund notification
   - ✅ Refund record created in database

#### Expected Backend Logs
```
🔄 Processing refund for rejected request ID: {id}
💳 Initiating M-Pesa refund for payment ID: {id}, Amount: KSH 30.0
✅ Refund completed successfully for request ID: {id}, Amount: KSH 30.0
```

#### Expected Database State
- Request status: `REJECTED`
- RequestsPayment record exists
- Refund record created with status `COMPLETED`
- DJ earnings do NOT include this payment

---

### Scenario 3: DJ Earnings Dashboard

#### Setup
1. Complete at least 2 approved requests and 1 rejected request
2. Login as DJ

#### Steps
1. **View Earnings Tab**
   - Navigate to Earnings tab
   - Check total earnings display
   
2. **Verify Earnings Calculation**
   - ✅ Total earnings = Sum of ACCEPTED requests + Tips
   - ✅ Pending amount = Sum of PENDING requests
   - ✅ Rejected requests NOT included in earnings
   - ✅ Revenue breakdown shows correct split

3. **Check Transaction History**
   - View transaction list
   - ✅ Only accepted request payments shown
   - ✅ Correct amounts and dates
   - ✅ Proper sorting (newest first)

#### Expected API Response
```json
{
  "totalEarnings": 150.0,
  "totalTips": 50.0,
  "totalRequests": 100.0,
  "pendingAmount": 30.0,
  "availableForPayout": 150.0,
  "totalTransactions": 3
}
```

---

### Scenario 4: Multiple Requests Management

#### Setup
1. Create 5 song requests from different users
2. Login as DJ

#### Steps
1. **View Request Queue**
   - Navigate to Session tab
   - View all pending requests
   - ✅ All 5 requests visible
   - ✅ Correct amounts displayed
   - ✅ User messages shown

2. **Mixed Approval/Rejection**
   - Accept 3 requests
   - Reject 2 requests
   
3. **Verify Results**
   - ✅ 3 refunds initiated automatically
   - ✅ Earnings updated for 3 accepted requests only
   - ✅ All status updates broadcast via WebSocket
   - ✅ Request queue updates in real-time

---

### Scenario 5: Error Handling

#### Test 5.1: Unauthorized Access
1. Login as User A
2. Try to accept/reject User B's request
3. ✅ Should receive 403 Forbidden error

#### Test 5.2: Request Not Found
1. Try to accept non-existent request ID
2. ✅ Should receive 404 Not Found error

#### Test 5.3: Duplicate Refund
1. Reject a request
2. Try to reject the same request again
3. ✅ Should not create duplicate refund
4. ✅ Should log warning about existing refund

#### Test 5.4: Payment Not Found
1. Create request without payment
2. Reject the request
3. ✅ Should log warning
4. ✅ Should not crash
5. ✅ Request status still updates

---

## API Testing with Postman/cURL

### Accept Request
```bash
curl -X PUT http://localhost:8080/api/v1/requests/{requestId}/accept \
  -H "Authorization: Bearer {dj_token}" \
  -H "Content-Type: application/json"
```

Expected Response:
```json
{
  "id": "uuid",
  "status": "ACCEPTED",
  "amount": 50.0,
  "djId": "uuid",
  "clientId": "uuid",
  "songId": "uuid",
  "message": "Great song!",
  "createdAt": "2024-01-01T12:00:00",
  "updatedAt": "2024-01-01T12:05:00"
}
```

### Reject Request
```bash
curl -X PUT http://localhost:8080/api/v1/requests/{requestId}/reject \
  -H "Authorization: Bearer {dj_token}" \
  -H "Content-Type: application/json"
```

Expected Response: Same structure with `status: "REJECTED"`

### Get Earnings Summary
```bash
curl -X GET "http://localhost:8080/api/v1/earnings/summary?period=month" \
  -H "Authorization: Bearer {dj_token}"
```

---

## Database Verification Queries

### Check Request Status
```sql
SELECT id, status, amount, created_at, updated_at 
FROM requests 
WHERE id = '{request_id}';
```

### Check Refund Records
```sql
SELECT r.id, r.amount, r.status, r.initiated_at, r.completed_at, rp.receipt_number
FROM refunds r
JOIN request_payments rp ON r.request_payment_id = rp.id
WHERE rp.request_id = '{request_id}';
```

### Check DJ Earnings
```sql
SELECT 
  SUM(rp.amount) as total_from_requests,
  COUNT(*) as request_count
FROM request_payments rp
JOIN requests req ON rp.request_id = req.id
WHERE req.dj_id = '{dj_id}' 
  AND req.status = 'ACCEPTED';
```

---

## Performance Testing

### Load Test: Multiple Concurrent Approvals
1. Create 50 pending requests
2. Accept all 50 requests simultaneously
3. ✅ All requests processed successfully
4. ✅ No race conditions
5. ✅ Earnings calculated correctly
6. ✅ Response time < 500ms per request

### Load Test: Multiple Concurrent Rejections
1. Create 50 pending requests
2. Reject all 50 requests simultaneously
3. ✅ All refunds initiated
4. ✅ No duplicate refunds
5. ✅ All refund records created
6. ✅ Response time < 1000ms per request

---

## Monitoring Checklist

### Backend Logs to Monitor
- ✅ Request acceptance logs with amounts
- ✅ Refund initiation logs
- ✅ Refund completion/failure logs
- ✅ Payment capture confirmations
- ✅ Error logs for failed operations

### Metrics to Track
- ✅ Request approval rate
- ✅ Request rejection rate
- ✅ Average refund processing time
- ✅ Failed refund count
- ✅ Total earnings per DJ
- ✅ Average request amount

---

## Troubleshooting

### Issue: Refund Not Processing
1. Check backend logs for error messages
2. Verify M-Pesa credentials are correct
3. Check if payment record exists
4. Verify refund record status in database

### Issue: Earnings Not Updating
1. Verify request status is ACCEPTED
2. Check if payment record exists
3. Verify earnings API filters by status
4. Check database query results

### Issue: WebSocket Not Broadcasting
1. Verify WebSocket connection is active
2. Check broadcaster service logs
3. Test with multiple clients
4. Verify frontend WebSocket listener

---

## Success Criteria

All tests pass when:
- ✅ Requests can be approved and rejected
- ✅ Payments are captured on approval
- ✅ Refunds are automatic on rejection
- ✅ Earnings only include accepted requests
- ✅ Dashboard shows correct data
- ✅ Real-time updates work
- ✅ Error handling is robust
- ✅ No duplicate refunds
- ✅ Performance is acceptable
- ✅ Logs are informative

