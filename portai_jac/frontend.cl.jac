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
import from .data.mock_data { default_favorite_team_ids, mock_teams }

sv import from main {
    update_favorites, get_user_favorites, get_portal_summary,
    get_transfers, search_players, get_player_by_id, get_ai_impact, get_portal_stats,
    predict_destination
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
        theme: str = "light";

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
        }
    }

    # Reactive watcher for transaction page filters
    # Fires AFTER state is committed, so fetchTxnPageData reads the new values
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
    async def handleToggleFavorite(teamId: str) -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;

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
        # Load players when navigating to players page for the first time
        if page == "players" and players.length == 0 and not playersLoading {
            fetchPlayers();
        }
        # Load transactions page data when navigating to transactions
        if page == "transactions" and txnPageData.length == 0 and not txnPageLoading {
            txnFilterVersion = txnFilterVersion + 1;
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
            # Fetch AI impact if not already loaded
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

    def handleToggleCrystalBall(playerId: str) -> None {
        if expandedCrystalBalls.includes(playerId) {
            expandedCrystalBalls = expandedCrystalBalls.filter(
                lambda id: str -> bool { return id != playerId; }
            );
        } else {
            expandedCrystalBalls = expandedCrystalBalls.concat([playerId]);
            # Fetch prediction if not already loaded
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
