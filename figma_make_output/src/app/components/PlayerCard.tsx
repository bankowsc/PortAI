import { Card } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { ArrowRight } from "lucide-react";
import { Link } from "react-router";
import type { Player } from "../data/mock-data";

interface PlayerCardProps {
  player: Player;
}

export function PlayerCard({ player }: PlayerCardProps) {
  return (
    <Card className="p-6 hover:shadow-lg transition-shadow">
      <div className="flex items-start gap-4 mb-4">
        <div className="text-5xl">{player.photo}</div>
        <div className="flex-1">
          <h3 className="mb-1">{player.name}</h3>
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Badge variant="outline">{player.position}</Badge>
            <span>•</span>
            <span>{player.class}</span>
          </div>
          <div className="flex items-center gap-1 mt-2">
            {Array.from({ length: player.starRating }).map((_, i) => (
              <span key={i} className="text-accent">
                ⭐
              </span>
            ))}
          </div>
        </div>
      </div>

      <div className="space-y-2 mb-4">
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">Current Team</span>
          <span>{player.currentTeam}</span>
        </div>
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">Previous Team</span>
          <span>{player.previousTeam}</span>
        </div>
        {player.nilValue && (
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">NIL Value</span>
            <span className="text-accent">{player.nilValue}</span>
          </div>
        )}
      </div>

      <Link to={`/players/${player.id}`}>
        <Button
          variant="outline"
          className="w-full rounded-lg border-accent text-accent hover:bg-accent hover:text-accent-foreground"
        >
          View Profile
        </Button>
      </Link>
    </Card>
  );
}