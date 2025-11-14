# 📡 Customer Journey API - Endpoints Documentation

## Base URL
```
http://your-vast-instance:8000
```

## Authentication
Actuellement aucune authentification requise (ajouter JWT pour production).

---

## 📋 Endpoints Disponibles

### 1. Root - Information API
```http
GET /
```

**Réponse:**
```json
{
  "service": "Customer Journey API",
  "version": "1.0.0",
  "status": "running",
  "endpoints": {...}
}
```

---

### 2. Health Check
```http
GET /health
```

**Réponse:**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-14T10:30:00",
  "journeys": {
    "total": 5,
    "running": 1
  },
  "storage": {
    "journeys_dir": "./journeys",
    "screenshots_dir": "./screenshots"
  }
}
```

---

### 3. Démarrer un Journey
```http
POST /journey/start
Content-Type: application/json
```

**Body:**
```json
{
  "url": "https://example.com",
  "task": "Navigate to products, add to cart, checkout",
  "max_steps": 20,
  "screenshot_every_step": true
}
```

**Réponse:**
```json
{
  "journey_id": "abc-123-def-456",
  "status": "started",
  "message": "Customer journey started for https://example.com",
  "started_at": "2025-11-14T10:30:00"
}
```

**Paramètres:**
- `url` (required): URL du site à analyser
- `task` (required): Description du parcours client (min 5 caractères)
- `max_steps` (optional): Nombre max d'étapes (1-50, défaut: 20)
- `screenshot_every_step` (optional): Capturer screenshots (défaut: true)

---

### 4. Récupérer le Statut d'un Journey
```http
GET /journey/{journey_id}
```

**Réponse:**
```json
{
  "journey_id": "abc-123",
  "status": "completed",
  "url": "https://example.com",
  "task": "Navigate to products",
  "steps_completed": 5,
  "steps_total": 20,
  "screenshots": ["path1.png", "path2.png"],
  "actions": [
    {
      "step": 1,
      "action": "click",
      "target": "text=Products",
      "timestamp": "2025-11-14T10:30:05"
    }
  ],
  "started_at": "2025-11-14T10:30:00",
  "completed_at": "2025-11-14T10:30:45",
  "duration_seconds": 45.2,
  "error": null
}
```

**Status possibles:**
- `running`: En cours d'exécution
- `completed`: Terminé avec succès
- `failed`: Échoué (voir `error`)
- `cancelled`: Annulé par l'utilisateur
- `pending`: En attente

---

### 5. Lister les Journeys
```http
GET /journeys?limit=10&status=completed&url=example
```

**Query Parameters:**
- `limit` (optional): Nombre max de résultats (1-100, défaut: 10)
- `status` (optional): Filtrer par status (running, completed, failed)
- `url` (optional): Filtrer par URL (recherche partielle)

**Réponse:**
```json
[
  {
    "journey_id": "abc-123",
    "status": "completed",
    "url": "https://example.com",
    "task": "...",
    "steps_completed": 5,
    "steps_total": 20,
    "duration_seconds": 45.2,
    "started_at": "2025-11-14T10:30:00",
    "completed_at": "2025-11-14T10:30:45"
  }
]
```

---

### 6. Supprimer un Journey
```http
DELETE /journey/{journey_id}
```

**Réponse:**
```json
{
  "message": "Journey deleted successfully",
  "journey_id": "abc-123"
}
```

Supprime le journey, ses screenshots et le fichier JSON associé.

---

### 7. Annuler un Journey en Cours
```http
POST /journey/{journey_id}/cancel
```

**Réponse:**
```json
{
  "message": "Journey cancelled",
  "journey_id": "abc-123"
}
```

**Note:** Fonctionne uniquement pour les journeys avec status `running`.

---

### 8. Récupérer un Screenshot
```http
GET /journey/{journey_id}/screenshot/{step}?as_base64=false
```

**Query Parameters:**
- `as_base64` (optional): Retourner en base64 (défaut: false)

**Réponse (as_base64=false):**
- Fichier PNG directement

**Réponse (as_base64=true):**
```json
{
  "journey_id": "abc-123",
  "step": 1,
  "filename": "abc-123_step_1.png",
  "base64": "data:image/png;base64,iVBORw0KG..."
}
```

---

### 9. Lister tous les Screenshots d'un Journey
```http
GET /journey/{journey_id}/screenshots
```

**Réponse:**
```json
{
  "journey_id": "abc-123",
  "screenshots": [
    {
      "step": 0,
      "filename": "abc-123_step_0.png",
      "url": "/journey/abc-123/screenshot/0",
      "path": "./screenshots/abc-123_step_0.png"
    },
    {
      "step": 1,
      "filename": "abc-123_step_1.png",
      "url": "/journey/abc-123/screenshot/1",
      "path": "./screenshots/abc-123_step_1.png"
    }
  ]
}
```

---

### 10. Statistiques Globales
```http
GET /stats
```

**Réponse:**
```json
{
  "total_journeys": 25,
  "completed": 20,
  "failed": 3,
  "running": 1,
  "pending": 1,
  "avg_steps": 8.5,
  "avg_duration_seconds": 42.3
}
```

---

## 🎨 Exemples d'Utilisation Frontend

### React / Next.js Example

```typescript
// Démarrer un journey
const startJourney = async () => {
  const response = await fetch('http://your-api:8000/journey/start', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      url: 'https://example.com',
      task: 'Navigate to products and add to cart',
      max_steps: 15
    })
  });
  const data = await response.json();
  return data.journey_id;
}

// Polling pour le statut
const pollJourneyStatus = async (journeyId: string) => {
  const response = await fetch(`http://your-api:8000/journey/${journeyId}`);
  const data = await response.json();

  if (data.status === 'running') {
    // Continue polling
    setTimeout(() => pollJourneyStatus(journeyId), 2000);
  } else {
    // Journey terminé
    console.log('Journey completed:', data);
  }
}

// Récupérer screenshots
const getScreenshot = (journeyId: string, step: number) => {
  return `http://your-api:8000/journey/${journeyId}/screenshot/${step}`;
}
```

### Vue.js Example

```javascript
export default {
  data() {
    return {
      journeys: [],
      currentJourney: null
    }
  },
  methods: {
    async loadJourneys() {
      const response = await fetch('http://your-api:8000/journeys?limit=20');
      this.journeys = await response.json();
    },
    async startNewJourney(url, task) {
      const response = await fetch('http://your-api:8000/journey/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url, task })
      });
      const data = await response.json();
      this.currentJourney = data.journey_id;
      this.watchJourney();
    },
    async watchJourney() {
      const interval = setInterval(async () => {
        const response = await fetch(
          `http://your-api:8000/journey/${this.currentJourney}`
        );
        const data = await response.json();

        if (data.status !== 'running') {
          clearInterval(interval);
          console.log('Journey finished:', data);
        }
      }, 2000);
    }
  }
}
```

### JavaScript Fetch Example

```javascript
// Créer un journey
fetch('http://your-api:8000/journey/start', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    url: 'https://demo.playwright.dev/todomvc',
    task: 'Add 3 todos, mark first as complete',
    max_steps: 10
  })
})
.then(res => res.json())
.then(data => {
  console.log('Journey started:', data.journey_id);

  // Vérifier le statut toutes les 2 secondes
  const checkStatus = setInterval(() => {
    fetch(`http://your-api:8000/journey/${data.journey_id}`)
      .then(res => res.json())
      .then(status => {
        console.log('Status:', status.status,
                    'Steps:', status.steps_completed);

        if (status.status !== 'running') {
          clearInterval(checkStatus);
          console.log('Journey finished!', status);
        }
      });
  }, 2000);
});

// Récupérer les stats
fetch('http://your-api:8000/stats')
  .then(res => res.json())
  .then(stats => console.log('Stats:', stats));

// Lister les journeys complétés
fetch('http://your-api:8000/journeys?status=completed&limit=5')
  .then(res => res.json())
  .then(journeys => console.log('Completed journeys:', journeys));
```

---

## 🔒 CORS

CORS est activé pour tous les origins (`*`). En production, restreindre à vos domaines:

```python
allow_origins=["https://votre-frontend.com"]
```

---

## 📊 Codes d'Erreur HTTP

- `200`: Succès
- `201`: Créé
- `400`: Requête invalide
- `404`: Ressource non trouvée
- `422`: Erreur de validation (Pydantic)
- `500`: Erreur serveur

---

## 🚀 Documentation Interactive

Accéder à Swagger UI:
```
http://your-api:8000/docs
```

Accéder à ReDoc:
```
http://your-api:8000/redoc
```

---

## 💡 Tips Frontend

### Afficher les Screenshots
```html
<img src="http://your-api:8000/journey/{id}/screenshot/0" alt="Step 0" />
```

### Afficher la Progression
```javascript
const progress = (journey.steps_completed / journey.steps_total) * 100;
```

### WebSocket Alternative (TODO)
Pour du real-time, considérer WebSocket:
```javascript
const ws = new WebSocket('ws://your-api:8000/ws/journey/{id}');
ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  console.log('Real-time update:', update);
};
```

---

## 📞 Support

Pour questions sur l'API, ouvrir une issue sur GitHub ou consulter `/docs`.
