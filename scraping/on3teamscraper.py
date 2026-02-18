"""
Michigan Football Transfer Portal Scraper
==========================================
Scrapes: https://www.on3.com/college/michigan-wolverines/transfer-portal/wire/football/

Requirements:
    pip install playwright beautifulsoup4
    playwright install chromium

Usage:
    python scrape_michigan_portal.py
    python scrape_michigan_portal.py --year 2025
    python scrape_michigan_portal.py --status committed
    python scrape_michigan_portal.py --out my_output
    python scrape_michigan_portal.py --visible
"""

import asyncio
import argparse
import csv
import re
from datetime import datetime

from bs4 import BeautifulSoup
from playwright.async_api import async_playwright


BASE_URL = "https://www.on3.com/college/michigan-wolverines/transfer-portal/wire/football/"


def build_url(year=None, status=None):
    url = BASE_URL
    if year:
        url = url.rstrip("/") + f"/{year}/"
    if status:
        url += f"?status={status}"
    return url


def parse_entries(html):
    soup = BeautifulSoup(html, "html.parser")
    entries = []

    for item in soup.select("ol > li"):
        try:
            name_tag = item.select_one("a[href*='/rivals/']")
            if not name_tag:
                continue
            name = name_tag.get_text(strip=True)
            profile_url = "https://www.on3.com" + name_tag["href"]
            text = item.get_text(" ", strip=True)

            pos_match = re.search(r'\b(QB|RB|WR|TE|OT|IOL|EDGE|DL|LB|CB|S|ATH|K|P|LS)\b', text)
            position = pos_match.group(1) if pos_match else ""

            year_match = re.search(r'\b(RS-[A-Z]{2}|FR|SO|JR|SR)\b', text)
            year_class = year_match.group(1) if year_match else ""

            status = ""
            for s in ["Entered", "Committed", "Withdrawn", "Signed", "Enrolled", "Expected"]:
                if re.search(s, text, re.IGNORECASE):
                    status = s
                    break

            date_match = re.search(r'(\d{1,2}/\d{1,2}/\d{4})', text)
            portal_date = date_match.group(1) if date_match else ""

            ratings = re.findall(r'\b(\d{2}\.\d{2})\b', text)
            rating = ratings[0] if ratings else ""

            team_imgs = item.select("img[alt]")
            team_names = [
                img["alt"].replace(" Avatar", "").strip()
                for img in team_imgs
                if "Avatar" in img.get("alt", "") and img["alt"] != "Default Avatar"
            ]
            from_team = team_names[0] if len(team_names) > 0 else ""
            to_team   = team_names[1] if len(team_names) > 1 else ""

            hs_tag = item.select_one("a[href*='/high-school/']")
            high_school = hs_tag.get_text(strip=True) if hs_tag else ""

            entries.append({
                "Name":                name,
                "Position":            position,
                "Year/Class":          year_class,
                "Status":              status,
                "Date Entered Portal": portal_date,
                "From Team":           from_team,
                "To Team":             to_team,
                "Rating":              rating,
                "High School":         high_school,
                "Profile URL":         profile_url,
            })
        except Exception:
            continue

    return entries


async def scrape(year=None, status=None, headless=True):
    url = build_url(year, status)
    print(f"\nTarget URL: {url}")
    print("Launching browser...")

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=headless)
        context = await browser.new_context(
            user_agent=(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        )
        page = await context.new_page()

        print("Loading page...")
        await page.goto(url, wait_until="domcontentloaded", timeout=60000)
        await page.wait_for_timeout(3000)

        clicks = 0
        while True:
            btn = await page.query_selector(
                "button:has-text('Load More'), "
                "a:has-text('Load More'), "
                "button:has-text('load more')"
            )

            if not btn:
                print("No 'Load More' button found — all entries loaded.")
                break

            if not await btn.is_visible():
                print("'Load More' button hidden — all entries loaded.")
                break

            clicks += 1
            print(f"  Clicking 'Load More' (#{clicks})...", end=" ", flush=True)

            before_count = await page.locator("ol > li").count()
            await btn.scroll_into_view_if_needed()
            await btn.click()

            try:
                await page.wait_for_function(
                    f"document.querySelectorAll('ol > li').length > {before_count}",
                    timeout=15000,
                )
            except Exception:
                print("no new items loaded, stopping.")
                break

            await page.wait_for_timeout(800)
            after_count = await page.locator("ol > li").count()
            print(f"done. ({before_count} → {after_count} items)")

        print(f"\nTotal 'Load More' clicks: {clicks}")
        html = await page.content()
        await browser.close()

    print("Parsing entries...")
    entries = parse_entries(html)
    print(f"Raw entries: {len(entries)}")

    seen, unique = set(), []
    for e in entries:
        key = (e["Name"], e["Status"], e["Date Entered Portal"])
        if key not in seen:
            seen.add(key)
            unique.append(e)

    print(f"Unique entries (after dedup): {len(unique)}")
    return unique


def save_csv(entries, filepath):
    if not entries:
        return
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(entries[0].keys()))
        writer.writeheader()
        writer.writerows(entries)
    print(f"CSV saved → {filepath}")


def parse_args():
    p = argparse.ArgumentParser(description="Michigan Football Transfer Portal Scraper")
    p.add_argument("--year",    default=None, help="Year, e.g. 2025 or 2026")
    p.add_argument("--status",  default=None,
                   help="Status filter: entered | committed | withdrawn | signed | enrolled")
    p.add_argument("--out",     default="michigan_transfer_portal",
                   help="Output filename prefix (default: michigan_transfer_portal)")
    p.add_argument("--visible", action="store_true", help="Show browser window")
    return p.parse_args()


async def main():
    args = parse_args()
    entries = await scrape(year=args.year, status=args.status, headless=not args.visible)

    if not entries:
        print("No entries found.")
        return

    suffix = (f"_{args.year}" if args.year else "") + (f"_{args.status}" if args.status else "")
    filepath = args.out + suffix + ".csv"

    save_csv(entries, filepath)

    print("\n--- Sample (first 5 entries) ---")
    for e in entries[:5]:
        print(
            f"  {e['Name']:<25} {e['Position']:<6} {e['Year/Class']:<8} "
            f"{e['Status']:<12} {e['Date Entered Portal']:<14} "
            f"{e['From Team']} → {e['To Team']}"
        )
    print(f"\nDone! {len(entries)} total entries exported.")


if __name__ == "__main__":
    asyncio.run(main())