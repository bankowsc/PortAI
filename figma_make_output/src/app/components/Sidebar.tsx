import { Link, useLocation } from "react-router";
import { Home, Users, UserCircle, Star, ArrowLeftRight, Newspaper, BarChart3, MessageSquare, ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "./ui/button";
import { useState } from "react";
import { mockTeams, favoriteTeamIds } from "../data/mock-data";

export function Sidebar() {
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);
  
  const menuItems = [
    { icon: Home, label: "Home", path: "/" },
    { icon: Users, label: "Teams", path: "/teams" },
    { icon: UserCircle, label: "Players", path: "/players" },
    { icon: Star, label: "Favorites", path: "/favorites" },
    { icon: ArrowLeftRight, label: "Transactions", path: "/transactions" },
    { icon: Newspaper, label: "News", path: "/news" },
    { icon: BarChart3, label: "Analytics", path: "/analytics" },
    { icon: MessageSquare, label: "Chat", path: "/chat" },
  ];

  const favoriteTeams = mockTeams.filter(team => favoriteTeamIds.includes(team.id));

  return (
    <aside className={`sticky top-[73px] h-[calc(100vh-73px)] bg-white border-r border-border transition-all duration-300 ${collapsed ? 'w-20' : 'w-64'} flex flex-col`}>
      <div className="flex-1 overflow-y-auto py-6">
        {/* Main Menu */}
        <div className="px-3 space-y-1">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link key={item.path} to={item.path}>
                <Button
                  variant={isActive ? "secondary" : "ghost"}
                  className={`w-full justify-start rounded-lg ${
                    isActive ? "bg-accent/10 text-accent" : ""
                  } ${collapsed ? 'px-3' : 'px-4'}`}
                >
                  <Icon className={`${collapsed ? '' : 'mr-3'} w-5 h-5`} />
                  {!collapsed && <span>{item.label}</span>}
                </Button>
              </Link>
            );
          })}
        </div>

        {/* Favorites Section */}
        {!collapsed && favoriteTeams.length > 0 && (
          <div className="mt-8 px-3">
            <h3 className="px-4 mb-3 text-xs tracking-wider text-muted-foreground">
              FAVORITE TEAMS
            </h3>
            <div className="space-y-1">
              {favoriteTeams.map((team) => (
                <Link key={team.id} to={`/teams/${team.id}`}>
                  <Button
                    variant="ghost"
                    className="w-full justify-start rounded-lg px-4 hover:bg-accent/5"
                  >
                    <span className="mr-3 text-xl">{team.logo}</span>
                    <span className="text-sm truncate">{team.name}</span>
                  </Button>
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Collapse Toggle */}
      <div className="border-t border-border p-3">
        <Button
          variant="ghost"
          size="sm"
          className="w-full rounded-lg"
          onClick={() => setCollapsed(!collapsed)}
        >
          {collapsed ? <ChevronRight className="w-5 h-5" /> : <ChevronLeft className="w-5 h-5" />}
          {!collapsed && <span className="ml-2">Collapse</span>}
        </Button>
      </div>
    </aside>
  );
}