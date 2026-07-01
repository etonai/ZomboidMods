# PseudonymousEd's Kentucky Kimchi

A Project Zomboid B42 mod that adds a Kentucky-style kimchi recipe using cabbage, salt, water, garlic, dried jalapeno, and cooked little bait fish.

## What It Does

PseudoKimchi adds Kentucky Kimchi as a jarred preserved food, with equivalent recipes for a glass jar, clay jar, and glazed clay jar. The first version keeps the scope deliberately small so the core recipes and food values can be verified before adding optional ingredients such as ginger.

## File Structure

```
PseudoKimchi/               <- wrapper folder
  PseudoKimchi/             <- mod folder loaded by the game
    42/
      media/scripts/items/  <- Kentucky kimchi food item
      media/scripts/recipes/<- Kentucky kimchi craft recipe
      mod.info
      poster.png
  doc/
    ideas/                  <- design notes
    planning/               <- DevCycle planning documents
  AGENTS.md
  CLAUDE.md
  README.md
```

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` and the active DevCycle document in `doc/planning/`.

For AI agents: read `AGENTS.md` before starting work.