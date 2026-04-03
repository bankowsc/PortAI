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
    onDateRangeChange: any,
    today: any,
    analyticsTransactions: list,
    analyticsDataLoaded: bool
) -> any {

    # Use the full background-loaded dataset when available, otherwise fall back to partial data
    effective_transactions = (analyticsTransactions if analyticsDataLoaded and analyticsTransactions.length > 0 else transactions);

    # ── Derived counts ────────────────────────────────────────────────────────

    total_transfers = (portalStatsData["totalTransfers"] if portalStatsData and portalStatsData["totalTransfers"] else effective_transactions.length);
    top_positions   = (portalStatsData["topPositions"]   if portalStatsData and portalStatsData["topPositions"]   else []);
    top_conferences = (portalStatsData["topConferences"] if portalStatsData and portalStatsData["topConferences"] else []);

    # Committed vs enrolled vs undecided
    enrolled_count  = effective_transactions.filter(lambda t: dict -> bool { return t["status"] == "Enrolled"; }).length;
    committed_count = effective_transactions.filter(lambda t: dict -> bool { return t["status"] == "Committed"; }).length;
    undecided_count = effective_transactions.filter(lambda t: dict -> bool { return t["toTeam"] == "Undecided" or t["toTeam"] == ""; }).length;
    commit_pct      = (Math.round(committed_count / total_transfers * 100) if total_transfers > 0 else 0);
    enrolled_pct    = (Math.round(enrolled_count  / total_transfers * 100) if total_transfers > 0 else 0);
    undecided_pct   = (Math.round(undecided_count / total_transfers * 100) if total_transfers > 0 else 0);

    # Average rating
    rated_txns = effective_transactions.filter(lambda t: dict -> bool { return t["rating"] and t["rating"] > 0; });
    avg_rating = (
        Math.round(rated_txns.reduce(lambda acc: float, t: dict -> float { return acc + t["rating"]; }, 0.0) / rated_txns.length * 10) / 10
        if rated_txns.length > 0 else 0
    );

    # Position vs conference heatmap
    # heatmap_positions   = ["QB", "WR", "RB", "IOL", "CB", "LB"];
    heatmap_positions = ["QB", "RB", "WR", "TE", "OT", "IOL", "Edge", "DL", "LB", "CB", "S", "K", "P", "LS"];

    heatmap_conferences = ["SEC", "Big Ten", "Big 12", "ACC", "Pac-12"];
    heatmap_counts = {};
    heatmap_positions.forEach(lambda pos: str -> None {
        heatmap_conferences.forEach(lambda conf: str -> None {
            heatmap_counts[pos + "|" + conf] = 0;
        });
    });
    effective_transactions.forEach(lambda t: dict -> None {
        pos  = t["position"];
        conf = t["conference"];
        if pos and conf {
            key = pos + "|" + conf;
            if heatmap_counts[key] != None {
                heatmap_counts[key] = heatmap_counts[key] + 1;
            }
        }
    });
    heatmap_max = heatmap_positions.reduce(
        lambda outer_acc: int, pos: str -> int {
            row_max = heatmap_conferences.reduce(
                lambda inner_acc: int, conf: str -> int {
                    v = heatmap_counts[pos + "|" + conf];
                    val = (v if v else 0);
                    return (val if val > inner_acc else inner_acc);
                }, 0
            );
            return (row_max if row_max > outer_acc else outer_acc);
        }, 1
    );

    # Top 5 gaining / losing teams
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

            {(
                <div className="card-static" style={({"padding": "0.75rem 1rem", "display": "flex", "alignItems": "center", "gap": "0.75rem", "background": "var(--surface-2, var(--bg-card))", "borderLeft": "3px solid var(--accent)"})}>
                    <div className="spinner" style={({"width": "16px", "height": "16px", "borderWidth": "2px"})}>
                    </div>
                    <span className="text-muted" style={({"fontSize": "0.85rem"})}>
                        Loading complete transfer portal data in the background... Statistics will update automatically.
                    </span>
                </div>
            ) if not analyticsDataLoaded else ""}

            <div className="section-header">
                <div>
                    <h1>Transfer Portal Analytics</h1>
                    <p className="text-muted" style={({"marginTop": "0.25rem"})}>
                        {(
                            "Live trends, position breakdowns, and team movement data"
                            if analyticsDataLoaded
                            else "Loading full dataset... showing partial data (" + String(effective_transactions.length) + " of " + String(total_transfers) + " transfers)"
                        )}
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
                    <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "#8b5cf6"})}>
                        {String(enrolled_count)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Enrolled</div>
                    <div style={({"fontSize": "0.75rem", "color": "#8b5cf6", "marginTop": "0.125rem"})}>
                        {String(enrolled_pct) + "% of portal"}
                    </div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--warning, #f59e0b)"})}>
                        {String(undecided_count)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Undecided</div>
                    <div style={({"fontSize": "0.75rem", "color": "#f59e0b", "marginTop": "0.125rem"})}>
                        {String(undecided_pct) + "% of portal"}
                    </div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "2rem", "fontWeight": "700"})}>
                        {String(avg_rating)}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginTop": "0.25rem"})}>Avg Portal Rating</div>
                </div>

                <div className="card-static card-padding" style={({"textAlign": "center"})}>
                    <div style={({"fontSize": "1rem", "fontWeight": "700", "color": "var(--warning, #ef4444)"})}>
                        {String(today.substring(today.indexOf(",") + 2))}
                    </div>
                    <div className="text-muted" style={({"fontSize": "0.85rem", "marginBottom": "0.25rem"})}>Today</div>
                    <div style={({"fontSize": "1rem", "color": "#ef4444", "marginBottom": "0.25rem"})}>
                        {String(today.substring(0, today.indexOf(",")))}
                    </div>
                </div>

            </div>

            <div style={({"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "1.25rem"})}>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Position × Conference Heatmap</h3>
                    <div style={({"overflowX": "auto"})}>
                        <table style={({"width": "100%", "borderCollapse": "collapse", "fontSize": "0.78rem"})}>
                            <thead>
                                <tr>
                                    <th style={({"padding": "4px 6px", "textAlign": "left", "color": "var(--text-muted)", "fontWeight": "500", "width": "36px"})}>
                                    </th>
                                    {heatmap_conferences.map(lambda conf: str -> any {
                                        return <th key={conf} style={({"padding": "4px 6px", "textAlign": "center", "color": "var(--text-muted)", "fontWeight": "500", "whiteSpace": "nowrap"})}>
                                            {conf}
                                        </th>;
                                    })}
                                </tr>
                            </thead>
                            <tbody>
                                {heatmap_positions.map(lambda pos: str -> any {
                                    return <tr key={pos}>
                                        <td style={({"padding": "4px 6px", "fontWeight": "600", "color": "var(--text-secondary)", "whiteSpace": "nowrap"})}>
                                            {pos}
                                        </td>
                                        {heatmap_conferences.map(lambda conf: str -> any {
                                            cell_key = pos + "|" + conf;
                                            raw = heatmap_counts[cell_key];
                                            val = (raw if raw else 0);
                                            intensity = (Math.round(val / heatmap_max * 100) if heatmap_max > 0 else 0);
                                            bg = (
                                                "rgba(16,185,129,0.7)"  if intensity > 75 else (
                                                "rgba(16,185,129,0.45)" if intensity > 50 else (
                                                "rgba(16,185,129,0.2)"  if intensity > 25 else (
                                                "rgba(16,185,129,0.07)" if intensity > 0  else
                                                "var(--surface-2, var(--bg-card))"
                                                )))
                                            );
                                            text_color = ("var(--color-text-primary)" if intensity > 50 else "var(--text-muted)");
                                            return <td key={conf} style={({"padding": "5px 6px", "textAlign": "center", "background": bg, "borderRadius": "4px", "color": text_color, "fontWeight": ("600" if intensity > 50 else "400")})}>
                                                {(String(val) if val > 0 else "–")}
                                            </td>;
                                        })}
                                    </tr>;
                                })}
                            </tbody>
                        </table>
                        <div style={({"display": "flex", "alignItems": "center", "gap": "0.5rem", "marginTop": "0.75rem"})}>
                            <span className="text-muted" style={({"fontSize": "0.75rem"})}>Low</span>
                            <div style={({"display": "flex", "gap": "3px"})}>
                                <div style={({"width": "16px", "height": "10px", "borderRadius": "2px", "background": "rgba(16,185,129,0.07)"})}></div>
                                <div style={({"width": "16px", "height": "10px", "borderRadius": "2px", "background": "rgba(16,185,129,0.2)"})}></div>
                                <div style={({"width": "16px", "height": "10px", "borderRadius": "2px", "background": "rgba(16,185,129,0.45)"})}></div>
                                <div style={({"width": "16px", "height": "10px", "borderRadius": "2px", "background": "rgba(16,185,129,0.7)"})}></div>
                            </div>
                            <span className="text-muted" style={({"fontSize": "0.75rem"})}>High</span>
                        </div>
                    </div>
                </div>

                <div className="card-static card-padding">
                    <h3 className="mb-4">Commitment Status</h3>
                    <div style={({"display": "flex", "flexDirection": "column", "gap": "1rem"})}>
                        <div style={({"display": "flex", "alignItems": "center", "justifyContent": "center", "gap": "1.5rem", "padding": "1rem 0"})}>
                            <div style={({"textAlign": "center"})}>
                                <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "#10b981"})}>
                                    {String(commit_pct) + "%"}
                                </div>
                                <div className="text-muted" style={({"fontSize": "0.8rem"})}>Committed</div>
                                <div style={({"fontSize": "0.75rem", "color": "#10b981"})}>{String(committed_count)}</div>
                            </div>
                            <div style={({"width": "1px", "height": "60px", "background": "var(--border)"})}>
                            </div>
                            <div style={({"textAlign": "center"})}>
                                <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "#8b5cf6"})}>
                                    {String(enrolled_pct) + "%"}
                                </div>
                                <div className="text-muted" style={({"fontSize": "0.8rem"})}>Enrolled</div>
                                <div style={({"fontSize": "0.75rem", "color": "#8b5cf6"})}>{String(enrolled_count)}</div>
                            </div>
                            <div style={({"width": "1px", "height": "60px", "background": "var(--border)"})}>
                            </div>
                            <div style={({"textAlign": "center"})}>
                                <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--warning, #f59e0b)"})}>
                                    {String(undecided_pct) + "%"}
                                </div>
                                <div className="text-muted" style={({"fontSize": "0.8rem"})}>Undecided</div>
                                <div style={({"fontSize": "0.75rem", "color": "var(--warning, #f59e0b)"})}>{String(undecided_count)}</div>
                            </div>
                        </div>
                        <div style={({"background": "var(--surface-2, var(--bg-card))", "borderRadius": "6px", "height": "12px", "overflow": "hidden", "display": "flex"})}>
                            <div style={({"width": String(commit_pct) + "%", "height": "100%", "background": "#10b981", "transition": "width 0.6s ease"})}>
                            </div>
                            <div style={({"width": String(enrolled_pct) + "%", "height": "100%", "background": "#8b5cf6", "transition": "width 0.6s ease"})}>
                            </div>
                            <div style={({"width": String(undecided_pct) + "%", "height": "100%", "background": "var(--warning, #f59e0b)", "transition": "width 0.6s ease"})}>
                            </div>
                        </div>
                        <div style={({"display": "flex", "justifyContent": "space-between"})}>
                            <span className="text-muted" style={({"fontSize": "0.8rem"})}>
                                {String(committed_count) + " committed"}
                            </span>
                            <span className="text-muted" style={({"fontSize": "0.8rem"})}>
                                {String(enrolled_count) + " enrolled"}
                            </span>
                            <span className="text-muted" style={({"fontSize": "0.8rem"})}>
                                {String(undecided_count) + " deciding"}
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
