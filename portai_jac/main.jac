"""PortAI - Transfer Portal Intelligence."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> JsxElement {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import json;

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# Import mock data for building LLM context
glob mock_teams_data: list = [
    {"id": "1", "name": "Air Force Falcons", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "2", "name": "Akron Zips", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "3", "name": "Alabama Crimson Tide", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "4", "name": "Appalachian State Mountaineers", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "5", "name": "Arizona Wildcats", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "6", "name": "Arizona State Sun Devils", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "7", "name": "Arkansas Razorbacks", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "8", "name": "Arkansas State Red Wolves", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "9", "name": "Army Black Knights", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "10", "name": "Auburn Tigers", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "11", "name": "Ball State Cardinals", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "12", "name": "Baylor Bears", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "13", "name": "Boise State Broncos", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "14", "name": "Boston College Eagles", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "15", "name": "Bowling Green Falcons", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "16", "name": "Buffalo Bulls", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "17", "name": "BYU Cougars", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "18", "name": "California Golden Bears", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "19", "name": "Central Michigan Chippewas", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "20", "name": "Charlotte 49ers", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "21", "name": "Cincinnati Bearcats", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "22", "name": "Clemson Tigers", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "23", "name": "Coastal Carolina Chanticleers", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "24", "name": "Colorado Buffaloes", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "25", "name": "Colorado State Rams", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "26", "name": "Duke Blue Devils", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "27", "name": "East Carolina Pirates", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "28", "name": "Eastern Michigan Eagles", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "29", "name": "FIU Panthers", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "30", "name": "Florida Atlantic Owls", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "31", "name": "Florida Gators", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "32", "name": "Florida State Seminoles", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "33", "name": "Fresno State Bulldogs", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "34", "name": "Georgia Bulldogs", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "35", "name": "Georgia Southern Eagles", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "36", "name": "Georgia State Panthers", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "37", "name": "Georgia Tech Yellow Jackets", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "38", "name": "Hawaii Rainbow Warriors", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "39", "name": "Houston Cougars", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "40", "name": "Illinois Fighting Illini", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "41", "name": "Indiana Hoosiers", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "42", "name": "Iowa Hawkeyes", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "43", "name": "Iowa State Cyclones", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "44", "name": "Jacksonville State Gamecocks", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "45", "name": "James Madison Dukes", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "46", "name": "Kansas Jayhawks", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "47", "name": "Kansas State Wildcats", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "48", "name": "Kennesaw State Owls", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "49", "name": "Kent State Golden Flashes", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "50", "name": "Kentucky Wildcats", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "51", "name": "Liberty Flames", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "52", "name": "Louisiana Ragin' Cajuns", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "53", "name": "Louisiana Tech Bulldogs", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "54", "name": "Louisville Cardinals", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "55", "name": "LSU Tigers", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "56", "name": "Marshall Thundering Herd", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "57", "name": "Maryland Terrapins", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "58", "name": "Memphis Tigers", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "59", "name": "Miami (FL) Hurricanes", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "60", "name": "Miami (OH) RedHawks", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "61", "name": "Michigan State Spartans", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "62", "name": "Middle Tennessee Blue Raiders", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "63", "name": "Minnesota Golden Gophers", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "64", "name": "Mississippi State Bulldogs", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "65", "name": "Missouri Tigers", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "66", "name": "Navy Midshipmen", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "67", "name": "NC State Wolfpack", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "68", "name": "Nebraska Cornhuskers", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "69", "name": "Nevada Wolf Pack", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "70", "name": "New Mexico Lobos", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "71", "name": "New Mexico State Aggies", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "72", "name": "North Carolina Tar Heels", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "73", "name": "North Texas Mean Green", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "74", "name": "Northern Illinois Huskies", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "75", "name": "Northwestern Wildcats", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "76", "name": "Notre Dame Fighting Irish", "conference": "Independent", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "77", "name": "Ohio Bobcats", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "78", "name": "Ohio State Buckeyes", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "79", "name": "Oklahoma Sooners", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "80", "name": "Oklahoma State Cowboys", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "81", "name": "Old Dominion Monarchs", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "82", "name": "Ole Miss Rebels", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "83", "name": "Oregon Ducks", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "84", "name": "Oregon State Beavers", "conference": "Pac-12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "85", "name": "Penn State Nittany Lions", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "86", "name": "Pittsburgh Panthers", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "87", "name": "Purdue Boilermakers", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "88", "name": "Rice Owls", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "89", "name": "Rutgers Scarlet Knights", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "90", "name": "Sam Houston Bearkats", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "91", "name": "San Diego State Aztecs", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "92", "name": "San Jose State Spartans", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "93", "name": "SMU Mustangs", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "94", "name": "South Alabama Jaguars", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "95", "name": "South Carolina Gamecocks", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "96", "name": "South Florida Bulls", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "97", "name": "Southern California Trojans", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "98", "name": "Southern Miss Golden Eagles", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "99", "name": "Stanford Cardinal", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "100", "name": "Syracuse Orange", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "101", "name": "TCU Horned Frogs", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "102", "name": "Temple Owls", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "103", "name": "Tennessee Volunteers", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "104", "name": "Texas A&M Aggies", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "105", "name": "Texas Longhorns", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "106", "name": "Texas State Bobcats", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "107", "name": "Texas Tech Red Raiders", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "108", "name": "Toledo Rockets", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "109", "name": "Troy Trojans", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "110", "name": "Tulane Green Wave", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "111", "name": "Tulsa Golden Hurricane", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "112", "name": "UAB Blazers", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "113", "name": "UCF Knights", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "114", "name": "UCLA Bruins", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "115", "name": "UConn Huskies", "conference": "Independent", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "116", "name": "ULM Warhawks", "conference": "Sun Belt", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "117", "name": "UNLV Rebels", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "118", "name": "USC Trojans", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "119", "name": "Utah Utes", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "120", "name": "Utah State Aggies", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "121", "name": "UTEP Miners", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "122", "name": "UTSA Roadrunners", "conference": "AAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "123", "name": "Vanderbilt Commodores", "conference": "SEC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "124", "name": "Virginia Cavaliers", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "125", "name": "Virginia Tech Hokies", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "126", "name": "Wake Forest Demon Deacons", "conference": "ACC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "127", "name": "Washington Huskies", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "128", "name": "Washington State Cougars", "conference": "Pac-12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "129", "name": "West Virginia Mountaineers", "conference": "Big 12", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "130", "name": "Western Kentucky Hilltoppers", "conference": "CUSA", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "131", "name": "Western Michigan Broncos", "conference": "MAC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "132", "name": "Wisconsin Badgers", "conference": "Big Ten", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0},
    {"id": "133", "name": "Wyoming Cowboys", "conference": "MWC", "portalActivityScore": 0, "lastSeasonRecord": "0-0", "incomingCount": 0, "outgoingCount": 0}
];

glob mock_transactions_data: list = [
    {"playerName": "Marcus Johnson", "position": "QB", "fromTeam": "USC Trojans", "toTeam": "Alabama Crimson Tide", "starRating": 5, "stats": "3245 yards, 28 TDs", "date": "Feb 15, 2026"},
    {"playerName": "DeAndre Williams", "position": "WR", "fromTeam": "Florida State Seminoles", "toTeam": "Ohio State Buckeyes", "starRating": 4, "stats": "982 yards, 12 TDs", "date": "Feb 14, 2026"},
    {"playerName": "Tyler Anderson", "position": "RB", "fromTeam": "Michigan Wolverines", "toTeam": "Georgia Bulldogs", "starRating": 4, "stats": "1456 yards, 18 TDs", "date": "Feb 13, 2026"},
    {"playerName": "Jamal Carter", "position": "LB", "fromTeam": "Oregon Ducks", "toTeam": "Texas Longhorns", "starRating": 5, "stats": "98 tackles, 12 sacks", "date": "Feb 12, 2026"},
    {"playerName": "Brandon Davis", "position": "DB", "fromTeam": "Alabama Crimson Tide", "toTeam": "USC Trojans", "starRating": 4, "stats": "76 tackles, 4 INTs", "date": "Feb 11, 2026"}
];

glob portal_stats_context: str = "Total transfers this week: 247. Top positions entering portal: WR (45), DB (41), LB (38), RB (34), QB (23). Most active conferences: SEC (89 transfers), Big Ten (76), ACC (54), Big 12 (48), Pac-12 (42).";

# --- AI Types ---

obj AISummary {
    has title: str;
    has content: str;
}

sem AISummary.title = "A concise, descriptive title for the AI summary";
sem AISummary.content = "A detailed 3-5 sentence analysis paragraph about college transfer portal activity";

obj NewsStory {
    has headline: str;
    has summary: str;
    has content: str;
    has source: str;
    has date: str;
    has category: str;
}

sem NewsStory.headline = "Catchy headline for the news story about NCAA transfer portal";
sem NewsStory.summary = "Brief 1-2 sentence summary of the story";
sem NewsStory.content = "Full news article content, 3-4 paragraphs";
sem NewsStory.source = "News source attribution (e.g., 'ESPN', 'Sports Illustrated', '247Sports')";
sem NewsStory.date = "Publication date in format 'Month Day, Year'";
sem NewsStory.category = "Category like 'Transfer News', 'Analysis', 'Trending', 'Recruiting'";

obj PlayerAnalysis {
    has strengths: list;
    has areas_for_growth: list;
    has overall_assessment: str;
    has projected_impact: str;
    has fit_rating: str;
}

sem PlayerAnalysis.strengths = "List of 3-5 key strengths as strings";
sem PlayerAnalysis.areas_for_growth = "List of 2-3 areas for improvement as strings";
sem PlayerAnalysis.overall_assessment = "2-3 sentence overall assessment of the player";
sem PlayerAnalysis.projected_impact = "One sentence about projected impact at new team";
sem PlayerAnalysis.fit_rating = "Rating: 'Excellent', 'Good', 'Moderate', or 'Uncertain'";

obj TeamAnalysis {
    has portal_strategy: str;
    has key_additions: str;
    has key_losses: str;
    has outlook: str;
    has risk_level: str;
}

sem TeamAnalysis.portal_strategy = "2-3 sentence description of team's portal strategy";
sem TeamAnalysis.key_additions = "Summary of most impactful incoming transfers";
sem TeamAnalysis.key_losses = "Summary of most significant departures";
sem TeamAnalysis.outlook = "2-3 sentence outlook for next season based on portal activity";
sem TeamAnalysis.risk_level = "Risk level: 'Low', 'Moderate', or 'High'";

obj ChatResponse {
    has response: str;
}

sem ChatResponse.response = "A helpful, informative response about NCAA transfer portal. Should be 2-4 sentences, conversational but factual. Reference specific teams, players, or statistics when possible.";

obj PortalOverview {
    has title: str;
    has content: str;
}

sem PortalOverview.title = "A short, engaging title summarizing the current transfer portal landscape (5-10 words). If favorite teams are provided, the title should reflect activity related to those teams. Example: 'SEC Heavyweights Shake Up the Portal' or 'Your Teams Are Making Moves'";
sem PortalOverview.content = "A 3-5 sentence analysis paragraph about recent NCAA college sports transfer portal activity. Reference specific team names, player names, positions, star ratings, and statistics from the provided context. Mention notable trends like which conferences are most active, which positions are in high demand, and significant player movements. If favorite teams are provided, focus the analysis on how portal activity impacts those specific teams. Be informative yet conversational, suitable for a sports analytics dashboard.";

"""Generate a transfer portal overview summary.
You are PortAI, an expert NCAA transfer portal analyst.
Use the provided portal_context to generate an insightful summary of recent transfer portal activity.
The context includes real data about teams, players, recent transactions, and portal statistics.
If favorite_teams_context is provided, prioritize analysis of those teams."""
def generate_portal_overview(
    portal_context: str,
    favorite_teams_context: str
) -> PortalOverview by llm();

"""Generate an AI summary for the transfer portal overview."""
def generate_summary(context: str) -> AISummary by llm();

"""Generate a news story about NCAA transfer portal activity."""
def generate_news_story(topic: str) -> NewsStory by llm();

"""Generate a player scouting analysis."""
def generate_player_analysis(player_info: str) -> PlayerAnalysis by llm();

"""Generate a team transfer portal analysis."""
def generate_team_analysis(team_info: str) -> TeamAnalysis by llm();

"""Generate a chat response about transfer portal topics."""
def generate_chat_response(question: str) -> ChatResponse by llm();


# --- Data Nodes ---

node User {
    has username: str;
    has favorite_team_ids: list = [];
}


# --- Server Walkers ---

walker:pub get_ai_summary {
    has context: str;

    can with Root entry {
        result = generate_summary(self.context);
        report {"title": result.title, "content": result.content};
    }
}

walker:pub get_news {
    has topic: str = "latest NCAA transfer portal activity";

    can with Root entry {
        result = generate_news_story(self.topic);
        report {
            "headline": result.headline,
            "summary": result.summary,
            "content": result.content,
            "source": result.source,
            "date": result.date,
            "category": result.category
        };
    }
}

walker:pub get_player_analysis {
    has player_info: str;

    can with Root entry {
        result = generate_player_analysis(self.player_info);
        report {
            "strengths": result.strengths,
            "areas_for_growth": result.areas_for_growth,
            "overall_assessment": result.overall_assessment,
            "projected_impact": result.projected_impact,
            "fit_rating": result.fit_rating
        };
    }
}

walker:pub get_team_analysis {
    has team_info: str;

    can with Root entry {
        result = generate_team_analysis(self.team_info);
        report {
            "portal_strategy": result.portal_strategy,
            "key_additions": result.key_additions,
            "key_losses": result.key_losses,
            "outlook": result.outlook,
            "risk_level": result.risk_level
        };
    }
}

walker:pub chat {
    has question: str;

    can with Root entry {
        result = generate_chat_response(self.question);
        report {"response": result.response};
    }
}

walker:priv get_portal_summary {
    has favorite_team_ids: list = [];
    has found_user: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can load_user with User entry {
        if not self.found_user {
            self.found_user = True;
            self.favorite_team_ids = here.favorite_team_ids;
        }
    }

    can generate with Root exit {
        # Build the portal context string from mock data
        teams_summary = "";
        for t in mock_teams_data {
            teams_summary = teams_summary + t["name"] + " (" + t["conference"] + "): Portal Activity Score " + str(t["portalActivityScore"]) + ", Record " + t["lastSeasonRecord"] + ", Incoming " + str(t["incomingCount"]) + ", Outgoing " + str(t["outgoingCount"]) + ". ";
        }

        transactions_summary = "";
        for tx in mock_transactions_data {
            transactions_summary = transactions_summary + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + " (" + tx["stats"] + ", " + tx["date"] + "). ";
        }

        portal_context = "PORTAL STATISTICS: " + portal_stats_context + " TEAM ACTIVITY: " + teams_summary + " RECENT TRANSACTIONS: " + transactions_summary;

        # Build favorite teams context if user has favorites
        fav_context = "";
        if len(self.favorite_team_ids) > 0 {
            fav_context = "USER'S FAVORITE TEAMS: ";
            for t in mock_teams_data {
                if t["id"] in self.favorite_team_ids {
                    fav_context = fav_context + t["name"] + " (" + t["conference"] + ", Record: " + t["lastSeasonRecord"] + ", Incoming: " + str(t["incomingCount"]) + ", Outgoing: " + str(t["outgoingCount"]) + ", Activity Score: " + str(t["portalActivityScore"]) + "). ";
                }
            }
            # Include transactions involving favorite teams
            fav_context = fav_context + "TRANSACTIONS INVOLVING FAVORITE TEAMS: ";
            fav_team_names: list = [];
            for t in mock_teams_data {
                if t["id"] in self.favorite_team_ids {
                    fav_team_names.append(t["name"]);
                }
            }
            for tx in mock_transactions_data {
                if tx["fromTeam"] in fav_team_names or tx["toTeam"] in fav_team_names {
                    fav_context = fav_context + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + ". ";
                }
            }
        }

        result = generate_portal_overview(
            portal_context=portal_context,
            favorite_teams_context=fav_context
        );

        report {"title": result.title, "content": result.content};
    }
}

walker:priv update_favorites {
    has new_favorites: list;
    has found: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can update with User entry {
        if not self.found {
            here.favorite_team_ids = self.new_favorites;
            self.found = True;
            report {"status": "updated", "favorites": here.favorite_team_ids};
        }
    }

    can create_if_needed with Root exit {
        if not self.found {
            new_user = here ++> User(username="default", favorite_team_ids=self.new_favorites);
            report {"status": "created", "favorites": new_user[0].favorite_team_ids};
        }
    }
}

walker:priv get_user_favorites {
    has found: bool = False;

    can search with Root entry {
        visit [-->];
    }

    can get_favs with User entry {
        if not self.found {
            self.found = True;
            report {"favorites": here.favorite_team_ids};
        }
    }

    can default_if_none with Root exit {
        if not self.found {
            report {"favorites": []};
        }
    }
}
