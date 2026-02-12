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

        favorites: list = ["Michigan", "Michigan State"]; # TODO ITS NOT PICKING THESE UP

    def toggleTheme -> None;
    def toggleDropdown -> None;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
        document.documentElement.className = theme;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            # NOTE THIS IS WHERE ILL MAKE IT LOAD MY GRID FOR LATER YIPEEEEEEEE
            # fetchTodos();
            # fetchMealPlan();
            # # BEGIN NEWS LOAD
            # fetchNews();
            # # END NEWS LOAD
        }
    }

    # Method declarations (implementations in frontend.impl.jac)

    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;

    # BEGIN NEWS METHODS

    # END NEWS METHODS


    
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
                                            <li>{("⭐" if "Michigan" in favorites else "☆")} Michigan</li>
                                            <li>{("⭐" if "Michigan State" in favorites else "☆")} Michigan State</li>
                                            <li>{("⭐" if "Ohio State" in favorites else "☆")} Ohio State</li>
                                            <li>{("⭐" if "Indiana" in favorites else "☆")} Indiana</li>
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
