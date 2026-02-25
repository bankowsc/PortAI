"""AI Summary Card component - displays AI-generated analysis."""

import from '@fortawesome/react-fontawesome' { FontAwesomeIcon }
import from '@fortawesome/free-solid-svg-icons' { faArrowsRotate }

def:pub AISummaryCard(
    title: str,
    content: str,
    onRegenerate: any = None,
    loading: bool = False
) -> any {
    return
        <div className="ai-summary-card">
            <div className="ai-summary-header">
                <div className="ai-summary-title">
                    <span className="sparkle-icon">✨</span>
                    <h2>{title}</h2>
                </div>
                <span className="badge badge-accent">AI Generated</span>
            </div>

            {(
                <div className="loading-overlay">
                    <div className="spinner"></div>
                    <span>Generating AI summary...</span>
                </div>
            ) if loading else
                <p className="ai-summary-content">{content}</p>
            }

            <div className="ai-summary-footer">
                <span className="ai-summary-timestamp">
                    Updated just now
                </span>
                {(
                    <button className="btn-regenerate"
                            onClick={lambda -> None { onRegenerate(); }}
                            disabled={loading}>
                            <FontAwesomeIcon icon={faArrowsRotate} /> Regenerate Summary
                    </button>
                ) if onRegenerate else None}
            </div>
        </div>;
}
