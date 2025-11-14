# Customer Journey MVP - Powered by Surfer-H & Holo1

MVP pour automatiser et analyser des parcours clients sur des sites web en utilisant **Surfer-H** et **Holo1 VLM**.

## 🎯 Fonctionnalités

- ✅ Crawling automatique de sites web
- ✅ Navigation intelligente avec AI (Holo1 VLM)
- ✅ Capture de screenshots à chaque étape
- ✅ Tracking complet des actions utilisateur
- ✅ API REST pour déclencher des journeys
- ✅ Export JSON des parcours

## 🖥️ GPU Recommandées pour Vast.ai

| GPU | VRAM | Prix/h | Performance |
|-----|------|--------|-------------|
| **RTX 4090** ⭐ | 24GB | ~$0.30-0.50 | Excellent |
| RTX 3090 | 24GB | ~$0.20-0.35 | Très bon |
| A100 40GB | 40GB | ~$0.60-1.00 | Production |
| RTX 4080 | 16GB | ~$0.25-0.40 | Budget (avec quantization) |

## 🚀 Installation sur Vast.ai

### 1. Louer une instance
```bash
# Sur Vast.ai, chercher: RTX 4090 ou RTX 3090 avec 24GB VRAM
# Image Docker: pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
```

### 2. Setup initial
```bash
cd /workspace
git clone <votre-repo>
cd redflag

# Exécuter le setup
chmod +x vast_setup.sh
./vast_setup.sh
```

### 3. Démarrer vLLM (Terminal 1)
```bash
chmod +x start_vllm.sh
./start_vllm.sh
```

Attendez que vLLM charge le modèle (~5-10 min pour le téléchargement initial).

### 4. Démarrer l'API (Terminal 2)
```bash
chmod +x start_api.sh
./start_api.sh
```

### 5. Tester
```bash
chmod +x test_customer_journey.sh
./test_customer_journey.sh
```

## 🐳 Déploiement avec Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier les logs
docker-compose logs -f

# Arrêter
docker-compose down
```

Services exposés:
- **vLLM**: http://localhost:8082
- **API**: http://localhost:8000
- **Docs API**: http://localhost:8000/docs

## 📖 Utilisation de l'API

### Démarrer un journey

```bash
curl -X POST http://localhost:8000/journey/start \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example-shop.com",
    "task": "Navigate to products, add item to cart, go to checkout",
    "max_steps": 20,
    "screenshot_every_step": true
  }'
```

Réponse:
```json
{
  "journey_id": "abc-123-def",
  "status": "started",
  "message": "Customer journey started"
}
```

### Vérifier le statut

```bash
curl http://localhost:8000/journey/abc-123-def
```

Réponse:
```json
{
  "journey_id": "abc-123-def",
  "status": "running",
  "url": "https://example-shop.com",
  "steps_completed": 3,
  "steps_total": 20,
  "screenshots": [
    "/app/screenshots/abc-123-def_step_0.png",
    "/app/screenshots/abc-123-def_step_1.png"
  ],
  "actions": [
    {
      "step": 1,
      "action": "click",
      "target": "text=Products",
      "timestamp": "2025-11-14T10:30:00"
    }
  ]
}
```

### Lister tous les journeys

```bash
curl http://localhost:8000/journeys?limit=10
```

## 📁 Structure du Projet

```
redflag/
├── api/
│   ├── main.py              # FastAPI endpoints
│   └── __init__.py
├── surfer_integration/
│   ├── journey_runner.py    # Customer journey logic
│   └── __init__.py
├── screenshots/             # Screenshots générés
├── journeys/                # Résultats JSON
├── docker-compose.yml       # Orchestration Docker
├── Dockerfile.api           # API container
├── requirements.txt         # Python deps
├── vast_setup.sh           # Setup script
├── start_vllm.sh           # Démarrage vLLM
├── start_api.sh            # Démarrage API
└── test_customer_journey.sh # Tests
```

## 🔧 Configuration

### Variables d'environnement

Créer un fichier `.env`:
```bash
# vLLM
VLLM_URL=http://localhost:8082
MODEL_NAME=Hcompany/Holo1-7B

# API
API_PORT=8000

# H Company API (optionnel, pour API hébergée)
HAI_API_KEY=your_key_here
```

## 🧪 Exemples de Tasks

### E-commerce
```json
{
  "task": "Search for 'laptop', add the first result to cart, proceed to checkout"
}
```

### Lead generation
```json
{
  "task": "Navigate to contact page, fill out form with test data, submit"
}
```

### Navigation test
```json
{
  "task": "Click on 'About Us', then 'Team', then return to homepage"
}
```

## 📊 Monitoring

```bash
# Logs vLLM
tail -f vllm.log

# Logs API
docker-compose logs -f api

# GPU usage
nvidia-smi -l 1
```

## 🐛 Troubleshooting

### vLLM ne démarre pas
```bash
# Vérifier VRAM disponible
nvidia-smi

# Réduire max-model-len si pas assez de VRAM
vllm serve Hcompany/Holo1-7B --max-model-len 2048
```

### API timeout
```bash
# Vérifier que vLLM est accessible
curl http://localhost:8082/health

# Augmenter timeout dans httpx
```

### Playwright erreurs
```bash
# Réinstaller browsers
playwright install chromium
playwright install-deps
```

## 🚧 TODO (Améliorations futures)

- [ ] Intégration complète avec Holo1 VLM pour analyse d'image
- [ ] Support multi-sites simultanés
- [ ] Analytics dashboard
- [ ] Export vers CSV/Excel
- [ ] Webhook notifications
- [ ] Rate limiting
- [ ] Authentication
- [ ] Redis pour queue de jobs
- [ ] Metrics avec Prometheus

## 📝 License

MIT

## 🤝 Support

Pour questions: ouvrir une issue sur GitHub

---

**Made with ❤️ using Surfer-H & Holo1**
