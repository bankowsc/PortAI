import { PlayerCard } from "../components/PlayerCard";
import { mockPlayers } from "../data/mock-data";

export default function PlayersPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">Transfer Portal Players</h1>
        <p className="text-muted-foreground">
          Browse all players in the transfer portal
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {mockPlayers.map((player) => (
          <PlayerCard key={player.id} player={player} />
        ))}
      </div>
    </div>
  );
}
