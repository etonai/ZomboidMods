# DevCycle 001: Self-Refilling Naquadah Generator

**Status:** Verified (Ed, 2026-11-06: "good enough", with known out-of-scope gaps listed in the Completion Summary)
**Start Date:** 2026-11-05
**Target Completion:** TBD
**Focus:** Deliver a single-player, debug-spawned "Naquadah Generator" that looks like the Blue Generator and is refueled and repaired every 10 in-game minutes and when its area loads.

**Source documents:** `doc/ideas/PseudonymousEdGenerator.txt` (idea) and `doc/ideas/PseudonymousEdGenerator_ImplementationPlan.md` (plan; Ed's answers in §7 are the requirements for this cycle)
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

Build the smallest version of the PseudoGenerator mod that proves the core mechanic: a visible generator, distinct from the vanilla Blue Generator, whose fuel and condition are reset by the mod so it never runs dry. It is the visible counterpart of the hidden generator RV Life uses (`claudeDocs/claude_RVLifeLessons.md` §4.1). The cycle also settles the engine unknowns from the plan (§6), since they decide how later features (recipes, multiplayer, art) are built.

## Desired Outcome

In a single-player game, a tester spawns a Naquadah Generator with the debug tools, places it, plugs it in, starts it, and:

- it looks and behaves like a Blue Generator (sound, power range, fuel and condition display);
- every 10 in-game minutes, and when its area loads, its fuel and condition are set back to full;
- if the player switches it off by hand, it stays off;
- it may run indoors and is toxic indoors, exactly like a vanilla generator (Ed's answer to Open Question 1);
- a vanilla Blue Generator next to it is **not** refilled;
- it still works after picking it up, re-placing it, saving, and reloading.

## Scope (from Ed's answers)

| Topic | Decision for this cycle |
|---|---|
| Distinguishing it from Blue | New item borrowing another Blue sprite frame (Option B) |
| Name spelling | "Naquadah" |
| Acquisition | Debug spawn only (no recipe or loot) |
| Indoors | **Allowed**, and poisonous like the regular generator (no special handling) |
| Plugging in | The refill does **not** plug it in; the player does that |
| Refill | Refuel and repair only, every 10 in-game minutes. The mod never switches a generator on |
| Manual shutdown | Respected |
| Area load | Also refill when the generator's area loads |
| Balance | None; a plain unlimited generator |
| Multiplayer | Not supported |

**Out of scope:** recipes, world loot, custom art or tilesheet, balance changes, multiplayer, translations beyond the minimum.

---

## Tasks

### Phase 1: Research the unknowns

**Status:** Verified

- [x] Find out whether the sprite→type map (`IsoGenerator.getGeneratorSpriteToType`) resolves a new item that borrows a Blue sprite frame (`appliances_misc_01_13`–`15`) to the new item rather than to `Generator_Blue` (plan §6).
- [x] Find out how a generator item from the debug list is placed, and whether the placement code (`ISMoveableSpriteProps`, hard-coded for sprites `appliances_misc_01_12`–`15`) produces a generator of the new type or of `Generator_Blue`.
- [x] Confirm that `ISTakeGenerator` returns the new item type when the generator is picked up.
- [x] Find a reliable way to detect a Naquadah Generator in the world from Lua (`getGeneratorItemType()`, the object's modData `generatorFullType`, or both).
- [x] Choose how to keep track of Naquadah Generators, since the engine's generator list is private (plan §3.2): a saved registry of locations, loaded-square events, or both.
- [x] Find the best event for "an area loads" so a registered generator can be refilled when its square becomes available.
- [x] Find a way to stop a Naquadah Generator from running indoors — **no longer needed**: Ed's answer to Open Question 1 allows indoor use.
- [x] Record each finding in the Technical Notes below.

**Technical Notes (findings, read from the v42.20.4 code; none of this has been run in game):**

1. **Type lookup.** `IsoGenerator.getGeneratorItemType()` (`IsoGenerator.java:148-156`) looks up the generator's sprite name in a map built from every item script tagged `base:generator`, keyed by each item's `WorldObjectSprite` (`:134-146`). Our item uses `appliances_misc_01_13`; `Generator_Blue` uses `appliances_misc_01_12`. The keys differ, so there is no collision and the lookup should return `PseudoGenerator.NaquadahGenerator`. The fallback for an unknown sprite is `Base.Generator`.
2. **Placement.** Dropping a generator item runs `ISDropWorldItemAction:complete` → `IsoGridSquare:AddWorldInventoryItem`, which creates `new IsoGenerator(item, cell, square)` for any item tagged `base:generator` that has a `WorldObjectSprite` (`IsoGridSquare.java:6603, 6669`). The constructor takes the sprite from the item script. The hard-coded sprite branches in `ISMoveableSpriteProps.lua:2024-2046` belong to the moveable-furniture tool, not to dropping a generator item, so they do not apply here. Likewise `MOGenerator.lua` only converts generator tiles that come from the map.
3. **Pick-up.** `ISTakeGenerator:complete` creates `instanceItem(generator:getGeneratorItemType())`, so a picked-up Naquadah Generator comes back as the Naquadah item, with condition and fuel carried over.
4. **Detection.** `PseudoGenerator.isNaquadah(generator)` compares `getGeneratorItemType()` to the item's full type and falls back to the object's modData `generatorFullType` (set by the constructor from the item).
5. **Tracking.** `AllGenerators` is private, so the mod keeps a registry in global ModData (`PseudoGenerator.gens`, keyed `"x,y,z"`). Entries are added after a Naquadah Generator is dropped and removed when it is picked up. The ten-minute pass also removes an entry whose loaded square no longer holds a Naquadah Generator.
6. **Area load.** The engine fires `LoadChunk` (with the `IsoChunk`) at the end of chunk loading (`IsoChunk.java:3971`). The mod handles it by maintaining the registered generators inside that chunk. `Events.OnObjectAdded` is not triggered by the engine for generators in the code I read, so it is not used.
7. **Long absences (important).** `IsoGenerator.update` charges fuel and condition for *every in-game hour since its internal `lastHour`* on its first update after loading (`IsoGenerator.java:195-225`); `lastHour` is private and has no Lua setter. Refilling alone on chunk load therefore does not stop a generator from draining to zero in a single step after a long absence. The mod works around it: when at least one in-game hour has passed since it last maintained a running generator, it switches that generator off and on, because `setActivated(true)` resets `lastHour` to now (`:526-533`). A generator that is off is left off. The side effects are a short "stopping" and "starting" sound, and the building toxicity flag turning off and on again. This workaround is unverified.
8. **Indoors.** Not needed (see Open Question 1).

### Phase 2: Item and debug spawn

**Status:** Verified (implemented; Ed accepted the result in game)

- [x] Add the `NaquadahGenerator` item script, based on `Generator_Blue` with the `base:generator` tag and the sprite chosen in Phase 1.
- [x] Give it a display name ("Naquadah Generator") and a tooltip.
- [x] Confirm it can be spawned from the debug item list, placed, plugged in, and started like a Blue Generator. *(Phase 6)*
- [x] Confirm picking it up returns the Naquadah item, not a Blue Generator. *(Phase 6)*
- [x] Update `mod.info` (description, and poster if the placeholder is not acceptable) as needed. *(Reviewed; the existing `mod.info` already names the Naquadah Generator, so no change was made. The poster is still the template placeholder.)*

**Technical Notes:**
- Item script: `PseudoGenerator/42/media/scripts/items/PseudoGenerator_Items.txt`, module `PseudoGenerator`, item `NaquadahGenerator` (full type `PseudoGenerator.NaquadahGenerator`). It is a copy of `Generator_Blue` (weight 30, icon `Generator3`, sound radius 23, same tags) with `WorldObjectSprite = appliances_misc_01_13`.
- Display name: `lua/shared/Translate/EN/ItemName.json` (`"PseudoGenerator.NaquadahGenerator": "Naquadah Generator"`). The tooltip is the vanilla `Tooltip_Generator`.
- **Frame choice (Open Question 3):** I picked frame `13` because it is a Blue-family frame that does not collide with the vanilla Blue item (`12`). I did not check how it looks or which way it faces. Please confirm this visually in Phase 6; frames `14` and `15` are the alternatives.

### Phase 3: Tracking Naquadah Generators

**Status:** Verified (implemented; Ed accepted the result in game)

- [x] Implement the identification helper (`isNaquadah(generator)`) from the Phase 1 findings.
- [x] Record each Naquadah Generator's location in global ModData when it is placed.
- [x] Remove the record when it is picked up or destroyed.
- [x] Drop stale records whose generator no longer exists.
- [x] Confirm the records survive save and load. *(Phase 6)*

**Technical Notes:**
- `PseudoGenerator/42/media/lua/shared/PseudoGenerator/PseudoGenerator.lua`: constants and `isNaquadah`.
- `PseudoGenerator/42/media/lua/server/PseudoGenerator/PseudoGeneratorServer.lua`: registry (`register`, `unregister`), and wrappers around `ISDropWorldItemAction:complete` (register after a drop) and `ISTakeGenerator:complete` (unregister on pick-up).
- **Known limitations:** a Naquadah Generator that reaches the world by any route other than dropping the item (for example, a mod that creates an `IsoGenerator` directly) is not tracked. A generator destroyed by other means is dropped from the registry at the next ten-minute pass. The registry is read through `ModData.getOrCreate` during chunk loading; it is not verified that the saved global ModData is already loaded at that moment (Phase 6 should include a reload test).

### Phase 4: Refill logic

**Status:** Verified (implemented; Ed accepted the result in game)

- [x] On `EveryTenMinutes`, for each tracked generator whose square is loaded: set condition to 100 and fuel to 10 (the engine maximum).
- [x] Do the same when a tracked generator's area loads.
- [x] Do **not** plug the generator in (`setConnected` is left to the player).
- [x] Respect a manual shutdown. The mod never switches a generator on; the off/on cycle in Technical Note 7 is applied only to a generator that is already running.
- [x] Make sure a vanilla Blue Generator placed nearby is never touched. (Only registered, `isNaquadah` generators are maintained.)
- [x] Run only in single player (and on the host); no multiplayer handling. (`if isClient() then return end`.)

**Technical Notes:**
- `maintain(entry, generator)` sets condition to 100 and fuel to 10 only if they are lower, then applies the long-absence workaround (Phase 1, finding 7) and records the world age in `entry.hour`.
- Handlers: `Events.EveryTenMinutes` (all registered entries whose square is loaded) and `Events.LoadChunk` (entries inside the loaded chunk, using `chunk.wx/wy` and `chunk:getGridSquare`).
- Not verified: that `chunk.wx` and `chunk.wy` are readable from Lua as fields, that `chunk:getGridSquare` returns the square at `LoadChunk` time, and the off/on workaround itself.

### Phase 5: Indoor use

**Status:** Verified (no code needed)

- [x] Ed's answer to Open Question 1: the generator may run indoors and is toxic like a regular generator. No restriction is implemented.
- [x] An indoor restriction I had briefly added before re-reading Ed's answer was removed again. Nothing in the mod touches indoor behavior.

**Technical Notes:**
- Vanilla behavior applies: a running generator indoors flags the building toxic (`IsoGenerator.java:526-531`).

### Phase 6: In-game testing

**Status:** Verified (Ed tested in game and accepted the result; individual checklist results were not recorded)

- [x] Spawn, place, plug in, and start the item; confirm it behaves like a Blue Generator and which direction/frame it shows.
- [x] Lower fuel and condition with debug tools, wait for the next 10-minute tick, and confirm fuel is full and condition is 100.
- [x] Turn it off by hand and confirm it stays off after the next tick.
- [x] Pick it up and place it again; confirm it is still a Naquadah Generator and is still refilled.
- [x] Save, quit, reload; confirm tracking and refills continue.
- [x] Leave the area for many in-game hours, return, and confirm the area-load refill prevents a drained generator (this tests the off/on workaround).
- [x] Place a vanilla Blue Generator next to it and confirm the vanilla one is **not** refilled.
- [x] Run it indoors and confirm it behaves like a vanilla generator (toxic fumes warning).
- [x] Check the game console/log for Lua errors from the mod after each step.
- [x] Record the results in the Completion Summary.

**Technical Notes:**
Per `AGENTS.md` and `DevelopmentProcess.md`, work stops at **Work Complete**; only Ed can mark a phase or the cycle **Verified**. To test, copy the mod into the game's mods folder with `utilities/CopyModToZomboid.bat PseudoGenerator` (described in the repository `CLAUDE.md`) and enable "PseudonymousEd's Generator" in the mod list.

### Phase 7: Fix – placed Naquadah Generator behaves like a vanilla generator

**Status:** Verified (Ed accepted the result in game)

**Problem (reported by Ed after first in-game test):** The item spawned and sat in inventory fine, but once placed on the ground it behaved as a regular generator that needs fuel and burns fuel.

**Earlier bug fixed in the same test session:** `onLoadChunk` read `chunk.wx`/`chunk.wy`, which are not readable from Lua (nil), causing `__mul not defined` errors on every chunk load. It now asks the chunk for `getGridSquare(x % 8, y % 8, z)` and checks the square's real coordinates.

**Findings:**
- Vanilla `Map/MapObjects/MOGenerator.lua:61` registers `MapObjects.OnNewWithSprite("appliances_misc_01_13", NewGenerator_Blue, 5)`. That handler replaces any object with sprite `_13` with a `Base.Generator_Blue` at fuel 0, which would discard the Naquadah identity. Our item borrows that sprite.
- `MapObjects.OnNewWithSprite` replaces the function already registered at the same priority (`MapObjects.java:54-58`).
- A newly placed generator starts at fuel 0, and the refill only ran on the next 10-minute pass, so it looked like a normal empty generator in the meantime.
- Not confirmed: whether the vanilla handler actually fired on placement. The log lines below should tell.

**Changes:**
- [x] Override the vanilla `_13` handler (same priority 5): an existing `IsoGenerator` is left alone.
- [x] Refill fuel and condition immediately when a placed generator is registered.
- [x] Diagnostic `print` lines were added during the fix and removed after Ed confirmed it (2026-11-06).
- [x] Ed to retest: place, confirm full fuel, confirm it does not drain, check `console.txt` for the log lines.

**Technical Notes:** If the register line reports `skipped`, `itemType` and `sprite` show what the placed object actually became. If frame `_13` still gets converted, the fallback is a different approach to identifying the generator (see Open Questions).

---

## Open Questions

All three have been answered.

1. **What exactly does "No" mean for running indoors, and how should it be enforced?**
   **Answer (Ed):** It is allowed to run indoors, and will be poisonous just like the regular generator. *Result: no restriction; Phase 5 needs no code.*

2. **How should "activate" work if a manual shutdown is respected?**
   **Answer (Ed):** The mod only refuels and repairs, as recommended. *Result: the mod never switches a generator on. The off/on cycle used to reset the engine's hour counter after a long absence is applied only to an already-running generator, and I would like Ed to confirm that is acceptable (see New Question A).*

3. **Which Blue sprite frame should the item use?**
   *Result: frame `13` was chosen because it does not collide with the vanilla Blue Generator. Its appearance has not been checked (see New Question B).*

### New questions raised during implementation

A. **Is it acceptable that the mod briefly switches a running Naquadah Generator off and on after a long absence?** It is the only way I found to stop the engine from charging a whole absence's worth of fuel in one step (Phase 1, finding 7). The cost is a short stop/start sound. Without it, the area-load refill would not prevent a drained generator after a long absence.

B. **Does frame `appliances_misc_01_13` look right?** If it faces the wrong way, `14` or `15` can be used instead; this is a one-line change in the item script.

---

## Notes and Risks

- **Nothing has been run in game.** The code was written from the v42.20.4 sources only. No Lua interpreter was available to syntax-check the scripts, so a first launch may show errors that need fixing.
- **Sprite→type lookup:** expected to work (different sprite key from Blue), but unverified. If it fails, the fallback is a custom sprite (Option A) or a modData flag (Option C).
- **No Lua access to the engine's generator list,** so the mod keeps its own registry (see Phase 3 limitations).
- **Long-absence drain:** handled by a workaround that is unverified (Phase 1, finding 7).
- **Single player only.** Multiplayer behavior is deliberately not designed or tested.
- **No balance changes** by design: the generator removes the fuel economy for any player who has one. This is a conscious decision by Ed, with debug spawn as the only source.

---

## Completion Summary

Ed tested the mod in game after the Phase 7 fixes and, on 2026-11-06, explicitly approved all phases and the cycle as **Verified** ("good enough"). Per-step Phase 6 results were not recorded.

**Known gaps accepted as out of scope (candidates for a future DevCycle):**
- A Naquadah Generator on the ground is still labelled "Generator", not "Naquadah Generator" (the world object takes its name from the sprite, not the item).
- `ItemName.json` has the same file name as the vanilla translation file (the game logs an override).
- New Questions A (off/on cycle after long absence) and B (frame `13` appearance) were not formally answered.
- Placement is detected by a once-a-minute scan within 12 tiles of the player, so a newly placed generator can take up to a minute to fill.
