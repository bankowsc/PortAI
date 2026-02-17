#!/usr/bin/env python3
"""
Scrapes the 247Sports transfer portal for every FBS team.
Outputs one combined CSV with a 'team' column.
Team names and institution keys are stored in teams.py.
"""

import requests
from bs4 import BeautifulSoup
import csv
import time

from teamkeys import TEAMS, MISSING_KEYS

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}


SLUG_OVERRIDES = {
    "Connecticut": "transfer-portal",
    "FIU": "transfer-portal",
    "Miami (OH)": "transfer-portal",
    "Middle Tennessee": "transfer-portal",
    "NC State": "transfer-portal",
    "Sam Houston": "transfer-portal",
    "Southern Miss": "transfer-portal",
    "UAB": "transfer-portal",
    "UCF": "transfer-portal",
}


def scrape_team(team_name, institution_key):
    if team_name in SLUG_OVERRIDES:
        slug = SLUG_OVERRIDES[team_name]
    else:
        slug = team_name.lower().replace(" ", "-").replace("(", "").replace(")", "").replace("&", "").replace(".", "")
    url = f"https://247sports.com/college/{slug}/season/2026-football/transferportal/?institutionkey={institution_key}"

    try:
        response = requests.get(url, headers=HEADERS, timeout=15)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"  [ERROR] Could not fetch {team_name}: {e}")
        return []

    soup = BeautifulSoup(response.text, 'lxml')
    players_li = soup.find_all('li', class_='transfer-player')

    players = []
    for li in players_li:
        player = {'team': team_name, 'institution_key': institution_key}

        # Name
        name_elem = li.find('h3')
        if name_elem:
            name_link = name_elem.find('a')
            if name_link:
                player['name'] = name_link.get_text(strip=True)
                player['profile_url'] = name_link.get('href', 'N/A')
            else:
                player['name'] = name_elem.get_text(strip=True)
                player['profile_url'] = 'N/A'
        else:
            player['name'] = 'N/A'
            player['profile_url'] = 'N/A'

        # Position
        pos_elem = li.find('div', class_='position')
        player['position'] = pos_elem.get_text(strip=True) if pos_elem else 'N/A'

        # Height / Weight
        bio_elem = li.find('div', class_='bio')
        if bio_elem:
            bio_text = bio_elem.get_text(strip=True)
            parts = bio_text.split('/')
            if len(parts) >= 2:
                player['height'] = parts[0].strip().replace('-', "'") + '"'
                player['weight'] = parts[1].strip() + ' lbs'
            else:
                player['height'] = bio_text.strip()
                player['weight'] = 'N/A'
        else:
            player['height'] = 'N/A'
            player['weight'] = 'N/A'

        # Stars + numeric rating
        star_container = li.find('div', class_='starContainer')
        if star_container:
            filled_stars = star_container.find_all('path', fill='#FBD032')
            player['stars'] = len(filled_stars)
            rating_elem = li.find('div', class_='rating')
            player['rating'] = rating_elem.get_text(strip=True) if rating_elem else 'N/A'
        else:
            player['stars'] = 0
            player['rating'] = 'N/A'

        # Status
        status_elem = li.find('div', class_='status')
        player['status'] = status_elem.get_text(strip=True) if status_elem else 'N/A'

        # From / To schools
        prediction_div = li.find('div', class_='transfer-prediction')
        if prediction_div:
            source_img = prediction_div.find('img', class_='source')
            player['from_school'] = source_img.get('alt', 'N/A') if source_img else 'N/A'

            dest_li = prediction_div.find('li', class_='destination')
            if dest_li:
                dest_img = dest_li.find('img')
                player['to_school'] = dest_img.get('alt', 'N/A') if dest_img else 'N/A'
            else:
                player['to_school'] = 'N/A'
        else:
            player['from_school'] = 'N/A'
            player['to_school'] = 'N/A'

        players.append(player)

    return players


def main():
    print("=" * 70)
    print("247SPORTS ALL-TEAM TRANSFER PORTAL SCRAPER")
    print("=" * 70)

    if MISSING_KEYS:
        print(f"\nSkipping {len(MISSING_KEYS)} teams with no institution key:")
        for t in MISSING_KEYS:
            print(f"  - {t}")

    all_players = []
    total_teams = len(TEAMS)

    for i, (team_name, inst_key) in enumerate(TEAMS.items(), 1):
        print(f"\n[{i}/{total_teams}] Scraping {team_name} (key: {inst_key})...")
        players = scrape_team(team_name, inst_key)
        print(f"  Found {len(players)} players")
        all_players.extend(players)

        # Be polite to the server — small delay between requests
        time.sleep(1.0)

    print(f"\n{'=' * 70}")
    print(f"DONE — Total players scraped: {len(all_players)}")
    print(f"{'=' * 70}\n")

    if not all_players:
        print("No players found. Exiting.")
        return

    # Save combined CSV
    csv_filename = "all_teams_transfer_portal_2026.csv"
    fieldnames = ['team', 'institution_key', 'name', 'position', 'height', 'weight',
                  'stars', 'rating', 'status', 'from_school', 'to_school', 'profile_url']

    with open(csv_filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        writer.writerows(all_players)

    print(f"✓ Saved to {csv_filename}")

    # Summary by team
    print(f"\nPlayers per team:")
    team_counts = {}
    for p in all_players:
        team_counts[p['team']] = team_counts.get(p['team'], 0) + 1
    for team, count in sorted(team_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {team}: {count}")


if __name__ == "__main__":
    main()