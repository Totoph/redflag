#!/bin/bash

# Servir le Visual Builder
# Usage: ./serve_visual_builder.sh [PORT]

PORT="${1:-8080}"

echo "========================================="
echo "🎨 Customer Journey Visual Builder"
echo "========================================="
echo ""
echo "Démarrage du serveur sur le port $PORT..."
echo ""
echo "Accéder à:"
echo "  - Local: http://localhost:$PORT"
echo ""

# Vérifier si Python est installé
if command -v python3 &> /dev/null; then
    echo "Utilisation de Python HTTP server..."
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    echo "Utilisation de Python HTTP server..."
    python -m http.server $PORT
else
    echo "❌ Python non trouvé"
    exit 1
fi
