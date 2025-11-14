#!/bin/bash

# Lance TOUT: vLLM + API + Visual Builder
# Usage: ./start_everything.sh

echo "========================================="
echo "🚀 Démarrage Complet du Système"
echo "========================================="
echo ""

# Kill processus existants
echo "🧹 Nettoyage..."
pkill -f "vllm.entrypoints" 2>/dev/null
pkill -f "uvicorn api.main" 2>/dev/null
pkill -f "python.*http.server.*8080" 2>/dev/null
sleep 2

# Vérifier qu'on est dans le bon dossier
if [ ! -f "visual_builder.html" ]; then
    echo "❌ Erreur: visual_builder.html non trouvé"
    echo "   Aller dans le dossier redflag: cd /workspace/redflag"
    exit 1
fi

# Créer dossiers
mkdir -p screenshots journeys logs

# 1. Démarrer vLLM
echo ""
echo "🤖 [1/3] Démarrage vLLM (Holo1-7B)..."
nohup vllm serve Hcompany/Holo1-7B \
    --host 0.0.0.0 \
    --port 8082 \
    --gpu-memory-utilization 0.85 \
    --max-model-len 2048 \
    --dtype auto \
    --trust-remote-code \
    --disable-log-requests \
    > logs/vllm.log 2>&1 &

VLLM_PID=$!
echo "   ✓ vLLM démarré (PID: $VLLM_PID)"
echo "   📝 Logs: tail -f logs/vllm.log"

# 2. Attendre vLLM (max 5 min)
echo ""
echo "⏳ Attente du démarrage de vLLM..."
MAX_WAIT=300
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8082/health > /dev/null 2>&1; then
        echo "   ✓ vLLM est prêt ! ($ELAPSED secondes)"
        break
    fi

    if [ $((ELAPSED % 10)) -eq 0 ]; then
        printf "   ... %ds\n" $ELAPSED
    fi

    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "   ⚠️  Timeout vLLM, mais on continue..."
fi

# 3. Démarrer l'API
echo ""
echo "⚡ [2/3] Démarrage API FastAPI..."
nohup uvicorn api.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info \
    > logs/api.log 2>&1 &

API_PID=$!
echo "   ✓ API démarrée (PID: $API_PID)"
echo "   📝 Logs: tail -f logs/api.log"

# Attendre l'API
sleep 3
for i in {1..10}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✓ API est prête !"
        break
    fi
    sleep 1
done

# 4. Démarrer Visual Builder
echo ""
echo "🎨 [3/3] Démarrage Visual Builder..."
nohup python3 -m http.server 8080 --bind 0.0.0.0 \
    > logs/visual_builder.log 2>&1 &

BUILDER_PID=$!
echo "   ✓ Visual Builder démarré (PID: $BUILDER_PID)"
echo "   📝 Logs: tail -f logs/visual_builder.log"

# Sauvegarder les PIDs
echo $VLLM_PID > logs/vllm.pid
echo $API_PID > logs/api.pid
echo $BUILDER_PID > logs/visual_builder.pid

# Attendre Visual Builder
sleep 2

# Résumé final
echo ""
echo "========================================="
echo "✅ Tous les services sont démarrés !"
echo "========================================="
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_IP")
echo ""
echo "🌐 URLs:"
echo "  📺 Visual Builder: http://$PUBLIC_IP:8000/ui"
echo "  📡 API:            http://$PUBLIC_IP:8000"
echo "  📖 API Docs:       http://$PUBLIC_IP:8000/docs"
echo "  🤖 vLLM:           http://$PUBLIC_IP:8082"
echo ""
echo "📊 Services:"
echo "  - vLLM     (PID: $VLLM_PID)  Port: 8082"
echo "  - API + UI (PID: $API_PID)   Port: 8000"
echo ""
echo "📝 Logs:"
echo "  tail -f logs/vllm.log"
echo "  tail -f logs/api.log"
echo "  tail -f logs/visual_builder.log"
echo ""
echo "🔍 Vérifier le statut:"
echo "  ./status.sh"
echo ""
echo "🛑 Arrêter tout:"
echo "  ./stop_everything.sh"
echo ""
echo "🧪 Test rapide:"
curl -s http://localhost:8000/health | jq -r '"  API: " + .status' 2>/dev/null || echo "  API: checking..."
echo ""
echo "🎉 Prêt ! Ouvrez votre navigateur sur:"
echo "   http://$PUBLIC_IP:8000/ui"
echo ""
