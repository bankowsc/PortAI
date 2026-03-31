"""PortAI - Frontend Method Implementations."""

impl app.fetchFavorites -> None {
    try {
        result = root spawn get_user_favorites();
        if result.reports {
            fetched = result.reports[0]["favorites"];
            if fetched.length > 0 {
                favoriteTeamIds = fetched;
                window.localStorage.setItem("portai_favorites", JSON.stringify(fetched));
            }
        }
    } except e {
        # Keep existing favoriteTeamIds (may have been loaded from localStorage)
        favoriteTeamIds = favoriteTeamIds;
    }
}

impl app.fetchAISummary -> None {
    aiSummaryLoading = True;
    try {
        result = root spawn get_portal_summary(favorite_team_ids=favoriteTeamIds);
        if result.reports {
            aiSummaryTitle = result.reports[0]["title"];
            aiSummary = result.reports[0]["content"];
            window.localStorage.setItem("portai_ai_summary_title", result.reports[0]["title"]);
            window.localStorage.setItem("portai_ai_summary", result.reports[0]["content"]);
        }
    } except e {
        if not aiSummary {
            aiSummaryTitle = "Transfer Impact Overview";
            aiSummary = "Unable to generate AI summary at this time. Please try again by clicking Regenerate Summary.";
        }
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
            transactions = result.reports[0]["transfers"].slice().sort(lambda a: dict, b: dict -> int { return (b["rating"] - a["rating"]); });
            totalTransactions = result.reports[0]["total"];
            transactionsOffset = 100;
            window.localStorage.setItem("portai_transactions", JSON.stringify({
                "data": transactions,
                "total": result.reports[0]["total"],
                "offset": 100
            }));
        }
    } except e {
        if transactions.length == 0 {
            transactions = [];
            totalTransactions = 0;
        }
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
            transactions = transactions.concat(result.reports[0]["transfers"]).slice().sort(lambda a: dict, b: dict -> int { return (b["rating"] - a["rating"]); });
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
            window.localStorage.setItem("portai_portal_stats", JSON.stringify(result.reports[0]));
        }
    } except e {
        if not portalStatsData {
            portalStatsData = {};
        }
    }
}

impl app.fetchAIImpact(playerId: str) -> None {
    # Return cached result if available
    if aiImpactTexts[playerId] {
        return;
    }
    aiImpactLoading = aiImpactLoading.concat([playerId]);
    try {
        result = root spawn get_ai_impact(player_id=playerId);
        if result.reports {
            new_texts = Object.assign({}, aiImpactTexts);
            new_texts[playerId] = result.reports[0]["impact"];
            aiImpactTexts = new_texts;
            window.localStorage.setItem("portai_ai_impacts", JSON.stringify(new_texts));
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
        userEmail = loginEmail;
        window.localStorage.setItem("portai_email", loginEmail);
        try {
            await root spawn update_profile(email=loginEmail);
        } except e {
            console.warn("Failed to sync email to server");
        }
        loginEmail = "";
        loginPassword = "";
        currentPage = "home";
        window.history.pushState({}, "", "/");
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
        userEmail = loginEmail;
        window.localStorage.setItem("portai_email", loginEmail);
        try {
            await root spawn update_profile(email=loginEmail);
        } except e {
            console.warn("Failed to sync email to server");
        }
        loginEmail = "";
        loginPassword = "";
        loginConfirmPassword = "";
        currentPage = "home";
        window.history.pushState({}, "", "/");
    } else {
        loginError = result["error"] if result["error"] else "Signup failed. Please try again.";
    }
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;
    currentPage = "home";
    window.history.pushState({}, "", "/");
    favoriteTeamIds = default_favorite_team_ids;
    watchedPlayerIds = [];
    # Clear all cached data from localStorage
    cache_keys: list = [
        "portai_watchlist", "portai_display_name", "portai_avatar_icon",
        "portai_email", "portai_ai_summary_title", "portai_ai_summary",
        "portai_transactions", "portai_portal_stats", "portai_team_counts",
        "portai_favorites", "portai_profile_transactions",
        "portai_ai_impacts", "portai_crystal_ball"
    ];
    for key in cache_keys {
        window.localStorage.removeItem(key);
    }
    # Clear team analysis caches (prefixed keys)
    keys_to_remove: list = [];
    for i in range(window.localStorage.length) {
        k = window.localStorage.key(i);
        if k and k.startsWith("portai_team_analysis_") {
            keys_to_remove.push(k);
        }
    }
    for k in keys_to_remove {
        window.localStorage.removeItem(k);
    }
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
            window.localStorage.setItem("portai_crystal_ball", JSON.stringify(new_texts));
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

impl app.fetchProfileTransactions -> None {
    profileTransactionsLoading = True;
    try {
        result = root spawn get_transfers(
            offset=0,
            limit=200,
            search_query="",
            position_filter="all",
            status_filter="all"
        );
        if result.reports {
            profileTransactions = result.reports[0]["transfers"];
            window.localStorage.setItem("portai_profile_transactions", JSON.stringify(result.reports[0]["transfers"]));
        }
    } except e {
        if profileTransactions.length == 0 {
            profileTransactions = [];
        }
    }
    profileTransactionsLoading = False;
}

impl app.handleChatSend(message: str) -> None {
    # Build the full updated message list locally first,
    # then assign to chatMessages exactly once per stage
    # to avoid Jac reactive state being lost mid-sequence.

    # Stage 1: snapshot current messages + add user message
    with_user: list = chatMessages.concat([
        {"role": "user", "content": message}
    ]);

    # Assign once so user bubble renders immediately
    chatMessages = with_user;
    chatLoading = True;

    # Stage 2: call AI walker
    ai_response_text = "Unable to get a response right now. Please try again.";
    try {
        result = root spawn chat(question=message);
        if result.reports {
            ai_response_text = result.reports[0]["response"];
        }
    } except e {
        ai_response_text = "Unable to get a response right now. Please try again.";
    }

    # Stage 3: build final list with AI response appended
    final_messages: list = with_user.concat([
        {"role": "assistant", "content": ai_response_text}
    ]);

    # Single assignment — both user + AI messages now in state
    chatMessages = final_messages;
    chatLoading = False;

    # Stage 4: update conversation history
    now = Date();
    time_str = String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0");
    date_str = now.toLocaleDateString("en-US", {"month": "short", "day": "numeric"});
    timestamp_str = date_str + " " + time_str;

    title_raw = message;
    conv_title = (title_raw.slice(0, 40) + "...") if title_raw.length > 40 else title_raw;

    is_new_conversation = activeConversationId == "";

    if is_new_conversation {
        new_id = "conv_" + String(Date.now());
        new_conv = {
            "id": new_id,
            "title": conv_title,
            "timestamp": timestamp_str,
            "messages": final_messages
        };
        conversations = [new_conv].concat(conversations);
        activeConversationId = new_id;
    } else {
        updated_convs: list = [];
        for conv in conversations {
            if conv["id"] == activeConversationId {
                updated_convs.push({
                    "id": conv["id"],
                    "title": conv["title"],
                    "timestamp": timestamp_str,
                    "messages": final_messages
                });
            } else {
                updated_convs.push(conv);
            }
        }
        conversations = updated_convs;
    }
}

impl app.fetchUserProfile -> None {
    try {
        result = root spawn get_user_profile();
        if result.reports.length > 0 {
            data = result.reports[0];
            if data["display_name"] {
                profileDisplayName = data["display_name"];
                window.localStorage.setItem("portai_display_name", data["display_name"]);
            }
            if data["avatar_icon"] {
                profileAvatarIcon = data["avatar_icon"];
                window.localStorage.setItem("portai_avatar_icon", data["avatar_icon"]);
            }
            if data["email"] {
                userEmail = data["email"];
                window.localStorage.setItem("portai_email", data["email"]);
            }
        }
    } except e {
        # Keep existing values (may have been loaded from localStorage)
        profileDisplayName = profileDisplayName;
    }
}

impl app.saveUserProfile(profileData: any) -> None {
    if profileData["displayName"] {
        profileDisplayName = profileData["displayName"];
        window.localStorage.setItem("portai_display_name", profileData["displayName"]);
    }
    if profileData["avatarIcon"] {
        profileAvatarIcon = profileData["avatarIcon"];
        window.localStorage.setItem("portai_avatar_icon", profileData["avatarIcon"]);
    }
    try {
        result = await root spawn update_profile(
            display_name=profileData["displayName"],
            avatar_icon=profileData["avatarIcon"]
        );
        if result.reports.length > 0 {
            data = result.reports[0];
            profileDisplayName = data["display_name"];
            profileAvatarIcon = data["avatar_icon"];
        }
    } except e {
        console.warn("Failed to sync profile to server");
    }
}

impl app.fetchTeamStats -> None {
    try {
        result = root spawn get_team_stats();
        if result.reports {
            teamCounts = result.reports[0]["teamCounts"];
            window.localStorage.setItem("portai_team_counts", JSON.stringify(result.reports[0]["teamCounts"]));
        }
    } except e {
        if Object.keys(teamCounts).length == 0 {
            teamCounts = {};
        }
    }
}

impl app.fetchTeamTransfers(teamName: str) -> None {
    teamTransfersLoading = True;
    teamTransfers = [];
    teamTransfersIncoming = [];
    teamTransfersOutgoing = [];
    try {
        result = root spawn get_team_transfers(team_name=teamName);
        if result.reports {
            teamTransfersIncoming = result.reports[0]["incoming"];
            teamTransfersOutgoing = result.reports[0]["outgoing"];
            teamTransfers = teamTransfersIncoming.concat(teamTransfersOutgoing);
        }
    } except e {
        teamTransfers = [];
    }
    teamTransfersLoading = False;
}

impl app.fetchTeamAnalysis(teamName: str) -> None {
    # Check localStorage cache for this team's analysis
    cache_key = "portai_team_analysis_" + teamName;
    cached = window.localStorage.getItem(cache_key);
    if cached {
        teamAnalysis = cached;
        return;
    }
    teamAnalysisLoading = True;
    teamAnalysis = "";
    try {
        result = root spawn get_team_analysis(team_info=teamName);
        if result.reports {
            data = result.reports[0];
            teamAnalysis = (
                "Strategy: " + data["portal_strategy"] + " " +
                "Key Additions: " + data["key_additions"] + " " +
                "Key Losses: " + data["key_losses"] + " " +
                "Outlook: " + data["outlook"] + " " +
                "Risk Level: " + data["risk_level"]
            );
            window.localStorage.setItem(cache_key, teamAnalysis);
        }
    } except e {
        teamAnalysis = "Unable to generate analysis at this time.";
    }
    teamAnalysisLoading = False;
}

impl app.fetchPlayerDetail(playerId: str) -> None {
    playerDetailLoading = True;
    playerDetailData = {};
    try {
        result = root spawn get_player_detail(player_id=playerId);
        if result.reports {
            playerDetailData = result.reports[0];
        }
    } except e {
        playerDetailData = {"error": "Failed to load player"};
    }
    playerDetailLoading = False;
}

impl app.fetchWatchlist -> None {
    try {
        result = root spawn get_user_watchlist();
        if result.reports {
            watchedPlayerIds = result.reports[0]["watched_player_ids"];
            window.localStorage.setItem("portai_watchlist", JSON.stringify(watchedPlayerIds));
        }
    } except e {
        # Keep existing watchedPlayerIds (may have been loaded from localStorage)
        watchedPlayerIds = watchedPlayerIds;
    }
}

impl app.handleToggleWatch(playerId: str) -> None {
    new_watchlist: list = [];
    if watchedPlayerIds.includes(playerId) {
        new_watchlist = watchedPlayerIds.filter(
            lambda id: str -> bool { return id != playerId; }
        );
    } else {
        new_watchlist = watchedPlayerIds.concat([playerId]);
    }
    watchedPlayerIds = new_watchlist;
    window.localStorage.setItem("portai_watchlist", JSON.stringify(new_watchlist));
    try {
        await root spawn update_watchlist(new_watchlist=new_watchlist);
    } except e {
        # localStorage already saved, server sync is best-effort
        console.warn("Failed to sync watchlist to server");
    }
}

