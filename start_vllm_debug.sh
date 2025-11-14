#!/bin/bash

# Démarrage vLLM en mode debug avec configuration safe

echo "Démarrage vLLM en mode DEBUG..."
echo "GPU Info:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv
echo ""

# Version avec fallback et debug
vllm serve Hcompany/Holo1-7B \
    --host 0.0.0.0 \
    --port 8082 \
    --gpu-memory-utilization 0.85 \
    --max-model-len 2048 \
    --dtype auto \
    --trust-remote-code \
    --disable-log-requests \
    --log-level debug \
    2>&1 | tee vllm_debug.log

# Si le premier échoue, essayer avec des paramètres plus conservateurs
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "❌ Échec avec paramètres standard"
    echo "🔄 Essai avec paramètres réduits..."
    echo ""

    vllm serve Hcompany/Holo1-7B \
        --host 0.0.0.0 \
        --port 8082 \
        --gpu-memory-utilization 0.7 \
        --max-model-len 1024 \
        --dtype float16 \
        --trust-remote-code \
        --log-level debug
fi
