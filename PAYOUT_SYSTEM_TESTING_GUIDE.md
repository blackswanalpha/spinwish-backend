# DJ Portal - Payout System Testing Guide

## Overview
This guide provides comprehensive testing instructions for the newly implemented payout system in the SpinWish DJ Portal application.

## Prerequisites
- Backend server running on `http://localhost:8080`
- Flutter app running on device/emulator
- Valid DJ user account with earnings available

## Test Scenarios

### 1. Add Bank Account Payout Method

**Steps:**
1. Login as a DJ user
2. Navigate to DJ Portal → Earnings Tab
3. Tap on "Payout Settings" button
4. Tap on "Add Payout Method" button
5. Select "Add Bank Account"
6. Fill in the form:
   - Display Name: "My Primary Bank"
   - Bank Name: Select "Equity Bank" from dropdown
   - Account Number: "1234567890"
   - Account Holder Name: "John Doe"
   - Bank Branch: "Nairobi Branch"
   - Bank Code: "68000"
   - Check "Set as default payout method"
7. Tap "Save Bank Account"

**Expected Results:**
- ✅ Form validation works for all fields
- ✅ Success message: "Bank account added successfully"
- ✅ Redirected back to Payout Settings screen
- ✅ New bank account appears in the list
- ✅ Bank account is marked as "Default"
- ✅ Account number is masked (e.g., "****7890")

**API Endpoint Tested:**
```
POST /api/v1/payouts/methods
```

---

### 2. Add M-Pesa Payout Method

**Steps:**
1. From Payout Settings screen
2. Tap "Add Payout Method"
3. Select "Add M-Pesa"
4. Fill in the form:
   - Display Name: "My M-Pesa"
   - M-Pesa Phone Number: "0712345678" or "254712345678"
   - Account Name: "John Doe"
   - Optionally check "Set as default payout method"
5. Tap "Save M-Pesa Account"

**Expected Results:**
- ✅ Phone number validation works (Kenyan format)
- ✅ Phone number is auto-formatted to 254XXXXXXXXX
- ✅ Success message: "M-Pesa account added successfully"
- ✅ New M-Pesa account appears in the list
- ✅ Phone number is masked (e.g., "****5678")
- ✅ If set as default, previous default is unset

**API Endpoint Tested:**
```
POST /api/v1/payouts/methods
```

---

### 3. Set Default Payout Method

**Steps:**
1. From Payout Settings screen with multiple payout methods
2. Tap the three-dot menu on a non-default method
3. Select "Set as Default"

**Expected Results:**
- ✅ Success message: "[Method Name] set as default"
- ✅ Previous default method loses "Default" badge
- ✅ Selected method gains "Default" badge
- ✅ List refreshes automatically

**API Endpoint Tested:**
```
PUT /api/v1/payouts/methods/{methodId}/default
```

---

### 4. Delete Payout Method

**Steps:**
1. From Payout Settings screen
2. Tap the three-dot menu on a payout method
3. Select "Delete"
4. Confirm deletion in the dialog

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ Success message: "Payout method deleted"
- ✅ Method is removed from the list
- ✅ List refreshes automatically

**API Endpoint Tested:**
```
DELETE /api/v1/payouts/methods/{methodId}
```

---

### 5. Request Payout - Full Flow

**Steps:**
1. Navigate to Earnings Tab
2. Ensure you have available balance (e.g., KES 1000.00)
3. Tap "Request Payout" button
4. In the dialog:
   - Verify available balance is displayed
   - Select a payout method from dropdown
   - Enter amount: "500.00"
   - Verify processing fee calculation (2%): "KES 10.00"
   - Verify net amount: "KES 490.00"
5. Tap "Submit Request"

**Expected Results:**
- ✅ Form validation works:
  - Minimum amount: KES 50.00
  - Maximum amount: Available balance
  - Invalid amounts show error messages
- ✅ Processing fee is calculated correctly (2%)
- ✅ Net amount is calculated correctly (amount - fee)
- ✅ Success dialog appears with payout details
- ✅ Payout status shows "PENDING"

**API Endpoint Tested:**
```
POST /api/v1/payouts/requests
```

---

### 6. Process Payout (Demo Mode)

**Steps:**
1. After requesting payout (Step 5)
2. In the success dialog, tap "Process Now (Demo)"
3. Wait for processing (2 seconds simulation)

**Expected Results:**
- ✅ Processing indicator appears
- ✅ Success message: "Payout processed successfully! Check your transaction history."
- ✅ Dialog closes automatically
- ✅ Earnings page refreshes
- ✅ Available balance is reduced by payout amount
- ✅ Transaction appears in transaction history

**API Endpoint Tested:**
```
POST /api/v1/payouts/requests/{requestId}/process
```

---

### 7. View Payout History

**Steps:**
1. From Earnings Tab
2. Tap "Transaction History" button
3. Look for payout transactions

**Expected Results:**
- ✅ Payout requests appear in transaction list
- ✅ Shows correct amount, date, and status
- ✅ Completed payouts show receipt number
- ✅ Transaction details are accurate

**API Endpoint Tested:**
```
GET /api/v1/payouts/requests
```

---

### 8. Period Selection in Earnings Tab

**Steps:**
1. From Earnings Tab
2. Tap the period dropdown (default: "This Month")
3. Select different periods: "Today", "This Week", "All Time"

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Earnings data refreshes for selected period
- ✅ All cards update with period-specific data
- ✅ Available balance updates correctly

**API Endpoint Tested:**
```
GET /api/v1/earnings/summary?period={period}
```

---

### 9. Error Handling Tests

#### 9.1 No Payout Methods Available
**Steps:**
1. Delete all payout methods
2. Try to request payout

**Expected Results:**
- ✅ Dialog shows "No payout methods available"
- ✅ "Add Payout Method" button is displayed
- ✅ Clicking button navigates to Payout Settings

#### 9.2 Insufficient Balance
**Steps:**
1. Try to request payout amount greater than available balance

**Expected Results:**
- ✅ Validation error: "Amount exceeds available balance"
- ✅ Submit button remains disabled

#### 9.3 Below Minimum Amount
**Steps:**
1. Try to request payout amount less than KES 50.00

**Expected Results:**
- ✅ Validation error: "Minimum amount is KES 50.00"
- ✅ Submit button remains disabled

#### 9.4 Invalid Phone Number (M-Pesa)
**Steps:**
1. Try to add M-Pesa with invalid phone number (e.g., "123")

**Expected Results:**
- ✅ Validation error: "Please enter a valid Kenyan mobile number"
- ✅ Save button remains disabled

#### 9.5 Network Error
**Steps:**
1. Turn off backend server
2. Try to load payout methods

**Expected Results:**
- ✅ Error message displayed
- ✅ Retry button available
- ✅ User-friendly error message

---

## API Endpoints Summary

### Payout Methods
- `POST /api/v1/payouts/methods` - Add payout method
- `GET /api/v1/payouts/methods` - Get all payout methods
- `GET /api/v1/payouts/methods/default` - Get default method
- `PUT /api/v1/payouts/methods/{methodId}/default` - Set default
- `DELETE /api/v1/payouts/methods/{methodId}` - Delete method

### Payout Requests
- `POST /api/v1/payouts/requests` - Create payout request
- `GET /api/v1/payouts/requests` - Get payout requests
- `POST /api/v1/payouts/requests/{requestId}/process` - Process payout (demo)

### Earnings
- `GET /api/v1/earnings/summary` - Get earnings summary
- `GET /api/v1/earnings/transactions` - Get transaction history

---

## Validation Rules

### Bank Account
- Display Name: Required, min 3 characters
- Bank Name: Required
- Account Number: Required, digits only
- Account Holder Name: Required, min 3 characters
- Bank Branch: Optional
- Bank Code: Optional

### M-Pesa
- Display Name: Required, min 3 characters
- Phone Number: Required, Kenyan format (254XXXXXXXXX or 07XXXXXXXX)
- Account Name: Required, min 3 characters

### Payout Request
- Amount: Required, min KES 50.00, max available balance
- Payout Method: Required
- Processing Fee: 2% of amount
- Net Amount: Amount - Processing Fee

---

## Success Criteria

All tests pass when:
- ✅ Users can add both bank account and M-Pesa payout methods
- ✅ Users can set default payout method
- ✅ Users can delete payout methods
- ✅ Users can request payouts with proper validation
- ✅ Demo payout processing works end-to-end
- ✅ Transaction history shows payout records
- ✅ Balance updates correctly after payout
- ✅ All error cases are handled gracefully
- ✅ Loading states are displayed appropriately
- ✅ User feedback messages are clear and helpful

