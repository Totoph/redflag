#!/bin/bash

# Arrêter TOUS les services

echo "========================================="
echo "🛑 Arrêt de Tous les Services"
echo "========================================="
echo ""

# Stop Visual Builder
echo "🎨 Arrêt Visual Builder..."
pkill -f "python.*http.server.*8080" && echo "  ✓ Visual Builder arrêté" || echo "  ℹ️  Pas actif"

# Stop API
echo "⚡ Arrêt API..."
pkill -f "uvicorn api.main" && echo "  ✓ API arrêtée" || echo "  ℹ️  Pas active"

# Stop vLLM
echo "🤖 Arrêt vLLM..."
pkill -f "vllm.entrypoints" && echo "  ✓ vLLM arrêté" || echo "  ℹ️  Pas actif"

# Wait
sleep 2

# Force kill si nécessaire
echo ""
echo "🔍 Vérification..."

if ps aux | grep -E "vllm|uvicorn|http.server.*8080" | grep -v grep > /dev/null; then
    echo "  ⚠️  Processus restants détectés, force kill..."
    pkill -9 -f "vllm.entrypoints"
    pkill -9 -f "uvicorn api.main"
    pkill -9 -f "python.*http.server.*8080"
    sleep 1
fi

# Clean up PIDs
rm -f logs/*.pid 2>/dev/null

echo ""
echo "✅ Tous les services sont arrêtés"
echo ""
echo "Pour redémarrer: ./start_everything.sh"
echo ""
