# Pseudonymous Automatic Butter Churner

A Project Zomboid mod that adds a buildable "Automatic Butter Churner" workstation: fill it with milk, press Start, and it converts milk into sticks of butter in 5 L increments with no further babysitting.

**Status: work in progress, not yet working end-to-end.** See [Current Status](#current-status) below before expecting this to function correctly in-game.

## What It Does

The Automatic Butter Churner is built from the BUILD menu like any other player-constructed fixture — no washing-machine conversion, no existing world object required. It costs one Screwdriver (kept, not consumed) and one Plank (consumed).

Once built, interacting with it opens a `Drying_Rack`-style crafting window: drag a milk-holding container (Cow Milk or Sheep Milk, e.g. a filled `BucketLargeWood`) into its input slot, press Start, and it consumes the milk 5 L at a time, producing one stick of Butter per 5 L, continuing on its own until the container runs dry. The container itself is returned to the player once the run finishes, holding whatever milk is left over.

## Current Status

DevCycle 2 (see `doc/planning/completed/DevCycle002.md`) closed on 2026-08-31 **without a confirmed, fully-working result.** Known open problems, to be picked up in DevCycle 3:

- The last applied fix (correcting how leftover milk is written back into a container's `FluidContainer`) was never live-tested before the cycle was closed.
- Whether a full multi-batch run (e.g. a 20 L container producing 4 sticks of Butter) completes correctly end to end — including the container ending up back in the player's inventory with the right leftover amount — is unconfirmed.
- The entity has no visual feedback while actively churning (the progress-tier sprite overlay was removed after it turned out to reference invalid tile data, rather than fixed).
- No real custom sprite art exists yet — the entity currently reuses vanilla's own manual Butter Churn (`ChurnBucket`) tile as a placeholder, so it doesn't look visually distinct.
- Churn sound, a schematic/magazine recipe-learn requirement, and power draw (electricity consumption) were never implemented.
- Dragging a milk container into the entity's input slot manually works, but the window's "select inputs" button (the small swap-icon that normally lets a player click to pull matching items from inventory, the way `Drying_Rack` does) likely doesn't list anything usable for this recipe — never fully resolved.

If you're picking this project back up, start by reading `doc/planning/completed/DevCycle002.md`'s Completion Summary in full — it has a phase-by-phase account of what was tried, what broke, and why, plus specific lessons for the next cycle.

## File Structure

```
PseudoButterChurner/               ← mod folder (loaded by the game, id=PseudonymousButterChurner)
  42/
    media/
      scripts/
        entities/workstations/
          entity_AutoButterChurn.txt          ← the entity: build recipe, Resources/DryingCraftLogic, sprite
          entity_AutoButterChurn_xuiSkin.txt  ← display name, icon, crafting window binding
        recipes/
          PseudoButterChurnerRecipes.txt      ← the milk -> butter churning recipe
      lua/
        client/
          AutoButterChurnEntityDiagnostic.lua      ← diagnostic: confirms the entity script resolves correctly
          AutoButterChurnWindowDiagnostic.lua       ← diagnostic: reports why the crafting window can/can't open
          ISUI/
            ISAutoButterChurnOpenMenu.lua           ← adds the entity's own right-click "Open" menu option
            AutoButterChurnItemSlotHook.lua         ← snapshots milk amount when the input slot's contents change
        shared/
          AutoButterChurnBuildHooks.lua             ← sets the entity's world sprite once built
          AutoButterChurnCode.lua                   ← owns all milk/butter production math and container handling
          Translate/EN/Tooltip.json
    mod.info
    poster.png
doc/
  ideas/                            ← design/investigation notes written before implementation
    claude_automaticButterChurning.md
    claude_dryingRackSimilarity.md
  planning/                         ← DevCycle planning documents
    DevelopmentProcess.md
    DevCycleTemplate.md
    examples/
    completed/
      DevCycle001.md                ← washing-machine-conversion approach, abandoned
      DevCycle002.md                ← BUILD-menu approach, closed incomplete - read this first
AGENTS.md
CLAUDE.md
README.md
```

Diagnostic logging (the two `*Diagnostic.lua` files, plus `print()` statements throughout `AutoButterChurnCode.lua`) is deliberately left in place and should stay until the full flow is confirmed working end-to-end in-game — do not remove it while picking this project back up.

## Why the Production Logic Lives Entirely in Lua

`AutoButterChurnCode.lua` does not rely on the game engine's own recipe-driven fluid consumption for the actual milk-to-butter math. Extensive testing during DevCycle 2 found that, for this specific combination of `component Resources` + `component DryingCraftLogic` + a `-fluid`-modified item input, the engine:

- drains a container's entire fluid content in one completed batch, not the declared per-batch amount, and
- removes the container item from its input slot on every completed batch regardless of `mode:keep`.

Both behaviors contradicted what reading the decompiled game source suggested should happen. Rather than keep fighting the engine's own accounting, the mod now tracks milk quantity and container identity itself in Lua, only using the engine's recipe system to trigger the Start button, the crafting window, and the timing between batches. Any future change to the entity's fill/production mechanic should keep this in mind and continue routing through the mod's own tracking rather than trusting the engine's fluid-consumption math for this component combination.

## Development Process

This project uses a DevCycle workflow. See `doc/planning/DevelopmentProcess.md` for the full process.

For AI agents: read `AGENTS.md` before starting any work.

## Compatibility

The mod targets **Project Zomboid build 42**.
