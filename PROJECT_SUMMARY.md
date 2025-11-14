# 📊 Customer Journey MVP - Résumé du Projet

## 🎯 Objectif
Créer un MVP pour automatiser et analyser des parcours clients sur des sites web en utilisant **Surfer-H** et le modèle **Holo1 VLM** de H-Company.

## 🏗️ Architecture

```
┌─────────────────┐
│   User Request  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   FastAPI       │ Port 8000
│   (Customer     │
│   Journey API)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Playwright    │
│   (Browser      │
│   Automation)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   vLLM Server   │ Port 8082
│   Holo1-7B VLM  │
│   (24GB VRAM)   │
└─────────────────┘
```

## 📦 Composants

### 1. Infrastructure (Vast.ai)
- **GPU**: RTX 4090 24GB (recommandé)
- **Alternative**: RTX 3090 24GB, A100 40GB
- **Coût**: ~$0.30-0.50/h

### 2. Backend (FastAPI)
- **Fichier**: `api/main.py`
- **Endpoints**:
  - `POST /journey/start` - Démarrer un journey
  - `GET /journey/{id}` - Statut d'un journey
  - `GET /journeys` - Liste tous les journeys
  - `GET /health` - Health check

### 3. AI/ML (vLLM + Holo1)
- **Modèle**: Holo1-7B (14GB)
- **Framework**: vLLM pour inference optimisée
- **Capabilities**: Vision-Language Model pour UI automation

### 4. Browser Automation
- **Tool**: Playwright (Chromium)
- **Features**:
  - Screenshots à chaque étape
  - Navigation intelligente
  - Form filling
  - Click automation

## 📁 Structure des Fichiers

```
redflag/
├── 📄 README.md                    # Documentation principale
├── 📄 QUICKSTART.md                # Guide rapide 5 min
├── 📄 DEPLOYMENT_GUIDE.md          # Guide détaillé Vast.ai
├── 📄 PROJECT_SUMMARY.md           # Ce fichier
│
├── 🐳 Docker & Config
│   ├── docker-compose.yml          # Orchestration containers
│   ├── Dockerfile.api              # API container
│   ├── requirements.txt            # Python dependencies
│   ├── .env.example                # Variables d'environnement
│   └── .gitignore                  # Git ignore rules
│
├── 🚀 Scripts de démarrage
│   ├── vast_setup.sh               # Setup initial Vast.ai
│   ├── start_vllm.sh               # Démarrer vLLM
│   ├── start_api.sh                # Démarrer API
│   └── test_customer_journey.sh   # Tests
│
├── 🔧 API Backend
│   └── api/
│       ├── __init__.py
│       └── main.py                 # FastAPI app + endpoints
│
├── 🤖 Surfer-H Integration
│   └── surfer_integration/
│       ├── __init__.py
│       └── journey_runner.py       # Customer journey logic
│
└── 📊 Outputs
    ├── screenshots/                # PNG screenshots
    └── journeys/                   # JSON résultats
```

## 🔄 Workflow Typique

1. **User** envoie requête POST avec URL + task
2. **API** crée un journey ID et lance background task
3. **Playwright** ouvre browser et navigue vers URL
4. **Holo1 VLM** analyse screenshot et décide next action
5. **Playwright** exécute l'action (click, type, scroll, etc.)
6. **Repeat** steps 4-5 jusqu'à task complete ou max_steps
7. **API** retourne résultats avec screenshots + actions log

## 📊 Données Générées

### Screenshot
```
screenshots/journey-abc-123_step_0.png
screenshots/journey-abc-123_step_1.png
...
```

### Journey JSON
```json
{
  "journey_id": "abc-123",
  "status": "completed",
  "url": "https://example.com",
  "task": "Navigate to products",
  "steps_completed": 5,
  "actions": [
    {
      "step": 1,
      "action": "click",
      "target": "text=Products",
      "timestamp": "2025-11-14T10:30:00"
    }
  ],
  "screenshots": ["path1.png", "path2.png"]
}
```

## 💰 Coûts Estimés

| Durée | RTX 4090 | RTX 3090 | A100 |
|-------|----------|----------|------|
| 1h | $0.40 | $0.30 | $0.80 |
| 8h | $3.20 | $2.40 | $6.40 |
| 24h | $9.60 | $7.20 | $19.20 |
| 30j | $288 | $216 | $576 |

## 🎯 Use Cases

### 1. E-commerce Testing
- Tester parcours d'achat
- Vérifier checkout flow
- Tester promo codes

### 2. Lead Generation Analysis
- Analyser formulaires
- Tester conversion funnels
- Optimiser CTAs

### 3. Competitor Analysis
- Analyser parcours concurrents
- Benchmarking UX
- Feature comparison

### 4. QA Automation
- Regression testing
- UI testing
- Integration testing

## 🚧 Limitations Actuelles

1. **VLM Integration**: Logique simplifiée, nécessite intégration complète Holo1
2. **Single User**: Pas de queue pour jobs multiples (ajouter Redis)
3. **No Auth**: API publique sans authentification
4. **Storage**: In-memory (utiliser DB en prod)
5. **Error Handling**: Basique, à améliorer

## 🔮 Roadmap Future

### Phase 2 (Court terme)
- [ ] Intégration complète Holo1 VLM
- [ ] Queue Redis pour jobs multiples
- [ ] Authentication JWT
- [ ] PostgreSQL pour persistence
- [ ] Webhooks notifications

### Phase 3 (Moyen terme)
- [ ] Dashboard analytics
- [ ] Export CSV/PDF reports
- [ ] A/B testing comparisons
- [ ] Multi-site batch analysis
- [ ] Rate limiting & quotas

### Phase 4 (Long terme)
- [ ] SaaS multi-tenant
- [ ] Custom training for specific sites
- [ ] Real-time collaboration
- [ ] Kubernetes auto-scaling
- [ ] Advanced ML insights

## 🛠️ Technologies Utilisées

### Backend
- **FastAPI**: API framework
- **Uvicorn**: ASGI server
- **Pydantic**: Data validation

### AI/ML
- **vLLM**: LLM inference server
- **Holo1-7B**: Vision-Language Model
- **Transformers**: Model loading

### Automation
- **Playwright**: Browser automation
- **BeautifulSoup**: HTML parsing
- **Selenium**: Alternative browser control

### Infrastructure
- **Docker**: Containerization
- **Docker Compose**: Orchestration
- **Vast.ai**: GPU cloud

## 📈 Performance

### Latence typique (RTX 4090)
- Model load: ~2-3 min (first time)
- Per step inference: ~1-2 sec
- Screenshot capture: ~200ms
- Full journey (10 steps): ~30-60 sec

### Throughput
- Concurrent journeys: 1-2 (single GPU)
- Steps/minute: ~20-30
- Screenshots/minute: ~30-40

## 🔒 Sécurité

### Actuel (MVP)
- ⚠️ No authentication
- ⚠️ No rate limiting
- ⚠️ Public API

### Recommandé Production
- ✅ JWT authentication
- ✅ API keys per user
- ✅ Rate limiting (10 req/min)
- ✅ Input validation & sanitization
- ✅ HTTPS only
- ✅ Firewall rules
- ✅ Secrets management

## 📞 Support & Resources

- **Holo1 Model**: https://huggingface.co/Hcompany/Holo1-7B
- **Surfer-H CLI**: https://github.com/hcompai/surfer-h-cli
- **Vast.ai Docs**: https://vast.ai/docs
- **vLLM Docs**: https://docs.vllm.ai
- **Playwright**: https://playwright.dev

## 👥 Team & Contributions

**Contributeurs bienvenus !**
- Issues: Pour bugs et feature requests
- PRs: Pour contributions code
- Discussions: Pour questions & idées

## 📄 License

MIT License - Libre d'utilisation commerciale

---

**Status**: MVP Ready ✅
**Version**: 1.0.0
**Dernière mise à jour**: Nov 2025
**Maintenu par**: Votre équipe
