"""PortAI - Portal Player Guesser Game Page."""

def:pub GamePage(
    onNavigate: any,
) -> any {

    clue_order: list = [
        {"key": "fromTeam",   "label": "From Team"},
        {"key": "toTeam",     "label": "To Team"},
        {"key": "position",   "label": "Position"},
        {"key": "starRating", "label": "Star Rating"},
        {"key": "height",     "label": "Height"},
        {"key": "weight",     "label": "Weight"},
        {"key": "playerPhoto","label": "Player Photo"},
        {"key": "playerName", "label": "Initals"},
        
    ];
    max_guesses: int = 6;

    mock_players: list = [
        {
        "id": "1",
        "playerId": "1",
        "playerName": "Jordan Shuler",
        "playerPhoto": "👤",
        "position": "LB",
        "fromTeam": "Air Force",
        "fromTeamLogo": "🔵",
        "toTeam": null,
        "toTeamLogo": "⬜",
        "starRating": 2,
        "rating": 0.79,
        "height": "6'2\"",
        "weight": 220,
        "status": null,
        "stats": {},
        "date": "2026-01-15",
        "sport": "Football",
        "profileUrl": "https://247sports.com/player/jordan-shuler-46116426/college-348647/"
    },
    {
        "id": "2",
        "playerId": "2",
        "playerName": "Trae Williams",
        "playerPhoto": "👤",
        "position": "CB",
        "fromTeam": "Air Force",
        "fromTeamLogo": "🔵",
        "toTeam": "Furman",
        "toTeamLogo": "🟣",
        "starRating": 0,
        "rating": null,
        "height": "5'10\"",
        "weight": 170,
        "status": "Committed",
        "stats": {},
        "date": "2026-01-15",
        "sport": "Football",
        "profileUrl": "https://247sports.com/player/trae-williams-46137057/college-350888/"
    },
    {
        "id": "3",
        "playerId": "3",
        "playerName": "Jeremiah Shelby",
        "playerPhoto": "👤",
        "position": "Edge",
        "fromTeam": "Air Force",
        "fromTeamLogo": "🔵",
        "toTeam": null,
        "toTeamLogo": "⬜",
        "starRating": 0,
        "rating": null,
        "height": "6'3\"",
        "weight": 250,
        "status": null,
        "stats": {},
        "date": "2026-01-15",
        "sport": "Football",
        "profileUrl": "https://247sports.com/player/jeremiah-shelby-46141024/college-348556/"
    },
    {
        "id": "4",
        "playerId": "4",
        "playerName": "Dominic Diaz",
        "playerPhoto": "👤",
        "position": "LS",
        "fromTeam": "Air Force",
        "fromTeamLogo": "🔵",
        "toTeam": null,
        "toTeamLogo": "⬜",
        "starRating": 0,
        "rating": null,
        "height": "6'0\"",
        "weight": 225,
        "status": null,
        "stats": {},
        "date": "2026-01-15",
        "sport": "Football",
        "profileUrl": "https://247sports.com/player/dominic-diaz-46134292/college-348557/"
    },
    ];

    rand_idx: int = Math.floor(Math.random() * mock_players.length);

    has guessCount: int = 0,
        gameOver: bool = False,
        gameResult: str = "",
        wrongGuesses: list = [],
        inputValue: str = "",
        showSuggestions: bool = False,
        targetPlayer: any = mock_players[rand_idx];

    revealedClueCount: int = (1 + wrongGuesses.length if not gameOver else clue_order.length);

    filteredSuggestions: list = [
        p for p in mock_players
        if inputValue.trim().length > 0
        and p["playerName"].toLowerCase().includes(inputValue.toLowerCase())
    ];

    def attemptsLabel -> str {
        remaining = max_guesses - guessCount;
        if remaining == 1 { return "1 guess remaining"; }
        return String(remaining) + " guesses remaining";
    }

    def roundLabel -> str {
        if guessCount == 0 { return "Round 1"; }
        return "Guess " + String(guessCount + 1);
    }

    def handleInputChange(e: any) -> None {
        inputValue = e.target.value;
        showSuggestions = inputValue.trim().length > 0;
    }

    def handleSelectSuggestion(name: str) -> None {
        inputValue = name;
        showSuggestions = False;
    }

    def handleKeyDown(e: any) -> None {
        if e.key == "Enter" { handleSubmitGuess(); }
        if e.key == "Escape" { showSuggestions = False; }
    }

    def handleSubmitGuess -> None {
        if gameOver or not inputValue.trim() { return; }

        matched = mock_players.filter(
            lambda p: any -> bool { return p["playerName"].toLowerCase() == inputValue.trim().toLowerCase(); }
        );

        if matched.length == 0 {
            inputValue = "";
            return;
        }

        guess = matched[0];
        guessCount = guessCount + 1;
        inputValue = "";
        showSuggestions = False;

        if guess["id"] == targetPlayer["id"] {
            gameOver = True;
            gameResult = "win";
        } else {
            wrongGuesses = wrongGuesses.concat([guess["playerName"]]);
            if guessCount >= max_guesses {
                gameOver = True;
                gameResult = "loss";
            }
        }
    }

    def handleNewGame -> None {
        new_idx = Math.floor(Math.random() * mock_players.length);
        targetPlayer = mock_players[new_idx];
        guessCount = 0;
        gameOver = False;
        gameResult = "";
        wrongGuesses = [];
        inputValue = "";
        showSuggestions = False;
    }

    return
        <div className="game-page">

            <div className="game-header">
                <div>
                    <h1 className="game-title">Portal Player Guesser</h1>
                    <p className="game-subtitle">
                        {"Identify the transfer portal player — a new clue unlocks after each wrong guess."}
                    </p>
                </div>
                <span className="game-status-badge">{roundLabel()}</span>
            </div>

            <div className="game-attempts-row">
                {[
                    <div
                        key={String(i)}
                        className={("attempt-dot used" if i < guessCount else "attempt-dot remaining")}
                    ></div>
                    for i in [0, 1, 2, 3, 4, 5]
                ]}
                <span className="attempts-label">{attemptsLabel()}</span>
            </div>

            {(
                <div className="game-result-banner win">
                    <div className="game-result-title">
                        {"Correct in " + String(guessCount) + (" guess!" if guessCount == 1 else " guesses!")}
                    </div>
                    <div className="game-result-sub">
                        {targetPlayer["playerName"] + " · " + targetPlayer["position"] + " · " + targetPlayer["fromTeam"] + " → " + targetPlayer["toTeam"]}
                    </div>
                    <button className="game-new-btn" onClick={lambda _: any -> None { handleNewGame(); }}>
                        Play Again
                    </button>
                </div>
            if gameResult == "win" else <span></span>)}

            {(
                <div className="game-result-banner loss">
                    <div className="game-result-title">
                        {"The answer was " + targetPlayer["playerName"]}
                    </div>
                    <div className="game-result-sub">
                        {targetPlayer["position"] + " · " + targetPlayer["fromTeam"] + " → " + targetPlayer["toTeam"]}
                    </div>
                    <button className="game-new-btn" onClick={lambda _: any -> None { handleNewGame(); }}>
                        Try Another
                    </button>
                </div>
            if gameResult == "loss" else <span></span>)}

            <div className="game-clue-grid">
                {clue_order.map(lambda clue: any, idx: int -> any {
                    is_revealed = idx < revealedClueCount;
                    card_class = ("game-clue-card revealed" if is_revealed else "game-clue-card hidden");
                    raw_val = targetPlayer[clue["key"]];
                    clue_val = (
                        "★".repeat(raw_val) 
                        # + "☆".repeat(5 - raw_val)
                        if clue["key"] == "starRating"
                        else String(raw_val)
                    );
                    locked_text = ("First clue" if idx == 0 else "Unlocks after guess " + String(idx));
                    return
                        <div key={clue["key"]} className={card_class}>
                            <span className="clue-label">{clue["label"]}</span>
                            {(
                                <span className={("clue-value stars" if clue["key"] == "starRating" else "clue-value")}>
                                    {clue_val}
                                </span>
                            if is_revealed else
                                <span className="clue-locked">{locked_text}</span>
                            )}
                        </div>;
                })}
            </div>

            {(
                <div className="game-guess-section">
                    <div className="guess-section-label">Enter a player name:</div>
                    <div className="guess-input-wrap">
                        <input
                            className="guess-input"
                            type="text"
                            placeholder="Type a player name..."
                            value={inputValue}
                            onChange={handleInputChange}
                            onKeyDown={handleKeyDown}
                            autoComplete="off"
                        />
                        <button
                            className="guess-submit-btn"
                            onClick={lambda _: any -> None { handleSubmitGuess(); }}
                            disabled={not inputValue.trim()}
                        >
                            Guess
                        </button>

                        {(
                            <div className="game-suggestions">
                                {[
                                    <div
                                        key={p["id"]}
                                        className="game-suggestion-item"
                                        onClick={lambda _: any -> None { handleSelectSuggestion(p["playerName"]); }}
                                    >
                                        <span>{p["playerName"]}</span>
                                        <span className="suggestion-pos-badge">{p["position"]}</span>
                                    </div>
                                    for p in filteredSuggestions
                                ]}
                            </div>
                        if showSuggestions and filteredSuggestions.length > 0 else
                            <span></span>
                        )}
                    </div>

                    {(
                        <div className="game-guess-history">
                            {[
                                <div key={g} className="game-guess-chip">
                                    <span className="guess-chip-x">✗</span>
                                    <span>{g}</span>
                                </div>
                                for g in wrongGuesses
                            ]}
                        </div>
                    if wrongGuesses.length > 0 else <span></span>)}
                </div>
            if not gameOver else <span></span>)}

        </div>;
}
