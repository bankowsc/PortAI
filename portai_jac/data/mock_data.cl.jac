"""Mock data for PortAI - matches the React version's data structures."""

glob:pub mock_teams = [
    {
        "id": "1",
        "name": "Alabama Crimson Tide",
        "logo": "🔴",
        "conference": "SEC",
        "portalActivityScore": 92,
        "lastSeasonRecord": "12-2",
        "incomingCount": 8,
        "outgoingCount": 5
    },
    {
        "id": "2",
        "name": "Ohio State Buckeyes",
        "logo": "⚪",
        "conference": "Big Ten",
        "portalActivityScore": 88,
        "lastSeasonRecord": "11-2",
        "incomingCount": 7,
        "outgoingCount": 6
    },
    {
        "id": "3",
        "name": "Georgia Bulldogs",
        "logo": "🔴",
        "conference": "SEC",
        "portalActivityScore": 85,
        "lastSeasonRecord": "13-1",
        "incomingCount": 6,
        "outgoingCount": 4
    },
    {
        "id": "4",
        "name": "Michigan Wolverines",
        "logo": "💙",
        "conference": "Big Ten",
        "portalActivityScore": 82,
        "lastSeasonRecord": "10-3",
        "incomingCount": 9,
        "outgoingCount": 7
    },
    {
        "id": "5",
        "name": "USC Trojans",
        "logo": "🟡",
        "conference": "Big Ten",
        "portalActivityScore": 79,
        "lastSeasonRecord": "8-5",
        "incomingCount": 10,
        "outgoingCount": 8
    },
    {
        "id": "6",
        "name": "Texas Longhorns",
        "logo": "🟠",
        "conference": "SEC",
        "portalActivityScore": 86,
        "lastSeasonRecord": "12-2",
        "incomingCount": 5,
        "outgoingCount": 3
    },
    {
        "id": "7",
        "name": "Oregon Ducks",
        "logo": "💚",
        "conference": "Big Ten",
        "portalActivityScore": 84,
        "lastSeasonRecord": "11-3",
        "incomingCount": 6,
        "outgoingCount": 5
    },
    {
        "id": "8",
        "name": "Florida State Seminoles",
        "logo": "🟡",
        "conference": "ACC",
        "portalActivityScore": 75,
        "lastSeasonRecord": "13-1",
        "incomingCount": 4,
        "outgoingCount": 9
    }
];

glob:pub mock_players = [
    {
        "id": "1",
        "name": "Marcus Johnson",
        "photo": "👤",
        "position": "QB",
        "height": "6'3\"",
        "weight": "215 lbs",
        "class": "Junior",
        "currentTeam": "Alabama Crimson Tide",
        "previousTeam": "USC Trojans",
        "starRating": 5,
        "stats": {"yards": 3245, "touchdowns": 28, "ppg": 0},
        "nilValue": "$1.2M"
    },
    {
        "id": "2",
        "name": "DeAndre Williams",
        "photo": "👤",
        "position": "WR",
        "height": "6'1\"",
        "weight": "190 lbs",
        "class": "Sophomore",
        "currentTeam": "Ohio State Buckeyes",
        "previousTeam": "Florida State Seminoles",
        "starRating": 4,
        "stats": {"yards": 982, "touchdowns": 12, "ppg": 0},
        "nilValue": "$850K"
    },
    {
        "id": "3",
        "name": "Tyler Anderson",
        "photo": "👤",
        "position": "RB",
        "height": "5'11\"",
        "weight": "205 lbs",
        "class": "Senior",
        "currentTeam": "Georgia Bulldogs",
        "previousTeam": "Michigan Wolverines",
        "starRating": 4,
        "stats": {"yards": 1456, "touchdowns": 18, "ppg": 0},
        "nilValue": "$950K"
    },
    {
        "id": "4",
        "name": "Jamal Carter",
        "photo": "👤",
        "position": "LB",
        "height": "6'2\"",
        "weight": "230 lbs",
        "class": "Junior",
        "currentTeam": "Texas Longhorns",
        "previousTeam": "Oregon Ducks",
        "starRating": 5,
        "stats": {"tackles": 98, "sacks": 12, "ppg": 0},
        "nilValue": "$780K"
    }
];

glob:pub mock_transactions = [
    {
        "id": "1",
        "playerId": "1",
        "playerName": "Marcus Johnson",
        "playerPhoto": "👤",
        "position": "QB",
        "fromTeam": "USC Trojans",
        "fromTeamLogo": "🟡",
        "toTeam": "Alabama Crimson Tide",
        "toTeamLogo": "🔴",
        "starRating": 5,
        "stats": {"yards": 3245, "touchdowns": 28},
        "date": "2026-02-15",
        "sport": "Football"
    },
    {
        "id": "2",
        "playerId": "2",
        "playerName": "DeAndre Williams",
        "playerPhoto": "👤",
        "position": "WR",
        "fromTeam": "Florida State Seminoles",
        "fromTeamLogo": "🟡",
        "toTeam": "Ohio State Buckeyes",
        "toTeamLogo": "⚪",
        "starRating": 4,
        "stats": {"yards": 982, "touchdowns": 12},
        "date": "2026-02-14",
        "sport": "Football"
    },
    {
        "id": "3",
        "playerId": "3",
        "playerName": "Tyler Anderson",
        "playerPhoto": "👤",
        "position": "RB",
        "fromTeam": "Michigan Wolverines",
        "fromTeamLogo": "💙",
        "toTeam": "Georgia Bulldogs",
        "toTeamLogo": "🔴",
        "starRating": 4,
        "stats": {"yards": 1456, "touchdowns": 18},
        "date": "2026-02-13",
        "sport": "Football"
    },
    {
        "id": "4",
        "playerId": "4",
        "playerName": "Jamal Carter",
        "playerPhoto": "👤",
        "position": "LB",
        "fromTeam": "Oregon Ducks",
        "fromTeamLogo": "💚",
        "toTeam": "Texas Longhorns",
        "toTeamLogo": "🟠",
        "starRating": 5,
        "stats": {"tackles": 98, "sacks": 12},
        "date": "2026-02-12",
        "sport": "Football"
    },
    {
        "id": "5",
        "playerId": "5",
        "playerName": "Brandon Davis",
        "playerPhoto": "👤",
        "position": "DB",
        "fromTeam": "Alabama Crimson Tide",
        "fromTeamLogo": "🔴",
        "toTeam": "USC Trojans",
        "toTeamLogo": "🟡",
        "starRating": 4,
        "stats": {"tackles": 76, "interceptions": 4},
        "date": "2026-02-11",
        "sport": "Football"
    }
];

glob:pub default_favorite_team_ids = ["1", "3", "6"];

glob:pub portal_stats = [
    {"name": "QB", "value": 23},
    {"name": "WR", "value": 45},
    {"name": "RB", "value": 34},
    {"name": "LB", "value": 38},
    {"name": "DB", "value": 41}
];

glob:pub conference_data = [
    {"name": "SEC", "transfers": 89},
    {"name": "Big Ten", "transfers": 76},
    {"name": "ACC", "transfers": 54},
    {"name": "Big 12", "transfers": 48},
    {"name": "Pac-12", "transfers": 42}
];

glob:pub trend_data = [
    {"week": "Wk 1", "transfers": 45},
    {"week": "Wk 2", "transfers": 67},
    {"week": "Wk 3", "transfers": 89},
    {"week": "Wk 4", "transfers": 112},
    {"week": "Wk 5", "transfers": 98},
    {"week": "Wk 6", "transfers": 134}
];

glob:pub position_data = [
    {"name": "QB", "value": 23, "color": "#0ea5e9"},
    {"name": "WR", "value": 45, "color": "#10b981"},
    {"name": "RB", "value": 34, "color": "#f59e0b"},
    {"name": "LB", "value": 38, "color": "#8b5cf6"},
    {"name": "DB", "value": 41, "color": "#ec4899"},
    {"name": "OL", "value": 52, "color": "#06b6d4"}
];

glob:pub news_articles = [
    {
        "id": "1",
        "title": "Record-Breaking Transfer Portal Week",
        "summary": "247 players entered the portal, marking the highest single-week total of the season.",
        "date": "Feb 17, 2026",
        "category": "Trending"
    },
    {
        "id": "2",
        "title": "Top QB Commits to Alabama",
        "summary": "5-star quarterback Marcus Johnson finalizes transfer to Crimson Tide.",
        "date": "Feb 16, 2026",
        "category": "Transfer News"
    },
    {
        "id": "3",
        "title": "SEC Dominates Portal Activity",
        "summary": "Conference leads all others with 89 total transfers this month.",
        "date": "Feb 15, 2026",
        "category": "Analysis"
    }
];

glob:pub recent_conversations = [
    {"id": "1", "title": "Alabama transfer analysis", "time": "2 hours ago"},
    {"id": "2", "title": "Top QB prospects", "time": "Yesterday"},
    {"id": "3", "title": "SEC portal trends", "time": "2 days ago"},
    {"id": "4", "title": "Defensive back rankings", "time": "3 days ago"}
];
