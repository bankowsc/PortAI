"BaseballManager - Game Page: Inning-by-inning baseball manager simulation."

def:pub GamePage() -> any {
    # ── constants ──────────────────────────────────────────────────────────────
    has POSITIONS: list = ["C","1B","2B","3B","SS","LF","CF","RF","DH"],
        NAMES_F: list = ["Carter","Morgan","Rivera","Chen","Williams","Davis",
                         "Wilson","Martinez","Thompson","Robinson","Hayes",
                         "Torres","Nguyen","Parker","Jackson"],
        NAMES_L: list = ["Smith","Johnson","Brown","Lee","Garcia","Miller",
                         "Moore","Taylor","Anderson","Thomas","White",
                         "Harris","Clark","Lewis","Walker"],
        TEAM_NAMES: list = ["Redbirds","Thunderhawks","Ironclads","Blue Sox",
                            "Coyotes","River Dogs","Stallions","Vipers",
                            "Grizzlies","Stingrays"],
        CITY_NAMES: list = ["Springfield","Lakewood","Riverdale","Oakburg",
                            "Summit","Millport","Fairview","Crestwood",
                            "Harborfield","Westgate"];

    # ── state ──────────────────────────────────────────────────────────────────
    has youTeam: any = None,
        oppTeam: any = None,
        yourLineup: list = [],       # indices into youTeam.hitters (9 slots)
        yourBenchIds: list = [],     # hitter indices on bench
        yourPitcherIdx: int = 0,
        oppLineup: list = [],
        battingIdxYou: int = 0,
        battingIdxOpp: int = 0,
        inning: int = 1,
        topBottom: str = "top",      # "top" = opp bats, "bottom" = you bat
        outs: int = 0,
        balls: int = 0,
        strikes: int = 0,
        bases: list = [None, None, None],   # 1B, 2B, 3B
        gameLog: list = [],
        gameOver: bool = False,
        screen: str = "setup",       # "setup" | "lineup" | "game" | "gameover"
        mgrTab: str = "sub",
        dragFromSlot: any = None,
        subOutSlot: int = 0,
        subInIdx: any = None,
        pitchChangeTarget: any = None;

    # ── helpers ────────────────────────────────────────────────────────────────
    def rnd(minVal: float, maxVal: float) -> float {
        return minVal + (Math.random() * (maxVal - minVal));
    }

    def rndInt(minVal: int, maxVal: int) -> int {
        return Math.floor(rnd(float(minVal), float(maxVal) + 1.0));
    }

    def pick(arr: list) -> any {
        return arr[rndInt(0, arr.length - 1)];
    }

    def round2(v: float) -> float {
        return Math.round(v * 100.0) / 100.0;
    }

    def round3(v: float) -> float {
        return Math.round(v * 1000.0) / 1000.0;
    }

    # ── player generation ──────────────────────────────────────────────────────
    def genHitter(idx: int) -> any {
        hand = ("R" if Math.random() > 0.3 else "L");
        num = rndInt(1, 99);
        firstName = pick(NAMES_F);
        lastName = pick(NAMES_L);
        pos = (POSITIONS[idx] if idx < POSITIONS.length else pick(POSITIONS));
        return {
            "id": idx,
            "name": firstName[0] + ". " + lastName,
            "hand": hand,
            "num": num,
            "pos": pos,
            "avg": round3(rnd(0.220, 0.320)),
            "ops": round2(rnd(0.650, 0.950)),
            "bbRate": round2(rnd(0.07, 0.18)),
            "kRate": round2(rnd(0.14, 0.30)),
            "active": True,
            "inGame": idx < 9,
            "stats": {"ab": 0, "h": 0, "bb": 0, "k": 0, "rbi": 0, "r": 0}
        };
    }

    def genPitcher(idx: int) -> any {
        isStarter = idx < 5;
        hand = ("R" if Math.random() > 0.3 else "L");
        num = rndInt(1, 99);
        firstName = pick(NAMES_F);
        lastName = pick(NAMES_L);
        ipLo = (4.5 if isStarter else 0.8);
        ipHi = (6.5 if isStarter else 1.5);
        kLo = (0.18 if isStarter else 0.22);
        kHi = (0.28 if isStarter else 0.35);
        eraLo = (3.2 if isStarter else 3.0);
        eraHi = (5.5 if isStarter else 5.0);
        whipLo = (1.1 if isStarter else 1.0);
        whipHi = (1.4 if isStarter else 1.35);
        return {
            "id": idx,
            "name": firstName[0] + ". " + lastName,
            "hand": hand,
            "num": num,
            "role": ("SP" if isStarter else "RP"),
            "isStarter": isStarter,
            "ipAvg": round2(rnd(ipLo, ipHi)),
            "kRate": round2(rnd(kLo, kHi)),
            "bbRate": round2(rnd(0.06, 0.15)),
            "whip": round2(rnd(whipLo, whipHi)),
            "era": round2(rnd(eraLo, eraHi)),
            "ipThisGame": 0,
            "pitchesThisGame": 0,
            "usedThisGame": False,
            "active": False,
            "currentPitcher": False
        };
    }

    def genTeam(name: str) -> any {
        hitters: list = [];
        pitchers: list = [];
        i = 0;
        while i < 13 {
            hitters.push(genHitter(i));
            i = i + 1;
        }
        j = 0;
        while j < 13 {
            pitchers.push(genPitcher(j));
            j = j + 1;
        }
        return {
            "name": name,
            "hitters": hitters,
            "pitchers": pitchers,
            "score": [0, 0, 0, 0, 0, 0, 0, 0, 0],
            "runs": 0
        };
    }

    # ── current-pitcher / batter getters ──────────────────────────────────────
    def getCurrentPitcher(team: any) -> any {
        for p in team["pitchers"] {
            if p["currentPitcher"] {
                return p;
            }
        }
        return team["pitchers"][0];
    }

    def getCurrentBatter(isYou: bool) -> any {
        team = (youTeam if isYou else oppTeam);
        lu = (yourLineup if isYou else oppLineup);
        idx = (battingIdxYou if isYou else battingIdxOpp) % 9;
        return team["hitters"][lu[idx]];
    }

    # ── at-bat outcome simulation ──────────────────────────────────────────────
    def getAtBatResult(batter: any, pitcher: any) -> str {
        adjK = (batter["kRate"] * 0.5) + (pitcher["kRate"] * 0.5) + ((pitcher["whip"] - 1.2) * 0.08);
        adjBB = (batter["bbRate"] * 0.5) + (pitcher["bbRate"] * 0.5);
        adjH = batter["avg"] * (1.0 / pitcher["whip"]);
        r = Math.random();
        kThresh = Math.min(0.35, adjK);
        bbThresh = kThresh + Math.min(0.18, adjBB);
        hitThresh = bbThresh + (adjH * 0.35);
        if r < kThresh {
            return "K";
        }
        if r < bbThresh {
            return "BB";
        }
        if r < hitThresh {
            hr = Math.random();
            if hr < 0.08 + (batter["ops"] * 0.04) {
                return "HR";
            }
            if hr < 0.20 {
                return "2B";
            }
            if hr < 0.28 {
                return "3B";
            }
            return "1B";
        }
        if r < 0.55 {
            return "GO";
        }
        return "FO";
    }

    # ── baserunning ────────────────────────────────────────────────────────────
    def advanceBases(result: str, curBases: list, batter: any) -> any {
        scored = 0;
        nb = [curBases[0], curBases[1], curBases[2]];

        if result == "1B" {
            if nb[2] {
                scored = scored + 1;
            }
            nb[2] = nb[1];
            nb[1] = (nb[0] if nb[0] else result);
            nb[0] = batter;
        }
        if result == "2B" {
            if nb[2] {
                scored = scored + 1;
            }
            if nb[1] {
                scored = scored + 1;
            }
            nb[2] = nb[0];
            nb[1] = batter;
            nb[0] = None;
        }
        if result == "3B" {
            if nb[0] {
                scored = scored + 1;
            }
            if nb[1] {
                scored = scored + 1;
            }
            if nb[2] {
                scored = scored + 1;
            }
            nb[0] = None;
            nb[1] = None;
            nb[2] = batter;
        }
        if result == "HR" {
            if nb[0] {
                scored = scored + 1;
            }
            if nb[1] {
                scored = scored + 1;
            }
            if nb[2] {
                scored = scored + 1;
            }
            scored = scored + 1;
            nb[0] = None;
            nb[1] = None;
            nb[2] = None;
        }
        if result == "BB" {
            if nb[0] and nb[1] and nb[2] {
                scored = scored + 1;
            } else {
                if nb[0] and nb[1] {
                    nb[2] = batter;
                } else {
                    if nb[0] {
                        nb[1] = batter;
                    } else {
                        nb[0] = batter;
                    }
                }
            }
        }

        return {"bases": nb, "scored": scored};
    }

    # ── game init ──────────────────────────────────────────────────────────────
    def handleNewGame -> None {
        cn1 = pick(CITY_NAMES);
        cn2 = pick(CITY_NAMES);
        tn1 = pick(TEAM_NAMES);
        tn2 = pick(TEAM_NAMES);
        youTeam = genTeam(cn1 + " " + tn1);
        oppTeam = genTeam(cn2 + " " + tn2);

        yourLineup = [0, 1, 2, 3, 4, 5, 6, 7, 8];
        yourBenchIds = [9, 10, 11, 12];
        yourPitcherIdx = 0;
        oppLineup = [0, 1, 2, 3, 4, 5, 6, 7, 8];

        inning = 1;
        topBottom = "top";
        outs = 0;
        balls = 0;
        strikes = 0;
        bases = [None, None, None];
        gameLog = [];
        gameOver = False;
        battingIdxYou = 0;
        battingIdxOpp = 0;
        mgrTab = "sub";

        oppTeam["pitchers"][0]["currentPitcher"] = True;
        oppTeam["pitchers"][0]["active"] = True;

        screen = "lineup";
    }

    # ── lineup drag-reorder ────────────────────────────────────────────────────
    def handleDragStart(slot: int) -> None {
        dragFromSlot = slot;
    }

    def handleDropOnSlot(toSlot: int) -> None {
        if dragFromSlot == None or dragFromSlot == toSlot {
            dragFromSlot = None;
            return;
        }
        tmp = yourLineup[dragFromSlot];
        yourLineup[dragFromSlot] = yourLineup[toSlot];
        yourLineup[toSlot] = tmp;
        dragFromSlot = None;
    }

    # ── start game from lineup screen ─────────────────────────────────────────
    def handleStartGame -> None {
        for p in youTeam["pitchers"] {
            p["currentPitcher"] = False;
            p["active"] = False;
        }
        youTeam["pitchers"][yourPitcherIdx]["currentPitcher"] = True;
        youTeam["pitchers"][yourPitcherIdx]["active"] = True;
        screen = "game";
    }

    # ── single at-bat simulation ───────────────────────────────────────────────
    def handleSimAtBat -> None {
        if gameOver {
            return;
        }
        isYouBatting = topBottom == "bottom";
        battingTeam = (youTeam if isYouBatting else oppTeam);
        fieldingTeam = (oppTeam if isYouBatting else youTeam);
        batter = getCurrentBatter(isYouBatting);
        pitcher = getCurrentPitcher(fieldingTeam);
        result = getAtBatResult(batter, pitcher);

        batter["stats"]["ab"] = batter["stats"]["ab"] + 1;
        pitcher["pitchesThisGame"] = pitcher["pitchesThisGame"] + 1;

        msg = "";

        if result == "K" {
            outs = outs + 1;
            batter["stats"]["k"] = batter["stats"]["k"] + 1;
            msg = batter["name"] + " strikes out.";
        }
        if result == "GO" {
            outs = outs + 1;
            msg = batter["name"] + " grounds out.";
        }
        if result == "FO" {
            outs = outs + 1;
            msg = batter["name"] + " flies out.";
        }
        if result == "BB" {
            adv = advanceBases("BB", bases, batter);
            bases = adv["bases"];
            batter["stats"]["bb"] = batter["stats"]["bb"] + 1;
            msg = batter["name"] + " walks.";
            if adv["scored"] > 0 {
                battingTeam["score"][inning - 1] = battingTeam["score"][inning - 1] + adv["scored"];
                battingTeam["runs"] = battingTeam["runs"] + adv["scored"];
                batter["stats"]["rbi"] = batter["stats"]["rbi"] + adv["scored"];
                msg = msg + " " + String(adv["scored"]) + " run(s) score!";
            }
        }
        if result == "1B" or result == "2B" or result == "3B" or result == "HR" {
            adv = advanceBases(result, bases, batter);
            bases = adv["bases"];
            batter["stats"]["h"] = batter["stats"]["h"] + 1;
            hitLabel = ("single" if result == "1B" else ("double" if result == "2B" else ("triple" if result == "3B" else "home run")));
            msg = batter["name"] + " hits a " + hitLabel + "!";
            if adv["scored"] > 0 {
                battingTeam["score"][inning - 1] = battingTeam["score"][inning - 1] + adv["scored"];
                battingTeam["runs"] = battingTeam["runs"] + adv["scored"];
                batter["stats"]["rbi"] = batter["stats"]["rbi"] + adv["scored"];
                msg = msg + " " + String(adv["scored"]) + " run(s) score!";
            }
        }

        if isYouBatting {
            battingIdxYou = battingIdxYou + 1;
        } else {
            battingIdxOpp = battingIdxOpp + 1;
        }

        gameLog = [msg] + gameLog;

        if outs >= 3 {
            handleEndHalfInning();
        }
    }

    # ── simulate a full half-inning ────────────────────────────────────────────
    def handleSimInning -> None {
        if gameOver {
            return;
        }
        while not gameOver and outs < 3 {
            handleSimAtBat();
        }
    }

    # ── end of half-inning logic ───────────────────────────────────────────────
    def handleEndHalfInning -> None {
        outs = 0;
        balls = 0;
        strikes = 0;
        bases = [None, None, None];

        if topBottom == "top" {
            topBottom = "bottom";
        } else {
            if inning >= 9 and youTeam["runs"] != oppTeam["runs"] {
                handleGameOver();
                return;
            }
            if inning >= 12 {
                handleGameOver();
                return;
            }
            inning = inning + 1;
            topBottom = "top";
            half = "Top " + String(inning);
            gameLog = ["--- " + half + " ---"] + gameLog;
        }
    }

    def handleGameOver -> None {
        gameOver = True;
        screen = "gameover";
    }

    # ── substitution ──────────────────────────────────────────────────────────
    def handleMakeSub -> None {
        if subInIdx == None {
            return;
        }
        outIdx = yourLineup[subOutSlot];
        outPlayer = youTeam["hitters"][outIdx];
        inPlayer = youTeam["hitters"][subInIdx];
        outPlayer["inGame"] = False;
        inPlayer["inGame"] = True;
        yourLineup[subOutSlot] = subInIdx;
        newBench: list = [];
        for bi in yourBenchIds {
            if bi != subInIdx {
                newBench.push(bi);
            }
        }
        yourBenchIds = newBench;
        logMsg = "Sub: " + inPlayer["name"] + " replaces " + outPlayer["name"] + " (slot " + String(subOutSlot + 1) + ").";
        gameLog = [logMsg] + gameLog;
        subInIdx = None;
    }

    # ── pitching change ────────────────────────────────────────────────────────
    def handleChangePitcher(newPid: int) -> None {
        oldPitcher = getCurrentPitcher(youTeam);
        oldPitcher["currentPitcher"] = False;
        oldPitcher["usedThisGame"] = True;
        newPitcher = youTeam["pitchers"][newPid];
        newPitcher["currentPitcher"] = True;
        newPitcher["active"] = True;
        logMsg = "Pitching change: " + newPitcher["name"] + " comes in for " + oldPitcher["name"] + ".";
        gameLog = [logMsg] + gameLog;
    }

    # ── SVG diamond builder ────────────────────────────────────────────────────
    def buildDiamondSvg -> any {
        cx = 70;
        cy = 58;
        c1 = (bases[0] != None);
        c2 = (bases[1] != None);
        c3 = (bases[2] != None);
        f1 = ("#185fa5" if c1 else "#d3d1c7");
        f2 = ("#185fa5" if c2 else "#d3d1c7");
        f3 = ("#185fa5" if c3 else "#d3d1c7");
        return (
            <svg width="140" height="120" viewBox="0 0 140 120">
                <polygon
                    points={(String(cx) + "," + String(cy - 38) + " " + String(cx + 38) + "," + String(cy) + " " + String(cx) + "," + String(cy + 38) + " " + String(cx - 38) + "," + String(cy))}
                    fill="none" stroke="#888780" strokeWidth="1.5"
                />
                <rect x={String(cx - 8)} y={String(cy - 8)} width="16" height="16" fill="#d3d1c7" stroke="#888780" rx="2" />
                <rect x={String(cx + 30)} y={String(cy - 8)} width="16" height="16" fill={f1} stroke="#888780" rx="2" />
                <rect x={String(cx - 8)} y={String(cy - 46)} width="16" height="16" fill={f2} stroke="#888780" rx="2" />
                <rect x={String(cx - 46)} y={String(cy - 8)} width="16" height="16" fill={f3} stroke="#888780" rx="2" />
                <text x={String(cx + 38)} y={String(cy - 14)} fontSize="9" fill="#888780" textAnchor="middle">1B</text>
                <text x={String(cx)} y={String(cy - 54)} fontSize="9" fill="#888780" textAnchor="middle">2B</text>
                <text x={String(cx - 38)} y={String(cy - 14)} fontSize="9" fill="#888780" textAnchor="middle">3B</text>
            </svg>
        );
    }

    # ── scoreboard row builder ─────────────────────────────────────────────────
    def buildScoreboardRow(team: any, isYou: bool) -> any {
        shortName = team["name"].split(" ")[1];
        cells: list = [];
        i = 0;
        while i < 9 {
            v = team["score"][i];
            cells.push(<td key={String(i)} style="padding:3px 6px;text-align:center;font-size:12px">{String(v)}</td>);
            i = i + 1;
        }
        return (
            <tr>
                <td style="padding:3px 8px;font-size:12px;font-weight:500">{shortName}</td>
                {cells}
                <td style="padding:3px 8px;font-size:12px;font-weight:500;border-left:1px solid var(--color-border-tertiary)">{String(team["runs"])}</td>
            </tr>
        );
    }

    # ── lineup screen render ──────────────────────────────────────────────────
    def renderLineupScreen -> any {
        lineupSlots: list = [];
        slotIdx = 0;
        for hi in yourLineup {
            h = youTeam["hitters"][hi];
            avgStr = "." + String(Math.round(h["avg"] * 1000));
            slotIdx_final = slotIdx;

            onDrag = lambda e { handleDragStart(slotIdx_final) };
            onOver = lambda e { e.preventDefault() };
            onDropFn = lambda e { handleDropOnSlot(slotIdx_final) };

            lineupSlots.push(
                <div
                    key={String(slotIdx)}
                    draggable={True}
                    onDragStart={onDrag}
                    onDragOver={onOver}
                    onDrop={onDropFn}
                    style="display:flex;align-items:center;gap:8px;padding:5px 8px;border-radius:8px;border:0.5px solid var(--color-border-tertiary);margin-bottom:4px;background:var(--color-background-primary);cursor:grab"
                >
                    <span style="font-size:12px;color:var(--color-text-tertiary);width:18px;text-align:right">{String(slotIdx + 1)}</span>
                    <span style="font-size:11px;color:var(--color-text-secondary);width:32px">{h["pos"]}</span>
                    <span style="font-weight:500;font-size:13px;flex:1">{h["name"]}</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">{avgStr} AVG</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">OPS {String(h["ops"])}</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">#{String(h["num"])} {h["hand"]}</span>
                </div>
            );
        }

        spOptions: list = [];
        pi = 0;
        for p in youTeam["pitchers"] {
            if p["isStarter"] {
                spOptions.push(
                    <option key={String(pi)} value={String(pi)}>{p["name"] + " (ERA " + String(p["era"]) + ", WHIP " + String(p["whip"]) + ", " + p["hand"] + "HP)"}</option>
                );
            }
            pi = pi + 1;
        }

        benchRows: list = [];
        for bi in yourBenchIds {
            h = youTeam["hitters"][bi];
            benchRows.push(
                <div key={String(bi)} style="display:flex;align-items:center;gap:8px;padding:4px 0;border-bottom:0.5px solid var(--color-border-tertiary);font-size:12px">
                    <span style="font-weight:500;flex:1">{h["name"]}</span>
                    <span style="color:var(--color-text-secondary)">{h["pos"]}</span>
                    <span style="color:var(--color-text-secondary)">.{String(Math.round(h["avg"] * 1000))} AVG</span>
                    <span style="color:var(--color-text-secondary)">OPS {String(h["ops"])}</span>
                </div>
            );
        }

        oppRows: list = [];
        oi = 0;
        for hi in oppLineup {
            h = oppTeam["hitters"][hi];
            oppRows.push(
                <div key={String(oi)} style="font-size:12px;color:var(--color-text-secondary);padding:2px 0">{String(oi + 1) + ". " + h["name"] + " - " + h["pos"] + " | ."+String(Math.round(h["avg"]*1000)) + " | " + h["hand"] + "H"}</div>
            );
            oi = oi + 1;
        }

        return (
            <div style="padding:12px 0;max-width:900px;margin:0 auto">
                <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:14px 16px;margin-bottom:10px">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                        <h2 style="font-size:18px;font-weight:500">{youTeam["name"]}</h2>
                        <span style="font-size:14px;color:var(--color-text-secondary)">{"vs " + oppTeam["name"]}</span>
                    </div>
                    <p style="font-size:12px;color:var(--color-text-secondary);margin-bottom:12px">Drag to reorder your batting lineup. Choose your starting pitcher, then click Play Ball.</p>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px">
                        <div>
                            <h3 style="font-size:15px;font-weight:500;margin-bottom:6px">Your lineup</h3>
                            {lineupSlots}
                            <div style="margin-top:8px">
                                <label style="font-size:13px;color:var(--color-text-secondary)">Starting pitcher: </label>
                                <select
                                    value={String(yourPitcherIdx)}
                                    onChange={lambda e: any -> None { yourPitcherIdx = int(e.target.value); }}
                                    style="padding:4px 8px;border-radius:8px;border:0.5px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);font-size:13px"
                                >
                                    {spOptions}
                                </select>
                            </div>
                        </div>
                        <div>
                            <h3 style="font-size:15px;font-weight:500;margin-bottom:4px">Your bench</h3>
                            {benchRows}
                            <h3 style="font-size:15px;font-weight:500;margin-top:12px;margin-bottom:4px">Opponent lineup</h3>
                            {oppRows}
                        </div>
                    </div>
                    <div style="margin-top:14px">
                        <button
                            onClick={handleStartGame}
                            style="background:#185fa5;color:#e6f1fb;border:0.5px solid #185fa5;border-radius:8px;padding:7px 18px;font-size:13px;cursor:pointer"
                        >Play Ball!</button>
                    </div>
                </div>
            </div>
        );
    }

    # ── manager panel: substitutions tab ─────────────────────────────────────
    def renderSubTab -> any {
        if topBottom != "bottom" {
            return <p style="font-size:13px;color:var(--color-text-secondary)">Substitutions are available when your team is batting.</p>;
        }
        bench = yourBenchIds.filter(lambda bi: int -> bool { return youTeam["hitters"][bi]["active"] and not youTeam["hitters"][bi]["inGame"]; });
        if bench.length == 0 {
            return <div style="padding:8px 12px;border-radius:8px;background:#e6f1fb;color:#185fa5;border:0.5px solid #b5d4f4;font-size:13px">No bench players remaining.</div>;
        }

        outOptions: list = [];
        si = 0;
        for hi in yourLineup {
            h = youTeam["hitters"][hi];
            outOptions.push(
                <option key={String(si)} value={String(si)}>{String(si + 1) + ". " + h["name"] + " (" + h["pos"] + ") ." + String(Math.round(h["avg"] * 1000))}</option>
            );
            si = si + 1;
        }

        inOptions: list = [];
        for bi in bench {
            h = youTeam["hitters"][bi];
            inOptions.push(
                <option key={String(bi)} value={String(bi)}>{h["name"] + " (" + h["pos"] + ") ." + String(Math.round(h["avg"] * 1000)) + " OPS " + String(h["ops"])}</option>
            );
        }

        return (
            <div>
                <p style="font-size:12px;color:var(--color-text-secondary);margin-bottom:8px">Pinch hit: swap a bench player into your lineup.</p>
                <div style="margin-bottom:6px">
                    <label style="font-size:12px;color:var(--color-text-secondary)">Replace: </label>
                    <select
                        value={String(subOutSlot)}
                        onChange={lambda e: any -> None { subOutSlot = int(e.target.value); }}
                        style="padding:4px 8px;border-radius:8px;border:0.5px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);font-size:12px"
                    >{outOptions}</select>
                </div>
                <div style="margin-bottom:8px">
                    <label style="font-size:12px;color:var(--color-text-secondary)">Bring in: </label>
                    <select
                        onChange={lambda e: any -> None { subInIdx = int(e.target.value); }}
                        style="padding:4px 8px;border-radius:8px;border:0.5px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);font-size:12px"
                    >{inOptions}</select>
                </div>
                <button
                    onClick={handleMakeSub}
                    style="background:transparent;border:0.5px solid var(--color-border-secondary);border-radius:8px;padding:5px 14px;font-size:13px;cursor:pointer;color:var(--color-text-primary)"
                >Make substitution</button>
            </div>
        );
    }

    # ── manager panel: pitching tab ───────────────────────────────────────────
    def renderPitchTab -> any {
        cp = getCurrentPitcher(youTeam);
        avail = youTeam["pitchers"].filter(lambda p: any -> bool { return not p["currentPitcher"] and not p["usedThisGame"]; });

        pitcherRows: list = [];
        for p in avail {
            pid = p["id"];
            pitcherRows.push(
                <div key={String(pid)} style="display:flex;align-items:center;gap:8px;padding:5px 0;border-bottom:0.5px solid var(--color-border-tertiary)">
                    <span style="font-weight:500;font-size:13px;flex:1">{p["name"]}</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">{p["role"]}</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">WHIP {String(p["whip"])}</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">K% {String(Math.round(p["kRate"] * 100))}%</span>
                    <span style="font-size:11px;padding:2px 7px;border-radius:12px;background:var(--color-background-secondary);color:var(--color-text-secondary)">{p["hand"]}HP</span>
                    <button
                        onClick={lambda e: any -> None { handleChangePitcher(pid); }}
                        style="background:transparent;border:0.5px solid var(--color-border-secondary);border-radius:8px;padding:3px 9px;font-size:12px;cursor:pointer;color:var(--color-text-primary)"
                    >Bring in</button>
                </div>
            );
        }

        noneMsg = (
            <div style="padding:8px 12px;border-radius:8px;background:#fcebeb;color:#a32d2d;border:0.5px solid #f7c1c1;font-size:13px">No fresh pitchers available.</div>
        );

        return (
            <div>
                <div style="padding:8px 12px;border-radius:8px;background:#e6f1fb;color:#185fa5;border:0.5px solid #b5d4f4;font-size:13px;margin-bottom:8px">
                    {"Current: " + cp["name"] + " | " + cp["hand"] + "HP | WHIP " + String(cp["whip"]) + " | ~" + String(cp["pitchesThisGame"]) + " pitches"}
                </div>
                {noneMsg if avail.length == 0 else pitcherRows}
            </div>
        );
    }

    # ── manager panel: stats tab ──────────────────────────────────────────────
    def renderStatsTab -> any {
        rows: list = [];
        si = 0;
        for hi in yourLineup {
            h = youTeam["hitters"][hi];
            avgStr = (String(round3(h["stats"]["h"] / float(h["stats"]["ab"]))) if h["stats"]["ab"] > 0 else "-");
            rows.push(
                <div key={String(si)} style="display:flex;gap:8px;padding:3px 0;border-bottom:0.5px solid var(--color-border-tertiary);font-size:12px">
                    <span style="width:18px;color:var(--color-text-tertiary)">{String(si + 1)}</span>
                    <span style="flex:1;font-weight:500">{h["name"]}</span>
                    <span style="color:var(--color-text-secondary)">{String(h["stats"]["ab"]) + "-" + String(h["stats"]["h"]) + " " + String(h["stats"]["bb"]) + "BB " + String(h["stats"]["k"]) + "K " + String(h["stats"]["rbi"]) + "RBI"}</span>
                </div>
            );
            si = si + 1;
        }
        return <div>{rows}</div>;
    }

    # ── game screen render ────────────────────────────────────────────────────
    def renderGameScreen -> any {
        halfLabel = ("Top" if topBottom == "top" else "Bot");
        isYouBatting = topBottom == "bottom";
        batter = getCurrentBatter(isYouBatting);
        fTeam = (oppTeam if isYouBatting else youTeam);
        pitcher = getCurrentPitcher(fTeam);

        logItems = gameLog.slice(0, 40).map(lambda l: str -> any {
            isSep = l[0] == "-";
            return <p key={l} style={"padding:2px 0;border-bottom:0.5px solid var(--color-border-tertiary);font-size:13px;line-height:1.7" + (";font-weight:500;color:var(--color-text-info)" if isSep else "")}>{l}</p>;
        });

        tabStyle = lambda active: bool -> str {
            base = "padding:4px 12px;border-radius:8px;font-size:13px;cursor:pointer;border:0.5px solid var(--color-border-tertiary);background:transparent;";
            if active {
                return base + "background:var(--color-background-primary);color:var(--color-text-primary);border-color:var(--color-border-secondary)";
            }
            return base + "color:var(--color-text-secondary)";
        };

        mgrContent = (
            renderSubTab() if mgrTab == "sub" else (
                renderPitchTab() if mgrTab == "pitch" else
                renderStatsTab()
            )
        );

        return (
            <div style="padding:12px 0;max-width:900px;margin:0 auto">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">

                    <div>
                        <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:12px 14px;margin-bottom:8px">
                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
                                <span style="font-weight:500">{halfLabel + " " + String(inning)}</span>
                                <span style="font-size:12px;color:var(--color-text-secondary)">{"Outs: " + String(outs)}</span>
                            </div>

                            <table style="width:100%;border-collapse:collapse;margin-bottom:6px">
                                <thead>
                                    <tr>
                                        <th style="padding:2px 8px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:left"></th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">1</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">2</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">3</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">4</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">5</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">6</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">7</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">8</th>
                                        <th style="padding:2px 6px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center">9</th>
                                        <th style="padding:2px 8px;font-size:11px;font-weight:400;color:var(--color-text-secondary);text-align:center;border-left:1px solid var(--color-border-tertiary)">R</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {buildScoreboardRow(youTeam, True)}
                                    {buildScoreboardRow(oppTeam, False)}
                                </tbody>
                            </table>

                            <div style="display:flex;justify-content:center;margin:6px 0">
                                {buildDiamondSvg()}
                            </div>

                            <div style="font-size:12px;color:var(--color-text-secondary);margin-bottom:8px">
                                <div>{"Batting: "}<strong>{batter["name"] + " (." + String(Math.round(batter["avg"] * 1000)) + ")"}</strong></div>
                                <div>{"Pitching: "}<strong>{pitcher["name"] + " (" + pitcher["hand"] + "HP, WHIP " + String(pitcher["whip"]) + ")"}</strong></div>
                            </div>

                            <div style="display:flex;gap:8px">
                                <button
                                    onClick={handleSimAtBat}
                                    style="background:#185fa5;color:#e6f1fb;border:0.5px solid #185fa5;border-radius:8px;padding:6px 14px;font-size:13px;cursor:pointer;flex:1"
                                >Simulate at-bat</button>
                                <button
                                    onClick={handleSimInning}
                                    style="background:transparent;border:0.5px solid var(--color-border-secondary);border-radius:8px;padding:6px 14px;font-size:13px;cursor:pointer;color:var(--color-text-primary)"
                                >Sim full inning</button>
                            </div>
                        </div>

                        <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:12px 14px">
                            <h3 style="font-size:15px;font-weight:500;margin-bottom:6px">Play log</h3>
                            <div style="max-height:200px;overflow-y:auto">{logItems}</div>
                        </div>
                    </div>

                    <div>
                        <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:12px 14px">
                            <div style="display:flex;gap:4px;margin-bottom:10px">
                                <button style={tabStyle(mgrTab == "sub")} onClick={lambda e: any -> None { mgrTab = "sub"; }}>Substitutions</button>
                                <button style={tabStyle(mgrTab == "pitch")} onClick={lambda e: any -> None { mgrTab = "pitch"; }}>Pitching</button>
                                <button style={tabStyle(mgrTab == "stats")} onClick={lambda e: any -> None { mgrTab = "stats"; }}>Stats</button>
                            </div>
                            {mgrContent}
                        </div>
                    </div>

                </div>
            </div>
        );
    }

    # ── game-over screen ──────────────────────────────────────────────────────
    def renderGameOverScreen -> any {
        won = youTeam["runs"] > oppTeam["runs"];
        resultMsg = ("Your team wins! Great managing." if won else "Your team loses. Better luck next time.");
        return (
            <div style="padding:12px 0;max-width:900px;margin:0 auto">
                <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:40px 24px;text-align:center">
                    <h2 style="font-size:18px;font-weight:500;margin-bottom:12px">Game Over</h2>
                    <p style="font-size:20px;font-weight:500;margin-bottom:8px">{youTeam["name"] + " " + String(youTeam["runs"]) + " – " + String(oppTeam["runs"]) + " " + oppTeam["name"]}</p>
                    <p style="font-size:15px;color:var(--color-text-secondary);margin-bottom:24px">{resultMsg}</p>
                    <button
                        onClick={handleNewGame}
                        style="background:#185fa5;color:#e6f1fb;border:0.5px solid #185fa5;border-radius:8px;padding:8px 24px;font-size:14px;cursor:pointer"
                    >New Game</button>
                </div>
            </div>
        );
    }

    # ── setup screen ──────────────────────────────────────────────────────────
    def renderSetupScreen -> any {
        return (
            <div style="padding:12px 0;max-width:900px;margin:0 auto">
                <div style="background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:12px;padding:24px">
                    <h2 style="font-size:18px;font-weight:500;margin-bottom:8px">Baseball Manager</h2>
                    <p style="font-size:13px;color:var(--color-text-secondary);margin-bottom:16px">Two randomly generated teams. Set your lineup, then manage the game inning by inning — substitutions, pitching changes, and strategy included.</p>
                    <button
                        onClick={handleNewGame}
                        style="background:#185fa5;color:#e6f1fb;border:0.5px solid #185fa5;border-radius:8px;padding:7px 18px;font-size:13px;cursor:pointer"
                    >Generate New Game</button>
                </div>
            </div>
        );
    }

    # ── root render ───────────────────────────────────────────────────────────
    return (
        <div>
            {renderSetupScreen() if screen == "setup" else None}
            {renderLineupScreen() if screen == "lineup" else None}
            {renderGameScreen() if screen == "game" else None}
            {renderGameOverScreen() if screen == "gameover" else None}
        </div>
    );
}
