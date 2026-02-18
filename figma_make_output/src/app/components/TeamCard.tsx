import { Card } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Star } from "lucide-react";
import { Link } from "react-router";
import type { Team } from "../data/mock-data";

interface TeamCardProps {
  team: Team;
  isFavorite?: boolean;
  onToggleFavorite?: (teamId: string) => void;
}

export function TeamCard({ team, isFavorite, onToggleFavorite }: TeamCardProps) {
  return (
    <Card className="p-6 hover:shadow-lg transition-shadow">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="text-4xl">{team.logo}</div>
          <div>
            <h3 className="mb-1">{team.name}</h3>
            <p className="text-sm text-muted-foreground">{team.conference}</p>
          </div>
        </div>
        <Button
          variant="ghost"
          size="icon"
          className="rounded-lg"
          onClick={() => onToggleFavorite?.(team.id)}
        >
          <Star
            className={`w-5 h-5 ${
              isFavorite ? "fill-accent text-accent" : ""
            }`}
          />
        </Button>
      </div>

      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Portal Activity</span>
          <Badge
            variant={team.portalActivityScore >= 85 ? "default" : "secondary"}
            className={
              team.portalActivityScore >= 85
                ? "bg-accent text-accent-foreground"
                : ""
            }
          >
            {team.portalActivityScore}
          </Badge>
        </div>

        <div className="flex gap-4 text-sm">
          <div className="flex-1 text-center py-2 bg-muted rounded-lg">
            <div className="text-accent">{team.incomingCount}</div>
            <div className="text-xs text-muted-foreground">Incoming</div>
          </div>
          <div className="flex-1 text-center py-2 bg-muted rounded-lg">
            <div className="text-destructive">{team.outgoingCount}</div>
            <div className="text-xs text-muted-foreground">Outgoing</div>
          </div>
        </div>

        <Link to={`/teams/${team.id}`}>
          <Button className="w-full rounded-lg bg-primary hover:bg-primary/90">
            View Team
          </Button>
        </Link>
      </div>
    </Card>
  );
}