#!/bin/bash

# Setup Simplifié - Sans Docker
# Utiliser si vast_setup.sh échoue

echo "========================================="
echo "Setup Simplifié Customer Journey MVP"
echo "========================================="

# Vérifier GPU
echo "Vérification GPU..."
nvidia-smi || echo "⚠️  GPU check failed"
echo ""

# Install Python packages
echo "Installation Python packages..."
pip3 install --upgrade pip

pip3 install vllm fastapi uvicorn httpx playwright beautifulsoup4 pillow python-multipart

# Install Playwright browsers
echo "Installation Playwright browsers..."
playwright install chromium
playwright install-deps chromium

# Create directories
echo "Création des dossiers..."
mkdir -p screenshots journeys

# Create .env
echo "Création .env..."
cat > .env << 'EOF'
VLLM_URL=http://localhost:8082
MODEL_NAME=Hcompany/Holo1-7B
API_PORT=8000
SCREENSHOTS_DIR=./screenshots
JOURNEYS_DIR=./journeys
EOF

echo ""
echo "========================================="
echo "✅ Setup simplifié terminé !"
echo "========================================="
echo ""
echo "Lancer maintenant:"
echo "1. Terminal 1: ./start_vllm.sh"
echo "2. Terminal 2: ./start_api.sh"
echo ""
