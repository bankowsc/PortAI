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
import csv;
import os;

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

# --- CSV Data Layer ---
# Resolve the CSV path relative to this file's directory
glob CSV_DIR: str = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scraping", "transfer_247_data");
glob CSV_FILE: str = os.path.join(CSV_DIR, "transfer_portal_247_2026.csv");

def read_all_transfers() -> list {
    # Read all transfers from the 2026 CSV file. Returns list of dicts.
    # Deduplicates by profile_url since each transfer can appear under both teams.
    transfers: list = [];
    seen_urls: dict = {};
    with open(CSV_FILE, "r", encoding="utf-8") as f {
        reader = csv.DictReader(f);
        row_id = 1;
        for row in reader {
            profile_url = row.get("profile_url", "").strip();
            if profile_url and profile_url in seen_urls {
                continue;
            }
            if profile_url {
                seen_urls[profile_url] = True;
            }
            stars_str = row.get("stars", "0").strip();
            stars_val = int(stars_str) if stars_str.isdigit() else 0;

            rating_val = None;
            raw_rating = row.get("rating", "").strip();
            if raw_rating and "N/A" not in raw_rating {
                clean_rating = raw_rating.replace(".", "", 1);
                if clean_rating.isdigit() {
                    rating_val = float(raw_rating);
                }
            }

            weight_str = row.get("weight", "0").replace(" lbs", "").replace("lbs", "").strip();
            weight_val = int(weight_str) if weight_str.isdigit() else 0;
            status_raw = row.get("status", "N/A");
            if status_raw == "N/A" {
                status_raw = "In Portal";
            }
            to_school = row.get("to_school", "N/A");
            if to_school == "N/A" or not to_school {
                to_school = "Undecided";
            }
            transfers.append({
                "id": str(row_id),
                "playerId": str(row_id),
                "playerName": row.get("name", "Unknown"),
                "playerPhoto": "👤",
                "position": row.get("position", "N/A"),
                "fromTeam": row.get("from_school", "Unknown"),
                "fromTeamLogo": "🏈",
                "toTeam": to_school,
                "toTeamLogo": ("🏈" if to_school != "Undecided" else "❓"),
                "starRating": stars_val,
                "rating": rating_val,
                "height": row.get("height", "N/A"),
                "weight": weight_val,
                "status": status_raw,
                "stats": {},
                "date": "2026",
                "sport": "Football",
                "profileUrl": row.get("profile_url", "")
            });
            row_id = row_id + 1;
        }
    }
    return transfers;
}

def get_paginated_transfers(offset: int = 0, limit: int = 100, search_query: str = "", position_filter: str = "all", status_filter: str = "all") -> dict {
    # Get a paginated slice of transfers with optional filters.
    all_transfers = read_all_transfers();
    filtered: list = [];
    sq = search_query.lower().strip();
    for t in all_transfers {
        if position_filter != "all" and t["position"] != position_filter {
            continue;
        }
        if status_filter != "all" {
            if status_filter == "committed" and t["status"] not in ["Committed", "Enrolled", "Signed"] {
                continue;
            }
            if status_filter == "in_portal" and t["status"] not in ["In Portal", "Entered"] {
                continue;
            }
            if status_filter == "withdrawn" and t["status"] != "Withdrawn" {
                continue;
            }
        }
        if sq {
            name_match = sq in t["playerName"].lower();
            from_match = sq in t["fromTeam"].lower();
            to_match = sq in t["toTeam"].lower();
            pos_match = sq in t["position"].lower();
            if not (name_match or from_match or to_match or pos_match) {
                continue;
            }
        }
        filtered.append(t);
    }
    total = len(filtered);
    page = filtered[offset:offset + limit];
    return {"transfers": page, "total": total, "offset": offset, "limit": limit};
}

def get_portal_stats_from_csv() -> dict {
    # Compute real portal statistics from the CSV data.
    all_transfers = read_all_transfers();
    total = len(all_transfers);
    position_counts: dict = {};
    conference_counts: dict = {};
    status_counts: dict = {"Committed": 0, "Enrolled": 0, "In Portal": 0, "Entered": 0, "Withdrawn": 0};
    for t in all_transfers {
        pos = t["position"];
        if pos in position_counts {
            position_counts[pos] = position_counts[pos] + 1;
        } else {
            position_counts[pos] = 1;
        }
        # Map from_school to conference using mock_teams_data
        for team in mock_teams_data {
            team_short = team["name"].split(" ")[0];
            if team_short.lower() in t["fromTeam"].lower() or t["fromTeam"].lower() in team["name"].lower() {
                conf = team["conference"];
                if conf in conference_counts {
                    conference_counts[conf] = conference_counts[conf] + 1;
                } else {
                    conference_counts[conf] = 1;
                }
                break;
            }
        }
        st = t["status"];
        if st in status_counts {
            status_counts[st] = status_counts[st] + 1;
        }
    }
    # Sort positions by count descending - manual approach
    pos_items = list(position_counts.items());
    # Simple bubble sort for positions
    for i in range(len(pos_items)) {
        for j in range(i + 1, len(pos_items)) {
            if pos_items[j][1] > pos_items[i][1] {
                temp = pos_items[i];
                pos_items[i] = pos_items[j];
                pos_items[j] = temp;
            }
        }
    }
    top_positions: list = [];
    for p in pos_items[:6] {
        top_positions.append({"name": p[0], "value": p[1]});
    }

    conf_items = list(conference_counts.items());
    for i in range(len(conf_items)) {
        for j in range(i + 1, len(conf_items)) {
            if conf_items[j][1] > conf_items[i][1] {
                temp = conf_items[i];
                conf_items[i] = conf_items[j];
                conf_items[j] = temp;
            }
        }
    }
    top_conferences: list = [];
    for c in conf_items[:5] {
        top_conferences.append({"name": c[0], "transfers": c[1]});
    }
    return {
        "totalTransfers": total,
        "topPositions": top_positions,
        "topConferences": top_conferences,
        "statusBreakdown": status_counts
    };
}

glob portal_stats_context: str = "";

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

obj TransferImpact {
    has impact: str;
}

sem TransferImpact.impact = "A concise 1-2 sentence description of this player's transfer impact. Reference the player's position, star rating, previous team, and destination team. Assess how the move strengthens or weakens both teams. Be specific and analytical, not generic.";

"""Generate a short AI impact assessment for a player transfer.
You are PortAI, an expert NCAA transfer portal analyst.
Given a player's name, position, star rating, previous team, destination team, height, weight, and status,
produce a brief but insightful 1-2 sentence impact assessment."""
def generate_transfer_impact(
    player_context: str
) -> TransferImpact by llm();


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

# --- Dynamic Data Walkers ---

walker:priv get_transfers {
    """Paginated transfer data from CSV. Returns {transfers, total, offset, limit}."""
    has offset: int = 0;
    has limit: int = 100;
    has search_query: str = "";
    has position_filter: str = "all";
    has status_filter: str = "all";

    can with Root entry {
        result = get_paginated_transfers(
            offset=self.offset,
            limit=self.limit,
            search_query=self.search_query,
            position_filter=self.position_filter,
            status_filter=self.status_filter
        );
        report result;
    }
}

walker:priv search_players {
    """Search players by name, position, or team. Returns paginated results."""
    has query: str = "";
    has offset: int = 0;
    has limit: int = 50;
    has position_filter: str = "all";

    can with Root entry {
        result = get_paginated_transfers(
            offset=self.offset,
            limit=self.limit,
            search_query=self.query,
            position_filter=self.position_filter
        );
        # Transform transfers into player-oriented format
        players: list = [];
        for t in result["transfers"] {
            players.append({
                "id": t["id"],
                "name": t["playerName"],
                "photo": "👤",
                "position": t["position"],
                "height": t["height"],
                "weight": str(t["weight"]) + " lbs" if t["weight"] else "N/A",
                "starRating": t["starRating"],
                "rating": t["rating"],
                "currentTeam": t["toTeam"] if t["toTeam"] != "Undecided" else t["fromTeam"],
                "previousTeam": t["fromTeam"] if t["toTeam"] != "Undecided" else "N/A",
                "status": t["status"],
                "profileUrl": t["profileUrl"]
            });
        }
        report {"players": players, "total": result["total"], "offset": self.offset, "limit": self.limit};
    }
}

walker:priv get_player_by_id {
    """Get a single player's details by their row ID."""
    has player_id: str;

    can with Root entry {
        all_transfers = read_all_transfers();
        for t in all_transfers {
            if t["id"] == self.player_id {
                report {
                    "id": t["id"],
                    "name": t["playerName"],
                    "photo": "👤",
                    "position": t["position"],
                    "height": t["height"],
                    "weight": str(t["weight"]) + " lbs" if t["weight"] else "N/A",
                    "starRating": t["starRating"],
                    "rating": t["rating"],
                    "currentTeam": t["toTeam"] if t["toTeam"] != "Undecided" else t["fromTeam"],
                    "previousTeam": t["fromTeam"] if t["toTeam"] != "Undecided" else "N/A",
                    "fromTeam": t["fromTeam"],
                    "toTeam": t["toTeam"],
                    "status": t["status"],
                    "profileUrl": t["profileUrl"]
                };
                return;
            }
        }
        report {"error": "Player not found"};
    }
}

walker:priv get_ai_impact {
    """Generate an AI impact assessment for a specific transfer."""
    has player_id: str;

    can with Root entry {
        all_transfers = read_all_transfers();
        for t in all_transfers {
            if t["id"] == self.player_id {
                context = (
                    t["playerName"] + ", " + t["position"] + ", " +
                    str(t["starRating"]) + "-star (rating: " + str(t["rating"]) + "). " +
                    "Height: " + t["height"] + ", Weight: " + str(t["weight"]) + " lbs. " +
                    "Transferring from " + t["fromTeam"] + " to " + t["toTeam"] + ". " +
                    "Status: " + t["status"] + "."
                );
                result = generate_transfer_impact(player_context=context);
                report {"impact": result.impact, "playerId": self.player_id};
                return;
            }
        }
        report {"impact": "Unable to generate impact assessment.", "playerId": self.player_id};
    }
}

walker:priv get_portal_stats {
    """Get real-time portal statistics computed from CSV data."""

    can with Root entry {
        stats = get_portal_stats_from_csv();
        report stats;
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
        # Build portal context from real CSV data
        stats = get_portal_stats_from_csv();
        portal_context = "PORTAL STATISTICS: Total transfers: " + str(stats["totalTransfers"]) + ". ";
        portal_context = portal_context + "Top positions entering portal: ";
        for p in stats["topPositions"] {
            portal_context = portal_context + p["name"] + " (" + str(p["value"]) + "), ";
        }
        portal_context = portal_context + ". Most active conferences: ";
        for c in stats["topConferences"] {
            portal_context = portal_context + c["name"] + " (" + str(c["transfers"]) + " transfers), ";
        }

        # Add sample of notable transfers (4+ star players)
        notable = get_paginated_transfers(offset=0, limit=20, search_query="", position_filter="all");
        transactions_summary = "RECENT NOTABLE TRANSACTIONS: ";
        for tx in notable["transfers"] {
            if tx["starRating"] >= 3 {
                transactions_summary = transactions_summary + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + ". ";
            }
        }

        teams_summary = "TEAM ACTIVITY: ";
        for t in mock_teams_data {
            teams_summary = teams_summary + t["name"] + " (" + t["conference"] + "). ";
        }

        portal_context = portal_context + teams_summary + transactions_summary;

        # Build favorite teams context if user has favorites
        fav_context = "";
        if len(self.favorite_team_ids) > 0 {
            fav_context = "USER'S FAVORITE TEAMS: ";
            for t in mock_teams_data {
                if t["id"] in self.favorite_team_ids {
                    fav_context = fav_context + t["name"] + " (" + t["conference"] + "). ";
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
            # Search CSV for transfers involving favorite teams
            all_transfers = read_all_transfers();
            count = 0;
            for tx in all_transfers {
                for fav_name in fav_team_names {
                    short_name = fav_name.split(" ")[0].lower();
                    if short_name in tx["fromTeam"].lower() or short_name in tx["toTeam"].lower() {
                        fav_context = fav_context + tx["playerName"] + " (" + tx["position"] + ", " + str(tx["starRating"]) + "-star): " + tx["fromTeam"] + " -> " + tx["toTeam"] + ". ";
                        count = count + 1;
                        break;
                    }
                }
                if count >= 15 {
                    break;
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
