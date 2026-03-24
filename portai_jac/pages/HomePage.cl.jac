"""Home Page - Dashboard with AI overview, transactions, trends, and stats."""

import from ..components.AISummaryCard { AISummaryCard }
import from ..components.TransactionCard { TransactionCard }
import from ..data.mock_data {
    mock_teams, default_favorite_team_ids
}

def:pub HomePage(
    onNavigate: any,
    favoriteTeamIds: list,
    aiSummary: str,
    aiSummaryTitle: str,
    aiSummaryLoading: bool,
    onRegenerateSummary: any,
    expandedAIImpacts: list,
    onToggleAIImpact: any,
    transactions: list,
    transactionsLoading: bool,
    totalTransactions: int,
    onLoadMore: any,
    aiImpactTexts: any,
    aiImpactLoading: list,
    portalStatsData: any,
    sortByFavorites: bool,
    onToggleSortByFavorites: callable,
    teamCounts: any,
    onToggleWatch: any,
    watchedPlayerIds: any,

) -> any {
    
    enriched_teams = mock_teams.map(
        lambda team: dict -> dict {
            counts = (teamCounts[team["name"]] if teamCounts and teamCounts[team["name"]] else {"incoming": 0, "outgoing": 0});
            return Object.assign({}, team, {
                "incomingCount": counts["incoming"],
                "outgoingCount": counts["outgoing"],
                "portalActivityScore": counts["incoming"] + counts["outgoing"]
            });
        }
    );

    favorite_teams = [t for t in enriched_teams if favoriteTeamIds.includes(t["id"])];
    has_favorites = favorite_teams.length > 0;

    trending_teams = enriched_teams.slice().sort(
        lambda a: dict, b: dict -> int { return b["portalActivityScore"] - a["portalActivityScore"]; }
    ).slice(0, 5);

    favorite_team_names = mock_teams
        .filter(lambda t: dict -> bool { return favoriteTeamIds.includes(t["id"]); })
        .map(lambda t: dict -> str { return t["name"]; });

    sorted_transactions = (
        transactions.slice().sort(lambda a: dict, b: dict -> int {
            a_fav = (1 if favorite_team_names.filter(lambda n: str -> bool { return a["fromTeam"].indexOf(n) >= 0 or n.indexOf(a["fromTeam"]) >= 0 or a["toTeam"].indexOf(n) >= 0 or n.indexOf(a["toTeam"]) >= 0; }).length > 0 else 0);
            b_fav = (1 if favorite_team_names.filter(lambda n: str -> bool { return b["fromTeam"].indexOf(n) >= 0 or n.indexOf(b["fromTeam"]) >= 0 or b["toTeam"].indexOf(n) >= 0 or n.indexOf(b["toTeam"]) >= 0; }).length > 0 else 0);
            if b_fav != a_fav { return b_fav - a_fav; }
            return (b["rating"] - a["rating"]);
        })
        if sortByFavorites else transactions
    );

    # Use dynamic portal stats if available, fallback to defaults
    total_transfers = (portalStatsData["totalTransfers"] if portalStatsData and portalStatsData["totalTransfers"] else 0);
    top_positions = (portalStatsData["topPositions"] if portalStatsData and portalStatsData["topPositions"] else []);
    top_conferences = (portalStatsData["topConferences"] if portalStatsData and portalStatsData["topConferences"] else []);
    max_portal_val = 1;
    if top_positions.length > 0 {
        max_portal_val = top_positions[0]["value"];
    }

    has_more = transactions.length < totalTransactions;

    return
        <div className="home-grid">
            <div className="home-main">
                <AISummaryCard
                    title={(
                        aiSummaryTitle if aiSummaryTitle
                        else (
                            "Transfer Impact Overview - Loading..."
                            if aiSummaryLoading
                            else "Transfer Impact Overview"
                        )
                    )}
                    content={(
                        aiSummary if aiSummary
                        else (
                            ""
                            if aiSummaryLoading
                            else "Click 'Regenerate Summary' to generate an AI-powered overview of transfer portal activity."
                        )
                    )}
                    onRegenerate={onRegenerateSummary}
                    loading={aiSummaryLoading}
                />

                <div>
                    <div className="section-header">
                        <h2>Notable Transactions</h2>
                        <div style={({"display": "flex", "alignItems": "center", "gap": "0.75rem"})}>
                            <button
                                className={("btn btn-sm " + ("btn-accent" if sortByFavorites else "btn-outline-accent")) + " rounded-lg"}
                                onClick={onToggleSortByFavorites}
                            >
                                ⭐ Favorites First
                            </button>
                            <span className="badge badge-secondary text-xs">
                                {String(totalTransactions) + " total transfers"}
                            </span>
                        </div>
                    </div>
                    {(
                        <div className="space-y-4">
                            <div className="loading-placeholder" style={({"padding": "2rem", "textAlign": "center"})}>
                                <p className="text-muted">Loading transactions from database...</p>
                            </div>
                        </div>
                    ) if transactionsLoading and transactions.length == 0 else (
                        <div className="space-y-4">
                            {sorted_transactions.map(lambda t: dict -> any {
                                tId = t["id"];
                                isWatched = watchedPlayerIds.includes(t["id"]);

                                return <TransactionCard
                                    key={t["id"]}
                                    transaction={t}
                                    showAIImpact={expandedAIImpacts.includes(t["id"])}
                                    onToggleAIImpact={onToggleAIImpact}
                                    onNavigate={onNavigate}
                                    aiImpactText={(aiImpactTexts[tId] if aiImpactTexts[tId] else "")}
                                    aiImpactLoading={aiImpactLoading.includes(t["id"])}

                                    isWatched={isWatched}
                                    onToggleWatch={onToggleWatch}


                                />;
                            })}

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
            </div>

            <div className="home-sidebar">
                <div className="card-static card-padding">
                    <h3 className="mb-4">Trending Teams</h3>
                    <div className="space-y-2">
                        {trending_teams.map(lambda team: dict, index: int -> any {
                            teamId = team["id"];
                            return <div key={team["id"]}
                                 className="trending-team-item"
                                 onClick={lambda -> None { onNavigate("team-detail:" + teamId); }}>
                                <span className="trending-team-rank">{"#" + String(index + 1)}</span>
                                <span className="trending-team-logo">{team["logo"]}</span>
                                <div className="trending-team-info">
                                    <div className="trending-team-name">{team["name"]}</div>
                                    <div className="trending-team-conf">{team["conference"]}</div>
                                </div>
                                <div className="trending-team-score">
                                    <span className="arrow">↑</span>
                                    <span>{team["portalActivityScore"]}</span>
                                </div>
                            </div>;
                        })}
                    </div>
                </div>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Portal Stats Snapshot</h3>
                    <div className="space-y-4">
                        <div className="portal-stat-highlight">
                            <div className="portal-stat-label">Total Transfers (2026)</div>
                            <div className="portal-stat-value">{String(total_transfers)}</div>
                        </div>

                        {(
                            <div>
                                <p className="text-sm text-muted mb-3">Top Positions Entering Portal</p>
                                <div className="bar-chart">
                                    {top_positions.map(lambda stat: any -> any {
                                        bar_height = String(Math.round(stat["value"] / max_portal_val * 100)) + "%";
                                        bar_style = {"height": bar_height};
                                        return <div key={stat["name"]} className="bar-chart-item">
                                            <span className="bar-chart-value">{stat["value"]}</span>
                                            <div className="bar-chart-bar"
                                                 style={bar_style}></div>
                                            <span className="bar-chart-label">{stat["name"]}</span>
                                        </div>;
                                    })}
                                </div>
                            </div>
                        ) if top_positions.length > 0 else None}

                        {(
                            <div className="border-t" style={({"paddingTop": "1rem"})}>
                                <p className="text-sm text-muted mb-3">Most Active Conferences</p>
                                <div className="space-y-2">
                                    {top_conferences.map(lambda conf: any -> any {
                                        return <div key={conf["name"]} className="conference-stat-row">
                                            <span>{conf["name"]}</span>
                                            <span className="badge badge-secondary">{conf["transfers"]}</span>
                                        </div>;
                                    })}
                                </div>
                            </div>
                        ) if top_conferences.length > 0 else None}
                    </div>
                </div>
            </div>
        </div>;
}
