# 🚀 Quick Start - Customer Journey MVP

## En 5 minutes sur Vast.ai

### 1️⃣ Louer GPU (2 min)
```
1. Aller sur vast.ai
2. Chercher: RTX 4090 24GB
3. Image: pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
4. Cliquer "Rent"
```

### 2️⃣ Setup (3 min)
```bash
ssh -p <PORT> root@<IP>
cd /workspace
git clone <votre-repo> redflag
cd redflag
./vast_setup.sh
```

### 3️⃣ Démarrer (Terminal 1)
```bash
screen -S vllm
./start_vllm.sh
# Ctrl+A puis D pour détacher
```

### 4️⃣ Démarrer API (Terminal 2)
```bash
screen -S api
./start_api.sh
# Ctrl+A puis D pour détacher
```

### 5️⃣ Tester
```bash
./test_customer_journey.sh
```

## 🎯 Exemples d'utilisation

### Tester un site e-commerce
```bash
curl -X POST http://localhost:8000/journey/start \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://demo.playwright.dev/todomvc",
    "task": "Add 3 todo items, mark first as complete",
    "max_steps": 15
  }'
```

### Vérifier progression
```bash
# Récupérer le journey_id de la réponse
curl http://localhost:8000/journey/<JOURNEY_ID>
```

### Voir tous les journeys
```bash
curl http://localhost:8000/journeys | jq .
```

## 📸 Accéder aux screenshots

```bash
# Lister screenshots
ls -lh ./screenshots/

# Télécharger depuis Vast.ai
scp -P <PORT> root@<IP>:/workspace/redflag/screenshots/*.png ./
```

## 🔍 Commandes utiles

```bash
# Voir GPU usage
nvidia-smi

# Réattacher aux screens
screen -r vllm
screen -r api

# Logs en temps réel
tail -f journeys/*.json

# Redémarrer API
screen -r api
# Ctrl+C puis ./start_api.sh
```

## ⚙️ Configuration rapide

### Utiliser Holo1-3B (plus rapide, moins précis)
```bash
# Éditer start_vllm.sh
vllm serve Hcompany/Holo1-3B --port 8082 --gpu-memory-utilization 0.9
```

### GPU 16GB (RTX 4080)
```bash
# Éditer start_vllm.sh
vllm serve Hcompany/Holo1-7B \
  --port 8082 \
  --max-model-len 2048 \
  --gpu-memory-utilization 0.85
```

## 🐛 Problèmes fréquents

**vLLM ne démarre pas**
```bash
nvidia-smi  # Vérifier VRAM dispo
```

**API timeout**
```bash
curl http://localhost:8082/health  # Vérifier vLLM
```

**Port déjà utilisé**
```bash
kill $(lsof -t -i:8000)  # Libérer port 8000
kill $(lsof -t -i:8082)  # Libérer port 8082
```

## 📚 Documentation complète

- [README.md](README.md) - Documentation principale
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Guide détaillé

## 💡 Prochaines étapes

1. Tester avec votre propre site web
2. Ajuster les prompts dans `surfer_integration/journey_runner.py`
3. Intégrer l'appel réel à Holo1 VLM (voir `call_holo1_vlm()`)
4. Ajouter votre logique métier

Bon développement ! 🎉
