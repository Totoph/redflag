#!/bin/bash

echo "========================================="
echo "Diagnostic vLLM"
echo "========================================="
echo ""

echo "1. Vérification GPU..."
nvidia-smi
echo ""

echo "2. Vérification CUDA..."
python3 -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}')"
echo ""

echo "3. Vérification vLLM..."
python3 -c "import vllm; print(f'vLLM version: {vllm.__version__}')"
echo ""

echo "4. VRAM disponible..."
nvidia-smi --query-gpu=memory.free,memory.total --format=csv
echo ""

echo "5. Tester import du modèle..."
python3 << 'PYEOF'
from transformers import AutoConfig
try:
    config = AutoConfig.from_pretrained("Hcompany/Holo1-7B", trust_remote_code=True)
    print(f"✅ Modèle trouvé: {config.model_type}")
except Exception as e:
    print(f"❌ Erreur: {e}")
PYEOF
echo ""

echo "========================================="
echo "Diagnostic terminé"
echo "========================================="
