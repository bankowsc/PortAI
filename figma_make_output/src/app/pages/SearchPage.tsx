import { useSearchParams } from "react-router";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { TeamCard } from "../components/TeamCard";
import { PlayerCard } from "../components/PlayerCard";
import { TransactionCard } from "../components/TransactionCard";
import { mockTeams, mockPlayers, mockTransactions, favoriteTeamIds } from "../data/mock-data";
import { useState } from "react";
import { Card } from "../components/ui/card";

export default function SearchPage() {
  const [searchParams] = useSearchParams();
  const query = searchParams.get("q") || "";
  const [favorites, setFavorites] = useState<string[]>(favoriteTeamIds);

  const toggleFavorite = (teamId: string) => {
    setFavorites((prev) =>
      prev.includes(teamId)
        ? prev.filter((id) => id !== teamId)
        : [...prev, teamId]
    );
  };

  const filteredTeams = mockTeams.filter((team) =>
    team.name.toLowerCase().includes(query.toLowerCase()) ||
    team.conference.toLowerCase().includes(query.toLowerCase())
  );

  const filteredPlayers = mockPlayers.filter(
    (player) =>
      player.name.toLowerCase().includes(query.toLowerCase()) ||
      player.position.toLowerCase().includes(query.toLowerCase()) ||
      player.currentTeam.toLowerCase().includes(query.toLowerCase())
  );

  const filteredTransactions = mockTransactions.filter(
    (transaction) =>
      transaction.playerName.toLowerCase().includes(query.toLowerCase()) ||
      transaction.toTeam.toLowerCase().includes(query.toLowerCase()) ||
      transaction.fromTeam.toLowerCase().includes(query.toLowerCase())
  );

  const totalResults =
    filteredTeams.length + filteredPlayers.length + filteredTransactions.length;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">Search Results</h1>
        <p className="text-muted-foreground">
          Found {totalResults} result{totalResults !== 1 ? "s" : ""} for "
          {query}"
        </p>
      </div>

      {totalResults === 0 ? (
        <Card className="p-12 text-center">
          <div className="text-6xl mb-4">🔍</div>
          <h2 className="mb-2">No Results Found</h2>
          <p className="text-muted-foreground">
            Try searching with different keywords
          </p>
        </Card>
      ) : (
        <Tabs defaultValue="all" className="space-y-6">
          <TabsList className="bg-white border border-border">
            <TabsTrigger value="all">
              All ({totalResults})
            </TabsTrigger>
            <TabsTrigger value="teams">
              Teams ({filteredTeams.length})
            </TabsTrigger>
            <TabsTrigger value="players">
              Players ({filteredPlayers.length})
            </TabsTrigger>
            <TabsTrigger value="transactions">
              Transactions ({filteredTransactions.length})
            </TabsTrigger>
          </TabsList>

          <TabsContent value="all" className="space-y-8">
            {filteredTeams.length > 0 && (
              <div>
                <h3 className="mb-4">Teams</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {filteredTeams.map((team) => (
                    <TeamCard
                      key={team.id}
                      team={team}
                      isFavorite={favorites.includes(team.id)}
                      onToggleFavorite={toggleFavorite}
                    />
                  ))}
                </div>
              </div>
            )}

            {filteredPlayers.length > 0 && (
              <div>
                <h3 className="mb-4">Players</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {filteredPlayers.map((player) => (
                    <PlayerCard key={player.id} player={player} />
                  ))}
                </div>
              </div>
            )}

            {filteredTransactions.length > 0 && (
              <div>
                <h3 className="mb-4">Transactions</h3>
                <div className="space-y-4">
                  {filteredTransactions.map((transaction) => (
                    <TransactionCard
                      key={transaction.id}
                      transaction={transaction}
                    />
                  ))}
                </div>
              </div>
            )}
          </TabsContent>

          <TabsContent value="teams">
            {filteredTeams.length === 0 ? (
              <Card className="p-8 text-center">
                <p className="text-muted-foreground">No teams found</p>
              </Card>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredTeams.map((team) => (
                  <TeamCard
                    key={team.id}
                    team={team}
                    isFavorite={favorites.includes(team.id)}
                    onToggleFavorite={toggleFavorite}
                  />
                ))}
              </div>
            )}
          </TabsContent>

          <TabsContent value="players">
            {filteredPlayers.length === 0 ? (
              <Card className="p-8 text-center">
                <p className="text-muted-foreground">No players found</p>
              </Card>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredPlayers.map((player) => (
                  <PlayerCard key={player.id} player={player} />
                ))}
              </div>
            )}
          </TabsContent>

          <TabsContent value="transactions">
            {filteredTransactions.length === 0 ? (
              <Card className="p-8 text-center">
                <p className="text-muted-foreground">No transactions found</p>
              </Card>
            ) : (
              <div className="space-y-4">
                {filteredTransactions.map((transaction) => (
                  <TransactionCard
                    key={transaction.id}
                    transaction={transaction}
                  />
                ))}
              </div>
            )}
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}
