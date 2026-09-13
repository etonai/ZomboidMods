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

**Status:** Work Complete — one item still needs Ed's in-game confirmation before Phase 2

- [x] Confirm the exact running-sound name to use.
- [x] Research the actual context-menu mechanism needed (not the real washer's hardcoded toggle).
- [x] Research how to play the looped/finished sounds from Lua on a scripted entity.
- [x] Research how to track "running since when" and stop automatically after 1 minute of game time.
- [x] Decide the milk-gate question — **resolved by direct instruction: "Turn On" is only available when the container has milk.**
- [ ] Check for the pre-existing Wash Menu before adding a new one — **still needs an in-game answer from Ed, not resolved by static reading (see below).**

**Technical Notes:**

**Sound names — confirmed to exist in the current build.** `media42_20_4/scripts/generated/sounds/objects/sounds_object_clothingwasher.txt` declares both:
```
sound ClothingWasherRunning { category = Object, clip { event = Object/ClothingWasher/Running, } }
sound ClothingWasherFinished { category = Object, clip { event = Object/ClothingWasher/Finished, } }
```
Both names `ClothingWasherLogic.java` uses (`updateSound()`, ~line 192-220) are real, current sound definitions — safe to reference directly, no substitution needed.

**Menu mechanism — confirmed via the Amphora's own lid toggle, not assumed.** `entity_amphora.txt:11-18`:
```
component ContextMenuConfig
{
    contextEntry
    {
        menu = CloseLid,
        customFunction = ContextMenuCode.OpenCloseAmphoraLid,
    }
}
```
This coexists with `uiEnabled = false` on the same entity (confirmed — the Amphora has both), so `entity_ChurningMachine.txt`'s existing `uiEnabled = false` does **not** need to change to add a `ContextMenuConfig` entry. Traced the exact call chain into Lua, not assumed: `ISWorldObjectContextMenuLogic.doContextConfigOptions()` (line 5275-5304) turns `menu = X` into the translated label `ContextMenu_X`, and wires `customFunction = Module.Function` through `ISWorldObjectContextMenu.onCustomFunction` → `ISWorldObjectContextMenuLogic.callCustomFunction()` (line 5306-5309), which calls the Lua function as `Module.Function(context, entity, playerObj, extraParam)` — matching `ContextMenuCode.OpenCloseAmphoraLid(context, entity, character, param)`'s real signature exactly. Since our entity already has `component FluidContainer`, this option will nest inside the same named submenu as "Container Info"/"Transfer Liquid"/"Fill"/"Empty" (confirmed by re-reading the same `fluidcontainer`-loop call site from DevCycle 004's investigation, `ISWorldObjectContextMenuLogic.java:919-934`, which calls `doContextConfigOptions(submenu, fluidcontainer, playerObj)` using the *same* submenu `doFluidContainerMenu()` returned) — not as a separate top-level right-click entry.

One simplification decided here: rather than declaring two separate `contextEntry` blocks with static "Turn On"/"Turn Off" labels (which would need an entity swap to alternate between them, the way the Amphora swaps between two whole entities for its lid), this cycle will use a single `contextEntry` whose Lua `customFunction` toggles state itself and can dynamically set the option's label via the `option`/`customSubmenu` mechanism if a dynamic label matters — flagged as a nice-to-have for Phase 2, not a hard requirement for this cycle's minimal test scope.

**Playing the sound — a real, usable path exists, but with more implementation risk than the menu mechanism.** `IsoObject.java:195` declares `public BaseSoundEmitter emitter;` as a plain public field (Lua-readable directly, no getter needed) — this is the exact field `ClothingWasherLogic.java` uses (`this.getObject().emitter = IsoWorld.instance.getFreeEmitter(x, y, z); ...emitter.playSoundLoopedImpl("ClothingWasherRunning")`). **However, no existing Lua script in this codebase does this on a world object** — every `getEmitter()`/`playSoundLoopedImpl` call site found (`ISLightFromKindle.lua`, `ISShovelGround.lua`, etc.) is on a *character* (`self.character:getEmitter()`), not a plain world object/entity. This is new, unproven ground for this project, similar in kind (though smaller in scope) to `PseudoButterChurner` DevCycle 2's repeated experience of "the engine supports this in principle, but nothing here has actually exercised it" — expect this to need live testing and possibly a Phase 2 correction, not to just work first try. A separately-discovered alternative, **`component CraftBenchSounds`** (seen on `entity_cooking_pit.txt` and others), plays sounds declaratively tied to an active `CraftBench`/`CraftLogic` cycle with zero custom Lua — not usable this cycle (no `CraftBench` exists yet, by design), but worth remembering for Steps 6+ once an actual milk-consumption cycle exists, as a possible declarative alternative to hand-rolled Lua sound code.

**Auto-stop after 1 minute — no declarative option without `CraftLogic`; will need a hand-rolled tick,** the same conclusion as originally suspected: a small `ModData`-backed start-time timestamp plus a periodic Lua event comparing against `GameTime.getInstance():getWorldAgeHours()`. Kept deliberately minimal in scope — just enough to flip the object back to "off" and stop the sound after 1 in-game minute, not a reimplementation of `PseudoButterChurner`'s fuller production-tracking system.

**Milk-gate decision — resolved by direct instruction, not left as an open question:** "Turn On" is only available when the container has milk. This will be implemented as a Lua-side check (e.g. `entity:getFluidContainer():getAmount() > 0`) gating whether the `customFunction` actually starts the machine (or, if a dynamic-label/enabled mechanism is used per the simplification above, gating whether the option is shown/enabled at all) — matching the real washer's own `getFluidAmount() <= 0.0F` gate in spirit, adapted to our own `FluidContainer`.

**Pre-existing Wash Menu — still open, cannot be resolved from static reading alone.** DevCycle 004 Phase 5 Part A's hypothesis (this tile may get reclassified into a real `IsoClothingWasher`/`IsoCombinationWasherDryer`) remains unconfirmed. If true, that pre-existing Wash Menu would use the real `ClothingWasherLogic`'s own Turn On (Water-gated, 90-in-game-minute cycle, tied to the real object's own hardcoded fluid container — not our `FluidContainer` component) — which would not match this cycle's 1-minute test duration or our milk-only, no-cycle scope even if it does work. **Decision for now: proceed with this cycle's own mod-owned `ContextMenuConfig` toggle regardless of whether that pre-existing Wash Menu works, since relying on unconfirmed, uncontrollable legacy behavior would conflict with Steps 6+'s planned design either way.** Ed should still confirm in-game whether both menus appear and whether they're visually distinguishable/confusing, since that's a real UX risk this cycle should check for in Phase 3, even though it doesn't change Phase 2's implementation plan.


### Phase 2: Implement the Turn On/Off action and audio

**Status:** Work Complete — implemented, in-game verification pending (Phase 3)

- [x] Add a `component ContextMenuConfig` entry to `entity_ChurningMachine.txt` — used `customSubmenu` (not `customFunction`), per a corrected finding below.
- [x] Add the Lua wiring needed: gate on the container having milk; toggle between starting the loop sound + recording a start time, and stopping the sound + clearing the start time; a periodic tick auto-stops (and stops the sound) once 1 in-game minute has elapsed since the recorded start time.
- [x] Confirm no interaction with the `FluidContainer`/item inventory — the toggle code never touches milk amount or the item inventory, only `ModData` (`churningMachineRunning`/`churningMachineStartHour`) and the sound emitter.
- [x] Sound-playing implemented following the exact Java pattern (`IsoWorld.instance:getFreeEmitter()` → `emitter:playSoundLoopedImpl()`/`stopOrTriggerSoundByName()`) — still unproven in this codebase until tested live, per Phase 1's caveat.

**Technical Notes:**

**Corrected during implementation: used `customSubmenu`, not `customFunction`, and found a real vanilla precedent for the dynamic "Turn On"/"Turn Off" label Phase 1 had flagged as a nice-to-have, not solved.** Found `entity_composter.txt`'s own `contextEntry` (`menu = GetCompost, customSubmenu = ContextMenuCode.CompostInteraction`) and its Lua implementation (`ContextMenuCode.CompostInteraction`, `media42_20_4/lua/client/ContextMenuCode.lua:76`) — a real, shipped example of exactly this shape: a static top-level label, with a Lua function that both decorates the top-level `option` (tooltip, `notAvailable`) *and* adds one or more dynamically-labeled child options via `context:addGetUpOption(...)`. Applied the same shape here instead of Phase 1's planned single-static-label simplification:
- `entity_ChurningMachine.txt`: `component ContextMenuConfig { contextEntry { menu = ChurningMachine, customSubmenu = ChurningMachineCode.turnOnOffMenu, } }`.
- New file `PseudoChurningMachine/42/media/lua/client/ChurningMachineCode.lua`: `turnOnOffMenu(context, option, entity, playerObj, param)` adds one child option via `context:addGetUpOption(...)`, labeled with the **existing generic vanilla keys** `ContextMenu_Turn_On`/`ContextMenu_Turn_Off` (`media42_20_4/lua/shared/Translate/EN/ContextMenu.json:14-15` — confirmed to exist already, no new translation needed for these two) depending on current running state (tracked via `ModData`) — giving the real dynamic label Phase 1 had deferred, for no extra implementation cost once the right mechanism was found.
- Added `"ContextMenu_ChurningMachine": "Churning Machine"` to a new `PseudoChurningMachine/42/media/lua/shared/Translate/EN/ContextMenu.json` (the top-level submenu label) and `"Tooltip_ChurningMachine_NoMilk"` to the existing `Tooltip.json` (shown when "Turn On" is grayed out).

**A real bug caught and fixed before it shipped, not just assumed correct:** `ISContextMenuWrapper.addGetUpOption(name, target, onSelect, params...)` (`zombie42_20_4/ui/ISUIWrapper/ISContextMenuWrapper.java:151-165`) only forwards the trailing `params...` to the callback — the `target` argument (used solely for walk-adjacency) is **not** passed through. An initial draft called `context:addGetUpOption(label, entity, ChurningMachineCode.onToggleOption, playerObj)` expecting `onToggleOption(entity, playerObj)`, which would have silently received only `playerObj` (with `entity` as `nil`) and thrown on the first click. Fixed by capturing `entity` via a Lua closure (`local function onSelect(pObj) ChurningMachineCode.onToggleOption(entity, pObj) end`) instead of relying on it being forwarded.

**ModData/tick implementation:** `ChurningMachineCode.active` is a plain (non-persisted) Lua table of currently-running machines, keyed by square coordinates, checked every `Events.OnTick` against `getGameTime():getWorldAgeHours()` versus the `ModData`-stored start hour. **Known limitation, accepted for this minimal test cycle:** since `active` isn't persisted, a save/reload while the machine is running would leave `ModData.churningMachineRunning = true` (persisted) with no corresponding Lua-side tracking or live sound — the machine would appear "on" (grayed toward "Turn Off") but silently never auto-stop until manually turned off. Given the real duration here is a 1-minute test value, this edge case is unlikely to matter in practice and wasn't engineered around; flagged in Notes and Risks in case it needs a real fix once Step 10 raises the duration to 15 minutes.


### Phase 3: In-game verification

**Status:** Planning

- [X] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing (per `PseudoChurningMachinePlan.md`'s standing instruction).
- [ ] Confirm "Turn On" appears only when the container has milk in it, and is absent/unavailable when it's empty.
- [ ] Confirm selecting "Turn On" starts the washer/dryer running sound.
- [ ] Confirm the machine automatically stops (sound stops) after 1 minute of game time with no manual action.
- [ ] Confirm "Turn Off" (while running) stops it early and stops the sound.
- [ ] Confirm milk amount and butter/item inventory are unchanged before and after a full on/off cycle.
- [ ] Confirm DevCycle 004's five fluid interactions ("Add Liquid from Item" excepted, per its DC 11 deferral — verify with "Transfer Liquid" instead) still all work unaffected by this cycle's changes.
- [ ] Check whether the pre-existing, not-ours Wash Menu (per DC004 Phase 5 Part A) is also present alongside this cycle's own new Turn On/Off option, and whether the two are confusing or visually hard to tell apart — report back regardless of outcome, since Phase 1 decided to proceed without resolving that hypothesis first.

**Technical Notes:**

---

## Notes and Risks

- This cycle explicitly does not consume milk, produce butter, or touch fullness/inventory — that begins in Step 6 (liquid removal on cycle end) and continues through the revised Step 7 (butter generation via inventory, per DevCycle 004 Phase 4).
- The real washer/dryer's own Turn On/Off logic (`toggleClothingWasher`/`toggleComboWasherDryer`, `ClothingWasherLogic`) is Java code gated on the real hardcoded classes and cannot be reused directly for our scripted entity — this cycle needs its own from-scratch (but minimal) Lua implementation, informed by but not copying that code.
- DevCycle 004's Phase 5 (both Parts A and B) remains deferred and out of scope for this cycle — do not attempt to fix the wrong displayed name, Wash Menu, or missing "Add Liquid from Item" while working on this cycle's own "Turn On" action, even though a Wash Menu is already present on this object for unrelated reasons (per DC004 Phase 5 Part A) — this cycle's own "Turn On"/"Turn Off" must be added independently and should not be confused with, or accidentally piggyback on, that pre-existing (and not-ours) Wash Menu.
- **Known limitation, accepted rather than engineered around:** the "is this machine running" registry used by the auto-stop tick (`ChurningMachineCode.active`) is a plain, non-persisted Lua table. If the game is saved and reloaded while a Churning Machine is running, `ModData.churningMachineRunning` (persisted) would still say `true`, but the Lua-side tracking and live sound would be gone — the machine would appear stuck "on" (offering "Turn Off") with no sound and no auto-stop until manually turned off. Not fixed this cycle since the duration is only a 1-minute test value; revisit if this still matters once Step 10 raises it to 15 minutes.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
