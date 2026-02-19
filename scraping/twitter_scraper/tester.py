"""
tester.py — Interactive test for TwitterScraper.

Usage:
    python tester.py

Requirements:
    pip install playwright python-dotenv
    python -m playwright install chromium
"""

import asyncio
import logging
import os
from pathlib import Path

from dotenv import load_dotenv
from profile_scraper import TwitterScraper

load_dotenv(Path(__file__).resolve().parent / ".env")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("Tester")

TWITTER_USERNAME = os.getenv("TWITTER_USERNAME", "")
TWITTER_PASSWORD = os.getenv("TWITTER_PASSWORD", "")

PROFILES = [
    "https://x.com/PeteThamel",
    "https://x.com/Brett_McMurphy",
    "https://x.com/RossDellenger",
    "https://x.com/BruceFeldmanCFB",
]


def _print_menu() -> None:
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
    ) as scraper:

        loop = asyncio.get_event_loop()

        while True:
            _print_menu()
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

            posts_json = await scraper.get_recent_posts(PROFILES[idx], n_posts=5)
            print(f"\n{posts_json}")

    logger.info("Done.")


if __name__ == "__main__":
    asyncio.run(main())
