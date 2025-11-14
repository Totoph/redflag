#!/bin/bash

# Surfer-H Customer Journey MVP - Vast.ai Setup Script
# Recommandé: RTX 4090 (24GB) ou RTX 3090 (24GB)

set -e

echo "========================================="
echo "Surfer-H Customer Journey MVP Setup"
echo "========================================="

# Update system
echo "[1/6] Mise à jour du système..."
apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget \
    curl \
    docker.io \
    docker-compose \
    nvidia-docker2

# Install Python dependencies
echo "[2/6] Installation des dépendances Python..."
pip3 install --upgrade pip
pip3 install vllm==0.6.3
pip3 install fastapi uvicorn
pip3 install httpx
pip3 install playwright
pip3 install beautifulsoup4
pip3 install pillow

# Install Playwright browsers
echo "[3/6] Installation des navigateurs Playwright..."
playwright install chromium
playwright install-deps

# Clone Surfer-H CLI
echo "[4/6] Clonage de Surfer-H CLI..."
cd /workspace
git clone https://github.com/hcompai/surfer-h-cli.git
cd surfer-h-cli

# Setup environment
echo "[5/6] Configuration de l'environnement..."
cat > .env << EOF
HAI_API_KEY=EMPTY
HAI_MODEL_URL=http://localhost:8082/v1
HAI_MODEL_NAME=Hcompany/Holo1-7B
EOF

# Download model (optional - vLLM fera automatiquement)
echo "[6/6] Les modèles seront téléchargés au premier lancement..."

echo ""
echo "========================================="
echo "✅ Setup terminé !"
echo "========================================="
echo ""
echo "Prochaines étapes:"
echo "1. Lancer vLLM: ./start_vllm.sh"
echo "2. Lancer l'API: ./start_api.sh"
echo "3. Tester: ./test_customer_journey.sh"
echo ""
