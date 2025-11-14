#!/bin/bash

# Test automatique Alib Aroma
# Usage: ./test_alib_aroma.sh [API_URL]

API_URL="${1:-http://localhost:8000}"

echo "========================================="
echo "🌿 Test Alib Aroma Customer Journey"
echo "API: $API_URL"
echo "========================================="
echo ""

# Démarrer le journey
echo "🚀 Lancement du journey Alib Aroma..."
RESPONSE=$(curl -s -X POST "$API_URL/journey/start" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://alib-aroma.lovable.app/",
    "task": "Explore the website, navigate through different sections, browse products, and add an item to the cart",
    "max_steps": 20,
    "screenshot_every_step": true
  }')

# Vérifier si la requête a réussi
if [ $? -ne 0 ]; then
    echo "❌ Erreur: Impossible de contacter l'API"
    exit 1
fi

# Extraire le journey_id
JOURNEY_ID=$(echo "$RESPONSE" | jq -r '.journey_id')

if [ "$JOURNEY_ID" = "null" ] || [ -z "$JOURNEY_ID" ]; then
    echo "❌ Erreur: Impossible de démarrer le journey"
    echo "$RESPONSE" | jq .
    exit 1
fi

echo "✓ Journey démarré"
echo "  ID: $JOURNEY_ID"
echo "  Site: https://alib-aroma.lovable.app/"
echo ""
echo "🎨 Ouvrir le Visual Builder:"
echo "  http://localhost:8080/visual_builder.html"
echo ""

# Créer dossier pour les résultats
RESULT_DIR="results/alib_aroma_$JOURNEY_ID"
mkdir -p "$RESULT_DIR"

# Polling du statut
echo "⏳ Suivi de la progression..."
echo ""

COUNTER=0
MAX_WAIT=200

while true; do
    STATUS_RESPONSE=$(curl -s "$API_URL/journey/$JOURNEY_ID")

    CURRENT_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
    STEPS=$(echo "$STATUS_RESPONSE" | jq -r '.steps_completed')
    TOTAL=$(echo "$STATUS_RESPONSE" | jq -r '.steps_total')

    if [ "$TOTAL" -gt 0 ]; then
        PROGRESS=$((STEPS * 100 / TOTAL))
    else
        PROGRESS=0
    fi

    printf "\r  Status: %-12s | Steps: %2d/%2d | Progress: %3d%% | Time: %ds" \
           "$CURRENT_STATUS" "$STEPS" "$TOTAL" "$PROGRESS" $((COUNTER * 3))

    if [ "$CURRENT_STATUS" != "running" ]; then
        echo ""
        break
    fi

    sleep 3
    COUNTER=$((COUNTER + 1))

    if [ $COUNTER -gt $MAX_WAIT ]; then
        echo ""
        echo "⚠️  Timeout"
        break
    fi
done

echo ""
echo "========================================="
echo "📊 Résultats"
echo "========================================="
echo ""

curl -s "$API_URL/journey/$JOURNEY_ID" | jq . > "$RESULT_DIR/journey.json"

STATUS=$(jq -r '.status' "$RESULT_DIR/journey.json")
STEPS=$(jq -r '.steps_completed' "$RESULT_DIR/journey.json")
DURATION=$(jq -r '.duration_seconds // "N/A"' "$RESULT_DIR/journey.json")
ERROR=$(jq -r '.error // ""' "$RESULT_DIR/journey.json")

echo "Status: $STATUS"
echo "Steps: $STEPS"
echo "Duration: ${DURATION}s"

if [ "$STATUS" = "failed" ] && [ -n "$ERROR" ]; then
    echo ""
    echo "❌ Error: $ERROR"
fi

echo ""
echo "Actions:"
jq -r '.actions[] | "  Step \(.step): \(.action) \(.target // "")"' "$RESULT_DIR/journey.json"
echo ""

echo "📸 Downloading screenshots..."
SCREENSHOTS=$(curl -s "$API_URL/journey/$JOURNEY_ID/screenshots" 2>/dev/null | jq -r '.screenshots[]?.step' 2>/dev/null)

COUNT=0
if [ -n "$SCREENSHOTS" ]; then
    for STEP in $SCREENSHOTS; do
        curl -s "$API_URL/journey/$JOURNEY_ID/screenshot/$STEP" \
             -o "$RESULT_DIR/step_$STEP.png" 2>/dev/null
        if [ $? -eq 0 ] && [ -s "$RESULT_DIR/step_$STEP.png" ]; then
            COUNT=$((COUNT + 1))
        fi
    done
fi

echo "✓ $COUNT screenshots downloaded"
echo ""
echo "========================================="
echo "✅ Test complete!"
echo "========================================="
echo ""
echo "📁 Results: $RESULT_DIR/"
echo ""
