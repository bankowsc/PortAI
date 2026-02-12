"""PortAI - Ai for NCAA fans."""

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

node NewsArticle {
    has id: str,
        school: str,
        headline: str,
        summary: str,
        content: str,
        source: str,
        date: str;
}

# --- News Walkers ---

walker:priv GenerateNewsWalker {
    has school: str;

    
    can generate with `root entry {
        # Call LLM to generate news story
        # visit [-->];

        # print("This prints to Jac runtime console 4");
        news = generate_news_story(self.school);
        # print("This prints to Jac runtime console 5");

        # Create news article node
        new_article = here ++> NewsArticle(
            id=str(uuid4()),
            school=self.school,
            headline=news.headline,
            summary=news.summary,
            content=news.content,
            source=news.source,
            date=news.date
        );
        
        # Return the news story
        report {
            "id": new_article[0].id,
            "school": new_article[0].school,
            "headline": new_article[0].headline,
            "summary": new_article[0].summary,
            "content": new_article[0].content,
            "source": new_article[0].source,
            "date": new_article[0].date
        };
    }
}

walker:priv ListNews {
    has articles: list = [];
    
    can collect with `root entry {
        visit [-->];
    }
    
    can gather with NewsArticle entry {
        self.articles.append({
            "id": here.id,
            "school": here.school,
            "headline": here.headline,
            "summary": here.summary,
            "content": here.content,
            "source": here.source,
            "date": here.date
        });
    }
    
    can report_all with `root exit {
        report self.articles;
    }
}

walker:priv DeleteNews {
    has article_id: str;
    
    can search with `root entry {
        visit [-->];
    }
    
    can delete with NewsArticle entry {
        if here.id == self.article_id {
            del here;
            report {"deleted": self.article_id};
        }
    }
}
