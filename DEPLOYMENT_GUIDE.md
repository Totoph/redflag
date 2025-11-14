# Guide de Déploiement Vast.ai - Customer Journey MVP

## 📋 Prérequis

- Compte Vast.ai avec crédits
- Clés SSH configurées
- Git installé localement

## 🚀 Déploiement étape par étape

### Étape 1: Louer une instance sur Vast.ai

1. Aller sur https://vast.ai
2. Cliquer sur "Search" pour chercher des instances
3. Filtres recommandés:
   - **GPU**: RTX 4090 ou RTX 3090
   - **VRAM**: Min 24GB
   - **Disk Space**: Min 50GB
   - **Bandwidth**: Min 100 Mbps
   - **Docker Image**: `pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime`

4. Trier par prix et choisir une instance
5. Cliquer "Rent" et confirmer

### Étape 2: Se connecter à l'instance

```bash
# Copier la commande SSH depuis Vast.ai dashboard
ssh -p <PORT> root@<IP>

# Ou utiliser le bouton "Connect" sur le dashboard
```

### Étape 3: Setup initial

```bash
# Vérifier NVIDIA
nvidia-smi

# Créer workspace
cd /workspace

# Cloner votre repo (ou télécharger les fichiers)
git clone https://github.com/<votre-username>/redflag.git
# OU
wget <url-vers-zip> && unzip redflag.zip

cd redflag

# Exécuter le setup
chmod +x vast_setup.sh
./vast_setup.sh
```

**Temps estimé**: 5-10 minutes

### Étape 4: Configuration

```bash
# Copier l'exemple d'env
cp .env.example .env

# Éditer si nécessaire
nano .env
```

### Étape 5: Démarrer vLLM (Terminal 1)

```bash
# Dans un screen ou tmux pour garder le processus actif
screen -S vllm

# Démarrer vLLM
chmod +x start_vllm.sh
./start_vllm.sh
```

**⏱️ Première fois**: Le modèle Holo1-7B (~14GB) sera téléchargé depuis HuggingFace.
Comptez 5-15 minutes selon la bande passante.

**Vérifier que vLLM fonctionne**:
```bash
# Dans un autre terminal
curl http://localhost:8082/health
```

Détacher le screen: `Ctrl+A` puis `D`

### Étape 6: Démarrer l'API (Terminal 2)

```bash
# Dans un nouveau screen
screen -S api

# Démarrer l'API
chmod +x start_api.sh
./start_api.sh
```

**Vérifier l'API**:
```bash
curl http://localhost:8000/health
```

Détacher: `Ctrl+A` puis `D`

### Étape 7: Exposer l'API publiquement (Optionnel)

Sur Vast.ai, pour exposer le port 8000:

1. Dashboard > Your Instances > Edit
2. Ajouter port mapping: `8000:8000`
3. Récupérer l'URL publique

OU utiliser un tunnel:

```bash
# Installer cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
./cloudflared-linux-amd64 tunnel --url http://localhost:8000
```

### Étape 8: Tester

```bash
# Lister les screens actifs
screen -ls

# Test l'API
chmod +x test_customer_journey.sh
./test_customer_journey.sh
```

## 🐳 Alternative: Docker Compose

```bash
# Démarrer avec Docker
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Redémarrer un service
docker-compose restart api

# Arrêter tout
docker-compose down
```

## 📊 Monitoring

### Surveiller GPU

```bash
# Usage en temps réel
watch -n 1 nvidia-smi

# OU
gpustat -i 1
```

### Logs

```bash
# Réattacher au screen vLLM
screen -r vllm

# Réattacher au screen API
screen -r api

# Logs Docker
docker-compose logs -f vllm
docker-compose logs -f api
```

## 🔧 Configuration Avancée

### Optimiser pour GPU 16GB (RTX 4080)

Éditer `start_vllm.sh`:
```bash
vllm serve Hcompany/Holo1-7B \
    --port 8082 \
    --gpu-memory-utilization 0.85 \
    --max-model-len 2048 \
    --dtype float16
```

### Utiliser Holo1-3B (plus léger)

```bash
# Dans .env
MODEL_NAME=Hcompany/Holo1-3B

# Dans start_vllm.sh
vllm serve Hcompany/Holo1-3B --port 8082
```

### Augmenter les performances

```bash
# Enable tensor parallelism (multi-GPU)
vllm serve Hcompany/Holo1-7B \
    --tensor-parallel-size 2 \
    --port 8082
```

## 🛠️ Troubleshooting

### vLLM OOM (Out of Memory)

```bash
# Réduire le context length
--max-model-len 2048

# Réduire l'utilisation GPU
--gpu-memory-utilization 0.8

# OU utiliser Holo1-3B au lieu de 7B
```

### API lente

```bash
# Vérifier latence réseau
ping google.com

# Vérifier charge CPU
htop

# Augmenter workers API
uvicorn api.main:app --workers 4 --host 0.0.0.0 --port 8000
```

### Playwright erreurs

```bash
# Réinstaller
pip install playwright
playwright install chromium
playwright install-deps chromium

# Si erreur de permissions
apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1
```

### Connection refused

```bash
# Vérifier que les services tournent
ps aux | grep vllm
ps aux | grep uvicorn

# Vérifier ports ouverts
netstat -tlnp | grep 8082
netstat -tlnp | grep 8000
```

## 💰 Estimation des Coûts

| GPU | Prix/h | Coût 24h | Coût 30j |
|-----|--------|----------|----------|
| RTX 4090 | $0.40 | $9.60 | $288 |
| RTX 3090 | $0.30 | $7.20 | $216 |
| A100 40GB | $0.80 | $19.20 | $576 |

**Recommandation**: Utiliser auto-shutdown pour réduire les coûts:
```bash
# Arrêt automatique après 2h d'inactivité
echo "*/30 * * * * /check_idle.sh" | crontab -
```

## 🔐 Sécurité

### Ajouter authentification à l'API

```bash
pip install python-jose[cryptography] passlib[bcrypt]
```

Voir exemple dans `api/auth.py` (à créer).

### Firewall

```bash
# Limiter accès aux IPs autorisées
ufw allow from <YOUR_IP> to any port 8000
ufw enable
```

## 📈 Scaling

### Multi-instances

Pour gérer plusieurs journeys simultanés:

1. Augmenter workers API
2. Utiliser queue Redis/RabbitMQ
3. Load balancer (nginx)
4. Auto-scaling avec Kubernetes

## 🔄 Mise à jour

```bash
cd /workspace/redflag
git pull
docker-compose down
docker-compose up -d --build
```

## 📞 Support

- Issues: GitHub issues
- Vast.ai support: https://vast.ai/faq
- HuggingFace Holo1: https://huggingface.co/Hcompany/Holo1-7B

---

**Durée totale setup**: ~20-30 minutes (incluant téléchargement modèle)
