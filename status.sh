#!/bin/bash

# Vérifier le statut de tous les services

echo "========================================="
echo "Statut des Services"
echo "========================================="
echo ""

# Check vLLM
echo "🔍 vLLM (port 8082):"
VLLM_PROC=$(ps aux | grep "vllm.entrypoints" | grep -v grep)
if [ -n "$VLLM_PROC" ]; then
    VLLM_PID=$(echo "$VLLM_PROC" | awk '{print $2}')
    echo "  ✓ Running (PID: $VLLM_PID)"

    # Test health endpoint
    if curl -s http://localhost:8082/health > /dev/null 2>&1; then
        echo "  ✓ Health check: OK"
    else
        echo "  ⚠️  Health check: FAILED"
    fi
else
    echo "  ✗ Not running"
fi
echo ""

# Check Visual Builder
echo "🔍 Visual Builder (port 8080):"
BUILDER_PROC=$(ps aux | grep "python.*http.server.*8080" | grep -v grep)
if [ -n "$BUILDER_PROC" ]; then
    BUILDER_PID=$(echo "$BUILDER_PROC" | awk '{print $2}')
    echo "  ✓ Running (PID: $BUILDER_PID)"

    # Test HTTP
    if curl -s http://localhost:8080/visual_builder.html > /dev/null 2>&1; then
        echo "  ✓ HTTP check: OK"
        echo "  🌐 URL: http://localhost:8080/visual_builder.html"
    else
        echo "  ⚠️  HTTP check: FAILED"
    fi
else
    echo "  ✗ Not running"
fi
echo ""

# Check API
echo "🔍 API (port 8000):"
API_PROC=$(ps aux | grep "uvicorn api.main" | grep -v grep)
if [ -n "$API_PROC" ]; then
    API_PID=$(echo "$API_PROC" | awk '{print $2}')
    echo "  ✓ Running (PID: $API_PID)"

    # Test health endpoint
    HEALTH=$(curl -s http://localhost:8000/health 2>/dev/null)
    if [ -n "$HEALTH" ]; then
        echo "  ✓ Health check: OK"
        echo "$HEALTH" | jq -r '  "  Journeys: \(.journeys.total) total, \(.journeys.running) running"' 2>/dev/null
    else
        echo "  ⚠️  Health check: FAILED"
    fi
else
    echo "  ✗ Not running"
fi
echo ""

# GPU Status
echo "🎮 GPU:"
nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.free --format=csv,noheader | \
    awk -F', ' '{printf "  %s\n  GPU Usage: %s\n  VRAM: %s used, %s free\n", $1, $2, $3, $4}'
echo ""

# Disk usage
echo "💾 Disk:"
df -h . | tail -1 | awk '{printf "  Used: %s / %s (%s)\n", $3, $2, $5}'
echo ""

# Recent logs
if [ -f "logs/vllm.log" ]; then
    echo "📝 Recent vLLM logs (last 3 lines):"
    tail -3 logs/vllm.log | sed 's/^/  /'
    echo ""
fi

if [ -f "logs/api.log" ]; then
    echo "📝 Recent API logs (last 3 lines):"
    tail -3 logs/api.log | sed 's/^/  /'
    echo ""
fi

# Ports
echo "🔌 Ports actifs:"
netstat -tlnp 2>/dev/null | grep -E ":(8000|8082)" | awk '{print "  " $4 " -> " $7}' || \
    lsof -i :8000,8082 2>/dev/null | grep LISTEN | awk '{print "  Port " $9 " -> PID " $2}'
echo ""

echo "========================================="
echo "Commandes utiles:"
echo "  Logs vLLM:  tail -f logs/vllm.log"
echo "  Logs API:   tail -f logs/api.log"
echo "  Test API:   ./test_api_prod.sh"
echo "  Arrêter:    ./stop_all.sh"
echo "  Redémarrer: ./start_all.sh"
echo "========================================="
