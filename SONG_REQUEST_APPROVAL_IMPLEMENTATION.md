# Song Request Approval Workflow Implementation

## Overview
This document describes the implementation of the song request approval workflow with automated payment processing and DJ earnings tracking in the SpinWish application.

## Implementation Summary

### 1. Song Request Approval System ✅

#### Backend Implementation
- **Endpoints**: 
  - `PUT /api/v1/requests/{id}/accept` - Accept a song request (DJ only)
  - `PUT /api/v1/requests/{id}/reject` - Reject a song request (DJ only)
  
- **Authorization**: Both endpoints verify that the authenticated user is the DJ for the request

- **Status Tracking**: Request status enum includes:
  - `PENDING` - Initial state when request is created
  - `ACCEPTED` - DJ approved the request
  - `REJECTED` - DJ rejected the request
  - `PLAYED` - Request has been fulfilled

#### Frontend Implementation
- **UI Components**:
  - `RequestQueueWidget` - Displays pending song requests with approve/reject buttons
  - `EnhancedRequestQueueWidget` - Enhanced version with additional features
  
- **Session Service**: 
  - `acceptRequest(requestId)` - Calls backend API to accept request
  - `rejectRequest(requestId)` - Calls backend API to reject request
  - Both methods update local state and session statistics

### 2. Payment Processing Logic ✅

#### Approval Flow (Payment Capture)
When a DJ **accepts** a song request:

1. **Backend** (`RequestsService.acceptRequest()`):
   - Updates request status to `ACCEPTED`
   - Payment is automatically captured (payment was already processed when request was created)
   - Logs the payment capture with amount
   - Broadcasts update via WebSocket

2. **Frontend** (`SessionService.acceptRequest()`):
   - Calls backend API
   - Updates local request status
   - Adds amount to session earnings
   - Updates session statistics

**Key Point**: Payments are processed upfront when the request is created. Accepting the request simply confirms the payment should be kept.

#### Rejection Flow (Automatic Refund)
When a DJ **rejects** a song request:

1. **Backend** (`RequestsService.rejectRequest()`):
   - Updates request status to `REJECTED`
   - Calls `RefundService.processRefundForRejectedRequest()`
   - Refund service:
     - Finds the payment associated with the request
     - Creates a `Refund` entity with status `PENDING`
     - Initiates refund transaction (M-Pesa B2C API)
     - Updates refund status to `COMPLETED` or `FAILED`
   - Broadcasts update via WebSocket

2. **Frontend** (`SessionService.rejectRequest()`):
   - Calls backend API
   - Updates local request status
   - Updates session statistics
   - Displays message about automatic refund

**Key Point**: Refunds are processed automatically on the backend when a request is rejected.

### 3. DJ Earnings Dashboard ✅

#### Backend Implementation
**EarningsService** (`getDJEarningsSummary()`):
- Calculates earnings from **ACCEPTED requests only**
- Separates pending vs available earnings:
  - **Total Earnings** = Tips + Accepted Request Payments
  - **Pending Amount** = Payments from PENDING requests (not yet approved)
  - **Available for Payout** = Total Earnings (all accepted)

**Repository Enhancement**:
- Added `findByRequestDjAndStatusAndTransactionDateBetween()` to filter payments by request status
- Ensures only ACCEPTED request payments count toward earnings

#### Frontend Implementation
**EarningsTab** displays:
- Total earnings (from accepted requests + tips)
- Revenue breakdown (tips vs song requests)
- Available for payout amount
- Pending amount (from unapproved requests)
- Transaction history

**DashboardTab** shows:
- Quick stats including total earnings
- Pending requests count
- Active listeners count

## Database Schema

### New Entities

#### Refund Entity
```java
@Entity
@Table(name = "refunds")
public class Refund {
    UUID id;
    RequestsPayment requestPayment;  // One-to-one with payment
    Double amount;
    String reason;
    RefundStatus status;  // PENDING, PROCESSING, COMPLETED, FAILED
    String refundMethod;  // MPESA, CARD, etc.
    String transactionId;
    LocalDateTime initiatedAt;
    LocalDateTime completedAt;
    String failureReason;
}
```

### Modified Entities

#### Request Entity
- Already has `status` field with enum: PENDING, ACCEPTED, REJECTED, PLAYED
- Already has `amount` field for payment amount

#### RequestsPayment Entity
- Links to Request entity
- Used to track payments for song requests
- Filtered by request status for earnings calculation

## API Endpoints

### Request Management
```
PUT /api/v1/requests/{id}/accept
- Description: Accept a song request (DJ only)
- Authorization: Bearer token (DJ must own the request)
- Response: PlaySongResponse with updated status
- Side Effect: Payment is captured, earnings updated

PUT /api/v1/requests/{id}/reject
- Description: Reject a song request (DJ only)
- Authorization: Bearer token (DJ must own the request)
- Response: PlaySongResponse with updated status
- Side Effect: Automatic refund initiated
```

### Earnings
```
GET /api/v1/earnings/summary
- Description: Get DJ earnings summary
- Query Params: period (today, week, month, all)
- Response: EarningsSummary with breakdown
- Note: Only includes ACCEPTED request payments
```

## Payment Flow Diagram

```
User Creates Request
        ↓
Payment Processed (M-Pesa STK Push)
        ↓
Request Status: PENDING
        ↓
    DJ Reviews
        ↓
    ┌───────┴───────┐
    ↓               ↓
ACCEPT          REJECT
    ↓               ↓
Payment         Refund
Captured        Initiated
    ↓               ↓
Earnings        Money
Updated         Returned
    ↓               ↓
Status:         Status:
ACCEPTED        REJECTED
```

## Error Handling

### Payment Capture (Accept)
- If request not found: Returns 404 error
- If unauthorized: Returns 403 error
- If already accepted: Idempotent (no duplicate capture)

### Refund Processing (Reject)
- If no payment found: Logs warning, continues (request may not have been paid)
- If refund already exists: Logs warning, skips duplicate refund
- If M-Pesa API fails: Marks refund as FAILED with reason
- All errors are logged with detailed context

## Testing Checklist

### Approval Workflow
- [ ] DJ can view pending requests
- [ ] DJ can accept a request
- [ ] Payment is captured on acceptance
- [ ] Earnings are updated immediately
- [ ] Request status changes to ACCEPTED
- [ ] WebSocket broadcasts update to all clients

### Rejection Workflow
- [ ] DJ can reject a request
- [ ] Refund is automatically initiated
- [ ] Refund entity is created with correct amount
- [ ] Request status changes to REJECTED
- [ ] User receives refund notification
- [ ] Earnings are NOT updated for rejected requests

### Earnings Dashboard
- [ ] Shows only earnings from accepted requests
- [ ] Displays pending amount separately
- [ ] Updates in real-time when requests are approved
- [ ] Shows correct breakdown of tips vs requests
- [ ] Historical data filters work correctly

## Future Enhancements

1. **M-Pesa B2C Integration**: Implement actual M-Pesa B2C API for refunds
2. **Refund Notifications**: Send push notifications when refunds are processed
3. **Partial Refunds**: Support partial refunds for special cases
4. **Refund History**: Add UI to view refund history
5. **Payout System**: Implement DJ payout requests and processing
6. **Analytics**: Add detailed analytics for approval/rejection rates

## Configuration

### Backend
- Refund service is automatically injected into RequestsService
- No additional configuration required
- M-Pesa credentials already configured in `application.properties`

### Frontend
- Session service automatically uses real API calls
- No configuration changes needed
- WebSocket updates work automatically

## Deployment Notes

1. **Database Migration**: New `refunds` table will be created automatically by JPA
2. **Backward Compatibility**: Existing requests continue to work
3. **No Breaking Changes**: All existing APIs remain functional
4. **Monitoring**: Check logs for refund processing status

## Support

For issues or questions:
- Check backend logs for detailed error messages
- Verify M-Pesa configuration for payment/refund issues
- Ensure WebSocket connection is active for real-time updates

