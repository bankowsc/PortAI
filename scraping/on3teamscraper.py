"""
CFB Transfer Portal Scraper — All FBS Teams
=============================================
Scrapes On3 transfer portal pages for every FBS program.

Requirements:
    pip install playwright beautifulsoup4
    playwright install chromium

Usage:
    python scrape_all_portal.py
    python scrape_all_portal.py --year 2025
    python scrape_all_portal.py --status committed
    python scrape_all_portal.py --team "Alabama"
    python scrape_all_portal.py --out portal_data
    python scrape_all_portal.py --visible
    python scrape_all_portal.py --delay 2.0        # seconds between requests
    python scrape_all_portal.py --workers 3        # parallel browser instances
"""

import asyncio
import argparse
import csv
import re
import time
from pathlib import Path
from datetime import datetime

from bs4 import BeautifulSoup
from playwright.async_api import async_playwright

# ---------------------------------------------------------------------------
# Team name → On3 URL slug
# ---------------------------------------------------------------------------
TEAM_SLUGS = {
    "Air Force":          "air-force-falcons",
    "Akron":              "akron-zips",
    "Alabama":            "alabama-crimson-tide",
    "Appalachian State":  "appalachian-state-mountaineers",
    "Arizona":            "arizona-wildcats",
    "Arizona State":      "arizona-state-sun-devils",
    "Arkansas":           "arkansas-razorbacks",
    "Arkansas State":     "arkansas-state-red-wolves",
    "Army":               "army-black-knights",
    "Auburn":             "auburn-tigers",
    "Ball State":         "ball-state-cardinals",
    "Baylor":             "baylor-bears",
    "Boise State":        "boise-state-broncos",
    "Boston College":     "boston-college-eagles",
    "Bowling Green":      "bowling-green-falcons",
    "Buffalo":            "buffalo-bulls",
    "BYU":                "byu-cougars",
    "California":         "california-golden-bears",
    "Central Michigan":   "central-michigan-chippewas",
    "Charlotte":          "charlotte-49ers",
    "Cincinnati":         "cincinnati-bearcats",
    "Clemson":            "clemson-tigers",
    "Coastal Carolina":   "coastal-carolina-chanticleers",
    "Colorado":           "colorado-buffaloes",
    "Colorado State":     "colorado-state-rams",
    "Connecticut":        "connecticut-huskies",
    "Duke":               "duke-blue-devils",
    "East Carolina":      "east-carolina-pirates",
    "Eastern Michigan":   "eastern-michigan-eagles",
    "FIU":                "fiu-golden-panthers",
    "Florida":            "florida-gators",
    "Florida Atlantic":   "florida-atlantic-owls",
    "Florida State":      "florida-state-seminoles",
    "Fresno State":       "fresno-state-bulldogs",
    "Georgia":            "georgia-bulldogs",
    "Georgia Southern":   "georgia-southern-eagles",
    "Georgia State":      "georgia-state-panthers",
    "Georgia Tech":       "georgia-tech-yellow-jackets",
    "Hawaii":             "hawaii-rainbow-warriors",
    "Houston":            "houston-cougars",
    "Idaho":              "idaho-vandals",
    "Illinois":           "illinois-fighting-illini",
    "Indiana":            "indiana-hoosiers",
    "Iowa":               "iowa-hawkeyes",
    "Iowa State":         "iowa-state-cyclones",
    "Jacksonville State": "jacksonville-state-gamecocks",
    "James Madison":      "james-madison-dukes",
    "Kansas":             "kansas-jayhawks",
    "Kansas State":       "kansas-state-wildcats",
    "Kennesaw State":     "kennesaw-state-owls",
    "Kent State":         "kent-state-golden-flashes",
    "Kentucky":           "kentucky-wildcats",
    "Liberty":            "liberty-flames",
    "Louisiana":          "louisiana-ragin-cajuns",
    "Louisiana Monroe":   "louisiana-monroe-warhawks",
    "Louisiana Tech":     "louisiana-tech-bulldogs",
    "Louisville":         "louisville-cardinals",
    "LSU":                "lsu-tigers",
    "Marshall":           "marshall-thundering-herd",
    "Maryland":           "maryland-terrapins",
    "Memphis":            "memphis-tigers",
    "Miami":              "miami-hurricanes",
    "Miami (OH)":         "miami-oh-redhawks",
    "Michigan":           "michigan-wolverines",
    "Michigan State":     "michigan-state-spartans",
    "Middle Tennessee":   "middle-tennessee-state-blue-raiders",
    "Minnesota":          "minnesota-golden-gophers",
    "Mississippi State":  "mississippi-state-bulldogs",
    "Missouri":           "missouri-tigers",
    "Navy":               "navy-midshipmen",
    "NC State":           "nc-state-wolfpack",
    "Nebraska":           "nebraska-cornhuskers",
    "Nevada":             "nevada-wolf-pack",
    "New Mexico":         "new-mexico-lobos",
    "New Mexico State":   "new-mexico-state-aggies",
    "North Carolina":     "north-carolina-tar-heels",
    "North Texas":        "north-texas-mean-green",
    "Northern Illinois":  "northern-illinois-huskies",
    "Northwestern":       "northwestern-wildcats",
    "Notre Dame":         "notre-dame-fighting-irish",
    "Ohio":               "ohio-bobcats",
    "Ohio State":         "ohio-state-buckeyes",
    "Oklahoma":           "oklahoma-sooners",
    "Oklahoma State":     "oklahoma-state-cowboys",
    "Old Dominion":       "old-dominion-monarchs",
    "Ole Miss":           "ole-miss-rebels",
    "Oregon":             "oregon-ducks",
    "Oregon State":       "oregon-state-beavers",
    "Penn State":         "penn-state-nittany-lions",
    "Pittsburgh":         "pittsburgh-panthers",
    "Purdue":             "purdue-boilermakers",
    "Rice":               "rice-owls",
    "Rutgers":            "rutgers-scarlet-knights",
    "Sam Houston":        "sam-houston-state-bearkats",
    "San Diego State":    "san-diego-state-aztecs",
    "San Jose State":     "san-jose-state-spartans",
    "SMU":                "smu-mustangs",
    "South Alabama":      "south-alabama-jaguars",
    "South Carolina":     "south-carolina-gamecocks",
    "South Florida":      "usf-bulls",
    "Southern Miss":      "southern-miss-golden-eagles",
    "Stanford":           "stanford-cardinal",
    "Syracuse":           "syracuse-orange",
    "TCU":                "tcu-horned-frogs",
    "Temple":             "temple-owls",
    "Tennessee":          "tennessee-volunteers",
    "Texas":              "texas-longhorns",
    "Texas A&M":          "texas-am-aggies",
    "Texas State":        "texas-state-bobcats",
    "Texas Tech":         "texas-tech-red-raiders",
    "Toledo":             "toledo-rockets",
    "Troy":               "troy-trojans",
    "Tulane":             "tulane-green-wave",
    "Tulsa":              "tulsa-golden-hurricane",
    "UAB":                "uab-blazers",
    "UCF":                "ucf-knights",
    "UCLA":               "ucla-bruins",
    "UNLV":               "unlv-rebels",
    "USC":                "usc-trojans",
    "Utah":               "utah-utes",
    "Utah State":         "utah-state-aggies",
    "UTEP":               "utep-miners",
    "UTSA":               "utsa-roadrunners",
    "Vanderbilt":         "vanderbilt-commodores",
    "Virginia":           "virginia-cavaliers",
    "Virginia Tech":      "virginia-tech-hokies",
    "Wake Forest":        "wake-forest-demon-deacons",
    "Washington":         "washington-huskies",
    "Washington State":   "washington-state-cougars",
    "West Virginia":      "west-virginia-mountaineers",
    "Western Kentucky":   "western-kentucky-hilltoppers",
    "Western Michigan":   "western-michigan-broncos",
    "Wisconsin":          "wisconsin-badgers",
    "Wyoming":            "wyoming-cowboys",
}

BASE = "https://www.on3.com/college/{slug}/transfer-portal/wire/football/2019/" \
"/"


def build_url(slug, year=None, status=None):
    url = BASE.format(slug=slug)
    if year:
        url = url.rstrip("/") + f"/{year}/"
    if status:
        url += f"?status={status}"
    return url


def parse_entries(html, team_name):
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

            pos_match = re.search(
                r'\b(QB|RB|WR|TE|OT|IOL|OL|EDGE|DL|LB|CB|S|ATH|K|P|LS)\b', text
            )
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
                "School":              team_name,
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


async def scrape_team(slug, team_name, year=None, status=None, headless=True, sem=None):
    """Scrape a single team's portal page. Uses semaphore if provided."""
    url = build_url(slug, year, status)

    async def _do():
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

            try:
                await page.goto(url, wait_until="domcontentloaded", timeout=60000)
                await page.wait_for_timeout(3000)

                clicks = 0
                while True:
                    btn = await page.query_selector(
                        "button:has-text('Load More'), "
                        "a:has-text('Load More'), "
                        "button:has-text('load more')"
                    )
                    if not btn or not await btn.is_visible():
                        break

                    clicks += 1
                    before_count = await page.locator("ol > li").count()
                    await btn.scroll_into_view_if_needed()
                    await btn.click()

                    try:
                        await page.wait_for_function(
                            f"document.querySelectorAll('ol > li').length > {before_count}",
                            timeout=15000,
                        )
                    except Exception:
                        break

                    await page.wait_for_timeout(800)

                html = await page.content()
            finally:
                await browser.close()

        entries = parse_entries(html, team_name)

        # dedup
        seen, unique = set(), []
        for e in entries:
            key = (e["Name"], e["Status"], e["Date Entered Portal"])
            if key not in seen:
                seen.add(key)
                unique.append(e)
        return unique

    if sem:
        async with sem:
            return await _do()
    else:
        return await _do()


async def scrape_all(teams, year=None, status=None, headless=True, delay=1.5, workers=3):
    sem = asyncio.Semaphore(workers)
    results = {}
    total = len(teams)

    async def bounded(name, slug):
        entries = await scrape_team(slug, name, year=year, status=status,
                                    headless=headless, sem=sem)
        results[name] = entries
        done = len(results)
        print(f"  [{done:>3}/{total}] {name:<35} → {len(entries)} entries")
        await asyncio.sleep(delay)

    tasks = [bounded(name, slug) for name, slug in teams.items()]
    await asyncio.gather(*tasks)
    return results


def save_combined_csv(all_entries, filepath):
    flat = [e for entries in all_entries.values() for e in entries]
    if not flat:
        print("No entries to save.")
        return
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(flat[0].keys()))
        writer.writeheader()
        writer.writerows(flat)
    print(f"\nCombined CSV saved → {filepath}  ({len(flat)} total rows)")


def save_per_team_csvs(all_entries, out_dir):
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    for team, entries in all_entries.items():
        if not entries:
            continue
        safe = re.sub(r'[^a-z0-9]+', '_', team.lower()).strip('_')
        path = out_dir / f"{safe}.csv"
        with open(path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(entries[0].keys()))
            writer.writeheader()
            writer.writerows(entries)
    print(f"Per-team CSVs saved → {out_dir}/")


def parse_args():
    p = argparse.ArgumentParser(description="CFB Transfer Portal Scraper — All FBS Teams")
    p.add_argument("--year",    default=None, help="Year, e.g. 2025 or 2026")
    p.add_argument("--status",  default=None,
                   help="Status filter: entered | committed | withdrawn | signed | enrolled")
    p.add_argument("--team",    default=None,
                   help="Scrape a single team only, e.g. 'Alabama'")
    p.add_argument("--out",     default="cfb_transfer_portal",
                   help="Output CSV filename prefix (default: cfb_transfer_portal)")
    p.add_argument("--per-team", action="store_true",
                   help="Also write one CSV per team into a subdirectory")
    p.add_argument("--visible", action="store_true", help="Show browser window(s)")
    p.add_argument("--delay",   type=float, default=1.5,
                   help="Seconds to sleep after each team (default: 1.5)")
    p.add_argument("--workers", type=int, default=3,
                   help="Parallel browser instances (default: 3)")
    return p.parse_args()


async def main():
    args = parse_args()

    if args.team:
        if args.team not in TEAM_SLUGS:
            print(f"Unknown team '{args.team}'. Available teams:")
            for t in sorted(TEAM_SLUGS):
                print(f"  {t}")
            return
        teams = {args.team: TEAM_SLUGS[args.team]}
    else:
        teams = TEAM_SLUGS

    print(f"\nScraping {len(teams)} team(s)...")
    print(f"  year={args.year or 'all'}  status={args.status or 'all'}  "
          f"workers={args.workers}  delay={args.delay}s\n")

    start = time.time()
    all_entries = await scrape_all(
        teams,
        year=args.year,
        status=args.status,
        headless=not args.visible,
        delay=args.delay,
        workers=args.workers,
    )
    elapsed = time.time() - start
    print(f"\nFinished in {elapsed:.1f}s")

    suffix = (f"_{args.year}" if args.year else "") + (f"_{args.status}" if args.status else "")
    combined_path = args.out + suffix + ".csv"
    save_combined_csv(all_entries, combined_path)

    if args.per_team:
        save_per_team_csvs(all_entries, args.out + suffix + "_by_team")

    # summary
    total_entries = sum(len(v) for v in all_entries.values())
    empty_teams   = [t for t, v in all_entries.items() if not v]
    print(f"\nSummary: {total_entries} total entries across {len(teams)} teams")
    if empty_teams:
        print(f"  Teams with 0 entries ({len(empty_teams)}): {', '.join(sorted(empty_teams))}")


if __name__ == "__main__":
    asyncio.run(main())