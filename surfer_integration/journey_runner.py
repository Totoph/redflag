"""
Customer Journey Runner - Intégration avec Surfer-H et Holo1
"""
import asyncio
from playwright.async_api import async_playwright
from pathlib import Path
from typing import List, Dict, Optional
import base64
from datetime import datetime
import httpx


class CustomerJourneyRunner:
    """
    Exécute un parcours client en utilisant Playwright + Holo1 VLM
    """

    def __init__(self, vllm_url: str, model_name: str):
        self.vllm_url = vllm_url
        self.model_name = model_name
        self.screenshots_dir = Path("/app/screenshots")
        self.screenshots_dir.mkdir(exist_ok=True)

    async def run_journey(
        self,
        url: str,
        task: str,
        max_steps: int = 20,
        screenshot_every_step: bool = True,
        journey_id: Optional[str] = None
    ) -> Dict:
        """
        Exécute un customer journey complet

        Returns:
            Dict avec résultats du journey
        """
        journey_id = journey_id or f"journey_{datetime.now().timestamp()}"
        screenshots = []
        actions = []

        async with async_playwright() as p:
            # Launch browser
            browser = await p.chromium.launch(
                headless=True,
                args=['--no-sandbox', '--disable-setuid-sandbox']
            )

            context = await browser.new_context(
                viewport={'width': 1920, 'height': 1080}
            )

            page = await context.new_page()

            try:
                # Navigate to initial URL
                await page.goto(url, wait_until='networkidle')
                await page.wait_for_timeout(2000)

                # Initial screenshot
                screenshot_path = self.screenshots_dir / f"{journey_id}_step_0.png"
                await page.screenshot(path=screenshot_path)
                screenshots.append(str(screenshot_path))

                actions.append({
                    "step": 0,
                    "action": "navigate",
                    "target": url,
                    "timestamp": datetime.now().isoformat()
                })

                # Execute journey steps
                for step in range(1, max_steps + 1):
                    # Get current page screenshot
                    screenshot_bytes = await page.screenshot()
                    screenshot_b64 = base64.b64encode(screenshot_bytes).decode()

                    # Get page HTML for context
                    html_content = await page.content()

                    # Ask Holo1 what to do next
                    action = await self._get_next_action(
                        screenshot_b64=screenshot_b64,
                        html_content=html_content,
                        task=task,
                        step=step
                    )

                    if action["type"] == "complete":
                        actions.append({
                            "step": step,
                            "action": "complete",
                            "reason": action.get("reason", "Task completed"),
                            "timestamp": datetime.now().isoformat()
                        })
                        break

                    # Execute action
                    await self._execute_action(page, action)

                    # Record action
                    actions.append({
                        "step": step,
                        "action": action["type"],
                        "target": action.get("target"),
                        "value": action.get("value"),
                        "timestamp": datetime.now().isoformat()
                    })

                    # Wait for page to stabilize
                    await page.wait_for_timeout(1500)

                    # Take screenshot
                    if screenshot_every_step:
                        screenshot_path = self.screenshots_dir / f"{journey_id}_step_{step}.png"
                        await page.screenshot(path=screenshot_path)
                        screenshots.append(str(screenshot_path))

            finally:
                await browser.close()

        return {
            "journey_id": journey_id,
            "steps_completed": len(actions),
            "screenshots": screenshots,
            "actions": actions
        }

    async def _get_next_action(
        self,
        screenshot_b64: str,
        html_content: str,
        task: str,
        step: int
    ) -> Dict:
        """
        Demande à Holo1 quelle action effectuer

        Pour simplifier le MVP, on utilise une approche heuristique
        En production, vous devez appeler l'API Holo1 pour analyse VLM
        """
        # TODO: Implémenter appel réel à Holo1 via vLLM API
        # Pour le MVP, on retourne des actions basiques

        # Exemple d'actions possibles:
        # - {"type": "click", "target": "selector"}
        # - {"type": "type", "target": "selector", "value": "text"}
        # - {"type": "scroll", "direction": "down", "pixels": 500}
        # - {"type": "navigate", "url": "..."}
        # - {"type": "complete"}

        # Pour démo: parsing basique de la task
        task_lower = task.lower()

        if step == 1 and "product" in task_lower:
            return {"type": "click", "target": "text=Products"}
        elif step == 2 and "cart" in task_lower:
            return {"type": "click", "target": "text=Add to cart"}
        elif step == 3 and "checkout" in task_lower:
            return {"type": "click", "target": "text=Checkout"}
        else:
            return {"type": "complete", "reason": "Task simulation completed"}

    async def _execute_action(self, page, action: Dict):
        """Exécute une action sur la page"""
        action_type = action["type"]

        if action_type == "click":
            target = action["target"]
            try:
                await page.click(target, timeout=5000)
            except Exception as e:
                print(f"Click failed on {target}: {e}")

        elif action_type == "type":
            target = action["target"]
            value = action["value"]
            await page.fill(target, value)

        elif action_type == "scroll":
            pixels = action.get("pixels", 500)
            await page.evaluate(f"window.scrollBy(0, {pixels})")

        elif action_type == "navigate":
            url = action["url"]
            await page.goto(url, wait_until='networkidle')

        elif action_type == "wait":
            ms = action.get("ms", 1000)
            await page.wait_for_timeout(ms)


async def call_holo1_vlm(
    vllm_url: str,
    model_name: str,
    image_b64: str,
    prompt: str
) -> str:
    """
    Appelle Holo1 via vLLM pour analyse d'image
    """
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{vllm_url}/chat/completions",
            json={
                "model": model_name,
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": prompt},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/png;base64,{image_b64}"
                                }
                            }
                        ]
                    }
                ],
                "max_tokens": 500
            }
        )
        result = response.json()
        return result["choices"][0]["message"]["content"]
