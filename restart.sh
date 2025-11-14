#!/bin/bash

# Redémarrer tous les services

echo "🔄 Redémarrage des services..."
echo ""

# Stop
./stop_all.sh

# Wait
echo "⏳ Attente de 3 secondes..."
sleep 3
echo ""

# Start
./start_all.sh
