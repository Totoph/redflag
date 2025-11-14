# 🎨 Frontend Integration Guide

Guide complet pour intégrer l'API Customer Journey dans votre frontend.

## 🔗 Base URL

Remplacez `YOUR_API_URL` par l'URL de votre instance Vast.ai:
```javascript
const API_URL = 'http://89.221.67.141:8000'; // Exemple
```

---

## 📦 Installation (Frontend)

### React / Next.js
```bash
npm install axios  # ou utilisez fetch natif
```

### Vue.js
```bash
npm install axios
```

---

## 🚀 Quick Start - React

### 1. Service API

Créer `services/journeyApi.js`:
```javascript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

export const journeyApi = {
  // Start journey
  async startJourney(url, task, maxSteps = 20) {
    const response = await fetch(`${API_URL}/journey/start`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        url,
        task,
        max_steps: maxSteps,
        screenshot_every_step: true
      })
    });
    if (!response.ok) throw new Error('Failed to start journey');
    return response.json();
  },

  // Get journey status
  async getJourney(journeyId) {
    const response = await fetch(`${API_URL}/journey/${journeyId}`);
    if (!response.ok) throw new Error('Journey not found');
    return response.json();
  },

  // List journeys
  async listJourneys(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${API_URL}/journeys?${params}`);
    return response.json();
  },

  // Get screenshot URL
  getScreenshotUrl(journeyId, step) {
    return `${API_URL}/journey/${journeyId}/screenshot/${step}`;
  },

  // Get screenshot base64
  async getScreenshotBase64(journeyId, step) {
    const response = await fetch(
      `${API_URL}/journey/${journeyId}/screenshot/${step}?as_base64=true`
    );
    return response.json();
  },

  // List screenshots
  async listScreenshots(journeyId) {
    const response = await fetch(`${API_URL}/journey/${journeyId}/screenshots`);
    return response.json();
  },

  // Cancel journey
  async cancelJourney(journeyId) {
    const response = await fetch(`${API_URL}/journey/${journeyId}/cancel`, {
      method: 'POST'
    });
    return response.json();
  },

  // Delete journey
  async deleteJourney(journeyId) {
    const response = await fetch(`${API_URL}/journey/${journeyId}`, {
      method: 'DELETE'
    });
    return response.json();
  },

  // Get stats
  async getStats() {
    const response = await fetch(`${API_URL}/stats`);
    return response.json();
  }
};
```

### 2. Hook React

Créer `hooks/useJourney.js`:
```javascript
import { useState, useEffect } from 'react';
import { journeyApi } from '../services/journeyApi';

export const useJourney = (journeyId) => {
  const [journey, setJourney] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!journeyId) return;

    let interval;

    const fetchJourney = async () => {
      try {
        const data = await journeyApi.getJourney(journeyId);
        setJourney(data);
        setLoading(false);

        // Stop polling if journey finished
        if (data.status !== 'running' && interval) {
          clearInterval(interval);
        }
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    // Initial fetch
    fetchJourney();

    // Poll every 2 seconds if running
    interval = setInterval(fetchJourney, 2000);

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [journeyId]);

  return { journey, loading, error };
};
```

### 3. Composant Journey

```jsx
import { useState } from 'react';
import { useJourney } from '../hooks/useJourney';
import { journeyApi } from '../services/journeyApi';

export default function JourneyViewer() {
  const [url, setUrl] = useState('');
  const [task, setTask] = useState('');
  const [journeyId, setJourneyId] = useState(null);

  const { journey, loading, error } = useJourney(journeyId);

  const handleStart = async () => {
    try {
      const result = await journeyApi.startJourney(url, task);
      setJourneyId(result.journey_id);
    } catch (err) {
      alert('Error: ' + err.message);
    }
  };

  const handleCancel = async () => {
    if (journey?.status === 'running') {
      await journeyApi.cancelJourney(journeyId);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Customer Journey</h1>

      {/* Form */}
      {!journeyId && (
        <div className="space-y-4">
          <input
            type="url"
            placeholder="https://example.com"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            className="w-full p-2 border rounded"
          />
          <textarea
            placeholder="Describe the customer journey..."
            value={task}
            onChange={(e) => setTask(e.target.value)}
            className="w-full p-2 border rounded"
            rows={3}
          />
          <button
            onClick={handleStart}
            className="px-4 py-2 bg-blue-500 text-white rounded"
          >
            Start Journey
          </button>
        </div>
      )}

      {/* Journey Status */}
      {journey && (
        <div className="mt-6 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold">
              Status: {journey.status}
            </h2>
            {journey.status === 'running' && (
              <button
                onClick={handleCancel}
                className="px-3 py-1 bg-red-500 text-white rounded"
              >
                Cancel
              </button>
            )}
          </div>

          <div className="bg-gray-100 p-4 rounded">
            <p><strong>URL:</strong> {journey.url}</p>
            <p><strong>Task:</strong> {journey.task}</p>
            <p><strong>Steps:</strong> {journey.steps_completed} / {journey.steps_total}</p>
            {journey.duration_seconds && (
              <p><strong>Duration:</strong> {journey.duration_seconds.toFixed(1)}s</p>
            )}
          </div>

          {/* Progress Bar */}
          <div className="w-full bg-gray-200 rounded-full h-4">
            <div
              className="bg-blue-500 h-4 rounded-full transition-all"
              style={{
                width: `${(journey.steps_completed / journey.steps_total) * 100}%`
              }}
            />
          </div>

          {/* Actions */}
          {journey.actions.length > 0 && (
            <div className="mt-4">
              <h3 className="font-semibold mb-2">Actions:</h3>
              <div className="space-y-2">
                {journey.actions.map((action, idx) => (
                  <div key={idx} className="bg-white p-2 rounded shadow-sm">
                    <span className="font-mono text-sm">
                      Step {action.step}: {action.action}
                      {action.target && ` → ${action.target}`}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Screenshots */}
          {journey.screenshots.length > 0 && (
            <div className="mt-4">
              <h3 className="font-semibold mb-2">Screenshots:</h3>
              <div className="grid grid-cols-3 gap-4">
                {journey.screenshots.map((_, idx) => (
                  <img
                    key={idx}
                    src={journeyApi.getScreenshotUrl(journeyId, idx)}
                    alt={`Step ${idx}`}
                    className="w-full rounded shadow-md hover:scale-105 transition"
                  />
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {loading && <p>Loading...</p>}
      {error && <p className="text-red-500">Error: {error}</p>}
    </div>
  );
}
```

---

## 🎨 Vue.js Example

### Composant Vue 3

```vue
<template>
  <div class="journey-viewer">
    <h1>Customer Journey</h1>

    <!-- Form -->
    <div v-if="!journeyId" class="form">
      <input v-model="url" type="url" placeholder="https://example.com" />
      <textarea v-model="task" placeholder="Describe journey..." />
      <button @click="startJourney">Start Journey</button>
    </div>

    <!-- Journey Status -->
    <div v-if="journey" class="status">
      <h2>Status: {{ journey.status }}</h2>

      <div class="progress">
        <div
          class="progress-bar"
          :style="{ width: progressPercent + '%' }"
        />
      </div>

      <p>Steps: {{ journey.steps_completed }} / {{ journey.steps_total }}</p>

      <!-- Screenshots -->
      <div class="screenshots">
        <img
          v-for="(_, idx) in journey.screenshots"
          :key="idx"
          :src="getScreenshotUrl(idx)"
          :alt="`Step ${idx}`"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const API_URL = 'http://localhost:8000';

const url = ref('');
const task = ref('');
const journeyId = ref(null);
const journey = ref(null);
let pollInterval = null;

const progressPercent = computed(() => {
  if (!journey.value) return 0;
  return (journey.value.steps_completed / journey.value.steps_total) * 100;
});

const startJourney = async () => {
  const response = await fetch(`${API_URL}/journey/start`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      url: url.value,
      task: task.value,
      max_steps: 20
    })
  });
  const data = await response.json();
  journeyId.value = data.journey_id;
};

const fetchJourney = async () => {
  if (!journeyId.value) return;

  const response = await fetch(`${API_URL}/journey/${journeyId.value}`);
  journey.value = await response.json();

  if (journey.value.status !== 'running' && pollInterval) {
    clearInterval(pollInterval);
  }
};

const getScreenshotUrl = (step) => {
  return `${API_URL}/journey/${journeyId.value}/screenshot/${step}`;
};

watch(journeyId, (newId) => {
  if (newId) {
    fetchJourney();
    pollInterval = setInterval(fetchJourney, 2000);
  }
});
</script>
```

---

## 📊 Dashboard Example

```jsx
// Dashboard.jsx - Afficher tous les journeys
import { useState, useEffect } from 'react';
import { journeyApi } from '../services/journeyApi';

export default function Dashboard() {
  const [journeys, setJourneys] = useState([]);
  const [stats, setStats] = useState(null);

  useEffect(() => {
    loadData();
    const interval = setInterval(loadData, 5000);
    return () => clearInterval(interval);
  }, []);

  const loadData = async () => {
    const [journeysData, statsData] = await Promise.all([
      journeyApi.listJourneys({ limit: 20 }),
      journeyApi.getStats()
    ]);
    setJourneys(journeysData);
    setStats(statsData);
  };

  return (
    <div className="dashboard">
      {/* Stats Cards */}
      {stats && (
        <div className="grid grid-cols-4 gap-4 mb-6">
          <div className="bg-blue-100 p-4 rounded">
            <div className="text-3xl font-bold">{stats.total_journeys}</div>
            <div>Total Journeys</div>
          </div>
          <div className="bg-green-100 p-4 rounded">
            <div className="text-3xl font-bold">{stats.completed}</div>
            <div>Completed</div>
          </div>
          <div className="bg-yellow-100 p-4 rounded">
            <div className="text-3xl font-bold">{stats.running}</div>
            <div>Running</div>
          </div>
          <div className="bg-red-100 p-4 rounded">
            <div className="text-3xl font-bold">{stats.failed}</div>
            <div>Failed</div>
          </div>
        </div>
      )}

      {/* Journeys Table */}
      <div className="bg-white rounded shadow">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th className="p-3 text-left">ID</th>
              <th className="p-3 text-left">URL</th>
              <th className="p-3 text-left">Status</th>
              <th className="p-3 text-left">Steps</th>
              <th className="p-3 text-left">Duration</th>
            </tr>
          </thead>
          <tbody>
            {journeys.map(journey => (
              <tr key={journey.journey_id} className="border-b hover:bg-gray-50">
                <td className="p-3 font-mono text-sm">
                  {journey.journey_id.slice(0, 8)}...
                </td>
                <td className="p-3">{journey.url}</td>
                <td className="p-3">
                  <span className={`badge badge-${journey.status}`}>
                    {journey.status}
                  </span>
                </td>
                <td className="p-3">
                  {journey.steps_completed}/{journey.steps_total}
                </td>
                <td className="p-3">
                  {journey.duration_seconds?.toFixed(1)}s
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
```

---

## 🌐 Variables d'Environnement

### Next.js `.env.local`
```bash
NEXT_PUBLIC_API_URL=http://89.221.67.141:8000
```

### React (Vite) `.env`
```bash
VITE_API_URL=http://89.221.67.141:8000
```

---

## 🔒 CORS Configuration

Si vous avez des problèmes CORS, vérifiez que l'API autorise votre origine dans `api/main.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "https://your-frontend.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 💡 Tips & Best Practices

### 1. Error Handling
```javascript
try {
  const journey = await journeyApi.startJourney(url, task);
} catch (error) {
  if (error.status === 422) {
    alert('Invalid data: ' + error.message);
  } else {
    alert('Server error');
  }
}
```

### 2. Loading States
```jsx
{loading && <Spinner />}
{error && <ErrorMessage error={error} />}
{journey && <JourneyDetails journey={journey} />}
```

### 3. Optimistic Updates
```javascript
// Start journey, update UI immédiatement
setJourneys([...journeys, { id: tempId, status: 'starting' }]);
const result = await journeyApi.startJourney(url, task);
// Update with real data
setJourneys(prev => prev.map(j => j.id === tempId ? result : j));
```

### 4. Debounce Polling
```javascript
// Éviter trop de requêtes
const debouncedPoll = useMemo(
  () => debounce(fetchJourney, 2000),
  [journeyId]
);
```

---

## 📱 Responsive Design

```css
/* Mobile-first */
.screenshots {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}

@media (min-width: 768px) {
  .screenshots {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .screenshots {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

## 🚀 Deployment

### Vercel / Netlify
```bash
# Set environment variable
NEXT_PUBLIC_API_URL=http://your-vast-instance:8000
```

### Docker
```dockerfile
ENV NEXT_PUBLIC_API_URL=http://api:8000
```

---

## 📞 Support

- API Documentation: `http://your-api:8000/docs`
- Issues: GitHub
