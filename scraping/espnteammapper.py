"""
ESPN Team Abbreviation Mapper
==============================
Maps ESPN shortcodes (UNT, DUKE, OSU, etc.) to full team names.

Requirements:
    pip install rapidfuzz pandas
Usage:
    python team_mapper.py
    
    Or import and use in another script:
        from team_mapper import map_team, apply_team_mapping
"""

import pandas as pd
from rapidfuzz import process, fuzz

# ── Full team list ────────────────────────────────────────────────────────────

TEAMS: list = [
    "Air Force", "Akron", "Alabama", "Appalachian State", "Arizona",
    "Arizona State", "Arkansas", "Arkansas State", "Army", "Auburn",
    "Ball State", "Baylor", "Boise State", "Boston College", "Bowling Green",
    "Buffalo", "BYU", "California", "Central Michigan", "Charlotte",
    "Cincinnati", "Clemson", "Coastal Carolina", "Colorado", "Colorado State",
    "Connecticut", "Duke", "East Carolina", "Eastern Michigan", "FIU",
    "Florida", "Florida Atlantic", "Florida State", "Fresno State", "Georgia",
    "Georgia Southern", "Georgia State", "Georgia Tech", "Hawaii", "Houston",
    "Idaho", "Illinois", "Indiana", "Iowa", "Iowa State", "Jacksonville State",
    "James Madison", "Kansas", "Kansas State", "Kennesaw State", "Kent State",
    "Kentucky", "Liberty", "Louisiana", "Louisiana Monroe", "Louisiana Tech",
    "Louisville", "LSU", "Marshall", "Maryland", "Memphis", "Miami",
    "Miami (OH)", "Michigan", "Michigan State", "Middle Tennessee", "Minnesota",
    "Mississippi State", "Missouri", "Navy", "NC State", "Nebraska",
    "Nevada", "New Mexico", "New Mexico State", "North Carolina", "North Texas",
    "Northern Illinois", "Northwestern", "Notre Dame", "Ohio", "Ohio State",
    "Oklahoma", "Oklahoma State", "Old Dominion", "Ole Miss", "Oregon",
    "Oregon State", "Penn State", "Pittsburgh", "Purdue", "Rice",
    "Rutgers", "Sam Houston", "San Diego State", "San Jose State", "SMU",
    "South Alabama", "South Carolina", "South Florida", "Southern Miss", "Stanford",
    "Syracuse", "TCU", "Temple", "Tennessee", "Texas", "Texas A&M",
    "Texas State", "Texas Tech", "Toledo", "Troy", "Tulane", "Tulsa",
    "UAB", "UCF", "UCLA", "UNLV", "USC", "Utah", "Utah State",
    "UTEP", "UTSA", "Vanderbilt", "Virginia", "Virginia Tech", "Wake Forest",
    "Washington", "Washington State", "West Virginia", "Western Kentucky",
    "Western Michigan", "Wisconsin", "Wyoming"
]

# ── Manual overrides ──────────────────────────────────────────────────────────

MANUAL_OVERRIDES = {
    "AF":    "Air Force",
    "AKR":   "Akron",
    "ALA":   "Alabama",
    "APP":   "Appalachian State",
    "ARIZ":  "Arizona",
    "ASU":   "Arizona State",
    "ARK":   "Arkansas",
    "ARST":  "Arkansas State",
    "ARMY":  "Army",
    "AUB":   "Auburn",
    "BAL":   "Ball State",
    "BAY":   "Baylor",
    "BSU":   "Boise State",
    "BC":    "Boston College",
    "BGSU":  "Bowling Green",
    "BUFF":  "Buffalo",
    "BYU":   "BYU",
    "CAL":   "California",
    "CMU":   "Central Michigan",
    "CHAR":  "Charlotte",
    "CIN":   "Cincinnati",
    "CLEM":  "Clemson",
    "CCU":   "Coastal Carolina",
    "COLO":  "Colorado",
    "CSU":   "Colorado State",
    "CONN":  "Connecticut",
    "DUKE":  "Duke",
    "ECU":   "East Carolina",
    "EMU":   "Eastern Michigan",
    "FIU":   "FIU",
    "FLA":   "Florida",
    "FAU":   "Florida Atlantic",
    "FSU":   "Florida State",
    "FRES":  "Fresno State",
    "UGA":   "Georgia",
    "GASO":  "Georgia Southern",
    "GAST":  "Georgia State",
    "GT":    "Georgia Tech",
    "HAW":   "Hawaii",
    "HOU":   "Houston",
    "IDHO":  "Idaho",
    "ILL":   "Illinois",
    "IU":    "Indiana",
    "IOWA":  "Iowa",
    "IAST":  "Iowa State",
    "JSU":   "Jacksonville State",
    "JMU":   "James Madison",
    "KU":    "Kansas",
    "KSU":   "Kansas State",
    "KENN":  "Kennesaw State",
    "KENT":  "Kent State",
    "UK":    "Kentucky",
    "LIB":   "Liberty",
    "ULL":   "Louisiana",
    "ULM":   "Louisiana Monroe",
    "LT":    "Louisiana Tech",
    "LOU":   "Louisville",
    "LSU":   "LSU",
    "MRSH":  "Marshall",
    "MD":    "Maryland",
    "MEM":   "Memphis",
    "MIA":   "Miami",
    "MIOH":  "Miami (OH)",
    "MICH":  "Michigan",
    "MSU":   "Michigan State",
    "MTSU":  "Middle Tennessee",
    "MINN":  "Minnesota",
    "MSST":  "Mississippi State",
    "MIZ":   "Missouri",
    "NAVY":  "Navy",
    "NCST":  "NC State",
    "NEB":   "Nebraska",
    "NEV":   "Nevada",
    "NM":    "New Mexico",
    "NMST":  "New Mexico State",
    "UNC":   "North Carolina",
    "UNT":   "North Texas",
    "NIU":   "Northern Illinois",
    "NW":    "Northwestern",
    "ND":    "Notre Dame",
    "OHIO":  "Ohio",
    "OSU":   "Ohio State",
    "OU":    "Oklahoma",
    "OKST":  "Oklahoma State",
    "ODU":   "Old Dominion",
    "MISS":  "Ole Miss",
    "ORE":   "Oregon",
    "ORST":  "Oregon State",
    "PSU":   "Penn State",
    "PITT":  "Pittsburgh",
    "PUR":   "Purdue",
    "RICE":  "Rice",
    "RUT":   "Rutgers",
    "SHSU":  "Sam Houston",
    "SDSU":  "San Diego State",
    "SJSU":  "San Jose State",
    "SMU":   "SMU",
    "USA":   "South Alabama",
    "SC":    "South Carolina",
    "USF":   "South Florida",
    "USM":   "Southern Miss",
    "STAN":  "Stanford",
    "SYR":   "Syracuse",
    "TCU":   "TCU",
    "TEMP":  "Temple",
    "TENN":  "Tennessee",
    "TEX":   "Texas",
    "TAMU":  "Texas A&M",
    "TXST":  "Texas State",
    "TTU":   "Texas Tech",
    "TOL":   "Toledo",
    "TROY":  "Troy",
    "TUL":   "Tulane",
    "TLSA":  "Tulsa",
    "UAB":   "UAB",
    "UCF":   "UCF",
    "UCLA":  "UCLA",
    "UNLV":  "UNLV",
    "USC":   "USC",
    "UTAH":  "Utah",
    "USU":   "Utah State",
    "UTEP":  "UTEP",
    "UTSA":  "UTSA",
    "VAN":   "Vanderbilt",
    "UVA":   "Virginia",
    "VT":    "Virginia Tech",
    "WAKE":  "Wake Forest",
    "WASH":  "Washington",
    "WSU":   "Washington State",
    "WVU":   "West Virginia",
    "WKU":   "Western Kentucky",
    "WMU":   "Western Michigan",
    "WIS":   "Wisconsin",
    "WYO":   "Wyoming",
    "DEL":   "Delaware",
}

# ── Mapper ────────────────────────────────────────────────────────────────────

def map_team(abbr: str, threshold: int = 70) -> str:
    """
    Convert an ESPN team abbreviation to a full team name.

    Priority order:
      1. Manual override (exact match, case-insensitive)
      2. Exact match against full team list
      3. Fuzzy match against full team list (using token_sort_ratio)
      4. Returns original abbreviation if no match found above threshold
    """
    if not abbr or not isinstance(abbr, str):
        return abbr

    clean = abbr.strip().upper()

    # 1. Manual override
    if clean in MANUAL_OVERRIDES:
        return MANUAL_OVERRIDES[clean]

    # 2. Exact match (case-insensitive) against full names
    for team in TEAMS:
        if team.upper() == clean:
            return team

    # 3. Fuzzy match
    result = process.extractOne(
        clean,
        TEAMS,
        scorer=fuzz.token_sort_ratio,
        score_cutoff=threshold
    )
    if result:
        return result[0]

    # 4. No match — return original so nothing is lost
    print(f"  [WARNING] No match found for '{abbr}' — keeping original.")
    return abbr


def apply_team_mapping(df: pd.DataFrame, team_col: str = "TEAM") -> pd.DataFrame:
    """Apply map_team() to a TEAM column in a DataFrame."""
    if team_col not in df.columns:
        print(f"  [WARNING] Column '{team_col}' not found in DataFrame.")
        return df
    df = df.copy()
    df[team_col] = df[team_col].apply(map_team)
    return df


# ── CLI: map a CSV file ───────────────────────────────────────────────────────

def map_csv(input_path: str, output_path: str = None, team_col: str = "TEAM"):
    """Load a CSV, map the TEAM column, save result."""
    df = pd.read_csv(input_path)
    df = apply_team_mapping(df, team_col)
    out = output_path or input_path.replace(".csv", "_mapped.csv")
    df.to_csv(out, index=False)
    print(f"Saved mapped file -> {out}")
    return df


def map_all_csvs(directory: str = "espn_cfb_stats", team_col: str = "TEAM"):
    """Map all CSVs in a directory."""
    import glob
    files = glob.glob(f"{directory}/*.csv")
    if not files:
        print(f"No CSV files found in '{directory}/'")
        return
    for f in sorted(files):
        if "_mapped" in f:
            continue
        print(f"Mapping {f}...")
        map_csv(f, team_col=team_col)
    print(f"\nDone! Mapped files saved alongside originals with '_mapped' suffix.")


# ── Quick test ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    test_cases = [
        "AF", "AKR", "ALA", "APP", "ARIZ", "ASU", "ARK", "ARST", "ARMY", "AUB",
        "BAL", "BAY", "BSU", "BC", "BGSU", "BUFF", "BYU", "CAL", "CMU", "CHAR",
        "CIN", "CLEM", "CCU", "COLO", "CSU", "CONN", "DUKE", "ECU", "EMU", "FIU",
        "FLA", "FAU", "FSU", "FRES", "UGA", "GASO", "GAST", "GT", "HAW", "HOU",
        "IDHO", "ILL", "IU", "IOWA", "IAST", "JSU", "JMU", "KU", "KSU", "KENN",
        "KENT", "UK", "LIB", "ULL", "ULM", "LT", "LOU", "LSU", "MRSH", "MD",
        "MEM", "MIA", "MIOH", "MICH", "MSU", "MTSU", "MINN", "MSST", "MIZ",
        "NAVY", "NCST", "NEB", "NEV", "NM", "NMST", "UNC", "UNT", "NIU", "NW",
        "ND", "OHIO", "OSU", "OU", "OKST", "ODU", "MISS", "ORE", "ORST", "PSU",
        "PITT", "PUR", "RICE", "RUT", "SHSU", "SDSU", "SJSU", "SMU", "USA", "SC",
        "USF", "USM", "STAN", "SYR", "TCU", "TEMP", "TENN", "TEX", "TAMU", "TXST",
        "TTU", "TOL", "TROY", "TUL", "TLSA", "UAB", "UCF", "UCLA", "UNLV", "USC",
        "UTAH", "USU", "UTEP", "UTSA", "VAN", "UVA", "VT", "WAKE", "WASH", "WSU",
        "WVU", "WKU", "WMU", "WIS", "WYO"
    ]

    print("Abbreviation Mapping Test")
    print("=" * 35)
    for abbr in test_cases:
        print(f"  {abbr:<8} ->  {map_team(abbr)}")

    print("\n--- Mapping all CSVs in espn_cfb_stats/ ---")
    map_all_csvs("espn_cfb_stats")