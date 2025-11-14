"""
Customer Journey API - Powered by Surfer-H and Holo1
"""
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
from typing import Optional, List, Dict
import uuid
import json
from datetime import datetime
from pathlib import Path

from surfer_integration.journey_runner import CustomerJourneyRunner

app = FastAPI(
    title="Customer Journey API",
    description="API pour simuler des parcours clients avec Surfer-H",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Storage
JOURNEYS_DIR = Path("/app/journeys")
SCREENSHOTS_DIR = Path("/app/screenshots")
JOURNEYS_DIR.mkdir(exist_ok=True)
SCREENSHOTS_DIR.mkdir(exist_ok=True)

# In-memory storage pour démo (remplacer par Redis/DB en prod)
journeys_status = {}


class JourneyRequest(BaseModel):
    url: HttpUrl
    task: str
    max_steps: int = 20
    screenshot_every_step: bool = True


class JourneyResponse(BaseModel):
    journey_id: str
    status: str
    message: str


class JourneyStatus(BaseModel):
    journey_id: str
    status: str
    url: str
    task: str
    steps_completed: int
    steps_total: int
    screenshots: List[str]
    actions: List[Dict]
    completed_at: Optional[str]
    error: Optional[str]


@app.get("/")
async def root():
    return {
        "service": "Customer Journey API",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}


@app.post("/journey/start", response_model=JourneyResponse)
async def start_journey(
    request: JourneyRequest,
    background_tasks: BackgroundTasks
):
    """
    Démarre un nouveau customer journey

    Exemple:
    ```
    {
        "url": "https://example-shop.com",
        "task": "Navigate to products page, add item to cart, go to checkout",
        "max_steps": 20,
        "screenshot_every_step": true
    }
    ```
    """
    journey_id = str(uuid.uuid4())

    # Initialize journey status
    journeys_status[journey_id] = {
        "journey_id": journey_id,
        "status": "running",
        "url": str(request.url),
        "task": request.task,
        "steps_completed": 0,
        "steps_total": request.max_steps,
        "screenshots": [],
        "actions": [],
        "started_at": datetime.now().isoformat(),
        "completed_at": None,
        "error": None
    }

    # Run journey in background
    background_tasks.add_task(
        run_journey,
        journey_id,
        str(request.url),
        request.task,
        request.max_steps,
        request.screenshot_every_step
    )

    return JourneyResponse(
        journey_id=journey_id,
        status="started",
        message=f"Customer journey started for {request.url}"
    )


@app.get("/journey/{journey_id}", response_model=JourneyStatus)
async def get_journey_status(journey_id: str):
    """Récupère le statut d'un journey"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    return journeys_status[journey_id]


@app.get("/journeys", response_model=List[JourneyStatus])
async def list_journeys(limit: int = 10):
    """Liste tous les journeys récents"""
    journeys = list(journeys_status.values())
    journeys.sort(key=lambda x: x.get("started_at", ""), reverse=True)
    return journeys[:limit]


async def run_journey(
    journey_id: str,
    url: str,
    task: str,
    max_steps: int,
    screenshot_every_step: bool
):
    """Execute customer journey in background"""
    try:
        runner = CustomerJourneyRunner(
            vllm_url="http://vllm:8082/v1",
            model_name="Hcompany/Holo1-7B"
        )

        # Run the journey
        result = await runner.run_journey(
            url=url,
            task=task,
            max_steps=max_steps,
            screenshot_every_step=screenshot_every_step,
            journey_id=journey_id
        )

        # Update status
        journeys_status[journey_id].update({
            "status": "completed",
            "steps_completed": result["steps_completed"],
            "screenshots": result["screenshots"],
            "actions": result["actions"],
            "completed_at": datetime.now().isoformat()
        })

        # Save to file
        journey_file = JOURNEYS_DIR / f"{journey_id}.json"
        with open(journey_file, "w") as f:
            json.dump(journeys_status[journey_id], f, indent=2)

    except Exception as e:
        journeys_status[journey_id].update({
            "status": "failed",
            "error": str(e),
            "completed_at": datetime.now().isoformat()
        })


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
