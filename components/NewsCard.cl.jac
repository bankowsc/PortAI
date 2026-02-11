"""News Card component for displaying generated news articles."""

def:pub NewsCard(article: dict, onDelete: any) -> any {
    return
        <div className="news-card">
            <div className="news-card-header">
                <div className="news-meta">
                    <span className="news-source">{article.source}</span>
                    <span className="news-date">{article.date}</span>
                </div>
                <button
                    onClick={lambda -> None { onDelete(article.id); }}
                    className="news-delete-btn"
                    title="Delete article"
                >
                    ×
                </button>
            </div>
            
            <h3 className="news-headline">{article.headline}</h3>
            
            <div className="news-school-badge">
                🏈 {article.school}
            </div>
            
            <p className="news-summary">{article.summary}</p>
            
            <div className="news-content">
                {article.content.split("\n").map(
                    lambda paragraph: str -> any {
                        return <p key={paragraph}>{paragraph}</p>;
                    }
                )}
            </div>
        </div>;
}
