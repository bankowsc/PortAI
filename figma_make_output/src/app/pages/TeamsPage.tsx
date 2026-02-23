import { useState } from "react";
import { TeamCard } from "../components/TeamCard";
import { mockTeams, favoriteTeamIds } from "../data/mock-data";
import { Input } from "../components/ui/input";
import { Button } from "../components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import { Slider } from "../components/ui/slider";
import { Search } from "lucide-react";

export default function TeamsPage() {
  const [favorites, setFavorites] = useState<string[]>(favoriteTeamIds);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedConference, setSelectedConference] = useState("all");
  const [activityLevel, setActivityLevel] = useState([0]);
  const [sortBy, setSortBy] = useState("activity");

  const conferences = ["all", "SEC", "Big Ten", "ACC", "Big 12", "Pac-12"];

  const toggleFavorite = (teamId: string) => {
    setFavorites((prev) =>
      prev.includes(teamId)
        ? prev.filter((id) => id !== teamId)
        : [...prev, teamId]
    );
  };

  const filteredTeams = mockTeams
    .filter((team) => {
      if (selectedConference !== "all" && team.conference !== selectedConference)
        return false;
      if (team.portalActivityScore < activityLevel[0]) return false;
      if (
        searchQuery &&
        !team.name.toLowerCase().includes(searchQuery.toLowerCase())
      )
        return false;
      return true;
    })
    .sort((a, b) => {
      if (sortBy === "activity") return b.portalActivityScore - a.portalActivityScore;
      if (sortBy === "gained") return b.incomingCount - a.incomingCount;
      if (sortBy === "lost") return b.outgoingCount - a.outgoingCount;
      return 0;
    });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="mb-2">College Teams</h1>
        <p className="text-muted-foreground">
          Browse all teams and their transfer portal activity
        </p>
      </div>

      {/* Filters */}
      <div className="bg-white p-6 rounded-xl border border-border space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="relative md:col-span-2">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
            <Input
              placeholder="Search teams..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>

          <Select value={selectedConference} onValueChange={setSelectedConference}>
            <SelectTrigger>
              <SelectValue placeholder="Conference" />
            </SelectTrigger>
            <SelectContent>
              {conferences.map((conf) => (
                <SelectItem key={conf} value={conf}>
                  {conf === "all" ? "All Conferences" : conf}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Select value={sortBy} onValueChange={setSortBy}>
            <SelectTrigger>
              <SelectValue placeholder="Sort by" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="activity">Most Active</SelectItem>
              <SelectItem value="gained">Most Gained</SelectItem>
              <SelectItem value="lost">Most Lost</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="text-sm">
              Minimum Activity Level
            </label>
            <span className="text-sm text-muted-foreground">
              {activityLevel[0]}+
            </span>
          </div>
          <Slider
            value={activityLevel}
            onValueChange={setActivityLevel}
            max={100}
            step={5}
            className="w-full"
          />
        </div>
      </div>

      {/* Results */}
      <div>
        <p className="text-sm text-muted-foreground mb-4">
          Showing {filteredTeams.length} team{filteredTeams.length !== 1 ? "s" : ""}
        </p>
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
    </div>
  );
}
