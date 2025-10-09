-- ============================================
-- SpinWish - Add Test Earnings Data
-- ============================================
-- This script adds test data for tips and song request payments
-- to verify the earnings system is working correctly.
--
-- INSTRUCTIONS:
-- 1. Access H2 Console: http://localhost:8080/h2-console
-- 2. Login with: jdbc:h2:mem:testdb, username: sa, password: (empty)
-- 3. Run STEP 1 to find your DJ ID
-- 4. Copy the DJ ID from the results
-- 5. Replace 'YOUR_DJ_ID_HERE' in STEP 2 and STEP 3 with your actual DJ ID
-- 6. Run STEP 2 to add test tips
-- 7. Run STEP 3 to add test song request payments
-- 8. Run STEP 4 to verify the data
-- 9. Refresh the earnings tab in the app
-- ============================================

-- ============================================
-- STEP 1: Find Your DJ User ID
-- ============================================
-- Run this query first to get your DJ's user ID
SELECT 
    id as DJ_ID,
    email_address as EMAIL,
    full_name as NAME,
    role_id as ROLE_ID
FROM users 
WHERE role_id IN (SELECT id FROM roles WHERE role_name = 'DJ')
ORDER BY created_at DESC;

-- Copy the DJ_ID from the results above and use it in the next steps


-- ============================================
-- STEP 2: Add Test Tips
-- ============================================
-- Replace 'YOUR_DJ_ID_HERE' with the actual DJ ID from STEP 1

-- Tip 1: KES 500.00
INSERT INTO tip_payments (
    id, 
    dj_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    500.00, 
    CURRENT_TIMESTAMP, 
    CONCAT('TIP', CAST(RAND() * 1000000 AS INT)), 
    'Test Fan 1', 
    '254712345678'
);

-- Tip 2: KES 300.00
INSERT INTO tip_payments (
    id, 
    dj_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    300.00, 
    CURRENT_TIMESTAMP, 
    CONCAT('TIP', CAST(RAND() * 1000000 AS INT)), 
    'Test Fan 2', 
    '254712345679'
);

-- Tip 3: KES 200.00
INSERT INTO tip_payments (
    id, 
    dj_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    200.00, 
    CURRENT_TIMESTAMP, 
    CONCAT('TIP', CAST(RAND() * 1000000 AS INT)), 
    'Test Fan 3', 
    '254712345680'
);

-- Tip 4: KES 150.00
INSERT INTO tip_payments (
    id, 
    dj_id, 
    amount, 
    transaction_date, 
    receipt_number, 
    payer_name, 
    phone_number
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    150.00, 
    CURRENT_TIMESTAMP, 
    CONCAT('TIP', CAST(RAND() * 1000000 AS INT)), 
    'Test Fan 4', 
    '254712345681'
);


-- ============================================
-- STEP 3: Add Test Song Request Payments
-- ============================================
-- Replace 'YOUR_DJ_ID_HERE' with the actual DJ ID from STEP 1

-- First, create test song requests with ACCEPTED status
-- Request 1: KES 250.00
INSERT INTO requests (
    id, 
    dj_id, 
    status, 
    amount, 
    songs_id,
    message,
    created_at, 
    updated_at
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    'ACCEPTED', 
    250.00,
    'test-song-1',
    'Test song request 1',
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
);

-- Get the request ID we just created (for the payment)
-- Note: In H2, we'll use a subquery to link the payment

-- Payment for Request 1
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
    r.id,
    250.00,
    CURRENT_TIMESTAMP,
    CONCAT('REQ', CAST(RAND() * 1000000 AS INT)),
    'Test Fan 5',
    '254712345682'
FROM requests r
WHERE r.dj_id = 'YOUR_DJ_ID_HERE'  -- ⚠️ REPLACE THIS
  AND r.status = 'ACCEPTED'
  AND r.amount = 250.00
ORDER BY r.created_at DESC
LIMIT 1;

-- Request 2: KES 180.00
INSERT INTO requests (
    id, 
    dj_id, 
    status, 
    amount, 
    songs_id,
    message,
    created_at, 
    updated_at
)
VALUES (
    RANDOM_UUID(), 
    'YOUR_DJ_ID_HERE',  -- ⚠️ REPLACE THIS
    'ACCEPTED', 
    180.00,
    'test-song-2',
    'Test song request 2',
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
);

-- Payment for Request 2
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
    r.id,
    180.00,
    CURRENT_TIMESTAMP,
    CONCAT('REQ', CAST(RAND() * 1000000 AS INT)),
    'Test Fan 6',
    '254712345683'
FROM requests r
WHERE r.dj_id = 'YOUR_DJ_ID_HERE'  -- ⚠️ REPLACE THIS
  AND r.status = 'ACCEPTED'
  AND r.amount = 180.00
ORDER BY r.created_at DESC
LIMIT 1;


-- ============================================
-- STEP 4: Verify the Data
-- ============================================
-- Run these queries to verify the data was inserted correctly

-- Check tips
SELECT 
    'TIPS' as TYPE,
    COUNT(*) as COUNT,
    SUM(amount) as TOTAL_AMOUNT
FROM tip_payments 
WHERE dj_id = 'YOUR_DJ_ID_HERE';  -- ⚠️ REPLACE THIS

-- Check request payments
SELECT 
    'REQUESTS' as TYPE,
    COUNT(*) as COUNT,
    SUM(rp.amount) as TOTAL_AMOUNT
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE r.dj_id = 'YOUR_DJ_ID_HERE'  -- ⚠️ REPLACE THIS
  AND r.status = 'ACCEPTED';

-- Check total earnings
SELECT 
    'TOTAL EARNINGS' as TYPE,
    (SELECT COALESCE(SUM(amount), 0) FROM tip_payments WHERE dj_id = 'YOUR_DJ_ID_HERE') +
    (SELECT COALESCE(SUM(rp.amount), 0) FROM request_payments rp 
     JOIN requests r ON rp.request_id = r.id 
     WHERE r.dj_id = 'YOUR_DJ_ID_HERE' AND r.status = 'ACCEPTED') as TOTAL_AMOUNT;

-- View all tips for the DJ
SELECT 
    id,
    amount,
    payer_name,
    phone_number,
    transaction_date,
    receipt_number
FROM tip_payments 
WHERE dj_id = 'YOUR_DJ_ID_HERE'  -- ⚠️ REPLACE THIS
ORDER BY transaction_date DESC;

-- View all accepted request payments for the DJ
SELECT 
    rp.id,
    rp.amount,
    rp.payer_name,
    rp.phone_number,
    rp.transaction_date,
    rp.receipt_number,
    r.status as request_status
FROM request_payments rp
JOIN requests r ON rp.request_id = r.id
WHERE r.dj_id = 'YOUR_DJ_ID_HERE'  -- ⚠️ REPLACE THIS
ORDER BY rp.transaction_date DESC;


-- ============================================
-- EXPECTED RESULTS
-- ============================================
-- After running this script, you should see:
--
-- Tips Total: KES 1,150.00
--   - Tip 1: KES 500.00
--   - Tip 2: KES 300.00
--   - Tip 3: KES 200.00
--   - Tip 4: KES 150.00
--
-- Song Requests Total: KES 430.00
--   - Request 1: KES 250.00
--   - Request 2: KES 180.00
--
-- TOTAL EARNINGS: KES 1,580.00
--
-- In the app, refresh the earnings tab and you should see:
-- - Total Earnings: KES 1,580.00
-- - Tips: KES 1,150.00
-- - Song Requests: KES 430.00
-- - Available for Payout: KES 1,580.00
-- ============================================


-- ============================================
-- CLEANUP (Optional)
-- ============================================
-- If you want to remove the test data, run these queries:

-- DELETE FROM request_payments 
-- WHERE request_id IN (
--     SELECT id FROM requests 
--     WHERE dj_id = 'YOUR_DJ_ID_HERE' 
--     AND songs_id LIKE 'test-song-%'
-- );

-- DELETE FROM requests 
-- WHERE dj_id = 'YOUR_DJ_ID_HERE' 
-- AND songs_id LIKE 'test-song-%';

-- DELETE FROM tip_payments 
-- WHERE dj_id = 'YOUR_DJ_ID_HERE' 
-- AND payer_name LIKE 'Test Fan%';

