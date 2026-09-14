# DevCycle 010: Cycle Time to 10 Minutes

**Status:** Verified (2026-09-13) — Ed confirmed testing passed
**Start Date:** 2026-09-13
**Target Completion:** 2026-09-13
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

**Status:** Work Complete — implementation done, in-game verification pending (Phase 2)

- [x] Change `local RUN_MINUTES = 1.0` to `local RUN_MINUTES = 10.0` in `ChurningMachineCode.lua:3`.
- [x] Update the trailing comment on that line (currently `-- test duration; raised to 15 in Step 10.`), since it references the Plan's original 15-minute figure, which no longer applies.
- [x] Confirm no other code in `ChurningMachineCode.lua` hardcodes the old 1-minute duration or the Plan's old 15-minute figure anywhere else (e.g. tooltip text, comments) that would now be misleading.

**Technical Notes:**

`ChurningMachineCode.lua:3` now reads `local RUN_MINUTES = 10.0 -- Step 10: full cycle duration.`, replacing both the `1.0` test value and the stale comment (which referenced the Plan's original, now-superseded 15-minute figure). Grepped the whole mod for `RUN_MINUTES`, "1 minute", and "15 minute" — the only other reference is `checkRunningMachines`'s comparison at `ChurningMachineCode.lua:100` (`(now - startHour) * 60.0 >= RUN_MINUTES`), which reads the constant rather than hardcoding a duration, so it needed no change. No tooltip text or other comments reference the old duration.

### Phase 2: In-game verification

**Status:** Verified — Ed confirmed testing passed

- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] Start a cycle with milk in the container and confirm it runs for 10 minutes of game time before auto-stopping (not 1 minute).
- [x] Confirm milk removal (DevCycle 006) and butter generation (DevCycle 007) still occur correctly when the (now longer) cycle completes naturally.
- [x] Confirm manual "Turn Off" before the 10 minutes elapse still stops the machine early with no milk removed and no butter produced.
- [x] Confirm DevCycle 004/005's other behaviors (fluid interactions, milk gate, Turn On/Off toggle) remain unaffected.

**Technical Notes:**

Ed confirmed testing passed (2026-09-13).

---

## Notes and Risks

- This is a minimal, single-constant change — no new mechanics, no new risk surface beyond confirming the longer duration doesn't interact badly with anything already built (it shouldn't, since `checkRunningMachines`' tick-based comparison against `RUN_MINUTES` is duration-agnostic).
- A 10-minute cycle takes 10x longer to verify in-game than DevCycle 005/006/007's 1-minute test duration — Phase 2 testing will simply take longer in real time, not require different steps.
- Audio (deferred to Step 11) and the Wash Menu/tile-reclassification question (deferred to post-Step-11) are unrelated to this cycle and remain untouched.

---

## Completion Summary

**Completion Date:** 2026-09-13

**Phases Completed:** 1-2, both Verified. Every line of the Desired Outcome was tested and confirmed working — no unmet goals.

**Work Deferred:** None new. Pre-existing deferrals (audio to Step 11, Wash Menu/tile-reclassification to post-Step-11, "Add Liquid from Item" to DC 11) were untouched and out of scope, as planned.

**Accomplishments:**
- `RUN_MINUTES` raised from the 1-minute test value to 10 minutes of game time, per Ed's direct instruction (deviating from the Plan's originally-written 15-minute target, which was updated to match).
- Confirmed the longer cycle duration doesn't disturb any mechanic built on top of it: milk-gate, manual "Turn Off", milk removal on completion (DevCycle 006), and butter generation (DevCycle 007) all still work correctly.

**Metrics:** Single-constant change, 1 in-game test round, no bugs found.

**Lessons / Notes:**
- This cycle confirms the duration-agnostic design of `checkRunningMachines`' tick-based comparison (established back in DevCycle 005) paid off — changing `RUN_MINUTES` required touching exactly one line of logic plus its comment, with zero ripple effects into DevCycle 006/007's completion-triggered logic.
