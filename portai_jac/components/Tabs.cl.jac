"""Tabs component - custom tab switching UI."""

def:pub Tabs(
    tabs: list,
    activeTab: str,
    onTabChange: any,
    children: any
) -> any {
    return
        <div className="space-y-6">
            <div className="tabs-list">
                {tabs.map(lambda tab: dict -> any {
                    tabId = tab["id"];
                    return <button key={tab["id"]}
                            className={"tab-trigger" + (" active" if activeTab == tab["id"] else "")}
                            onClick={lambda -> None { onTabChange(tabId); }}>
                        {tab["label"]}
                    </button>;
                })}
            </div>
            {children}
        </div>;
}
