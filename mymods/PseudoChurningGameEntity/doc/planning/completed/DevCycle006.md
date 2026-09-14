# DevCycle 006: Liquid Removal on Cycle End

**Status:** Verified (2026-09-13) — Ed confirmed all Phase 3 tests pass
**Start Date:** 2026-09-13
**Target Completion:** 2026-09-13
**Focus:** When a Churning Machine cycle completes naturally, remove a whole multiple of 5 liters of milk from its `FluidContainer`. No butter yet (that's Step 7) — the milk simply disappears.

---

## Goal

Implement Step 6 of `PseudoChurningMachinePlan.md`: at the end of a completed Turn On cycle, consume milk from the Churning Machine's `FluidContainer` in whole 5-liter increments. Any remainder under 5L stays in the container for the next cycle. This cycle does **not** add butter production, fullness tracking, or any inventory changes — those are Step 7. This cycle also does not touch audio (deferred to Step 11 per DevCycle 005) or the Wash Menu/tile-reclassification question (deferred to post-Step-11 per the Plan).

## Desired Outcome

- When a Churning Machine's cycle finishes on its own (the auto-stop tick fires after the run duration elapses), the container loses `floor(amount / 5) * 5` liters of milk.
- Example: 12L in the container at cycle end -> 10L removed, 2L remains.
- Example: 3L in the container at cycle end -> 0L removed (below the 5L threshold), all 3L remains.
- Example: 20L (full) at cycle end -> 20L removed, container ends empty.
- Manually selecting "Turn Off" before the cycle completes does **not** trigger this removal — matching the real washer/dryer's own behavior, where switching it off mid-cycle doesn't produce a finished load. (This is a design decision made in Phase 1 below, not left ambiguous.)
- DevCycle 004's fluid interactions ("Add Liquid from Item" excepted, per its DC 11 deferral) and DevCycle 005's Turn On/Off toggle, milk gate, and auto-stop timer all continue to work unaffected.
- No butter or item-inventory changes of any kind — that remains entirely Step 7's scope.

---

## Tasks

### Phase 1: Research and design the removal point

**Status:** Work Complete

- [x] Confirm `FluidContainer:removeFluid(amount)` (or the equivalent Lua-exposed method) is the right call, and confirm its units match the container's `Capacity = 20.0` (liters), not milliliters or some other unit.
- [x] Decide precisely where in the existing code the removal belongs: only in the natural auto-stop path (`checkRunningMachines` -> `stopMachine`), not in the manual "Turn Off" path (`onToggleOption` -> `stopMachine`). Since both currently funnel through the same `stopMachine(entity)` function, this likely means either splitting `stopMachine` into "stop early" vs "stop because the cycle finished" variants, or passing a flag/reason into `stopMachine` so it knows whether to remove milk.
- [x] Confirm the whole-multiple-of-5 math: `local removable = math.floor(fluidContainer:getAmount() / 5.0) * 5.0`.
- [x] Confirm no existing DevCycle 004/005 code path already removes fluid on cycle end (it shouldn't — DC005's Desired Outcome explicitly said no milk consumption was in scope for that cycle).

**Technical Notes:**

**`removeFluid` — confirmed real, Lua-callable, and already used with a float amount by shipped vanilla code, not just present in Java.** `FluidContainer.java:971-977` (`zombie42_20_4/entity/components/fluids/FluidContainer.java`) declares:
```java
public void removeFluid(float remove) { this.removeFluid(remove, false); }
public FluidConsume removeFluid(float remove, boolean createFluidConsume) { ... }
```
Grepping actual Lua call sites (not just the Java declaration) confirms both the float-amount form and its Lua-side call shape are real and already shipping:
- `media42_20_4/lua/shared/FeedingTrough/TimedActions/ISAddWaterToTrough.lua:22` — `self.itemFrom:getFluidContainer():removeFluid(toremove, false);`
- `media42_20_4/lua/shared/TimedActions/Animals/ISGiveWaterToAnimal.lua:34` — `self.item:getFluidContainer():removeFluid(0.05, false);`
- `media42_20_4/lua/shared/TimedActions/ISDumpWaterAction.lua:47` — `self.item:getFluidContainer():removeFluid(self.startUsedDelta / self.maxTime);`

**Units — liters, matching the container's own `Capacity`, no conversion needed.** `entity_ChurningMachine.txt:22` declares `Capacity = 20.0` for a container the Plan and DevCycle 004 both already describe as "20 liters" (DevCycle 004 tested and confirmed the 20-liter cap in-game). Since `getAmount()`/`removeFluid()` operate directly in the same unit as `Capacity`, no unit conversion is needed — `removeFluid(5.0)` removes exactly 5 liters. `ChurningMachineCode.lua`'s own existing milk-gate check (`fluidContainer:getAmount() > 0`) already relies on this same unit assumption, so this is consistent with code already shipped in DevCycle 005, not a new assumption.

**Removal point — decided: only the natural auto-stop path, via a new parameter on `stopMachine`, not a separate function.** `stopMachine(entity)` is currently called from two places in `ChurningMachineCode.lua`:
- `onToggleOption` (manual "Turn Off", `ChurningMachineCode.lua:46`)
- `checkRunningMachines` (natural auto-stop when the run duration elapses, `ChurningMachineCode.lua:89`)

Decision: add a `completedCycle` boolean parameter to `stopMachine(entity, completedCycle)`. `onToggleOption` passes `false` (manual stop, no removal); `checkRunningMachines` passes `true` (natural completion, remove milk). A single shared function with a parameter was chosen over two separate functions (`stopMachineEarly`/`stopMachineOnCompletion`) because the sound-stopping, `ModData` clearing, and registry cleanup are identical in both cases — only the milk-removal step differs, so branching inside one function is less duplication than two near-identical functions. This matches DevCycle 005's own established pattern of keeping `stopMachine`/`startMachine` as the single source of truth for state transitions.

**Math — confirmed against `removeFluid`'s own internal clamping, not just the plan's stated intent.** `local removable = math.floor(fluidContainer:getAmount() / 5.0) * 5.0` matches the Plan's "whole 5-liter increments" language exactly (e.g. 12L -> 10L removed, 3L -> 0L removed, 20L -> 20L removed). Cross-checked against `removeFluid`'s own Java implementation (`FluidContainer.java:987-989`): `remove = PZMath.max(0.0F, remove); ... remove = PZMath.min(remove, this.getAmount());` — it already clamps to `[0, currentAmount]` internally, so passing `0.0` (the 3L-remaining case) is safe and a no-op, and there's no risk of ever asking it to remove more than what's present.

**No existing removal on cycle end — confirmed by re-reading the current `ChurningMachineCode.lua` in full.** Neither `stopMachine` nor `checkRunningMachines` (the only two functions involved in ending a cycle) reference `removeFluid`, `getFluidContainer`, or any fluid-amount field anywhere — consistent with DevCycle 005's Desired Outcome, which explicitly stated "No milk is consumed... the `FluidContainer`/item inventory from DevCycle 004 are untouched by this action," and confirmed as tested/working in DevCycle 005 Phase 3.

### Phase 2: Implement

**Status:** Work Complete — implementation done, in-game verification pending (Phase 3)

- [x] Modify `ChurningMachineCode.lua` so that only the natural end-of-cycle path removes milk, not manual "Turn Off".
- [x] Add the 5L-increment removal logic using `FluidContainer:removeFluid(...)`.
- [x] Make sure the removal happens exactly once per completed cycle (no double-removal if `checkRunningMachines` somehow processes the same entity twice in one tick, and no removal if the container is already below 5L).

**Technical Notes:**

Implemented exactly per Phase 1's decision: `stopMachine(entity)` became `stopMachine(entity, completedCycle)` (`ChurningMachineCode.lua:18-38`). When `completedCycle` is true, it computes `removable = math.floor(fluidContainer:getAmount() / 5.0) * 5.0` and calls `fluidContainer:removeFluid(removable, false)` only if `removable > 0` — so an under-5L remainder is a no-op rather than a wasted zero-amount call. Both call sites were updated to pass the right value:
- `onToggleOption` (manual "Turn Off", `ChurningMachineCode.lua:55`): `stopMachine(entity, false)` — no removal.
- `checkRunningMachines` (natural auto-stop, `ChurningMachineCode.lua:98`): `stopMachine(toStop[i], true)` — removal happens.

**Double-removal risk ruled out by re-reading `checkRunningMachines`'s own loop, not just assumed.** Each entity is stopped via `stopMachine`, which immediately clears `ChurningMachineCode.active[key] = nil` before any later iteration could re-process it, and `checkRunningMachines` itself only builds `toStop` from a single pass over `ChurningMachineCode.active` per tick, then stops each entry exactly once — there's no path that could call `stopMachine(entity, true)` twice for the same completed cycle.

No changes were made to `startMachine`, `turnOnOffMenu`, or `isRunning` — this phase only touched `stopMachine` and its two call sites.

### Phase 3: In-game verification

**Status:** Verified — Ed confirmed all tests pass after Phase 4's fix

- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] Fill the Churning Machine with an amount of milk that isn't a clean multiple of 5 (e.g. 12L), run a full cycle to completion without touching it, and confirm exactly 10L is removed (2L remains).
- [x] Fill it with exactly 20L (full), run a full cycle to completion, confirm it ends empty.
- [x] Fill it with less than 5L (e.g. 3L), run a full cycle to completion, confirm nothing is removed.
- [x] Start a cycle, then manually select "Turn Off" before it completes, and confirm **no** milk is removed.
- [x] Confirm DevCycle 004's fluid interactions and DevCycle 005's Turn On/Off toggle, milk gate, and auto-stop timer all still work unaffected.
- [x] Confirm no butter or item-inventory changes occur (Step 7 is still not implemented) — the milk should just disappear.

**Technical Notes:**

First pass surfaced the exact-multiple bug documented in Phase 4 (10L in -> only 5L removed). After that fix, Ed re-ran the full checklist and confirmed all cases pass, including the exact-multiple case Phase 4 was written to fix.

---

### Phase 4: Fix under-removal caused by float imprecision

**Status:** Verified — fix applied and confirmed by Ed's re-test

- [x] Diagnose why 10L in the container resulted in only 5L removed (5L remaining) instead of the full 10L.
- [x] Fix the 5L-increment math to tolerate float imprecision.
- [x] Ed to re-run Phase 3's verification checklist now that this is fixed. — **Confirmed: all tests pass.**

**The bug, as reported by Ed:** filled the Churning Machine with 10L and ran a full cycle; afterward it had 5L remaining, not 0L — even though 10 is an exact multiple of 5 and should have been removed in full.

**Root cause — `FluidContainer:getAmount()` returns an accumulated `float`, not a precision-guaranteed integer-liter value, so an amount that was poured/transferred in as "10L" can actually be stored as something fractionally under it (e.g. `9.999998`).** `FluidContainer.getAmount()` (`zombie42_20_4/entity/components/fluids/FluidContainer.java:563-566`) returns `this.amountCache`, a cached `float` built up by `recalculateCaches()` summing over the container's individual `Fluid` entries — ordinary floating-point summation, with no rounding to a clean value anywhere in that path. Phase 2's math, `math.floor(amount / 5.0) * 5.0`, is exact for a truly-exact `10.0`, but `math.floor(9.999998 / 5.0) * 5.0 = math.floor(1.9999996) * 5.0 = 1 * 5.0 = 5.0` — removing only 5L and leaving the other ~5L behind, exactly matching what Ed observed. This wasn't caught in Phase 1's math check because that check confirmed the formula against the *intended* clean values (12, 3, 20), not against how a real in-game pour actually populates `amountCache`.

**Fix applied** (`ChurningMachineCode.lua:32`):
```lua
local removable = math.floor(fluidContainer:getAmount() / 5.0 + 0.0001) * 5.0
```
Adding a small epsilon before flooring nudges a near-exact value like `9.999998` back over the `2.0` boundary before truncation, while being far too small to change the result for any genuinely-partial amount (e.g. 7L still correctly yields 5L removable, not 10L). This is the standard fix for this class of floating-point floor/round bug and doesn't change behavior for exact values.

**Verification note:** this specific bug could only be caught in-game, not by re-reading the Phase 1 math in isolation — Ed's Phase 3 testing is what surfaced it. Re-run the full Phase 3 checklist, particularly the exact-multiple cases (10L, 20L), not just the non-exact ones.

---

## Notes and Risks

- This cycle explicitly does not add butter production or fullness tracking — that begins in Step 7.
- Audio remains silent per DevCycle 005's deferral to Step 11; not affected or investigated in this cycle.
- The Wash Menu / possible tile-reclassification question remains open and deferred to post-Step-11, per the Plan; not affected or investigated in this cycle.
- Splitting "stop because manually turned off" from "stop because the cycle finished" is new branching in `stopMachine`/`checkRunningMachines` that DevCycle 005 didn't need — worth double-checking it doesn't regress the auto-stop or manual-stop behavior DevCycle 005 already verified working.

---

## Completion Summary

**Completion Date:** 2026-09-13

**Phases Completed:** 1-4, all Verified. Every line of the Desired Outcome was tested and confirmed working — no unmet goals.

**Work Deferred:** None new. Pre-existing deferrals from earlier cycles (audio to Step 11, Wash Menu/tile-reclassification to post-Step-11) were untouched and out of scope, as planned.

**Accomplishments:**
- `stopMachine(entity, completedCycle)` now removes milk in whole 5-liter increments only when a cycle completes naturally, never on a manual "Turn Off" — confirmed in-game for both the removal and non-removal paths.
- Verified exact-amount edge cases: 12L->10L removed, 20L->fully empty, 3L->untouched, and (after the Phase 4 fix) the exact-multiple 10L case.
- Found and fixed a float-imprecision bug where `FluidContainer:getAmount()` returning a near-but-not-exact value (e.g. `9.999998` for a "10L" pour) caused `math.floor` to under-count, silently leaving milk behind that should have been fully removed.
- Confirmed DevCycle 004's fluid interactions and DevCycle 005's Turn On/Off toggle, milk gate, and auto-stop timer are unaffected by this cycle's changes.

**Metrics:** 1 in-game test round (surfaced the float-imprecision bug), 1 fix, 1 re-test round confirming full pass. 0 unmet Desired Outcome items.

**Lessons / Notes:**
- `FluidContainer:getAmount()` is a `float` built from summed internal fluid entries, not a rounded/clean value — any code dividing or comparing it against a clean threshold (like the 5L increment here) should add a small epsilon before flooring/rounding, rather than assuming a "10L" pour is stored as exactly `10.0`. Worth remembering for Step 7's butter-per-5L conversion, which will do the same kind of division.
- Testing against exact round-number inputs (10L, 20L) is not automatically safer than testing partial ones (12L, 3L) when floating-point storage is involved — the exact-multiple case was the one that actually broke here, precisely because it looked "safe" enough not to double-check the math against real accumulated float values in Phase 1.
