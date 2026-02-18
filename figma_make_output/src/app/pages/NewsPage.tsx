import { Card } from "../components/ui/card";
import { Newspaper } from "lucide-react";

export default function NewsPage() {
  const newsArticles = [
    {
      id: "1",
      title: "Record-Breaking Transfer Portal Week",
      summary: "247 players entered the portal, marking the highest single-week total of the season.",
      date: "Feb 17, 2026",
      category: "Trending",
    },
    {
      id: "2",
      title: "Top QB Commits to Alabama",
      summary: "5-star quarterback Marcus Johnson finalizes transfer to Crimson Tide.",
      date: "Feb 16, 2026",
      category: "Transfer News",
    },
    {
      id: "3",
      title: "SEC Dominates Portal Activity",
      summary: "Conference leads all others with 89 total transfers this month.",
      date: "Feb 15, 2026",
      category: "Analysis",
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">Transfer Portal News</h1>
        <p className="text-muted-foreground">
          Latest news and updates from the transfer portal
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {newsArticles.map((article) => (
          <Card key={article.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
            <div className="flex items-start gap-3 mb-3">
              <Newspaper className="w-5 h-5 text-accent" />
              <span className="text-xs text-accent">{article.category}</span>
            </div>
            <h3 className="mb-2">{article.title}</h3>
            <p className="text-sm text-muted-foreground mb-4">
              {article.summary}
            </p>
            <p className="text-xs text-muted-foreground">{article.date}</p>
          </Card>
        ))}
      </div>
    </div>
  );
}
