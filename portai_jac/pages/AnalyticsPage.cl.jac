"""Analytics Page - Transfer portal trends, position breakdowns, conference activity, and rating distributions."""

import from ..data.mock_data { mock_teams }

def:pub AnalyticsPage(
    onNavigate: any,
    transactions: list,
    portalStatsData: any,
    favoriteTeamIds: list,
    teamCounts: any,
    aiAnalysisSummary: str,
    aiAnalysisLoading: bool,
    onRegenerateAnalysis: any,
    dateRange: str,
    onDateRangeChange: any
) -> any {

    # ── Derived counts ────────────────────────────────────────────────────────

    total_transfers = (portalStatsData["totalTransfers"] if portalStatsData and portalStatsData["totalTransfers"] else transactions.length);
    top_positions   = (portalStatsData["topPositions"]   if portalStatsData and portalStatsData["topPositions"]   else []);
    top_conferences = (portalStatsData["topConferences"] if portalStatsData and portalStatsData["topConferences"] else []);

    # Committed vs undecided
    committed_count  = transactions.filter(lambda t: dict -> bool { return t["toTeam"] != "Undecided" and t["toTeam"] != ""; }).length;
    undecided_count  = total_transfers - committed_count;
    commit_pct       = (Math.round(committed_count / total_transfers * 100) if total_transfers > 0 else 0);

    # Average rating
    rated_txns  = transactions.filter(lambda t: dict -> bool { return t["rating"] and t["rating"] > 0; });
    avg_rating  = (
        Math.round(rated_txns.reduce(lambda acc: float, t: dict -> float { return acc + t["rating"]; }, 0.0) / rated_txns.length * 10) / 10
        if rated_txns.length > 0 else 0
    );

    # Star rating buckets  (5★ → 4★ → 3★ → 2★ → 1★)
    star_buckets = {"5": 0, "4": 0, "3": 0, "2": 0, "1": 0};
    transactions.forEach(lambda t: dict -> None {
        s = String(t["starRating"]);
        if star_buckets[s] != None { star_buckets[s] = star_buckets[s] + 1; }
    });
    star_data = [
        {"label": "5★", "value": star_buckets["5"], "color": "#f59e0b"},
        {"label": "4★", "value": star_buckets["4"], "color": "#10b981"},
        {"label": "3★", "value": star_buckets["3"], "color": "#3b82f6"},
        {"label": "2★", "value": star_buckets["2"], "color": "#8b5cf6"},
        {"label": "1★", "value": star_buckets["1"], "color": "var(--text-muted)"}
    ];
    # max_star = Math.max(...star_data.map(lambda s: any -> int { return s["value"]; }));

    # Top 5 gaining teams (most incoming)
    enriched_teams = mock_teams.map(
        lambda team: dict -> dict {
            counts = (teamCounts[team["name"]] if teamCounts and teamCounts[team["name"]] else {"incoming": 0, "outgoing": 0});
            return Object.assign({}, team, {
                "incomingCount": counts["incoming"],
                "outgoingCount": counts["outgoing"],
                "netActivity": counts["incoming"] - counts["outgoing"]
            });
        }
    );

    top_gainers = enriched_teams.slice().sort(
        lambda a: dict, b: dict -> int { return b["incomingCount"] - a["incomingCount"]; }
    ).slice(0, 5);

    top_losers = enriched_teams.slice().sort(
        lambda a: dict, b: dict -> int { return b["outgoingCount"] - a["outgoingCount"]; }
    ).slice(0, 5);

    max_incoming = (top_gainers[0]["incomingCount"] if top_gainers.length > 0 and top_gainers[0]["incomingCount"] > 0 else 1);
    max_outgoing = (top_losers[0]["outgoingCount"]  if top_losers.length  > 0 and top_losers[0]["outgoingCount"]  > 0 else 1);

    max_conf_val = (top_conferences[0]["transfers"] if top_conferences.length > 0 else 1);
    max_pos_val  = (top_positions[0]["value"]       if top_positions.length  > 0 else 1);

    # ── Render ────────────────────────────────────────────────────────────────

    return
        <div className="space-y-6">

            <div className="section-header">
                <div>
                    <h1>Transfer Portal Analytics</h1>
                    <p className="text-muted" style={({"marginTop": "0.25rem"})}>
                        Live trends, position breakdowns, and team movement data
                    </p>
                </div>
                <div style={({"display": "flex", "alignItems": "center", "gap": "0.75rem"})}>
                    <select
                        className="btn btn-outline btn-sm rounded-lg"
                        value={dateRange}
                        onChange={lambda e: any -> None { onDateRangeChange(e.target.value); }}
                        style={({"cursor": "pointer"})}>
                        <option value="all">All Time</option>
                        <option value="30d">Last 30 Days</option>
                        <option value="7d">Last 7 Days</option>
                    </select>
                </div>
            </div>

            <div style={({"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(160px, 1fr))", "gap": "1rem"})}>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--accent)"})}>
                        {String(total_transfers)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Total Transfers</div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "#10b981"})}>
                        {String(committed_count)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Committed</div>
                    <div style={({"fontSize": "0.75rem", "color": "#10b981", "marginTop": "0.125rem"})}>
                        {String(commit_pct) + "% of portal"}
                    </div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--warning, #f59e0b)"})}>
                        {String(undecided_count)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Undecided</div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700"})}>
                        {String(avg_rating)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Avg Rating</div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700"})}>
                        {String(top_conferences.length)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Conferences Active</div>
                </div>

            </div>

            <div style={({"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "1.25rem"})}>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Star Rating Distribution</h3>
                    <div className="space-y-3">
                        {star_data.map(lambda s: any -> any {
                            # bar_pct = (Math.round(s["value"] / max_star * 100) if max_star > 0 else 0);
                            return <div key={s["label"]} style={({"display": "flex", "alignItems": "center", "gap": "0.75rem"})}>
                                <span style={({"minWidth": "2rem", "fontSize": "0.85rem", "fontWeight": "600", "color": s["color"]})}>
                                    {s["label"]}
                                </span>
                                <div style={({"flex": "1", "background": "var(--surface-2, var(--bg-card))", "borderRadius": "4px", "height": "10px", "overflow": "hidden"})}>
                                </div>
                            
                            </div>;
                        })}
                    </div>
                </div>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Commitment Status</h3>
                    <div style={({"display": "flex", "flexDirection": "column", "gap": "1rem"})}>
                        <div style={({"display": "flex", "alignItems": "center", "justifyContent": "center", "gap": "2rem", "padding": "1rem 0"})}>
                            <div style={({"textAlign": "center"})}>
                                <div style={({"fontSize": "2.5rem", "fontWeight": "700", "color": "#10b981"})}>
                                    {String(commit_pct) + "%"}
                                </div>
                                <div className="text-muted" style={({"fontSize": "0.8rem"})}>Committed</div>
                            </div>
                            <div style={({"width": "1px", "height": "60px", "background": "var(--border)"})}>
                            </div>
                            <div style={({"textAlign": "center"})}>
                                <div style={({"fontSize": "2.5rem", "fontWeight": "700", "color": "var(--warning, #f59e0b)"})}>
                                    {String(100 - commit_pct) + "%"}
                                </div>
                                <div className="text-muted" style={({"fontSize": "0.8rem"})}>Undecided</div>
                            </div>
                        </div>
                        <div style={({"background": "var(--surface-2, var(--bg-card))", "borderRadius": "6px", "height": "12px", "overflow": "hidden"})}>
                            <div style={({"width": String(commit_pct) + "%", "height": "100%", "background": "linear-gradient(90deg, #10b981, var(--accent))", "transition": "width 0.6s ease"})}>
                            </div>
                        </div>
                        <div style={({"display": "flex", "justifyContent": "space-between"})}>
                            <span className="text-muted" style={({"fontSize": "0.8rem"})}>
                                {String(committed_count) + " committed"}
                            </span>
                            <span className="text-muted" style={({"fontSize": "0.8rem"})}>
                                {String(undecided_count) + " still deciding"}
                            </span>
                        </div>
                    </div>
                </div>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Top Positions Entering Portal</h3>
                    {(
                        <div className="bar-chart">
                            {top_positions.slice(0, 6).map(lambda stat: any -> any {
                                bar_height = String(Math.round(stat["value"] / max_pos_val * 100)) + "%";
                                return <div key={stat["name"]} className="bar-chart-item">
                                    <span className="bar-chart-value">{stat["value"]}</span>
                                    <div className="bar-chart-bar" style={({"height": bar_height})}>
                                    </div>
                                    <span className="bar-chart-label">{stat["name"]}</span>
                                </div>;
                            })}
                        </div>
                    ) if top_positions.length > 0 else (
                        <p className="text-muted">No position data available.</p>
                    )}
                </div>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Most Active Conferences</h3>
                    {(
                        <div className="space-y-3">
                            {top_conferences.map(lambda conf: any, idx: int -> any {
                                bar_pct = Math.round(conf["transfers"] / max_conf_val * 100);
                                conf_colors = ["var(--accent)", "#8b5cf6", "#3b82f6", "#10b981", "#f59e0b", "#ef4444"];
                                color = (conf_colors[idx] if idx < conf_colors.length else "var(--text-muted)");
                                return <div key={conf["name"]}>
                                    <div style={({"display": "flex", "justifyContent": "space-between", "marginBottom": "0.3rem"})}>
                                        <span style={({"fontSize": "0.85rem", "fontWeight": "500"})}>
                                            {conf["name"]}
                                        </span>
                                        <span className="badge badge-secondary">{conf["transfers"]}</span>
                                    </div>
                                    <div style={({"background": "var(--surface-2, var(--bg-card))", "borderRadius": "4px", "height": "8px", "overflow": "hidden"})}>
                                        <div style={({"width": String(bar_pct) + "%", "height": "100%", "background": color, "borderRadius": "4px"})}>
                                        </div>
                                    </div>
                                </div>;
                            })}
                        </div>
                    ) if top_conferences.length > 0 else (
                        <p className="text-muted">No conference data available.</p>
                    )}
                </div>

            </div>

            <div style={({"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "1.25rem"})}>

                <div className="card-static card-padding">
                    <div className="section-header mb-4">
                        <h3>Top Gaining Teams</h3>
                        <span className="badge badge-secondary text-xs" style={({"color": "#10b981"})}>↑ Incoming</span>
                    </div>
                    <div className="space-y-2">
                        {top_gainers.map(lambda team: dict, index: int -> any {
                            teamId = team["id"];
                            bar_pct = Math.round(team["incomingCount"] / max_incoming * 100);
                            return <div
                                key={team["id"]}
                                className="trending-team-item"
                                style={({"cursor": "pointer"})}
                                onClick={lambda -> None { onNavigate("team-detail:" + teamId); }}>
                                <span className="trending-team-rank">{"#" + String(index + 1)}</span>
                                <span className="trending-team-logo">{team["logo"]}</span>
                                <div className="trending-team-info" style={({"flex": "1"})}>
                                    <div className="trending-team-name">{team["name"]}</div>
                                    <div style={({"background": "var(--surface-2, var(--bg-card))", "borderRadius": "3px", "height": "5px", "marginTop": "4px", "overflow": "hidden"})}>
                                        <div style={({"width": String(bar_pct) + "%", "height": "100%", "background": "#10b981", "borderRadius": "3px"})}>
                                        </div>
                                    </div>
                                </div>
                                <div className="trending-team-score">
                                    <span style={({"color": "#10b981"})}>↑</span>
                                    <span>{team["incomingCount"]}</span>
                                </div>
                            </div>;
                        })}
                    </div>
                </div>

                <div className="card-static card-padding">
                    <div className="section-header mb-4">
                        <h3>Most Departures</h3>
                        <span className="badge badge-secondary text-xs" style={({"color": "var(--destructive, #ef4444)"})}>↓ Outgoing</span>
                    </div>
                    <div className="space-y-2">
                        {top_losers.map(lambda team: dict, index: int -> any {
                            teamId = team["id"];
                            bar_pct = Math.round(team["outgoingCount"] / max_outgoing * 100);
                            return <div
                                key={team["id"]}
                                className="trending-team-item"
                                style={({"cursor": "pointer"})}
                                onClick={lambda -> None { onNavigate("team-detail:" + teamId); }}>
                                <span className="trending-team-rank">{"#" + String(index + 1)}</span>
                                <span className="trending-team-logo">{team["logo"]}</span>
                                <div className="trending-team-info" style={({"flex": "1"})}>
                                    <div className="trending-team-name">{team["name"]}</div>
                                    <div style={({"background": "var(--surface-2, var(--bg-card))", "borderRadius": "3px", "height": "5px", "marginTop": "4px", "overflow": "hidden"})}>
                                        <div style={({"width": String(bar_pct) + "%", "height": "100%", "background": "var(--destructive, #ef4444)", "borderRadius": "3px"})}>
                                        </div>
                                    </div>
                                </div>
                                <div className="trending-team-score">
                                    <span style={({"color": "var(--destructive, #ef4444)"})}>↓</span>
                                    <span>{team["outgoingCount"]}</span>
                                </div>
                            </div>;
                        })}
                    </div>
                </div>

            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "0.75rem"})}>
                    <h2>⚡ AI Portal Analysis</h2>
                    <button
                        className="btn btn-outline btn-sm rounded-lg"
                        onClick={onRegenerateAnalysis}
                        disabled={aiAnalysisLoading}>
                        {("Generating..." if aiAnalysisLoading else "Regenerate Analysis")}
                    </button>
                </div>
                {(
                    <div className="loading-overlay" style={({"padding": "1rem"})}>
                        <div className="spinner"></div>
                    </div>
                ) if aiAnalysisLoading else (
                    <p style={({"lineHeight": "1.7", "color": "var(--text-secondary, var(--text-muted))"})}>
                        {(
                            aiAnalysisSummary if aiAnalysisSummary
                            else "Click 'Regenerate Analysis' to get an AI-powered breakdown of current transfer portal trends."
                        )}
                    </p>
                )}
            </div>

        </div>;
}
