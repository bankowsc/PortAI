import { AISummaryCard } from "../components/AISummaryCard";
import { TransactionCard } from "../components/TransactionCard";
import { Card } from "../components/ui/card";
import { mockTransactions, mockTeams, favoriteTeamIds } from "../data/mock-data";
import { TrendingUp } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { Badge } from "../components/ui/badge";

export default function HomePage() {
  const favoriteTeams = mockTeams.filter((team) =>
    favoriteTeamIds.includes(team.id)
  );
  const hasFavorites = favoriteTeams.length > 0;

  const trendingTeams = [...mockTeams]
    .sort((a, b) => b.portalActivityScore - a.portalActivityScore)
    .slice(0, 5);

  const portalStats = [
    { name: "QB", value: 23 },
    { name: "WR", value: 45 },
    { name: "RB", value: 34 },
    { name: "LB", value: 38 },
    { name: "DB", value: 41 },
  ];

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
      {/* Main Content - Center */}
      <div className="lg:col-span-8 space-y-6">
        {/* AI Overview Card */}
        <AISummaryCard
          title={
            hasFavorites
              ? "Transfer Impact Overview - Impacting Your Favorite Teams"
              : "Transfer Impact Overview - Trending Portal Activity"
          }
          content={
            hasFavorites
              ? `Your favorite teams are showing significant portal activity this week. Alabama leads with 8 incoming transfers, including a 5-star QB. Georgia's defense gets a major boost with two elite linebackers. Texas maintains roster stability with minimal losses. Overall, your teams are positioned well for next season.`
              : `This week's portal activity shows unprecedented movement in the quarterback position, with 23 entries. The SEC leads all conferences in total transfers with 89 players. Elite defensive backs are in high demand, commanding the highest NIL valuations. Notable: Three top-10 teams secured 5-star transfers in the past 48 hours.`
          }
          onRegenerate={() => console.log("Regenerate summary")}
        />

        {/* Recent Transactions Feed */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2>Recent Transactions</h2>
            <Badge variant="secondary" className="text-xs">
              Updated 5 min ago
            </Badge>
          </div>
          <div className="space-y-4">
            {mockTransactions.map((transaction) => (
              <TransactionCard key={transaction.id} transaction={transaction} />
            ))}
          </div>
        </div>
      </div>

      {/* Right Sidebar */}
      <div className="lg:col-span-4 space-y-6">
        {/* Trending Teams Card */}
        <Card className="p-6">
          <h3 className="mb-4">Trending Teams</h3>
          <div className="space-y-4">
            {trendingTeams.map((team, index) => (
              <div
                key={team.id}
                className="flex items-center gap-3 p-3 hover:bg-muted rounded-lg transition-colors cursor-pointer"
              >
                <span className="text-sm text-muted-foreground w-6">
                  #{index + 1}
                </span>
                <span className="text-2xl">{team.logo}</span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm truncate">{team.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {team.conference}
                  </p>
                </div>
                <div className="flex items-center gap-1">
                  <TrendingUp className="w-4 h-4 text-accent" />
                  <span className="text-sm">{team.portalActivityScore}</span>
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Portal Stats Snapshot */}
        <Card className="p-6">
          <h3 className="mb-4">Portal Stats Snapshot</h3>
          <div className="space-y-4">
            <div className="p-4 bg-accent/5 rounded-lg">
              <p className="text-sm text-muted-foreground mb-1">
                Total Transfers This Week
              </p>
              <p className="text-3xl text-accent">247</p>
            </div>

            <div>
              <p className="text-sm text-muted-foreground mb-3">
                Top Positions Entering Portal
              </p>
              <ResponsiveContainer width="100%" height={200}>
                <BarChart data={portalStats}>
                  <CartesianGrid strokeDasharray="3 3" opacity={0.1} />
                  <XAxis dataKey="name" fontSize={12} />
                  <YAxis fontSize={12} />
                  <Tooltip />
                  <Bar dataKey="value" fill="hsl(var(--accent))" radius={[8, 8, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            <div className="pt-4 border-t border-border">
              <p className="text-sm text-muted-foreground mb-3">
                Most Active Conferences
              </p>
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span>SEC</span>
                  <Badge variant="secondary">89</Badge>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>Big Ten</span>
                  <Badge variant="secondary">76</Badge>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>ACC</span>
                  <Badge variant="secondary">54</Badge>
                </div>
              </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
