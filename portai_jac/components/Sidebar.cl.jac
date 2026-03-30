"""Sidebar navigation component."""

import from ..data.mock_data { mock_teams, default_favorite_team_ids }

# RUN THESE TWO
# jac add --npm @fortawesome/free-solid-svg-icons
# npm install @fortawesome/react-fontawesome @fortawesome/fontawesome-svg-core
import from '@fortawesome/react-fontawesome' { FontAwesomeIcon }
import from '@fortawesome/free-solid-svg-icons' { 
    faHouse, 
    faUsers, 
    faPerson, 
    faStar, 
    faRightLeft, 
    faNewspaper, 
    faChartBar, 
    faMessage,
    faBullseye
}

def:pub Sidebar(
    currentPage: str,
    collapsed: bool,
    onToggleCollapse: any,
    onNavigate: any,
    favoriteTeamIds: list
) -> any {
    # has menu_items: list = [
    #     {"icon": "🏠", "label": "Home", "page": "home"},
    #     {"icon": "👥", "label": "Teams", "page": "teams"},
    #     {"icon": "🧑", "label": "Players", "page": "players"},
    #     {"icon": "⭐", "label": "Favorites", "page": "favorites"},
    #     {"icon": "🔄", "label": "Transactions", "page": "transactions"},
    #     {"icon": "📰", "label": "News", "page": "news"},
    #     {"icon": "📊", "label": "Analytics", "page": "analytics"},
    #     {"icon": "💬", "label": "Chat", "page": "chat"}
    # ];
    has menu_items: list = [
        {"icon": faHouse,     "label": "Home",          "page": "home"},
        {"icon": faUsers,     "label": "Teams",         "page": "teams"},
        {"icon": faPerson,    "label": "Players",       "page": "players"},
        {"icon": faStar,      "label": "Favorites",     "page": "favorites"},
        {"icon": faRightLeft, "label": "Transactions",  "page": "transactions"},
        {"icon": faNewspaper, "label": "News",          "page": "news"},
        {"icon": faChartBar,  "label": "Analytics",     "page": "analytics"},
        {"icon": faMessage,   "label": "Chat",          "page": "chat"},
        {"icon": faBullseye,  "label": "Game",          "page": "game"}
    ];

    favorite_teams = [t for t in mock_teams if favoriteTeamIds.includes(t["id"])];

    return
        <aside className={"sidebar " + ("collapsed" if collapsed else "expanded")}>
            <div className="sidebar-content">
                <div className="sidebar-menu">
                    {menu_items.map(lambda item: dict -> any {
                        page = item["page"];
                        return <button key={item["page"]}
                                className={"sidebar-menu-item" + (" active" if currentPage == item["page"] else "")}
                                onClick={lambda -> None { onNavigate(page); }}>
                                <FontAwesomeIcon icon={item["icon"]} className="menu-icon" />
                                {(
                                <span className="menu-label">{item["label"]}</span>
                            ) if not collapsed else None}
                        </button>;
                    })}
                </div>

                {(
                    <div className="sidebar-favorites">
                        <div className="sidebar-favorites-title">FAVORITE TEAMS</div>
                        {favorite_teams.map(lambda team: dict -> any {
                            teamId = team["id"];
                            return <button key={team["id"]}
                                    className="sidebar-favorite-item"
                                    onClick={lambda -> None { onNavigate("team-detail:" + teamId); }}>
                                <span className="team-emoji">{team["logo"]}</span>
                                <span className="team-name">{team["name"]}</span>
                            </button>;
                        })}
                    </div>
                ) if not collapsed and favorite_teams.length > 0 else None}
            </div>

            <div className="sidebar-toggle">
                <button className="sidebar-toggle-btn"
                        onClick={lambda -> None { onToggleCollapse(); }}>
                    <span>{("▶" if collapsed else "◀")}</span>
                    {(
                        <span>Collapse</span>
                    ) if not collapsed else None}
                </button>
            </div>
        </aside>;
}
