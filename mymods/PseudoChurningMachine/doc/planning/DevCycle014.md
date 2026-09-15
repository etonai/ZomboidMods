# DevCycle 014: Manual-Tick Emitter — Replicating the Left-Behind Alarm Watch's Working Pattern

**Status:** Planning
**Start Date:** 2026-09-14
**Target Completion:** TBD

---

## Goal

The Churning Machine's running sound has been silent since it was first attempted (DevCycle 005), through DevCycle 011's 17-phase investigation, DevCycle 012's research/diagnostics, and DevCycle 013's abandoned real-object pivot — always using the same emitter-ownership pattern (`IsoWorld.instance:setEmitterOwner(emitter, entity)`, relying on the engine to tick the emitter automatically). Every DC11/DC12 test confirmed the engine genuinely considers the sound "playing" (`isPlaying() == true`, checked both once and repeatedly over a full cycle) — yet nothing was ever audible.

`claude_digitalWatchAudioAnalysis.md` surfaced a mechanism never tried against the Churning Machine: a left-behind digital watch's alarm — confirmed, everyday, real vanilla behavior — plays through a **manually-ticked** emitter, acquired via `getFreeEmitter()` and immediately detached from the engine's automatic tick pool via `takeOwnershipOfEmitter()`, with `ItemSoundManager.update()` calling `emitter:tick()` on it explicitly every frame. Critically, the thing making that sound is an `InventoryItem`, not an `IsoObject` — the same non-`IsoObject` category our `GameEntity`-based Churning Machine is in. This is the first genuinely different emitter-management recipe this whole investigation has found that (a) is confirmed to produce real, positioned, non-character-emitter audio in vanilla, and (b) has never actually been tried here.

## Desired Outcome

- Turning the Churning Machine on produces an audible, positioned running sound anchored to the machine's own location (not the player), confirmed by ear.
- The sound stops correctly on both manual "Turn Off" and natural cycle completion.
- No regression to existing behavior: milk gate, milk removal (DC006), butter generation (DC007), and the 10-minute cycle (DC010) all continue to work exactly as before.
- This stays within the current scripted-entity (`GameEntity`) architecture — no reversion to DC13's real-object-conversion approach.
- **If manual ticking still produces "engine says playing, nothing audible," that is a valid, reportable outcome — not a reason to invent a sixth hypothesis to test.** This investigation has now examined five distinct vanilla sound architectures (washer, fireplace, generator, stove/microwave, watch) across DC11, DC12, and this analysis pass. If the one mechanism confirmed to work for a non-`IsoObject` source still doesn't produce audio here, that should be reported back as a real, considered dead end — prompting a decision (accept silent audio, or reconsider architecture) rather than another round of guessing.

---

## Tasks

### Phase 1: Implement the manual-tick recipe

**Status:** Planning

Replicate the specific mechanism `ItemSoundManager`/`AlarmClockClothing` use for a left-behind, audible, non-character-emitter sound — not just re-trying the washer's own pattern again.

- [ ] When starting the machine: acquire the emitter via `IsoWorld.instance:getFreeEmitter(x, y, z)` as before, but immediately call `IsoWorld.instance:takeOwnershipOfEmitter(emitter)` — detaching it from the engine's automatic per-frame tick pool, the one step every prior version of this code has never done.
- [ ] Start the loop with `emitter:playSoundLoopedImpl(RUNNING_SOUND)` (kept as-is — `ClothingWasherRunning` is vanilla's own loop-capable event; this phase isolates the ownership/ticking variable rather than also changing the start method).
- [ ] Add a manual tick: every `Events.OnTick` (the mod's existing `checkRunningMachines`, which already runs continuously), call `emitter:tick()` on every active machine's emitter — mirroring `ItemSoundManager.update()`'s own per-frame `emitter.tick()` call. This is the specific, previously-never-attempted ingredient this whole DevCycle exists to test.
- [ ] Keep the existing continuous, logged `isPlaying()` diagnostic from DC012 running throughout — an objective check, not by-ear judgment, for whether this changes anything about the engine's own reported playback state (even though DC12 already showed it staying `true`, worth re-confirming nothing regresses).
- [ ] On stop (manual Turn Off or natural completion): stop the tracked sound instance, then call `IsoWorld.instance:returnOwnershipOfEmitter(emitter)` to properly hand the emitter back — mirroring the generator's and `ItemSoundManager`'s own explicit cleanup, rather than just discarding the Lua reference and leaving the emitter's ownership state unresolved.

**Technical Notes:**

### Phase 2: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Select "Turn On" with milk in the container and listen for the running sound — this is the actual test this whole DevCycle exists to run.
- [ ] Confirm the sound stops correctly on manual "Turn Off" and on natural 10-minute completion.
- [ ] Confirm milk removal (DC006), butter generation (DC007), and the 10-minute cycle length (DC010) are all unaffected.
- [ ] Remove the DC012-era diagnostic logging once the result is captured and understood, one way or the other.

**Technical Notes:**

---

## Notes and Risks

- This is the single most targeted, evidence-backed hypothesis remaining from the full sound-architecture investigation (`claude_washingMachineAudioAnalysis.md`, `claude_generatorAudioAnalysis.md`, `claude_microwaveAudioAnalysis.md`, `claude_digitalWatchAudioAnalysis.md`). It is not another guess pulled from nowhere — it's the one mechanism confirmed, from real vanilla behavior, to produce audible non-character-emitter sound from something that isn't an `IsoObject`.
- If this doesn't work, there is no further known vanilla precedent left to mine from this investigation. That should be treated as a real signal to stop and make a decision, not as license to keep inventing new hypotheses.
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
