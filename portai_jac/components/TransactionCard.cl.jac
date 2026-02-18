"""Transaction Card component - displays a transfer transaction."""

def:pub TransactionCard(
    transaction: dict,
    showAIImpact: bool,
    onToggleAIImpact: any,
    onNavigate: any
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

                    <div className="transaction-card-stats">
                        {[
                            <span key={entry[0]}>
                                <span className="transaction-card-stat-label">{entry[0]}: </span>
                                <span>{entry[1]}</span>
                            </span>
                            for entry in Object.entries(transaction["stats"])
                        ]}
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
                                <p>
                                    This transfer significantly strengthens {transaction["toTeam"]}'s
                                    {" " + transaction["position"]} position. Expected to contribute
                                    immediately based on previous performance metrics.
                                </p>
                            </div>
                        </div>
                    ) if showAIImpact else None}
                </div>
            </div>
        </div>;
}
