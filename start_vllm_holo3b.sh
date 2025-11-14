#!/bin/bash

# Alternative: Utiliser Holo1-3B (plus léger, moins de VRAM)

echo "Démarrage vLLM avec Holo1-3B (modèle plus léger)..."

vllm serve Hcompany/Holo1-3B \
    --host 0.0.0.0 \
    --port 8082 \
    --gpu-memory-utilization 0.9 \
    --max-model-len 4096 \
    --dtype bfloat16 \
    --trust-remote-code \
    --enable-prefix-caching
