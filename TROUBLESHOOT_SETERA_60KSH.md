# Troubleshooting: Setera DJ - 60 KSH Not Showing

## Issue
Setera DJ made 60 KSH but it's not showing in the earnings tab.

---

## Quick Diagnosis Steps

### Step 1: Access H2 Console
1. Make sure backend is running
2. Go to: `http://localhost:8080/h2-console`
3. Login:
   - JDBC URL: `jdbc:h2:mem:testdb`
   - Username: `sa`
   - Password: (empty)

### Step 2: Find Setera DJ ID
Run this query:
```sql
SELECT 
    id as DJ_ID,
    email_address,
    full_name,
    username
FROM users 
WHERE LOWER(full_name) LIKE '%setera%' 
   OR LOWER(username) LIKE '%setera%'
   OR LOWER(email_address) LIKE '%setera%';
```

**Copy the DJ_ID** - you'll need it for the next steps.

### Step 3: Check for 60 KSH Payment
Run these queries (replace `SETERA_DJ_ID` with the actual ID from Step 2):

**Check Tips:**
```sql
SELECT * FROM tip_payments 
WHERE dj_id = 'SETERA_DJ_ID' 
ORDER BY transaction_date DESC;
```

**Check Request Payments:**
```sql
SELECT rp.*, r.status as REQUEST_STATUS
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE r.dj_id = 'SETERA_DJ_ID'
ORDER BY rp.transaction_date DESC;
```

**Check for 60 KSH specifically:**
```sql
-- Tips
SELECT * FROM tip_payments WHERE amount = 60.00;

-- Requests
SELECT rp.*, r.status 
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE rp.amount = 60.00;
```

---

## Common Issues & Fixes

### Issue 1: Payment is for a PENDING Song Request ⚠️

**Symptom:** You see the 60 KSH in `request_payments` table, but the linked request has `status = 'PENDING'`

**Why:** Only **ACCEPTED** requests are included in earnings. Pending requests are not counted.

**Fix:** Accept the request

```sql
-- First, find the pending request
SELECT 
    r.id as REQUEST_ID,
    r.status,
    r.amount,
    r.songs_id,
    r.message,
    rp.amount as PAYMENT_AMOUNT
FROM requests r
JOIN request_payments rp ON rp.request_id = r.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- Replace with actual DJ ID
  AND r.status = 'PENDING'
ORDER BY r.created_at DESC;

-- Then accept it
UPDATE requests 
SET status = 'ACCEPTED', updated_at = CURRENT_TIMESTAMP
WHERE id = 'REQUEST_ID_FROM_ABOVE';  -- Replace with actual request ID
```

**After Fix:** Refresh the earnings tab in the app. The 60 KSH should now appear.

---

### Issue 2: M-Pesa Callback Not Received Yet ⏳

**Symptom:** You see the payment in `stk_push_sessions` with `status = 'PENDING'`

**Why:** The M-Pesa callback hasn't been received yet, so the payment hasn't been saved to `tip_payments` or `request_payments`.

**Check:**
```sql
SELECT * FROM stk_push_sessions 
WHERE amount = 60.00 
  AND status = 'PENDING'
ORDER BY created_at DESC;
```

**Fix:** 
- Wait for M-Pesa callback (usually takes 5-30 seconds)
- If it's been more than 5 minutes, the callback may have failed
- Check backend logs for callback errors
- You may need to manually create the payment record (see Issue 4)

---

### Issue 3: Payment Failed or Cancelled ❌

**Symptom:** You see the payment in `stk_push_sessions` with `status = 'FAILED'` or `result_code = 1032`

**Why:** 
- User cancelled the payment
- Payment timed out
- Insufficient funds
- Other M-Pesa error

**Check:**
```sql
SELECT 
    id,
    amount,
    status,
    result_code,
    result_description,
    failure_reason,
    created_at
FROM stk_push_sessions 
WHERE amount = 60.00 
  AND (status = 'FAILED' OR result_code != 0)
ORDER BY created_at DESC;
```

**Fix:** The payment was not completed. User needs to try again.

---

### Issue 4: STK Completed But Payment Not Saved 🔧

**Symptom:** You see the payment in `stk_push_sessions` with `status = 'COMPLETED'` and `mpesa_receipt_number`, but no corresponding record in `tip_payments` or `request_payments`.

**Why:** M-Pesa callback was received but the payment saving logic failed (database error, exception, etc.)

**Check:**
```sql
SELECT 
    s.id as SESSION_ID,
    s.amount,
    s.mpesa_receipt_number,
    s.transaction_date,
    s.status,
    d.full_name as DJ_NAME,
    CASE 
        WHEN s.dj_id IS NOT NULL THEN 'TIP'
        WHEN s.request_id IS NOT NULL THEN 'REQUEST'
        ELSE 'UNKNOWN'
    END as PAYMENT_TYPE
FROM stk_push_sessions s
LEFT JOIN users d ON s.dj_id = d.id
WHERE s.status = 'COMPLETED'
  AND s.amount = 60.00
  AND s.mpesa_receipt_number IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM tip_payments tp 
    WHERE tp.receipt_number = s.mpesa_receipt_number
  )
  AND NOT EXISTS (
    SELECT 1 FROM request_payments rp 
    WHERE rp.receipt_number = s.mpesa_receipt_number
  );
```

**Fix:** Manually create the payment record

**For Tips:**
```sql
INSERT INTO tip_payments (
    id, 
    dj_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
SELECT 
    RANDOM_UUID(),
    s.dj_id,
    s.amount,
    s.transaction_date,
    s.mpesa_receipt_number,
    COALESCE(u.full_name, 'M-Pesa User'),
    s.phone_number
FROM stk_push_sessions s
LEFT JOIN users u ON s.payer_id = u.id
WHERE s.id = 'SESSION_ID_FROM_ABOVE';  -- Replace with actual session ID
```

**For Request Payments:**
```sql
INSERT INTO request_payments (
    id, 
    request_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
SELECT 
    RANDOM_UUID(),
    s.request_id,
    s.amount,
    s.transaction_date,
    s.mpesa_receipt_number,
    COALESCE(u.full_name, 'M-Pesa User'),
    s.phone_number
FROM stk_push_sessions s
LEFT JOIN users u ON s.payer_id = u.id
WHERE s.id = 'SESSION_ID_FROM_ABOVE';  -- Replace with actual session ID
```

---

### Issue 5: Payment Linked to Wrong DJ 🔀

**Symptom:** You see the 60 KSH payment in the database, but it's linked to a different DJ

**Check:**
```sql
-- Check all 60 KSH tips
SELECT 
    tp.amount,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL,
    tp.transaction_date,
    tp.receipt_number
FROM tip_payments tp
LEFT JOIN users d ON tp.dj_id = d.id
WHERE tp.amount = 60.00;

-- Check all 60 KSH requests
SELECT 
    rp.amount,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL,
    rp.transaction_date,
    rp.receipt_number,
    r.status
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
WHERE rp.amount = 60.00;
```

**Fix:** Update the DJ ID (only if you're sure it's the wrong DJ)

```sql
-- For tips
UPDATE tip_payments
SET dj_id = 'CORRECT_DJ_ID'  -- Replace with Setera's DJ ID
WHERE id = 'PAYMENT_ID';  -- Replace with the payment ID

-- For requests
UPDATE requests
SET dj_id = 'CORRECT_DJ_ID'  -- Replace with Setera's DJ ID
WHERE id = 'REQUEST_ID';  -- Replace with the request ID
```

---

## Verification After Fix

After applying any fix, verify the earnings:

```sql
-- Replace SETERA_DJ_ID with actual DJ ID
SELECT 
    'SETERA DJ EARNINGS' as REPORT,
    d.full_name as DJ_NAME,
    (SELECT COUNT(*) FROM tip_payments WHERE dj_id = d.id) as TIP_COUNT,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = d.id) as TIPS_TOTAL,
    (SELECT COUNT(*) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'ACCEPTED') as ACCEPTED_REQUEST_COUNT,
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'ACCEPTED') as ACCEPTED_REQUESTS_TOTAL,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = d.id) +
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'ACCEPTED') as TOTAL_EARNINGS
FROM users d
WHERE d.id = 'SETERA_DJ_ID';
```

**Expected Result:**
- If it was a tip: `TIPS_TOTAL` should include 60.00
- If it was a request: `ACCEPTED_REQUESTS_TOTAL` should include 60.00
- `TOTAL_EARNINGS` should include 60.00

---

## Refresh the App

After fixing the database:
1. Open the SpinWish app
2. Login as Setera DJ
3. Go to Earnings tab
4. **Pull down to refresh**
5. The 60 KSH should now appear

---

## SQL Scripts Provided

I've created two SQL scripts to help:

1. **`check_setera_earnings.sql`**
   - Comprehensive diagnostic queries
   - Checks all possible locations for the payment
   - Shows complete earnings summary

2. **`fix_setera_earnings.sql`**
   - Ready-to-use fix queries
   - Covers all common issues
   - Includes verification queries

---

## Backend Logs

If you still can't find the issue, check the backend logs:

```bash
# In the backend directory
tail -f logs/spring-boot-application.log

# Or if running in terminal
# Look for lines containing:
# - "Saved tip payment"
# - "Saved request payment"
# - "M-Pesa callback"
# - "STK session"
```

Look for:
- ✅ "💾 Saved tip payment for DJ ID ..."
- ✅ "💾 Saved request payment for request ID ..."
- ❌ Error messages
- ⚠️ "STK session found but neither request nor DJ is set"

---

## Summary

**Most Common Issue:** Payment is for a PENDING song request

**Quick Fix:**
1. Find the request ID
2. Update status to ACCEPTED
3. Refresh the app

**If that doesn't work:**
- Use `check_setera_earnings.sql` to diagnose
- Use `fix_setera_earnings.sql` to fix
- Check backend logs for errors

