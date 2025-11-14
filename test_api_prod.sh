#!/bin/bash

# Test complet de l'API en production
# Usage: ./test_api_prod.sh http://your-vast-instance:8000

API_URL="${1:-http://localhost:8000}"

echo "========================================="
echo "Test API Customer Journey"
echo "Base URL: $API_URL"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4

    echo -e "${BLUE}[TEST]${NC} $name"

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$API_URL$endpoint")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL$endpoint")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
        echo "$body"
    fi
    echo ""
}

# 1. Test root
test_endpoint "Root endpoint" "GET" "/"

# 2. Test health
test_endpoint "Health check" "GET" "/health"

# 3. Test stats (avant journey)
test_endpoint "Stats (initial)" "GET" "/stats"

# 4. Start a journey
echo -e "${BLUE}[TEST]${NC} Start journey"
response=$(curl -s -X POST "$API_URL/journey/start" \
    -H "Content-Type: application/json" \
    -d '{
        "url": "https://aroma-zone.com",
        "task": "Add 1 article to the cart and go to the checkout",
        "max_steps": 10,
        "screenshot_every_step": true
    }')

echo "$response" | jq '.'
JOURNEY_ID=$(echo "$response" | jq -r '.journey_id')
echo -e "Journey ID: ${GREEN}$JOURNEY_ID${NC}"
echo ""

if [ "$JOURNEY_ID" = "null" ] || [ -z "$JOURNEY_ID" ]; then
    echo -e "${RED}✗ Failed to create journey${NC}"
    exit 1
fi

# 5. Get journey status
sleep 2
test_endpoint "Get journey status" "GET" "/journey/$JOURNEY_ID"

# 6. List all journeys
test_endpoint "List all journeys" "GET" "/journeys?limit=5"

# 7. List filtered journeys
test_endpoint "List running journeys" "GET" "/journeys?status=running"

# 8. Wait for journey to progress
echo -e "${BLUE}[INFO]${NC} Waiting 10 seconds for journey to progress..."
sleep 10

# 9. Get updated status
test_endpoint "Get updated status" "GET" "/journey/$JOURNEY_ID"

# 10. List screenshots
test_endpoint "List screenshots" "GET" "/journey/$JOURNEY_ID/screenshots"

# 11. Get specific screenshot (if exists)
echo -e "${BLUE}[TEST]${NC} Get screenshot step 0"
curl -s "$API_URL/journey/$JOURNEY_ID/screenshot/0" -o "/tmp/test_screenshot.png"
if [ -f "/tmp/test_screenshot.png" ]; then
    size=$(stat -f%z "/tmp/test_screenshot.png" 2>/dev/null || stat -c%s "/tmp/test_screenshot.png" 2>/dev/null)
    if [ "$size" -gt 0 ]; then
        echo -e "${GREEN}✓ PASS${NC} Screenshot downloaded ($size bytes)"
    else
        echo -e "${RED}✗ FAIL${NC} Screenshot empty"
    fi
else
    echo -e "${RED}✗ FAIL${NC} Screenshot not found"
fi
echo ""

# 12. Get screenshot as base64
test_endpoint "Get screenshot as base64" "GET" "/journey/$JOURNEY_ID/screenshot/0?as_base64=true"

# 13. Get stats (after journey)
test_endpoint "Stats (after journey)" "GET" "/stats"

# 14. Cancel journey (if still running)
echo -e "${BLUE}[TEST]${NC} Cancel journey (if running)"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/journey/$JOURNEY_ID/cancel")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 400 ]; then
    echo -e "${GREEN}✓ Expected${NC} (HTTP $http_code)"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Unexpected${NC} (HTTP $http_code)"
fi
echo ""

# 15. Final status
test_endpoint "Final journey status" "GET" "/journey/$JOURNEY_ID"

# 16. Delete journey (optional - uncomment to test)
# test_endpoint "Delete journey" "DELETE" "/journey/$JOURNEY_ID"

echo "========================================="
echo -e "${GREEN}Tests terminés !${NC}"
echo "========================================="
echo ""
echo "Journey ID créé: $JOURNEY_ID"
echo ""
echo "Pour voir les détails:"
echo "  curl $API_URL/journey/$JOURNEY_ID | jq ."
echo ""
echo "Pour voir les screenshots:"
echo "  curl $API_URL/journey/$JOURNEY_ID/screenshots | jq ."
echo ""
echo "Pour supprimer:"
echo "  curl -X DELETE $API_URL/journey/$JOURNEY_ID"
echo ""
