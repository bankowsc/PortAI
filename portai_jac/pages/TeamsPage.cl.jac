"""Teams Page - Browse and filter all teams."""

import from ..components.TeamCard { TeamCard }
import from ..data.mock_data { mock_teams }

def:pub TeamsPage(
    onNavigate: any,
    favoriteTeamIds: list,
    onToggleFavorite: any,
    searchFilter: str,
    onSearchFilterChange: any,
    conferenceFilter: str,
    onConferenceFilterChange: any,
    sortBy: str,
    onSortByChange: any,
    activityLevel: int,
    onActivityLevelChange: any
) -> any {
    conferences = ["all", "AAC", "ACC", "Big Ten", "Big 12", "CUSA", "MAC", "MWC", "Pac-12", "SEC", "Sun Belt"];

    filtered_teams = mock_teams.filter(
        lambda team: dict -> bool {
            if conferenceFilter != "all" and team["conference"] != conferenceFilter {
                return False;
            }
            if team["portalActivityScore"] < activityLevel {
                return False;
            }
            if searchFilter and not team["name"].toLowerCase().includes(searchFilter.toLowerCase()) {
                return False;
            }
            return True;
        }
    );

    if sortBy == "activity" {
        filtered_teams = filtered_teams.slice().sort(
            lambda a: dict, b: dict -> int { return b["portalActivityScore"] - a["portalActivityScore"]; }
        );
    } elif sortBy == "gained" {
        filtered_teams = filtered_teams.slice().sort(
            lambda a: dict, b: dict -> int { return b["incomingCount"] - a["incomingCount"]; }
        );
    } elif sortBy == "lost" {
        filtered_teams = filtered_teams.slice().sort(
            lambda a: dict, b: dict -> int { return b["outgoingCount"] - a["outgoingCount"]; }
        );
    }

    return
        <div className="space-y-6">
            <div>
                <h1 className="mb-2">College Teams</h1>
                <p className="text-muted">Browse all teams and their transfer portal activity</p>
            </div>

            <div className="filter-bar">
                <div className="filter-row">
                    <div className="filter-search-wrapper">
                        <span className="search-icon">🔍</span>
                        <input
                            className="input"
                            placeholder="Search teams..."
                            value={searchFilter}
                            onChange={onSearchFilterChange}
                            style={({"paddingLeft": "2.5rem"})}
                        />
                    </div>

                    <div className="select-wrapper">
                        <select className="select"
                                value={conferenceFilter}
                                onChange={onConferenceFilterChange}>
                            {[
                                <option key={c} value={c}>
                                    {("All Conferences" if c == "all" else c)}
                                </option>
                                for c in conferences
                            ]}
                        </select>
                        <span className="select-arrow">▼</span>
                    </div>

                    <div className="select-wrapper">
                        <select className="select"
                                value={sortBy}
                                onChange={onSortByChange}>
                            <option value="activity">Most Active</option>
                            <option value="gained">Most Gained</option>
                            <option value="lost">Most Lost</option>
                        </select>
                        <span className="select-arrow">▼</span>
                    </div>
                </div>

                <div>
                    <div className="slider-header">
                        <label className="slider-label">Minimum Activity Level</label>
                        <span className="slider-value">{activityLevel}+</span>
                    </div>
                    <input
                        type="range"
                        className="slider"
                        min="0"
                        max="100"
                        step="5"
                        value={activityLevel}
                        onChange={onActivityLevelChange}
                    />
                </div>
            </div>

            <div>
                <p className="results-count">
                    {"Showing " + String(filtered_teams.length) + " "} team{("s" if filtered_teams.length != 1 else "")}
                </p>
                <div className="grid-3">
                    {[
                        <TeamCard
                            key={team["id"]}
                            team={team}
                            isFavorite={favoriteTeamIds.includes(team["id"])}
                            onToggleFavorite={onToggleFavorite}
                            onNavigate={onNavigate}
                        />
                        for team in filtered_teams
                    ]}
                </div>
            </div>
        </div>;
}
