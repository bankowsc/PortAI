import { useParams } from "react-router";
import { mockPlayers, mockTransactions } from "../data/mock-data";
import { Button } from "../components/ui/button";
import { Badge } from "../components/ui/badge";
import { Card } from "../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { ArrowRight } from "lucide-react";
import { AISummaryCard } from "../components/AISummaryCard";
import { ChatPanel } from "../components/ChatPanel";

export default function PlayerDetailPage() {
  const { id } = useParams();
  const player = mockPlayers.find((p) => p.id === id);

  if (!player) {
    return (
      <div className="text-center py-12">
        <h2 className="mb-2">Player not found</h2>
        <p className="text-muted-foreground">
          The player you're looking for doesn't exist.
        </p>
      </div>
    );
  }

  const suggestedPrompts = [
    "What are their biggest strengths?",
    "How will they fit in the new system?",
    "Compare them to current roster players",
    "What's their projected impact?",
  ];

  return (
    <div className="space-y-6">
      {/* Player Header */}
      <Card className="p-8">
        <div className="flex items-start gap-8">
          <div className="text-8xl">{player.photo}</div>
          <div className="flex-1">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h1 className="mb-2">{player.name}</h1>
                <div className="flex items-center gap-3 mb-3">
                  <Badge variant="outline" className="text-base">
                    {player.position}
                  </Badge>
                  <span className="text-muted-foreground">{player.class}</span>
                </div>
                <div className="flex items-center gap-2">
                  {Array.from({ length: player.starRating }).map((_, i) => (
                    <span key={i} className="text-accent text-xl">
                      ⭐
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
              <div>
                <p className="text-sm text-muted-foreground mb-1">Height</p>
                <p>{player.height}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground mb-1">Weight</p>
                <p>{player.weight}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground mb-1">Class</p>
                <p>{player.class}</p>
              </div>
              {player.nilValue && (
                <div>
                  <p className="text-sm text-muted-foreground mb-1">
                    NIL Value
                  </p>
                  <p className="text-accent">{player.nilValue}</p>
                </div>
              )}
            </div>

            {/* Transfer Info */}
            <div className="bg-muted p-4 rounded-lg">
              <p className="text-sm text-muted-foreground mb-3">
                Transfer History
              </p>
              <div className="flex items-center gap-4">
                <div className="text-center">
                  <p className="text-sm mb-1">Previous Team</p>
                  <p>{player.previousTeam}</p>
                </div>
                <ArrowRight className="w-6 h-6 text-accent" />
                <div className="text-center">
                  <p className="text-sm mb-1">Current Team</p>
                  <p>{player.currentTeam}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Card>

      {/* Main Content with Chat */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Tabs Content */}
        <div className="lg:col-span-2">
          <Tabs defaultValue="stats" className="space-y-6">
            <TabsList className="bg-white border border-border">
              <TabsTrigger value="stats">Stats</TabsTrigger>
              <TabsTrigger value="history">Transfer History</TabsTrigger>
              <TabsTrigger value="scouting">Scouting Report</TabsTrigger>
              <TabsTrigger value="ai">AI Analysis</TabsTrigger>
            </TabsList>

            <TabsContent value="stats" className="space-y-6">
              <Card className="p-6">
                <h3 className="mb-4">Career Statistics</h3>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
                  {Object.entries(player.stats).map(([key, value]) => (
                    <div key={key} className="text-center p-4 bg-muted rounded-lg">
                      <p className="text-3xl text-accent mb-1">{value}</p>
                      <p className="text-sm text-muted-foreground capitalize">
                        {key}
                      </p>
                    </div>
                  ))}
                </div>
              </Card>

              <Card className="p-6">
                <h3 className="mb-4">Season Performance Trend</h3>
                <div className="h-64 flex items-center justify-center text-muted-foreground">
                  Performance chart visualization coming soon
                </div>
              </Card>
            </TabsContent>

            <TabsContent value="history">
              <Card className="p-6">
                <h3 className="mb-4">Transfer Timeline</h3>
                <div className="space-y-6">
                  <div className="relative pl-8 pb-6 border-l-2 border-accent">
                    <div className="absolute left-[-9px] top-0 w-4 h-4 bg-accent rounded-full"></div>
                    <p className="text-sm text-muted-foreground mb-1">
                      February 2026
                    </p>
                    <p className="mb-2">
                      Transferred to {player.currentTeam}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      Entered transfer portal and committed to new program
                    </p>
                  </div>
                  <div className="relative pl-8 border-l-2 border-border">
                    <div className="absolute left-[-9px] top-0 w-4 h-4 bg-muted rounded-full"></div>
                    <p className="text-sm text-muted-foreground mb-1">
                      2023-2025
                    </p>
                    <p className="mb-2">Played for {player.previousTeam}</p>
                    <p className="text-sm text-muted-foreground">
                      Developed into a key contributor over multiple seasons
                    </p>
                  </div>
                </div>
              </Card>
            </TabsContent>

            <TabsContent value="scouting">
              <Card className="p-6">
                <h3 className="mb-4">Scouting Report</h3>
                <div className="space-y-6">
                  <div>
                    <h4 className="mb-3">Strengths</h4>
                    <div className="flex flex-wrap gap-2">
                      <Badge className="bg-accent/10 text-accent border-accent/20">
                        Speed
                      </Badge>
                      <Badge className="bg-accent/10 text-accent border-accent/20">
                        Field Vision
                      </Badge>
                      <Badge className="bg-accent/10 text-accent border-accent/20">
                        Leadership
                      </Badge>
                      <Badge className="bg-accent/10 text-accent border-accent/20">
                        Consistency
                      </Badge>
                    </div>
                  </div>

                  <div>
                    <h4 className="mb-3">Areas for Growth</h4>
                    <div className="flex flex-wrap gap-2">
                      <Badge variant="outline">Ball Security</Badge>
                      <Badge variant="outline">Pass Blocking</Badge>
                    </div>
                  </div>

                  <div>
                    <h4 className="mb-2">Overall Assessment</h4>
                    <p className="text-muted-foreground">
                      High-impact player with proven production at previous
                      program. Brings immediate value and veteran presence.
                      Should compete for starting role and contribute across
                      multiple situations.
                    </p>
                  </div>
                </div>
              </Card>
            </TabsContent>

            <TabsContent value="ai">
              <AISummaryCard
                title="AI-Powered Player Analysis"
                content={`${player.name} represents a significant addition with a ${player.starRating}-star rating and proven production. Statistical analysis shows consistent performance trends with ${player.stats.yards || player.stats.ppg || "strong"} output. Projected impact: High - should immediately compete for significant playing time. Fit assessment: Excellent match for ${player.currentTeam}'s system based on playing style and positional needs. Risk level: Low - experienced player with track record of success.`}
              />

              <Card className="p-6 mt-6">
                <h3 className="mb-4">Projected Season Statistics</h3>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  {Object.entries(player.stats).map(([key, value]) => (
                    <div key={key} className="text-center p-4 bg-accent/5 rounded-lg border border-accent/20">
                      <p className="text-2xl text-accent mb-1">
                        {typeof value === "number" ? Math.round(value * 1.15) : value}
                      </p>
                      <p className="text-xs text-muted-foreground capitalize">
                        Projected {key}
                      </p>
                    </div>
                  ))}
                </div>
              </Card>
            </TabsContent>
          </Tabs>
        </div>

        {/* Chat Panel */}
        <div className="lg:col-span-1">
          <div className="sticky top-24">
            <ChatPanel
              title={`Ask Portal AI About ${player.name}`}
              suggestedPrompts={suggestedPrompts}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
