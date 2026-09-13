# PseudoChurningMachine Plan

**Status:** Planning
**Created:** 2026-09-12
**Source:** `doc/ideas/PseudoChurningMachineIdea.txt`

This is the design plan overview for the PseudoChurningMachine mod. It is intentionally high-level — each step below gets its own detailed planning (a DevCycle) when work on it begins, per `DevelopmentProcess.md`.

## Background

The earlier PseudoButterChurner mod did not work. This mod replaces that approach with a PseudoChurningMachine: a new object that combines behaviors from three existing objects, but is not itself a reskinned Butter Churn.

## What It Is

A combination of:
- **Blue Combo Washer/Dryer** — appearance, "Turn On" action, running audio/cycle
- **Composter** — the "Get Butter" style menu item pattern (like "Get Compost")
- **Amphora** — liquid container behavior (fill, remove, empty; 20L capacity)

It is explicitly **not** a Butter Churn, even though it produces a similar result.

## Core Mechanics

- Capacity: 20 liters, cow's milk only for the initial build (sheep's milk mixing is deferred, see Step 11).
- "Turn On" starts a cycle (target: 15 minutes of game time) with the washer/dryer audio.
- At the end of a cycle, milk is consumed in whole 5-liter increments: for every 5L consumed, fullness increases by 25%. Any remainder under 5L stays in the container for the next cycle.
- "Churner / Get Butter" menu item shows current fullness (e.g. "Get Butter (75% full)"), mirroring the composter's "Get Compost" display.
- Selecting "Get Butter" resets fullness to 0% and grants 1 stick of butter per 25% of fullness consumed.
- Fullness is independent of the milk currently in the container — the machine can hold >100% worth of unprocessed milk if butter isn't collected between cycles, capped only by the 20L liquid limit.

## Build Approach

Research existing analyses first (`claudeDocs/claude_washingMachineAnalysis.md`, `claude_composterAnalysis.md`, `claude_amphoraAnalysis.md`, `claude_butterChurn.md`), verifying against the current build before relying on them, since they may be outdated.

Construction placeholder: 1 plank + 1 nail, following the same pattern PseudoSaltWell uses (simple recipe/tool interaction producing a custom-graphic object) if a comparable approach is needed here.

**Before every in-game verification phase, run `utilities\CopyModToZomboid.bat PseudoChurningMachine` to copy the mod's current source into the local Zomboid mods folder.** Editing files under `mymods/PseudoChurningMachine/` has no effect on the game until this copy step runs — testing against a stale copy is a real risk (`PseudoButterChurner`'s DevCycle 2 repeatedly re-ran this after every fix, and skipping it would have made every verification result meaningless).

## Incremental Steps

Each step is scoped to add one piece of functionality and remain independently testable. Detailed design for each happens in its own DevCycle when started.

1. **Research** — verify the four existing analysis docs against current code. **Done (2026-09-12).** Washing Machine, Amphora, and Butter Churn docs were already verified against 42.20.4 as of 2026-08-30 (no changes needed). Composter doc was still pinned to 42.19 — re-verified against `zombie42_20_4`/`media42_20_4`: all core mechanics (accumulation, conversion, worm breeding, capacity, dung tags, bag withdrawal math) are byte-for-byte unchanged; only correction was the `CompostTime` sandbox option range, which extends to 2016h (8 steps) in 42.20.4 vs the previously documented 1344h (6 steps) max — default of 336h is unchanged.
2. **This plan document** — overview only, no per-step detail yet.
3. **Placeholder object** — buildable with 1 plank + 1 nail, looks like the Blue Combo Washer/Dryer, no functionality, not walkable.
4. **Liquid container** — 20L capacity, add/remove/empty like the Amphora.
5. **Turn On action** — plays washer/dryer audio, runs for 1 minute (test duration), no other effect.
6. **Liquid removal on cycle end** — removes a whole multiple of 5L at cycle end; milk simply disappears, no fullness yet.
7. **Fullness menu item** — adds "Get Butter (0% full)" plus temporary debug items "Add Butter by 25%" / "Reduce Butter by 25%" (unbounded, for testing).
8. **Butter generation** — "Get Butter" resets fullness to 0 and grants 1 stick of butter per 25% fullness.
9. **Wire fullness to the cycle** — cycle end now adds 25% fullness per 5L removed (replacing the manual debug adjustment).
10. **Clean up** — cycle time raised to 15 minutes; debug Add/Reduce Butter menu items removed.
11. **Additional testing and follow-on planning** — manual testing pause; plan correct build materials/recipe; plan sheep's milk support.

## Deferred / Out of Scope (for now)

- Sheep's milk mixing and its contribution to fullness — planned for after Step 11.
- Final build recipe/materials — placeholder (plank + nail) until Step 11 planning.

## Open Questions

None currently blocking — cow's-milk-only scope and the 5L-remainder behavior were clarified during planning discussion (2026-09-12).
