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
import from .pages.ChatPage { ChatPage }
import from .data.mock_data { default_favorite_team_ids, mock_teams }
import from .pages.TeamDetailPage { TeamDetailPage }

sv import from main {
    update_favorites, get_user_favorites, get_portal_summary, update_profile, get_user_profile, 
    get_transfers, search_players, get_player_by_id, get_ai_impact, get_portal_stats,
    predict_destination, chat, get_team_stats, get_team_analysis, get_team_transfers
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
        portalStatsData: any = {},
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
        teamAnalysis: str = "",
        teamAnalysisLoading: bool = False,
        userEmail: str = "";

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
        document.documentElement.className = theme;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchFavorites();
            fetchAISummary();
            fetchTransactions();
            fetchPortalStats();
            fetchUserProfile();
            fetchTeamStats();
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
    if page.startsWith("team-detail:") {
        teamDetailId = page.split(":")[1];
        team_name = "";
        found = mock_teams.filter(lambda t: dict -> bool { return t["id"] == teamDetailId; });
        if found.length > 0 {
            fetchTeamTransfers(found[0]["name"]);
            fetchTeamAnalysis(found[0]["name"]);
        }
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
                searchQuery={searchQuery}
                onSearch={handleSearch}
                onSearchChange={handleSearchChange}
                onNavigate={handleNavigate}
                onLogout={handleLogout}
                showUserMenu={showUserMenu}
                onToggleUserMenu={handleToggleUserMenu}
                theme={theme}
                onToggleTheme={toggleTheme}
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
                        />
                    ) if currentPage == "transactions" else (
                        <FavoritesPage
                            onNavigate={handleNavigate}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                        />
                    ) if currentPage == "favorites" else (
                        <ProfilePage
                            onNavigate={handleNavigate}
                            onLogout={handleLogout}
                            favoriteTeamIds={favoriteTeamIds}
                            onToggleFavorite={handleToggleFavorite}
                            userEmail={loginEmail}
                            profileTransactions={profileTransactions}
                            profileTransactionsLoading={profileTransactionsLoading}
                            portalStatsData={portalStatsData}
                            savedDisplayName={profileDisplayName}
                            savedAvatarIcon={profileAvatarIcon}
                            onSaveProfile={saveUserProfile}
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
                            onRegenerateAnalysis={lambda -> None { fetchTeamAnalysis(teamDetailName); }}
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
