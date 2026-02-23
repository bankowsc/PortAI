import { useState } from "react";
import { AISummaryCard } from "../components/AISummaryCard";
import { TransactionCard } from "../components/TransactionCard";
import { TeamCard } from "../components/TeamCard";
import { mockTeams, mockTransactions, favoriteTeamIds } from "../data/mock-data";
import { Card } from "../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";

export default function FavoritesPage() {
  const [favorites, setFavorites] = useState<string[]>(favoriteTeamIds);
  const favoriteTeams = mockTeams.filter((team) =>
    favorites.includes(team.id)
  );

  const favoriteTransactions = mockTransactions.filter(
    (transaction) =>
      favoriteTeams.some(
        (team) =>
          team.name === transaction.toTeam ||
          team.name === transaction.fromTeam
      )
  );

  const toggleFavorite = (teamId: string) => {
    setFavorites((prev) =>
      prev.includes(teamId)
        ? prev.filter((id) => id !== teamId)
        : [...prev, teamId]
    );
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">Your Favorites</h1>
        <p className="text-muted-foreground">
          Track your favorite teams and their transfer portal activity
        </p>
      </div>

      {favoriteTeams.length === 0 ? (
        <Card className="p-12 text-center">
          <div className="text-6xl mb-4">⭐</div>
          <h2 className="mb-2">No Favorite Teams Yet</h2>
          <p className="text-muted-foreground mb-6">
            Add teams to your favorites to track their portal activity
          </p>
        </Card>
      ) : (
        <>
          {/* AI Summary for Favorites */}
          <AISummaryCard
            title="What's Changed for Your Teams This Week"
            content={`Your favorite teams have been active in the transfer portal. Alabama leads with 8 new additions including a 5-star QB transfer. Georgia strengthened their defense with two elite linebacker pickups. Texas has maintained roster stability with minimal departures. Overall trend: Your favorite teams are positioning themselves well for next season with strategic acquisitions that address key positional needs.`}
          />

          {/* Tabs for Teams and Transactions */}
          <Tabs defaultValue="teams" className="space-y-6">
            <TabsList className="bg-white border border-border">
              <TabsTrigger value="teams">Favorite Teams</TabsTrigger>
              <TabsTrigger value="transactions">
                Related Transactions
              </TabsTrigger>
            </TabsList>

            <TabsContent value="teams">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {favoriteTeams.map((team) => (
                  <TeamCard
                    key={team.id}
                    team={team}
                    isFavorite={true}
                    onToggleFavorite={toggleFavorite}
                  />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="transactions">
              <div className="space-y-4">
                {favoriteTransactions.length === 0 ? (
                  <Card className="p-8 text-center">
                    <p className="text-muted-foreground">
                      No recent transactions for your favorite teams
                    </p>
                  </Card>
                ) : (
                  favoriteTransactions.map((transaction) => (
                    <TransactionCard
                      key={transaction.id}
                      transaction={transaction}
                    />
                  ))
                )}
              </div>
            </TabsContent>
          </Tabs>
        </>
      )}
    </div>
  );
}
