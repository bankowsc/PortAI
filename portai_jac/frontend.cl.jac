"""PortAI - Frontend Entry Point."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import "./styles.css";

import from .components.Navigation { Navigation }
import from .components.Sidebar { Sidebar }
import from .components.Footer { Footer }
import from .components.AuthForm { AuthForm }
import from .pages.HomePage { HomePage }
import from .pages.TeamsPage { TeamsPage }
import from .data.mock_data { default_favorite_team_ids }

sv import from main {
    update_favorites, get_user_favorites, get_portal_summary
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
        loginEmail: str = "",
        loginPassword: str = "",
        loginConfirmPassword: str = "",
        loginError: str = "",
        loginLoading: bool = False,
        isLoginMode: bool = True,
        teamsSearchFilter: str = "",
        teamsConferenceFilter: str = "all",
        teamsSortBy: str = "activity",
        teamsActivityLevel: int = 0;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchFavorites();
            fetchAISummary();
        }
    }

    async def fetchFavorites -> None;
    async def fetchAISummary -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;

    def handleNavigate(page: str) -> None {
        currentPage = page;
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

    def handleToggleFavorite(teamId: str) -> None {
        if favoriteTeamIds.includes(teamId) {
            favoriteTeamIds = favoriteTeamIds.filter(
                lambda id: str -> bool { return id != teamId; }
            );
        } else {
            favoriteTeamIds = favoriteTeamIds.concat([teamId]);
        }
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
        }
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
