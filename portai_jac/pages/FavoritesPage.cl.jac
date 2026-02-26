"""Favorites Page - View and manage favorite teams."""

import from ..components.TeamCard { TeamCard }
import from ..data.mock_data { mock_teams }

def:pub FavoritesPage(
    onNavigate: any,
    favoriteTeamIds: list,
    onToggleFavorite: any
) -> any {
    favorite_teams = mock_teams.filter(
        lambda t: dict -> bool { return favoriteTeamIds.includes(t["id"]); }
    );

    return
        <div className="space-y-6">
            <div>
                <h1 className="mb-2">My Favorite Teams</h1>
                <p className="text-muted">
                    {"Track transfer portal activity for your " + String(favorite_teams.length) + " favorite team" + ("s" if favorite_teams.length != 1 else "")}
                </p>
            </div>

            {(
                <div className="favorites-empty-state">
                    <div className="favorites-empty-icon">⭐</div>
                    <h2>No Favorite Teams Yet</h2>
                    <p className="text-muted">
                        Add teams to your favorites to track their transfer portal activity.
                        You can favorite teams from the Teams page or from the sidebar.
                    </p>
                    <button
                        className="btn btn-accent rounded-lg"
                        onClick={lambda -> None { onNavigate("teams"); }}
                    >
                        Browse Teams
                    </button>
                </div>
            ) if favorite_teams.length == 0 else (
                <div>
                    <p className="results-count">
                        {"Showing " + String(favorite_teams.length) + " favorite team" + ("s" if favorite_teams.length != 1 else "")}
                    </p>
                    <div className="grid-3">
                        {favorite_teams.map(lambda team: dict -> any {
                            return <TeamCard
                                key={team["id"]}
                                team={team}
                                isFavorite={True}
                                onToggleFavorite={onToggleFavorite}
                                onNavigate={onNavigate}
                            />;
                        })}
                    </div>
                </div>
            )}
        </div>;
}
