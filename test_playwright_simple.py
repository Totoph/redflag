#!/usr/bin/env python3
"""
Test simple Playwright pour Aroma Zone
Ne nécessite pas vLLM, juste Playwright
"""
import asyncio
from playwright.async_api import async_playwright
from pathlib import Path
from datetime import datetime

async def test_aroma_zone():
    print("🚀 Test Playwright - Aroma Zone")
    print("=" * 50)

    screenshots_dir = Path("./test_screenshots")
    screenshots_dir.mkdir(exist_ok=True)

    try:
        async with async_playwright() as p:
            print("1. Lancement du navigateur...")
            browser = await p.chromium.launch(
                headless=True,
                args=['--no-sandbox', '--disable-setuid-sandbox']
            )

            context = await browser.new_context(
                viewport={'width': 1920, 'height': 1080}
            )

            page = await context.new_page()

            print("2. Navigation vers Aroma Zone...")
            try:
                await page.goto(
                    'https://www.aroma-zone.com',
                    wait_until='domcontentloaded',
                    timeout=60000
                )
                print("   ✓ Page chargée")
            except Exception as e:
                print(f"   ✗ Erreur de chargement: {e}")
                await browser.close()
                return

            # Screenshot initial
            screenshot_path = screenshots_dir / "step_0_homepage.png"
            await page.screenshot(path=screenshot_path)
            print(f"   ✓ Screenshot: {screenshot_path}")

            # Get page title
            title = await page.title()
            print(f"   ✓ Titre: {title}")

            # Wait a bit
            await page.wait_for_timeout(2000)

            # Try to find common elements
            print("\n3. Recherche d'éléments...")

            # Accepter cookies si présent
            try:
                cookie_button = page.locator('button:has-text("Accepter")').first
                if await cookie_button.is_visible(timeout=3000):
                    await cookie_button.click()
                    print("   ✓ Cookies acceptés")
                    await page.wait_for_timeout(1000)
            except:
                print("   - Pas de popup cookies")

            # Screenshot après cookies
            screenshot_path = screenshots_dir / "step_1_after_cookies.png"
            await page.screenshot(path=screenshot_path)
            print(f"   ✓ Screenshot: {screenshot_path}")

            # Chercher le menu produits
            print("\n4. Navigation vers produits...")
            try:
                # Essayer plusieurs sélecteurs possibles
                selectors = [
                    'a:has-text("Produits")',
                    'a:has-text("Boutique")',
                    'a[href*="produit"]',
                    'nav a:has-text("Huiles")'
                ]

                clicked = False
                for selector in selectors:
                    try:
                        element = page.locator(selector).first
                        if await element.is_visible(timeout=2000):
                            await element.click()
                            print(f"   ✓ Cliqué sur: {selector}")
                            clicked = True
                            await page.wait_for_timeout(2000)
                            break
                    except:
                        continue

                if not clicked:
                    print("   - Aucun lien produits trouvé, on reste sur la page")

                # Screenshot
                screenshot_path = screenshots_dir / "step_2_products.png"
                await page.screenshot(path=screenshot_path)
                print(f"   ✓ Screenshot: {screenshot_path}")

            except Exception as e:
                print(f"   ✗ Erreur navigation: {e}")

            print("\n5. Fermeture du navigateur...")
            await browser.close()
            print("   ✓ Fermé")

            print("\n" + "=" * 50)
            print("✅ Test terminé avec succès !")
            print(f"📸 Screenshots dans: {screenshots_dir}/")

    except Exception as e:
        print(f"\n❌ Erreur globale: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_aroma_zone())
