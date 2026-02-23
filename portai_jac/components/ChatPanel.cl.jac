"""Chat Panel component - interactive AI chat interface."""

def:pub ChatPanel(
    title: str,
    messages: list,
    inputValue: str,
    onInputChange: any,
    onSend: any,
    suggestedPrompts: list,
    onPromptClick: any,
    loading: bool = False
) -> any {
    return
        <div className="chat-panel">
            <div className="chat-panel-header">
                <h3>{title}</h3>
            </div>

            <div className="chat-panel-body">
                {(
                    <div className="chat-suggested-prompts">
                        <p className="chat-suggested-label">Suggested questions:</p>
                        {suggestedPrompts.map(lambda prompt: str -> any {
                            p = prompt;
                            return <button key={prompt}
                                    className="chat-suggested-btn"
                                    onClick={lambda -> None { onPromptClick(p); }}>
                                {prompt}
                            </button>;
                        })}
                    </div>
                ) if messages.length == 0 and suggestedPrompts.length > 0 else None}

                <div className="chat-messages">
                    {[
                        <div key={msg["id"]}
                             className={"chat-message " + msg["role"]}>
                            <p>{msg["content"]}</p>
                            <div className="chat-message-time">{msg["time"]}</div>
                        </div>
                        for msg in messages
                    ]}
                    {(
                        <div className="chat-message assistant">
                            <div className="flex items-center gap-2">
                                <div className="spinner"></div>
                                <span className="text-sm">Thinking...</span>
                            </div>
                        </div>
                    ) if loading else None}
                </div>
            </div>

            <div className="chat-panel-footer">
                <div className="chat-input-row">
                    <input
                        className="input"
                        placeholder="Type your question..."
                        value={inputValue}
                        onChange={onInputChange}
                        onKeyDown={lambda e: any -> None {
                            if e.key == "Enter" { onSend(); }
                        }}
                    />
                    <button className="chat-send-btn"
                            onClick={lambda -> None { onSend(); }}
                            disabled={loading}>
                        ➤
                    </button>
                </div>
            </div>
        </div>;
}
