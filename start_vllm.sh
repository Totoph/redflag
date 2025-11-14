#!/bin/bash

# Démarrage de vLLM avec Holo1-7B
# GPU recommandée: RTX 4090 24GB ou RTX 3090 24GB

echo "Démarrage de vLLM avec Holo1-7B..."

vllm serve Hcompany/Holo1-7B \
    --port 8082 \
    --gpu-memory-utilization 0.9 \
    --max-model-len 4096 \
    --dtype bfloat16 \
    --trust-remote-code \
    --enable-prefix-caching

# Options alternatives pour GPU plus petite (16GB):
# --gpu-memory-utilization 0.85 \
# --max-model-len 2048 \
# --quantization awq
