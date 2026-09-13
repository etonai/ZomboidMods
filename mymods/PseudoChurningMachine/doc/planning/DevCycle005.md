# DevCycle 005: Turn On Action

**Status:** Planning
**Start Date:** 2026-09-13
**Target Completion:** TBD
**Focus:** Give the Churning Machine a "Turn On" menu action that plays the washer/dryer audio and runs for a short test duration (1 minute of game time), with no other effect.

---

## Goal

Implement Step 5 of `PseudoChurningMachinePlan.md`: add a "Turn On" interaction to the `Pseudonymous.ChurningMachine` entity that plays the Blue Combo Washer/Dryer's running sound and runs for 1 minute of game time (a deliberately short test duration, to be raised to 15 minutes later in Step 10). No liquid consumption, no butter production, no fullness/inventory changes, and no cycle-completion logic belong in this cycle — purely the on/off action and its audio.

## Desired Outcome

- Right-clicking the built Churning Machine offers a "Turn On" menu option (and "Turn Off" while running, mirroring the real washer/dryer's toggle).
- Selecting "Turn On" starts playing the washer/dryer's running sound and automatically stops after 1 minute of game time (test duration), or can be manually turned off early via "Turn Off".
- No milk is consumed, no butter is produced, and the `FluidContainer`/item inventory from DevCycle 004 are untouched by this action.
- This is additive to DevCycle 004's work — the "Add Liquid from Item"/"Container Info"/"Transfer Liquid"/"Fill"/"Empty" interactions from DevCycle 004 must still all work exactly as before.

---

## Tasks

### Phase 1: Research how to add a Turn On/Off action with audio to a scripted entity

**Status:** Planning

- [ ] Confirm the exact running-sound name to use. `zombie42_20_4/iso/objects/ClothingWasherLogic.java` (`updateSound()`, ~line 192-220) shows the real washer/dryer plays `"ClothingWasherRunning"` on loop (`emitter.playSoundLoopedImpl("ClothingWasherRunning")`) while active, and `"ClothingWasherFinished"` once when a cycle completes (`emitter.playSoundImpl("ClothingWasherFinished", ...)`) — confirm both sound names still exist/resolve in the current sound scripts (`media42_20_4/scripts/generated/sounds/...`) before relying on them, since Step 1's washing-machine research only explicitly checked file/line references, not every sound name.
- [ ] Since `Pseudonymous.ChurningMachine` is a scripted entity (not the hardcoded `IsoClothingWasher`/`IsoCombinationWasherDryer` Java class), `toggleClothingWasher()`/`toggleComboWasherDryer()` (the real washer's own Turn On/Off logic, gated on those specific Java types per DevCycle 004's Phase 5 findings) do **not** apply to our object and must not be relied on. Research the actual mechanism needed: most likely a `component ContextMenuConfig` entry (the same pattern the Amphora uses for its lid toggle, per `claude_amphoraAnalysis.md`) wired to a custom Lua `customFunction`, since `entity_ChurningMachine.txt` currently has no `ContextMenuConfig` at all (`uiEnabled = false` only suppresses the crafting *window*, not a `ContextMenuConfig` menu entry — confirm this distinction holds for our entity specifically).
- [ ] Research how to actually play the looped/finished sounds from Lua on a scripted entity's `IsoObject`/`IsoThumpable` — `media42_20_4/lua/...` has multiple existing call sites using `playSoundLoopedImpl`/`getEmitter()` (e.g. `ISBuildAction.lua`, `ISMultiStageBuild.lua`) as reference patterns, though none are on an entity's own emitter specifically — confirm the exact accessor chain needed (e.g. `object:getEmitter()`, or whether one must be created first via `IsoWorld.instance:...` the way the real washer's Java code does).
- [ ] Research how to track "running since when" and stop automatically after 1 minute of game time, without a `CraftBench`/`CraftLogic` component (explicitly out of scope this cycle) — likely a small `ModData`-backed timestamp plus a periodic Lua tick (`Events.EveryTenMinutes`/`EveryHours`, or a finer-grained event if 1 minute of game time needs closer-to-real-time checking) comparing against `GameTime.getInstance():getWorldAgeHours()`, similar in shape to `PseudoButterChurner`'s own hand-rolled tick system (DevCycle 2 Phase 8) — but keep this deliberately minimal (on/off + sound only), not a reimplementation of that mod's fuller production-tracking system.
- [ ] Confirm whether "Turn On" should be blocked/hidden while the container has 0 milk (matching the real washer's own gate, `object.getFluidAmount() <= 0.0F`, per `claude_washingMachineAnalysis.md`) or should be allowed regardless, since this cycle explicitly has no milk-consumption logic yet — decide based on what feels right for testing rather than assuming the real washer's exact gate applies before Step 6 exists.
- [ ] **Check for the pre-existing Wash Menu before adding a new one.** Per DevCycle 004 Phase 5 Part A, this object already shows an unrelated, not-ours Wash Menu (leading hypothesis: the tile gets reclassified into a real `IsoClothingWasher`/`IsoCombinationWasherDryer`, still unconfirmed and deferred). Confirm in-game whether that existing Wash Menu already offers a working "Turn On"/"Turn Off" toggle with the correct sound before building a second, separate one — if it does, decide whether this cycle can/should just verify that pre-existing behavior instead of adding new script, or whether a second, mod-owned toggle is still wanted regardless (e.g. because the pre-existing one is tied to the real washer's own fluid/cycle logic in ways that would conflict with this mod's plan). Don't assume either way — this needs a direct answer before Phase 2 starts.

**Technical Notes:**


### Phase 2: Implement the Turn On/Off action and audio

**Status:** Planning

- [ ] Add a `component ContextMenuConfig` entry (or whatever Phase 1 research confirms is the right mechanism) to `entity_ChurningMachine.txt` for "Turn On"/"Turn Off".
- [ ] Add the Lua wiring needed: starting the loop sound and recording a start time on "Turn On"; stopping the sound (and clearing the start time) on manual "Turn Off" or automatic stop after 1 minute of game time.
- [ ] Confirm no interaction with the `FluidContainer`/item inventory — milk amount and butter inventory must be completely unaffected by turning the machine on or off in this cycle.

**Technical Notes:**


### Phase 3: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing (per `PseudoChurningMachinePlan.md`'s standing instruction).
- [ ] Confirm "Turn On" appears and, when selected, starts the washer/dryer running sound.
- [ ] Confirm the machine automatically stops (sound stops) after 1 minute of game time with no manual action.
- [ ] Confirm "Turn Off" (while running) stops it early and stops the sound.
- [ ] Confirm milk amount and butter/item inventory are unchanged before and after a full on/off cycle.
- [ ] Confirm DevCycle 004's five fluid interactions ("Add Liquid from Item" excepted, per its DC 11 deferral — verify with "Transfer Liquid" instead) still all work unaffected by this cycle's changes.

**Technical Notes:**

---

## Notes and Risks

- This cycle explicitly does not consume milk, produce butter, or touch fullness/inventory — that begins in Step 6 (liquid removal on cycle end) and continues through the revised Step 7 (butter generation via inventory, per DevCycle 004 Phase 4).
- The real washer/dryer's own Turn On/Off logic (`toggleClothingWasher`/`toggleComboWasherDryer`, `ClothingWasherLogic`) is Java code gated on the real hardcoded classes and cannot be reused directly for our scripted entity — this cycle needs its own from-scratch (but minimal) Lua implementation, informed by but not copying that code.
- DevCycle 004's Phase 5 (both Parts A and B) remains deferred and out of scope for this cycle — do not attempt to fix the wrong displayed name, Wash Menu, or missing "Add Liquid from Item" while working on this cycle's own "Turn On" action, even though a Wash Menu is already present on this object for unrelated reasons (per DC004 Phase 5 Part A) — this cycle's own "Turn On"/"Turn Off" must be added independently and should not be confused with, or accidentally piggyback on, that pre-existing (and not-ours) Wash Menu.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
