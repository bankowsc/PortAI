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
