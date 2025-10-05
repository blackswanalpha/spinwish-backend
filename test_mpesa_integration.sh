#!/bin/bash

# M-Pesa Integration Test Script
# This script tests the M-Pesa Daraja integration endpoints

BASE_URL="http://localhost:8080/api/v1/payment"
CONTENT_TYPE="Content-Type: application/json"

echo "🧪 M-Pesa Integration Test Suite"
echo "================================"

# Function to test STK Push
test_stk_push() {
    local phone_number=$1
    local amount=$2
    local request_id=$3
    local description=$4
    
    echo "📱 Testing STK Push: $description"
    echo "Phone: $phone_number, Amount: $amount"
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/mpesa/stkpush" \
        -H "$CONTENT_TYPE" \
        -d "{
            \"phoneNumber\": \"$phone_number\",
            \"amount\": \"$amount\",
            \"requestId\": \"$request_id\"
        }")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    echo "HTTP Code: $http_code"
    echo "Response: $body"
    echo "---"
}

# Function to test callback
test_callback() {
    local checkout_request_id=$1
    local result_code=$2
    local description=$3
    
    echo "📞 Testing Callback: $description"
    echo "CheckoutRequestID: $checkout_request_id"
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/mpesa/callback" \
        -H "$CONTENT_TYPE" \
        -d "{
            \"Body\": {
                \"stkCallback\": {
                    \"MerchantRequestID\": \"29115-34620561-1\",
                    \"CheckoutRequestID\": \"$checkout_request_id\",
                    \"ResultCode\": $result_code,
                    \"ResultDesc\": \"Test callback\",
                    \"CallbackMetadata\": {
                        \"Item\": [
                            {\"Name\": \"Amount\", \"Value\": 100.00},
                            {\"Name\": \"MpesaReceiptNumber\", \"Value\": \"TEST123\"},
                            {\"Name\": \"TransactionDate\", \"Value\": 20231201120000},
                            {\"Name\": \"PhoneNumber\", \"Value\": 254708374149}
                        ]
                    }
                }
            }
        }")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    echo "HTTP Code: $http_code"
    echo "Response: $body"
    echo "---"
}

# Function to test status query
test_status_query() {
    local checkout_request_id=$1
    local description=$2
    
    echo "🔍 Testing Status Query: $description"
    echo "CheckoutRequestID: $checkout_request_id"
    
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/stk/query/$checkout_request_id")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    echo "HTTP Code: $http_code"
    echo "Response: $body"
    echo "---"
}

# Check if server is running
echo "🔍 Checking if server is running..."
if ! curl -s "$BASE_URL/../health" > /dev/null 2>&1; then
    echo "❌ Server is not running at $BASE_URL"
    echo "Please start the backend server first:"
    echo "cd backend && ./mvnw spring-boot:run"
    exit 1
fi

echo "✅ Server is running"
echo ""

# Test Cases
echo "🚀 Starting Test Cases..."
echo ""

# Test 1: Valid STK Push
test_stk_push "254708374149" "100" "test-$(date +%s)" "Valid phone number and amount"

# Test 2: Invalid phone number
test_stk_push "123456789" "100" "test-$(date +%s)" "Invalid phone number format"

# Test 3: Invalid amount
test_stk_push "254708374149" "0" "test-$(date +%s)" "Invalid amount (zero)"

# Test 4: Missing request ID (should work for tip payment)
echo "📱 Testing Tip Payment (no requestId)"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/mpesa/stkpush" \
    -H "$CONTENT_TYPE" \
    -d "{
        \"phoneNumber\": \"254708374149\",
        \"amount\": \"50\",
        \"djName\": \"testdj\"
    }")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

echo "HTTP Code: $http_code"
echo "Response: $body"
echo "---"

# Test 5: Success callback
test_callback "ws_CO_test_success" 0 "Successful payment callback"

# Test 6: Failed callback
test_callback "ws_CO_test_failed" 1 "Failed payment callback"

# Test 7: Status query (will likely return 404 for test data)
test_status_query "ws_CO_test_query" "Status query test"

echo "🏁 Test Suite Complete!"
echo ""
echo "📋 Summary:"
echo "- STK Push endpoints tested with various scenarios"
echo "- Callback endpoint tested with success/failure cases"
echo "- Status query endpoint tested"
echo ""
echo "💡 Next Steps:"
echo "1. Review the HTTP response codes and messages above"
echo "2. Check server logs for detailed error information"
echo "3. Test with real M-Pesa sandbox credentials if needed"
echo "4. Verify database records for successful transactions"
