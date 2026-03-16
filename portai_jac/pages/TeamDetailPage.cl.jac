"""Team Detail Page - Full breakdown of a team's transfer portal activity."""

import from ..components.TransactionCard { TransactionCard }
import from ..data.mock_data { mock_teams }

def:pub TeamDetailPage(
    teamId: str,
    teamCounts: any,
    onNavigate: any,
    favoriteTeamIds: list,
    onToggleFavorite: any,
    expandedAIImpacts: list,
    onToggleAIImpact: any,
    aiImpactTexts: any,
    aiImpactLoading: list,
    teamTransfers: list,
    teamTransfersLoading: bool,
    teamTransfersIncoming: list,
    teamTransfersOutgoing: list,
    teamAnalysis: str,
    teamAnalysisLoading: bool,
    onRegenerateAnalysis: any
) -> any {

    matched = mock_teams.filter(lambda t: dict -> bool { return t["id"] == teamId; });
    team = (matched[0] if matched.length > 0 else None);

    if not team {
        return
            <div className="placeholder-page">
                <h1>Team Not Found</h1>
                <button className="btn btn-primary" onClick={lambda -> None { onNavigate("teams"); }}>
                    Back to Teams
                </button>
            </div>;
    }

    team_name = team["name"];
    counts = (teamCounts[team_name] if teamCounts and teamCounts[team_name] else {"incoming": 0, "outgoing": 0});
    
    net = counts["incoming"] - counts["outgoing"];
    is_favorite = favoriteTeamIds.includes(teamId);

    has tab: str = "incoming";

    return
        <div className="space-y-6">
            <button
                className="btn btn-ghost"
                onClick={lambda -> None { onNavigate("teams"); }}
                style={({"display": "flex", "alignItems": "center", "gap": "0.5rem"})}>
                ← Back to Teams
            </button>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start"})}>
                    <div>
                        <h1 className="mb-1">{team_name}</h1>
                        <p className="text-muted">{team["conference"]}</p>
                    </div>
                    <button
                        className={"btn " + ("btn-accent" if is_favorite else "btn-outline")}
                        onClick={lambda -> None { onToggleFavorite(teamId); }}>
                        {("★ Favorited" if is_favorite else "☆ Add to Favorites")}
                    </button>
                </div>

                <div style={({"display": "flex", "gap": "1.5rem", "marginTop": "1.5rem"})}>
                    <div className="card-static" style={({"flex": "1", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--accent)"})}>
                            {String(counts["incoming"])}
                        </div>
                        <div className="text-muted">Incoming</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "2rem", "fontWeight": "700", "color": "var(--destructive)"})}>
                            {String(counts["outgoing"])}
                        </div>
                        <div className="text-muted">Outgoing</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "2rem", "fontWeight": "700", "color": ("var(--accent)" if net >= 0 else "var(--destructive)")})}>
                            {(("+" if net > 0 else "") + String(net))}
                        </div>
                        <div className="text-muted">Net Change</div>
                    </div>
                    <div className="card-static" style={({"flex": "1", "textAlign": "center", "padding": "1rem"})}>
                        <div style={({"fontSize": "2rem", "fontWeight": "700"})}>
                            {String(counts["incoming"] + counts["outgoing"])}
                        </div>
                        <div className="text-muted">Total Activity</div>
                    </div>
                </div>
            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div style={({"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "1rem"})}>
                    <h2>AI Portal Analysis</h2>
                    <button
                        className="btn btn-outline btn-sm rounded-lg"
                        onClick={onRegenerateAnalysis}
                        disabled={teamAnalysisLoading}>
                        {("Generating..." if teamAnalysisLoading else "🔄 Regenerate")}
                    </button>
                </div>
                {(
                    <p className="text-muted" style={({"fontStyle": "italic"})}>Generating AI analysis...</p>
                ) if teamAnalysisLoading else (
                    <p>{(teamAnalysis if teamAnalysis else "Click Regenerate to generate an AI analysis of this team's portal activity.")}</p>
                )}
            </div>

            <div className="card" style={({"padding": "1.5rem"})}>
                <div className="status-pills" style={({"marginBottom": "1.5rem"})}>
                    <button
                        className={"status-pill" + (" active" if tab == "incoming" else "")}
                        onClick={lambda -> None { tab = "incoming"; }}>
                        {"Incoming (" + String(counts["incoming"]) + ")"}
                    </button>
                    <button
                        className={"status-pill" + (" active" if tab == "outgoing" else "")}
                        onClick={lambda -> None { tab = "outgoing"; }}>
                        {"Outgoing (" + String(counts["outgoing"]) + ")"}
                    </button>
                </div>

                {(
                    <div className="loading-overlay">
                        <div className="spinner"></div>
                        <p className="text-muted">Loading transfers...</p>
                    </div>
                ) if teamTransfersLoading else (
                    <div className="space-y-4">
                        {(
                            <div>
                                {(
                                    <p className="text-muted" style={({"textAlign": "center", "padding": "2rem"})}>
                                        No incoming transfers found.
                                    </p>
                                ) if teamTransfersIncoming.length == 0 else (
                                    <div className="space-y-4">
                                        {teamTransfersIncoming.map(lambda t: dict -> any {
                                            tId = t["id"];
                                            return <TransactionCard
                                                key={t["id"]}
                                                transaction={t}
                                                showAIImpact={expandedAIImpacts.includes(t["id"])}
                                                onToggleAIImpact={onToggleAIImpact}
                                                onNavigate={onNavigate}
                                                aiImpactText={(aiImpactTexts[tId] if aiImpactTexts[tId] else "")}
                                                aiImpactLoading={aiImpactLoading.includes(t["id"])}
                                            />;
                                        })}
                                    </div>
                                )}
                            </div>
                        ) if tab == "incoming" else (
                            <div>
                                {(
                                    <p className="text-muted" style={({"textAlign": "center", "padding": "2rem"})}>
                                        No outgoing transfers found.
                                    </p>
                                ) if teamTransfersOutgoing.length == 0 else (
                                    <div className="space-y-4">
                                        {teamTransfersOutgoing.map(lambda t: dict -> any {
                                            tId = t["id"];
                                            return <TransactionCard
                                                key={t["id"]}
                                                transaction={t}
                                                showAIImpact={expandedAIImpacts.includes(t["id"])}
                                                onToggleAIImpact={onToggleAIImpact}
                                                onNavigate={onNavigate}
                                                aiImpactText={(aiImpactTexts[tId] if aiImpactTexts[tId] else "")}
                                                aiImpactLoading={aiImpactLoading.includes(t["id"])}
                                            />;
                                        })}
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>;
}
