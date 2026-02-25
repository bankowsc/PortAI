"""Login/Auth Form component."""

def:pub AuthForm(
    isLogin: bool,
    email: str,
    password: str,
    confirmPassword: str,
    error: str,
    loading: bool,
    onEmailChange: any,
    onPasswordChange: any,
    onConfirmPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> any {
    return <div className="login-page">
            <div className="login-hero">
                <div className="login-hero-bg">
                    <div className="login-hero-circle-1"></div>
                    <div className="login-hero-circle-2"></div>
                </div>
                <div className="login-hero-content">
                    <div className="login-hero-logo">
                        <div className="login-hero-logo-icon">📈</div>
                        <span className="login-hero-logo-text">
                            Port<span className="accent-light">AI</span>
                        </span>
                    </div>
                    <h1>Understand the Transfer Portal. Instantly.</h1>
                    <p>Track player movement, team changes, and portal trends in one place.</p>
                    <div className="login-hero-graphic">
                        <div className="login-hero-line">
                            <div className="login-hero-dot"></div>
                            <div className="login-hero-rule"></div>
                            <div className="login-hero-circle-small accent-bg">📈</div>
                        </div>
                        <div className="login-hero-line" style={({"marginLeft": "3rem"})}>
                            <div className="login-hero-dot accent"></div>
                            <div className="login-hero-rule"></div>
                            <div className="login-hero-circle-small white-bg"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div className="login-form-side">
                <div className="card-static login-card">
                    <div className="login-toggle">
                        <button className={"login-toggle-btn" + (" active" if isLogin else "")}
                                onClick={lambda -> None { if not isLogin { onToggleMode(); } }}>
                            Login
                        </button>
                        <button className={"login-toggle-btn" + (" active" if not isLogin else "")}
                                onClick={lambda -> None { if isLogin { onToggleMode(); } }}>
                            Register
                        </button>
                    </div>

                    {(
                        <div className="form-error">{error}</div>
                    ) if error else None}

                    <form className="login-form"
                          onSubmit={onSubmit}>
                        <div className="form-field">
                            <label className="form-label">Email</label>
                            <input
                                type="email"
                                className="input"
                                placeholder="you@example.com"
                                value={email}
                                onChange={onEmailChange}
                                required={True}
                            />
                        </div>

                        <div className="form-field">
                            <label className="form-label">Password</label>
                            <input
                                type="password"
                                className="input"
                                placeholder="••••••••"
                                value={password}
                                onChange={onPasswordChange}
                                required={True}
                            />
                        </div>

                        {(
                            <div className="form-field">
                                <label className="form-label">Confirm Password</label>
                                <input
                                    type="password"
                                    className="input"
                                    placeholder="••••••••"
                                    value={confirmPassword}
                                    onChange={onConfirmPasswordChange}
                                    required={True}
                                />
                            </div>
                        ) if not isLogin else None}

                        {(
                            <div className="login-remember-row">
                                <label className="checkbox-wrapper">
                                    <input type="checkbox" className="checkbox" />
                                    <span>Remember me</span>
                                </label>
                                <a href="#" className="login-forgot-link">Forgot password?</a>
                            </div>
                        ) if isLogin else None}

                        <button type="submit"
                                className="btn btn-accent btn-full btn-lg"
                                disabled={loading}>
                            {(
                                "Processing..."
                                if loading
                                else ("Sign In" if isLogin else "Create Account")
                            )}
                        </button>
                    </form>

                    <div className="login-divider">
                        <div className="login-divider-line"></div>
                        <span className="login-divider-text">Or continue with</span>
                    </div>

                    <div className="login-oauth-row">
                        <button className="login-oauth-btn">Google</button>
                        <button className="login-oauth-btn">Apple</button>
                    </div>
                </div>
            </div>
        </div>;
}
