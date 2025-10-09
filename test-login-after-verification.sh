#!/bin/bash
# Test login after verification

BASE_URL="http://localhost:8080/api/v1"
TEST_EMAIL="testuser1759825097@example.com"
TEST_PASSWORD="Test123!@#"

echo "Testing login for: $TEST_EMAIL"
echo ""

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{
      "emailAddress": "'$TEST_EMAIL'",
      "password": "'$TEST_PASSWORD'"
    }' \
    "${BASE_URL}/users/login")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "200" ]; then
    echo "✓ Login successful!"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
else
    echo "✗ Login failed ($http_code)"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
fi
