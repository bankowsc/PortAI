"""PortAI - Portal Player Guesser Game Page."""

def:pub GamePage(
    onNavigate: any,
    players: list,          # Full player list used for autocomplete
    targetPlayer: any,      # The randomly-selected player object for this round
    onNewGame: any,         # Callback: parent picks a new random player and resets state
) -> any {

    # Moved inside the function — module-level constants not supported
    clue_order: list = [
        {"key": "position",   "label": "Position"},
        {"key": "conference", "label": "From Conference"},
        {"key": "class",      "label": "Class Year"},
        {"key": "height",     "label": "Height"},
        {"key": "weight",     "label": "Weight"},
        {"key": "stars",      "label": "Star Rating"},
    ];
    max_guesses: int = 6;

    has guessCount: int = 0,
        gameOver: bool = False,
        gameResult: str = "",          # "win" | "loss" | ""
        wrongGuesses: list = [],
        inputValue: str = "",
        showSuggestions: bool = False;

    # Derived: how many clues are currently visible (1 is always shown; +1 per wrong guess)
    revealedClueCount: int = (1 + wrongGuesses.length if not gameOver else clue_order.length);


    filteredSuggestions: list = [
        p for p in players
        if inputValue.trim().length > 0
        and p["name"].toLowerCase().includes(inputValue.toLowerCase())
    ];

    # ---- Helpers ----

    def clueValue(clue: any) -> str {
        key = clue["key"];
        val = targetPlayer[key];
        if key == "stars" {
            return "★".repeat(val) + "☆".repeat(5 - val);
        }
        return String(val);
    }

    def attemptsLabel -> str {
        remaining = max_guesses - guessCount;
        if remaining == 1 { return "1 guess remaining"; }
        return String(remaining) + " guesses remaining";
    }

    def roundLabel -> str {
        if guessCount == 0 { return "Round 1"; }
        return "Guess " + String(guessCount + 1);
    }

    # ---- Event Handlers ----

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

        matched = players.filter(
            lambda p: any -> bool { return p["name"].toLowerCase() == inputValue.trim().toLowerCase(); }
        );

        # Reject unknown names with a soft error (don't count as a guess)
        if matched.length == 0 {
            inputValue = "";
            return;
        }

        guess = matched[0];
        guessCount = guessCount + 1;
        inputValue = "";
        showSuggestions = False;

        if guess["id"] == targetPlayer["id"] {
            # Correct!
            gameOver = True;
            gameResult = "win";
        } else {
            wrongGuesses = wrongGuesses.concat([guess["name"]]);
            if guessCount >= max_guesses {
                gameOver = True;
                gameResult = "loss";
            }
        }
    }

    def handleNewGame -> None {
        guessCount = 0;
        gameOver = False;
        gameResult = "";
        wrongGuesses = [];
        inputValue = "";
        showSuggestions = False;
        onNewGame();
    }

    # ---- Render ----

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
                        {targetPlayer["name"] + " · " + targetPlayer["position"] + " · " + targetPlayer["fromTeam"] + " → " + targetPlayer["toTeam"]}
                    </div>
                    <button className="game-new-btn" onClick={lambda _: any -> None { handleNewGame(); }}>
                        Play Again
                    </button>
                </div>
            if gameResult == "win" else <span></span>)}

            {(
                <div className="game-result-banner loss">
                    <div className="game-result-title">
                        {"The answer was " + targetPlayer["name"]}
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
                    return
                        <div
                            key={clue["key"]}
                            className={("game-clue-card revealed" if idx < revealedClueCount else "game-clue-card hidden")}
                        >
                            <span className="clue-label">{clue["label"]}</span>
                            {(
                                <span className={("clue-value stars" if clue["key"] == "stars" else "clue-value")}>
                                    {clueValue(clue)}
                                </span>
                            if idx < revealedClueCount else
                                <span className="clue-locked">
                                    {("First clue" if idx == 0 else "Unlocks after guess " + String(idx))}
                                </span>
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
                                        onClick={lambda _: any -> None { handleSelectSuggestion(p["name"]); }}
                                    >
                                        <span>{p["name"]}</span>
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
