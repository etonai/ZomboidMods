# DevCycle 013: Convert to a Real Washer/Dryer Object (Flag-Based) for Working Audio

**Status:** Planning
**Start Date:** 2026-09-14
**Target Completion:** TBD

---

## Goal

DevCycle 011 (17 phases) and DevCycle 012 (research + diagnostics) both failed to make the scripted-`entity`-based Churning Machine produce audible running sound, and DC12 found a real, well-grounded reason why: the mod's `entity` is a `zombie.entity.GameEntity`, while every vanilla mechanism for a continuous ambient sound loop (`ClothingWasherLogic`, `IsoFireplace`) is written against the unrelated `zombie.iso.IsoObject`, and no vanilla scripted entity has ever been found looping ambient sound this way. Rather than continuing to debug audio inside an architecture that may not support it at all, this cycle changes the architecture: convert the Churning Machine into (or onto) a **real vanilla `IsoClothingWasher`/`IsoCombinationWasherDryer` object**, per `doc/ideas/PseudoChurningMachineDC11Plus.md` item #8's "flag-based" approach. Since the object would then be the genuine vanilla appliance, its running sound is vanilla's own already-working code — the audio problem becomes moot rather than fixed.

This is a bigger architectural change than any prior DevCycle on this mod, and audio is a hard release requirement (per Ed) — there is no acceptable fallback to "ship without sound."

## Desired Outcome

- Turning on the machine produces an audible looped running sound, using vanilla's own real audio (no more Lua-side emitter/sound code of our own to debug).
- The milk-to-butter behavior (DC006 removal, DC007 butter generation, DC010's cycle duration or an equivalent) is preserved, running on the real vanilla object instead of the scripted entity.
- The player must actually place/obtain a real washer or washer/dryer object (through whatever means DC13 decides — see Phase 2) before it can be "converted" — this is a bigger ask of the player than building the current scripted entity, and that tradeoff is accepted as the cost of working audio, per Ed's priority.
- The vanilla "Wash"/"Dry" menu options are not left active and confusing alongside our own "Turn On"/"Turn Off" option on a converted object — some resolution (hide, relabel, or gate) is required, not deferred.
- If, once implemented, this approach turns out not to fix audio either (e.g. the flag-based hook doesn't actually let our logic drive the real object's cycle correctly), that is a valid outcome to report back — not a license to fall back to the scripted-entity approach silently.

---

## Tasks

### Phase 1: Decide the conversion mechanism and player-facing flow

**Status:** Planning

Idea #8's analysis identified the mechanism is feasible but left open exactly how a player gets from "nothing" to "a converted Churning Machine," and left the flag-based vs. replacement-based fork undecided. This phase resolves both before any code is written.

- [ ] Decide how the player obtains the base object: build a real washer/dryer via the vanilla building mechanism (if moddable/obtainable that way), or some other in-fiction path (e.g. finding one in the world, as most washers already exist pre-placed on the map). Confirm which is actually feasible for a mod to gate/trigger on.
- [ ] Confirm the flag-based approach over replacement-based (per idea #8's own analysis: only flag-based actually fixes audio) — proceed unless a concrete blocker is found.
- [ ] Design the "convert" action: a context-menu option (via `Events.OnFillWorldObjectContextMenu`) on a real `IsoClothingWasher`/`IsoCombinationWasherDryer`, gated by the Electrician perk (`Perks.Electricity`, per idea #8's research) and whatever materials/recipe makes sense, that sets a `ModData` flag (e.g. `isChurningMachine = true`) on the object.
- [ ] Decide what "converted" changes about the object's own menu: hide/suppress the vanilla Wash option, relabel it, or leave both present with a clear tooltip explaining the dual nature — pick one, don't defer.

**Technical Notes:**

### Phase 2: Hook the milk-to-butter logic onto the real object

**Status:** Planning

- [ ] Re-derive `ChurningMachineCode.lua`'s existing logic (`startMachine`/`stopMachine`/`checkRunningMachines`) against a real `IsoClothingWasher`-backed object instead of a `GameEntity` — identify what changes (e.g. `entity:getFluidContainer()` vs. whatever the real object's container API looks like from Lua, milk whitelist on a real object that wasn't built with one, etc.).
- [ ] Decide how milk gets into a real washer/dryer at all (it wasn't designed to hold milk) — likely needs its own container-whitelist or bypass, not assumed to already work.
- [ ] Drop all of the mod's own sound-emitter code (`getFreeEmitter`, `setEmitterOwner`, `playSoundLoopedImpl`, the DC012 diagnostic logging) — the real object's own Java `ClothingWasherLogic.updateSound()` already handles this; our Lua code should not be fighting it or duplicating it.
- [ ] Confirm the real object's own 90-in-game-minute wash cycle (per `claudeDocs/claude_washingMachineAnalysis.md`) either gets bypassed/overridden for our 10-minute butter cycle, or decide our cycle duration should just become 90 minutes to match vanilla's own timer instead of maintaining a second, competing timer on the same object.

**Technical Notes:**

### Phase 3: Implementation

**Status:** Planning

- [ ] Implement Phase 1/2's decisions in `ChurningMachineCode.lua` and the entity/context-menu hookup.
- [ ] Decide the fate of `entity_ChurningMachine.txt`, its xuiSkin, and the scripted-entity approach generally — likely removed/deprecated in favor of the real-object hook, not run alongside it (running both would reintroduce the exact naming/architecture confusion flagged when reviewing `PseudoChurningGameEntity`).

**Technical Notes:**

### Phase 4: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Convert a real washer (and, separately, a combination washer/dryer if supported) and confirm the running sound is audible by ear.
- [ ] Confirm milk-to-butter conversion still works (removal + butter generation) on the real object.
- [ ] Confirm the vanilla Wash/Dry menu is handled the way Phase 1 decided (hidden/relabeled/gated), not left as confusing dead weight.
- [ ] Confirm the Electrician-perk gate (or whatever gate Phase 1 settles on) actually blocks conversion for a player without it.

**Technical Notes:**

---

## Notes and Risks

- This is a bigger scope change than any prior DevCycle on this mod — accepted explicitly because audio is a hard release requirement with no acceptable fallback, per Ed.
- `mymods/PseudoChurningGameEntity` (a straight copy of the current scripted-entity mod, made to prototype an alternative) currently shares internal names with `PseudoChurningMachine` and cannot run alongside it without renaming — not addressed by this DevCycle unless Ed asks for that copy to be used as the actual implementation target instead of `PseudoChurningMachine` itself.
- Idea #8's own cross-references note this also reframes items #2 (Wash Menu/reclassification) and #3 ("Add Liquid from Item") from this mod's idea backlog — both may become differently-scoped or partly resolved once the object is genuinely a real washer/dryer, rather than needing separate fixes. Worth revisiting that backlog once this cycle's direction is confirmed working, not before.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
