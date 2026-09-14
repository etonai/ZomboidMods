# DevCycle 010: Cycle Time to 10 Minutes

**Status:** Planning
**Start Date:** 2026-09-13
**Target Completion:** TBD
**Focus:** Change the Churning Machine's run duration from the 1-minute test value (DevCycle 005) to 10 minutes of game time.

---

## Goal

Implement Step 10 of `PseudoChurningMachinePlan.md` ("Clean up" — raising the cycle time from its test duration), with one deliberate deviation from the Plan's originally-written text: **by Ed's direct instruction (2026-09-13), the target is 10 minutes of game time, not the 15 minutes the Plan originally stated.** `PseudoChurningMachinePlan.md` Step 10 has already been updated to record this revision and point here.

## Desired Outcome

- `RUN_MINUTES` in `ChurningMachineCode.lua` changes from `1.0` to `10.0`.
- A completed Turn On cycle now takes 10 minutes of game time to auto-stop, instead of 1 minute.
- No other behavior changes: the milk-gate, manual "Turn Off", milk removal on completion (DevCycle 006), and butter generation (DevCycle 007) all continue to work exactly as before — this cycle only changes the duration, not any of the mechanics built on top of it.
- Audio remains deferred to Step 11 (DevCycle 005) and is not addressed here.
- The Wash Menu / tile-reclassification question remains deferred to post-Step-11 and is not addressed here.

---

## Tasks

### Phase 1: Implement

**Status:** Planning

- [ ] Change `local RUN_MINUTES = 1.0` to `local RUN_MINUTES = 10.0` in `ChurningMachineCode.lua:3`.
- [ ] Update the trailing comment on that line (currently `-- test duration; raised to 15 in Step 10.`), since it references the Plan's original 15-minute figure, which no longer applies.
- [ ] Confirm no other code in `ChurningMachineCode.lua` hardcodes the old 1-minute duration or the Plan's old 15-minute figure anywhere else (e.g. tooltip text, comments) that would now be misleading.

**Technical Notes:**

### Phase 2: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Start a cycle with milk in the container and confirm it runs for 10 minutes of game time before auto-stopping (not 1 minute).
- [ ] Confirm milk removal (DevCycle 006) and butter generation (DevCycle 007) still occur correctly when the (now longer) cycle completes naturally.
- [ ] Confirm manual "Turn Off" before the 10 minutes elapse still stops the machine early with no milk removed and no butter produced.
- [ ] Confirm DevCycle 004/005's other behaviors (fluid interactions, milk gate, Turn On/Off toggle) remain unaffected.

**Technical Notes:**

---

## Notes and Risks

- This is a minimal, single-constant change — no new mechanics, no new risk surface beyond confirming the longer duration doesn't interact badly with anything already built (it shouldn't, since `checkRunningMachines`' tick-based comparison against `RUN_MINUTES` is duration-agnostic).
- A 10-minute cycle takes 10x longer to verify in-game than DevCycle 005/006/007's 1-minute test duration — Phase 2 testing will simply take longer in real time, not require different steps.
- Audio (deferred to Step 11) and the Wash Menu/tile-reclassification question (deferred to post-Step-11) are unrelated to this cycle and remain untouched.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
