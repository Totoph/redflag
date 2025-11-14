"""
Customer Journey API - Powered by Surfer-H and Holo1
"""
from fastapi import FastAPI, HTTPException, BackgroundTasks, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, HttpUrl, Field
from typing import Optional, List, Dict, Any
import uuid
import json
import os
from datetime import datetime
from pathlib import Path
import base64

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

# Storage - Support both Docker and local paths
if os.path.exists("/app"):
    JOURNEYS_DIR = Path("/app/journeys")
    SCREENSHOTS_DIR = Path("/app/screenshots")
else:
    JOURNEYS_DIR = Path("./journeys")
    SCREENSHOTS_DIR = Path("./screenshots")

JOURNEYS_DIR.mkdir(exist_ok=True)
SCREENSHOTS_DIR.mkdir(exist_ok=True)

# In-memory storage pour démo (remplacer par Redis/DB en prod)
journeys_status = {}


class JourneyRequest(BaseModel):
    url: HttpUrl = Field(..., description="URL du site web à analyser")
    task: str = Field(..., description="Description du parcours client à effectuer", min_length=5)
    max_steps: int = Field(20, ge=1, le=50, description="Nombre maximum d'étapes")
    screenshot_every_step: bool = Field(True, description="Capturer un screenshot à chaque étape")

    class Config:
        json_schema_extra = {
            "example": {
                "url": "https://demo.playwright.dev/todomvc",
                "task": "Add 3 todo items, mark first as complete",
                "max_steps": 15,
                "screenshot_every_step": True
            }
        }


class JourneyResponse(BaseModel):
    journey_id: str
    status: str
    message: str
    started_at: str


class JourneyStatus(BaseModel):
    journey_id: str
    status: str
    url: str
    task: str
    steps_completed: int
    steps_total: int
    screenshots: List[str]
    actions: List[Dict]
    started_at: str
    completed_at: Optional[str] = None
    error: Optional[str] = None
    duration_seconds: Optional[float] = None


class JourneyStats(BaseModel):
    total_journeys: int
    completed: int
    failed: int
    running: int
    pending: int
    avg_steps: float
    avg_duration_seconds: Optional[float] = None


class ScreenshotResponse(BaseModel):
    journey_id: str
    step: int
    filename: str
    url: str
    base64: Optional[str] = None


@app.get("/")
async def root():
    """Root endpoint - API information"""
    return {
        "service": "Customer Journey API",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "docs": "/docs",
            "health": "/health",
            "start_journey": "/journey/start",
            "list_journeys": "/journeys",
            "get_journey": "/journey/{journey_id}",
            "delete_journey": "/journey/{journey_id}",
            "get_screenshot": "/journey/{journey_id}/screenshot/{step}",
            "stats": "/stats"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint with system info"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "journeys": {
            "total": len(journeys_status),
            "running": len([j for j in journeys_status.values() if j.get("status") == "running"])
        },
        "storage": {
            "journeys_dir": str(JOURNEYS_DIR),
            "screenshots_dir": str(SCREENSHOTS_DIR)
        }
    }


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
        message=f"Customer journey started for {request.url}",
        started_at=journeys_status[journey_id]["started_at"]
    )


@app.get("/journey/{journey_id}", response_model=JourneyStatus)
async def get_journey_status(journey_id: str):
    """Récupère le statut détaillé d'un journey"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    journey = journeys_status[journey_id].copy()

    # Calculate duration if completed
    if journey.get("completed_at") and journey.get("started_at"):
        try:
            start = datetime.fromisoformat(journey["started_at"])
            end = datetime.fromisoformat(journey["completed_at"])
            journey["duration_seconds"] = (end - start).total_seconds()
        except:
            journey["duration_seconds"] = None

    return journey


@app.get("/journeys", response_model=List[JourneyStatus])
async def list_journeys(
    limit: int = Query(10, ge=1, le=100, description="Nombre maximum de journeys à retourner"),
    status: Optional[str] = Query(None, description="Filtrer par status: running, completed, failed"),
    url: Optional[str] = Query(None, description="Filtrer par URL (contient)")
):
    """Liste tous les journeys récents avec filtres optionnels"""
    journeys = list(journeys_status.values())

    # Apply filters
    if status:
        journeys = [j for j in journeys if j.get("status") == status]

    if url:
        journeys = [j for j in journeys if url.lower() in j.get("url", "").lower()]

    # Calculate duration for each
    for journey in journeys:
        if journey.get("completed_at") and journey.get("started_at"):
            try:
                start = datetime.fromisoformat(journey["started_at"])
                end = datetime.fromisoformat(journey["completed_at"])
                journey["duration_seconds"] = (end - start).total_seconds()
            except:
                journey["duration_seconds"] = None

    journeys.sort(key=lambda x: x.get("started_at", ""), reverse=True)
    return journeys[:limit]


@app.delete("/journey/{journey_id}")
async def delete_journey(journey_id: str):
    """Supprime un journey et ses screenshots"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    journey = journeys_status[journey_id]

    # Delete screenshots
    for screenshot_path in journey.get("screenshots", []):
        try:
            if os.path.exists(screenshot_path):
                os.remove(screenshot_path)
        except Exception as e:
            print(f"Error deleting screenshot {screenshot_path}: {e}")

    # Delete journey file
    journey_file = JOURNEYS_DIR / f"{journey_id}.json"
    if journey_file.exists():
        journey_file.unlink()

    # Remove from memory
    del journeys_status[journey_id]

    return {"message": "Journey deleted successfully", "journey_id": journey_id}


@app.post("/journey/{journey_id}/cancel")
async def cancel_journey(journey_id: str):
    """Annule un journey en cours d'exécution"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    journey = journeys_status[journey_id]

    if journey.get("status") != "running":
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel journey with status: {journey.get('status')}"
        )

    # Mark as cancelled
    journeys_status[journey_id].update({
        "status": "cancelled",
        "completed_at": datetime.now().isoformat(),
        "error": "Cancelled by user"
    })

    return {"message": "Journey cancelled", "journey_id": journey_id}


@app.get("/journey/{journey_id}/screenshot/{step}")
async def get_screenshot(
    journey_id: str,
    step: int,
    as_base64: bool = Query(False, description="Retourner en base64 au lieu d'un fichier")
):
    """Récupère un screenshot spécifique d'un journey"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    journey = journeys_status[journey_id]
    screenshots = journey.get("screenshots", [])

    # Find screenshot for this step
    screenshot_path = None
    for path in screenshots:
        if f"_step_{step}." in path:
            screenshot_path = path
            break

    if not screenshot_path or not os.path.exists(screenshot_path):
        raise HTTPException(status_code=404, detail=f"Screenshot for step {step} not found")

    if as_base64:
        # Return as base64 JSON
        with open(screenshot_path, "rb") as f:
            image_data = base64.b64encode(f.read()).decode()

        return {
            "journey_id": journey_id,
            "step": step,
            "filename": os.path.basename(screenshot_path),
            "base64": f"data:image/png;base64,{image_data}"
        }
    else:
        # Return as image file
        return FileResponse(
            screenshot_path,
            media_type="image/png",
            filename=os.path.basename(screenshot_path)
        )


@app.get("/journey/{journey_id}/screenshots")
async def list_screenshots(journey_id: str):
    """Liste tous les screenshots d'un journey"""
    if journey_id not in journeys_status:
        raise HTTPException(status_code=404, detail="Journey not found")

    journey = journeys_status[journey_id]
    screenshots = journey.get("screenshots", [])

    result = []
    for path in screenshots:
        if os.path.exists(path):
            # Extract step number from filename
            filename = os.path.basename(path)
            try:
                step = int(filename.split("_step_")[1].split(".")[0])
            except:
                step = -1

            result.append({
                "step": step,
                "filename": filename,
                "url": f"/journey/{journey_id}/screenshot/{step}",
                "path": path
            })

    result.sort(key=lambda x: x["step"])
    return {"journey_id": journey_id, "screenshots": result}


@app.get("/stats", response_model=JourneyStats)
async def get_statistics():
    """Récupère des statistiques globales sur tous les journeys"""
    journeys = list(journeys_status.values())

    total = len(journeys)
    completed = len([j for j in journeys if j.get("status") == "completed"])
    failed = len([j for j in journeys if j.get("status") == "failed"])
    running = len([j for j in journeys if j.get("status") == "running"])
    pending = len([j for j in journeys if j.get("status") == "pending"])

    # Calculate average steps
    steps_list = [j.get("steps_completed", 0) for j in journeys if j.get("steps_completed", 0) > 0]
    avg_steps = sum(steps_list) / len(steps_list) if steps_list else 0

    # Calculate average duration
    durations = []
    for j in journeys:
        if j.get("completed_at") and j.get("started_at"):
            try:
                start = datetime.fromisoformat(j["started_at"])
                end = datetime.fromisoformat(j["completed_at"])
                durations.append((end - start).total_seconds())
            except:
                pass

    avg_duration = sum(durations) / len(durations) if durations else None

    return JourneyStats(
        total_journeys=total,
        completed=completed,
        failed=failed,
        running=running,
        pending=pending,
        avg_steps=round(avg_steps, 2),
        avg_duration_seconds=round(avg_duration, 2) if avg_duration else None
    )


async def run_journey(
    journey_id: str,
    url: str,
    task: str,
    max_steps: int,
    screenshot_every_step: bool
):
    """Execute customer journey in background"""
    try:
        # Support both Docker and local deployment
        vllm_url = os.getenv("VLLM_URL", "http://localhost:8082/v1")
        if not vllm_url.endswith("/v1"):
            vllm_url = vllm_url.rstrip("/") + "/v1"

        runner = CustomerJourneyRunner(
            vllm_url=vllm_url,
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
