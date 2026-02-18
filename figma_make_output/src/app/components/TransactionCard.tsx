import { Card } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { ArrowRight, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";
import type { Transaction } from "../data/mock-data";

interface TransactionCardProps {
  transaction: Transaction;
}

export function TransactionCard({ transaction }: TransactionCardProps) {
  const [showAIImpact, setShowAIImpact] = useState(false);

  return (
    <Card className="p-6 hover:shadow-md transition-shadow">
      <div className="flex items-start gap-4">
        <div className="text-4xl">{transaction.playerPhoto}</div>
        <div className="flex-1">
          <div className="flex items-start justify-between mb-2">
            <div>
              <h3 className="mb-1">{transaction.playerName}</h3>
              <Badge variant="outline" className="mb-2">
                {transaction.position}
              </Badge>
            </div>
            <div className="flex items-center gap-1">
              {Array.from({ length: transaction.starRating }).map((_, i) => (
                <span key={i} className="text-accent text-sm">
                  ⭐
                </span>
              ))}
            </div>
          </div>

          <div className="flex items-center gap-3 mb-3">
            <div className="flex items-center gap-2">
              <span className="text-2xl">{transaction.fromTeamLogo}</span>
              <span className="text-sm text-muted-foreground">
                {transaction.fromTeam}
              </span>
            </div>
            <ArrowRight className="w-5 h-5 text-accent" />
            <div className="flex items-center gap-2">
              <span className="text-2xl">{transaction.toTeamLogo}</span>
              <span className="text-sm">{transaction.toTeam}</span>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="flex gap-4 mb-3 text-sm">
            {Object.entries(transaction.stats).map(([key, value]) => (
              <div key={key}>
                <span className="text-muted-foreground capitalize">{key}: </span>
                <span>{value}</span>
              </div>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground">
              {new Date(transaction.date).toLocaleDateString("en-US", {
                month: "short",
                day: "numeric",
                year: "numeric",
              })}
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="ghost"
                size="sm"
                className="text-accent hover:text-accent"
                onClick={() => setShowAIImpact(!showAIImpact)}
              >
                {showAIImpact ? (
                  <>
                    <ChevronUp className="w-4 h-4 mr-1" />
                    Hide AI Impact
                  </>
                ) : (
                  <>
                    <ChevronDown className="w-4 h-4 mr-1" />
                    AI Impact
                  </>
                )}
              </Button>
              <Button variant="outline" size="sm" className="rounded-lg">
                View Details
              </Button>
            </div>
          </div>

          {/* AI Impact Section */}
          {showAIImpact && (
            <div className="mt-4 p-4 bg-accent/5 rounded-lg border border-accent/20">
              <div className="flex items-start gap-2">
                <Badge className="bg-accent text-accent-foreground text-xs">
                  AI Generated
                </Badge>
                <p className="text-sm flex-1">
                  This transfer significantly strengthens {transaction.toTeam}'s
                  {transaction.position} position. Expected to contribute
                  immediately based on previous performance metrics.
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </Card>
  );
}