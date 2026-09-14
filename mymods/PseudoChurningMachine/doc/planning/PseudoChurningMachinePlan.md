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
- **Amphora** — liquid container behavior (fill, remove, empty; 20L capacity)

Originally also drew on the **Composter**'s "Get Compost"-style menu pattern for a fullness/percentage mechanic; that approach was dropped in favor of placing butter directly into the object's own item inventory (see Core Mechanics, revised 2026-09-12).

It is explicitly **not** a Butter Churn, even though it produces a similar result.

## Core Mechanics

- Capacity: 20 liters, cow's milk only for the initial build (sheep's milk mixing is deferred, see Step 11).
- "Turn On" starts a cycle (target: 15 minutes of game time) with the washer/dryer audio.
- At the end of a cycle, milk is consumed in whole 5-liter increments: for every 5L consumed, the machine produces 1 stick of butter, placed directly into the Churning Machine's own item inventory. Any remainder under 5L stays in the liquid container for the next cycle.
- **Revised 2026-09-12 (DevCycle 004 Phase 4):** butter is no longer tracked via an abstract "fullness" percentage cashed out through a composter-style "Get Butter (X% full)" menu. DevCycle 004 testing found the built object already has its own 20-encumbrance item inventory; butter sticks are placed into it directly as they're produced, and the player retrieves them the normal way (opening/looting the object). This removes the need for a fullness value, a "Get Butter" menu item, and the debug "Add/Reduce Butter" testing items entirely — see the revised Incremental Steps below.

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
5. **Turn On action** — runs for 1 minute (test duration), no other effect. **Closed 2026-09-13 (DevCycle 005) with the audio portion unmet and deferred to Step 11** — the "Turn On"/"Turn Off" toggle, milk gate, and auto-stop timer all work, but the washer/dryer running sound does not play despite matching the vanilla `emitter`/`setEmitterOwner`/`playSoundLoopedImpl` pattern; see `doc/planning/completed/DevCycle005.md`.
6. **Liquid removal on cycle end** — removes a whole multiple of 5L at cycle end; milk simply disappears, no fullness yet.
7. **Butter generation via inventory** (revised 2026-09-12, DevCycle 004 Phase 4) — at the end of a cycle, for every 5L of milk removed, place 1 stick of butter directly into the Churning Machine's own item inventory (the 20-encumbrance capacity discovered in DevCycle 004). No fullness value, no "Get Butter" menu item, and no debug testing items are needed — the player retrieves butter by opening/looting the object directly.
8. **(Merged into Step 7)** — was "Butter generation" (converting a fullness percentage into butter sticks); no longer a separate step now that butter is placed directly with no intermediate fullness value.
9. **(Merged into Step 7)** — was "Wire fullness to the cycle"; no longer applicable for the same reason.
10. **Clean up** — cycle time raised to 15 minutes of game time (from whatever shorter test duration was used while implementing Steps 5-7).
11. **Additional testing and follow-on planning** — manual testing pause; plan correct build materials/recipe; plan sheep's milk support.

## Deferred / Out of Scope (for now)

- **The "Turn On" running sound does not play.** By direct decision (2026-09-13), deferred to Step 11 rather than investigated further now. The Lua code matches the vanilla `emitter`/`setEmitterOwner`/`playSoundLoopedImpl` pattern (`ClothingWasherLogic.java`) exactly, including a `setEmitterOwner` call added specifically to close the gap with vanilla — still silent after that fix. Root cause not found; likely needs in-game audio debugging (or investigating whether it's connected to the Wash Menu/reclassification hypothesis below) rather than more source reading. See `doc/planning/completed/DevCycle005.md` Phase 6.
- Sheep's milk mixing and its contribution to butter output — planned for after Step 11.
- Final build recipe/materials — placeholder (plank + nail) until Step 11 planning.
- **Possible need for a custom mod-owned appearance (texture pack/tile) for the Churning Machine.** DevCycle 004 confirmed the entity currently reuses the literal vanilla `appliances_laundry_01_0` tile (that part is a fact — it's what `SpriteConfig.row` points at), and found an unwanted Wash Menu, the wrong displayed name ("Blue Combo Washer/Dryer"/"Clothing Washer" instead of "Churning Machine"), and a free 20-encumbrance item inventory that Step 7's butter-storage design currently relies on. **The leading hypothesis — not yet confirmed — is that this vanilla tile is baked with a specific `ISO_TYPE` value of `"IsoCombinationWasherDryer"`, or a `CONTAINER` value of `"clothingwasher"`/`"clothingdryer"`, that makes the game reclassify the placed object as a real washer/dryer at a low level.** `CONTAINER` itself is a generic tile property (also used for `barbecue`, `fireplace`, `campfire`, `woodstove`, `microwave`, etc., each a different value of the same key) — it's not inherently washer-related, and it isn't what's being blamed here; the specific *value* assigned to it on this particular tile is what would matter. This is a strong, code-backed theory (the mechanism it describes definitely exists in `CellLoader.java`), but whether this specific tile actually carries one of those specific values has not been directly verified — the tile's own property data isn't accessible in this project's decompiled sources. Investigating and, if confirmed, fixing this (authoring a new mod-owned texture pack + tile definition, the same pattern `PseudoSaltWell42_19` uses for its own graphic) is postponed until after Step 11 by direct decision (2026-09-12), alongside the final build recipe. **Until then, expect the Wash Menu and wrong name to be present, and be aware the free item inventory may not survive if this hypothesis is later confirmed and fixed** — see `doc/planning/completed/DevCycle004.md` Phase 5 Part A for the full trace and its unconfirmed status.
- **"Add Liquid from Item" is missing on the Churning Machine and its cause was not found.** Three candidate causes were investigated and individually ruled out (input lock, container already full, wrong fluid type in the test item) without identifying the real one. By direct decision (2026-09-13), this is deferred to DC 11 rather than continuing to chase it now. **Workaround in the meantime: use "Transfer Liquid" instead** — it works, but is a clunkier interaction than a direct one-click pour would have been. See `doc/planning/completed/DevCycle004.md` Phase 5 Part B.

## Open Questions

None currently blocking — cow's-milk-only scope and the 5L-remainder behavior were clarified during planning discussion (2026-09-12).

Ed question 1: How does the butter churn handle milk mixed with water?
