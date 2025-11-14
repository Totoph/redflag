#!/bin/bash

# Test script pour vérifier le Customer Journey API

API_URL="http://localhost:8000"

echo "========================================="
echo "Test Customer Journey API"
echo "========================================="
echo ""

# 1. Health check
echo "[1/4] Health check..."
curl -s "$API_URL/health" | jq .
echo ""

# 2. Start a journey
echo "[2/4] Démarrage d'un journey de test..."
JOURNEY_RESPONSE=$(curl -s -X POST "$API_URL/journey/start" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://demo.playwright.dev/todomvc",
    "task": "Add a new todo item, mark it as complete, then filter to show only completed items",
    "max_steps": 10,
    "screenshot_every_step": true
  }')

echo "$JOURNEY_RESPONSE" | jq .
JOURNEY_ID=$(echo "$JOURNEY_RESPONSE" | jq -r '.journey_id')
echo ""
echo "Journey ID: $JOURNEY_ID"
echo ""

# 3. Wait and check status
echo "[3/4] Attente de 5 secondes..."
sleep 5

echo "Vérification du statut..."
curl -s "$API_URL/journey/$JOURNEY_ID" | jq .
echo ""

# 4. List all journeys
echo "[4/4] Liste de tous les journeys..."
curl -s "$API_URL/journeys?limit=5" | jq .
echo ""

echo "========================================="
echo "✅ Tests terminés !"
echo "========================================="
echo ""
echo "Pour voir les screenshots:"
echo "ls -lh ./screenshots/"
echo ""
echo "Pour voir les résultats JSON:"
echo "cat ./journeys/$JOURNEY_ID.json | jq ."
echo ""
