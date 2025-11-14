#!/bin/bash

# Afficher les logs en temps réel

SERVICE="${1:-api}"

if [ "$SERVICE" = "vllm" ]; then
    echo "📝 Logs vLLM (Ctrl+C pour quitter):"
    echo ""
    tail -f logs/vllm.log
elif [ "$SERVICE" = "api" ]; then
    echo "📝 Logs API (Ctrl+C pour quitter):"
    echo ""
    tail -f logs/api.log
elif [ "$SERVICE" = "both" ]; then
    echo "📝 Logs vLLM + API (Ctrl+C pour quitter):"
    echo ""
    tail -f logs/vllm.log logs/api.log
else
    echo "Usage: ./logs.sh [vllm|api|both]"
    echo ""
    echo "Examples:"
    echo "  ./logs.sh api   # Logs API uniquement"
    echo "  ./logs.sh vllm  # Logs vLLM uniquement"
    echo "  ./logs.sh both  # Les deux"
    exit 1
fi
