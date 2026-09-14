# DevCycle 012: Fresh Look at Silent Running Audio, Grounded in the Vanilla Washer Audio Analysis

**Status:** Planning
**Start Date:** 2026-09-14
**Target Completion:** TBD

---

## Goal

Take a genuinely fresh angle on the still-unresolved problem from DevCycle 011: the Churning Machine produces no audible sound while running, even though the engine confirms (`isPlaying()`) that `ClothingWasherRunning` is actually triggered on the emitter. DevCycle 011 exhausted the "keep varying this mod's own code and listen for a difference" approach across 17 phases without success and hit a real ceiling — several remaining hypotheses can't be confirmed or ruled out from source alone (the FMOD event content and the concrete `FMODSoundEmitter` implementation aren't in this repo's decompiled sources).

This cycle starts instead from `claudeDocs/claude_washingMachineAudioAnalysis.md` — a detailed, mechanism-level read of exactly how vanilla's own `ClothingWasherLogic.updateSound()` produces audible sound — and uses it to generate specific, testable hypotheses for *why* a Lua-triggered, otherwise line-for-line-matching copy of that mechanism might still be silent.

## Desired Outcome

- Selecting "Turn On" on a Churning Machine with milk in it produces an audible looped running sound, confirmed by ear (not just `isPlaying() == true`, which DC11 already established is insufficient evidence of audibility on its own).
- The sound continues for the duration of the cycle and stops when the machine stops (Turn Off or natural completion) — the on/off *logic* already works (DC005/006 built it, DC011 confirmed transitions are correct); only audibility remains unproven.
- No other Churning Machine behavior changes — milk gate, milk removal on completion (DC006), butter generation (DC007), and the 10-minute cycle duration (DC010) stay exactly as they are.
- If this cycle concludes the current scripted-entity approach cannot be made audible at all (i.e. the ceiling identified in DC011 is confirmed to be architectural, not fixable from Lua), that is a valid outcome to report back for a separate decision — not a license to unilaterally adopt DC11+'s item #8 ("convert a real washer/dryer") in this cycle.

---

## Tasks

### Phase 1: Mine the vanilla audio analysis for concrete, testable differences

**Status:** Planning

Re-read `claudeDocs/claude_washingMachineAudioAnalysis.md` specifically for anything the current `ChurningMachineCode.lua` (`startMachine`/`stopMachine`, as left at the end of DC011 — loop start, `ClothingWasherLoaded` parameter set to `1.0`, no per-tick re-arming) does not already match. Two concrete leads fall directly out of that document and were **not** tested in DC011:

- [ ] **Positional/distance attenuation.** The analysis explicitly notes (Part 1) that the emitter is a *positional/3D sound* anchored to the object's tile — "volume and stereo panning fall off with player distance the same way any world sound would." DC011's tests don't record how close Ed's character was standing to the machine during any test. If the FMOD event has a tight baked-in min/max attenuation distance, standing even a couple of tiles away could make it inaudible while `isPlaying()` still reports `true`. **Test:** stand directly adjacent to (or on top of) the machine's tile for the next audibility check, as close as physically possible, before concluding the loop itself is broken.
- [ ] **No per-tick re-arming, unlike vanilla.** The analysis stresses that vanilla's `updateSound()` runs *every tick* (not once), and its "start the loop" branch is guarded by `this.soundInstance == -1L` — meaning vanilla re-checks and, if necessary, re-acquires the emitter/loop continuously for as long as the machine is activated. This mod's `startMachine` sets the loop up exactly once, when "Turn On" is selected, and never revisits it until "Turn Off"/completion. Cross-referencing `IsoWorld.java` (not itself part of the audio analysis doc, but directly relevant to it): `IsoWorld.update()` reclaims any emitter in `currentEmitters` back into the shared `freeEmitters` pool the moment `e.isEmpty()` is true (checked roughly every 30ms), and that reclamation is silent to any Lua code holding a reference to the old emitter object. **Test:** add a temporary, engine-reported (not by-ear) diagnostic that polls `emitter:isPlaying(RUNNING_SOUND)` repeatedly over the life of a running cycle (e.g. once every few seconds via `Events.OnTick`, logged with a timestamp) rather than once immediately after starting it (DC011 Phase 15's check). If it ever flips to `false` before "Turn Off"/completion, the emitter is being silently reclaimed mid-cycle and the fix is to re-arm it periodically, matching vanilla's per-tick guard.
- [ ] Re-check the `category = Object` vs `category = Player` distinction (DC011 Phase 1 called this "confirmed real, inconclusive") against anything new in the audio analysis doc. The doc doesn't add new information here beyond confirming the category value — note this explicitly rather than re-investigating a dead end.
- [ ] Note explicitly, so DC012 doesn't repeat DC011's mistake: the audio analysis doc's own Caveats section confirms the FMOD event content and the real `FMODSoundEmitter` implementation are **not** present in this repo's decompiled sources — so any hypothesis that would require inspecting either of those is not resolvable by further source reading. Prioritize in-game, objective (`isPlaying`/logged) tests over more code-reading once a hypothesis reaches that ceiling.

### Phase 2: Carry forward DC11's own agreed-but-untested next step

**Status:** Planning

DevCycle 011 closed with a specific, already-reasoned-through next step that was never implemented (Phase 17: "awaiting Ed's go-ahead"):

- [ ] Temporarily swap the sound played by `startMachine` from `ClothingWasherRunning` to a different, known-good sound that is also played via `playSoundLoopedImpl` (not `playAmbientLoopedImpl`, which is a different method used by `TreeAmbianceLogic` and not a fair comparison) through the exact same object-emitter code path.
- [ ] Ed to test and report: is *this* sound audible? This isolates "looped playback from a Lua-created world-object emitter is broken in general" (this test would also be silent) from "something specific to the `Object/ClothingWasher/Running` FMOD event" (this test would be audible, the real event would still be silent).

### Phase 3: Run the diagnostics, in isolation, one variable at a time

**Status:** Planning

Following the process discipline Ed set in DC011 (Phase 9 onward): one change at a time, re-test after each, rather than layering hypotheses.

- [ ] Test proximity (Phase 1's first bullet) first — cheapest, no code change required, just re-run the existing DC011-end-state code while standing adjacent to the machine.
- [ ] If still silent up close, add the repeated `isPlaying()` polling diagnostic (Phase 1's second bullet) and run a full cycle, watching for a `false` flip.
- [ ] If `isPlaying()` stays `true` throughout and it's still inaudible, run Phase 2's substitute-sound test.
- [ ] Remove all temporary diagnostic code once each test's result is captured — do not let diagnostics accumulate across phases the way DC011's did.

**Technical Notes:**

### Phase 4: Implement whatever fix the diagnostics point to

**Status:** Planning

- [ ] Deliberately left unspecified until Phase 3's evidence exists.
- [ ] If proximity turns out to be the explanation, no code fix may even be needed — document the effective range and close this cycle on that finding alone (updating Ed's testing expectations, not the code).
- [ ] If emitter reclamation is confirmed, add a per-tick (or periodic) re-arm check to `checkRunningMachines` (already running every `Events.OnTick`) that re-acquires the emitter/loop if `ChurningMachineCode.emitters[key]` is missing, empty, or no longer reports `isPlaying(RUNNING_SOUND) == true`, mirroring vanilla's own `soundInstance == -1L` re-arm gate.
- [ ] If the substitute-sound test shows the mechanism itself is broken for any looped object-emitter sound, this is the "architectural ceiling" outcome — report back rather than proceeding into DC11+'s item #8 territory unilaterally.

**Technical Notes:**

### Phase 5: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Select "Turn On" with milk in the container and confirm the running sound is audible by ear, from a normal play distance (not just standing on top of the tile).
- [ ] Confirm the sound continues for the duration of a cycle and stops correctly on both manual "Turn Off" and natural completion.
- [ ] Confirm DC006 (milk removal on completion), DC007 (butter generation), and DC010 (10-minute cycle duration) are unaffected.
- [ ] Confirm all temporary diagnostic code from Phases 1-3 has been fully removed.

**Technical Notes:**

---

## Notes and Risks

- This cycle explicitly does **not** re-litigate what DC011 already ruled out: `Invisible` debug mode, session-wide mute/volume settings (a real vanilla washer was confirmed audible in the same session), manual emitter ticking, and both values of the `ClothingWasherLoaded` parameter. Re-testing any of these without new evidence suggesting they were wrongly ruled out would be repeating DC011's mistake, not a fresh angle.
- Per DC011's own lesson: prefer engine-reported/logged checks (`isPlaying()`, polled over time) over judging results by ear wherever possible — DC011 lost significant time to confusion between similar-sounding one-shot diagnostics.
- Item #2 (Wash Menu / reclassification) and item #8 (converting a real washer/dryer) from `doc/ideas/PseudoChurningMachineDC11Plus.md` remain out of scope, same as DC011 — if Phase 4 concludes the sound genuinely can't be fixed within the current scripted-entity approach, report that back for a separate decision rather than acting on it here.
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
