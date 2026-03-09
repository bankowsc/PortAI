"""PortAI - Frontend Method Implementations."""

impl app.fetchFavorites -> None {
    result = root spawn get_user_favorites();
    if result.reports {
        favoriteTeamIds = result.reports[0]["favorites"];
    }
}

impl app.fetchAISummary -> None {
    aiSummaryLoading = True;
    try {
        result = root spawn get_portal_summary(favorite_team_ids=favoriteTeamIds);
        if result.reports {
            aiSummaryTitle = result.reports[0]["title"];
            aiSummary = result.reports[0]["content"];
        }
    } except e {
        aiSummaryTitle = "Transfer Impact Overview";
        aiSummary = "Unable to generate AI summary at this time. Please try again by clicking Regenerate Summary.";
    }
    aiSummaryLoading = False;
}

impl app.fetchTransactions -> None {
    transactionsLoading = True;
    try {
        result = root spawn get_transfers(
            offset=0,
            limit=100,
            search_query="",
            position_filter="all",
            status_filter="all"
        );
        if result.reports {
            transactions = result.reports[0]["transfers"];
            totalTransactions = result.reports[0]["total"];
            transactionsOffset = 100;
        }
    } except e {
        transactions = [];
        totalTransactions = 0;
    }
    transactionsLoading = False;
}

impl app.loadMoreTransactions -> None {
    transactionsLoading = True;
    try {
        result = root spawn get_transfers(
            offset=transactionsOffset,
            limit=100,
            search_query="",
            position_filter="all",
            status_filter="all"
        );
        if result.reports {
            transactions = transactions.concat(result.reports[0]["transfers"]);
            totalTransactions = result.reports[0]["total"];
            transactionsOffset = transactionsOffset + 100;
        }
    } except e {
        console.error("Failed to load more transactions");
    }
    transactionsLoading = False;
}

impl app.fetchPlayers -> None {
    playersLoading = True;
    try {
        result = root spawn search_players(
            query=playerSearchQuery,
            offset=0,
            limit=50,
            position_filter=playerPositionFilter
        );
        if result.reports {
            players = result.reports[0]["players"];
            totalPlayers = result.reports[0]["total"];
            playersOffset = 50;
        }
    } except e {
        players = [];
        totalPlayers = 0;
    }
    playersLoading = False;
}

impl app.loadMorePlayers -> None {
    playersLoading = True;
    try {
        result = root spawn search_players(
            query=playerSearchQuery,
            offset=playersOffset,
            limit=50,
            position_filter=playerPositionFilter
        );
        if result.reports {
            players = players.concat(result.reports[0]["players"]);
            totalPlayers = result.reports[0]["total"];
            playersOffset = playersOffset + 50;
        }
    } except e {
        console.error("Failed to load more players");
    }
    playersLoading = False;
}

impl app.fetchPortalStats -> None {
    try {
        result = root spawn get_portal_stats();
        if result.reports {
            portalStatsData = result.reports[0];
        }
    } except e {
        portalStatsData = {};
    }
}

impl app.fetchAIImpact(playerId: str) -> None {
    aiImpactLoading = aiImpactLoading.concat([playerId]);
    try {
        result = root spawn get_ai_impact(player_id=playerId);
        if result.reports {
            new_texts = Object.assign({}, aiImpactTexts);
            new_texts[playerId] = result.reports[0]["impact"];
            aiImpactTexts = new_texts;
        }
    } except e {
        new_texts = Object.assign({}, aiImpactTexts);
        new_texts[playerId] = "Unable to generate AI impact assessment.";
        aiImpactTexts = new_texts;
    }
    aiImpactLoading = aiImpactLoading.filter(
        lambda id: str -> bool { return id != playerId; }
    );
}

impl app.handleLogin -> None {
    loginError = "";
    if not loginEmail.trim() or not loginPassword {
        loginError = "Please fill in all fields";
        return;
    }
    loginLoading = True;
    success = await jacLogin(loginEmail, loginPassword);
    loginLoading = False;
    if success {
        isLoggedIn = True;
        loginEmail = "";
        loginPassword = "";
        currentPage = "home";
    } else {
        loginError = "Invalid email or password";
    }
}

impl app.handleSignup -> None {
    loginError = "";
    if not loginEmail.trim() or not loginPassword {
        loginError = "Please fill in all fields";
        return;
    }
    if loginPassword != loginConfirmPassword {
        loginError = "Passwords do not match";
        return;
    }
    if loginPassword.length < 4 {
        loginError = "Password must be at least 4 characters";
        return;
    }
    loginLoading = True;
    result = await jacSignup(loginEmail, loginPassword);
    loginLoading = False;
    if result["success"] {
        isLoggedIn = True;
        loginEmail = "";
        loginPassword = "";
        loginConfirmPassword = "";
        currentPage = "home";
    } else {
        loginError = result["error"] if result["error"] else "Signup failed. Please try again.";
    }
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;
    currentPage = "home";
    favoriteTeamIds = default_favorite_team_ids;
}

impl app.handleSubmit(e: any) -> None {
    e.preventDefault();
    if isLoginMode {
        await handleLogin();
    } else {
        await handleSignup();
    }
}

impl app.handleToggleFavorite(teamId: str) -> None {
    new_favorites: list = [];
    if favoriteTeamIds.includes(teamId) {
        new_favorites = favoriteTeamIds.filter(
            lambda id: str -> bool { return id != teamId; }
        );
    } else {
        new_favorites = favoriteTeamIds.concat([teamId]);
    }
    favoriteTeamIds = new_favorites;
    await root spawn update_favorites(new_favorites=new_favorites);
}

impl app.fetchTxnPageData -> None {
    txnPageLoading = True;
    try {
        # Build team filter string
        effective_team_filter = txnTeamFilter;
        if txnFavoritesOnly and favoriteTeamIds.length > 0 {
            # Build pipe-separated list of favorite team names
            fav_names: list = [];
            for fid in favoriteTeamIds {
                for t in mock_teams {
                    if t["id"] == fid {
                        fav_names.push(t["name"]);
                    }
                }
            }
            effective_team_filter = fav_names.join("|");
        }
        result = root spawn get_transfers(
            offset=0,
            limit=100,
            search_query="",
            position_filter=txnPositionFilter,
            status_filter=txnStatusFilter,
            team_filter=effective_team_filter
        );
        if result.reports {
            txnPageData = result.reports[0]["transfers"];
            txnPageTotal = result.reports[0]["total"];
            txnPageOffset = 100;
        }
    } except e {
        txnPageData = [];
        txnPageTotal = 0;
    }
    txnPageLoading = False;
}

impl app.loadMoreTxnPageData -> None {
    txnPageLoading = True;
    try {
        effective_team_filter = txnTeamFilter;
        if txnFavoritesOnly and favoriteTeamIds.length > 0 {
            fav_names: list = [];
            for fid in favoriteTeamIds {
                for t in mock_teams {
                    if t["id"] == fid {
                        fav_names.push(t["name"]);
                    }
                }
            }
            effective_team_filter = fav_names.join("|");
        }
        result = root spawn get_transfers(
            offset=txnPageOffset,
            limit=100,
            search_query="",
            position_filter=txnPositionFilter,
            status_filter=txnStatusFilter,
            team_filter=effective_team_filter
        );
        if result.reports {
            txnPageData = txnPageData.concat(result.reports[0]["transfers"]);
            txnPageTotal = result.reports[0]["total"];
            txnPageOffset = txnPageOffset + 100;
        }
    } except e {
        console.error("Failed to load more transactions");
    }
    txnPageLoading = False;
}

impl app.handleCrystalBall(playerId: str) -> None {
    # Don't re-fetch if already have a prediction
    if crystalBallTexts[playerId] {
        return;
    }
    crystalBallLoading = crystalBallLoading.concat([playerId]);
    try {
        result = root spawn predict_destination(player_id=playerId);
        if result.reports {
            new_texts = Object.assign({}, crystalBallTexts);
            report_data = result.reports[0];
            prediction_text = "Predicted Destination: " + report_data["prediction"] + " (Confidence: " + report_data["confidence"] + "). " + report_data["reasoning"];
            new_texts[playerId] = prediction_text;
            crystalBallTexts = new_texts;
        }
    } except e {
        new_texts = Object.assign({}, crystalBallTexts);
        new_texts[playerId] = "Unable to generate prediction at this time.";
        crystalBallTexts = new_texts;
    }
    crystalBallLoading = crystalBallLoading.filter(
        lambda id: str -> bool { return id != playerId; }
    );
}
