"""Transaction Card component - displays a transfer transaction."""

def:pub TransactionCard(
    transaction: dict,
    showAIImpact: bool,
    onToggleAIImpact: any,
    onNavigate: any,
    aiImpactText: str,
    aiImpactLoading: bool
) -> any {
    return
        <div className="card transaction-card">
            <div className="transaction-card-content">
                <span className="transaction-card-photo">{transaction["playerPhoto"]}</span>
                <div className="transaction-card-body">
                    <div className="transaction-card-header">
                        <div>
                            <h3 className="mb-1">{transaction["playerName"]}</h3>
                            <span className="badge badge-outline">{transaction["position"]}</span>
                            {(
                                <span className="badge badge-secondary" style={({"marginLeft": "0.5rem"})}>
                                    {transaction["status"]}
                                </span>
                            ) if transaction["status"] else None}
                        </div>
                        <div className="player-card-stars">
                            {[
                                <span key={i} className="star">⭐</span>
                                for i in Array.from({"length": transaction["starRating"]}, lambda _: any, idx: int -> int { return idx; })
                            ]}
                        </div>
                    </div>

                    <div className="transaction-card-transfer">
                        <div className="transaction-card-team">
                            <span className="transaction-card-team-logo">{transaction["fromTeamLogo"]}</span>
                            <span className="transaction-card-team-name">{transaction["fromTeam"]}</span>
                        </div>
                        <span className="transaction-card-arrow">→</span>
                        <div className="transaction-card-team">
                            <span className="transaction-card-team-logo">{transaction["toTeamLogo"]}</span>
                            <span className="transaction-card-team-name to">{transaction["toTeam"]}</span>
                        </div>
                    </div>

                    <div className="transaction-card-meta" style={({"display": "flex", "gap": "1rem", "fontSize": "0.85rem", "color": "var(--color-muted)"})}>
                        {(
                            <span>{"Height: " + transaction["height"]}</span>
                        ) if transaction["height"] and transaction["height"] != "N/A" else None}
                        {(
                            <span>{"Weight: " + String(transaction["weight"]) + " lbs"}</span>
                        ) if transaction["weight"] and transaction["weight"] != 0 else None}
                        {(
                            <span>{"Rating: " + String(transaction["rating"])}</span>
                        ) if transaction["rating"] else None}
                    </div>

                    <div className="transaction-card-footer">
                        <span className="transaction-card-date">
                            {transaction["date"]}
                        </span>
                        <div className="transaction-card-actions">
                            <button className="btn btn-ghost btn-sm text-accent"
                                    onClick={lambda -> None { onToggleAIImpact(transaction["id"]); }}>
                                {("▲ Hide AI Impact" if showAIImpact else "▼ AI Impact")}
                            </button>
                            <button className="btn btn-outline btn-sm rounded-lg"
                                    onClick={lambda -> None { onNavigate("player-detail:" + transaction["playerId"]); }}>
                                View Details
                            </button>
                        </div>
                    </div>

                    {(
                        <div className="ai-impact-section">
                            <div className="ai-impact-content">
                                <span className="badge badge-accent-solid">AI Generated</span>
                                {(
                                    <p className="text-muted" style={({"fontStyle": "italic"})}>
                                        Generating AI impact assessment...
                                    </p>
                                ) if aiImpactLoading else (
                                    <p>
                                        {(aiImpactText if aiImpactText else "Click to generate AI impact assessment for this transfer.")}
                                    </p>
                                )}
                            </div>
                        </div>
                    ) if showAIImpact else None}
                </div>
            </div>
        </div>;
}
