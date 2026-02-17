"""Todo App - Client-Side UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import "./styles.css";

# import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }
import from .components.NewsCard { NewsCard }

import from "react" { useState, useEffect }

glob transfer_data: list = [
    # team,institution_key,name,position,height,weight,stars,rating,status,from_school,to_school,profile_url
    {"team": "Air Force", "institution_key": "24078", "name": "Jordan Shuler", "position": "LB", "height": "6'2", "weight": "220 lbs", "stars": "2", "rating": "0.7900", "status": "N/A", "from_school": "Air Force", "to_school": "N/A", "profile_url": "https://247sports.com/player/jordan-shuler-46116426/college-348647/"},
    {"team": "Air Force", "institution_key": "24078", "name": "Trae Williams", "position": "CB", "height": "5'10", "weight": "170 lbs", "stars": "0", "rating": "N/A", "status": "Committed", "from_school": "Air Force", "to_school": "Furman", "profile_url": "https://247sports.com/player/trae-williams-46137057/college-350888/"},
    {"team": "Air Force", "institution_key": "24078", "name": "Jeremiah Shelby", "position": "Edge", "height": "6'3", "weight": "250 lbs", "stars": "0", "rating": "N/A", "status": "N/A", "from_school": "Air Force", "to_school": "N/A", "profile_url": "https://247sports.com/player/jeremiah-shelby-46141024/college-348556/"},
    {"team": "Air Force", "institution_key": "24078", "name": "Jeremiah Shelby", "position": "Edge", "height": "6'3", "weight": "250 lbs", "stars": "0", "rating": "N/A", "status": "N/A", "from_school": "Air Force", "to_school": "N/A", "profile_url": "https://247sports.com/player/jeremiah-shelby-46141024/college-348556/"},
    {"team": "Air Force", "institution_key": "24078", "name": "Dominic Diaz", "position": "LS", "height": "6'0", "weight": "225 lbs", "stars": "0", "rating": "N/A", "status": "N/A", "from_school": "Air Force", "to_school": "N/A", "profile_url": "https://247sports.com/player/dominic-diaz-46134292/college-348557/"},
    {"team": "Akron", "institution_key": "24065", "name": "Khory Moss", "position": "CB", "height": "5'11", "weight": "190 lbs", "stars": "3", "rating": "0.8300", "status": "Enrolled", "from_school": "Miami (OH)", "to_school": "Akron", "profile_url": "https://247sports.com/player/khory-moss-46152016/college-332830/"},
    {"team": "Akron", "institution_key": "24065", "name": "Dwight Nunoo", "position": "LB", "height": "6'0", "weight": "221 lbs", "stars": "3", "rating": "0.8200", "status": "Enrolled", "from_school": "FIU", "to_school": "Akron", "profile_url": "https://247sports.com/player/dwight-nunoo-46114271/college-319050/"}
];

# with entry {
#     with open("/scraping/all_teams_transfer_portal_2026.csv", "r") as f {
#         reader = csv.DictReader(f);
#         for row in reader {
#             if row["to_school"] != "N/A" and row["status"] == "Committed" {
#                 transfer_data.append(row);
#             }
#             if len(transfer_data) >= 10 {
#                 break;
#             }
#         }
#     }
# }

# sv import from main { get_transfer_news }

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
        # [transfer_data, setTransferData] = useState([]);


    def toggleTheme -> None;
    def toggleDropdown -> None;
    async def toggleFavorite(team: str) -> None;

    # PROBLEM HERE WANT UI TO CHANGE
    


    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
        document.documentElement.className = theme;

        # fetch("/api/transfer-news")
        # .then(lambda r: any -> any { return r.json(); })
        # .then(lambda data: any -> None { setTransferData(data); });
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

                <div className="transfer-news">
                    <h2>Recent Transfers</h2>
                    {
                        [
                            <div className="transfer-card" key={player["profile_url"]}>
                                <div className="transfer-card-top">
                                    <div className="player-name-row">
                                        <span className="player-name">{player["name"]}</span>
                                        <span className="player-position">{player["position"]}</span>
                                    </div>
                                    <div className="player-meta">
                                        <span className="player-physical">{player["height"]} "  {player["weight"]}</span>
                                        <span className="player-stars">{"★" if player["stars"] != "N/A" else ""}</span> # TODO <-- get the stars
                                        <span className="player-rating">{player["rating"]}</span>
                                    </div>
                                </div>
                                <div className="transfer-route">
                                    <span className="from-school">{player["from_school"]}</span>
                                    <span className="arrow">→</span>
                                    <span className="to-school">{player["to_school"]}</span>
                                </div>
                                <div className="transfer-card-bottom">
                                    <span className={"status-badge status-" + player["status"].lower()}>{player["status"]}</span>
                                    <a href={player["profile_url"]} target="_blank" className="profile-link">View Profile →</a>
                                </div>
                            </div>
                            for player in transfer_data # if player["to_school"] != "N/A"
                        ]
                    }
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
