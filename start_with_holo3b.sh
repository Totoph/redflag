#!/bin/bash

# Lance avec Holo1-3B (plus léger, moins de VRAM)

echo "========================================="
echo "🚀 Démarrage avec Holo1-3B (Léger)"
echo "========================================="
echo ""

# Kill tout
pkill -9 -f "vllm" 2>/dev/null
pkill -9 -f "uvicorn" 2>/dev/null
pkill -9 -f "http.server.*8080" 2>/dev/null
sleep 3

mkdir -p logs

# GPU
nvidia-smi --query-gpu=name,memory.free --format=csv,noheader

# vLLM avec Holo1-3B
echo ""
echo "🤖 Démarrage vLLM (Holo1-3B)..."
nohup vllm serve Hcompany/Holo1-3B \
    --host 0.0.0.0 \
    --port 8082 \
    --gpu-memory-utilization 0.9 \
    --max-model-len 2048 \
    --dtype bfloat16 \
    --trust-remote-code \
    > logs/vllm.log 2>&1 &

echo "   Attente..."
sleep 30

# API
echo ""
echo "⚡ Démarrage API..."
nohup uvicorn api.main:app --host 0.0.0.0 --port 8000 > logs/api.log 2>&1 &
sleep 5

# Visual Builder
echo ""
echo "🎨 Démarrage Visual Builder..."
cd /workspace/redflag
nohup python3 -m http.server 8080 --bind 0.0.0.0 > logs/visual_builder.log 2>&1 &

sleep 2

PUBLIC_IP=$(curl -s ifconfig.me)

echo ""
echo "========================================="
echo "✅ Démarré avec Holo1-3B !"
echo "========================================="
echo ""
echo "http://$PUBLIC_IP:8080/visual_builder.html"
echo ""
