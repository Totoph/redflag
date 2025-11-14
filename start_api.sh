#!/bin/bash

# Démarrage de l'API FastAPI pour Customer Journey

echo "Démarrage de l'API Customer Journey..."

# Install dependencies if needed
pip3 install -q -r requirements.txt

# Create directories
mkdir -p screenshots journeys

# Start API
uvicorn api.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --log-level info
