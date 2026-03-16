"""TaskFlow - A multi-user todo app with AI meal planning."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# --- AI Types ---

# enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }

# enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

# BEGIN NEWS ADDITION

obj NewsStory {
    has headline: str;
    has summary: str;
    has content: str;
    has source: str;
    has date: str;
}

glob TEAM_NAME_MAP: dict = {
    "Alabama Crimson Tide": "Alabama",
    "Auburn Tigers": "Auburn",
    "LSU Tigers": "LSU",
    "Ole Miss Rebels": "Ole Miss",
    "Mississippi State Bulldogs": "Mississippi State",
    "Miami Hurricanes": "Miami",
    "Miami (OH) RedHawks": "Miami (OH)",
    "NC State Wolfpack": "NC State",
    "BYU Cougars": "BYU",
    "SMU Mustangs": "SMU",
    "TCU Horned Frogs": "TCU",
    "USC Trojans": "USC",
    "UCF Knights": "UCF",
    "UCLA Bruins": "UCLA",
    "UAB Blazers": "UAB",
    "Texas A&M Aggies": "Texas A&M",
    "Oklahoma Sooners": "Oklahoma",
    "Oklahoma State Cowboys": "Oklahoma State",
    "Ohio State Buckeyes": "Ohio State",
    "Michigan Wolverines": "Michigan",
    "Michigan State Spartans": "Michigan State",
    "Penn State Nittany Lions": "Penn State",
    "Notre Dame Fighting Irish": "Notre Dame",
    "Georgia Bulldogs": "Georgia",
    "Florida Gators": "Florida",
    "Florida State Seminoles": "Florida State",
    "Tennessee Volunteers": "Tennessee",
    "Arkansas Razorbacks": "Arkansas",
    "South Carolina Gamecocks": "South Carolina",
    "Kentucky Wildcats": "Kentucky",
    "Vanderbilt Commodores": "Vanderbilt",
    "Missouri Tigers": "Missouri",
    "Texas Longhorns": "Texas",
    "Texas Tech Red Raiders": "Texas Tech",
    "Baylor Bears": "Baylor",
    "Kansas Jayhawks": "Kansas",
    "Kansas State Wildcats": "Kansas State",
    "Iowa State Cyclones": "Iowa State",
    "West Virginia Mountaineers": "West Virginia",
    "Oregon Ducks": "Oregon",
    "Oregon State Beavers": "Oregon State",
    "Washington Huskies": "Washington",
    "Washington State Cougars": "Washington State",
    "Utah Utes": "Utah",
    "Colorado Buffaloes": "Colorado",
    "Arizona Wildcats": "Arizona",
    "Arizona State Sun Devils": "Arizona State",
    "Stanford Cardinal": "Stanford",
    "California Golden Bears": "California",
    "UCLA Bruins": "UCLA",
    "Wisconsin Badgers": "Wisconsin",
    "Minnesota Golden Gophers": "Minnesota",
    "Iowa Hawkeyes": "Iowa",
    "Illinois Fighting Illini": "Illinois",
    "Northwestern Wildcats": "Northwestern",
    "Indiana Hoosiers": "Indiana",
    "Purdue Boilermakers": "Purdue",
    "Nebraska Cornhuskers": "Nebraska",
    "Rutgers Scarlet Knights": "Rutgers",
    "Maryland Terrapins": "Maryland",
    "Pittsburgh Panthers": "Pittsburgh",
    "Syracuse Orange": "Syracuse",
    "Boston College Eagles": "Boston College",
    "Wake Forest Demon Deacons": "Wake Forest",
    "Duke Blue Devils": "Duke",
    "North Carolina Tar Heels": "North Carolina",
    "Virginia Cavaliers": "Virginia",
    "Virginia Tech Hokies": "Virginia Tech",
    "Clemson Tigers": "Clemson",
    "Georgia Tech Yellow Jackets": "Georgia Tech",
    "Louisville Cardinals": "Louisville",
    "Cincinnati Bearcats": "Cincinnati",
    "Houston Cougars": "Houston",
    "UCF Knights": "UCF",
    "Memphis Tigers": "Memphis",
    "Tulane Green Wave": "Tulane",
    "Army Black Knights": "Army",
    "Navy Midshipmen": "Navy",
    "Air Force Falcons": "Air Force",
    "Boise State Broncos": "Boise State",
    "Fresno State Bulldogs": "Fresno State",
    "San Diego State Aztecs": "San Diego State",
    "Nevada Wolf Pack": "Nevada",
    "UNLV Rebels": "UNLV",
    "Utah State Aggies": "Utah State",
    "Colorado State Rams": "Colorado State",
    "Wyoming Cowboys": "Wyoming",
    "New Mexico Lobos": "New Mexico",
    "New Mexico State Aggies": "New Mexico State",
    "Hawaii Warriors": "Hawaii",
    "Liberty Flames": "Liberty",
    "James Madison Dukes": "James Madison",
    "Jacksonville State Gamecocks": "Jacksonville State",
    "Sam Houston Bearkats": "Sam Houston",
    "Kennesaw State Owls": "Kennesaw State",
};

sem NewsStory.headline = "Catchy headline for the news story";
sem NewsStory.summary = "Brief 1-2 sentence summary";
sem NewsStory.content = "Full news article content, 3-4 paragraphs";
sem NewsStory.source = "News source attribution (e.g., 'ESPN', 'Sports Illustrated')";
sem NewsStory.date = "Publication date in format 'Month Day, Year'";

"""Generate a realistic NCAA news story about a specific school."""
def generate_news_story(school: str) -> NewsStory by llm();
# END NEWS ADDITION


# --- Data Nodes ---


# --- News Walkers ---
node User {
    has username: str;
    has favorite_teams: list = [];
}


# -- Player Walker

# import:py csv;


# walker get_transfer_news {
#     can run with `root entry {
#         results: list = [];
        
#         with open("/scraping/all_teams_transfer_portal_2026.csv", "r") as f {
#             reader = csv.DictReader(f);
#             for row in reader {
#                 if row["to_school"] != "N/A" and row["status"] == "Committed" {
#                     results.append({
#                         "name": row["name"],
#                         "position": row["position"],
#                         "stars": row["stars"],
#                         "from_school": row["from_school"],
#                         "to_school": row["to_school"],
#                         "profile_url": row["profile_url"]
#                     });
#                 }
#                 if len(results) >= 10 {
#                     break;
#                 }
#             }
#         }
        
#         report results;
#     }
# }



# walker example_walker {
#     has transfer_data: list = [
#         {
#             "profile_url": "http://example.com/player1",
#             "name": "Player One",
#             "position": "Forward",
#             "height": "6'5\"",
#             "weight": "220 lbs",
#             "stars": "4",
#             "rating": "85",
#             "from_school": "School A",
#             "to_school": "School B",
#             "status": "Active"
#         },
#         {
#             "profile_url": "http://example.com/player2",
#             "name": "Player Two",
#             "position": "Guard",
#             "height": "6'1\"",
#             "weight": "190 lbs",
#             "stars": "N/A",
#             "rating": "78",
#             "from_school": "School C",
#             "to_school": "N/A",
#             "status": "Inactive"
#         }
#     ];

#     can build_transfer_cards with Root entry {
#         cards = [
#             <div className="transfer-card" key={player["profile_url"]}>
#                 <div className="transfer-card-top">
#                     <div className="player-name-row">
#                         <span className="player-name">{player["name"]}</span>
#                         <span className="player-position">{player["position"]}</span>
#                     </div>
#                     <div className="player-meta">
#                         <span className="player-physical">{player["height"]} · {player["weight"]}</span>
#                         <span className="player-stars">{player["stars"] != "N/A" ? "★" * int(player["stars"]) : ""}</span>
#                         <span className="player-rating">{player["rating"]}</span>
#                     </div>
#                 </div>
#                 <div className="transfer-route">
#                     <span className="from-school">{player["from_school"]}</span>
#                     <span className="arrow">→</span>
#                     <span className="to-school">{player["to_school"]}</span>
#                 </div>
#                 <div className="transfer-card-bottom">
#                     <span className={"status-badge status-" + player["status"].lower()}>{player["status"]}</span>
#                     <a href={player["profile_url"]} target="_blank" className="profile-link">View Profile →</a>
#                 </div>
#             </div>
#             for player in transfer_data if player["to_school"] != "N/A"
#         ];

#         report {"cards": cards};
#     }
# }
