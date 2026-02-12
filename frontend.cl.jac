"""Todo App - Client-Side UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import "./styles.css";

# import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }
import from .components.NewsCard { NewsCard }

# import from .components.IngredientItem { IngredientItem }

# BEGIN NEWS IMPORT
# import from .components.NewsCard { NewsCard }
# END NEWS IMPORT


# sv import from main {
#     # , ListTodos, ToggleTodo, DeleteTodo,
#     # GenerateShoppingList, ListMealPlan, ClearMealPlan,
#     # BEGIN NEWS WALKERS
#     # END NEWS WALKERS
# }

# sv import from main { get_current_user, update_favorites }

def:pub app -> any {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        theme: str = "dark",
        showDropdown: bool = False,
        # favorites: list = ["Michigan", "Michigan State"],
        teams: list = [
            "Air Force", "Akron", "Alabama", "Appalachian State", "Arizona",
            "Arizona State", "Arkansas", "Arkansas State", "Army", "Auburn",
            "Ball State", "Baylor", "Boise State", "Boston College", "Bowling Green",
            "Buffalo", "BYU", "California", "Central Michigan", "Charlotte",
            "Cincinnati", "Clemson", "Coastal Carolina", "Colorado", "Colorado State",
            "Connecticut", "Duke", "East Carolina", "Eastern Michigan", "FIU",
            "Florida", "Florida Atlantic", "Florida State", "Fresno State", "Georgia",
            "Georgia Southern", "Georgia State", "Georgia Tech", "Hawaii", "Houston",
            "Illinois", "Indiana", "Iowa", "Iowa State", "Jacksonville State",
            "James Madison", "Kansas", "Kansas State", "Kennesaw State", "Kent State",
            "Kentucky", "Liberty", "Louisiana", "Louisiana Monroe", "Louisiana Tech",
            "Louisville", "LSU", "Marshall", "Maryland", "Memphis", "Miami",
            "Miami (OH)", "Michigan", "Michigan State", "Middle Tennessee", "Minnesota",
            "Mississippi State", "Missouri", "Navy", "NC State", "Nebraska",
            "Nevada", "New Mexico", "New Mexico State", "North Carolina", "North Texas",
            "Northern Illinois", "Northwestern", "Notre Dame", "Ohio", "Ohio State",
            "Oklahoma", "Oklahoma State", "Old Dominion", "Ole Miss", "Oregon",
            "Oregon State", "Penn State", "Pittsburgh", "Purdue", "Rice",
            "Rutgers", "Sam Houston", "San Diego State", "San Jose State", "SMU",
            "South Alabama", "South Carolina", "South Florida", "Southern Miss", "Stanford",
            "Syracuse", "TCU", "Temple", "Tennessee", "Texas", "Texas A&M",
            "Texas State", "Texas Tech", "Toledo", "Troy", "Tulane", "Tulsa",
            "UAB", "UCF", "UCLA", "UNLV", "USC", "Utah", "Utah State",
            "UTEP", "UTSA", "Vanderbilt", "Virginia", "Virginia Tech", "Wake Forest",
            "Washington", "Washington State", "West Virginia", "Western Kentucky",
            "Western Michigan", "Wisconsin", "Wyoming"
        ];
        [favorites, setFavorites] = useState(["Michigan", "Michigan State", "Akron"]);


    def toggleTheme -> None;
    def toggleDropdown -> None;
    async def toggleFavorite(team: str) -> None;

    # PROBLEM HERE WANT UI TO CHANGE
    


    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
        document.documentElement.className = theme;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            # loadUserData();
        }
    }

    # Method declarations (implementations in frontend.impl.jac)

    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    

    
    # BEGIN NEWS METHODS

    # END NEWS METHODS

    # async def loadUserData -> None;

    

    
    if checkingAuth {
        return
            <div style={{"display": "flex", "justifyContent": "center",
                         "alignItems": "center", "minHeight": "100vh",
                         "color": "rgba(255,255,255,0.6)", "fontFamily": "system-ui"}}>
                Loading...
            </div>;
    }

    if isLoggedIn {
        return
            <div className="app-container">
                <div className="app-content">
                    <div className="card">
                        <div className="card-header">
                            <div className="header-actions">
                                <button
                                    onClick={lambda -> None { toggleTheme(); }}
                                    className="btn-theme-toggle">
                                    <span className="theme-icon">
                                        {("🌙" if theme == "dark" else "☀️")}
                                    </span>
                                    <span className="theme-label">
                                        {("Dark" if theme == "dark" else "Light")}
                                    </span>
                                </button>
                            </div>
                            <div>
                                <h1 className="app-title">PortAI</h1>
                                <p className="app-subtitle">
                                    A David & Goliath Product
                                </p>

                            </div>
                            <button onClick={handleLogout} className="btn-signout">
                                Sign Out
                            </button>
                        </div>

                            <div className="dropdown-button">
                                <button
                                    onClick={lambda -> None { toggleDropdown(); }}
                                    className="btn-dropdown">
                                    Favorites
                                </button>

                                {(
                                    <div>
                                        <ul className="dropdown-menu">
                                            {[
                                                <li onClick={lambda -> None { toggleFavorite(team); }}>
                                                    {("⭐" if favorites.includes(team) else "☆ ")} {team}
                                                </li>
                                                for team in teams
                                            ]}
                                        </ul>
                                    </div>
                                    
                                    if showDropdown else ""
                                )}
                            </div>
                    </div>
                </div>

                <div className="bottom-line">
                    <img src="./assets/mockLogo.png" className="mock-logo" />
                    <h1>
                        <div className="bottom-text">
                            You've reached the bottom of the page!
                        </div>
                    </h1>
                </div>
            </div>;
            
    }

    return
        <AuthForm
            isSignup={isSignup}
            username={username}
            password={password}
            error={error}
            loading={loading}
            onUsernameChange={lambda e: any -> None { username = e.target.value; }}
            onPasswordChange={lambda e: any -> None { password = e.target.value; }}
            onSubmit={handleSubmit}
            onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; }}
        />;
}
