"""Transactions Page - Browse all transfer portal transactions with advanced filters."""

import from ..components.TransactionCard { TransactionCard }
import from ..data.mock_data { mock_teams }

def:pub TransactionsPage(
    transactions: list,
    transactionsLoading: bool,
    totalTransactions: int,
    onLoadMore: any,
    statusFilter: str,
    onStatusFilterChange: any,
    positionFilter: str,
    onPositionFilterChange: any,
    teamFilter: str,
    onTeamSelect: any,
    onClearTeamFilter: any,
    favoritesOnly: bool,
    rivalsOnly: bool,
    onToggleFavoritesOnly: any,
    onToggleRivalsOnly: any,
    favoriteTeamIds: list,
    rivalTeamIds: list,
    expandedAIImpacts: list,
    onToggleAIImpact: any,
    aiImpactTexts: any,
    aiImpactLoading: list,
    onNavigate: any,
    crystalBallTexts: any,
    crystalBallLoading: list,
    expandedCrystalBalls: list,
    onToggleCrystalBall: any
) -> any {
    has teamSearchText: str = "";
    has showSuggestions: bool = False;

    positions = ["all", "QB", "RB", "WR", "TE", "OT", "IOL", "Edge", "DL", "LB", "CB", "S", "K", "P", "LS", "ATH"];
    statuses = [
        {"value": "all", "label": "All"},
        {"value": "in_portal", "label": "In Portal"},
        {"value": "committed", "label": "Committed"},
        {"value": "enrolled", "label": "Enrolled"},
        {"value": "withdrawn", "label": "Withdrawn"}
    ];

    has_more = transactions.length < totalTransactions;

    # Filter team suggestions based on search text
    team_suggestions = (
        mock_teams.filter(
            lambda t: dict -> bool {
                return t["name"].toLowerCase().includes(teamSearchText.toLowerCase());
            }
        ).slice(0, 8)
    ) if teamSearchText.trim().length > 0 else [];

    def handleTeamSearchInput(e: any) -> None {
        teamSearchText = e.target.value;
        showSuggestions = True;
    }

    def handleTeamClick(teamName: str) -> None {
        teamSearchText = "";
        showSuggestions = False;
        onTeamSelect(teamName);
    }

    def handleClearTeam -> None {
        teamSearchText = "";
        showSuggestions = False;
        onClearTeamFilter();
    }

    def handleBlur -> None {
        # Delay hiding to allow click on suggestion
        setTimeout(lambda -> None { showSuggestions = False; }, 200);
    }

    def handleFocus -> None {
        if teamSearchText.trim().length > 0 {
            showSuggestions = True;
        }
    }

    return
        <div className="space-y-6">
            <div>
                <h1 className="mb-2">Transfer Portal Transactions</h1>
                <p className="text-muted">
                    {"Browse and filter " + String(totalTransactions) + " transfer portal transactions"}
                </p>
            </div>

            <div className="filter-bar">
                <div className="status-pills">
                    {statuses.map(lambda s: dict -> any {
                        sVal = s["value"];
                        return <button
                            key={s["value"]}
                            className={"status-pill" + (" active" if statusFilter == s["value"] else "")}
                            onClick={lambda -> None { onStatusFilterChange(sVal); }}
                        >
                            {s["label"]}
                        </button>;
                    })}
                </div>

                <div className="filter-row">
                    <div className="team-autocomplete">
                        {(
                            <div className="team-filter-active">
                                <span className="team-filter-tag">
                                    <span>{"🏈 " + teamFilter}</span>
                                    <button className="team-filter-remove" onClick={handleClearTeam}>✕</button>
                                </span>
                            </div>
                        ) if teamFilter else (
                            <div className="filter-search-wrapper">
                                <span className="search-icon">🔍</span>
                                <input
                                    className="input"
                                    placeholder="Search by team name..."
                                    value={teamSearchText}
                                    onChange={handleTeamSearchInput}
                                    onBlur={handleBlur}
                                    onFocus={handleFocus}
                                    style={({"paddingLeft": "2.5rem"})}
                                />
                                {(
                                    <div className="team-suggestions">
                                        {team_suggestions.map(lambda team: dict -> any {
                                            tName = team["name"];
                                            return <button
                                                key={team["id"]}
                                                className="team-suggestion-item"
                                                onMouseDown={lambda -> None { handleTeamClick(tName); }}
                                            >
                                                <span className="team-suggestion-logo">🏈</span>
                                                <div className="team-suggestion-info">
                                                    <span className="team-suggestion-name">{team["name"]}</span>
                                                    <span className="team-suggestion-conf">{team["conference"]}</span>
                                                </div>
                                            </button>;
                                        })}
                                    </div>
                                ) if showSuggestions and team_suggestions.length > 0 else None}
                            </div>
                        )}
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
                        className={"btn favorites-toggle-btn" + (" active" if favoritesOnly else "")}
                        onClick={onToggleFavoritesOnly}
                        disabled={favoriteTeamIds.length == 0}
                    >
                        {("★ Favorites" if favoritesOnly else "☆ Favorites")}
                    </button>

                    <button
                        className={"btn rivals-toggle-btn" + (" active" if rivalsOnly else "")}
                        onClick={onToggleRivalsOnly}
                        disabled={rivalTeamIds.length == 0}
                    >
                        {("★ Rivals" if rivalsOnly else "☆ Rivals")}
                    </button>
                </div>
            </div>

            {(
                <div className="loading-overlay">
                    <div className="spinner"></div>
                    <p className="text-muted">Loading transactions...</p>
                </div>
            ) if transactionsLoading and transactions.length == 0 else (
                <div>
                    {(
                        <div style={({"textAlign": "center", "padding": "3rem"})}>
                            <h2 className="text-muted">No Transactions Found</h2>
                            <p className="text-muted">Try adjusting your filters to see more results.</p>
                        </div>
                    ) if transactions.length == 0 and not transactionsLoading else (
                        <div>
                            <p className="results-count">
                                {"Showing " + String(transactions.length) + " of " + String(totalTransactions) + " transactions"}
                            </p>
                            <div className="space-y-4">
                                {transactions.map(lambda t: dict -> any {
                                    tId = t["id"];
                                    isNotEnrolled = t["status"] != "Enrolled" and t["status"] != "Committed" and t["toTeam"] == "Undecided";
                                    hasCrystalBall = crystalBallTexts[tId] if crystalBallTexts[tId] else "";
                                    isCrystalBallLoading = crystalBallLoading.includes(t["id"]);
                                    isCrystalBallExpanded = expandedCrystalBalls.includes(t["id"]);
                                    return <div key={t["id"]}>
                                        <TransactionCard
                                            transaction={t}
                                            showAIImpact={expandedAIImpacts.includes(t["id"])}
                                            onToggleAIImpact={onToggleAIImpact}
                                            onNavigate={onNavigate}
                                            aiImpactText={(aiImpactTexts[tId] if aiImpactTexts[tId] else "")}
                                            aiImpactLoading={aiImpactLoading.includes(t["id"])}
                                        />
                                        {(
                                            <div className="crystal-ball-section">
                                                <button
                                                    className={"btn crystal-ball-btn" + (" loading" if isCrystalBallLoading else "")}
                                                    onClick={lambda -> None { onToggleCrystalBall(tId); }}
                                                    disabled={isCrystalBallLoading}
                                                >
                                                    {("🔮 Predicting..." if isCrystalBallLoading else ("🔮 Crystal Ball - Hide Prediction" if isCrystalBallExpanded and hasCrystalBall else "🔮 Crystal Ball - Predict Destination"))}
                                                </button>
                                                {(
                                                    <div className="crystal-ball-result">
                                                        <span className="badge badge-accent-solid">AI Prediction</span>
                                                        <p>{hasCrystalBall}</p>
                                                    </div>
                                                ) if isCrystalBallExpanded and hasCrystalBall and not isCrystalBallLoading else None}
                                            </div>
                                        ) if isNotEnrolled else None}
                                    </div>;
                                })}
                            </div>

                            {(
                                <div style={({"textAlign": "center", "padding": "1.5rem"})}>
                                    <button
                                        className="btn btn-outline-accent rounded-lg"
                                        onClick={onLoadMore}
                                        disabled={transactionsLoading}
                                    >
                                        {("Loading..." if transactionsLoading else "Show More Transactions (" + String(totalTransactions - transactions.length) + " remaining)")}
                                    </button>
                                </div>
                            ) if has_more else None}
                        </div>
                    )}
                </div>
            )}
        </div>;
}
