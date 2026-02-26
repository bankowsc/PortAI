"""Players Page - Browse and search all transfer portal players."""

def:pub PlayersPage(
    onNavigate: any,
    players: list,
    playersLoading: bool,
    totalPlayers: int,
    searchQuery: str,
    onSearchChange: any,
    onSearch: any,
    positionFilter: str,
    onPositionFilterChange: any,
    onLoadMore: any
) -> any {
    positions = ["all", "QB", "RB", "WR", "TE", "OT", "IOL", "Edge", "DL", "LB", "CB", "S", "K", "P", "LS", "ATH"];

    has_more = players.length < totalPlayers;

    def handleKeyPress(e: any) -> None {
        if e.key == "Enter" {
            onSearch();
        }
    }

    return
        <div className="space-y-6">
            <div>
                <h1 className="mb-2">Transfer Portal Players</h1>
                <p className="text-muted">
                    {"Browse and search " + String(totalPlayers) + " players in the 2026 transfer portal"}
                </p>
            </div>

            <div className="filter-bar">
                <div className="filter-row">
                    <div className="filter-search-wrapper" style={({"flex": "1"})}>
                        <span className="search-icon">🔍</span>
                        <input
                            className="input"
                            placeholder="Search by name, team, or position..."
                            value={searchQuery}
                            onChange={onSearchChange}
                            onKeyPress={handleKeyPress}
                            style={({"paddingLeft": "2.5rem"})}
                        />
                    </div>

                    <div className="select-wrapper">
                        <select className="select"
                                value={positionFilter}
                                onChange={onPositionFilterChange}>
                            {positions.map(lambda p: str -> any {
                                return <option key={p} value={p}>
                                    {("All Positions" if p == "all" else p)}
                                </option>;
                            })}
                        </select>
                        <span className="select-arrow">▼</span>
                    </div>

                    <button
                        className="btn btn-accent rounded-lg"
                        onClick={onSearch}
                        disabled={playersLoading}
                    >
                        Search
                    </button>
                </div>
            </div>

            {(
                <div style={({"textAlign": "center", "padding": "3rem"})}>
                    <p className="text-muted">Loading players...</p>
                </div>
            ) if playersLoading and players.length == 0 else (
                <div>
                    {(
                        <div style={({"textAlign": "center", "padding": "3rem"})}>
                            <h2 className="text-muted">Search for Players</h2>
                            <p className="text-muted">Use the search bar above to find players by name, team, or position. Or click Search to browse all players.</p>
                        </div>
                    ) if players.length == 0 and not playersLoading else (
                        <div>
                            <p className="results-count">
                                {"Showing " + String(players.length) + " of " + String(totalPlayers) + " players"}
                            </p>
                            <div className="grid-3">
                                {players.map(lambda player: dict -> any {
                                    playerId = player["id"];
                                    return <div key={player["id"]} className="card player-card">
                                        <div className="player-card-top">
                                            <span className="player-card-photo">{player["photo"]}</span>
                                            <div className="flex-1">
                                                <div className="player-card-name">{player["name"]}</div>
                                                <div className="player-card-meta">
                                                    <span className="badge badge-outline">{player["position"]}</span>
                                                    {(
                                                        <span className="badge badge-secondary" style={({"marginLeft": "0.25rem"})}>
                                                            {player["status"]}
                                                        </span>
                                                    ) if player["status"] else None}
                                                </div>
                                                <div className="player-card-stars">
                                                    {Array.from(
                                                        {"length": player["starRating"]},
                                                        lambda _: any, idx: int -> int { return idx; }
                                                    ).map(lambda i: int -> any {
                                                        return <span key={i} className="star">⭐</span>;
                                                    })}
                                                </div>
                                            </div>
                                        </div>

                                        <div className="player-card-details">
                                            <div className="player-card-detail-row">
                                                <span className="player-card-detail-label">Current Team</span>
                                                <span>{player["currentTeam"]}</span>
                                            </div>
                                            {(
                                                <div className="player-card-detail-row">
                                                    <span className="player-card-detail-label">Previous Team</span>
                                                    <span>{player["previousTeam"]}</span>
                                                </div>
                                            ) if player["previousTeam"] and player["previousTeam"] != "N/A" else None}
                                            {(
                                                <div className="player-card-detail-row">
                                                    <span className="player-card-detail-label">Height</span>
                                                    <span>{player["height"]}</span>
                                                </div>
                                            ) if player["height"] and player["height"] != "N/A" else None}
                                            {(
                                                <div className="player-card-detail-row">
                                                    <span className="player-card-detail-label">Weight</span>
                                                    <span>{player["weight"]}</span>
                                                </div>
                                            ) if player["weight"] and player["weight"] != "0 lbs" else None}
                                            {(
                                                <div className="player-card-detail-row">
                                                    <span className="player-card-detail-label">Rating</span>
                                                    <span className="player-card-detail-value accent">{String(player["rating"])}</span>
                                                </div>
                                            ) if player["rating"] else None}
                                        </div>

                                        <button className="btn btn-outline-accent btn-full rounded-lg"
                                                onClick={lambda -> None { onNavigate("player-detail:" + playerId); }}>
                                            View Profile
                                        </button>
                                    </div>;
                                })}
                            </div>

                            {(
                                <div style={({"textAlign": "center", "padding": "1.5rem"})}>
                                    <button
                                        className="btn btn-outline-accent rounded-lg"
                                        onClick={onLoadMore}
                                        disabled={playersLoading}
                                    >
                                        {("Loading..." if playersLoading else "Load More Players (" + String(totalPlayers - players.length) + " remaining)")}
                                    </button>
                                </div>
                            ) if has_more else None}
                        </div>
                    )}
                </div>
            )}
        </div>;
}
