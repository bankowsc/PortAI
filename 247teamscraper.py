#!/usr/bin/env python3
"""
This only scrapes one team at a time, 
I will have to change it so it scrapes every team from the dropdown.
"""

import requests
from bs4 import BeautifulSoup
import json
import csv
import re

def scrape_transfer_portal():
    url = "https://247sports.com/college/michigan/season/2026-football/transferportal/?institutionkey=24042"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    print("Fetching page...")
    response = requests.get(url, headers=headers, timeout=15)
    soup = BeautifulSoup(response.text, 'lxml')
    
    # Find all player list items - they're <li class="transfer-player">
    players_li = soup.find_all('li', class_='transfer-player')
    
    print(f"Found {len(players_li)} players\n")
    
    players = []
    
    for li in players_li:
        player = {}
        
        # Name - in <h3><a>
        name_elem = li.find('h3')
        if name_elem:
            name_link = name_elem.find('a')
            if name_link:
                player['name'] = name_link.get_text(strip=True)
                player['profile_url'] = name_link.get('href', 'N/A')
            else:
                player['name'] = name_elem.get_text(strip=True)
        else:
            player['name'] = "N/A"
        
        # Position - in <div class="position">
        pos_elem = li.find('div', class_='position')
        player['position'] = pos_elem.get_text(strip=True) if pos_elem else "N/A"
        
        # Bio (height/weight) - in <div class="bio">
        bio_elem = li.find('div', class_='bio')
        if bio_elem:
            bio_text = bio_elem.get_text(strip=True)
            # Format is like "6-2 / 238"
            parts = bio_text.split('/')
            if len(parts) >= 2:
                player['height'] = parts[0].strip().replace('-', "'") + "\""
                player['weight'] = parts[1].strip() + " lbs"
            else:
                player['height'] = bio_text.strip()
                player['weight'] = "N/A"
        else:
            player['height'] = "N/A"
            player['weight'] = "N/A"
        
        # Rating - count the filled stars (gold color)
        star_container = li.find('div', class_='starContainer')
        if star_container:
            filled_stars = star_container.find_all('path', fill='#FBD032')
            player['stars'] = len(filled_stars)
            
            # Also get numeric rating
            rating_elem = li.find('div', class_='rating')
            if rating_elem:
                player['rating'] = rating_elem.get_text(strip=True)
            else:
                player['rating'] = "N/A"
        else:
            player['stars'] = 0
            player['rating'] = "N/A"
        
        # Status - in <div class="status">
        status_elem = li.find('div', class_='status')
        player['status'] = status_elem.get_text(strip=True) if status_elem else "N/A"
        
        # Transfer from/to schools - look for logos
        prediction_div = li.find('div', class_='transfer-prediction')
        if prediction_div:
            # Source school (where they're coming from) - has class "source"
            source_img = prediction_div.find('img', class_='source')
            if source_img:
                player['from_school'] = source_img.get('alt', 'N/A')
            else:
                player['from_school'] = "N/A"
            
            # Destination school (where they're going) - inside <li class="destination">
            dest_li = prediction_div.find('li', class_='destination')
            if dest_li:
                dest_img = dest_li.find('img')
                if dest_img:
                    player['to_school'] = dest_img.get('alt', 'N/A')
                else:
                    player['to_school'] = "N/A"
            else:
                player['to_school'] = "N/A"
        else:
            player['from_school'] = "N/A"
            player['to_school'] = "N/A"
        
        players.append(player)
    
    return players


def save_data(players, team_name="michigan"):
    """Save to JSON and CSV"""
    if not players:
        print("No players to save!")
        return
    
    # Save JSON
    #json_filename = f'{team_name}_transfer_portal_data.json'
    #with open(json_filename, 'w', encoding='utf-8') as f:
        #json.dump(players, f, indent=2, ensure_ascii=False)
    #print(f"✓ Saved to {json_filename}")
    
    # Save CSV
    csv_filename = f'{team_name}_transfer_portal_data.csv'
    fieldnames = list(players[0].keys())
    with open(csv_filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(players)
    print(f"✓ Saved to {csv_filename}")
    
    # Print summary
    print(f"\n{'='*70}")
    print(f"SUMMARY")
    print(f"{'='*70}")
    print(f"Total players: {len(players)}")
    
    # Count by position
    positions = {}
    for p in players:
        pos = p.get('position', 'Unknown')
        positions[pos] = positions.get(pos, 0) + 1
    
    print(f"\nPlayers by position:")
    for pos, count in sorted(positions.items(), key=lambda x: x[1], reverse=True):
        print(f"  {pos}: {count}")
    
    # Count by status
    statuses = {}
    for p in players:
        status = p.get('status', 'Unknown')
        statuses[status] = statuses.get(status, 0) + 1
    
    print(f"\nPlayers by status:")
    for status, count in sorted(statuses.items(), key=lambda x: x[1], reverse=True):
        print(f"  {status}: {count}")
    
    # Show first 5 players
    print(f"\n{'='*70}")
    print("FIRST 5 PLAYERS")
    print(f"{'='*70}\n")
    
    for i, p in enumerate(players[:5], 1):
        print(f"{i}. {p.get('name', 'N/A')}")
        print(f"   Position: {p.get('position', 'N/A')}")
        print(f"   Height/Weight: {p.get('height', 'N/A')} / {p.get('weight', 'N/A')}")
        print(f"   Rating: {p.get('stars', 0)}-star ({p.get('rating', 'N/A')})")
        print(f"   From: {p.get('from_school', 'N/A')} → To: {p.get('to_school', 'N/A')}")
        print(f"   Status: {p.get('status', 'N/A')}")
        print()


def main():
    print("="*70)
    print("247SPORTS MICHIGAN TRANSFER PORTAL SCRAPER")
    print("="*70)
    print()
    
    players = scrape_transfer_portal()
    save_data(players)


if __name__ == "__main__":
    main()