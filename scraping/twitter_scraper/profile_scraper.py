import asyncio
import json
import logging
import os
import random
import shutil
import signal
import subprocess
import socket
import time
from typing import Dict, Optional, List

from playwright.async_api import async_playwright, Browser, BrowserContext, Page

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger("TwitterScraper")

GLOBAL_DEFAULT_N = 4


def _find_chrome_executable() -> str:
    """Locate the real Google Chrome binary on macOS / Linux."""
    candidates = [
        # macOS
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        # Linux
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
    An asynchronous, persistent Playwright scraper for monitoring X (Twitter) profiles.
    
    Features:
    - Producer-consumer architecture via asyncio.Queue
    - Automated login bypass and session persistence
    - Disk-backed state management for tweet watermarks
    - Global and profile-specific scrape limits
    
    Detection avoidance:
    - Launches a real Chrome subprocess (NOT Playwright's bundled Chromium)
    - Connects via connect_over_cdp, avoiding the launch-time flags that
      Playwright normally injects (--enable-automation, --remote-debugging-pipe, etc.)
    """

    def __init__(
        self, 
        username: Optional[str] = None,
        password: Optional[str] = None,
        user_data_dir: str = "./playwright_chrome_data",
        state_file: str = "scraper_state.json",
        headless: bool = True,
        default_n: int = GLOBAL_DEFAULT_N
    ):
        self.username = username
        self.password = password
        # Resolve to absolute path so Chrome doesn't misinterpret it
        self.user_data_dir = os.path.abspath(user_data_dir)
        self.state_file = state_file
        self.headless = headless
        self.default_n = default_n
        
        # Profile-specific overrides for N
        self.custom_n_settings: Dict[str, int] = {}
        
        # Persistent state for watermarks
        self.state: Dict[str, str] = self._load_state()
        
        self.queue: asyncio.Queue = asyncio.Queue()
        self._playwright = None
        self._browser: Optional[Browser] = None
        self._browser_context: Optional[BrowserContext] = None
        self._chrome_proc: Optional[subprocess.Popen] = None
        self._worker_task: Optional[asyncio.Task] = None
        self._authenticated: bool = False

    def _load_state(self) -> Dict[str, str]:
        """Loads the latest tweet ID watermarks from disk."""
        if os.path.exists(self.state_file):
            try:
                with open(self.state_file, "r") as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to load state file: {e}")
        return {}

    def _save_state(self) -> None:
        """Flushes the current watermarks to disk."""
        try:
            with open(self.state_file, "w") as f:
                json.dump(self.state, f, indent=4)
        except Exception as e:
            logger.error(f"Failed to save state file: {e}")

    def set_custom_n(self, profile_url: str, n: int) -> None:
        """Assigns a custom N (number of tweets to check) for a specific profile."""
        self.custom_n_settings[profile_url] = n
        logger.info(f"Set custom N={n} for {profile_url}")

    def _get_n_for_profile(self, profile_url: str) -> int:
        """Retrieves the custom N for a profile, falling back to the global default."""
        return self.custom_n_settings.get(profile_url, self.default_n)

    async def _human_delay(self, min_s: float = 1.0, max_s: float = 3.0) -> None:
        """Sleeps for a random duration to mimic human browsing behavior."""
        delay = random.uniform(min_s, max_s)
        logger.debug(f"Human delay: {delay:.2f}s")
        await asyncio.sleep(delay)

    def _launch_real_chrome(self, debug_port: int) -> subprocess.Popen:
        """Launch a real Chrome process with a remote-debugging port.
        
        This is the key trick: instead of letting Playwright launch Chrome
        (which injects dozens of detectable flags), we launch Chrome ourselves
        with only the flags a normal user would have, plus the single
        --remote-debugging-port flag needed for Playwright to connect.
        """
        chrome_path = os.environ.get("CHROME_PATH") or _find_chrome_executable()
        
        args = [
            chrome_path,
            f"--remote-debugging-port={debug_port}",
            f"--user-data-dir={self.user_data_dir}",
            # Anti-detection: disable the AutomationControlled blink feature
            "--disable-blink-features=AutomationControlled",
            # Use a realistic window size
            "--window-size=1280,720",
        ]
        
        if self.headless:
            args.append("--headless=new")
        
        logger.info(f"Launching Chrome on debug port {debug_port}...")
        proc = subprocess.Popen(
            args,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        
        # Wait for Chrome's debug port to become available
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

    async def start(self) -> None:
        """Initializes the browser context, handles authentication, and starts the worker."""
        logger.info("Starting TwitterScraper...")
        
        # 1. Launch a *real* Chrome process ourselves (clean fingerprint)
        debug_port = _free_port()
        self._chrome_proc = self._launch_real_chrome(debug_port)
        
        # 2. Attach Playwright over CDP — this does NOT inject any launch flags
        self._playwright = await async_playwright().start()
        self._browser = await self._playwright.chromium.connect_over_cdp(
            f"http://127.0.0.1:{debug_port}"
        )
        self._browser_context = self._browser.contexts[0]
        
        # 3. Minimal stealth patches (most detection is already gone
        #    because Chrome was launched cleanly)
        await self._browser_context.add_init_script("""
            // Override navigator.webdriver — just in case
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined,
            });
        """)
        
        await self._authenticate()
        
        if not self._authenticated:
            raise RuntimeError("Authentication failed. Cannot start scraper without login.")
            
        self._worker_task = asyncio.create_task(self._worker())
        logger.info("TwitterScraper worker started and listening for commands.")

    async def stop(self) -> None:
        """Gracefully shuts down the worker and cleans up browser resources."""
        logger.info("Stopping TwitterScraper...")
        if self._worker_task:
            self._worker_task.cancel()
            
        if self._browser:
            await self._browser.close()
            
        if self._playwright:
            await self._playwright.stop()
        
        # Kill the Chrome process we launched manually
        if self._chrome_proc:
            try:
                self._chrome_proc.terminate()
                self._chrome_proc.wait(timeout=5)
            except Exception:
                self._chrome_proc.kill()
            self._chrome_proc = None
            
        self._save_state()
        logger.info("Shutdown complete.")

    async def __aenter__(self) -> "TwitterScraper":
        """Enters the async context manager by starting the scraper."""
        await self.start()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        """Exits the async context manager, guaranteeing cleanup via stop()."""
        await self.stop()

    async def _is_logged_in(self, page: Page) -> bool:
        """Returns True if the page shows a logged-in indicator."""
        try:
            await page.wait_for_selector(
                '[data-testid="SideNav_AccountSwitcher_Button"]',
                timeout=8000
            )
            return True
        except Exception:
            return False

    async def _authenticate(self) -> None:
        """Opens the login page and waits for the user to log in manually.
        
        Navigates to the login page exactly once. If cookies from a previous
        session are valid, X auto-redirects to /home and we detect the logged-in
        sidebar element. Otherwise the login form is already showing and we wait.
        """
        if not self._browser_context:
            return
            
        page = await self._browser_context.new_page()
        try:
            logger.info("Checking authentication state...")
            await page.goto("https://x.com/i/flow/login")
            
            # If cookies are valid, X redirects to /home and shows the sidebar.
            # If not, the login form is displayed — either way, one navigation.
            if await self._is_logged_in(page):
                logger.info("Already authenticated. Skipping login flow.")
                self._authenticated = True
                return
            
            # ── Manual login ─────────────────────────────────────────────
            logger.info(
                "🔑 Not logged in. Please log in manually in the browser window. "
                "Waiting for you to complete login..."
            )
            
            # Poll until the user finishes logging in (timeout after 3 min)
            for _ in range(60):
                await page.wait_for_timeout(3000)
                # Check if the user reached a logged-in state
                try:
                    acct_btn = page.locator('[data-testid="SideNav_AccountSwitcher_Button"]')
                    if await acct_btn.count() > 0:
                        logger.info("Manual login successful. Session cookies saved.")
                        self._authenticated = True
                        return
                except Exception:
                    pass
            
            logger.error("Login timed out after 3 minutes.")
            
        except Exception as e:
            logger.error(f"Authentication error: {e}")
        finally:
            await page.close()

    async def enqueue_profile(self, profile_url: str) -> None:
        """Producer method: Submits a profile to the queue for checking."""
        await self.queue.put(profile_url)
        logger.debug(f"Enqueued {profile_url} for scraping.")

    async def _worker(self) -> None:
        """Consumer loop: Continuously pulls profiles from the queue and scrapes them."""
        if not self._browser_context:
            raise RuntimeError("Browser context not initialized.")
            
        page = await self._browser_context.new_page()
        
        while True:
            try:
                profile_url = await self.queue.get()
                await self._check_profile(page, profile_url)
                self.queue.task_done()
                # Random cooldown between profile checks
                await self._human_delay(2.0, 5.0)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Worker encountered an error: {e}")

    async def _check_profile(self, page: Page, profile_url: str) -> None:
        """Navigates to the profile and extracts new tweets up to N."""
        if not self._authenticated:
            logger.error("Cannot scrape — not authenticated. Skipping.")
            return
        logger.info(f"Checking profile: {profile_url}")
        n_to_check = self._get_n_for_profile(profile_url)
        
        try:
            await page.goto(profile_url)
            await self._human_delay(1.5, 3.5)  # Pause after navigating
            await page.wait_for_selector('[data-testid="tweet"]', timeout=15000)
            await self._human_delay(1.0, 2.5)  # Pause before reading tweets
            
            tweets = page.locator('[data-testid="tweet"]')
            count = await tweets.count()
            
            new_tweets: List[Dict[str, str]] = []
            latest_id_seen: Optional[str] = None
            
            for i in range(min(n_to_check, count)):
                tweet_loc = tweets.nth(i)
                
                # Scroll tweet into view and pause like a human reading
                await tweet_loc.scroll_into_view_if_needed()
                await self._human_delay(0.5, 1.5)
                
                text = await tweet_loc.inner_text()
                
                if text.startswith("Pinned"):
                    continue
                    
                time_link = tweet_loc.locator("time").first.locator("xpath=..")
                href = await time_link.get_attribute("href")
                
                if not href:
                    continue
                    
                tweet_id = href.split("/")[-1]
                
                if not latest_id_seen:
                    latest_id_seen = tweet_id
                    
                if self.state.get(profile_url) == tweet_id:
                    break
                    
                new_tweets.append({"id": tweet_id, "text": text})
            
            if latest_id_seen:
                self.state[profile_url] = latest_id_seen
                self._save_state()
                
            for t in reversed(new_tweets):
                logger.info(f"🚨 NEW TWEET [{profile_url}] ID: {t['id']}\n{t['text'][:100]}...\n")
                # Insert your Discord webhook logic here
                
        except Exception as e:
            logger.error(f"Failed to check {profile_url}: {e}")