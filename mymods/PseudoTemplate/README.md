# PseudoTemplate

A starter template for new Project Zomboid mods in this project. Copy this directory, rename it, and fill in the placeholders — it has no gameplay content of its own.

## Using This Template

1. Copy `PseudoTemplate/` to a new directory named for the mod being created (e.g. `PseudoWhatever/`).
2. Rename the nested `PseudoTemplate/42/` mod folder to match, and update `mod.info` inside it:
   - `name=` — the mod's display name
   - `id=` — a unique mod ID
   - `description=` — a short description
   - `poster=` — replace `poster.png` with real cover art if available; the placeholder is a blank/generic image
3. Add the mod's actual content under the mod folder's `42/media/` (and `common/media/` if the mod should also support other builds — see other mods in this project, e.g. `PseudoAgriculture`, for that split).
4. Replace this README with one describing the actual mod, following the shape used by other mods in this project (what it does, file structure, compatibility).
5. Start a `DevCycle001.md` in `doc/planning/` from `DevCycleTemplate.md` to plan the mod's first development cycle.

## File Structure

```
PseudoTemplate/             ← mod folder (loaded by the game, id=PseudonymousEdModTemplate)
  42/
    mod.info
    poster.png               ← placeholder art, replace before shipping
doc/
  planning/                  ← DevCycle planning documents
    DevelopmentProcess.md
    DevCycleTemplate.md
    examples/
AGENTS.md
CLAUDE.md
README.md                    ← this file - replace once the mod has real content
```

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` for the full process.

For AI agents: read `AGENTS.md` before starting any work.

## Compatibility

Targets **Project Zomboid build 42** by default, matching the nested `42/` mod folder. Add a `common/` folder alongside `42/` if the new mod needs to support other builds too.
