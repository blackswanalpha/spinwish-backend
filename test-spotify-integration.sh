#!/bin/bash

# Test script for Spotify Integration
# This script tests the Spotify API endpoints

BASE_URL="http://localhost:8080/api/v1"

echo "=========================================="
echo "Spotify Integration Test Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Spotify Health Check${NC}"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/spotify/health")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "Health check passed"
    echo "$body" | jq '.'
else
    print_result 1 "Health check failed (HTTP $http_code)"
    echo "$body"
fi
echo ""

# Test 2: Get Statistics
echo -e "${YELLOW}Test 2: Get Spotify Statistics${NC}"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/spotify/stats")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "Statistics retrieved"
    echo "$body" | jq '.'
else
    print_result 1 "Failed to get statistics (HTTP $http_code)"
    echo "$body"
fi
echo ""

# Test 3: Trigger Manual Sync
echo -e "${YELLOW}Test 3: Trigger Manual Sync${NC}"
echo "This will start the Spotify sync in the background..."
response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/spotify/sync")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ]; then
    print_result 0 "Sync triggered successfully"
    echo "$body" | jq '.'
else
    print_result 1 "Failed to trigger sync (HTTP $http_code)"
    echo "$body"
fi
echo ""

# Test 4: Wait and check songs
echo -e "${YELLOW}Test 4: Check Songs Endpoint${NC}"
echo "Waiting 10 seconds for some songs to be fetched..."
sleep 10

response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/songs")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ]; then
    song_count=$(echo "$body" | jq '. | length')
    spotify_songs=$(echo "$body" | jq '[.[] | select(.spotifyUrl != null)] | length')
    
    print_result 0 "Songs endpoint accessible"
    echo "Total songs: $song_count"
    echo "Songs from Spotify: $spotify_songs"
    
    if [ "$spotify_songs" -gt 0 ]; then
        echo ""
        echo "Sample Spotify song:"
        echo "$body" | jq '[.[] | select(.spotifyUrl != null)] | .[0]'
    fi
else
    print_result 1 "Failed to get songs (HTTP $http_code)"
    echo "$body"
fi
echo ""

# Test 5: Check Artists
echo -e "${YELLOW}Test 5: Check Artists Endpoint${NC}"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/artists")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ]; then
    artist_count=$(echo "$body" | jq '. | length')
    
    print_result 0 "Artists endpoint accessible"
    echo "Total artists: $artist_count"
    
    if [ "$artist_count" -gt 0 ]; then
        echo ""
        echo "Sample artist:"
        echo "$body" | jq '.[0]'
    fi
else
    print_result 1 "Failed to get artists (HTTP $http_code)"
    echo "$body"
fi
echo ""

# Final Statistics
echo -e "${YELLOW}Final Statistics Check${NC}"
response=$(curl -s "${BASE_URL}/spotify/stats")
echo "$response" | jq '.'
echo ""

echo "=========================================="
echo "Test Complete!"
echo "=========================================="
echo ""
echo "Note: The sync process runs in the background."
echo "Check the application logs for detailed progress."
echo "Run this script again after a few minutes to see more results."

