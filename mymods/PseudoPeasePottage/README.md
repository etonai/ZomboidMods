# Realistic Kentucky Farming Calendar

A Project Zomboid mod that replaces vanilla crop growing seasons with calendar-accurate seasons for Central Kentucky.

Primary sources: [almanac.com](https://www.almanac.com) and [University of Kentucky Cooperative Extension](https://extension.uky.edu).

## What It Does

Project Zomboid's vanilla farming uses simplified growing windows that do not reflect real regional agriculture. This mod overrides `farming_vegetableconf.props` for every farmable crop with accurate sowing windows, best months, risk months, and bad months based on Central Kentucky growing conditions.

It does not change game mechanics — only the crop calendar data that the farming system reads.

## File Structure

```
PseudoAgriculture/          ← mod folder (loaded by the game)
  common/
    media/lua/server/
      PseudoGPTFarming.lua  ← version-agnostic crop overrides
  42/
    media/lua/server/
      RealisticKentuckyFarming.lua  ← build-42-specific overrides
    mod.info
    poster.png
doc/
  planning/                 ← DevCycle planning documents
    DevelopmentProcess.md
    DevCycleTemplate.md
    examples/
AGENTS.md
CLAUDE.md
README.md
```

The `common/` folder applies to all supported game versions. The `42/` folder applies specifically to Project Zomboid build 42 and takes precedence over `common/` for that build.

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` for the full process.

For AI agents: read `AGENTS.md` before starting any work.

## Compatibility

The mod targets **Project Zomboid build 42**. See the parent project's `docs/AgricultureChanges_42_19_0.md` for a record of structural changes between the version the mod was originally built against and the current game files.
