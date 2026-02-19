import asyncio
import json
import logging
import os
import random
import shutil
import signal
import socket
import subprocess
import time
from typing import Dict, List, Optional

from playwright.async_api import async_playwright, Browser, BrowserContext, Page

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("TwitterScraper")


def _find_chrome_executable() -> str:
    """Locate the real Google Chrome binary on macOS / Linux."""
    candidates = [
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        shutil.which("google-chrome") or "",
        shutil.which("google-chrome-stable") or "",
    ]
    for c in candidates:
        if c and os.path.isfile(c):
            return c
    raise FileNotFoundError(
        "Could not find Google Chrome. Install it or set CHROME_PATH env var."
    )


def _free_port() -> int:
    """Return a random free TCP port."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


class TwitterScraper:
    """
    Async Playwright scraper for X (Twitter) profiles.

    Public API:
        scraper = TwitterScraper(username, password)
        posts   = await scraper.get_recent_posts("https://x.com/elonmusk", 5)

    Detection avoidance:
        - Launches a real Chrome subprocess (not Playwright's bundled Chromium)
        - Connects via CDP, avoiding detectable automation flags
    """

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password

        self._user_data_dir = os.path.abspath("./playwright_chrome_data")
        self._playwright = None
        self._browser: Optional[Browser] = None
        self._browser_context: Optional[BrowserContext] = None
        self._chrome_proc: Optional[subprocess.Popen] = None
        self._authenticated: bool = False

    # ── Browser lifecycle (private) ──────────────────────────────────────

    def _launch_real_chrome(self, debug_port: int) -> subprocess.Popen:
        """Launch a real Chrome process with a remote-debugging port."""
        chrome_path = os.environ.get("CHROME_PATH") or _find_chrome_executable()

        args = [
            chrome_path,
            f"--remote-debugging-port={debug_port}",
            f"--user-data-dir={self._user_data_dir}",
            "--disable-blink-features=AutomationControlled",
            "--window-size=1280,720",
        ]

        logger.info(f"Launching Chrome on debug port {debug_port}...")
        proc = subprocess.Popen(
            args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )

        for _ in range(30):
            try:
                with socket.create_connection(("127.0.0.1", debug_port), timeout=1):
                    break
            except OSError:
                time.sleep(0.5)
        else:
            proc.kill()
            raise RuntimeError(
                f"Chrome did not open debug port {debug_port} within 15 s"
            )

        logger.info("Chrome is up and listening.")
        return proc

    async def _ensure_browser(self) -> None:
        """Start browser + authenticate if not already running."""
        if self._browser and self._authenticated:
            return

        debug_port = _free_port()
        self._chrome_proc = self._launch_real_chrome(debug_port)

        self._playwright = await async_playwright().start()
        self._browser = await self._playwright.chromium.connect_over_cdp(
            f"http://127.0.0.1:{debug_port}"
        )
        self._browser_context = self._browser.contexts[0]

        await self._browser_context.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined,
            });
        """)

        await self._authenticate()
        if not self._authenticated:
            await self._shutdown()
            raise RuntimeError(
                "Authentication failed. Cannot scrape without login."
            )

    async def _shutdown(self) -> None:
        """Clean up browser resources."""
        if self._browser:
            await self._browser.close()
            self._browser = None

        if self._playwright:
            await self._playwright.stop()
            self._playwright = None

        if self._chrome_proc:
            try:
                self._chrome_proc.terminate()
                self._chrome_proc.wait(timeout=5)
            except Exception:
                self._chrome_proc.kill()
            self._chrome_proc = None

        self._authenticated = False

    # ── Authentication (private) ─────────────────────────────────────────

    async def _is_logged_in(self, page: Page) -> bool:
        """Returns True if the page shows a logged-in indicator."""
        try:
            await page.wait_for_selector(
                '[data-testid="SideNav_AccountSwitcher_Button"]', timeout=8000
            )
            return True
        except Exception:
            return False

    async def _authenticate(self) -> None:
        """Log in via cookies or manual flow.

        X's login page often fails to render properly on the first load.
        This method retries navigation up to 5 times until the login form
        (or a logged-in indicator) actually appears.
        """
        if not self._browser_context:
            return

        page = await self._browser_context.new_page()
        try:
            logger.info("Checking authentication state...")

            # ── Try loading the login page (with retries) ────────────────
            login_form_ready = False
            for attempt in range(1, 6):
                try:
                    await page.goto(
                        "https://x.com/i/flow/login",
                        wait_until="domcontentloaded",
                        timeout=60000,
                    )
                except Exception as nav_err:
                    logger.warning(
                        f"Navigation failed (attempt {attempt}/5): {nav_err}"
                    )
                    await self._human_delay(2.0, 4.0)
                    continue

                # Already logged in from saved cookies?
                if await self._is_logged_in(page):
                    logger.info("Already authenticated (session cookies valid).")
                    self._authenticated = True
                    return

                # Check whether the login form actually rendered
                try:
                    await page.wait_for_selector(
                        'input[autocomplete="username"]', timeout=8000
                    )
                    login_form_ready = True
                    break
                except Exception:
                    logger.warning(
                        f"Login form did not render (attempt {attempt}/5). "
                        "Refreshing..."
                    )
                    await self._human_delay(1.0, 2.0)

            if not login_form_ready:
                logger.error(
                    "Login form failed to render after 5 attempts. "
                    "Try deleting ./playwright_chrome_data and retrying."
                )
                return

            # ── Wait for manual login ────────────────────────────────────
            logger.info(
                "🔑 Not logged in. Please log in manually in the browser window. "
                "Waiting up to 3 minutes..."
            )

            for _ in range(60):
                await page.wait_for_timeout(8000)
                try:
                    btn = page.locator(
                        '[data-testid="SideNav_AccountSwitcher_Button"]'
                    )
                    if await btn.count() > 0:
                        logger.info("Manual login successful.")
                        self._authenticated = True
                        return
                except Exception:
                    pass

            logger.error("Login timed out after 3 minutes.")

        except Exception as e:
            logger.error(f"Authentication error: {e}")
        finally:
            await page.close()

    # ── Helpers (private) ────────────────────────────────────────────────

    async def _human_delay(self, min_s: float = 1.0, max_s: float = 3.0) -> None:
        """Sleep for a random duration to mimic human behaviour."""
        await asyncio.sleep(random.uniform(min_s, max_s))

    # ── Public API ───────────────────────────────────────────────────────

    async def get_recent_posts(self, profile: str, n_posts: int = 5) -> str:
        """
        Scrape the most recent posts from an X profile.

        Args:
            profile:  Full profile URL, e.g. "https://x.com/elonmusk"
            n_posts:  Maximum number of posts to retrieve.

        Returns:
            A JSON string containing a list of post objects, each with
            keys "id", "text", and "url".
        """
        await self._ensure_browser()

        page = await self._browser_context.new_page()
        posts: List[Dict[str, str]] = []

        try:
            logger.info(f"Scraping up to {n_posts} posts from {profile}")
            await page.goto(profile)
            await self._human_delay(1.5, 3.5)
            await page.wait_for_selector('[data-testid="tweet"]', timeout=15000)
            await self._human_delay(1.0, 2.5)

            tweets = page.locator('[data-testid="tweet"]')
            count = await tweets.count()

            for i in range(min(n_posts, count)):
                tweet = tweets.nth(i)

                await tweet.scroll_into_view_if_needed()
                await self._human_delay(0.5, 1.5)

                text = await tweet.inner_text()

                # Skip pinned tweets
                if text.startswith("Pinned"):
                    continue

                time_link = tweet.locator("time").first.locator("xpath=..")
                href = await time_link.get_attribute("href")
                if not href:
                    continue

                tweet_id = href.split("/")[-1]
                posts.append(
                    {
                        "id": tweet_id,
                        "text": text,
                        "url": f"https://x.com{href}",
                    }
                )

        except Exception as e:
            logger.error(f"Failed to scrape {profile}: {e}")
        finally:
            await page.close()

        return json.dumps(posts, indent=2, ensure_ascii=False)

    # ── Async context-manager support ────────────────────────────────────

    async def __aenter__(self) -> "TwitterScraper":
        await self._ensure_browser()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        await self._shutdown()