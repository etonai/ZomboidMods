# PseudoChurningMachine

A Project Zomboid build 42 mod that lets players convert a washing machine into a butter churning machine.

## What It Does

- Converts a (white) top-loading washing machine into a churning machine workstation.
- Churns **sheep or cow milk** into butter.
- If the milk is contaminated with any other liquid, the churn produces nothing — contaminated milk cannot be churned.
- Churning takes **10 minutes of in-game time**.
- Plays churning audio while the machine is running.

## File Structure

```
PseudoChurningMachine/          ← mod folder (loaded by the game, id=PseudonymousChurningMachine)
  42/
    mod.info
    poster.png
    media/
      lua/
        client/
          ChurningMachineCode.lua
        shared/
          TimedActions/
            ISConvertWasherToChurningMachine.lua
          Translate/
            EN/
      scripts/
        entities/
          workstations/
            entity_ChurningMachine.txt
            entity_ChurningMachine_xuiSkin.txt
  common/
    media/
doc/
  planning/                     ← DevCycle planning documents
    DevelopmentProcess.md
    DevCycleTemplate.md
    PseudoChurningMachinePlan.md
    DC18PlusFinalRefinements.md
    completed/                  ← completed DevCycles
    examples/
AGENTS.md
CLAUDE.md
README.md                       ← this file
```

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` for the full process.

For AI agents: read `AGENTS.md` before starting any work.

## Compatibility

Targets **Project Zomboid build 42** by default, matching the nested `42/` mod folder.
