import from byllm.lib { Model }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

obj NewsStory {
    has headline: str;
    has summary: str;
    has content: str;
    has source: str;
    has date: str;
}

sem NewsStory.headline = "Catchy headline for the news story";
sem NewsStory.summary = "Brief 4-5 sentence summary";
sem NewsStory.content = "Full news article content, 3-4 paragraphs";
sem NewsStory.source = "News source attribution";
sem NewsStory.date = "Publication date in format 'Month Day, Year'";

def generate_news_story(school: str) -> NewsStory by llm();

with entry {
    result = generate_news_story("Michigan Wolverines");
    print(result.headline);
    print(result.summary);
}
