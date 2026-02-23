"""PortAI - Transfer Portal Intelligence."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> JsxElement {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import json;

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# Import mock data for building LLM context
glob mock_teams_data: list = [
    {"id": "1", "name": "Alabama Crimson Tide", "conference": "SEC", "portalActivityScore": 92, "lastSeasonRecord": "12-2", "incomingCount": 8, "outgoingCount": 5},
    {"id": "2", "name": "Ohio State Buckeyes", "conference": "Big Ten", "portalActivityScore": 88, "lastSeasonRecord": "11-2", "incomingCount": 7, "outgoingCount": 6},
    {"id": "3", "name": "Georgia Bulldogs", "conference": "SEC", "portalActivityScore": 85, "lastSeasonRecord": "13-1", "incomingCount": 6, "outgoingCount": 4},
    {"id": "4", "name": "Michigan Wolverines", "conference": "Big Ten", "portalActivityScore": 82, "lastSeasonRecord": "10-3", "incomingCount": 9, "outgoingCount": 7},
    {"id": "5", "name": "USC Trojans", "conference": "Big Ten", "portalActivityScore": 79, "lastSeasonRecord": "8-5", "incomingCount": 10, "outgoingCount": 8},
    {"id": "6", "name": "Texas Longhorns", "conference": "SEC", "portalActivityScore": 86, "lastSeasonRecord": "12-2", "incomingCount": 5, "outgoingCount": 3},
    {"id": "7", "name": "Oregon Ducks", "conference": "Big Ten", "portalActivityScore": 84, "lastSeasonRecord": "11-3", "incomingCount": 6, "outgoingCount": 5},
    {"id": "8", "name": "Florida State Seminoles", "conference": "ACC", "portalActivityScore": 75, "lastSeasonRecord": "13-1", "incomingCount": 4, "outgoingCount": 9}
];

glob mock_transactions_data: list = [
    {"playerName": "Marcus Johnson", "position": "QB", "fromTeam": "USC Trojans", "toTeam": "Alabama Crimson Tide", "starRating": 5, "stats": "3245 yards, 28 TDs", "date": "Feb 15, 2026"},
    {"playerName": "DeAndre Williams", "position": "WR", "fromTeam": "Florida State Seminoles", "toTeam": "Ohio State Buckeyes", "starRating": 4, "stats": "982 yards, 12 TDs", "date": "Feb 14, 2026"},
    {"playerName": "Tyler Anderson", "position": "RB", "fromTeam": "Michigan Wolverines", "toTeam": "Georgia Bulldogs", "starRating": 4, "stats": "1456 yards, 18 TDs", "date": "Feb 13, 2026"},
    {"playerName": "Jamal Carter", "position": "LB", "fromTeam": "Oregon Ducks", "toTeam": "Texas Longhorns", "starRating": 5, "stats": "98 tackles, 12 sacks", "date": "Feb 12, 2026"},
    {"playerName": "Brandon Davis", "position": "DB", "fromTeam": "Alabama Crimson Tide", "toTeam": "USC Trojans", "starRating": 4, "stats": "76 tackles, 4 INTs", "date": "Feb 11, 2026"}
];

glob portal_stats_context: str = "Total transfers this week: 247. Top positions entering portal: WR (45), DB (41), LB (38), RB (34), QB (23). Most active conferences: SEC (89 transfers), Big Ten (76), ACC (54), Big 12 (48), Pac-12 (42).";

# --- AI Types ---

obj AISummary {
    has title: str;
    has content: str;
}

sem AISummary.title = "A concise, descriptive title for the AI summary";
sem AISummary.content = "A detailed 3-5 sentence analysis paragraph about college transfer portal activity";

obj NewsStory {
    has headline: str;
    has summary: str;
    has content: str;
    has source: str;
    has date: str;
    has category: str;
}

sem NewsStory.headline = "Catchy headline for the news story about NCAA transfer portal";
sem NewsStory.summary = "Brief 1-2 sentence summary of the story";
sem NewsStory.content = "Full news article content, 3-4 paragraphs";
sem NewsStory.source = "News source attribution (e.g., 'ESPN', 'Sports Illustrated', '247Sports')";
sem NewsStory.date = "Publication date in format 'Month Day, Year'";
sem NewsStory.category = "Category like 'Transfer News', 'Analysis', 'Trending', 'Recruiting'";

obj PlayerAnalysis {
    has strengths: list;
    has areas_for_growth: list;
    has overall_assessment: str;
    has projected_impact: str;
    has fit_rating: str;
}

sem PlayerAnalysis.strengths = "List of 3-5 key strengths as strings";
sem PlayerAnalysis.areas_for_growth = "List of 2-3 areas for improvement as strings";
sem PlayerAnalysis.overall_assessment = "2-3 sentence overall assessment of the player";
sem PlayerAnalysis.projected_impact = "One sentence about projected impact at new team";
sem PlayerAnalysis.fit_rating = "Rating: 'Excellent', 'Good', 'Moderate', or 'Uncertain'";

obj TeamAnalysis {
    has portal_strategy: str;
    has key_additions: str;
    has key_losses: str;
    has outlook: str;
    has risk_level: str;
}

sem TeamAnalysis.portal_strategy = "2-3 sentence description of team's portal strategy";
sem TeamAnalysis.key_additions = "Summary of most impactful incoming transfers";
sem TeamAnalysis.key_losses = "Summary of most significant departures";
sem TeamAnalysis.outlook = "2-3 sentence outlook for next season based on portal activity";
sem TeamAnalysis.risk_level = "Risk level: 'Low', 'Moderate', or 'High'";

obj ChatResponse {
    has response: str;
}

sem ChatResponse.response = "A helpful, informative response about NCAA transfer portal. Should be 2-4 sentences, conversational but factual. Reference specific teams, players, or statistics when possible.";

obj PortalOverview {
    has title: str;
    has content: str;
}

sem PortalOverview.title = "A short, engaging title summarizing the current transfer portal landscape (5-10 words). If favorite teams are provided, the title should reflect activity related to those teams. Example: 'SEC Heavyweights Shake Up the Portal' or 'Your Teams Are Making Moves'";
sem PortalOverview.content = "A 3-5 sentence analysis paragraph about recent NCAA college sports transfer portal activity. Reference specific team names, player names, positions, star ratings, and statistics from the provided context. Mention notable trends like which conferences are most active, which positions are in high demand, and significant player movements. If favorite teams are provided, focus the analysis on how portal activity impacts those specific teams. Be informative yet conversational, suitable for a sports analytics dashboard.";

"""Generate a transfer portal overview summary.
You are PortAI, an expert NCAA transfer portal analyst.
Use the provided portal_context to generate an insightful summary of recent transfer portal activity.
The context includes real data about teams, players, recent transactions, and portal statistics.
If favorite_teams_context is provided, prioritize analysis of those teams."""
def generate_portal_overview(
    portal_context: str,
    favorite_teams_context: str
) -> PortalOverview by llm();

"""Generate an AI summary for the transfer portal overview."""
def generate_summary(context: str) -> AISummary by llm();

"""Generate a news story about NCAA transfer portal activity."""
def generate_news_story(topic: str) -> NewsStory by llm();

"""Generate a player scouting analysis."""
def generate_player_analysis(player_info: str) -> PlayerAnalysis by llm();

"""Generate a team transfer portal analysis."""
def generate_team_analysis(team_info: str) -> TeamAnalysis by llm();

"""Generate a chat response about transfer portal topics."""
def generate_chat_response(question: str) -> ChatResponse by llm();


# --- Data Nodes ---

node User {
    has username: str;
    has favorite_team_ids: list = [];
}


# --- Server Walkers ---

walker:pub get_ai_summary {
    has context: str;

    can with Root entry {
        result = generate_summary(self.context);
        report {"title": result.title, "content": result.content};
    }
}

walker:pub get_news {
    has topic: str = "latest NCAA transfer portal activity";

    can with Root entry {
        result = generate_news_story(self.topic);
        report {
            "headline": result.headline,
            "summary": result.summary,
            "content": result.content,
            "source": result.source,
            "date": result.date,
            "category": result.category
        };
    }
}

walker:pub get_player_analysis {
    has player_info: str;

    can with Root entry {
        result = generate_player_analysis(self.player_info);
        report {
            "strengths": result.strengths,
            "areas_for_growth": result.areas_for_growth,
            "overall_assessment": result.overall_assessment,
            "projected_impact": result.projected_impact,
            "fit_rating": result.fit_rating
        };
    }
}

walker:pub get_team_analysis {
    has team_info: str;

    can with Root entry {
        result = generate_team_analysis(self.team_info);
        report {
            "portal_strategy": result.portal_strategy,
            "key_additions": result.key_additions,
            "key_losses": result.key_losses,
            "outlook": result.outlook,
            "risk_level": result.risk_level
        };
    }
}

walker:pub chat {
    has question: str;

    can with Root entry {
        result = generate_chat_response(self.question);
        report {"response": result.response};
    }
}

walker:priv get_portal_summary {
    has favorite_team_ids: list = [];
    has found_user: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can load_user with User entry {
        if not self.found_user {
            self.found_user = True;
            self.favorite_team_ids = here.favorite_team_ids;
        }
    }

    can generate with Root exit {
        # Build the portal context string from mock data
        teams_summary = "";
        for t in mock_teams_data {
            teams_summary = teams_summary + t["name"] + " (" + t["conference"] + "): Portal Activity Score " + str(t["portalActivityScore"]) + ", Record " + t["lastSeasonRecord"] + ", Incoming " + str(t["incomingCount"]) + ", Outgoing " + str(t["outgoingCount"]) + ". ";
        }

        transactions_summary = "";
        for tx in mock_transactions_data {
            transactions_summary = transactions_summary + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + " (" + tx["stats"] + ", " + tx["date"] + "). ";
        }

        portal_context = "PORTAL STATISTICS: " + portal_stats_context + " TEAM ACTIVITY: " + teams_summary + " RECENT TRANSACTIONS: " + transactions_summary;

        # Build favorite teams context if user has favorites
        fav_context = "";
        if len(self.favorite_team_ids) > 0 {
            fav_context = "USER'S FAVORITE TEAMS: ";
            for t in mock_teams_data {
                if t["id"] in self.favorite_team_ids {
                    fav_context = fav_context + t["name"] + " (" + t["conference"] + ", Record: " + t["lastSeasonRecord"] + ", Incoming: " + str(t["incomingCount"]) + ", Outgoing: " + str(t["outgoingCount"]) + ", Activity Score: " + str(t["portalActivityScore"]) + "). ";
                }
            }
            # Include transactions involving favorite teams
            fav_context = fav_context + "TRANSACTIONS INVOLVING FAVORITE TEAMS: ";
            fav_team_names: list = [];
            for t in mock_teams_data {
                if t["id"] in self.favorite_team_ids {
                    fav_team_names.append(t["name"]);
                }
            }
            for tx in mock_transactions_data {
                if tx["fromTeam"] in fav_team_names or tx["toTeam"] in fav_team_names {
                    fav_context = fav_context + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + ". ";
                }
            }
        }

        result = generate_portal_overview(
            portal_context=portal_context,
            favorite_teams_context=fav_context
        );

        report {"title": result.title, "content": result.content};
    }
}

walker:priv update_favorites {
    has new_favorites: list;
    has found: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can update with User entry {
        if not self.found {
            here.favorite_team_ids = self.new_favorites;
            self.found = True;
            report {"status": "updated", "favorites": here.favorite_team_ids};
        }
    }

    can create_if_needed with Root exit {
        if not self.found {
            new_user = here ++> User(username="default", favorite_team_ids=self.new_favorites);
            report {"status": "created", "favorites": new_user[0].favorite_team_ids};
        }
    }
}

walker:priv get_user_favorites {
    has found: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can get_favs with User entry {
        if not self.found {
            self.found = True;
            report {"favorites": here.favorite_team_ids};
        }
    }

    can default_if_none with Root exit {
        if not self.found {
            report {"favorites": []};
        }
    }
}
