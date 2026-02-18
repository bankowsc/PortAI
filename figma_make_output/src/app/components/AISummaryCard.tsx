import { Card } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Sparkles, RefreshCw } from "lucide-react";

interface AISummaryCardProps {
  title: string;
  content: string;
  onRegenerate?: () => void;
  timestamp?: string;
}

export function AISummaryCard({
  title,
  content,
  onRegenerate,
  timestamp = new Date().toISOString(),
}: AISummaryCardProps) {
  return (
    <Card className="p-6 bg-gradient-to-br from-accent/5 to-primary/5 border-accent/20">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-2">
          <Sparkles className="w-5 h-5 text-accent" />
          <h2>{title}</h2>
        </div>
        <Badge variant="secondary" className="bg-accent/10 text-accent border-accent/20">
          AI Generated
        </Badge>
      </div>

      <p className="text-muted-foreground leading-relaxed mb-4">{content}</p>

      <div className="flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          Updated{" "}
          {new Date(timestamp).toLocaleTimeString("en-US", {
            hour: "numeric",
            minute: "2-digit",
          })}
        </span>
        {onRegenerate && (
          <Button
            variant="ghost"
            size="sm"
            className="text-accent hover:text-accent"
            onClick={onRegenerate}
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            Regenerate Summary
          </Button>
        )}
      </div>
    </Card>
  );
}