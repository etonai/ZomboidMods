# Project Zomboid 42.X - Code Analysis & Mod Development

This repository contains AI-assisted code analysis documentation and mod development tooling for Project Zomboid 42.X. The primary purpose is to enable accurate, code-based documentation of game mechanics and to support the creation of mods backed by verified game logic rather than community speculation.

> **Note:** The game source files (`zombie/`, `media/`) and reference mods (`notmymods/`) are **not included in this repository**. They must be present locally (e.g., from a game installation) and are excluded via `.gitignore`. Their content may change as examples are updated.

## Tech Stack

- **Java** — Core game engine source files (`zombie/` directory, local only)
- **Lua** — Game scripting, UI, server logic, and item definitions (`media/` directory, local only)
- **Python 3** — Mod deployment tooling (`deploy_mod.py`)
- **Markdown** — Analysis documentation (`claudeDocs/`, `cursorDocs/`)
- **Claude Code (AI)** — Primary agent for code analysis and documentation
- **Cursor (AI)** — Secondary agent for additional analysis and peer review

## Directory Structure

The following directories are **tracked in this repository**:

```
claudeDocs/      Technical analysis documents authored by Claude
cursorDocs/      Technical analysis documents authored by Cursor
mymods/          Mod projects under development
modPlans/        Planning documents for mod development
```

The following directories must be present **locally** but are excluded from version control (see `.gitignore`):

```
zombie/          Java source files for the game engine (from game installation)
media/           Lua scripts, configurations, translations, and game data (from game installation)
notmymods/       Reference mods used as examples (third-party, not authored here)
```

## Analysis Focus Areas

- **Farming Systems** — Plant growth, disease, fertilizer mechanics, water management
- **Fishing Mechanics** — Fish species, environmental factors, skill progression
- **Game Balance** — Risk-reward systems, player progression
- **Mod Feasibility** — Evaluating and planning new mod implementations

## Key Findings (v42.11.0)

- **Overwatering System**: Completely disabled — all `waterNeededMax` values are commented out in game files
- **Fertilizer System**: Active with a 3-tier risk model (1 application = beneficial, 2+ = growth penalty, 3+ = cursed status)
- **Wiki Accuracy**: Community wikis frequently contain outdated or incorrect information; this project cross-references against actual source code

## Mod Deployment

Mods are developed in `mymods/` and deployed to the local Project Zomboid installation using the included script.

```bash
python deploy_mod.py <ModName>
```

Paths for the development and local mods directories are configured in `config.txt`.

## Documentation Standards

All analysis documents in `claudeDocs/` follow these conventions:

- File references and line numbers for every claim
- Code snippets from the actual game files
- Clear distinction between active and disabled systems
- Version noted as `42.11.0`
- Creation and update dates included in each document
