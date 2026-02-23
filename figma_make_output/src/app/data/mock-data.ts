export interface Team {
  id: string;
  name: string;
  logo: string;
  conference: string;
  portalActivityScore: number;
  lastSeasonRecord: string;
  incomingCount: number;
  outgoingCount: number;
}

export interface Player {
  id: string;
  name: string;
  photo: string;
  position: string;
  height: string;
  weight: string;
  class: string;
  currentTeam: string;
  previousTeam: string;
  starRating: number;
  stats: {
    ppg?: number;
    rpg?: number;
    apg?: number;
    yards?: number;
    touchdowns?: number;
  };
  nilValue?: string;
}

export interface Transaction {
  id: string;
  playerId: string;
  playerName: string;
  playerPhoto: string;
  position: string;
  fromTeam: string;
  fromTeamLogo: string;
  toTeam: string;
  toTeamLogo: string;
  starRating: number;
  stats: any;
  date: string;
  sport: string;
}

export const mockTeams: Team[] = [
  {
    id: "1",
    name: "Alabama Crimson Tide",
    logo: "🔴",
    conference: "SEC",
    portalActivityScore: 92,
    lastSeasonRecord: "12-2",
    incomingCount: 8,
    outgoingCount: 5,
  },
  {
    id: "2",
    name: "Ohio State Buckeyes",
    logo: "⚪",
    conference: "Big Ten",
    portalActivityScore: 88,
    lastSeasonRecord: "11-2",
    incomingCount: 7,
    outgoingCount: 6,
  },
  {
    id: "3",
    name: "Georgia Bulldogs",
    logo: "🔴",
    conference: "SEC",
    portalActivityScore: 85,
    lastSeasonRecord: "13-1",
    incomingCount: 6,
    outgoingCount: 4,
  },
  {
    id: "4",
    name: "Michigan Wolverines",
    logo: "💙",
    conference: "Big Ten",
    portalActivityScore: 82,
    lastSeasonRecord: "10-3",
    incomingCount: 9,
    outgoingCount: 7,
  },
  {
    id: "5",
    name: "USC Trojans",
    logo: "🟡",
    conference: "Big Ten",
    portalActivityScore: 79,
    lastSeasonRecord: "8-5",
    incomingCount: 10,
    outgoingCount: 8,
  },
  {
    id: "6",
    name: "Texas Longhorns",
    logo: "🟠",
    conference: "SEC",
    portalActivityScore: 86,
    lastSeasonRecord: "12-2",
    incomingCount: 5,
    outgoingCount: 3,
  },
  {
    id: "7",
    name: "Oregon Ducks",
    logo: "💚",
    conference: "Big Ten",
    portalActivityScore: 84,
    lastSeasonRecord: "11-3",
    incomingCount: 6,
    outgoingCount: 5,
  },
  {
    id: "8",
    name: "Florida State Seminoles",
    logo: "🟡",
    conference: "ACC",
    portalActivityScore: 75,
    lastSeasonRecord: "13-1",
    incomingCount: 4,
    outgoingCount: 9,
  },
];

export const mockPlayers: Player[] = [
  {
    id: "1",
    name: "Marcus Johnson",
    photo: "👤",
    position: "QB",
    height: "6'3\"",
    weight: "215 lbs",
    class: "Junior",
    currentTeam: "Alabama Crimson Tide",
    previousTeam: "USC Trojans",
    starRating: 5,
    stats: {
      ppg: 0,
      yards: 3245,
      touchdowns: 28,
    },
    nilValue: "$1.2M",
  },
  {
    id: "2",
    name: "DeAndre Williams",
    photo: "👤",
    position: "WR",
    height: "6'1\"",
    weight: "190 lbs",
    class: "Sophomore",
    currentTeam: "Ohio State Buckeyes",
    previousTeam: "Florida State Seminoles",
    starRating: 4,
    stats: {
      ppg: 0,
      yards: 982,
      touchdowns: 12,
    },
    nilValue: "$850K",
  },
  {
    id: "3",
    name: "Tyler Anderson",
    photo: "👤",
    position: "RB",
    height: "5'11\"",
    weight: "205 lbs",
    class: "Senior",
    currentTeam: "Georgia Bulldogs",
    previousTeam: "Michigan Wolverines",
    starRating: 4,
    stats: {
      ppg: 0,
      yards: 1456,
      touchdowns: 18,
    },
    nilValue: "$950K",
  },
  {
    id: "4",
    name: "Jamal Carter",
    photo: "👤",
    position: "LB",
    height: "6'2\"",
    weight: "230 lbs",
    class: "Junior",
    currentTeam: "Texas Longhorns",
    previousTeam: "Oregon Ducks",
    starRating: 5,
    stats: {
      ppg: 0,
      yards: 0,
      touchdowns: 0,
    },
    nilValue: "$780K",
  },
];

export const mockTransactions: Transaction[] = [
  {
    id: "1",
    playerId: "1",
    playerName: "Marcus Johnson",
    playerPhoto: "👤",
    position: "QB",
    fromTeam: "USC Trojans",
    fromTeamLogo: "🟡",
    toTeam: "Alabama Crimson Tide",
    toTeamLogo: "🔴",
    starRating: 5,
    stats: { yards: 3245, touchdowns: 28 },
    date: "2026-02-15",
    sport: "Football",
  },
  {
    id: "2",
    playerId: "2",
    playerName: "DeAndre Williams",
    playerPhoto: "👤",
    position: "WR",
    fromTeam: "Florida State Seminoles",
    fromTeamLogo: "🟡",
    toTeam: "Ohio State Buckeyes",
    toTeamLogo: "⚪",
    starRating: 4,
    stats: { yards: 982, touchdowns: 12 },
    date: "2026-02-14",
    sport: "Football",
  },
  {
    id: "3",
    playerId: "3",
    playerName: "Tyler Anderson",
    playerPhoto: "👤",
    position: "RB",
    fromTeam: "Michigan Wolverines",
    fromTeamLogo: "💙",
    toTeam: "Georgia Bulldogs",
    toTeamLogo: "🔴",
    starRating: 4,
    stats: { yards: 1456, touchdowns: 18 },
    date: "2026-02-13",
    sport: "Football",
  },
  {
    id: "4",
    playerId: "4",
    playerName: "Jamal Carter",
    playerPhoto: "👤",
    position: "LB",
    fromTeam: "Oregon Ducks",
    fromTeamLogo: "💚",
    toTeam: "Texas Longhorns",
    toTeamLogo: "🟠",
    starRating: 5,
    stats: { tackles: 98, sacks: 12 },
    date: "2026-02-12",
    sport: "Football",
  },
  {
    id: "5",
    playerId: "5",
    playerName: "Brandon Davis",
    playerPhoto: "👤",
    position: "DB",
    fromTeam: "Alabama Crimson Tide",
    fromTeamLogo: "🔴",
    toTeam: "USC Trojans",
    toTeamLogo: "🟡",
    starRating: 4,
    stats: { tackles: 76, interceptions: 4 },
    date: "2026-02-11",
    sport: "Football",
  },
];

export const favoriteTeamIds: string[] = ["1", "3", "6"];
