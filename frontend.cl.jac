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


sv import from main {
    # , ListTodos, ToggleTodo, DeleteTodo,
    # GenerateShoppingList, ListMealPlan, ClearMealPlan,
    # BEGIN NEWS WALKERS
    GenerateNews, ListNews, DeleteNews
    # END NEWS WALKERS
}

def:pub app -> any {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        theme: str = "dark",

        # BEGIN NEWS STATE
        schoolInput: str = "",
        newsArticles: list = [],
        newsLoading: bool = False;
        # END NEWS STATE

    def toggleTheme -> None;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
        document.documentElement.className = theme;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
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
    # def handleTodoKeyPress(e: any) -> None;

    # BEGIN NEWS METHODS
    async def fetchNews -> None;
    async def generateNews -> None;
    async def deleteNewsArticle(articleId: str) -> None;
    async def handleNewsKeyPress(e: any) -> None;
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
                    </div>


                    <div className="card">
                        <h2 className="panel-title">NCAA News Generator</h2>
                        <p className="panel-subtitle">
                            Generate AI news stories about your favorite NCAA school
                        </p>
                        <div className="add-row">
                            <input
                                type="text"
                                value={schoolInput}
                                onChange={lambda e: any -> None { schoolInput = e.target.value; }}
                                onKeyPress={handleNewsKeyPress}
                                placeholder="e.g. Michigan Wolverines"
                                className="todo-input"
                            />
                            <button
                                onClick={lambda -> None { generateNews(); }}
                                disabled={newsLoading}
                                className="btn-generate"
                            >
                                {("Generating..." if newsLoading else "Generate News")}
                            </button>
                        </div>
                        
                        <div className="news-container">
                            {(
                                <div className="loading-message">
                                    <div className="generating-spinner"></div>
                                    Generating news story...
                                </div>
                            ) if newsLoading else (
                                <div>
                                    {(
                                        <div className="empty-message">
                                            Enter a school name above to generate news.
                                        </div>
                                    ) if newsArticles.length == 0 else (
                                        <div>
                                            {[
                                                <NewsCard
                                                    key={article.id}
                                                    article={article}
                                                    onDelete={deleteNewsArticle}
                                                /> for article in newsArticles
                                            ]}
                                        </div>
                                    )}
                                </div>
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
