-- ============================================
-- Fix Setera DJ Earnings - 60 KSH Payment
-- ============================================
-- This script helps fix common issues that prevent earnings from showing
-- ============================================

-- ============================================
-- DIAGNOSTIC: Run this first to understand the issue
-- ============================================

-- Find Setera DJ
SELECT 
    id as DJ_ID,
    email_address,
    full_name,
    username
FROM users 
WHERE LOWER(full_name) LIKE '%setera%' 
   OR LOWER(username) LIKE '%setera%'
   OR LOWER(email_address) LIKE '%setera%';

-- Check for 60 KSH payments
SELECT 
    'TIPS - 60 KSH' as TYPE,
    tp.*,
    d.full_name as DJ_NAME
FROM tip_payments tp
LEFT JOIN users d ON tp.dj_id = d.id
WHERE tp.amount = 60.00;

SELECT 
    'REQUESTS - 60 KSH' as TYPE,
    rp.*,
    r.status as REQUEST_STATUS,
    d.full_name as DJ_NAME
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
WHERE rp.amount = 60.00;

-- Check STK sessions for 60 KSH
SELECT 
    'STK SESSIONS - 60 KSH' as TYPE,
    s.*,
    d.full_name as DJ_NAME
FROM stk_push_sessions s
LEFT JOIN users d ON s.dj_id = d.id
WHERE s.amount = 60.00
ORDER BY s.created_at DESC;


-- ============================================
-- FIX 1: If payment is for a PENDING request
-- ============================================
-- This accepts all pending requests for Setera DJ
-- Replace 'SETERA_DJ_ID' with actual DJ ID

-- First, check which requests are pending
SELECT 
    r.id as REQUEST_ID,
    r.status,
    r.amount,
    rp.amount as PAYMENT_AMOUNT,
    r.created_at,
    d.full_name as DJ_NAME
FROM requests r
LEFT JOIN request_payments rp ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
  AND r.status = 'PENDING'
  AND rp.id IS NOT NULL  -- Has payment
ORDER BY r.created_at DESC;

-- Accept the pending requests (this will include them in earnings)
-- UNCOMMENT THE LINES BELOW AFTER VERIFYING THE REQUESTS ABOVE

-- UPDATE requests 
-- SET status = 'ACCEPTED', updated_at = CURRENT_TIMESTAMP
-- WHERE dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
--   AND status = 'PENDING'
--   AND id IN (
--     SELECT r.id FROM requests r
--     JOIN request_payments rp ON rp.request_id = r.id
--     WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
--   );


-- ============================================
-- FIX 2: If payment exists but not linked to DJ
-- ============================================
-- Check if there's a 60 KSH tip not linked to any DJ
SELECT 
    'ORPHANED TIPS' as TYPE,
    tp.*
FROM tip_payments tp
WHERE tp.dj_id IS NULL
  AND tp.amount = 60.00;

-- If found, link it to Setera DJ
-- UNCOMMENT AFTER VERIFYING

-- UPDATE tip_payments
-- SET dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
-- WHERE dj_id IS NULL
--   AND amount = 60.00;


-- ============================================
-- FIX 3: If STK session completed but payment not saved
-- ============================================
-- Check for completed STK sessions without corresponding payments
SELECT 
    'COMPLETED STK WITHOUT PAYMENT' as TYPE,
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

-- If found, manually create the payment record
-- For TIPS:
-- UNCOMMENT AND FILL IN THE VALUES AFTER VERIFYING

-- INSERT INTO tip_payments (
--     id, 
--     dj_id, 
--     amount, 
--     transaction_date, 
--     receipt_number, 
--     payer_name, 
--     phone_number
-- )
-- SELECT 
--     RANDOM_UUID(),
--     s.dj_id,
--     s.amount,
--     s.transaction_date,
--     s.mpesa_receipt_number,
--     COALESCE(u.full_name, 'M-Pesa User'),
--     s.phone_number
-- FROM stk_push_sessions s
-- LEFT JOIN users u ON s.payer_id = u.id
-- WHERE s.id = 'STK_SESSION_ID';  -- ⚠️ REPLACE WITH SESSION ID FROM ABOVE

-- For REQUEST PAYMENTS:
-- UNCOMMENT AND FILL IN THE VALUES AFTER VERIFYING

-- INSERT INTO request_payments (
--     id, 
--     request_id, 
--     amount, 
--     transaction_date, 
--     receipt_number, 
--     payer_name, 
--     phone_number
-- )
-- SELECT 
--     RANDOM_UUID(),
--     s.request_id,
--     s.amount,
--     s.transaction_date,
--     s.mpesa_receipt_number,
--     COALESCE(u.full_name, 'M-Pesa User'),
--     s.phone_number
-- FROM stk_push_sessions s
-- LEFT JOIN users u ON s.payer_id = u.id
-- WHERE s.id = 'STK_SESSION_ID';  -- ⚠️ REPLACE WITH SESSION ID FROM ABOVE


-- ============================================
-- VERIFICATION: Run after applying fixes
-- ============================================
-- Check Setera DJ earnings again
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
WHERE d.id = 'SETERA_DJ_ID';  -- ⚠️ REPLACE THIS


-- ============================================
-- INSTRUCTIONS
-- ============================================
-- 1. Run the DIAGNOSTIC queries first
-- 2. Identify which issue applies:
--    - Payment for PENDING request → Use FIX 1
--    - Payment not linked to DJ → Use FIX 2
--    - STK completed but payment not saved → Use FIX 3
-- 3. Uncomment the appropriate fix
-- 4. Replace 'SETERA_DJ_ID' with actual DJ ID
-- 5. Run the fix
-- 6. Run VERIFICATION to confirm
-- 7. Refresh the earnings tab in the app
-- ============================================

