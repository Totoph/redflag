#!/bin/bash

# Quick Start - API avec Visual Builder intégré

echo "🚀 Démarrage Rapide"
echo ""

cd /workspace/redflag

# Kill processus
pkill -f "uvicorn api.main" 2>/dev/null
sleep 2

# Démarrer API
echo "⚡ Démarrage API avec Visual Builder..."
nohup uvicorn api.main:app --host 0.0.0.0 --port 8000 > logs/api.log 2>&1 &

sleep 3

# Test
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_IP")

    echo ""
    echo "✅ API démarrée !"
    echo ""
    echo "🌐 Accès:"
    echo "  📺 Visual Builder: http://$PUBLIC_IP:8000/ui"
    echo "  📡 API:            http://$PUBLIC_IP:8000"
    echo "  📖 Docs:           http://$PUBLIC_IP:8000/docs"
    echo ""
else
    echo "❌ Erreur: API ne répond pas"
    echo "Voir les logs: tail -f logs/api.log"
fi
