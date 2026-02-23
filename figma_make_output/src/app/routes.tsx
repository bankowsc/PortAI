import { createBrowserRouter } from "react-router";
import RootLayout from "./layouts/RootLayout";
import HomePage from "./pages/HomePage";
import LoginPage from "./pages/LoginPage";
import TeamsPage from "./pages/TeamsPage";
import TeamDetailPage from "./pages/TeamDetailPage";
import PlayersPage from "./pages/PlayersPage";
import PlayerDetailPage from "./pages/PlayerDetailPage";
import FavoritesPage from "./pages/FavoritesPage";
import TransactionsPage from "./pages/TransactionsPage";
import NewsPage from "./pages/NewsPage";
import AnalyticsPage from "./pages/AnalyticsPage";
import ChatPage from "./pages/ChatPage";
import SearchPage from "./pages/SearchPage";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: LoginPage,
  },
  {
    path: "/",
    Component: RootLayout,
    children: [
      { index: true, Component: HomePage },
      { path: "teams", Component: TeamsPage },
      { path: "teams/:id", Component: TeamDetailPage },
      { path: "players", Component: PlayersPage },
      { path: "players/:id", Component: PlayerDetailPage },
      { path: "favorites", Component: FavoritesPage },
      { path: "transactions", Component: TransactionsPage },
      { path: "news", Component: NewsPage },
      { path: "analytics", Component: AnalyticsPage },
      { path: "chat", Component: ChatPage },
      { path: "search", Component: SearchPage },
    ],
  },
]);
