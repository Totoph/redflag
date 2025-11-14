#!/bin/bash

# Lance TOUT avec configuration SAFE (moins de VRAM)
# Usage: ./start_everything_safe.sh

echo "========================================="
echo "🚀 Démarrage Complet (Mode Safe)"
echo "========================================="
echo ""

# Kill processus existants
echo "🧹 Nettoyage..."
pkill -9 -f "vllm.entrypoints" 2>/dev/null
pkill -9 -f "uvicorn api.main" 2>/dev/null
pkill -9 -f "python.*http.server.*8080" 2>/dev/null
sleep 3

# Vérifier qu'on est dans le bon dossier
if [ ! -f "visual_builder.html" ]; then
    echo "❌ Erreur: visual_builder.html non trouvé"
    echo "   Aller dans: cd /workspace/redflag"
    exit 1
fi

# Créer dossiers
mkdir -p screenshots journeys logs

# Vérifier GPU
echo "🎮 GPU Info:"
nvidia-smi --query-gpu=name,memory.free --format=csv,noheader
echo ""

# 1. Démarrer vLLM avec config SAFE
echo "🤖 [1/3] Démarrage vLLM (Configuration Safe)..."
nohup vllm serve Hcompany/Holo1-7B \
    --host 0.0.0.0 \
    --port 8082 \
    --gpu-memory-utilization 0.7 \
    --max-model-len 1024 \
    --dtype float16 \
    --trust-remote-code \
    --disable-log-requests \
    --enforce-eager \
    > logs/vllm.log 2>&1 &

VLLM_PID=$!
echo "   ✓ vLLM démarré (PID: $VLLM_PID)"
echo "   📝 Logs: tail -f logs/vllm.log"

# 2. Attendre vLLM avec monitoring
echo ""
echo "⏳ Attente vLLM (max 10 min)..."
MAX_WAIT=600
ELAPSED=0
LAST_LOG=""

while [ $ELAPSED -lt $MAX_WAIT ]; do
    # Vérifier health
    if curl -s http://localhost:8082/health > /dev/null 2>&1; then
        echo ""
        echo "   ✅ vLLM est prêt ! ($ELAPSED secondes)"
        break
    fi

    # Vérifier si le processus existe encore
    if ! ps -p $VLLM_PID > /dev/null 2>&1; then
        echo ""
        echo "   ❌ vLLM s'est arrêté !"
        echo "   📝 Voir les logs:"
        tail -30 logs/vllm.log
        exit 1
    fi

    # Afficher progression toutes les 10s
    if [ $((ELAPSED % 10)) -eq 0 ]; then
        # Récupérer dernière ligne de log
        CURRENT_LOG=$(tail -1 logs/vllm.log 2>/dev/null)
        if [ "$CURRENT_LOG" != "$LAST_LOG" ]; then
            printf "   %ds: %s\n" $ELAPSED "$(echo "$CURRENT_LOG" | cut -c1-80)"
            LAST_LOG="$CURRENT_LOG"
        else
            printf "   %ds...\n" $ELAPSED
        fi
    fi

    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo "   ❌ Timeout vLLM après ${MAX_WAIT}s"
    echo "   📝 Derniers logs:"
    tail -50 logs/vllm.log
    exit 1
fi

# 3. Démarrer l'API
echo ""
echo "⚡ [2/3] Démarrage API..."
nohup uvicorn api.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info \
    > logs/api.log 2>&1 &

API_PID=$!
echo "   ✓ API démarrée (PID: $API_PID)"

# Attendre l'API
sleep 3
for i in {1..10}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✓ API prête !"
        break
    fi
    sleep 1
done

# Visual Builder est maintenant intégré dans l'API sur /ui
echo ""
echo "🎨 [3/3] Visual Builder intégré dans l'API"
echo "   ✓ Accessible sur /ui"

sleep 1

# Récupérer IP publique
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "YOUR_IP")

# Résumé final
echo ""
echo "========================================="
echo "✅ Tous les services démarrés !"
echo "========================================="
echo ""
echo "🌐 URLs d'Accès:"
echo ""
echo "  📺 Visual Builder:"
echo "     http://$PUBLIC_IP:8000/ui"
echo ""
echo "  📡 API:"
echo "     http://$PUBLIC_IP:8000"
echo "     http://$PUBLIC_IP:8000/docs"
echo ""
echo "  🤖 vLLM:"
echo "     http://$PUBLIC_IP:8082"
echo ""
echo "📊 Services:"
echo "  - vLLM  (PID: $VLLM_PID)  Port: 8082"
echo "  - API + UI (PID: $API_PID)   Port: 8000"
echo ""
echo "📝 Logs:"
echo "  tail -f logs/vllm.log"
echo "  tail -f logs/api.log"
echo "  tail -f logs/visual_builder.log"
echo ""
echo "🔍 Statut: ./status.sh"
echo "🛑 Arrêter: ./stop_everything.sh"
echo ""
echo "🎉 Ouvrez votre navigateur:"
echo "   http://$PUBLIC_IP:8080/visual_builder.html"
echo ""

# Test quick
echo "🧪 Test rapide..."
if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo "   ✅ API répond correctement"
else
    echo "   ⚠️  API ne répond pas"
fi

if curl -s http://localhost:8080/visual_builder.html | grep -q "Visual Builder"; then
    echo "   ✅ Visual Builder accessible"
else
    echo "   ⚠️  Visual Builder inaccessible"
fi

echo ""
