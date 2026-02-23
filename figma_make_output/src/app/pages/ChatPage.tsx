import { ChatPanel } from "../components/ChatPanel";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Clock, MessageSquare } from "lucide-react";

export default function ChatPage() {
  const suggestedPrompts = [
    "Who are the biggest winners this week?",
    "Show me the top guards in the portal",
    "Which teams improved the most?",
    "What positions are most active right now?",
    "Compare SEC and Big Ten portal activity",
    "Who are the highest-rated available players?",
  ];

  const recentConversations = [
    { id: "1", title: "Alabama transfer analysis", time: "2 hours ago" },
    { id: "2", title: "Top QB prospects", time: "Yesterday" },
    { id: "3", title: "SEC portal trends", time: "2 days ago" },
    { id: "4", title: "Defensive back rankings", time: "3 days ago" },
  ];

  return (
    <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 h-[calc(100vh-140px)]">
      {/* Left Sidebar - Recent Conversations */}
      <div className="lg:col-span-1">
        <Card className="p-4 h-full">
          <div className="flex items-center justify-between mb-4">
            <h3>Recent Chats</h3>
            <Button variant="ghost" size="sm">
              <MessageSquare className="w-4 h-4" />
            </Button>
          </div>
          <div className="space-y-2">
            {recentConversations.map((conv) => (
              <button
                key={conv.id}
                className="w-full text-left p-3 rounded-lg hover:bg-muted transition-colors"
              >
                <p className="text-sm mb-1 truncate">{conv.title}</p>
                <div className="flex items-center gap-1 text-xs text-muted-foreground">
                  <Clock className="w-3 h-3" />
                  {conv.time}
                </div>
              </button>
            ))}
          </div>
          <Button variant="outline" className="w-full mt-4">
            New Chat
          </Button>
        </Card>
      </div>

      {/* Main Chat Area */}
      <div className="lg:col-span-3 h-full">
        <ChatPanel
          title="Portal AI Assistant"
          suggestedPrompts={suggestedPrompts}
        />
      </div>
    </div>
  );
}
