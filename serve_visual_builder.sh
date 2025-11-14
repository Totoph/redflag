#!/bin/bash

# Servir le Visual Builder
# Usage: ./serve_visual_builder.sh [PORT]

PORT="${1:-8080}"

echo "========================================="
echo "🎨 Customer Journey Visual Builder"
echo "========================================="
echo ""

# Vérifier si le port est déjà utilisé
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Port $PORT déjà utilisé"
    echo "Arrêt du processus existant..."
    PID=$(lsof -ti :$PORT)
    kill -9 $PID 2>/dev/null
    sleep 1
fi

echo "Démarrage du serveur sur le port $PORT..."
echo ""
echo "Accéder à:"
echo "  - Local: http://localhost:$PORT"
echo "  - Remote: http://$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_IP"):$PORT"
echo ""
echo "Ouvrir le Visual Builder:"
echo "  http://localhost:$PORT/visual_builder.html"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Vérifier si Python est installé
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT --bind 0.0.0.0
elif command -v python &> /dev/null; then
    python -m http.server $PORT
else
    echo "❌ Python non trouvé"
    exit 1
fi
