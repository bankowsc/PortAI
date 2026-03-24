"""PortAI - User Profile Page."""

import from ..data.mock_data {
    mock_teams, default_favorite_team_ids
}

def:pub ProfilePage(
    onNavigate: any,
    onLogout: any,
    favoriteTeamIds: list,
    onToggleFavorite: any,
    userEmail: str,
    userSignupDate: any,
    profileTransactions: list,
    profileTransactionsLoading: bool,
    portalStatsData: any,
    savedDisplayName: str,
    savedAvatarIcon: str,
    onSaveProfile: any,
    watchedPlayerIds: list,
    onToggleWatch: any,
    userCredits: int,
    onIncrementCredits: any,
    creditsLoading: bool,
) -> any {

    has activeTab: str = "overview",
        positionFilter: str = "All",
        editingName: bool = False,
        editNameValue: str = "",
        showIconPicker: bool = False,
        selectedIcon: str = "default",
        displayName: str = "";

    can with [savedDisplayName, savedAvatarIcon, userEmail] entry {
        atSymbol = "@";
        if savedDisplayName {
            displayName = savedDisplayName;
        } else {
            displayName = (userEmail.split(atSymbol)[0] if userEmail.includes(atSymbol) else (userEmail if userEmail else "Fan"));
        }
        if savedAvatarIcon and selectedIcon == "default" {
            selectedIcon = savedAvatarIcon;
        }
    }

    atSymbol = "@";
    initials = displayName.substring(0, 2).toUpperCase();

    avatarIcons = ["🏈", "🦅", "🐻", "🐯", "🦁", "🐺", "⚡", "🔥", "🏆", "⭐"];
    currentIcon = (selectedIcon if selectedIcon != "default" else "");

    favTeams = [team for team in mock_teams if favoriteTeamIds.includes(team["id"])];

    totalTransfers = (portalStatsData["totalTransfers"] if portalStatsData and portalStatsData["totalTransfers"] else 0);
    topPositions = (portalStatsData["topPositions"] if portalStatsData and portalStatsData["topPositions"] else []);
    topConferences = (portalStatsData["topConferences"] if portalStatsData and portalStatsData["topConferences"] else []);

    allPositions = ["All", "ATH", "CB", "DL", "Edge", "IOL", "K", "LB", "LS", "OT", "P", "QB", "RB", "S", "TE", "WR"];

    filteredTransactions = [t for t in profileTransactions if positionFilter == "All" or t["position"] == positionFilter];
    fourStarPlus = [t for t in filteredTransactions if t["starRating"] >= 4].length;
    watchlistItems = [t for t in filteredTransactions if watchedPlayerIds.includes(t["id"])];

    posMaxVal = (topPositions[0]["value"] if topPositions.length > 0 and topPositions[0]["value"] else 1);
    confMaxVal = (topConferences[0]["transfers"] if topConferences.length > 0 and topConferences[0]["transfers"] else 1);

    def handleTabChange(tab: str) -> None {
        activeTab = tab;
    }

    def handlePositionFilter(pos: str) -> None {
        positionFilter = pos;
    }

    def handleStartEditName -> None {
        editNameValue = displayName;
        editingName = True;
    }

    def handleEditNameChange(e: any) -> None {
        editNameValue = e.target.value;
    }

    def handleSaveName -> None {
        if editNameValue.trim() {
            displayName = editNameValue.trim();
            onSaveProfile({"displayName": editNameValue.trim(), "avatarIcon": (selectedIcon if selectedIcon != "default" else "")});
        }
        editingName = False;
    }

    def handleCancelEdit -> None {
        editingName = False;
    }

    def handleEditNameKeyDown(e: any) -> None {
        if e.key == "Enter" {
            handleSaveName();
        }
        if e.key == "Escape" {
            handleCancelEdit();
        }
    }

    def handleToggleIconPicker -> None {
        showIconPicker = not showIconPicker;
    }

    def handleSelectIcon(icon: str) -> None {
        selectedIcon = icon;
        showIconPicker = False;
        onSaveProfile({"displayName": displayName, "avatarIcon": (icon if icon != "default" else "")});
    }

    return
        <div className="profile-page">

            <div className="profile-body">

                <div className="profile-filters-sidebar">
                    <div className="profile-filter-section">
                        <div className="profile-filter-heading">Filters</div>
                        <div className="profile-filter-group">
                            <label className="profile-filter-label">Position</label>
                            <div className="profile-position-pills">
                                {[
                                    <button
                                        key={pos}
                                        className={("profile-pos-pill active" if pos == positionFilter else "profile-pos-pill")}
                                        onClick={lambda _: any -> None { handlePositionFilter(pos); }}
                                    >{pos}</button>
                                    for pos in allPositions
                                ]}
                            </div>
                        </div>
                    </div>

                    <div className="profile-filter-section">
                        <div className="profile-filter-heading">My Teams</div>
                        {(
                            <div className="profile-fav-teams-list">
                                {[
                                    <div key={team["id"]} className="profile-fav-team-row">
                                        <div className="profile-fav-team-badge">{team["name"].split(" ")[0].substring(0, 2).toUpperCase()}</div>
                                        <div className="profile-fav-team-info">
                                            <div className="profile-fav-team-name">{team["name"]}</div>
                                            <div className="profile-fav-team-conf">{team["conference"]}</div>
                                        </div>
                                        <button
                                            className="profile-unfav-btn"
                                            onClick={lambda _: any -> None { onToggleFavorite(team["id"]); }}
                                        >x</button>
                                    </div>
                                    for team in favTeams
                                ]}
                            </div>
                        if favTeams.length > 0 else
                            <div className="profile-no-favs">
                                <p>No favorite teams yet.</p>
                                <button
                                    className="btn btn-outline btn-sm"
                                    onClick={lambda _: any -> None { onNavigate("teams"); }}
                                >Browse Teams</button>
                            </div>
                        )}
                    </div>
                </div>

                <div className="profile-main">

                    <div className="profile-hero-card">
                        <div className="profile-hero-bg"></div>
                        <div className="profile-hero-content">

                            <div className="profile-avatar-wrap">
                                <div
                                    className="profile-avatar profile-avatar-clickable"
                                    onClick={lambda _: any -> None { handleToggleIconPicker(); }}
                                    title="Change avatar"
                                >
                                    {(currentIcon if currentIcon else initials)}
                                </div>
                                <div className="profile-avatar-ring"></div>
                                <button
                                    className="profile-avatar-edit-btn"
                                    onClick={lambda _: any -> None { handleToggleIconPicker(); }}
                                    title="Change avatar"
                                >✏️</button>

                                {(
                                    <div className="profile-icon-picker">
                                        <div className="profile-icon-picker-title">Choose Avatar</div>
                                        <div className="profile-icon-picker-grid">
                                            {[
                                                <button
                                                    key={icon}
                                                    className={("profile-icon-option selected" if icon == selectedIcon else "profile-icon-option")}
                                                    onClick={lambda _: any -> None { handleSelectIcon(icon); }}
                                                >{icon}</button>
                                                for icon in avatarIcons
                                            ]}
                                        </div>
                                        <button
                                            className="profile-icon-picker-close"
                                            onClick={lambda _: any -> None { handleToggleIconPicker(); }}
                                        >Done</button>
                                    </div>
                                if showIconPicker else
                                    <span></span>
                                )}
                            </div>

                            <div className="profile-hero-info">
                                {(
                                    <div className="profile-name-edit-row">
                                        <input
                                            className="profile-name-input"
                                            type="text"
                                            value={editNameValue}
                                            onChange={handleEditNameChange}
                                            onKeyDown={handleEditNameKeyDown}
                                            autoFocus={True}
                                        />
                                        <button className="profile-name-save-btn" onClick={lambda _: any -> None { handleSaveName(); }}>Save</button>
                                        <button className="profile-name-cancel-btn" onClick={lambda _: any -> None { handleCancelEdit(); }}>Cancel</button>
                                    </div>
                                if editingName else
                                    <div className="profile-name-display-row">
                                        <h1 className="profile-display-name">{displayName}</h1>
                                        <button
                                            className="profile-name-edit-btn"
                                            onClick={lambda _: any -> None { handleStartEditName(); }}
                                            title="Edit display name"
                                        >✏️</button>
                                    </div>
                                )}
                                <div className="profile-email">{userEmail}</div>
                                <div className="profile-meta-pills">
                                    <span className="profile-meta-pill">{String(favoriteTeamIds.length) + " Favorite Teams"}</span>
                                    <span className="profile-meta-pill">{String(watchedPlayerIds.length) + " Watching"}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="profile-tabs-bar">
                        <button
                            className={("profile-tab active" if activeTab == "overview" else "profile-tab")}
                            onClick={lambda _: any -> None { handleTabChange("overview"); }}
                        >Overview</button>
                        <button
                            className={("profile-tab active" if activeTab == "watchlist" else "profile-tab")}
                            onClick={lambda _: any -> None { handleTabChange("watchlist"); }}
                        >
                            {"My Watchlist"}
                            {(<span className="tab-badge">{String(watchedPlayerIds.length)}</span> if watchedPlayerIds.length > 0 else <span></span>)}
                        </button>
                        <button
                            className={("profile-tab active" if activeTab == "teams" else "profile-tab")}
                            onClick={lambda _: any -> None { handleTabChange("teams"); }}
                        >My Teams</button>
                        <button
                            className={("profile-tab active" if activeTab == "settings" else "profile-tab")}
                            onClick={lambda _: any -> None { handleTabChange("settings"); }}
                        >Settings</button>
                    </div>

                    {(
                        <div className="profile-tab-content">
                            <div className="profile-snapshot-grid">
                                <div className="profile-snapshot-card">
                                    <div className="snapshot-card-label">Total Tracked Transfers</div>
                                    <div className="snapshot-card-value blue">{String(totalTransfers)}</div>
                                    <div className="snapshot-card-sub">across all programs</div>
                                </div>
                                <div className="profile-snapshot-card">
                                    <div className="snapshot-card-label">Players Watching</div>
                                    <div className="snapshot-card-value green">{String(watchedPlayerIds.length)}</div>
                                    <div className="snapshot-card-sub">on your watchlist</div>
                                </div>
                                <div className="profile-snapshot-card">
                                    <div className="snapshot-card-label">Favorite Teams</div>
                                    <div className="snapshot-card-value gold">{String(favoriteTeamIds.length)}</div>
                                    <div className="snapshot-card-sub">teams followed</div>
                                </div>
                                <div className="profile-snapshot-card">
                                    <div className="snapshot-card-label">ACCOUNT CREDITS</div>
                                    <div className="snapshot-card-value red">{String(userCredits)}</div>
                                    <div className="snapshot-card-sub">increments every login day</div>
                                    <div className="credits-section">
                                    <button
                                        className="btn btn-primary btn-sm"
                                        onClick={onIncrementCredits}
                                        disabled={creditsLoading}
                                    >
                                        + Claim Credits
                                    </button>
                                    </div>
                                </div>
                            </div>

                            <div className="profile-stats-row">
                                <div className="profile-stats-card">
                                    <div className="profile-stats-card-title">Top Positions in Portal</div>
                                    <div className="profile-bar-list">
                                        {(
                                            <div className="profile-bar-rows-wrap">
                                                {[
                                                    <div key={pos["name"]} className="profile-bar-row">
                                                        <span className="profile-bar-label">{pos["name"]}</span>
                                                        <div className="profile-bar-track">
                                                            <div
                                                                className="profile-bar-fill"
                                                                style={({"width": String(Math.round((pos["value"] / posMaxVal) * 100)) + "%"})}
                                                            ></div>
                                                        </div>
                                                        <span className="profile-bar-count">{String(pos["value"])}</span>
                                                    </div>
                                                    for pos in topPositions
                                                ]}
                                            </div>
                                        if topPositions.length > 0 else
                                            <div className="profile-empty-state">Loading stats...</div>
                                        )}
                                    </div>
                                </div>

                                <div className="profile-stats-card">
                                    <div className="profile-stats-card-title">Most Active Conferences</div>
                                    <div className="profile-bar-list">
                                        {(
                                            <div className="profile-bar-rows-wrap">
                                                {[
                                                    <div key={conf["name"]} className="profile-bar-row">
                                                        <span className="profile-bar-label">{conf["name"]}</span>
                                                        <div className="profile-bar-track">
                                                            <div
                                                                className="profile-bar-fill conf"
                                                                style={({"width": String(Math.round((conf["transfers"] / confMaxVal) * 100)) + "%"})}
                                                            ></div>
                                                        </div>
                                                        <span className="profile-bar-count">{String(conf["transfers"])}</span>
                                                    </div>
                                                    for conf in topConferences
                                                ]}
                                            </div>
                                        if topConferences.length > 0 else
                                            <div className="profile-empty-state">Loading stats...</div>
                                        )}
                                    </div>
                                </div>
                            </div>

                            <div className="profile-activity-card">
                                <div className="profile-activity-header">
                                    <span className="profile-activity-title">Recent Portal Activity</span>
                                    <button
                                        className="profile-view-all-btn"
                                        onClick={lambda _: any -> None { onNavigate("transactions"); }}
                                    >View All</button>
                                </div>
                                {(
                                    <div className="profile-loading-state">
                                        <div className="profile-spinner"></div>
                                        <span>Loading transactions...</span>
                                    </div>
                                if profileTransactionsLoading else (
                                    <div className="profile-activity-list">
                                        {[
                                            <div key={txn["id"]} className="profile-activity-row">
                                                <div className="profile-activity-left">
                                                    <div className="profile-activity-avatar">{txn["playerName"].split(" ").map(lambda w: str -> str { return w.substring(0, 1); }).join("")}</div>
                                                    <div className="profile-activity-info">
                                                        <div className="profile-activity-name">{txn["playerName"]}</div>
                                                        <div className="profile-activity-route">
                                                            <span className="activity-from">{txn["fromTeam"]}</span>
                                                            <span className="activity-arrow"> to </span>
                                                            <span className="activity-to">{txn["toTeam"]}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div className="profile-activity-right">
                                                    <span className="profile-pos-badge">{txn["position"]}</span>
                                                    <button
                                                        className={("profile-watch-btn watching" if watchedPlayerIds.includes(txn["id"]) else "profile-watch-btn")}
                                                        onClick={lambda _: any -> None { onToggleWatch(txn["id"]); }}
                                                    >{("Watching" if watchedPlayerIds.includes(txn["id"]) else "+ Watch")}</button>
                                                </div>
                                            </div>
                                            for txn in filteredTransactions.slice(0, 8)
                                        ]}
                                    </div>
                                if filteredTransactions.length > 0 else
                                    <div className="profile-empty-state">
                                        <p>No transactions match your current filters.</p>
                                    </div>
                                ))}
                            </div>
                        </div>
                    if activeTab == "overview" else (
                        <div className="profile-tab-content">
                            {(
                                <div className="profile-watchlist-grid">
                                    {[
                                        <div key={txn["id"]} className="profile-watchlist-card">
                                            <div className="watchlist-card-top">
                                                <div className="watchlist-avatar">{txn["playerName"].split(" ").map(lambda w: str -> str { return w.substring(0, 1); }).join("")}</div>
                                            </div>
                                            <div className="watchlist-name">{txn["playerName"]}</div>
                                            <div className="watchlist-pos-status">
                                                <span className="profile-pos-badge">{txn["position"]}</span>
                                                <span className="watchlist-status">{txn["status"]}</span>
                                            </div>
                                            <div className="watchlist-route">
                                                <span>{txn["fromTeam"]}</span>
                                                <span className="activity-arrow"> to </span>
                                                <span>{txn["toTeam"]}</span>
                                            </div>
                                            <button
                                                className="profile-unwatch-btn"
                                                onClick={lambda _: any -> None { onToggleWatch(txn["id"]); }}
                                            >Remove from Watchlist</button>
                                        </div>
                                        for txn in watchlistItems
                                    ]}
                                </div>
                            if watchlistItems.length > 0 else
                                <div className="profile-empty-tab">
                                    <h3>Your watchlist is empty</h3>
                                    <p>Add players to your watchlist from the Overview tab or the Transactions page.</p>
                                    <button
                                        className="btn btn-primary"
                                        onClick={lambda _: any -> None { onNavigate("transactions"); }}
                                    >Browse Transactions</button>
                                </div>
                            )}
                        </div>
                    if activeTab == "watchlist" else (
                        <div className="profile-tab-content">
                            {(
                                <div className="profile-my-teams-grid">
                                    {[
                                        <div key={team["id"]} className="profile-team-detail-card">
                                            <div className="ptdc-header">
                                                <div className="ptdc-badge">{team["name"].split(" ")[0].substring(0, 2).toUpperCase()}</div>
                                                <div className="ptdc-title-block">
                                                    <div className="ptdc-name">{team["name"]}</div>
                                                    <div className="ptdc-conf">{team["conference"]}</div>
                                                </div>
                                                <button
                                                    className="ptdc-remove-btn"
                                                    onClick={lambda _: any -> None { onToggleFavorite(team["id"]); }}
                                                >Remove</button>
                                            </div>
                                            <div className="ptdc-stats">
                                                <div className="ptdc-stat">
                                                    <span className="ptdc-stat-val">{String(team["incomingCount"])}</span>
                                                    <span className="ptdc-stat-label">In</span>
                                                </div>
                                                <div className="ptdc-stat-divider"></div>
                                                <div className="ptdc-stat">
                                                    <span className="ptdc-stat-val">{String(team["outgoingCount"])}</span>
                                                    <span className="ptdc-stat-label">Out</span>
                                                </div>
                                                <div className="ptdc-stat-divider"></div>
                                                <div className="ptdc-stat">
                                                    <span className="ptdc-stat-val">{String(team["portalActivityScore"])}</span>
                                                    <span className="ptdc-stat-label">Score</span>
                                                </div>
                                            </div>
                                            <button
                                                className="ptdc-view-btn"
                                                onClick={lambda _: any -> None { onNavigate("transactions"); }}
                                            >View Transactions</button>
                                        </div>
                                        for team in favTeams
                                    ]}
                                </div>
                            if favTeams.length > 0 else
                                <div className="profile-empty-tab">
                                    <h3>No favorite teams yet</h3>
                                    <p>Follow teams to track their portal activity here.</p>
                                    <button
                                        className="btn btn-primary"
                                        onClick={lambda _: any -> None { onNavigate("teams"); }}
                                    >Browse Teams</button>
                                </div>
                            )}
                        </div>
                    if activeTab == "teams" else
                        <div className="profile-tab-content">
                            <div className="profile-settings-card">

                                <div className="profile-settings-section">
                                    <div className="profile-settings-heading">Account</div>
                                    <div className="profile-settings-row">
                                        <div className="profile-settings-label">Email</div>
                                        <div className="profile-settings-value">{userEmail}</div>
                                    </div>
                                    <div className="profile-settings-row">
                                        <div className="profile-settings-label">Display Name</div>
                                        <div className="profile-settings-value-row">
                                            <div className="profile-settings-value">{displayName}</div>
                                            <button
                                                className="profile-settings-edit-btn"
                                                onClick={lambda _: any -> None { handleTabChange("overview"); handleStartEditName(); }}
                                            >Edit</button>
                                        </div>
                                    </div>
                                    <div className="profile-settings-row">
                                        <div className="profile-settings-label">Member Since</div>
                                        <div className="profile-settings-value">{String(userSignupDate)}</div>
                                    </div>
                                </div>

                                <div className="profile-settings-section">
                                    <div className="profile-settings-heading">Danger Zone</div>
                                    <button className="profile-logout-danger-btn" onClick={onLogout}>
                                        Sign Out of PortAI
                                    </button>
                                </div>

                            </div>
                        </div>
                    )))}

                </div>

            </div>
        </div>;
}
