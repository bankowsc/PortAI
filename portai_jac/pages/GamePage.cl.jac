"""PortAI - Portal Player Guesser Game Page."""

def:pub GamePage(
    onNavigate: any,
    onNewGame: any,
) -> any {

    clue_order: list = [
        {"key": "position",   "label": "Position"},
        {"key": "conference", "label": "From Conference"},
        {"key": "class",      "label": "Class Year"},
        {"key": "height",     "label": "Height"},
        {"key": "weight",     "label": "Weight"},
        {"key": "stars",      "label": "Star Rating"},
    ];
    max_guesses: int = 6;

    mock_players: list = [
        {"id": "p1", "name": "Dillon Gabriel",  "position": "QB", "height": "6'0\"", "weight": "190 lbs", "stars": 4, "fromTeam": "Oregon",         "toTeam": "Pittsburgh",  "class": "Sr", "conference": "Big 12"},
        {"id": "p2", "name": "Riley Leonard",   "position": "QB", "height": "6'2\"", "weight": "205 lbs", "stars": 4, "fromTeam": "Duke",           "toTeam": "Notre Dame",  "class": "Jr", "conference": "ACC"},
        {"id": "p3", "name": "Nico Iamaleava",  "position": "QB", "height": "6'5\"", "weight": "215 lbs", "stars": 5, "fromTeam": "Tennessee",      "toTeam": "UCLA",        "class": "So", "conference": "SEC"},
        {"id": "p4", "name": "Zayne Anderson",  "position": "CB", "height": "6'1\"", "weight": "183 lbs", "stars": 4, "fromTeam": "BYU",            "toTeam": "Texas A&M",   "class": "Jr", "conference": "Big 12"},
        {"id": "p5", "name": "Luther Burden",   "position": "WR", "height": "5'11\"","weight": "202 lbs", "stars": 5, "fromTeam": "Missouri",       "toTeam": "Oklahoma",    "class": "So", "conference": "SEC"},
        {"id": "p6", "name": "Ollie Gordon",    "position": "RB", "height": "6'1\"", "weight": "220 lbs", "stars": 4, "fromTeam": "Oklahoma State", "toTeam": "Miami",       "class": "Jr", "conference": "Big 12"},
        {"id": "p7", "name": "Malachi Moore",   "position": "S",  "height": "6'0\"", "weight": "196 lbs", "stars": 4, "fromTeam": "Alabama",        "toTeam": "LSU",         "class": "Sr", "conference": "SEC"},
        {"id": "p8", "name": "Tre Harris",      "position": "WR", "height": "6'3\"", "weight": "210 lbs", "stars": 4, "fromTeam": "Ole Miss",       "toTeam": "Oregon",      "class": "Jr", "conference": "SEC"},
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
        and p["name"].toLowerCase().includes(inputValue.toLowerCase())
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
            lambda p: any -> bool { return p["name"].toLowerCase() == inputValue.trim().toLowerCase(); }
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
            wrongGuesses = wrongGuesses.concat([guess["name"]]);
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
        onNewGame();
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
                    is_revealed = idx < revealedClueCount;
                    card_class = ("game-clue-card revealed" if is_revealed else "game-clue-card hidden");
                    raw_val = targetPlayer[clue["key"]];
                    clue_val = (
                        "★".repeat(raw_val) + "☆".repeat(5 - raw_val)
                        if clue["key"] == "stars"
                        else String(raw_val)
                    );
                    locked_text = ("First clue" if idx == 0 else "Unlocks after guess " + String(idx));
                    return
                        <div key={clue["key"]} className={card_class}>
                            <span className="clue-label">{clue["label"]}</span>
                            {(
                                <span className={("clue-value stars" if clue["key"] == "stars" else "clue-value")}>
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

# def:pub GamePage() -> any {
#     has worldWidth: int = 1000,
#         worldHeight: int = 500,
#         groundY: int = 420,
#         qbX: int = 115,
#         qbY: int = 392,
#         score: int = 0,
#         throws: int = 0,
#         tick: int = 0,
#         nextTargetId: int = 1,
#         isDragging: bool = False,
#         dragStart: any = {},
#         dragCurrent: any = {},
#         ball: any = {"x": 132, "y": 362, "vx": 0, "vy": 0, "active": False},
#         targets: list = [],
#         pageMissingFrames: int = 0;

#     def difficulty -> float {
#         return Math.min(4.0, 1.0 + (score / 42.0));
#     }

#     def ballStart -> any {
#         return {"x": qbX + 17, "y": qbY - 62};
#     }

#     def resetBall -> None {
#         start = ballStart();
#         ball = {"x": start["x"], "y": start["y"], "vx": 0, "vy": 0, "active": False};
#         window._portaiBallState = ball;
#         isDragging = False;
#         dragStart = {};
#         dragCurrent = {};
#     }

#     def randomBetween(minVal: float, maxVal: float) -> float {
#         return minVal + (Math.random() * (maxVal - minVal));
#     }

#     def randomTargetType -> str {
#         roll = Math.random();
#         if roll < 0.42 {
#             return "wheel";
#         }
#         if roll < 0.84 {
#             return "swing";
#         }
#         return "balloon";
#     }

#     def createTarget(kind: str, targetId: int) -> any {
#         scale = difficulty();
#         baseSize = (36 if kind == "wheel" else (31 if kind == "swing" else 28));
#         tSize = Math.max(13, Math.round(baseSize - (scale * 3.2)));
#         baseSpeed = (0.035 + randomBetween(0.0, 0.02)) * (0.66 + (scale * 0.08));
#         tX = randomBetween(620.0, 940.0);
#         tY = (groundY - randomBetween(48.0, 82.0));
#         tDy = 0.0;

#         if kind == "swing" {
#             tY = groundY - randomBetween(95.0, 135.0);
#         }
#         if kind == "balloon" {
#             tY = randomBetween(210.0, 360.0);
#             tDy = (0.1 + randomBetween(0.0, 0.07)) * (1 if Math.random() > 0.5 else -1);
#         }

#         horizDir = (1 if Math.random() > 0.5 else -1);
#         tDx = baseSpeed * horizDir;

#         return {
#             "id": "target_" + String(targetId),
#             "kind": kind,
#             "x": tX,
#             "y": tY,
#             "baseY": tY,
#             "baseX": tX,
#             "phase": randomBetween(0.0, 6.283),
#             "size": tSize,
#             "speed": baseSpeed,
#             "dx": tDx,
#             "dy": tDy,
#             "points": Math.max(8, Math.round((10 + scale * 3.5) + (35 - tSize))),
#             "anchorY": 58 + randomBetween(-12.0, 26.0)
#         };
#     }

#     def spawnTarget -> None {
#         tType = randomTargetType();
#         newTarget = createTarget(tType, nextTargetId);
#         targets = targets.concat([newTarget]);
#         nextTargetId = nextTargetId + 1;
#     }

#     def repopulateTargets -> None {
#         targetPool = targets.slice();
#         missing = 4 - targetPool.length;

#         if missing <= 0 {
#             return;
#         }

#         slots = [1, 2, 3, 4];
#         for slot in slots {
#             if slot <= missing {
#                 tType = randomTargetType();
#                 targetPool.push(createTarget(tType, nextTargetId));
#                 nextTargetId = nextTargetId + 1;
#             }
#         }

#         targets = targetPool;
#     }

#     def pointerFromEvent(e: any) -> any {
#         if e.touches and e.touches.length > 0 {
#             return {"x": e.touches[0].clientX, "y": e.touches[0].clientY};
#         }
#         if e.changedTouches and e.changedTouches.length > 0 {
#             return {"x": e.changedTouches[0].clientX, "y": e.changedTouches[0].clientY};
#         }
#         return {"x": e.clientX, "y": e.clientY};
#     }

#     def toWorldPoint(e: any) -> any {
#         world = document.getElementById("portai-game-world");
#         if not world {
#             start = ballStart();
#             return start;
#         }
#         rect = world.getBoundingClientRect();
#         pointer = pointerFromEvent(e);
#         xRaw = ((pointer["x"] - rect.left) / rect.width) * worldWidth;
#         yRaw = ((pointer["y"] - rect.top) / rect.height) * worldHeight;
#         clampedX = Math.max(0, Math.min(worldWidth, xRaw));
#         clampedY = Math.max(0, Math.min(worldHeight, yRaw));
#         return {"x": clampedX, "y": clampedY};
#     }

#     def updateTarget(t: any) -> any {
#         nx = t["x"];
#         ny = t["y"];
#         ndx = t["dx"];
#         ndy = t["dy"];
#         rightMinX = 560;
#         rightMaxX = 960;

#         if t["kind"] == "balloon" {
#             nx = t["baseX"] + (Math.sin((tick / 30.0) + t["phase"]) * 10.0);
#             ny = t["y"] + ndy;

#             if ny < 175 or ny > 380 {
#                 ndy = -ndy;
#                 ny = Math.max(175, Math.min(380, ny));
#             }
#         } else {
#             nx = t["x"] + ndx;
#             if nx < rightMinX or nx > rightMaxX {
#                 ndx = -ndx;
#                 nx = Math.max(rightMinX, Math.min(rightMaxX, nx));
#             }

#             ny = t["baseY"];
#             if t["kind"] == "swing" {
#                 ny = t["baseY"] + (Math.sin((tick / 36.0) + t["phase"]) * 9.0);
#             } else {
#                 ny = t["baseY"] + (Math.sin((tick / 52.0) + t["phase"]) * 2.2);
#             }
#         }

#         return Object.assign({}, t, {"x": nx, "y": ny, "dx": ndx, "dy": ndy});
#     }

#     def hitDistanceSq(x1: float, y1: float, x2: float, y2: float) -> float {
#         dx = x1 - x2;
#         dy = y1 - y2;
#         return (dx * dx) + (dy * dy);
#     }

#     def runTick -> None {
#         nowMs = Date.now();
#         if window._portaiLastTickMs and (nowMs - window._portaiLastTickMs) < 32 {
#             return;
#         }
#         window._portaiLastTickMs = nowMs;

#         world = document.getElementById("portai-game-world");
#         if not world {
#             pageMissingFrames = pageMissingFrames + 1;
#             # Auto-stop loop if user navigates away.
#             if pageMissingFrames > 40 and window._portaiGameLoopId {
#                 clearInterval(window._portaiGameLoopId);
#                 window._portaiGameLoopId = None;
#             }
#             return;
#         }
#         pageMissingFrames = 0;

#         if window._portaiBallState {
#             ball = window._portaiBallState;
#         } else {
#             window._portaiBallState = ball;
#         }

#         tick = tick + 1;
#         moved: list = [];
#         for t in targets {
#             moved.push(updateTarget(t));
#         }
#         targets = moved;

#         if ball["active"] {
#             gravity = 0.03;
#             nx = ball["x"] + ball["vx"];
#             ny = ball["y"] + ball["vy"];
#             nvx = ball["vx"] * 0.999;
#             nvy = ball["vy"] + gravity;

#             remainingTargets: list = [];
#             hitPoints = 0;
#             for t in targets {
#                 catchRadius = (t["size"] * 0.55) + 9;
#                 isHit = hitDistanceSq(nx, ny, t["x"], t["y"]) <= (catchRadius * catchRadius);
#                 if isHit {
#                     hitPoints = t["points"];
#                 } else {
#                     remainingTargets.push(t);
#                 }
#             }

#             if hitPoints > 0 {
#                 score = score + hitPoints;
#                 if remainingTargets.length < 4 {
#                     tType = randomTargetType();
#                     remainingTargets.push(createTarget(tType, nextTargetId));
#                     nextTargetId = nextTargetId + 1;
#                 }
#                 targets = remainingTargets;
#                 resetBall();
#             } else {
#                 if ny > (worldHeight + 220) or nx > (worldWidth + 320) or nx < -140 or ny < -240 {
#                     resetBall();
#                 } else {
#                     ball = {"x": nx, "y": ny, "vx": nvx, "vy": nvy, "active": True};
#                     window._portaiBallState = ball;
#                 }
#             }
#         }
#     }

#     def constrainAimPoint(point: any, start: any) -> any {
#         # Slingshot style: drag backward (left) from QB, throw launches forward (right).
#         minX = start["x"] - 220;
#         maxX = start["x"] - 12;
#         maxY = start["y"] + 170;
#         minY = start["y"] - 200;

#         cx = Math.max(minX, Math.min(maxX, point["x"]));
#         cy = Math.max(minY, Math.min(maxY, point["y"]));
#         return {"x": cx, "y": cy};
#     }

#     def handlePress(e: any) -> None {
#         e.preventDefault();
#         if ball["active"] {
#             resetBall();
#         }
#         start = ballStart();
#         pos = toWorldPoint(e);
#         if Math.abs(pos["x"] - start["x"]) > 130 or Math.abs(pos["y"] - start["y"]) > 130 {
#             return;
#         }
#         isDragging = True;
#         dragStart = start;
#         dragCurrent = pos;
#     }

#     def handleMove(e: any) -> None {
#         if not isDragging {
#             return;
#         }
#         e.preventDefault();
#         dragCurrent = constrainAimPoint(toWorldPoint(e), dragStart);
#     }

#     def handleRelease(e: any) -> None {
#         if not isDragging {
#             return;
#         }
#         e.preventDefault();
#         releasePoint = (
#             constrainAimPoint(dragCurrent, dragStart)
#             if dragCurrent and dragCurrent["x"] else
#             constrainAimPoint(toWorldPoint(e), dragStart)
#         );
#         dragCurrent = releasePoint;

#         # Launch vector is the inverse of pull vector.
#         dx = dragStart["x"] - releasePoint["x"];
#         dy = dragStart["y"] - releasePoint["y"];
#         power = Math.sqrt((dx * dx) + (dy * dy));

#         isDragging = False;

#         if power < 1 {
#             ball = {
#                 "x": dragStart["x"],
#                 "y": dragStart["y"],
#                 "vx": 2.2,
#                 "vy": -1.2,
#                 "active": True
#             };
#             window._portaiBallState = ball;
#             throws = throws + 1;
#             dragStart = {};
#             dragCurrent = {};
#             return;
#         }

#         maxPower = Math.min(300.0, power);
#         velocityScale = 0.014;
#         unitX = dx / power;
#         unitY = dy / power;

#         ball = {
#             "x": dragStart["x"],
#             "y": dragStart["y"],
#             "vx": unitX * maxPower * velocityScale,
#             "vy": unitY * maxPower * velocityScale,
#             "active": True
#         };
#         window._portaiBallState = ball;
#         throws = throws + 1;
#         dragStart = {};
#         dragCurrent = {};
#     }

#     def handleReset -> None {
#         score = 0;
#         throws = 0;
#         tick = 0;
#         targets = [];
#         nextTargetId = 1;
#         resetBall();
#         repopulateTargets();
#     }

#     can with entry {
#         resetBall();
#         repopulateTargets();
#         if window._portaiGameLoopId {
#             clearInterval(window._portaiGameLoopId);
#         }
#         window._portaiGameLoopId = setInterval(lambda -> None { runTick(); }, 16);
#     }

#     # Build trajectory points while aiming.
#     trajectory: list = [];
#     if isDragging and dragStart["x"] and dragCurrent["x"] {
#         # Preview uses launch direction (opposite drag direction).
#         dx = dragStart["x"] - dragCurrent["x"];
#         dy = dragStart["y"] - dragCurrent["y"];
#         pwr = Math.sqrt((dx * dx) + (dy * dy));
#         if pwr > 0 {
#             usePower = Math.min(300.0, pwr);
#             ux = dx / pwr;
#             uy = dy / pwr;
#             tvx = ux * usePower * 0.014;
#             tvy = uy * usePower * 0.014;
#             steps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42];
#             for s in steps {
#                 px = dragStart["x"] + (tvx * s);
#                 py = dragStart["y"] + (tvy * s) + (0.03 * (s * s) * 0.5);
#                 if px > (worldWidth + 20) or py > (worldHeight + 20) or py < -30 {
#                     break;
#                 }
#                 trajectory.push({"x": px, "y": py});
#             }
#         }
#     }

#     throwAngle = (Math.atan2(ball["vy"], ball["vx"]) * 57.2958 if ball["active"] else -18);

#     accuracy = (Math.round((score / throws) * 10) / 10 if throws > 0 else 0);

#     return
#         <div className="game-page">
#             <div className="game-header-row">
#                 <div>
#                     <h1>Game: Target Practice</h1>
#                     <p className="text-muted">Click and drag from the quarterback, then release to throw.</p>
#                 </div>
#                 <div className="game-ui-group">
#                     <div className="game-stat-card">
#                         <span className="game-stat-label">Score</span>
#                         <span className="game-stat-value">{String(score)}</span>
#                     </div>
#                     <div className="game-stat-card">
#                         <span className="game-stat-label">Throws</span>
#                         <span className="game-stat-value">{String(throws)}</span>
#                     </div>
#                     <div className="game-stat-card">
#                         <span className="game-stat-label">Avg Points</span>
#                         <span className="game-stat-value">{String(accuracy)}</span>
#                     </div>
#                     <button className="btn btn-outline game-reset-btn" onClick={handleReset}>Reset</button>
#                 </div>
#             </div>

#             <div className="game-stage-shell">
#                 <div
#                     id="portai-game-world"
#                     className="game-world"
#                     onMouseDown={handlePress}
#                     onMouseMove={handleMove}
#                     onMouseUp={handleRelease}
#                     onMouseLeave={handleRelease}
#                     onTouchStart={handlePress}
#                     onTouchMove={handleMove}
#                     onTouchEnd={handleRelease}
#                 >
#                     <div className="game-skyline"></div>
#                     <div className="game-field-lines"></div>
#                     <div className="game-endzone-label">END ZONE</div>
#                     <div className="game-goalpost">
#                         <div className="goalpost-bar"></div>
#                         <div className="goalpost-left"></div>
#                         <div className="goalpost-right"></div>
#                         <div className="goalpost-stem"></div>
#                     </div>

#                     {(
#                         <svg className="game-trajectory" viewBox={"0 0 " + String(worldWidth) + " " + String(worldHeight)}>
#                             <polyline
#                                 points={trajectory.map(lambda p: dict -> str {
#                                     return String(Math.round(p["x"])) + "," + String(Math.round(p["y"]));
#                                 }).join(" ")}
#                                 className="trajectory-line"
#                             />
#                         </svg>
#                     ) if trajectory.length > 1 else None}

#                     {targets.map(lambda t: dict -> any {
#                         targetStyle = ({
#                             "left": String(Math.round(t["x"] - (t["size"] / 2))) + "px",
#                             "top": String(Math.round(t["y"] - (t["size"] / 2))) + "px",
#                             "width": String(Math.round(t["size"])) + "px",
#                             "height": String(Math.round(t["size"])) + "px"
#                         });

#                         return <div key={t["id"]} className={"target target-" + t["kind"]} style={targetStyle}>
#                             {(
#                                 <div className="target-wheel-base">
#                                     <span className="target-wheel-dot"></span>
#                                 </div>
#                             ) if t["kind"] == "wheel" else None}
#                             {(
#                                 <div className="target-swing-rope" style={({"height": String(Math.max(16, Math.round(t["y"] - t["anchorY"]))) + "px"})}></div>
#                             ) if t["kind"] == "swing" else None}
#                             {(
#                                 <div className="target-balloon-string"></div>
#                             ) if t["kind"] == "balloon" else None}
#                         </div>;
#                     })}

#                     <div className={"qb-figure" + (" throwing" if ball["active"] else "")} style={({"left": String(qbX) + "px", "top": String(qbY - 74) + "px"})}>
#                         <span className="qb-head"></span>
#                         <span className="qb-torso"></span>
#                         <span className="qb-arm"></span>
#                         <span className="qb-leg left"></span>
#                         <span className="qb-leg right"></span>
#                     </div>

#                     <div className={"football" + (" flying" if ball["active"] else "")}
#                          style={({
#                              "left": String(Math.round(ball["x"] - 11)) + "px",
#                              "top": String(Math.round(ball["y"] - 6)) + "px",
#                              "transform": "rotate(" + String(Math.round(throwAngle)) + "deg)"
#                          })}>
#                     </div>
#                 </div>
#             </div>

#             <div className="game-footer-hint">
#                 <span>Difficulty scales as you score: targets get smaller and faster.</span>
#                 <span className="game-difficulty-pill">{"Level " + String(Math.round(difficulty() * 10) / 10)}</span>
#             </div>
#         </div>;
# }
