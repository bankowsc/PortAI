"""PortAI - Frontend Entry Point."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import "./styles.css";

import from .components.Navigation { Navigation }
import from .components.Sidebar { Sidebar }
import from .components.Footer { Footer }
import from .components.AuthForm { AuthForm }
import from .pages.HomePage { HomePage }
import from .pages.TeamsPage { TeamsPage }
import from .pages.PlayersPage { PlayersPage }
import from .pages.TransactionsPage { TransactionsPage }
import from .pages.FavoritesPage { FavoritesPage }
import from .pages.ProfilePage { ProfilePage }
import from .pages.AnalyticsPage { AnalyticsPage }
import from .pages.ChatPage { ChatPage }
import from .data.mock_data { default_favorite_team_ids, mock_teams }
import from .pages.TeamDetailPage { TeamDetailPage }
import from .pages.PlayerDetailPage { PlayerDetailPage }

sv import from main {
    update_favorites, get_user_favorites, get_portal_summary, update_profile, get_user_profile, 
    get_transfers, search_players, get_player_by_id, get_ai_impact, get_portal_stats,
    predict_destination, chat, get_team_stats, get_team_analysis, get_team_transfers, get_player_detail,
    update_watchlist, get_user_watchlist, claim_daily_credits
}

# --- URL <-> Page Sync Helpers ---
def pageToPath(page: str) -> str {
    if page == "home" { return "/"; }
    if page.startsWith("team-detail:") { return "/teams/" + page.split(":")[1]; }
    if page.startsWith("player-detail:") { return "/players/" + page.split(":")[1]; }
    return "/" + page;
}

def pathToPage(path: str) -> str {
    if path == "/" or path == "" { return "home"; }
    # Remove leading slash
    cleaned = path;
    if cleaned.startsWith("/") { cleaned = cleaned.substring(1); }
    # Remove trailing slash
    if cleaned.endsWith("/") { cleaned = cleaned.substring(0, cleaned.length - 1); }
    # Handle /teams/123 -> team-detail:123
    if cleaned.startsWith("teams/") {
        parts = cleaned.split("/");
        if parts.length >= 2 and parts[1] { return "team-detail:" + parts[1]; }
        return "teams";
    }
    # Handle /players/123 -> player-detail:123
    if cleaned.startsWith("players/") {
        parts = cleaned.split("/");
        if parts.length >= 2 and parts[1] { return "player-detail:" + parts[1]; }
        return "players";
    }
    return cleaned;
}

def:pub app -> JsxElement {
    has currentPage: str = "home",
        isLoggedIn: bool = False,
        checkingAuth: bool = True,
        sidebarCollapsed: bool = False,
        searchQuery: str = "",
        showUserMenu: bool = False,
        favoriteTeamIds: list = default_favorite_team_ids,
        aiSummary: str = "",
        aiSummaryTitle: str = "",
        aiSummaryLoading: bool = False,
        expandedAIImpacts: list = [],
        aiImpactTexts: any = {},
        teamCounts: any = {},
        aiImpactLoading: list = [],
        transactions: list = [],
        transactionsLoading: bool = False,
        transactionsOffset: int = 0,
        totalTransactions: int = 0,
        players: list = [],
        playersLoading: bool = False,
        playersOffset: int = 0,
        totalPlayers: int = 0,
        playerSearchQuery: str = "",
        playerPositionFilter: str = "all",
        portalStatsData: any = None,
        txnPageData: list = [],
        txnPageLoading: bool = False,
        txnPageOffset: int = 0,
        txnPageTotal: int = 0,
        txnStatusFilter: str = "all",
        txnPositionFilter: str = "all",
        txnTeamFilter: str = "",
        txnFavoritesOnly: bool = False,
        txnFilterVersion: int = 0,
        crystalBallTexts: any = {},
        crystalBallLoading: list = [],
        expandedCrystalBalls: list = [],
        loginEmail: str = "",
        loginPassword: str = "",
        loginConfirmPassword: str = "",
        loginError: str = "",
        loginLoading: bool = False,
        isLoginMode: bool = True,
        teamsSearchFilter: str = "",
        teamsConferenceFilter: str = "all",
        teamsSortBy: str = "activity",
        teamsActivityLevel: int = 0,
        theme: str = "light",
        chatMessages: list = [],
        chatLoading: bool = False,
        conversations: list = [],
        activeConversationId: str = "",
        profileTransactions: list = [],
        profileTransactionsLoading: bool = False,
        profileDisplayName: str = "",
        profileAvatarIcon: str = "",
        teamDetailId: str = "",
        teamTransfers: list = [],
        teamTransfersLoading: bool = False,
        teamTransfersIncoming: list = [],    
        teamTransfersOutgoing: list = [],
        teamAnalysis: str = "",
        teamAnalysisLoading: bool = False,
        playerDetailData: any = {},
        playerDetailLoading: bool = False,
        playerDetailId: str = "",
        userEmail: str = "",
        homeSortByFavorites: bool = False,
        watchedPlayerIds: list = [],
        aiAnalysisSummary: str = "",
        aiAnalysisLoading: bool = False,
        dateRange: str = "all",
        userCredits: int = 0,
        creditsLoading: bool = False,
        today: any = {};


    can with entry {
        auth_result = jacIsLoggedIn();
        isLoggedIn = auth_result;
        checkingAuth = False;
        document.documentElement.className = theme;
        # --- Restore persisted data from localStorage ---
        if auth_result {
            stored_watchlist = window.localStorage.getItem("portai_watchlist");
            if stored_watchlist {
                watchedPlayerIds = JSON.parse(stored_watchlist);
            }
            stored_name = window.localStorage.getItem("portai_display_name");
            if stored_name {
                profileDisplayName = stored_name;
            }
            stored_email = window.localStorage.getItem("portai_email");
            if stored_email {
                userEmail = stored_email;
            }
            stored_avatar = window.localStorage.getItem("portai_avatar_icon");
            if stored_avatar {
                profileAvatarIcon = stored_avatar;
            }
            stored_ai_title = window.localStorage.getItem("portai_ai_summary_title");
            stored_ai_content = window.localStorage.getItem("portai_ai_summary");
            if stored_ai_title and stored_ai_content {
                aiSummaryTitle = stored_ai_title;
                aiSummary = stored_ai_content;
            }
            stored_transactions = window.localStorage.getItem("portai_transactions");
            if stored_transactions {
                parsed_txns = JSON.parse(stored_transactions);
                transactions = parsed_txns["data"].slice().sort(lambda a: dict, b: dict -> int { return (b["rating"] - a["rating"]); });
                totalTransactions = parsed_txns["total"];
                transactionsOffset = parsed_txns["offset"];
            }
            stored_portal_stats = window.localStorage.getItem("portai_portal_stats");
            if stored_portal_stats {
                portalStatsData = JSON.parse(stored_portal_stats);
            }
            stored_team_counts = window.localStorage.getItem("portai_team_counts");
            if stored_team_counts {
                teamCounts = JSON.parse(stored_team_counts);
            }
            stored_favorites = window.localStorage.getItem("portai_favorites");
            if stored_favorites {
                favoriteTeamIds = JSON.parse(stored_favorites);
            }
            stored_profile_txns = window.localStorage.getItem("portai_profile_transactions");
            if stored_profile_txns {
                profileTransactions = JSON.parse(stored_profile_txns);
            }
            stored_ai_impacts = window.localStorage.getItem("portai_ai_impacts");
            if stored_ai_impacts {
                aiImpactTexts = JSON.parse(stored_ai_impacts);
            }
            stored_crystal = window.localStorage.getItem("portai_crystal_ball");
            if stored_crystal {
                crystalBallTexts = JSON.parse(stored_crystal);
            }
        }
        # --- URL Sync: read URL on mount ---
        initial_page = pathToPage(window.location.pathname);
        if initial_page != currentPage {
            currentPage = initial_page;
            # Trigger side-effects for the restored page
            if initial_page.startsWith("team-detail:") {
                teamDetailId = initial_page.split(":")[1];
                found = mock_teams.filter(lambda t: dict -> bool { return t["id"] == teamDetailId; });
                if found.length > 0 {
                    fetchTeamTransfers(found[0]["name"]);
                    fetchTeamAnalysis(found[0]["name"]);
                }
            }

            # if initial_page.startsWith("player-detail:") {
            #     playerDetailId = initial_page.split(":")[1];
            #     fetchPlayerDetail(playerDetailId);
            # }
            if initial_page.startsWith("player-detail:") {
                new_player_id = initial_page.split(":")[1];
                playerDetailId = new_player_id;
                fetchPlayerDetail(new_player_id);
            }


            if initial_page == "players" and players.length == 0 and not playersLoading {
                fetchPlayers();
            }
            if initial_page == "transactions" and txnPageData.length == 0 and not txnPageLoading {
                txnFilterVersion = txnFilterVersion + 1;
            }
            if initial_page == "profile" and profileTransactions.length == 0 and not profileTransactionsLoading {
                fetchProfileTransactions();
            }
        }
        # --- URL Sync: listen for browser back/forward ---
        if not window._portaiPopstateSet {
            window._portaiPopstateSet = True;
            window.addEventListener("popstate", lambda -> None {
                nav_page = pathToPage(window.location.pathname);
                if nav_page != currentPage {
                    handleNavigate(nav_page);
                }
            });
        }

        today = Reflect.construct(Date, []).toLocaleDateString("en-US", {
            "weekday": "long",
            "year": "numeric",
            "month": "long",
            "day": "numeric"
        });
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            # Always fetch user profile and watchlist (lightweight)
            fetchUserProfile();
            fetchWatchlist();
            fetchFavorites();
            claimDailyCredits(); # new

            # Only fetch heavy data if not already restored from cache
            if not aiSummary {
                fetchAISummary();
            }
            if transactions.length == 0 {
                fetchTransactions();
            }
            if not portalStatsData or Object.keys(portalStatsData).length == 0 {
                fetchPortalStats();
            }
            if Object.keys(teamCounts).length == 0 {
                fetchTeamStats();
            }
        }
    }

    # Reactive watcher for transaction page filters
    can with [txnFilterVersion] entry {
        if isLoggedIn and txnFilterVersion > 0 {
            fetchTxnPageData();
        }
    }

    async def fetchFavorites -> None;
    async def fetchAISummary -> None;
    async def fetchTransactions -> None;
    async def loadMoreTransactions -> None;
    async def fetchPlayers -> None;
    async def loadMorePlayers -> None;
    async def fetchPortalStats -> None;
    async def fetchAIImpact(playerId: str) -> None;
    async def fetchTxnPageData -> None;
    async def loadMoreTxnPageData -> None;
    async def handleCrystalBall(playerId: str) -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    async def fetchTeamStats -> None;
    async def handleToggleFavorite(teamId: str) -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    async def fetchProfileTransactions -> None;
    async def handleChatSend(message: str) -> None;
    def handleNewConversation -> None;
    def handleSelectConversation(convId: str) -> None;
    async def fetchUserProfile -> None;
    async def saveUserProfile(profileData: any) -> None;
    async def fetchTeamTransfers(teamName: str) -> None;
    async def fetchTeamAnalysis(teamName: str) -> None;
    async def fetchPlayerDetail(playerId: str) -> None;
    async def fetchWatchlist -> None;
    async def handleToggleWatch(playerId: str) -> None;

    async def handleRegenerateAnalysis -> None;
    def handleDateRangeChange(value: str) -> None;
    async def fetchAnalysisSummary -> None;

    async def claimDailyCredits -> None;
    async def handleIncrementCredits -> None;





    def toggleTheme -> None {
        if theme == "dark" {
            theme = "light";
            document.documentElement.className = "light";
        } else {
            theme = "dark";
            document.documentElement.className = "dark";
        }
    }

    def handleNavigate(page: str) -> None {
        currentPage = page;
        # --- URL Sync: push URL to browser history ---
        new_path = pageToPath(page);
        if window.location.pathname != new_path {
            window.history.pushState({}, "", new_path);
        }
        if page.startsWith("team-detail:") {
            new_team_id = page.split(":")[1];
            teamDetailId = new_team_id;
            teamTransfersLoading = True;
            teamTransfersIncoming = [];
            teamTransfersOutgoing = [];
            teamAnalysis = "";
            found = mock_teams.filter(lambda t: dict -> bool { return t["id"] == new_team_id; });
            if found.length > 0 {
                fetchTeamTransfers(found[0]["name"]);
                fetchTeamAnalysis(found[0]["name"]);
            }
        }
        if page.startsWith("player-detail:") {
            new_player_id = page.split(":")[1];
            playerDetailId = new_player_id;
            fetchPlayerDetail(new_player_id);
        }
        if page == "players" and players.length == 0 and not playersLoading {
            fetchPlayers();
        }
        if page == "transactions" and txnPageData.length == 0 and not txnPageLoading {
            txnFilterVersion = txnFilterVersion + 1;
        }
        if page == "profile" and profileTransactions.length == 0 and not profileTransactionsLoading {
            fetchProfileTransactions();
        }
    }


    async def loadTeamDetailData(teamName: str) -> None {
        await fetchTeamTransfers(teamName);
        await fetchTeamAnalysis(teamName);
    }

    def handleSearch -> None {
        if searchQuery.trim() {
            currentPage = "search";
        }
    }

    def handleSearchChange(e: any) -> None {
        searchQuery = e.target.value;
    }

    def handleToggleSidebar -> None {
        sidebarCollapsed = not sidebarCollapsed;
    }

    def handleToggleUserMenu -> None {
        showUserMenu = not showUserMenu;
    }

    def handleToggleLoginMode -> None {
        isLoginMode = not isLoginMode;
        loginError = "";
    }

    def handleRegenerateSummary -> None {
        # Clear cache so a fresh LLM call is made
        window.localStorage.removeItem("portai_ai_summary_title");
        window.localStorage.removeItem("portai_ai_summary");
        aiSummary = "";
        aiSummaryTitle = "";
        fetchAISummary();
    }

    def handleToggleAIImpact(transactionId: str) -> None {
        if expandedAIImpacts.includes(transactionId) {
            expandedAIImpacts = expandedAIImpacts.filter(
                lambda id: str -> bool { return id != transactionId; }
            );
        } else {
            expandedAIImpacts = expandedAIImpacts.concat([transactionId]);
            if not aiImpactTexts[transactionId] {
                fetchAIImpact(transactionId);
            }
        }
    }

    def handlePlayerSearchChange(e: any) -> None {
        playerSearchQuery = e.target.value;
    }

    def handlePlayerPositionFilter(e: any) -> None {
        playerPositionFilter = e.target.value;
    }

    def handlePlayerSearch -> None {
        playersOffset = 0;
        players = [];
        fetchPlayers();
    }

    def handleTeamsSearchChange(e: any) -> None {
        teamsSearchFilter = e.target.value;
    }

    def handleConferenceFilterChange(e: any) -> None {
        teamsConferenceFilter = e.target.value;
    }

    def handleSortByChange(e: any) -> None {
        teamsSortBy = e.target.value;
    }

    def handleActivityLevelChange(e: any) -> None {
        teamsActivityLevel = parseInt(e.target.value);
    }

    def handleTxnStatusFilterChange(value: str) -> None {
        txnStatusFilter = value;
        txnPageData = [];
        txnPageOffset = 0;
        txnFilterVersion = txnFilterVersion + 1;
    }

    def handleTxnPositionFilterChange(e: any) -> None {
        txnPositionFilter = e.target.value;
        txnPageData = [];
        txnPageOffset = 0;
        txnFilterVersion = txnFilterVersion + 1;
    }

    def handleTxnTeamSelect(teamName: str) -> None {
        txnTeamFilter = teamName;
        txnFavoritesOnly = False;
        txnPageData = [];
        txnPageOffset = 0;
        txnFilterVersion = txnFilterVersion + 1;
    }

    def handleTxnClearTeamFilter -> None {
        txnTeamFilter = "";
        txnPageData = [];
        txnPageOffset = 0;
        txnFilterVersion = txnFilterVersion + 1;
    }

    def handleTxnToggleFavoritesOnly -> None {
        txnFavoritesOnly = not txnFavoritesOnly;
        txnTeamFilter = "";
        txnPageData = [];
        txnPageOffset = 0;
        txnFilterVersion = txnFilterVersion + 1;
    }

    def handleNewConversation -> None {
        activeConversationId = "";
        chatMessages = [];
    }

    def handleSelectConversation(convId: str) -> None {
        for conv in conversations {
            if conv["id"] == convId {
                activeConversationId = convId;
                chatMessages = conv["messages"];
            }
        }
    }

    def handleToggleCrystalBall(playerId: str) -> None {
        if expandedCrystalBalls.includes(playerId) {
            expandedCrystalBalls = expandedCrystalBalls.filter(
                lambda id: str -> bool { return id != playerId; }
            );
        } else {
            expandedCrystalBalls = expandedCrystalBalls.concat([playerId]);
            if not crystalBallTexts[playerId] {
                handleCrystalBall(playerId);
            }
        }
    }

    def handleToggleHomeSortByFavorites -> None {
        homeSortByFavorites = not homeSortByFavorites;
    }

    if checkingAuth {
        return
            <div className="app-layout">
                <div className="placeholder-page">
                    <p className="text-muted">Loading...</p>
                </div>
            </div>;
    }

    if not isLoggedIn {
        return
            <AuthForm
                isLogin={isLoginMode}
                email={loginEmail}
                password={loginPassword}
                confirmPassword={loginConfirmPassword}
                error={loginError}
                loading={loginLoading}
                onEmailChange={lambda e: any -> None { loginEmail = e.target.value; }}
                onPasswordChange={lambda e: any -> None { loginPassword = e.target.value; }}
                onConfirmPasswordChange={lambda e: any -> None { loginConfirmPassword = e.target.value; }}
                onSubmit={handleSubmit}
                onToggleMode={handleToggleLoginMode}
            />;
    }

    return
        <div className="app-layout">
            <Navigation
                currentPage={currentPage}
                onNavigate={handleNavigate}
                onLogout={handleLogout}
                showUserMenu={showUserMenu}
                onToggleUserMenu={handleToggleUserMenu}
                theme={theme}
                onToggleTheme={toggleTheme}
                userCredits={userCredits}
            />
            <div className="app-body">
                <Sidebar
                    currentPage={currentPage}
                    collapsed={sidebarCollapsed}
                    onToggleCollapse={handleToggleSidebar}
                    onNavigate={handleNavigate}
                    favoriteTeamIds={favoriteTeamIds}
                />
                <main className="main-content">
                    {(
                        <HomePage
                            onNavigate={handleNavigate}
                            favoriteTeamIds={favoriteTeamIds}
                            aiSummary={aiSummary}
                            aiSummaryTitle={aiSummaryTitle}
                            aiSummaryLoading={aiSummaryLoading}
                            onRegenerateSummary={handleRegenerateSummary}
                            expandedAIImpacts={expandedAIImpacts}
                            onToggleAIImpact={handleToggleAIImpact}
                            transactions={transactions}
                            transactionsLoading={transactionsLoading}
                            totalTransactions={totalTransactions}
                            onLoadMore={loadMoreTransactions}
                            aiImpactTexts={aiImpactTexts}
                            aiImpactLoading={aiImpactLoading}
                            portalStatsData={portalStatsData}
                            teamCounts={teamCounts}
                            sortByFavorites={homeSortByFavorites}
                            onToggleSortByFavorites={handleToggleHomeSortByFavorites}
                            onToggleWatch={handleToggleWatch}
                            watchedPlayerIds={watchedPlayerIds}

                        />
                    ) if currentPage == "home" else (
                        <TeamsPage
                            onNavigate={handleNavigate}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                            searchFilter={teamsSearchFilter}
                            onSearchFilterChange={handleTeamsSearchChange}
                            conferenceFilter={teamsConferenceFilter}
                            onConferenceFilterChange={handleConferenceFilterChange}
                            sortBy={teamsSortBy}
                            onSortByChange={handleSortByChange}
                            activityLevel={teamsActivityLevel}
                            onActivityLevelChange={handleActivityLevelChange}
                            teamCounts={teamCounts}
                        />
                    ) if currentPage == "teams" else (
                        <PlayersPage
                            onNavigate={handleNavigate}
                            players={players}
                            playersLoading={playersLoading}
                            totalPlayers={totalPlayers}
                            searchQuery={playerSearchQuery}
                            onSearchChange={handlePlayerSearchChange}
                            onSearch={handlePlayerSearch}
                            positionFilter={playerPositionFilter}
                            onPositionFilterChange={handlePlayerPositionFilter}
                            onLoadMore={loadMorePlayers}
                        />
                    ) if currentPage == "players" else (
                        <TransactionsPage
                            transactions={txnPageData}
                            transactionsLoading={txnPageLoading}
                            totalTransactions={txnPageTotal}
                            onLoadMore={loadMoreTxnPageData}
                            statusFilter={txnStatusFilter}
                            onStatusFilterChange={handleTxnStatusFilterChange}
                            positionFilter={txnPositionFilter}
                            onPositionFilterChange={handleTxnPositionFilterChange}
                            teamFilter={txnTeamFilter}
                            onTeamSelect={handleTxnTeamSelect}
                            onClearTeamFilter={handleTxnClearTeamFilter}
                            favoritesOnly={txnFavoritesOnly}
                            onToggleFavoritesOnly={handleTxnToggleFavoritesOnly}
                            favoriteTeamIds={favoriteTeamIds}
                            expandedAIImpacts={expandedAIImpacts}
                            onToggleAIImpact={handleToggleAIImpact}
                            aiImpactTexts={aiImpactTexts}
                            aiImpactLoading={aiImpactLoading}
                            onNavigate={handleNavigate}
                            crystalBallTexts={crystalBallTexts}
                            crystalBallLoading={crystalBallLoading}
                            expandedCrystalBalls={expandedCrystalBalls}
                            onToggleCrystalBall={handleToggleCrystalBall}
                            watchedPlayerIds={watchedPlayerIds}
                            onToggleWatch={handleToggleWatch}
                        />
                    ) if currentPage == "transactions" else (
                        <FavoritesPage
                            onNavigate={handleNavigate}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                            teamCounts={teamCounts}
                        />
                    ) if currentPage == "favorites" else (
                        <ProfilePage
                            onNavigate={handleNavigate}
                            onLogout={handleLogout}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                            userEmail={userEmail}
                            profileTransactions={profileTransactions}
                            profileTransactionsLoading={profileTransactionsLoading}
                            portalStatsData={portalStatsData}
                            savedDisplayName={profileDisplayName}
                            savedAvatarIcon={profileAvatarIcon}
                            onSaveProfile={saveUserProfile}
                            watchedPlayerIds={watchedPlayerIds}
                            onToggleWatch={handleToggleWatch}
                            userCredits={userCredits}
                            onIncrementCredits={handleIncrementCredits}
                            creditsLoading={creditsLoading}
                        />
                    ) if currentPage == "profile" else (
                        <ChatPage
                            onNavigate={handleNavigate}
                            chatMessages={chatMessages}
                            chatLoading={chatLoading}
                            onChatSend={handleChatSend}
                            conversations={conversations}
                            activeConversationId={activeConversationId}
                            onSelectConversation={handleSelectConversation}
                            onNewConversation={handleNewConversation}
                        />

                    ) if currentPage == "chat" else (

                        <AnalyticsPage
                            onNavigate={handleNavigate}
                            transactions={transactions}
                            portalStatsData={portalStatsData}
                            favoriteTeamIds={favoriteTeamIds}
                            teamCounts={teamCounts}
                            aiAnalysisSummary={aiAnalysisSummary}
                            aiAnalysisLoading={aiAnalysisLoading}
                            onRegenerateAnalysis={handleRegenerateAnalysis}
                            dateRange={dateRange}
                            onDateRangeChange={handleDateRangeChange}
                            today={today}
                        />
                    ) if currentPage == "analytics" else (

                        <PlayerDetailPage
                            playerId={playerDetailId}
                            playerData={playerDetailData}
                            playerLoading={playerDetailLoading}
                            onNavigate={handleNavigate}
                            aiImpactTexts={aiImpactTexts}
                            aiImpactLoading={aiImpactLoading}
                            expandedAIImpacts={expandedAIImpacts}
                            onToggleAIImpact={handleToggleAIImpact}
                            crystalBallTexts={crystalBallTexts}
                            crystalBallLoading={crystalBallLoading}
                            expandedCrystalBalls={expandedCrystalBalls}
                            onToggleCrystalBall={handleToggleCrystalBall}
                        />
                    ) if currentPage.startsWith("player-detail:") else (
                        <TeamDetailPage
                            teamId={teamDetailId}
                            teamCounts={teamCounts}
                            onNavigate={handleNavigate}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                            expandedAIImpacts={expandedAIImpacts}
                            onToggleAIImpact={handleToggleAIImpact}
                            aiImpactTexts={aiImpactTexts}
                            aiImpactLoading={aiImpactLoading}
                            teamTransfers={teamTransfers}
                            teamTransfersLoading={teamTransfersLoading}
                            teamAnalysis={teamAnalysis}
                            teamAnalysisLoading={teamAnalysisLoading}
                            teamTransfersIncoming={teamTransfersIncoming}
                            teamTransfersOutgoing={teamTransfersOutgoing}
                            onRegenerateAnalysis={lambda -> None { 
                                found = mock_teams.filter(lambda t: dict -> bool { return t["id"] == teamDetailId; });
                                if found.length > 0 { fetchTeamAnalysis(found[0]["name"]); }
                            }}
                        />
                    ) if currentPage.startsWith("team-detail:") else (
                    
                        <div className="placeholder-page">
                            <h1>Coming Soon</h1>
                            <p className="text-muted">This page is under construction.</p>
                        </div>
                    )}
                </main>
            </div>
            <Footer />
        </div>;
}
