"""Team Card component - displays a team summary card."""

def:pub TeamCard(
    team: dict,
    isFavorite: bool,
    isRival: bool,
    onToggleFavorite: any,
    onToggleRival: any,
    onNavigate: any
) -> any {
    return
        <div className="card team-card">
            <div className="team-card-header">
                <div className="team-card-info">
                    <span className="team-card-logo">{team["logo"]}</span>
                    <div>
                        <div className="team-card-name">{team["name"]}</div>
                        <div className="team-card-conference">{team["conference"]}</div>
                    </div>
                </div>
                <button className={"team-card-fav-btn" + (" active" if isFavorite else "")}
                        onClick={lambda -> None { onToggleFavorite(team["id"]); }}>
                    {("★" if isFavorite else "☆")}
                </button>
                <button className={"team-card-riv-btn" + (" active" if isRival else "")}
                        onClick={lambda -> None { onToggleRival(team["id"]); }}>
                    {("★" if isRival else "☆")}
                </button>
            </div>

            <div className="team-card-stats">
                <div className="team-card-activity-row">
                    <span className="team-card-activity-label">Portal Activity</span>
                    <span className={"badge " + ("badge-accent-solid" if team["portalActivityScore"] >= 85 else "badge-secondary")}>
                        {team["portalActivityScore"]}
                    </span>
                </div>

                <div className="team-card-transfer-counts">
                    <div className="team-card-count-box">
                        <div className="team-card-count-value incoming">{team["incomingCount"]}</div>
                        <div className="team-card-count-label">Incoming</div>
                    </div>
                    <div className="team-card-count-box">
                        <div className="team-card-count-value outgoing">{team["outgoingCount"]}</div>
                        <div className="team-card-count-label">Outgoing</div>
                    </div>
                </div>

                <button className="btn btn-primary btn-full rounded-lg"
                        onClick={lambda -> None { onNavigate("team-detail:" + team["id"]); }}>
                    View Team
                </button>
            </div>
        </div>;
}
