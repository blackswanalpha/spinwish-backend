-- ============================================
-- Check Setera DJ Earnings - Diagnostic Script
-- ============================================
-- This script helps diagnose why the 60 KSH payment is not showing
-- in the earnings for Setera DJ
-- ============================================

-- ============================================
-- STEP 1: Find Setera DJ User
-- ============================================
SELECT 
    id as DJ_ID,
    email_address as EMAIL,
    full_name as NAME,
    username as USERNAME,
    role_id as ROLE_ID
FROM users 
WHERE LOWER(full_name) LIKE '%setera%' 
   OR LOWER(username) LIKE '%setera%'
   OR LOWER(email_address) LIKE '%setera%';

-- Alternative: Find all DJs
SELECT 
    id as DJ_ID,
    email_address as EMAIL,
    full_name as NAME,
    username as USERNAME
FROM users 
WHERE role_id IN (SELECT id FROM roles WHERE role_name = 'DJ')
ORDER BY created_at DESC;


-- ============================================
-- STEP 2: Check All Tips for Setera DJ
-- ============================================
-- Replace 'SETERA_DJ_ID' with the actual ID from STEP 1

SELECT 
    'TIP PAYMENTS' as TYPE,
    tp.id,
    tp.amount,
    tp.payer_name,
    tp.phone_number,
    tp.transaction_date,
    tp.receipt_number,
    tp.dj_id,
    d.full_name as DJ_NAME
FROM tip_payments tp
LEFT JOIN users d ON tp.dj_id = d.id
WHERE tp.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
ORDER BY tp.transaction_date DESC;

-- Check ALL tips (if you don't know the DJ ID yet)
SELECT 
    'ALL TIPS' as TYPE,
    tp.id,
    tp.amount,
    tp.payer_name,
    tp.phone_number,
    tp.transaction_date,
    tp.receipt_number,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL
FROM tip_payments tp
LEFT JOIN users d ON tp.dj_id = d.id
ORDER BY tp.transaction_date DESC
LIMIT 20;


-- ============================================
-- STEP 3: Check All Request Payments for Setera DJ
-- ============================================
SELECT 
    'REQUEST PAYMENTS' as TYPE,
    rp.id,
    rp.amount,
    rp.payer_name,
    rp.phone_number,
    rp.transaction_date,
    rp.receipt_number,
    r.status as REQUEST_STATUS,
    r.dj_id,
    d.full_name as DJ_NAME
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
ORDER BY rp.transaction_date DESC;

-- Check ALL request payments (if you don't know the DJ ID yet)
SELECT 
    'ALL REQUEST PAYMENTS' as TYPE,
    rp.id,
    rp.amount,
    rp.payer_name,
    rp.phone_number,
    rp.transaction_date,
    rp.receipt_number,
    r.status as REQUEST_STATUS,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
ORDER BY rp.transaction_date DESC
LIMIT 20;


-- ============================================
-- STEP 4: Check for 60 KSH Payment Specifically
-- ============================================
-- Check tips for 60 KSH
SELECT 
    '60 KSH TIPS' as TYPE,
    tp.id,
    tp.amount,
    tp.payer_name,
    tp.phone_number,
    tp.transaction_date,
    tp.receipt_number,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL
FROM tip_payments tp
LEFT JOIN users d ON tp.dj_id = d.id
WHERE tp.amount = 60.00
ORDER BY tp.transaction_date DESC;

-- Check request payments for 60 KSH
SELECT 
    '60 KSH REQUESTS' as TYPE,
    rp.id,
    rp.amount,
    rp.payer_name,
    rp.phone_number,
    rp.transaction_date,
    rp.receipt_number,
    r.status as REQUEST_STATUS,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
LEFT JOIN users d ON r.dj_id = d.id
WHERE rp.amount = 60.00
ORDER BY rp.transaction_date DESC;


-- ============================================
-- STEP 5: Check STK Push Sessions
-- ============================================
-- Check if the payment was initiated but not completed
SELECT 
    'STK SESSIONS - 60 KSH' as TYPE,
    s.id,
    s.checkout_request_id,
    s.amount,
    s.phone_number,
    s.status,
    s.result_code,
    s.result_description,
    s.mpesa_receipt_number,
    s.transaction_date,
    s.created_at,
    d.full_name as DJ_NAME,
    r.id as REQUEST_ID,
    r.status as REQUEST_STATUS
FROM stk_push_sessions s
LEFT JOIN users d ON s.dj_id = d.id
LEFT JOIN requests r ON s.request_id = r.id
WHERE s.amount = 60.00
ORDER BY s.created_at DESC;

-- Check recent STK sessions for Setera DJ
SELECT 
    'RECENT STK SESSIONS' as TYPE,
    s.id,
    s.checkout_request_id,
    s.amount,
    s.phone_number,
    s.status,
    s.result_code,
    s.mpesa_receipt_number,
    s.transaction_date,
    s.created_at,
    d.full_name as DJ_NAME
FROM stk_push_sessions s
LEFT JOIN users d ON s.dj_id = d.id
WHERE s.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
ORDER BY s.created_at DESC
LIMIT 10;


-- ============================================
-- STEP 6: Calculate Total Earnings for Setera DJ
-- ============================================
-- Tips total
SELECT 
    'TIPS TOTAL' as TYPE,
    COUNT(*) as COUNT,
    COALESCE(SUM(amount), 0) as TOTAL_AMOUNT
FROM tip_payments 
WHERE dj_id = 'SETERA_DJ_ID';  -- ⚠️ REPLACE THIS

-- Request payments total (ACCEPTED only)
SELECT 
    'ACCEPTED REQUESTS TOTAL' as TYPE,
    COUNT(*) as COUNT,
    COALESCE(SUM(rp.amount), 0) as TOTAL_AMOUNT
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
  AND r.status = 'ACCEPTED';

-- Request payments total (ALL statuses)
SELECT 
    'ALL REQUESTS TOTAL' as TYPE,
    r.status,
    COUNT(*) as COUNT,
    COALESCE(SUM(rp.amount), 0) as TOTAL_AMOUNT
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
GROUP BY r.status;

-- Grand total
SELECT 
    'GRAND TOTAL EARNINGS' as TYPE,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = 'SETERA_DJ_ID') +
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp 
     JOIN requests r ON rp.request_id = r.id 
     WHERE r.dj_id = 'SETERA_DJ_ID' AND r.status = 'ACCEPTED') as TOTAL_AMOUNT;


-- ============================================
-- STEP 7: Check Recent Requests for Setera DJ
-- ============================================
SELECT 
    'RECENT REQUESTS' as TYPE,
    r.id,
    r.status,
    r.amount,
    r.songs_id,
    r.message,
    r.created_at,
    r.updated_at,
    d.full_name as DJ_NAME,
    c.full_name as CLIENT_NAME
FROM requests r
LEFT JOIN users d ON r.dj_id = d.id
LEFT JOIN users c ON r.client_id = c.id
WHERE r.dj_id = 'SETERA_DJ_ID'  -- ⚠️ REPLACE THIS
ORDER BY r.created_at DESC
LIMIT 10;


-- ============================================
-- STEP 8: Diagnostic Summary
-- ============================================
-- This query shows a complete summary
SELECT 
    'DIAGNOSTIC SUMMARY' as REPORT,
    d.full_name as DJ_NAME,
    d.email_address as DJ_EMAIL,
    (SELECT COUNT(*) FROM tip_payments WHERE dj_id = d.id) as TIP_COUNT,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = d.id) as TIPS_TOTAL,
    (SELECT COUNT(*) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id) as REQUEST_PAYMENT_COUNT,
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'ACCEPTED') as ACCEPTED_REQUESTS_TOTAL,
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'PENDING') as PENDING_REQUESTS_TOTAL,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = d.id) +
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp JOIN requests r ON rp.request_id = r.id WHERE r.dj_id = d.id AND r.status = 'ACCEPTED') as TOTAL_EARNINGS
FROM users d
WHERE d.id = 'SETERA_DJ_ID';  -- ⚠️ REPLACE THIS


-- ============================================
-- POSSIBLE ISSUES TO CHECK
-- ============================================
-- 1. Payment was initiated but M-Pesa callback failed
--    → Check STK sessions with status = 'PENDING' or 'FAILED'
--
-- 2. Payment was for a song request but request is still PENDING
--    → Check requests with status = 'PENDING' (not included in earnings)
--
-- 3. Payment was saved but linked to wrong DJ
--    → Check all 60 KSH payments to see which DJ they're linked to
--
-- 4. Payment was cancelled by user
--    → Check STK sessions with result_code = 1032
--
-- 5. M-Pesa callback not received yet
--    → Check STK sessions with status = 'PENDING'
-- ============================================

