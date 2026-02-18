import { useParams } from "react-router";
import { mockTeams, mockPlayers, mockTransactions } from "../data/mock-data";
import { Button } from "../components/ui/button";
import { Badge } from "../components/ui/badge";
import { Card } from "../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { Star, TrendingUp, TrendingDown } from "lucide-react";
import { useState } from "react";
import { AISummaryCard } from "../components/AISummaryCard";
import { PlayerCard } from "../components/PlayerCard";
import { ChatPanel } from "../components/ChatPanel";

export default function TeamDetailPage() {
  const { id } = useParams();
  const team = mockTeams.find((t) => t.id === id);
  const [isFavorite, setIsFavorite] = useState(false);

  if (!team) {
    return (
      <div className="text-center py-12">
        <h2 className="mb-2">Team not found</h2>
        <p className="text-muted-foreground">
          The team you're looking for doesn't exist.
        </p>
      </div>
    );
  }

  const incomingPlayers = mockPlayers.filter(
    (p) => p.currentTeam === team.name
  );
  const outgoingPlayers = mockPlayers.filter(
    (p) => p.previousTeam === team.name
  );

  const suggestedPrompts = [
    "How will this affect their starting lineup?",
    "Did they improve from last season?",
    "Who replaces their top scorer?",
    "What are the biggest needs remaining?",
  ];

  return (
    <div className="space-y-6">
      {/* Hero Section */}
      <Card className="p-8">
        <div className="flex items-start justify-between mb-6">
          <div className="flex items-center gap-6">
            <div className="text-7xl">{team.logo}</div>
            <div>
              <h1 className="mb-2">{team.name}</h1>
              <div className="flex items-center gap-4 text-muted-foreground">
                <span>{team.conference}</span>
                <span>•</span>
                <span>{team.lastSeasonRecord} Last Season</span>
              </div>
            </div>
          </div>
          <Button
            variant={isFavorite ? "default" : "outline"}
            className={`rounded-lg ${
              isFavorite ? "bg-accent hover:bg-accent/90" : ""
            }`}
            onClick={() => setIsFavorite(!isFavorite)}
          >
            <Star
              className={`w-5 h-5 mr-2 ${isFavorite ? "fill-current" : ""}`}
            />
            {isFavorite ? "Favorited" : "Add to Favorites"}
          </Button>
        </div>

        {/* Portal Activity Meter */}
        <div className="bg-muted p-6 rounded-lg">
          <div className="flex items-center justify-between mb-3">
            <h3>Portal Activity Score</h3>
            <Badge
              variant={team.portalActivityScore >= 85 ? "default" : "secondary"}
              className={`text-lg px-4 py-1 ${
                team.portalActivityScore >= 85
                  ? "bg-accent text-accent-foreground"
                  : ""
              }`}
            >
              {team.portalActivityScore}
            </Badge>
          </div>
          <div className="w-full h-3 bg-background rounded-full overflow-hidden">
            <div
              className="h-full bg-accent rounded-full transition-all"
              style={{ width: `${team.portalActivityScore}%` }}
            ></div>
          </div>
          <div className="flex justify-between mt-2 text-xs text-muted-foreground">
            <span>Low Activity</span>
            <span>High Activity</span>
          </div>
        </div>
      </Card>

      {/* Main Content with Chat */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Tabs Content */}
        <div className="lg:col-span-2">
          <Tabs defaultValue="overview" className="space-y-6">
            <TabsList className="bg-white border border-border">
              <TabsTrigger value="overview">Overview</TabsTrigger>
              <TabsTrigger value="incoming">Incoming Transfers</TabsTrigger>
              <TabsTrigger value="outgoing">Outgoing Transfers</TabsTrigger>
              <TabsTrigger value="depth">Depth Chart</TabsTrigger>
              <TabsTrigger value="stats">Stats</TabsTrigger>
              <TabsTrigger value="ai">AI Insights</TabsTrigger>
            </TabsList>

            <TabsContent value="overview" className="space-y-6">
              <AISummaryCard
                title="Team Portal Activity Overview"
                content={`${team.name} is showing ${
                  team.portalActivityScore >= 85 ? "high" : "moderate"
                } portal activity with ${team.incomingCount} incoming and ${
                  team.outgoingCount
                } outgoing transfers. The team has strategically added talent in key positions while managing roster departures effectively. Overall impact rating: ${
                  team.portalActivityScore >= 85 ? "High" : "Moderate"
                }.`}
              />

              {/* Quick Stats */}
              <div className="grid grid-cols-2 gap-4">
                <Card className="p-6">
                  <div className="flex items-center gap-3 mb-2">
                    <TrendingUp className="w-5 h-5 text-accent" />
                    <h3>Incoming Transfers</h3>
                  </div>
                  <p className="text-4xl text-accent">{team.incomingCount}</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    New additions
                  </p>
                </Card>
                <Card className="p-6">
                  <div className="flex items-center gap-3 mb-2">
                    <TrendingDown className="w-5 h-5 text-destructive" />
                    <h3>Outgoing Transfers</h3>
                  </div>
                  <p className="text-4xl text-destructive">
                    {team.outgoingCount}
                  </p>
                  <p className="text-sm text-muted-foreground mt-1">
                    Departures
                  </p>
                </Card>
              </div>

              {/* Player Lists */}
              <div className="space-y-6">
                <div>
                  <h3 className="mb-4">Top Incoming Players</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {incomingPlayers.slice(0, 4).map((player) => (
                      <PlayerCard key={player.id} player={player} />
                    ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="incoming" className="space-y-4">
              <h3>Incoming Transfer Players</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {incomingPlayers.map((player) => (
                  <PlayerCard key={player.id} player={player} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="outgoing" className="space-y-4">
              <h3>Outgoing Transfer Players</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {outgoingPlayers.map((player) => (
                  <PlayerCard key={player.id} player={player} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="depth">
              <Card className="p-8 text-center">
                <h3 className="mb-2">Depth Chart</h3>
                <p className="text-muted-foreground">
                  Depth chart visualization coming soon
                </p>
              </Card>
            </TabsContent>

            <TabsContent value="stats">
              <Card className="p-8 text-center">
                <h3 className="mb-2">Team Stats</h3>
                <p className="text-muted-foreground">
                  Detailed statistics coming soon
                </p>
              </Card>
            </TabsContent>

            <TabsContent value="ai">
              <AISummaryCard
                title="AI-Powered Team Analysis"
                content={`${team.name}'s transfer portal strategy appears focused on addressing key weaknesses from last season. The incoming talent brings immediate impact potential, particularly in skill positions. Defensive depth has improved significantly with the addition of experienced players. Risk assessment: Low - the team has maintained core identity while upgrading strategically. Projected impact for next season: Positive trajectory with improved depth and competition at critical positions.`}
              />
            </TabsContent>
          </Tabs>
        </div>

        {/* Chat Panel */}
        <div className="lg:col-span-1">
          <div className="sticky top-24">
            <ChatPanel
              title={`Ask Portal AI About ${team.name}`}
              suggestedPrompts={suggestedPrompts}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
