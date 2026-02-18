"""Player Card component - displays a player summary card."""

def:pub PlayerCard(
    player: dict,
    onNavigate: any
) -> any {
    return
        <div className="card player-card">
            <div className="player-card-top">
                <span className="player-card-photo">{player["photo"]}</span>
                <div className="flex-1">
                    <div className="player-card-name">{player["name"]}</div>
                    <div className="player-card-meta">
                        <span className="badge badge-outline">{player["position"]}</span>
                        <span>•</span>
                        <span>{player["class"]}</span>
                    </div>
                    <div className="player-card-stars">
                        {[
                            <span key={i} className="star">⭐</span>
                            for i in Array.from({"length": player["starRating"]}, lambda _: any, idx: int -> int { return idx; })
                        ]}
                    </div>
                </div>
            </div>

            <div className="player-card-details">
                <div className="player-card-detail-row">
                    <span className="player-card-detail-label">Current Team</span>
                    <span>{player["currentTeam"]}</span>
                </div>
                <div className="player-card-detail-row">
                    <span className="player-card-detail-label">Previous Team</span>
                    <span>{player["previousTeam"]}</span>
                </div>
                {(
                    <div className="player-card-detail-row">
                        <span className="player-card-detail-label">NIL Value</span>
                        <span className="player-card-detail-value accent">{player["nilValue"]}</span>
                    </div>
                ) if player["nilValue"] else None}
            </div>

            <button className="btn btn-outline-accent btn-full rounded-lg"
                    onClick={lambda -> None { onNavigate("player-detail:" + player["id"]); }}>
                View Profile
            </button>
        </div>;
}
