# PseudoGritsPorridgePottage

A Project Zomboid build 42 mod that combines PseudonymousEd's grits, porridge, and pease pottage recipes into one mod.

## What It Does

This mod packages the current working content from:

- `PseudoGrits`
- `PseudoPorridge`
- `PseudoPeasePottage`

It preserves the separate food identities and recipe behavior from those mods while allowing players to enable one combined mod instead of three.

## Included Food Systems

- Grits bowl, saucepan, and cooking pot recipes.
- Sweet and savory grits evolved recipe outcomes.
- Porridge bowl, saucepan, and cooking pot recipes.
- Sweet and savory porridge evolved recipe outcomes.
- Pease pottage saucepan and cooking pot recipes.
- Pease pottage stew-style evolved recipe outcomes.

## File Structure

```text
PseudoGritsPorridgePottage/
  42/
    media/
      lua/shared/Translate/EN/
      scripts/
        evolvedrecipes/
        items/
        recipes/
    mod.info
    poster.png
doc/
  planning/
    DevCycle001.md
    DevelopmentProcess.md
    DevCycleTemplate.md
AGENTS.md
CLAUDE.md
README.md
```

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` for the full process.

For AI agents: read `AGENTS.md` before starting any work.