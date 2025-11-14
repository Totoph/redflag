#!/bin/bash

# Arrêter tous les services

echo "========================================="
echo "Arrêt des Services"
echo "========================================="
echo ""

# Stop API
echo "🛑 Arrêt de l'API..."
pkill -f "uvicorn api.main" && echo "  ✓ API arrêtée" || echo "  ℹ️  API n'était pas active"

# Stop vLLM
echo "🛑 Arrêt de vLLM..."
pkill -f "vllm.entrypoints" && echo "  ✓ vLLM arrêté" || echo "  ℹ️  vLLM n'était pas actif"

# Wait for processes to terminate
sleep 2

# Force kill if still running
VLLM_PROC=$(ps aux | grep "vllm.entrypoints" | grep -v grep)
if [ -n "$VLLM_PROC" ]; then
    echo "  ⚠️  Force kill vLLM..."
    pkill -9 -f "vllm.entrypoints"
fi

API_PROC=$(ps aux | grep "uvicorn api.main" | grep -v grep)
if [ -n "$API_PROC" ]; then
    echo "  ⚠️  Force kill API..."
    pkill -9 -f "uvicorn api.main"
fi

# Clean up PID files
rm -f logs/vllm.pid logs/api.pid 2>/dev/null

echo ""
echo "✅ Tous les services sont arrêtés"
echo ""
echo "Pour redémarrer: ./start_all.sh"
echo ""
