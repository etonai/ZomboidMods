# DevCycle 001: Self-Refilling Naquadah Generator

**Status:** Planning
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
- it cannot be run indoors (see Open Question 1 for the exact meaning);
- a vanilla Blue Generator next to it is **not** refilled;
- it still works after picking it up, re-placing it, saving, and reloading.

## Scope (from Ed's answers)

| Topic | Decision for this cycle |
|---|---|
| Distinguishing it from Blue | New item borrowing another Blue sprite frame (Option B) |
| Name spelling | "Naquadah" |
| Acquisition | Debug spawn only (no recipe or loot) |
| Indoors | Not allowed to run indoors (mechanism to be settled, see Open Questions 1) |
| Plugging in | The refill does **not** plug it in; the player does that |
| Refill | Refuel, repair, and activate, every 10 in-game minutes |
| Manual shutdown | Respected (see Open Question 2 about how this fits with "activate") |
| Area load | Also refill when the generator's area loads |
| Balance | None; a plain unlimited generator |
| Multiplayer | Not supported |

**Out of scope:** recipes, world loot, custom art or tilesheet, balance changes, multiplayer, translations beyond the minimum.

---

## Tasks

### Phase 1: Research the unknowns

**Status:** Planning

- [ ] Find out whether the sprite→type map (`IsoGenerator.getGeneratorSpriteToType`) resolves a new item that borrows a Blue sprite frame (`appliances_misc_01_13`–`15`) to the new item rather than to `Generator_Blue` (plan §6).
- [ ] Find out how a generator item from the debug list is placed, and whether the placement code (`ISMoveableSpriteProps`, hard-coded for sprites `appliances_misc_01_12`–`15`) produces a generator of the new type or of `Generator_Blue`.
- [ ] Confirm that `ISTakeGenerator` returns the new item type when the generator is picked up.
- [ ] Find a reliable way to detect a Naquadah Generator in the world from Lua (`getGeneratorItemType()`, the object's modData `generatorFullType`, or both).
- [ ] Choose how to keep track of Naquadah Generators, since the engine's generator list is private (plan §3.2): a saved registry of locations, loaded-square events, or both.
- [ ] Find the best event for "an area loads" so a registered generator can be refilled when its square becomes available.
- [ ] Find a way to stop a Naquadah Generator from running indoors (block the start action, check at refill time, or restrict placement) and record the options.
- [ ] Record each finding in the Technical Notes below.

**Technical Notes:**
*To be filled in during the phase.* Reference points: `zombie42_20_4/iso/objects/IsoGenerator.java` (type lookup lines 134-156, activation 526-531, fuel clamp 512); item script `media42_20_4/scripts/generated/items/normal.txt:4827-4842` (`Generator_Blue`); `lua/shared/Moveables/ISMoveableSpriteProps.lua:2044-2046`; `lua/shared/TimedActions/ISTakeGenerator.lua`; `lua/server/Map/MapObjects/MOGenerator.lua`.

### Phase 2: Item and debug spawn

**Status:** Planning

- [ ] Add the `NaquadahGenerator` item script, based on `Generator_Blue` with the `base:generator` tag and the sprite chosen in Phase 1.
- [ ] Give it a display name ("Naquadah Generator") and a tooltip.
- [ ] Confirm it can be spawned from the debug item list, placed, plugged in, and started like a Blue Generator.
- [ ] Confirm picking it up returns the Naquadah item, not a Blue Generator.
- [ ] Update `mod.info` (description, and poster if the placeholder is not acceptable) as needed.

**Technical Notes:**
*To be filled in during the phase.*

### Phase 3: Tracking Naquadah Generators

**Status:** Planning

- [ ] Implement the identification helper (`isNaquadah(generator)`) from the Phase 1 findings.
- [ ] Record each Naquadah Generator's location in global ModData when it is placed.
- [ ] Remove the record when it is picked up or destroyed.
- [ ] Drop stale records whose generator no longer exists.
- [ ] Confirm the records survive save and load.

**Technical Notes:**
*To be filled in during the phase.*

### Phase 4: Refill logic

**Status:** Planning

- [ ] On `EveryTenMinutes`, for each tracked generator whose square is loaded: set condition to 100 and fuel to 10 (the engine maximum).
- [ ] Do the same when a tracked generator's area loads.
- [ ] Do **not** plug the generator in (`setConnected` is left to the player).
- [ ] Respect a manual shutdown (see Open Question 2 for how "activate" fits in).
- [ ] Make sure a vanilla Blue Generator placed nearby is never touched.
- [ ] Run only in single player (and on the host); no multiplayer handling.

**Technical Notes:**
*To be filled in during the phase.* The engine charges fuel and condition for the in-game hours elapsed since the generator last updated (`IsoGenerator.java:195-225`). This is why the area-load refill matters after a long absence.

### Phase 5: No running indoors

**Status:** Planning

- [ ] Implement the indoor restriction chosen in Phase 1 and Open Question 1.
- [ ] Decide what the player sees when they try to start it indoors (menu entry disabled with a tooltip, or a message).
- [ ] Confirm a Naquadah Generator placed outdoors works normally and the building is never flagged toxic by it.

**Technical Notes:**
*To be filled in during the phase.* A vanilla running generator indoors flags the building as toxic (`IsoGenerator.java:526-531`). The restriction must also hold for a generator that was already running when it was moved or loaded.

### Phase 6: In-game testing

**Status:** Planning

- [ ] Spawn, place, plug in, and start the item; confirm it behaves like a Blue Generator.
- [ ] Lower fuel and condition with debug tools, wait for the next 10-minute tick, and confirm fuel is full and condition is 100.
- [ ] Turn it off by hand and confirm it stays off after the next tick.
- [ ] Pick it up and place it again; confirm it is still a Naquadah Generator and is still refilled.
- [ ] Save, quit, reload; confirm tracking and refills continue.
- [ ] Leave the area for many in-game hours, return, and confirm the area-load refill prevents a drained generator.
- [ ] Place a vanilla Blue Generator next to it and confirm the vanilla one is **not** refilled.
- [ ] Try to run it indoors and confirm the restriction works.
- [ ] Record the results in the Completion Summary.

**Technical Notes:**
*To be filled in during the phase.* Per `AGENTS.md` and `DevelopmentProcess.md`, work stops at **Work Complete**; only Ed can mark a phase or the cycle **Verified**.

---

## Open Questions

1. **What exactly does "No" mean for running indoors, and how should it be enforced?** Your answer to "Should it be allowed to run indoors?" was "No". I read that as: the generator must not be able to run inside a building.
   Recommendation: block starting it (and re-check at refill time) when its square is inside a building, with the Start option greyed out and a tooltip explaining why. This is simpler than restricting placement and also covers a generator that is carried indoors. Is that the behavior you want?
It is allowed to run indorrs, and will be poisonous just like the regular generator.
2. **How should "activate" work if a manual shutdown is respected?** The idea says the mod "activates it" every 10 minutes, and your answers say "refuel, repair and activate" but also "manual shutdown is respected". Both cannot hold if the mod always switches it on.
   Recommendation: the mod only refuels and repairs, and never switches the generator on. With fuel and condition always full, the engine no longer switches it off by itself, so the player's own on/off choice stays in control. If you want it switched on in some case (for example, when it was switched off because it ran dry before the area-load refill), please say which case.
Ok, the mod only refuels and repairs, as you recommend.
3. **Which Blue sprite frame should the item use?** Option B borrows one of the other Blue frames (`appliances_misc_01_13`–`15`). The frames may face different directions.
   Recommendation: let Phase 1 report which frame resolves correctly in the sprite lookup and looks right, then pick that one. I would bring the result back to you before Phase 2 if more than one works.

---

## Notes and Risks

- **Sprite→type collision:** if the borrowed frame still resolves to `Generator_Blue`, Option B fails and the fallback is a custom sprite (Option A) or a modData flag (Option C). Either would change Phase 2 and could extend the cycle.
- **Placement hard-coding:** `ISMoveableSpriteProps` creates `Generator_Blue` for the frames `appliances_misc_01_12`–`15`. A new item using one of those frames may need a small patch or wrapper.
- **No Lua access to the engine's generator list,** so the mod must keep its own tracking (Phase 3).
- **Drain between loads:** covered by the area-load refill (Phase 4); verify it in testing.
- **Single player only.** Multiplayer behavior is deliberately not designed or tested.
- **No balance changes** by design: the generator removes the fuel economy for any player who has one. This is a conscious decision by Ed, with debug spawn as the only source.
- This document is a plan only. No implementation begins until Ed explicitly asks for it.

---

## Completion Summary

*To be filled in at the end of the cycle.*
