"""
ESPN College Football Player Stats Scraper — Full Data (all pages)
===================================================================
Requirements:
    pip install selenium webdriver-manager beautifulsoup4 pandas lxml
Usage:
    python espn_cfb_scraper.py
"""

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import pandas as pd
import time
import os

# ── Config ────────────────────────────────────────────────────────────────────

URLS = {
    #"espn_passing_2024":   "https://www.espn.com/college-football/stats/player/_/season/2024",
    #"espn_rushing_2024":   "https://www.espn.com/college-football/stats/player/_/stat/rushing/season/2024",
    #"espn_receiving_2024": "https://www.espn.com/college-football/stats/player/_/stat/receiving/season/2024",
    "espn_defense_2024":   "https://www.espn.com/college-football/stats/player/_/view/defense/season/2024",
    #"espn_scoring_2024":   "https://www.espn.com/college-football/stats/player/_/view/scoring/season/2024",
    "espn_returning_2024":   "https://www.espn.com/college-football/stats/player/_/view/special/season/2024",
    "espn_kicking_2024":   "https://www.espn.com/college-football/stats/player/_/view/special/stat/kicking/season/2024",
    "espn_punting_2024":   "https://www.espn.com/college-football/stats/player/_/view/special/stat/punting/season/2024",
}

OUTPUT_DIR = "espn_cfb_stats"
DELAY = 1.5  # seconds to wait after each "Show More" click


# ── Driver setup ──────────────────────────────────────────────────────────────

def get_driver():
    opts = Options()
    opts.add_argument("--headless")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--window-size=1920,1080")
    opts.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
    return webdriver.Chrome(
        service=Service(ChromeDriverManager().install()), options=opts
    )


# ── Debug helper ──────────────────────────────────────────────────────────────

def debug_show_more_button(driver):
    """Print tag/class/text of any element mentioning 'show more' — helps nail down the selector."""
    elems = driver.find_elements(
        By.XPATH,
        "//*[contains(translate(text(),'SHOWMORE ','showmore '),'show more')]"
    )
    if elems:
        print("  [DEBUG] Found 'show more' elements:")
        for e in elems:
            print(f"    TAG: {e.tag_name}  CLASS: {e.get_attribute('class')}  TEXT: {repr(e.text)}")
    else:
        print("  [DEBUG] No 'show more' elements found in DOM.")


# ── Click through all "Show More" ─────────────────────────────────────────────

def click_show_more(driver):
    """Keep clicking 'Show More' until it's gone. Returns total clicks made."""
    clicks = 0
    while True:
        try:
            btn = None
            selectors = [
                (By.XPATH,       "//a[contains(@class,'ShowMore')]"),
                (By.XPATH,       "//a[contains(@class,'showMore')]"),
                (By.XPATH,       "//button[contains(@class,'ShowMore')]"),
                (By.XPATH,       "//button[contains(@class,'showMore')]"),
                (By.XPATH,       "//a[normalize-space(text())='Show More']"),
                (By.XPATH,       "//button[normalize-space(text())='Show More']"),
                (By.XPATH,       "//div[contains(@class,'ShowMore')]//a"),
                (By.XPATH,       "//div[contains(@class,'showMore')]//a"),
                (By.CSS_SELECTOR, "a.ShowMore"),
                (By.CSS_SELECTOR, "div.ShowMore a"),
                (By.CSS_SELECTOR, "button.ShowMore"),
            ]

            for by, selector in selectors:
                try:
                    btn = WebDriverWait(driver, 3).until(
                        EC.element_to_be_clickable((by, selector))
                    )
                    break  # found it
                except TimeoutException:
                    continue

            if btn is None:
                break  # no button found with any selector — we're done

            driver.execute_script("arguments[0].scrollIntoView(true);", btn)
            time.sleep(0.5)
            driver.execute_script("arguments[0].click();", btn)  # JS click avoids overlay issues
            clicks += 1
            print(f"    Clicked 'Show More' ({clicks}x)...", end="\r")
            time.sleep(DELAY)

        except Exception as e:
            print(f"\n    Stopped at click {clicks}: {e}")
            break

    if clicks:
        print(f"    Clicked 'Show More' {clicks} times — all rows loaded.     ")
    else:
        print("    'Show More' button not found — running debug check...")
        debug_show_more_button(driver)

    return clicks


# ── Parse the loaded HTML ─────────────────────────────────────────────────────

def parse_stats_table(soup):
    """
    ESPN uses two side-by-side tables:
      Table 1 — RK, Name (with team embedded as a sub-element), POS
      Table 2 — stat columns

    The player name and team are in the same <td> but in separate elements:
      <td>
        <a>Drew Mestemaker</a>  ← player name
        <span>UNT</span>        ← team
      </td>

    We manually extract name + team from Table 1, then merge with Table 2.
    """
    tables = soup.find_all("table")
    if not tables:
        print("  No <table> tags found.")
        return None

    # ── Manually parse Table 1 for RK, Name, Team, POS ──────────────────────
    rows = []
    table1 = tables[0]
    for tr in table1.find_all("tr"):
        tds = tr.find_all("td")
        if not tds:
            continue

        row = {}

        for i, td in enumerate(tds):
            if i == 0:
                row["RK"] = td.get_text(strip=True)

            elif i == 1:
                # Name is in <a>, team is in a nested <span> or <a> after it
                anchors = td.find_all("a")
                spans   = td.find_all("span")

                if anchors:
                    row["NAME"] = anchors[0].get_text(strip=True)
                else:
                    row["NAME"] = td.get_text(strip=True)

                # Team is usually the last <span> or second <a>
                if len(anchors) >= 2:
                    row["TEAM"] = anchors[1].get_text(strip=True)
                elif spans:
                    row["TEAM"] = spans[-1].get_text(strip=True)
                else:
                    row["TEAM"] = ""

            elif i == 2:
                row["POS"] = td.get_text(strip=True)

        if row:
            rows.append(row)

    if not rows:
        print("  Could not parse player info from Table 1.")
        return None

    df_info = pd.DataFrame(rows)

    # ── Parse Table 2 for stats ───────────────────────────────────────────────
    if len(tables) < 2:
        return df_info

    try:
        df_stats = pd.read_html(str(tables[1]))[0]
    except Exception as e:
        print(f"  Could not parse stats table: {e}")
        return df_info

    # Drop duplicate columns (RK, POS sometimes appear in both)
    drop_cols = [c for c in df_stats.columns if str(c).upper() in ("RK", "POS", "NAME")]
    df_stats = df_stats.drop(columns=drop_cols, errors="ignore")

    # Align row counts before merging
    min_len = min(len(df_info), len(df_stats))
    merged = pd.concat(
        [df_info.iloc[:min_len].reset_index(drop=True),
         df_stats.iloc[:min_len].reset_index(drop=True)],
        axis=1
    )
    return merged


# ── Main scraper ──────────────────────────────────────────────────────────────

def scrape_all():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    driver = get_driver()
    results = {}

    try:
        for name, url in URLS.items():
            print(f"\n[{name.upper()}]  {url}")

            driver.get(url)

            # Wait for initial table load
            try:
                WebDriverWait(driver, 15).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "table"))
                )
            except TimeoutException:
                print("  Timed out waiting for table. Skipping.")
                continue

            # Expand all rows by clicking Show More repeatedly
            click_show_more(driver)

            # Parse fully-loaded page
            soup = BeautifulSoup(driver.page_source, "html.parser")
            df = parse_stats_table(soup)

            if df is None or df.empty:
                print("  No data extracted.")
                continue

            df.columns = [str(c).strip() for c in df.columns]
            df = df.dropna(how="all")

            out_path = os.path.join(OUTPUT_DIR, f"{name}.csv")
            df.to_csv(out_path, index=False)
            print(f"  Saved {len(df)} rows  -->  {out_path}")
            results[name] = df

    finally:
        driver.quit()

    return results


if __name__ == "__main__":
    print("ESPN CFB Stats Scraper — Full Roster Mode")
    print("=" * 44)
    results = scrape_all()
    print(f"\nDone: {len(results)}/{len(URLS)} categories saved to '{OUTPUT_DIR}/'")