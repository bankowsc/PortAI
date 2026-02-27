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
    {"team": "Akron", "institution_key": "24065", "name": "Dwight Nunoo", "position": "LB", "height": "6'0", "weight": "221 lbs", "stars": "3", "rating": "0.8200", "status": "Enrolled", "from_school": "FIU", "to_school": "Akron", "profile_url": "https://247sports.com/player/dwight-nunoo-46114271/college-319050/"},
    {"team": "Akron", "institution_key": "24065", "name": "Reese Poffenbarger", "position": "QB", "height": "6'0", "weight": "210 lbs", "stars": "3", "rating": "0.8100", "status": "Enrolled", "from_school": "North Texas", "to_school": "Akron", "profile_url": "https://247sports.com/player/reese-poffenbarger-46084447/college-328717/"},
    {"team": "Akron", "institution_key": "24065", "name": "Nate Hampton", "position": "IOL", "height": "6'2", "weight": "295 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Saint Francis (PA)", "to_school": "Akron", "profile_url": "https://247sports.com/player/nate-hampton-46164015/college-350318/"},
    {"team": "Akron", "institution_key": "24065", "name": "Titus Myers", "position": "WR", "height": "6'2", "weight": "175 lbs", "stars": "3", "rating": "0.8300", "status": "Enrolled", "from_school": "Old Dominion", "to_school": "Akron", "profile_url": "https://247sports.com/player/titus-myers-46152569/college-332146/"},
    {"team": "Akron", "institution_key": "24065", "name": "Shamar McNeil", "position": "CB", "height": "6'3", "weight": "180 lbs", "stars": "3", "rating": "0.8500", "status": "Enrolled", "from_school": "Missouri", "to_school": "Akron", "profile_url": "https://247sports.com/player/shamar-mcneil-46130932/college-301217/"},
    {"team": "Akron", "institution_key": "24065", "name": "Caiden Newsome", "position": "CB", "height": "5'10", "weight": "175 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Holy Cross", "to_school": "Akron", "profile_url": "https://247sports.com/player/caiden-newsome-46164018/college-350326/"},
    {"team": "Akron", "institution_key": "24065", "name": "Zach Hobson", "position": "CB", "height": "6'3", "weight": "193 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Old Dominion", "to_school": "Akron", "profile_url": "https://247sports.com/player/zach-hobson-46158829/college-341970/"},
    {"team": "Akron", "institution_key": "24065", "name": "Wyatt Hook", "position": "TE", "height": "6'6", "weight": "258 lbs", "stars": "3", "rating": "0.8400", "status": "Enrolled", "from_school": "Michigan State", "to_school": "Akron", "profile_url": "https://247sports.com/player/wyatt-hook-46134462/college-318453/"},
    {"team": "Akron", "institution_key": "24065", "name": "Brandon Smith", "position": "IOL", "height": "6'1", "weight": "295 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "South Dakota", "to_school": "Akron", "profile_url": "https://247sports.com/player/brandon-smith-46135064/college-348416/"},
    {"team": "Akron", "institution_key": "24065", "name": "Carlos Slayden", "position": "IOL", "height": "6'3", "weight": "300 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Southern Miss", "to_school": "Akron", "profile_url": "https://247sports.com/player/carlos-slayden-46157854/college-342055/"},
    {"team": "Akron", "institution_key": "24065", "name": "Miles Burris", "position": "WR", "height": "6'2", "weight": "200 lbs", "stars": "3", "rating": "0.8400", "status": "Enrolled", "from_school": "Charlotte", "to_school": "Akron", "profile_url": "https://247sports.com/player/miles-burris-46136708/college-309650/"},
    {"team": "Akron", "institution_key": "24065", "name": "Aidan Stire", "position": "P", "height": "6'0", "weight": "193 lbs", "stars": "3", "rating": "0.8000", "status": "Enrolled", "from_school": "West Virginia", "to_school": "Akron", "profile_url": "https://247sports.com/player/aidan-stire-46151630/college-348258/"},
    {"team": "Akron", "institution_key": "24065", "name": "Dawayne Galloway Jr.", "position": "CB", "height": "6'1", "weight": "165 lbs", "stars": "3", "rating": "0.8600", "status": "Enrolled", "from_school": "West Virginia", "to_school": "Akron", "profile_url": "https://247sports.com/player/dawayne-galloway-jr-46144049/college-340517/"},
    {"team": "Akron", "institution_key": "24065", "name": "Vaughn Highland", "position": "DL", "height": "6'1", "weight": "310 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Arkansas-Pine Bluff", "to_school": "Akron", "profile_url": "https://247sports.com/player/vaughn-highland-46164017/college-350324/"},
    {"team": "Akron", "institution_key": "24065", "name": "Melvin Puckett", "position": "IOL", "height": "6'3", "weight": "310 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Bethune-Cookman", "to_school": "Akron", "profile_url": "https://247sports.com/player/melvin-puckett-46146107/college-347997/"},
    {"team": "Akron", "institution_key": "24065", "name": "Kurtis Waye", "position": "Edge", "height": "6'5", "weight": "240 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Clark Atlanta", "to_school": "Akron", "profile_url": "https://247sports.com/player/kurtis-waye-46118042/college-350319/"},
    {"team": "Akron", "institution_key": "24065", "name": "Stone Dean", "position": "LS", "height": "6'3", "weight": "225 lbs", "stars": "3", "rating": "0.8000", "status": "Enrolled", "from_school": "West Texas A&M", "to_school": "Akron", "profile_url": "https://247sports.com/player/stone-dean-46164021/college-350333/"},
    {"team": "Akron", "institution_key": "24065", "name": "Ian Falkner", "position": "IOL", "height": "6'3", "weight": "290 lbs", "stars": "0", "rating": "N/A", "status": "Enrolled", "from_school": "Missouri Southern State", "to_school": "Akron", "profile_url": "https://247sports.com/player/ian-falkner-46164022/college-350335/"},
    {"team": "Akron", "institution_key": "24065", "name": "Kenneth McManus IV", "position": "IOL", "height": "6'2", "weight": "320 lbs", "stars": "3", "rating": "0.8600", "status": "Enrolled", "from_school": "Akron", "to_school": "Auburn", "profile_url": "https://247sports.com/player/kenneth-mcmanus-iv-46144546/college-343013/"},
    {"team": "Akron", "institution_key": "24065", "name": "Markus Boswell", "position": "LB", "height": "6'1", "weight": "230 lbs", "stars": "3", "rating": "0.8500", "status": "Enrolled", "from_school": "Akron", "to_school": "Texas", "profile_url": "https://247sports.com/player/markus-boswell-46136015/college-349638/"},
    {"team": "Akron", "institution_key": "24065", "name": "Ben Kamara", "position": "CB", "height": "6'3", "weight": "200 lbs", "stars": "0", "rating": "N/A", "status": "N/A", "from_school": "Akron", "to_school": "N/A", "profile_url": "https://247sports.com/player/ben-kamara-46156089/college-334150/"},
    {"team": "Akron", "institution_key": "24065", "name": "Melvin Spriggs", "position": "LB", "height": "6'1", "weight": "225 lbs", "stars": "0", "rating": "N/A", "status": "Committed", "from_school": "Akron", "to_school": "Southern Miss", "profile_url": "https://247sports.com/player/melvin-spriggs-46138037/college-320707/"},
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
        showDropdownTeam: bool = False,
        # showDropdownFavorite: bool = False,
        transferSearch: str = "",
        messages: list = ["test"],
        user_input: "N/A",
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
        [favorites, setFavorites] = useState(["Michigan", "Michigan State"]);
        [showDropdownFavorite, setshowDropdownFavorite] = useState(False);
        # [transfer_data, setTransferData] = useState([]);


    def toggleTheme -> None;
    def toggleDropdownTeam -> None;
    def toggleDropdownFavorite -> None;
    async def toggleFavorite(team: str) -> None;
    async def sendMessage -> None;

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
                                    onClick={lambda -> None { toggleDropdownTeam(); }}
                                    className="btn-dropdown">
                                    Teams
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
                                    
                                    if showDropdownTeam else ""
                                )}
                            </div>

                            <div className="dropdown-button-2">
                                <button
                                    onClick={lambda -> None { toggleDropdownFavorite(); }}
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
                                                for team in favorites
                                            ]}
                                        </ul>
                                    </div>
                                    
                                    if showDropdownFavorite else ""
                                )}
                            </div>
                    </div>
                </div>

                <div className="content-container">

                    <div className="ai-container">
                        <div className="chat-window">
                            {[
                                <div className={"chat-bubble " + msg["role"]}>
                                    {msg["content"]}
                                </div>
                                for msg in messages
                            ]}
                        </div>

                        <div className="chat-input-row">
                            <input
                                type="text"
                                value={user_input}
                                placeholder="Ask anything..."
                            />
                            <button onClick={sendMessage}>
                                Send
                            </button>
                        </div>

                    </div>

                    <div className="transfer-news">
                        <div className="search-bar">
                        <input
                            type="text"
                            className="transfer-search"
                            placeholder="Search teams..."
                            value={transferSearch}
                            onChange={lambda e: any -> None { transferSearch = e.target.value; console.log(transferSearch); }}
                        />

                        </div>
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
                                            <span className="player-stars">{ "*" if player["stars"] != "N/A" else ""}</span> # TODO <-- get the stars ["★" for star in int(player["stars"])]
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
