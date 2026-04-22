# PortAI

PortAI aggregates transfer portal activity across college football and surfaces AI-generated summaries, player and team profiles, transactions, and news. Built as a full-stack Jac application.

## Demo

[![PortAI Demo](/assets/demo_thumbnail.png)](https://youtu.be/ppkHVHOR12w)

## Getting started

### Prerequisites

- Python 3.11+

### Install

```bash
git clone https://github.com/bankowsc/PortAI.git
cd PortAI
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install jaclang byllm
export GEMINI_API_KEY=your_key_here
```

### Run

```bash
cd portai_jac
jac start
```

## Features

- Browse players, teams, transactions, and games
- Crystal Ball: predicts where a given player is likely to transfer
- AI analysis of player fits and team needs
- Per-team news digests scraped and summarized 
- Favorites, chat panel, and analytics dashboard
- Full-stack in Jac. frontend (`.cl.jac`) and backend in one language

## Tech stack

- **Jac / Jaseci**: app framework (frontend + backend)
- **byllm + Gemini 2.5 Flash**: LLM layer
- **Python**: scrapers for 247Sports, On3, ESPN, Twitter
- **Playwright / Selenium / BeautifulSoup**; scraping
- **scikit-learn, pandas**: data processing and modeling

## Project structure

```
PortAI/
├── main.jac               # app entry, AI types, server walkers
├── frontend.cl.jac        # root frontend module
├── frontend.impl.jac
├── portai_jac/
│   ├── pages/             # HomePage, PlayersPage, TeamDetailPage, ...
│   ├── components/        # PlayerCard, ChatPanel, Navigation, ...
│   └── data/              # static data
├── scraping/              # Python scrapers (247, On3, ESPN, Twitter)
├── assets/                # logo and images
└── requirements.txt
```
