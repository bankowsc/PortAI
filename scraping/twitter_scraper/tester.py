"""
tester.py — Interactive integration test for TwitterScraper.

Usage:
    python tester.py

Flow:
    1. Launches the scraper (with credentials) inside an async context manager.
    2. Scrapes every profile in PROFILES once on startup.
    3. Drops into an interactive loop where you can enter a profile index
       to re-check, or press 'q' to quit.

Requirements:
    pip install playwright python-dotenv
    python -m playwright install chromium
"""

import asyncio
import logging
import os
from time import sleep
from pathlib import Path

from dotenv import load_dotenv
from profile_scraper import TwitterScraper

# Load .env from the same directory as this script
load_dotenv(Path(__file__).resolve().parent / ".env")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("Tester")

# ── Credentials (loaded from .env) ──────────────────────────────────────────
TWITTER_USERNAME = os.getenv("TWITTER_USERNAME", "")
TWITTER_PASSWORD = os.getenv("TWITTER_PASSWORD", "")

# ── Profiles to monitor (fill these in) ─────────────────────────────────────
PROFILES = [
    "https://x.com/PeteThamel",
    "https://x.com/Brett_McMurphy",
    "https://x.com/RossDellenger",
    "https://x.com/BruceFeldmanCFB"
]


def _print_menu() -> None:
    """Prints the numbered profile list and prompt."""
    print("\n" + "═" * 50)
    print("PROFILES:")
    for i, url in enumerate(PROFILES):
        print(f"  [{i}] {url}")
    print("═" * 50)
    print("Enter a profile index to check, or 'q' to quit.")


async def main() -> None:
    async with TwitterScraper(
        username=TWITTER_USERNAME,
        password=TWITTER_PASSWORD,
        headless=False,
    ) as scraper:

        # ── Initial pass: scrape every profile once ──────────────────────
        logger.info("Running initial scrape of all profiles...")
        for url in PROFILES:
            sleep(1)
            await scraper.enqueue_profile(url)
        await scraper.queue.join()
        logger.info("Initial scrape complete.")

        # ── Interactive loop ─────────────────────────────────────────────
        loop = asyncio.get_event_loop()

        while True:
            _print_menu()

            # Read input without blocking the event loop
            user_input = await loop.run_in_executor(None, input, "> ")
            user_input = user_input.strip()

            if user_input.lower() == "q":
                logger.info("Quitting...")
                break

            try:
                idx = int(user_input)
                if idx < 0 or idx >= len(PROFILES):
                    print(f"Invalid index. Enter 0–{len(PROFILES) - 1}.")
                    continue
            except ValueError:
                print("Please enter a valid integer or 'q'.")
                continue

            await scraper.enqueue_profile(PROFILES[idx])
            await scraper.queue.join()
            logger.info(f"Finished checking {PROFILES[idx]}")

    # __aexit__ guarantees browser cleanup here
    logger.info("Done.")


if __name__ == "__main__":
    asyncio.run(main())
