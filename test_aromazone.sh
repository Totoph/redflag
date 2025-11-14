#!/bin/bash

# Test automatique Aroma Zone
# Usage: ./test_aromazone.sh [API_URL]

API_URL="${1:-http://localhost:8000}"

echo "========================================="
echo "🛒 Test Aroma Zone Customer Journey"
echo "API: $API_URL"
echo "========================================="
echo ""

# Démarrer le journey
echo "🚀 Lancement du journey Aroma Zone..."
RESPONSE=$(curl -s -X POST "$API_URL/journey/start" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.aroma-zone.com",
    "task": "Navigate to products section, browse items, select one product, add it to cart, and proceed to checkout page",
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
echo ""

# Créer dossier pour les résultats
RESULT_DIR="results/aroma_zone_$JOURNEY_ID"
mkdir -p "$RESULT_DIR"

# Polling du statut
echo "⏳ Suivi de la progression..."
echo ""

COUNTER=0
while true; do
    # Récupérer le statut
    STATUS_RESPONSE=$(curl -s "$API_URL/journey/$JOURNEY_ID")

    CURRENT_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
    STEPS=$(echo "$STATUS_RESPONSE" | jq -r '.steps_completed')
    TOTAL=$(echo "$STATUS_RESPONSE" | jq -r '.steps_total')

    # Afficher la progression
    PROGRESS=$((STEPS * 100 / TOTAL))
    printf "\r  Status: %-12s | Steps: %2d/%2d | Progress: %3d%%" \
           "$CURRENT_STATUS" "$STEPS" "$TOTAL" "$PROGRESS"

    # Vérifier si terminé
    if [ "$CURRENT_STATUS" != "running" ]; then
        echo ""
        break
    fi

    sleep 3
    COUNTER=$((COUNTER + 1))

    # Timeout après 5 minutes
    if [ $COUNTER -gt 100 ]; then
        echo ""
        echo "⚠️  Timeout après 5 minutes"
        break
    fi
done

echo ""
echo "========================================="
echo "📊 Résultats"
echo "========================================="
echo ""

# Sauvegarder le résultat complet
curl -s "$API_URL/journey/$JOURNEY_ID" | jq . > "$RESULT_DIR/journey.json"

# Afficher le résumé
echo "Status final: $(jq -r '.status' "$RESULT_DIR/journey.json")"
echo "Steps complétés: $(jq -r '.steps_completed' "$RESULT_DIR/journey.json")"
echo "Durée: $(jq -r '.duration_seconds // "N/A"' "$RESULT_DIR/journey.json")s"
echo ""

# Afficher les actions effectuées
echo "Actions effectuées:"
jq -r '.actions[] | "  Step \(.step): \(.action) \(.target // "")"' "$RESULT_DIR/journey.json"
echo ""

# Télécharger les screenshots
echo "📸 Téléchargement des screenshots..."
SCREENSHOTS=$(curl -s "$API_URL/journey/$JOURNEY_ID/screenshots" | jq -r '.screenshots[].step')

COUNT=0
for STEP in $SCREENSHOTS; do
    curl -s "$API_URL/journey/$JOURNEY_ID/screenshot/$STEP" \
         -o "$RESULT_DIR/step_$STEP.png" 2>/dev/null
    if [ $? -eq 0 ]; then
        COUNT=$((COUNT + 1))
    fi
done

echo "✓ $COUNT screenshots téléchargés"
echo ""

# Résumé final
echo "========================================="
echo "✅ Test terminé !"
echo "========================================="
echo ""
echo "Résultats sauvegardés dans: $RESULT_DIR/"
echo "  - journey.json      : Détails complets"
echo "  - step_*.png        : Screenshots"
echo ""
echo "Voir le JSON:"
echo "  cat $RESULT_DIR/journey.json | jq ."
echo ""
echo "Voir les images:"
echo "  open $RESULT_DIR/"
echo ""
