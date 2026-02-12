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
    has favorite_words: list = [];
}

# walker get_current_user {
#     can with Root entry {
#         current_name = visitor;

#         for u in here --> User {
#             if u.username == current_name {
#                 report u;
#                 return;
#             }
#         }

#         new_user = User(username=current_name);
#         here ++> new_user;
#         report new_user;
#     }
# }

# walker:pub update_favorites {
#     has new_favorites: list;

#     can with Root entry {
#         current_name = visitor;

#         for u in here --> User {
#             if u.username == current_name {
#                 u.favorite_words = self.new_favorites;
#                 report {"status": "updated"};
#                 return;
#             }
#         }
#     }
# }
