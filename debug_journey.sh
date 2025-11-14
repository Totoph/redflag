#!/bin/bash

# Debug d'un journey qui a échoué
# Usage: ./debug_journey.sh [journey_id]

API_URL="${2:-http://localhost:8000}"
JOURNEY_ID="${1}"

if [ -z "$JOURNEY_ID" ]; then
    echo "Usage: ./debug_journey.sh <journey_id> [api_url]"
    echo ""
    echo "Récupérer le dernier journey_id:"
    curl -s "$API_URL/journeys?limit=1" | jq -r '.[0].journey_id'
    exit 1
fi

echo "========================================="
echo "🔍 Debug Journey: $JOURNEY_ID"
echo "========================================="
echo ""

# Récupérer les détails
DETAILS=$(curl -s "$API_URL/journey/$JOURNEY_ID")

echo "📊 Status:"
echo "$DETAILS" | jq '{
    journey_id,
    status,
    url,
    task,
    steps_completed,
    steps_total,
    error,
    duration_seconds
}'

echo ""
echo "❌ Error:"
echo "$DETAILS" | jq -r '.error // "No error message"'

echo ""
echo "📝 Actions:"
echo "$DETAILS" | jq '.actions'

echo ""
echo "========================================="
echo "💡 Vérifications:"
echo "========================================="

# Vérifier vLLM
echo ""
echo "1. vLLM Status:"
if curl -s http://localhost:8082/health > /dev/null 2>&1; then
    echo "   ✓ vLLM is responding"
else
    echo "   ✗ vLLM is NOT responding"
fi

# Vérifier API health
echo ""
echo "2. API Health:"
curl -s "$API_URL/health" | jq .

echo ""
echo "3. Logs récents (API):"
if [ -f "logs/api.log" ]; then
    echo "   Last 20 lines:"
    tail -20 logs/api.log
else
    echo "   No logs/api.log found"
fi

echo ""
echo "========================================="
