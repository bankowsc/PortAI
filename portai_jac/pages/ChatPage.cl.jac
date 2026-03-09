"""PortAI - AI Chat Page (v2) — persistent prompts, saved history, fixed bubble rendering."""

def:pub ChatPage(
    onNavigate: any,
    chatMessages: list,
    chatLoading: bool,
    onChatSend: any,
    conversations: list,
    activeConversationId: str,
    onSelectConversation: any,
    onNewConversation: any
) -> any {

    has chatInput: str = "";

    suggestedPrompts = [
        "How will my favorite teams' portal moves affect their depth chart?",
        "Which positions still need upgrades for my teams?",
        "Who is the best transfer available at QB right now?",
        "Compare incoming transfers for my teams this cycle",
        "Which conferences are most active in the portal?",
        "What is the biggest surprise transfer so far?",
        "Show me the top 5-star transfers this season",
        "Which teams have gained the most from the portal?",
        "Can you explain how the NCAA transfer portal works?",
        "Who's playing in the upcoming bowl game?"
    ];

    def handleInputChange(e: any) -> None {
        chatInput = e.target.value;
    }

    def handleKeyDown(e: any) -> None {
        if e.key == "Enter" and chatInput.trim() {
            onChatSend(chatInput);
            chatInput = "";
        }
    }

    def handleSend -> None {
        if chatInput.trim() {
            onChatSend(chatInput);
            chatInput = "";
        }
    }

    def handlePromptClick(prompt: str) -> None {
        onChatSend(prompt);
    }

    return
        <div className="chat-page">

            <div className="chat-page-header">
                <div className="chat-page-header-left">
                    <div className="chat-page-brand">
                        Port<span className="accent">AI</span>
                        <span className="chat-page-brand-sub">Assistant</span>
                    </div>
                    <div className="chat-page-subtitle">Ask anything about the transfer portal</div>
                </div>
                <div className="chat-page-header-right">
                    <div className="chat-page-status">
                        <span className="chat-status-dot"></span>
                        <span className="chat-status-label">AI Online</span>
                    </div>
                </div>
            </div>

            <div className="chat-page-body">

                <div className="chat-page-sidebar">

                    <button
                        className="chat-new-btn"
                        onClick={lambda _: any -> None { onNewConversation(); }}
                    >
                        <span>✦</span>
                        New Chat
                    </button>

                    {(
                        <div className="chat-history-section">
                            <div className="chat-sidebar-section-title">Recent Chats</div>
                            <div className="chat-history-list">
                                {[
                                    <button
                                        key={conv["id"]}
                                        className={("chat-history-item active" if conv["id"] == activeConversationId else "chat-history-item")}
                                        onClick={lambda _: any -> None { onSelectConversation(conv["id"]); }}
                                    >
                                        <span className="chat-history-icon">💬</span>
                                        <div className="chat-history-info">
                                            <div className="chat-history-title">{conv["title"]}</div>
                                            <div className="chat-history-meta">{conv["timestamp"]}</div>
                                        </div>
                                    </button>
                                    for conv in conversations
                                ]}
                            </div>
                        </div>
                    if conversations.length > 0 else
                        <span></span>
                    )}

                    <div className="chat-prompts-section">
                        <div className="chat-sidebar-section-title">Suggested Questions</div>
                        <div className="chat-prompt-list">
                            {[
                                <button
                                    key={prompt}
                                    className="chat-sidebar-prompt"
                                    onClick={lambda _: any -> None { handlePromptClick(prompt); }}
                                >
                                    <span className="chat-prompt-icon">→</span>
                                    <span className="chat-prompt-text">{prompt}</span>
                                </button>
                                for prompt in suggestedPrompts
                            ]}
                        </div>
                    </div>

                </div>

                <div className="chat-page-main">

                    <div className="chat-page-messages">

                        {(
                            <div className="chat-page-empty">
                                <div className="chat-page-empty-icon">✦</div>
                                <h2 className="chat-page-empty-title">Portal AI</h2>
                                <p className="chat-page-empty-sub">Ask me anything about transfers, players, teams, or roster strategy.</p>
                                <div className="chat-page-empty-chips">
                                    {[
                                        <button
                                            key={prompt}
                                            className="chat-empty-chip"
                                            onClick={lambda _: any -> None { handlePromptClick(prompt); }}
                                        >{prompt}</button>
                                        for prompt in suggestedPrompts.slice(0, 4)
                                    ]}
                                </div>
                            </div>
                        if chatMessages.length == 0 else
                            <div className="chat-messages-list">
                                {[
                                    <div
                                        key={String(chatMessages.indexOf(msg))}
                                        className={("chat-page-bubble user" if msg["role"] == "user" else "chat-page-bubble ai")}
                                    >
                                        {(
                                            <span></span>
                                        if msg["role"] == "user" else
                                            <div className="chat-page-ai-label">
                                                <span className="chat-ai-icon">✦</span>
                                                Portal AI
                                            </div>
                                        )}
                                        <div className="chat-page-bubble-text">{msg["content"]}</div>
                                    </div>
                                    for msg in chatMessages
                                ]}
                            </div>
                        )}

                        {(
                            <div className="chat-page-bubble ai">
                                <div className="chat-page-ai-label">
                                    <span className="chat-ai-icon">✦</span>
                                    Portal AI
                                </div>
                                <div className="chat-page-typing">
                                    <span></span><span></span><span></span>
                                </div>
                            </div>
                        if chatLoading else
                            <span></span>
                        )}

                    </div>

                    <div className="chat-page-input-bar">
                        <input
                            className="chat-page-input"
                            type="text"
                            placeholder="Ask about a player, team, roster move, or trend..."
                            value={chatInput}
                            onChange={handleInputChange}
                            onKeyDown={handleKeyDown}
                        />
                        <button
                            className={("chat-page-send-btn" if chatInput.trim() else "chat-page-send-btn disabled")}
                            onClick={lambda _: any -> None { handleSend(); }}
                        >
                            <span className="chat-send-arrow">↑</span>
                        </button>
                    </div>

                </div>

            </div>

        </div>;
}
