import { Card } from "../components/ui/card";
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";

export default function AnalyticsPage() {
  const conferenceData = [
    { name: "SEC", transfers: 89 },
    { name: "Big Ten", transfers: 76 },
    { name: "ACC", transfers: 54 },
    { name: "Big 12", transfers: 48 },
    { name: "Pac-12", transfers: 42 },
  ];

  const trendData = [
    { week: "Week 1", transfers: 45 },
    { week: "Week 2", transfers: 67 },
    { week: "Week 3", transfers: 89 },
    { week: "Week 4", transfers: 112 },
    { week: "Week 5", transfers: 98 },
    { week: "Week 6", transfers: 134 },
  ];

  const positionData = [
    { name: "QB", value: 23 },
    { name: "WR", value: 45 },
    { name: "RB", value: 34 },
    { name: "LB", value: 38 },
    { name: "DB", value: 41 },
    { name: "OL", value: 52 },
  ];

  const COLORS = ["hsl(var(--chart-1))", "hsl(var(--chart-2))", "hsl(var(--chart-3))", "hsl(var(--chart-4))", "hsl(var(--chart-5))", "hsl(var(--accent))"];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">Portal Analytics</h1>
        <p className="text-muted-foreground">
          Data-driven insights into transfer portal trends
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="p-6">
          <p className="text-sm text-muted-foreground mb-2">Total Transfers</p>
          <p className="text-4xl text-accent mb-1">547</p>
          <p className="text-xs text-muted-foreground">This season</p>
        </Card>
        <Card className="p-6">
          <p className="text-sm text-muted-foreground mb-2">Active Teams</p>
          <p className="text-4xl text-accent mb-1">128</p>
          <p className="text-xs text-muted-foreground">Across all conferences</p>
        </Card>
        <Card className="p-6">
          <p className="text-sm text-muted-foreground mb-2">Avg. Star Rating</p>
          <p className="text-4xl text-accent mb-1">3.8</p>
          <p className="text-xs text-muted-foreground">Portal players</p>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="p-6">
          <h3 className="mb-4">Conference Activity</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={conferenceData}>
              <CartesianGrid strokeDasharray="3 3" opacity={0.1} />
              <XAxis dataKey="name" fontSize={12} />
              <YAxis fontSize={12} />
              <Tooltip />
              <Bar dataKey="transfers" fill="hsl(var(--accent))" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <h3 className="mb-4">Transfer Trend (6 Weeks)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={trendData}>
              <CartesianGrid strokeDasharray="3 3" opacity={0.1} />
              <XAxis dataKey="week" fontSize={12} />
              <YAxis fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="transfers" stroke="hsl(var(--accent))" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <h3 className="mb-4">Position Distribution</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={positionData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {positionData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <h3 className="mb-4">Key Insights</h3>
          <div className="space-y-4">
            <div className="p-4 bg-accent/5 rounded-lg border border-accent/20">
              <p className="text-sm">
                <span className="text-accent">↑ 23%</span> increase in QB transfers compared to last year
              </p>
            </div>
            <div className="p-4 bg-accent/5 rounded-lg border border-accent/20">
              <p className="text-sm">
                <span className="text-accent">SEC</span> leads with most 5-star portal additions
              </p>
            </div>
            <div className="p-4 bg-accent/5 rounded-lg border border-accent/20">
              <p className="text-sm">
                <span className="text-accent">Peak Week</span> was Week 6 with 134 total transfers
              </p>
            </div>
            <div className="p-4 bg-accent/5 rounded-lg border border-accent/20">
              <p className="text-sm">
                <span className="text-accent">OL</span> is the most active position group
              </p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
