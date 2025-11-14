# 🚀 Commandes Rapides

Guide de référence rapide pour gérer votre instance Customer Journey.

---

## 📦 Setup Initial

```bash
# Sur votre instance Vast.ai
cd /workspace
git clone <votre-repo> redflag
cd redflag

# Setup complet
./setup_simple.sh
```

---

## 🎬 Démarrage

### Tout démarrer en une commande
```bash
./start_all.sh
```

Ce script va:
1. ✓ Nettoyer les processus existants
2. ✓ Démarrer vLLM (Holo1-7B) sur port 8082
3. ✓ Attendre que vLLM soit prêt
4. ✓ Démarrer l'API sur port 8000
5. ✓ Créer les logs dans `logs/`

**Temps d'attente:** 1-5 minutes (premier lancement avec téléchargement du modèle)

---

## 📊 Vérifier le Statut

```bash
./status.sh
```

Affiche:
- ✓ Statut vLLM et API (running/stopped)
- ✓ Health checks
- ✓ GPU usage
- ✓ Journeys actifs
- ✓ Disk usage
- ✓ Logs récents

---

## 🛑 Arrêter

```bash
./stop_all.sh
```

Arrête proprement vLLM et l'API.

---

## 🔄 Redémarrer

```bash
./restart.sh
```

Équivalent à `./stop_all.sh` puis `./start_all.sh`

---

## 📝 Logs

### Logs API
```bash
./logs.sh api
# OU
tail -f logs/api.log
```

### Logs vLLM
```bash
./logs.sh vllm
# OU
tail -f logs/vllm.log
```

### Les deux en même temps
```bash
./logs.sh both
```

---

## 🧪 Tester l'API

```bash
./test_api_prod.sh http://localhost:8000
```

Teste automatiquement:
- ✓ Health check
- ✓ Créer un journey
- ✓ Récupérer statut
- ✓ Lister journeys
- ✓ Récupérer screenshots
- ✓ Stats

---

## 🔍 Diagnostic

```bash
# GPU usage
nvidia-smi

# Processus actifs
ps aux | grep -E "vllm|uvicorn"

# Ports ouverts
netstat -tlnp | grep -E "8000|8082"

# Espace disque
df -h

# Diagnostic complet
./diagnose_vllm.sh
```

---

## 📡 Appels API

### Health Check
```bash
curl http://localhost:8000/health
```

### Démarrer un Journey
```bash
curl -X POST http://localhost:8000/journey/start \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://demo.playwright.dev/todomvc",
    "task": "Add 3 todos, mark first as complete",
    "max_steps": 10
  }'
```

### Récupérer Statut
```bash
curl http://localhost:8000/journey/{JOURNEY_ID} | jq .
```

### Lister Journeys
```bash
curl http://localhost:8000/journeys?limit=10 | jq .
```

### Stats
```bash
curl http://localhost:8000/stats | jq .
```

### Screenshot
```bash
# PNG
curl http://localhost:8000/journey/{ID}/screenshot/0 -o step0.png

# Base64
curl "http://localhost:8000/journey/{ID}/screenshot/0?as_base64=true" | jq .
```

---

## 🌐 Accès Externe

### Depuis votre machine locale

Remplacer `localhost` par l'IP de votre instance:
```bash
curl http://89.221.67.141:8000/health
```

### Tunnel SSH
```bash
ssh -L 8000:localhost:8000 -p PORT root@IP
```

Puis accéder à `http://localhost:8000` sur votre machine.

---

## 🐛 Dépannage

### vLLM ne démarre pas
```bash
# Vérifier VRAM
nvidia-smi

# Vérifier logs
tail -100 logs/vllm.log

# Redémarrer avec moins de VRAM
# Éditer start_all.sh: --gpu-memory-utilization 0.7
```

### API timeout
```bash
# Vérifier que vLLM répond
curl http://localhost:8082/health

# Redémarrer API seulement
pkill -f uvicorn
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

### Playwright erreurs
```bash
playwright install chromium
playwright install-deps
```

### Out of disk space
```bash
# Nettoyer screenshots anciens
rm -rf screenshots/*

# Nettoyer journeys anciens
rm -rf journeys/*

# Nettoyer cache HuggingFace
rm -rf ~/.cache/huggingface/*
```

---

## 📚 Documentation

```bash
# Swagger UI
open http://localhost:8000/docs

# ReDoc
open http://localhost:8000/redoc

# Endpoints
cat API_ENDPOINTS.md

# Frontend integration
cat FRONTEND_INTEGRATION.md
```

---

## 🔧 Configuration

### Éditer variables d'environnement
```bash
nano .env
```

### Changer le modèle
```bash
# Dans .env
MODEL_NAME=Hcompany/Holo1-3B  # Plus léger

# OU éditer start_all.sh directement
```

### Changer les ports
```bash
# Dans start_all.sh
# vLLM: --port 8082
# API: --port 8000
```

---

## 💾 Backup

### Sauvegarder les journeys
```bash
tar -czf journeys_backup_$(date +%Y%m%d).tar.gz journeys/ screenshots/
```

### Télécharger localement
```bash
scp -P PORT root@IP:/workspace/redflag/journeys_backup_*.tar.gz .
```

---

## 🚀 Performance

### Optimiser vLLM
```bash
# Dans start_all.sh, ajouter:
--enable-prefix-caching \
--max-num-batched-tokens 8192 \
--disable-log-requests
```

### Monitorer GPU
```bash
watch -n 1 nvidia-smi
```

---

## 📞 Aide Rapide

```bash
# Tout redémarrer
./restart.sh

# Voir ce qui se passe
./status.sh

# Voir les logs
./logs.sh both

# Tester
./test_api_prod.sh
```

---

## ⚡ Commandes One-Liner

```bash
# Kill tout et redémarrer
pkill -f vllm; pkill -f uvicorn; sleep 2; ./start_all.sh

# Nettoyer et redémarrer
rm -rf screenshots/* journeys/*; ./restart.sh

# Vérifier que tout marche
curl -s http://localhost:8000/health | jq .status

# Compter les journeys
curl -s http://localhost:8000/stats | jq .total_journeys

# Derniers journeys
curl -s http://localhost:8000/journeys?limit=5 | jq '.[] | {id: .journey_id, status: .status}'
```

---

## 📋 Checklist Démarrage

- [ ] Instance Vast.ai louée (RTX 4090 24GB)
- [ ] SSH key configurée
- [ ] Connecté à l'instance
- [ ] Code cloné dans `/workspace/redflag`
- [ ] Setup exécuté: `./setup_simple.sh`
- [ ] Services démarrés: `./start_all.sh`
- [ ] Statut vérifié: `./status.sh`
- [ ] API testée: `./test_api_prod.sh`
- [ ] Frontend connecté

---

**Pour plus de détails, voir:**
- `README.md` - Documentation complète
- `API_ENDPOINTS.md` - Référence API
- `FRONTEND_INTEGRATION.md` - Intégration frontend
- `VAST_TROUBLESHOOTING.md` - Résolution problèmes
