# DevCycle 006: Liquid Removal on Cycle End

**Status:** Planning
**Start Date:** 2026-09-13
**Target Completion:** TBD
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

**Status:** Planning

- [ ] Confirm `FluidContainer:removeFluid(amount)` (or the equivalent Lua-exposed method) is the right call, and confirm its units match the container's `Capacity = 20.0` (liters), not milliliters or some other unit.
- [ ] Decide precisely where in the existing code the removal belongs: only in the natural auto-stop path (`checkRunningMachines` -> `stopMachine`), not in the manual "Turn Off" path (`onToggleOption` -> `stopMachine`). Since both currently funnel through the same `stopMachine(entity)` function, this likely means either splitting `stopMachine` into "stop early" vs "stop because the cycle finished" variants, or passing a flag/reason into `stopMachine` so it knows whether to remove milk.
- [ ] Confirm the whole-multiple-of-5 math: `local removable = math.floor(fluidContainer:getAmount() / 5.0) * 5.0`.
- [ ] Confirm no existing DevCycle 004/005 code path already removes fluid on cycle end (it shouldn't — DC005's Desired Outcome explicitly said no milk consumption was in scope for that cycle).

**Technical Notes:**

### Phase 2: Implement

**Status:** Planning

- [ ] Modify `ChurningMachineCode.lua` so that only the natural end-of-cycle path removes milk, not manual "Turn Off".
- [ ] Add the 5L-increment removal logic using `FluidContainer:removeFluid(...)`.
- [ ] Make sure the removal happens exactly once per completed cycle (no double-removal if `checkRunningMachines` somehow processes the same entity twice in one tick, and no removal if the container is already below 5L).

**Technical Notes:**

### Phase 3: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Fill the Churning Machine with an amount of milk that isn't a clean multiple of 5 (e.g. 12L), run a full cycle to completion without touching it, and confirm exactly 10L is removed (2L remains).
- [ ] Fill it with exactly 20L (full), run a full cycle to completion, confirm it ends empty.
- [ ] Fill it with less than 5L (e.g. 3L), run a full cycle to completion, confirm nothing is removed.
- [ ] Start a cycle, then manually select "Turn Off" before it completes, and confirm **no** milk is removed.
- [ ] Confirm DevCycle 004's fluid interactions and DevCycle 005's Turn On/Off toggle, milk gate, and auto-stop timer all still work unaffected.
- [ ] Confirm no butter or item-inventory changes occur (Step 7 is still not implemented) — the milk should just disappear.

**Technical Notes:**

---

## Notes and Risks

- This cycle explicitly does not add butter production or fullness tracking — that begins in Step 7.
- Audio remains silent per DevCycle 005's deferral to Step 11; not affected or investigated in this cycle.
- The Wash Menu / possible tile-reclassification question remains open and deferred to post-Step-11, per the Plan; not affected or investigated in this cycle.
- Splitting "stop because manually turned off" from "stop because the cycle finished" is new branching in `stopMachine`/`checkRunningMachines` that DevCycle 005 didn't need — worth double-checking it doesn't regress the auto-stop or manual-stop behavior DevCycle 005 already verified working.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
