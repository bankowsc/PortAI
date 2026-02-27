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
    has rival_teams: list = [];
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
