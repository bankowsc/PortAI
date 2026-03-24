"""Player Detail Page - Full breakdown of a transfer portal player."""

import from ..data.mock_data { mock_teams }

def:pub PlayerDetailPage(
    playerId: str,
    onNavigate: any,
    aiImpactTexts: any,
    aiImpactLoading: list,
    expandedAIImpacts: list,
    onToggleAIImpact: any,
    crystalBallTexts: any,
    crystalBallLoading: list,
    expandedCrystalBalls: list,
    onToggleCrystalBall: any,
    playerData: any,
    playerLoading: bool
) -> any {

    if playerLoading {
        return
            <div className="loading-overlay">
                <div className="spinner"></div>
                <p className="text-muted">Loading player...</p>
            </div>;
    }

    if not playerData or playerData["error"] {
        return
            <div className="placeholder-page">
                <h1>Player Not Found</h1>
                <button className="btn btn-primary" onClick={lambda -> None { onNavigate("players"); }}>
                    Back to Players
                </button>
            </div>;
    }

    pid = playerData["id"];
    stars = playerData["starRating"];
    star_str = "★" * stars + "☆" * (5 - stars);
    rating_str = (String(playerData["rating"]) if playerData["rating"] else "N/A");
    impact_text = (aiImpactTexts[pid] if aiImpactTexts[pid] else "");
    impact_loading = aiImpactLoading.includes(pid);
    crystal_text = (crystalBallTexts[pid] if crystalBallTexts[pid] else "");
    crystal_loading = crystalBallLoading.includes(pid);
    show_impact = expandedAIImpacts.includes(pid);
    show_crystal = expandedCrystalBalls.includes(pid);

    status_color_map: any = {
        "Committed": "var(--accent)",
        "Enrolled": "#8b5cf6",
        "In Portal": "var(--warning, #f59e0b)",
        "Entered": "var(--warning, #f59e0b)",
        "Withdrawn": "var(--destructive)"
    };
    status_color = (status_color_map[playerData["status"]] if status_color_map[playerData["status"]] else "var(--text-muted)");

    from_team_match = mock_teams.filter(lambda t: dict -> bool {
        return t["name"].toLowerCase().includes(playerData["fromTeam"].toLowerCase()) or
               playerData["fromTeam"].toLowerCase().includes(t["name"].split(" ")[0].toLowerCase());
    });
    to_team_id = "";
    to_team_match = mock_teams.filter(lambda t: dict -> bool {
        return t["name"].toLowerCase().includes(playerData["toTeam"].toLowerCase()) or
               playerData["toTeam"].toLowerCase().includes(t["name"].split(" ")[0].toLowerCase());
    });
    if to_team_match.length > 0 {
        to_team_id = to_team_match[0]["id"];
    }

    return
        <div className="space-y-6">
            <button
                className="btn btn-ghost"
                onClick={lambda -> None { onNavigate("players"); }}
                style={({"display": "flex", "alignItems": "center", "gap": "0.5rem"})}>
                ← Back to Players
            </button>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start", "flexWrap": "wrap", "gap": "1rem"})}>
                    <div style={({"display": "flex", "alignItems": "center", "gap": "1rem"})}>
                        <div style={({"fontSize": "3rem"})}>👤</div>
                        <div>
                            <h1 className="mb-1">{playerData["name"]}</h1>
                            <div style={({"display": "flex", "alignItems": "center", "gap": "0.75rem", "flexWrap": "wrap"})}>
                                <span className="badge badge-position">{playerData["position"]}</span>
            
                                <span className="text-muted">{"Rating: " + rating_str}</span>
                                <span style={({"color": status_color, "fontWeight": "600"})}>
                                    {playerData["status"]}
                                </span>
                            </div>
                        </div>
                    </div>
                    {(
                        <a
                            href={playerData["profileUrl"]}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="btn btn-outline btn-sm">
                            View on 247Sports ↗
                        </a>
                    ) if playerData["profileUrl"] else <div />}
                </div>

                <div style={({"display": "flex", "gap": "1.5rem", "marginTop": "1.5rem", "flexWrap": "wrap"})}>
                    <div className="card-static" style={({"flex": "1", "minWidth": "120px", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "1.5rem", "fontWeight": "700"})}>
                            {playerData["height"]}
                        </div>
                        <div className="text-muted">Height</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "minWidth": "120px", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "1.5rem", "fontWeight": "700"})}>
                            {playerData["weight"]}
                        </div>
                        <div className="text-muted">Weight</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "minWidth": "120px", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "1.5rem", "fontWeight": "700", "color": "var(--warning, #f59e0b)"})}>
                            {String(stars) + "★"}
                        </div>
                        <div className="text-muted">Star Rating</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "minWidth": "120px", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "1.5rem", "fontWeight": "700"})}>
                            {rating_str}
                        </div>
                        <div className="text-muted">Rating</div>
                    </div>
                </div>
            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                <h2 className="mb-4">Transfer Route</h2>
                <div style={({"display": "flex", "alignItems": "center", "gap": "1rem", "flexWrap": "wrap"})}>
                    <div
                        className="card-static"
                        style={({"flex": "1", "minWidth": "140px", "padding": "1rem", "textAlign": "center", "cursor": "pointer"})}
                        onClick={lambda -> None {
                            if from_team_match.length > 0 {
                                onNavigate("team-detail:" + from_team_match[0]["id"]);
                            }
                        }}>
                        <div style={({"fontSize": "1.5rem"})}>🏈</div>
                        <div style={({"fontWeight": "600", "marginTop": "0.5rem"})}>
                            {playerData["fromTeam"]}
                        </div>
                        <div className="text-muted" style={({"fontSize": "0.8rem"})}>From</div>
                    </div>

                    <div style={({"fontSize": "1.5rem", "color": "var(--text-muted)"})}>→</div>

                    <div style={({"flex": "1", "minWidth": "140px", "padding": "1rem", "textAlign": "center",
                        "borderRadius": "0.5rem",
                        "background": ("var(--accent-muted, rgba(16,185,129,0.1))" if playerData["toTeam"] != "Undecided" else "var(--surface-2, var(--bg-card))")
                    })}>
                        <div style={({"fontSize": "1.5rem"})}>
                            {("🏈" if playerData["toTeam"] != "Undecided" else "❓")}
                        </div>
                        <div
                            style={({"fontWeight": "600", "marginTop": "0.5rem",
                                "cursor": ("pointer" if to_team_id else "default"),
                                "color": ("var(--accent)" if playerData["toTeam"] != "Undecided" else "var(--text-muted)")
                            })}
                            onClick={lambda -> None {
                                if to_team_id {
                                    onNavigate("team-detail:" + to_team_id);
                                }
                            }}>
                            {playerData["toTeam"]}
                        </div>
                        <div className="text-muted" style={({"fontSize": "0.8rem"})}>To</div>
                    </div>
                </div>
            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "0.75rem"})}>
                    <h2>AI Transfer Impact</h2>
                    <button
                        className="btn btn-outline btn-sm rounded-lg"
                        onClick={lambda -> None { onToggleAIImpact(pid); }}>
                        {(
                            "Hide" if show_impact else
                            ("Generating..." if impact_loading else "⚡ Generate Impact")
                        )}
                    </button>
                </div>
                {(
                    <div>
                        {(
                            <div className="loading-overlay" style={({"padding": "1rem"})}>
                                <div className="spinner"></div>
                            </div>
                        ) if impact_loading else (
                            <p style={({"lineHeight": "1.6"})}>
                                {(impact_text if impact_text else "Click Generate Impact to get an AI assessment.")}
                            </p>
                        )}
                    </div>
                ) if show_impact else <div />}
            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                {(<div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "0.75rem"})}>
                    <h2>🔮 Crystal Ball Prediction</h2>
                    <button
                        className="btn btn-outline btn-sm rounded-lg"
                        onClick={lambda -> None { onToggleCrystalBall(pid); }}
                        disabled={crystal_loading}>
                        {(
                            "Hide" if show_crystal else
                            ("Predicting..." if crystal_loading else "🔮 Predict Destination")
                        )}
                    </button>
                </div>) if playerData["toTeam"] != "Undecided" else <div />}
                {(
                    <div>
                        {(
                            <div className="loading-overlay" style={({"padding": "1rem"})}>
                                <div className="spinner"></div>
                            </div>
                        ) if crystal_loading else (
                            <p style={({"lineHeight": "1.6"})}>
                                {(crystal_text if crystal_text else "Click Predict Destination to get an AI prediction.")}
                            </p>
                        )}
                    </div>
                ) if show_crystal else <div />}
            </div>
        </div>;
}
