#!/bin/bash

# Script de démarrage complet - vLLM + API
# Lance les deux services en arrière-plan

echo "========================================="
echo "Démarrage Customer Journey MVP"
echo "========================================="
echo ""

# Vérifier GPU
echo "🔍 Vérification GPU..."
nvidia-smi --query-gpu=name,memory.free --format=csv,noheader
echo ""

# Kill processus existants
echo "🧹 Nettoyage des processus existants..."
pkill -f "vllm.entrypoints" 2>/dev/null
pkill -f "uvicorn api.main" 2>/dev/null
sleep 2

# Créer dossiers
mkdir -p screenshots journeys logs

# Démarrer vLLM en arrière-plan
echo "🚀 Démarrage vLLM (Holo1-7B)..."
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
echo "✓ vLLM démarré (PID: $VLLM_PID)"
echo "  Logs: tail -f logs/vllm.log"
echo ""

# Attendre que vLLM soit prêt
echo "⏳ Attente du démarrage de vLLM (peut prendre 1-5 min pour le premier téléchargement)..."
echo "   Progression dans logs/vllm.log"

MAX_WAIT=300  # 5 minutes max
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8082/health > /dev/null 2>&1; then
        echo "✓ vLLM est prêt !"
        break
    fi

    # Afficher progression toutes les 10 secondes
    if [ $((ELAPSED % 10)) -eq 0 ]; then
        echo "  ... attente ${ELAPSED}s"
    fi

    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "❌ Timeout: vLLM n'a pas démarré après ${MAX_WAIT}s"
    echo "   Vérifier les logs: tail -f logs/vllm.log"
    exit 1
fi

echo ""

# Démarrer l'API en arrière-plan
echo "🚀 Démarrage API FastAPI..."
nohup uvicorn api.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info \
    > logs/api.log 2>&1 &

API_PID=$!
echo "✓ API démarrée (PID: $API_PID)"
echo "  Logs: tail -f logs/api.log"
echo ""

# Attendre que l'API soit prête
echo "⏳ Attente du démarrage de l'API..."
sleep 3

for i in {1..10}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✓ API est prête !"
        break
    fi
    sleep 1
done

echo ""
echo "========================================="
echo "✅ Tous les services sont démarrés !"
echo "========================================="
echo ""
echo "📊 Services actifs:"
echo "  - vLLM:  http://localhost:8082  (PID: $VLLM_PID)"
echo "  - API:   http://localhost:8000  (PID: $API_PID)"
echo ""
echo "📖 Documentation:"
echo "  - Swagger UI: http://localhost:8000/docs"
echo "  - ReDoc:      http://localhost:8000/redoc"
echo ""
echo "📝 Logs:"
echo "  - vLLM: tail -f logs/vllm.log"
echo "  - API:  tail -f logs/api.log"
echo ""
echo "🔍 Vérifier statut:"
echo "  ./status.sh"
echo ""
echo "🛑 Arrêter tous les services:"
echo "  ./stop_all.sh"
echo ""
echo "🧪 Tester l'API:"
echo "  ./test_api_prod.sh"
echo ""

# Sauvegarder les PIDs
echo $VLLM_PID > logs/vllm.pid
echo $API_PID > logs/api.pid

# Test rapide
echo "🧪 Test rapide..."
sleep 2
HEALTH=$(curl -s http://localhost:8000/health | grep -o "healthy" | head -1)
if [ "$HEALTH" = "healthy" ]; then
    echo "✓ API fonctionne correctement"
else
    echo "⚠️  API health check failed - vérifier logs/api.log"
fi

echo ""
echo "🎉 Prêt à recevoir des requêtes !"
echo ""
