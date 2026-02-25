"""
Convert transfer portal CSV to a JAC mock_data file.
Usage: python csv_to_jac.py players.csv > mock_players.jac
  or:  python csv_to_jac.py players.csv  (writes mock_players.jac automatically)
"""

import csv
import sys
import json
import re

def clean_value(val: str):
    """Convert CSV string values to appropriate Python/JAC types."""
    val = val.strip()

    if val in ("N/A", "( N/A )", "", "None"):
        return None

    # Strip lbs from weight before trying numeric parse
    if re.match(r"^\d+ lbs$", val):
        return int(val.replace(" lbs", ""))

    # Try int
    try:
        return int(val)
    except ValueError:
        pass

    # Try float
    try:
        return float(val)
    except ValueError:
        pass

    return val


# Emoji logo map — extend as needed
TEAM_LOGOS: dict = {
    "alabama":      "🔴",
    "usc":          "🟡",
    "ohio state":   "🔴",
    "michigan":     "💛",
    "georgia":      "🔴",
    "notre dame":   "🟢",
    "air force":    "🔵",
    "akron":        "🔵",
    "miami":        "🟠",
    "fiu":          "🔵",
    "missouri":     "🟡",
    "old dominion": "🔵",
    "michigan state":"🟢",
    "furman":       "🟣",
    "holy cross":   "🟣",
    "north texas":  "🟢",
    "saint francis (pa)": "🔴",
    "south dakota": "🔵",
    "southern miss":"🟡",
}

def team_logo(name: str | None) -> str:
    if not name:
        return "⬜"
    return TEAM_LOGOS.get(name.lower(), "🏈")


def make_date(season) -> str:
    """Turn a season year into a plausible transfer date string."""
    if season:
        return f"{season}-01-15"
    return "2026-01-15"


def csv_to_jac(csv_path: str, output_path: str = "mock_players.jac"):
    players = []

    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            # Skip incomplete rows (e.g. trailing partial lines)
            if not row.get("name", "").strip():
                continue

            pid        = str(i + 1)
            season     = clean_value(row.get("season", ""))
            name       = clean_value(row.get("name", ""))
            position   = clean_value(row.get("position", ""))
            from_school = clean_value(row.get("from_school", ""))
            to_school  = clean_value(row.get("to_school", ""))
            stars      = clean_value(row.get("stars", "")) or 0
            status     = clean_value(row.get("status", ""))
            height     = clean_value(row.get("height", ""))
            weight     = clean_value(row.get("weight", ""))
            rating     = clean_value(row.get("rating", ""))
            profile_url = clean_value(row.get("profile_url", ""))

            player = {
                "id":           pid,
                "playerId":     pid,
                "playerName":   name,
                "playerPhoto":  "👤",
                "position":     position,
                "fromTeam":     from_school,
                "fromTeamLogo": team_logo(from_school),
                "toTeam":       to_school,
                "toTeamLogo":   team_logo(to_school),
                "starRating":   stars,
                "rating":       rating,
                "height":       height,
                "weight":       weight,
                "status":       status,
                "stats":        {},
                "date":         make_date(season),
                "sport":        "Football",
                "profileUrl":   profile_url,
            }
            players.append(player)

    # Render as JAC
    lines = ['"""Auto-generated from CSV — do not edit by hand."""', ""]
    lines.append(f"glob:pub mock_players: list = [")

    for player in players:
        # Use json.dumps for each dict for clean serialization,
        # then indent it nicely
        dumped = json.dumps(player, indent=4, ensure_ascii=False)
        # indent the whole block by 4 spaces
        indented = "\n".join("    " + l for l in dumped.splitlines())
        lines.append(indented + ",")

    lines.append("];")
    lines.append("")

    output = "\n".join(lines)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output)

    print(f"✅ Written {len(players)} players to {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python csv_to_jac.py <players.csv> [output.jac]")
        sys.exit(1)

    csv_path = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else "mock_players.jac"
    csv_to_jac(csv_path, out_path)
