"PortAI - Game Page: Minimalist football target practice mini-game."

def:pub GamePage() -> any {
    has worldWidth: int = 1000,
        worldHeight: int = 550,
        groundY: int = 440,
        qbX: int = 120,
        qbY: int = 408,
        score: int = 0,
        throws: int = 0,
        tick: int = 0,
        nextTargetId: int = 1,
        isDragging: bool = False,
        dragStart: any = {},
        dragCurrent: any = {},
        # ball: any = {"x": 137, "y": 348, "vx": 0, "vy": 0, "active": False},
        targets: list = [],
        hitFlash: bool = False,
        hitText: any = {},
        pageMissingFrames: int = 0,
        numMisses: int = 0,
        highScore: int = 0,
        gameOver: bool = False,
        balls: list = [],
        lastThrowMs: int = 0;

    def difficulty -> int {
        s = (window._portaiScore if window._portaiScore else 0);
        return Math.min(10, Math.floor(1 + 9 * Math.pow(s / 5000.0, 0.5)));
    }

    def ballStart -> any {
        return {"x": qbX + 17, "y": qbY - 60};
    }

    def resetBall -> None {
        newBall = {
            "x": ballStart()["x"],
            "y": ballStart()["y"],
            "vx": 0,
            "vy": 0,
            "active": False
        };
        # window._portaiBallState = newBall;
        # ball = newBall;
        window._portaiBalls = [];
        balls = [];

        isDragging = False;
        dragStart = {};
        dragCurrent = {};

    }

    def randomBetween(minVal: float, maxVal: float) -> float {
        return minVal + (Math.random() * (maxVal - minVal));
    }

    def randomTargetType -> str {
        roll = Math.random();
        if roll < 0.40 {
            return "wheel";
        }
        if roll < 0.80 {
            return "swing";
        }
        if roll < 0.95 {
            return "balloon";
        }
        return "plane";
    }

    def createTarget(kind: str, targetId: int) -> any {
        scale = difficulty();
        baseSize = (38 if kind == "wheel" else (33 if kind == "swing" else (30 if kind == "balloon" else 28)));
        tSize = Math.max(16, Math.round(baseSize - (scale * 2.5)));
        baseSpeed = 0.25 + randomBetween(0.0, 0.15) + (scale * 0.06);
        speedMultiplier = (2.0 if kind == "plane" else 1.0);
        tX = randomBetween(550.0, 920.0);
        tY = groundY - randomBetween(48.0, 82.0);
        tDy = 0.0;

        if kind == "swing" {
            tY = groundY - randomBetween(100.0, 155.0);
        }
        if kind == "balloon" {
            tY = randomBetween(160.0, 350.0);
            tDy = (0.12 + randomBetween(0.0, 0.08)) * (1 if Math.random() > 0.5 else -1);
        }
        if kind == "plane" {
            tY = randomBetween(100.0, 260.0);
        }

        horizDir = (1 if Math.random() > 0.5 else -1);
        tDx = baseSpeed * horizDir * speedMultiplier;

        return {
            "id": "target_" + String(targetId),
            "kind": kind,
            "x": tX,
            "y": tY,
            "baseY": tY,
            "baseX": tX,
            "phase": randomBetween(0.0, 6.283),
            "size": tSize,
            "speed": baseSpeed * speedMultiplier,
            "dx": tDx,
            "dy": tDy,
            "points": Math.max(8, Math.round((10 + scale * 3.5) + (38 - tSize) + (20 if kind == "plane" else 0))),
            "anchorY": 60.0 + randomBetween(-12.0, 26.0)
        };
    }

    def repopulateTargets -> None {
        targetPool = (window._portaiTargets if window._portaiTargets else []).slice();
        missing = 4 - targetPool.length;
        if missing <= 0 {
            return;
        }
        slots = [1, 2, 3, 4];
        for slot in slots {
            if slot <= missing {
                tType = randomTargetType();
                targetPool.push(createTarget(tType, nextTargetId));
                nextTargetId = nextTargetId + 1;
            }
        }
        targets = targetPool;
        window._portaiTargets = targetPool;
    }

    def pointerFromEvent(e: any) -> any {
        if e.touches and e.touches.length > 0 {
            return {"x": e.touches[0].clientX, "y": e.touches[0].clientY};
        }
        if e.changedTouches and e.changedTouches.length > 0 {
            return {"x": e.changedTouches[0].clientX, "y": e.changedTouches[0].clientY};
        }
        return {"x": e.clientX, "y": e.clientY};
    }

    def toWorldPoint(e: any) -> any {
        world = document.getElementById("portai-game-world");
        if not world {
            return ballStart();
        }
        rect = world.getBoundingClientRect();
        pointer = pointerFromEvent(e);
        xRaw = ((pointer["x"] - rect.left) / rect.width) * worldWidth;
        yRaw = ((pointer["y"] - rect.top) / rect.height) * worldHeight;
        clampedX = Math.max(0, Math.min(worldWidth, xRaw));
        clampedY = Math.max(0, Math.min(worldHeight, yRaw));
        return {"x": clampedX, "y": clampedY};
    }

    def updateTarget(t: any, currentTick: int) -> any {
        nx = t["x"];
        ny = t["y"];
        ndx = t["dx"];
        ndy = t["dy"];
        rightMinX = 480;
        rightMaxX = 960;

        if t["kind"] == "balloon" {
            nx = t["baseX"] + (Math.sin((currentTick / 30.0) + t["phase"]) * 14.0);
            ny = t["y"] + ndy;

            if ny < 130 or ny > 390 {
                ndy = -ndy;
                ny = Math.max(130, Math.min(390, ny));
            }
        } else {
            nx = t["x"] + ndx;
            if nx < rightMinX or nx > rightMaxX {
                ndx = -ndx;
                nx = Math.max(rightMinX, Math.min(rightMaxX, nx));
            }

            ny = t["baseY"];
            if t["kind"] == "swing" {
                ny = t["baseY"] + (Math.sin((currentTick / 36.0) + t["phase"]) * 10.0);
            } else {
                ny = t["baseY"] + (Math.sin((currentTick / 52.0) + t["phase"]) * 3.0);
            }
        }

        return Object.assign({}, t, {"x": nx, "y": ny, "dx": ndx, "dy": ndy});
    }

    def hitDistanceSq(x1: float, y1: float, x2: float, y2: float) -> float {
        dx = x1 - x2;
        dy = y1 - y2;
        return (dx * dx) + (dy * dy);
    }

    def runTick -> None {
        nowMs = Date.now();
        if window._portaiLastTickMs and (nowMs - window._portaiLastTickMs) < 15 {
            return;
        }
        window._portaiLastTickMs = nowMs;

        world = document.getElementById("portai-game-world");
        if not world {
            pageMissingFrames = pageMissingFrames + 1;
            if pageMissingFrames > 40 and window._portaiGameLoopId {
                clearInterval(window._portaiGameLoopId);
                window._portaiGameLoopId = None;
            }
            return;
        }
        pageMissingFrames = 0;

        # Read mutable state from window globals to avoid stale closures.
        cBalls = (window._portaiBalls if window._portaiBalls else []);
        cTargets = (window._portaiTargets if window._portaiTargets else []);
        cTick = ((window._portaiTick if window._portaiTick else 0) + 1);
        cScore = (window._portaiScore if window._portaiScore else 0);
        cNextId = (window._portaiNextTargetId if window._portaiNextTargetId else 1);
        cNumMisses = (window._portaiNumMisses if window._portaiNumMisses != None else 0);

        # Update targets.
        moved: list = [];
        for t in cTargets {
            moved.push(updateTarget(t, cTick));
        }

        # Update all balls.
        survivingBalls: list = [];
        for b in cBalls {
            GRAVITY = 0.32;
            nx = b["x"] + b["vx"];
            ny = b["y"] + b["vy"];
            nvx = b["vx"] * 0.998;
            nvy = b["vy"] + GRAVITY;

            hitPoints = 0;
            hitX = 0;
            hitY = 0;
            remainingTargets: list = [];
            for t in moved {
                catchRadius = (t["size"] * 0.6) + 12;
                isHit = hitDistanceSq(nx, ny, t["x"], t["y"]) <= (catchRadius * catchRadius);
                if isHit {
                    hitPoints = t["points"];
                    hitX = t["x"];
                    hitY = t["y"];
                } else {
                    remainingTargets.push(t);
                }
            }

            if hitPoints > 0 {
                cNumMisses = 0;
                cScore = cScore + hitPoints;
                hitFlash = True;
                hitText = {"x": hitX, "y": hitY - 20, "points": hitPoints, "key": Date.now()};
                setTimeout(lambda -> None { hitFlash = False; }, 200);
                setTimeout(lambda -> None { hitText = {}; }, 700);
                while remainingTargets.length < 4 {
                    tType = randomTargetType();
                    remainingTargets.push(createTarget(tType, cNextId));
                    cNextId = cNextId + 1;
                }
                moved = remainingTargets;
                # Ball consumed on hit — not added to survivingBalls
            } else {
                if ny > (worldHeight + 220) or nx > (worldWidth + 320) or nx < -140 or ny < -240 {
                    cNumMisses = cNumMisses + 1;
                    if cNumMisses >= 4 {
                        clearInterval(window._portaiGameLoopId);
                        window._portaiGameLoopId = None;
                        highScore = Math.max(highScore, cScore);
                        window._portaiHighScore = Math.max((window._portaiHighScore if window._portaiHighScore else 0), cScore);
                        gameOver = True;
                    }
                    # Ball OOB — not added to survivingBalls
                } else {
                    survivingBalls.push({"x": nx, "y": ny, "vx": nvx, "vy": nvy, "active": True, "id": b["id"]});
                }
            }
        }

        # Write to window globals.
        window._portaiBalls = survivingBalls;
        window._portaiTargets = moved;
        window._portaiTick = cTick;
        window._portaiScore = cScore;
        window._portaiNextTargetId = cNextId;
        window._portaiNumMisses = cNumMisses;

        # Push to React state for re-render.
        balls = survivingBalls;
        targets = moved;
        tick = cTick;
        score = cScore;
        nextTargetId = cNextId;
        numMisses = cNumMisses;

    }

    def handlePress(e: any) -> None {
        e.preventDefault();
        # if ball["active"] {
        #     resetBall();
        # }
        isDragging = True;
        dragStart = toWorldPoint(e);
        dragCurrent = toWorldPoint(e);
    }

    def handleMove(e: any) -> None {
        if not isDragging {
            return;
        }
        e.preventDefault();
        dragCurrent = toWorldPoint(e);
    }

    def handleRelease(e: any) -> None {
        if not isDragging {
            return;
        }
        e.preventDefault();
        releasePoint = toWorldPoint(e);
        if not releasePoint["x"] {
            releasePoint = dragCurrent;
        }

        dx = releasePoint["x"] - dragStart["x"];
        dy = releasePoint["y"] - dragStart["y"];
        power = Math.sqrt((dx * dx) + (dy * dy));

        isDragging = False;
        dragStart = {};
        dragCurrent = {};

        if power < 5 {
            return;
        }

        nowMs = Date.now();
        if (nowMs - (window._portaiLastThrowMs if window._portaiLastThrowMs else 0)) < 100 {
            return;
        }
        window._portaiLastThrowMs = nowMs;

        VELOCITY_SCALE = 0.065;
        maxPower = Math.min(250.0, power);
        unitX = dx / power;
        unitY = dy / power;

        newBall = {
            "x": ballStart()["x"],
            "y": ballStart()["y"],
            "vx": unitX * maxPower * VELOCITY_SCALE,
            "vy": unitY * maxPower * VELOCITY_SCALE,
            "active": True,
            "id": String(nowMs)
        };
        cBalls = (window._portaiBalls if window._portaiBalls else []).slice();
        cBalls.push(newBall);
        window._portaiBalls = cBalls;
        balls = cBalls;
        throws = throws + 1;
    }

    # def handleReset -> None {
    #     score = 0;
    #     throws = 0;
    #     tick = 0;
    #     targets = [];
    #     nextTargetId = 1;
    #     hitFlash = False;
    #     hitText = {};
    #     numMisses = 0;
    #     gameOver = False;
    #     highScore = (window._portaiHighScore if window._portaiHighScore else 0);
    #     window._portaiScore = 0;
    #     window._portaiTick = 0;
    #     window._portaiNextTargetId = 1;
    #     window._portaiTargets = [];
    #     window._portaiNumMisses = 0;
    #     resetBall();
    #     repopulateTargets();
    #     if window._portaiGameLoopId {
    #         clearInterval(window._portaiGameLoopId);
    #     }
    #     window._portaiGameLoopId = setInterval(lambda -> None { runTick(); }, 16);

    #     window._portaiBalls = [];
    #     window._portaiLastThrowMs = 0;
    #     balls = [];
    # }

    def handleReset -> None {
        # 1. Stop the loop first
        if window._portaiGameLoopId {
            clearInterval(window._portaiGameLoopId);
            window._portaiGameLoopId = None;
        }

        # 2. Clear ALL window globals before anything reads them
        window._portaiScore = 0;
        window._portaiTick = 0;
        window._portaiNextTargetId = 1;
        window._portaiTargets = [];
        window._portaiNumMisses = 0;
        window._portaiBalls = [];
        window._portaiLastThrowMs = 0;

        # 3. Reset React state
        score = 0;
        throws = 0;
        tick = 0;
        targets = [];
        nextTargetId = 1;
        hitFlash = False;
        hitText = {};
        numMisses = 0;
        gameOver = False;
        highScore = (window._portaiHighScore if window._portaiHighScore else 0);
        balls = [];

        # 4. Now repopulate from the clean empty global
        repopulateTargets();

        # 5. Restart the loop last
        window._portaiGameLoopId = setInterval(lambda -> None { runTick(); }, 16);
    }

    can with entry {
        resetBall();
        repopulateTargets();
        window._portaiScore = 0;
        window._portaiTick = 0;
        window._portaiNextTargetId = 1;
        window._portaiNumMisses = 0;

        # Don't reset high score on mount, only initialize if absent
        if not window._portaiHighScore {
            window._portaiHighScore = 0;
        }
        highScore = (window._portaiHighScore if window._portaiHighScore else 0);

        if window._portaiGameLoopId {
            clearInterval(window._portaiGameLoopId);
        }
        window._portaiGameLoopId = setInterval(lambda -> None { runTick(); }, 16);
    }

    # Build trajectory preview while aiming.
    trajectory: list = [];
    if isDragging and dragStart["x"] and dragCurrent["x"] {
        dx = dragCurrent["x"] - dragStart["x"];
        dy = dragCurrent["y"] - dragStart["y"];
        pwr = Math.sqrt((dx * dx) + (dy * dy));
        if pwr > 2 {
            usePower = Math.min(250.0, pwr);
            ux = dx / pwr;
            uy = dy / pwr;
            tvx = ux * usePower * 0.065;
            tvy = uy * usePower * 0.065;
            origin = ballStart();
            steps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
            for s in steps {
                px = origin["x"] + (tvx * s);
                py = origin["y"] + (tvy * s) + (0.35 * (s * s) * 0.5);
                if px > (worldWidth + 20) or py > (worldHeight + 20) or py < -30 {
                    break;
                }
                trajectory.push({"x": px, "y": py});
            }
        }
    }

    # throwAngle = (Math.atan2(ball["vy"], ball["vx"]) * 57.2958 if ball["active"] else -18);
    accuracy = (Math.round((score / throws) * 10) / 10 if throws > 0 else 0);

    # SVG helper strings.
    trajectoryStr = trajectory.map(lambda p: dict -> str {
        return String(Math.round(p["x"])) + "," + String(Math.round(p["y"]));
    }).join(" ");

    return
        <div className="game-page">
            <div className="game-header-row">
                <div>
                    <h1 className="game-title">Target Practice</h1>
                    <p className="game-hint">Click and drag in the direction you want to throw. Release to launch the football.</p>
                </div>
                <div className="game-ui-group">
                    <div className="game-stat-card">
                        <span className="game-stat-label">Score</span>
                        <span className="game-stat-value">{String(score)}</span>
                    </div>
                    <div className="game-stat-card">
                        <span className="game-stat-label">Throws</span>
                        <span className="game-stat-value">{String(throws)}</span>
                    </div>
                    <div className="game-stat-card">
                        <span className="game-stat-label">Avg Pts</span>
                        <span className="game-stat-value">{String(accuracy)}</span>
                    </div>
                    <div className="game-stat-card">
                        <span className="game-stat-label">Best</span>
                        <span className="game-stat-value">{String(highScore)}</span>
                    </div>
                    <div className="game-stat-card">
                        <span className="game-stat-label">Misses Left</span>
                        <span className="game-stat-value">{4 - String(numMisses)}</span>
                    </div>
                    <button className="btn btn-outline game-reset-btn" onClick={handleReset}>Reset</button>
                </div>
            </div>

            <div className="game-stage-shell">
                <div
                    id="portai-game-world"
                    className={"game-world" + (" game-hit-flash" if hitFlash else "")}
                    onMouseDown={handlePress}
                    onMouseMove={handleMove}
                    onMouseUp={handleRelease}
                    onMouseLeave={handleRelease}
                    onTouchStart={handlePress}
                    onTouchMove={handleMove}
                    onTouchEnd={handleRelease}
                >
                    <svg className="game-svg" viewBox={"0 0 " + String(worldWidth) + " " + String(worldHeight)} preserveAspectRatio="xMidYMid meet">
                        <defs>
                            <linearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stopColor="#1a2a4a" />
                                <stop offset="100%" stopColor="#2d4a2e" />
                            </linearGradient>
                            <linearGradient id="fieldGrad" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stopColor="#2e5a2f" />
                                <stop offset="100%" stopColor="#1d3d1e" />
                            </linearGradient>
                        </defs>

                        <rect x="0" y="0" width={String(worldWidth)} height={String(groundY)} fill="url(#skyGrad)" />
                        <rect x="0" y={String(groundY)} width={String(worldWidth)} height={String(worldHeight - groundY)} fill="url(#fieldGrad)" />

                        <line x1="0" y1={String(groundY)} x2={String(worldWidth)} y2={String(groundY)} stroke="#ffffff" strokeWidth="2" />
                        <line x1="200" y1={String(groundY)} x2="200" y2={String(worldHeight)} stroke="#ffffff" strokeWidth="1" opacity="0.4" />
                        <line x1="400" y1={String(groundY)} x2="400" y2={String(worldHeight)} stroke="#ffffff" strokeWidth="1" opacity="0.4" />
                        <line x1="600" y1={String(groundY)} x2="600" y2={String(worldHeight)} stroke="#ffffff" strokeWidth="1" opacity="0.4" />
                        <line x1="800" y1={String(groundY)} x2="800" y2={String(worldHeight)} stroke="#ffffff" strokeWidth="1" opacity="0.4" />

                        <rect x="870" y={String(groundY)} width="130" height={String(worldHeight - groundY)} fill="#8b2020" opacity="0.25" />
                        <text x="935" y={String(groundY + 40)} textAnchor="middle" fill="#ffffff" fontSize="14" opacity="0.5" fontFamily="sans-serif">END ZONE</text>

                        <rect x="910" y={String(groundY - 130)} width="6" height="130" fill="#FFFF00" opacity="0.6" />
                        <rect x="880" y={String(groundY - 132)} width="66" height="5" fill="#FFFF00" opacity="0.6" rx="2" />
                        <rect x="880" y={String(groundY - 162)} width="3" height="35" fill="#FFFF00" opacity="0.6" />
                        <rect x="943" y={String(groundY - 162)} width="3" height="35" fill="#FFFF00" opacity="0.6" />

                        {(
                            <polyline
                                points={trajectoryStr}
                                fill="none"
                                stroke="#ffffff"
                                strokeWidth="2"
                                strokeDasharray="6,4"
                                opacity="0.55"
                            />
                        ) if trajectory.length > 1 else None}

                        {targets.map(lambda t: dict -> any {
                            r = t["size"] / 2;
                            fillColor = ("#e8a520" if t["kind"] == "wheel" else ("#20a8e8" if t["kind"] == "swing" else ("#e84040" if t["kind"] == "balloon" else "#9333ea")));
                            
                            return <g key={t["id"]}>
                                {(
                                    <g transform={"translate(" + String(t["x"]) + "," + String(t["y"]) + ")"}>
                                        <ellipse cx="0" cy="0" rx={String(r * 1.8)} ry={String(r * 0.5)} fill="#9333ea" stroke="#ffffff" strokeWidth="2" opacity="0.9" />
                                        <ellipse cx={String(r * 0.4)} cy={String(-r * 0.3)} rx={String(r * 0.7)} ry={String(r * 0.35)} fill="#a855f7" stroke="#ffffff" strokeWidth="1.5" opacity="0.9" />
                                        <ellipse cx={String(-r * 1.2)} cy="0" rx={String(r * 0.4)} ry={String(r * 0.2)} fill="#7e22ce" stroke="#ffffff" strokeWidth="1" opacity="0.9" />
                                        <circle cx={String(r * 0.3)} cy={String(-r * 0.2)} r={String(Math.max(2, r * 0.15))} fill="#ffffff" opacity="0.7" />
                                    </g>
                                ) if t["kind"] == "plane" else (
                                    <g>
                                        <circle cx={String(t["x"])} cy={String(t["y"])} r={String(r)} fill={fillColor} stroke="#ffffff" strokeWidth="2" opacity="0.9" />
                                        <circle cx={String(t["x"])} cy={String(t["y"])} r={String(Math.max(3, r * 0.3))} fill="#ffffff" opacity="0.7" />
                                    </g>
                                )}
                                <text x={String(t["x"])} y={String(t["y"] - r - 6)} textAnchor="middle" fill="#ffffff" fontSize="11" opacity="0.7" fontFamily="sans-serif">
                                    {("+" + String(t["points"]))}
                                </text>
                            </g>;
                        })}

                        <g transform={"translate(" + String(qbX) + "," + String(qbY - 60) + ")"}>
                            <circle cx="0" cy="0" r="10" fill="#1a3a6a" />
                            <rect x="-6" y="10" width="12" height="28" rx="3" fill="#1a3a6a" />
                            <line x1="6" y1="16" x2="18" y2={"2" if balls.length > 0 else "8"} stroke="#1a3a6a" strokeWidth="4" strokeLinecap="round" />
                            <line x1="-6" y1="16" x2="-14" y2="28" stroke="#1a3a6a" strokeWidth="4" strokeLinecap="round" />
                            <line x1="-3" y1="38" x2="-8" y2="56" stroke="#1a3a6a" strokeWidth="4" strokeLinecap="round" />
                            <line x1="3" y1="38" x2="8" y2="56" stroke="#1a3a6a" strokeWidth="4" strokeLinecap="round" />
                            <text x="0" y="-16" textAnchor="middle" fill="#ffffff" fontSize="10" opacity="0.7" fontFamily="sans-serif">QB</text>
                        </g>

                        {balls.map(lambda b: dict -> any {
                            bAngle = (Math.atan2(b["vy"], b["vx"]) * 57.2958 if b["active"] else -18);
                            return <g key={b["id"]} transform={"translate(" + String(Math.round(b["x"])) + "," + String(Math.round(b["y"])) + ") rotate(" + String(Math.round(bAngle)) + ")"}>
                                <ellipse cx="0" cy="0" rx="11" ry="6" fill="#8B4513" stroke="#5a2d0c" strokeWidth="1" />
                                <line x1="-4" y1="0" x2="4" y2="0" stroke="#ffffff" strokeWidth="1.5" />
                                <line x1="-2" y1="-2" x2="-2" y2="2" stroke="#ffffff" strokeWidth="0.8" />
                                <line x1="0" y1="-2" x2="0" y2="2" stroke="#ffffff" strokeWidth="0.8" />
                                <line x1="2" y1="-2" x2="2" y2="2" stroke="#ffffff" strokeWidth="0.8" />
                            </g>;
                        })}

                        {(
                            <text
                                className="game-hit-text"
                                x={String(hitText["x"])}
                                y={String(hitText["y"])}
                                textAnchor="middle"
                                fill="#22c55e"
                                fontSize="22"
                                fontWeight="bold"
                                fontFamily="sans-serif"
                            >
                                {"+" + String(hitText["points"])}
                            </text>
                        ) if hitText and hitText["points"] else None}
                    </svg>


                    {(
                        <div className="game-over-overlay">
                            <div className="game-over-card">
                                <h2 className="game-over-title">Game Over</h2>
                                <p className="game-over-score">{"Final Score: " + String(score)}</p>
                                <p className="game-over-highscore">{"Best Ever: " + String(highScore)}</p>
                                <button className="btn btn-primary" onClick={handleReset}>Play Again</button>
                            </div>
                        </div>
                    ) if gameOver else None}
                </div>

            </div>

            <div className="game-footer-hint">
                <span>Difficulty scales as you score: targets get smaller and faster.</span>
                <span className="game-difficulty-pill">{"Level " + String(difficulty())}</span>
            </div>

        </div>;
}
