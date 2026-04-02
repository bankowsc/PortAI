"""Navigation bar component."""

import from '@fortawesome/react-fontawesome' { FontAwesomeIcon }
import from '@fortawesome/free-solid-svg-icons' { 
    faSun,
    faMoon
}

def:pub Navigation(
    currentPage: str,
    onNavigate: any,
    onLogout: any,
    showUserMenu: bool,
    onToggleUserMenu: any,
    theme: str,
    onToggleTheme: any,
) -> any {
    return
        <nav className="navbar">
            <div className="navbar-inner">
                <div className="navbar-logo"
                     onClick={lambda -> None { onNavigate("home"); }}>
                    <div className="navbar-logo-icon">📈</div>
                    <span className="navbar-logo-text">
                        Port<span className="accent">AI</span>
                    </span>
                </div>

                <div className="navbar-actions">
                    <button
                        onClick={onToggleTheme}
                        className="btn-theme-toggle">
                        <span className="theme-icon">
                            {(<FontAwesomeIcon icon={faMoon} className="theme-icon" /> if theme == "dark" else <FontAwesomeIcon icon={faSun} className="theme-icon" />)}
                        </span>
                        <span className="theme-label">
                            {("Dark" if theme == "dark" else "Light")}
                        </span>
                    </button>
                    <button className="icon-btn"
                            onClick={lambda -> None { onNavigate("favorites"); }}
                            title="Favorites">
                        ⭐
                    </button>
                    <button className="icon-btn" title="Notifications">
                        🔔
                    </button>
                    <div className="avatar-dropdown">
                        <button className="avatar-btn"
                                onClick={lambda -> None { onToggleUserMenu(); }}>
                            👤
                        </button>
                        {(
                            <div className="avatar-dropdown-menu">
                                <button
                                    className="avatar-dropdown-item"
                                    onClick={lambda -> None { onNavigate("profile"); onToggleUserMenu(); }}
                                >Profile</button>
                                <button
                                    className="avatar-dropdown-item"
                                    onClick={lambda -> None { onLogout(); }}
                                >Sign Out</button>
                            </div>
                        ) if showUserMenu else None}
                    </div>
                </div>
            </div>
        </nav>;
}
