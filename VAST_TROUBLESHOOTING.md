# 🔧 Vast.ai Troubleshooting Guide

## Erreur: "Unable to locate package nvidia-docker2"

### Solution 1: Utiliser le setup simplifié

```bash
# Sur votre instance Vast.ai
cd /workspace/redflag
chmod +x setup_simple.sh
./setup_simple.sh
```

Ce script évite les packages Docker qui peuvent ne pas être disponibles.

### Solution 2: Installation manuelle

```bash
# 1. Vérifier GPU
nvidia-smi

# 2. Update packages
apt-get update

# 3. Installer Python deps
pip3 install --upgrade pip
pip3 install vllm fastapi uvicorn httpx playwright beautifulsoup4 pillow

# 4. Installer Playwright
playwright install chromium
playwright install-deps

# 5. Créer dossiers
mkdir -p screenshots journeys

# 6. Configurer environnement
cat > .env << 'EOF'
VLLM_URL=http://localhost:8082
MODEL_NAME=Hcompany/Holo1-7B
EOF
```

## Erreur SSH: "Permission denied (publickey)"

### Solution:
1. Aller sur https://cloud.vast.ai/account/
2. Section "SSH Keys"
3. Ajouter votre clé publique: `cat ~/.ssh/id_rsa.pub`
4. Détruire l'ancienne instance
5. Louer une nouvelle instance

## Erreur: "Playwright chromium not found"

```bash
# Réinstaller
playwright install chromium
playwright install-deps chromium

# Si erreur de permissions
apt-get install -y \
  libnss3 \
  libatk-bridge2.0-0 \
  libdrm2 \
  libxkbcommon0 \
  libgbm1 \
  libasound2
```

## Erreur: vLLM Out of Memory (OOM)

### Pour GPU 16GB ou moins:

Éditer `start_vllm.sh`:
```bash
vllm serve Hcompany/Holo1-7B \
    --port 8082 \
    --gpu-memory-utilization 0.8 \
    --max-model-len 2048 \
    --dtype float16
```

### Alternative: Utiliser Holo1-3B (plus léger):
```bash
vllm serve Hcompany/Holo1-3B \
    --port 8082 \
    --gpu-memory-utilization 0.9
```

## Erreur: "Cannot connect to vLLM"

```bash
# Vérifier que vLLM tourne
curl http://localhost:8082/health

# Vérifier les processus
ps aux | grep vllm

# Vérifier les ports
netstat -tlnp | grep 8082

# Redémarrer vLLM
pkill -f vllm
./start_vllm.sh
```

## Erreur: Import errors Python

```bash
# Réinstaller toutes les deps
pip3 install --upgrade --force-reinstall \
    vllm \
    fastapi \
    uvicorn \
    httpx \
    playwright \
    beautifulsoup4 \
    pillow
```

## Performance lente

### Vérifier GPU usage:
```bash
watch -n 1 nvidia-smi
```

### Vérifier charge CPU:
```bash
htop
```

### Optimiser vLLM:
```bash
# Ajouter ces flags à start_vllm.sh
--enable-prefix-caching \
--disable-log-requests \
--max-num-batched-tokens 8192
```

## Problème de réseau / Timeout

```bash
# Augmenter timeout dans journey_runner.py
# Ligne: async with httpx.AsyncClient(timeout=30.0)
# Changer à: timeout=60.0
```

## Screen / Tmux tips

```bash
# Créer un screen
screen -S vllm

# Détacher: Ctrl+A puis D

# Lister screens
screen -ls

# Réattacher
screen -r vllm

# Kill un screen
screen -S vllm -X quit
```

## Logs et Debug

```bash
# Voir logs API en temps réel
tail -f /var/log/api.log

# Mode verbose vLLM
vllm serve Hcompany/Holo1-7B --port 8082 --log-level debug

# Test API
curl -X POST http://localhost:8000/journey/start \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com", "task": "Navigate", "max_steps": 5}'
```

## Réinitialisation complète

```bash
# Kill tous les processus
pkill -f vllm
pkill -f uvicorn

# Nettoyer
rm -rf screenshots/* journeys/*

# Réinstaller
pip3 uninstall vllm -y
pip3 install vllm

# Redémarrer
./start_vllm.sh &
sleep 10
./start_api.sh
```

## Support

- **Vast.ai**: https://vast.ai/faq
- **vLLM**: https://docs.vllm.ai
- **Playwright**: https://playwright.dev/python
- **Holo1**: https://huggingface.co/Hcompany/Holo1-7B

## Scripts de diagnostic

Créer un script `diagnose.sh`:
```bash
#!/bin/bash
echo "=== GPU ==="
nvidia-smi

echo "=== Python packages ==="
pip3 list | grep -E "vllm|fastapi|playwright"

echo "=== Processus ==="
ps aux | grep -E "vllm|uvicorn"

echo "=== Ports ==="
netstat -tlnp | grep -E "8082|8000"

echo "=== Disk space ==="
df -h

echo "=== Memory ==="
free -h
```

Exécuter: `chmod +x diagnose.sh && ./diagnose.sh`
