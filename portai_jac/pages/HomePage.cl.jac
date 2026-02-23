"""Home Page - Dashboard with AI overview, transactions, trends, and stats."""

import from ..components.AISummaryCard { AISummaryCard }
import from ..components.TransactionCard { TransactionCard }
import from ..data.mock_data {
    mock_transactions, mock_teams, default_favorite_team_ids, portal_stats
}

def:pub HomePage(
    onNavigate: any,
    favoriteTeamIds: list,
    aiSummary: str,
    aiSummaryTitle: str,
    aiSummaryLoading: bool,
    onRegenerateSummary: any,
    expandedAIImpacts: list,
    onToggleAIImpact: any
) -> any {
    favorite_teams = [t for t in mock_teams if favoriteTeamIds.includes(t["id"])];
    has_favorites = favorite_teams.length > 0;

    trending_teams = mock_teams.slice().sort(
        lambda a: dict, b: dict -> int { return b["portalActivityScore"] - a["portalActivityScore"]; }
    ).slice(0, 5);

    max_portal_val = 45;

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
                        <h2>Recent Transactions</h2>
                        <span className="badge badge-secondary text-xs">Updated 5 min ago</span>
                    </div>
                    <div className="space-y-4">
                        {[
                            <TransactionCard
                                key={t["id"]}
                                transaction={t}
                                showAIImpact={expandedAIImpacts.includes(t["id"])}
                                onToggleAIImpact={onToggleAIImpact}
                                onNavigate={onNavigate}
                            />
                            for t in mock_transactions
                        ]}
                    </div>
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
                            <div className="portal-stat-label">Total Transfers This Week</div>
                            <div className="portal-stat-value">247</div>
                        </div>

                        <div>
                            <p className="text-sm text-muted mb-3">Top Positions Entering Portal</p>
                            <div className="bar-chart">
                                {portal_stats.map(lambda stat: any -> any {
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

                        <div className="border-t" style={({"paddingTop": "1rem"})}>
                            <p className="text-sm text-muted mb-3">Most Active Conferences</p>
                            <div className="space-y-2">
                                <div className="conference-stat-row">
                                    <span>SEC</span>
                                    <span className="badge badge-secondary">89</span>
                                </div>
                                <div className="conference-stat-row">
                                    <span>Big Ten</span>
                                    <span className="badge badge-secondary">76</span>
                                </div>
                                <div className="conference-stat-row">
                                    <span>ACC</span>
                                    <span className="badge badge-secondary">54</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>;
}
