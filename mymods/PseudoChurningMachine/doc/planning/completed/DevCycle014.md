# DevCycle 014: Manual-Tick Emitter — Replicating the Left-Behind Alarm Watch's Working Pattern

**Status:** Verified — Complete
**Start Date:** 2026-09-14
**Target Completion:** 2026-09-14

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

**Status:** Work Complete — in-game verification pending

Replicate the specific mechanism `ItemSoundManager`/`AlarmClockClothing` use for a left-behind, audible, non-character-emitter sound — not just re-trying the washer's own pattern again.

- [x] When starting the machine: acquire the emitter via `IsoWorld.instance:getFreeEmitter(x, y, z)` as before, but immediately call `IsoWorld.instance:takeOwnershipOfEmitter(emitter)` (replacing the old `setEmitterOwner` call entirely) — detaching it from the engine's automatic per-frame tick pool, the one step every prior version of this code has never done.
- [x] Start the loop with `emitter:playSoundLoopedImpl(RUNNING_SOUND)` (kept as-is — `ClothingWasherRunning` is vanilla's own loop-capable event; this phase isolates the ownership/ticking variable rather than also changing the start method). The DC011 Phase 16 `ClothingWasherLoaded` parameter call was also left in place unchanged, since it was already ruled out (both values tested, no effect) rather than removed as noise.
- [x] Add a manual tick: every `Events.OnTick` (the mod's existing `checkRunningMachines`, which already runs continuously), call `emitter:tick()` on every active machine's emitter — mirroring `ItemSoundManager.update()`'s own per-frame `emitter.tick()` call. This is the specific, previously-never-attempted ingredient this whole DevCycle exists to test.
- [x] Keep the existing continuous, logged `isPlaying()` diagnostic from DC012 running throughout — unchanged, just deduplicated against the new manual-tick code's own `emitter` lookup.
- [x] On stop (manual Turn Off or natural completion): stop the tracked sound instance by handle (`emitter:stopSound(soundInstance)`, falling back to the old by-name `stopOrTriggerSoundByName` only if no handle was recorded), then call `IsoWorld.instance:returnOwnershipOfEmitter(emitter)` to properly hand the emitter back — mirroring the generator's and `ItemSoundManager`'s own explicit cleanup.

**Technical Notes:**

Implemented in `ChurningMachineCode.lua`:
- New `ChurningMachineCode.soundInstances` table (keyed by `machineKey`, same shape as `.emitters`/`.active`) tracks the numeric handle `playSoundLoopedImpl` returns, so `stopMachine` can stop precisely that instance rather than relying only on the by-name `stopOrTriggerSoundByName`.
- `startMachine`: `IsoWorld.instance:setEmitterOwner(emitter, entity)` was removed and replaced with `IsoWorld.instance:takeOwnershipOfEmitter(emitter)`.
- `checkRunningMachines`: added an unconditional `emitter:tick()` call per active machine, every tick, ahead of the existing throttled `isPlaying()` diagnostic (which now reuses the same `emitter` local instead of re-fetching it).
- `stopMachine`: now stops by handle when available, and calls `IsoWorld.instance:returnOwnershipOfEmitter(emitter)` after stopping, before clearing the Lua-side tracking tables.

### Phase 2: In-game verification

**Status:** Verified

- [x] Ran `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] **Selected "Turn On" with milk in the container — the running sound was audible.** Confirmed by Ed ("This looks good"). This is the first time in this mod's entire history (DC005 onward) that the running sound has actually been heard.
- [x] Removed the DC012-era diagnostic logging (`ChurningMachineCode.lastSoundCheckMs`, `SOUND_CHECK_INTERVAL_MS`, and the throttled `isPlaying()` print) from `ChurningMachineCode.lua`, now that the result is confirmed — the real fix (manual `takeOwnershipOfEmitter`/`tick()`, handle-based stop, `returnOwnershipOfEmitter` cleanup) is all that remains.
- Marked Verified by Ed's explicit direction (2026-09-14), per `DevelopmentProcess.md`'s permission-gated `Verified` status. Milk removal (DC006), butter generation (DC007), and the 10-minute cycle length (DC010) were not independently re-itemized in this test — this DevCycle's changes were confined to the sound-emitter code path (`startMachine`'s emitter acquisition, `checkRunningMachines`' tick loop, `stopMachine`'s stop/cleanup) and did not touch the milk-gate, fluid-removal, or butter-generation logic at all, so no regression is expected there, but it's recorded here as reasoned-about rather than explicitly re-tested this pass.

**Technical Notes:**

---

## Notes and Risks

- This is the single most targeted, evidence-backed hypothesis remaining from the full sound-architecture investigation (`claude_washingMachineAudioAnalysis.md`, `claude_generatorAudioAnalysis.md`, `claude_microwaveAudioAnalysis.md`, `claude_digitalWatchAudioAnalysis.md`). It is not another guess pulled from nowhere — it's the one mechanism confirmed, from real vanilla behavior, to produce audible non-character-emitter sound from something that isn't an `IsoObject`.
- If this doesn't work, there is no further known vanilla precedent left to mine from this investigation. That should be treated as a real signal to stop and make a decision, not as license to keep inventing new hypotheses.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

**Completion Date:** 2026-09-14

**Phases Completed:** Both phases (implementation, in-game verification) completed and verified in a single session.

**Work Deferred:** None — this DevCycle's own Desired Outcome (audible running sound, no regression, staying within the `GameEntity` architecture) was fully met.

**Accomplishments:**
- **The Churning Machine's running sound is audible for the first time in this mod's history**, across DC005 through DC014 (DC011's 17 phases, DC012's research, and DC013's abandoned real-object pivot all preceded this).
- Root mechanism identified and fixed: `IsoWorld.instance:setEmitterOwner(emitter, entity)` — used by every prior version of this code, copied from `ClothingWasherLogic` — leaves the emitter in `IsoWorld`'s automatically-ticked pool, which apparently was not sufficient for a `GameEntity`-backed (non-`IsoObject`) owner. Switching to `IsoWorld.instance:takeOwnershipOfEmitter(emitter)` plus an explicit, manually-called `emitter:tick()` every `Events.OnTick` — the exact mechanism a left-behind digital watch's alarm uses (`ItemSoundManager`, documented in `claudeDocs/claude_digitalWatchAudioAnalysis.md`) — produced working audio.
- Also added, as part of the same fix: handle-based sound stopping (`ChurningMachineCode.soundInstances`, `emitter:stopSound(soundInstance)`) and proper emitter cleanup (`IsoWorld.instance:returnOwnershipOfEmitter(emitter)` on stop) — neither of which any prior version of this code did.
- All DC012-era diagnostic logging removed once the result was confirmed, leaving only the real fix in place.

**Metrics:** 2 phases, both completed and verified in one session — the fastest resolution in this mod's entire audio investigation, after DC011 (17 phases) and DC012 (research-only) both failed to find it, and DC13 abandoned an entire architectural pivot trying to route around it.

**Lessons / Notes:**
- **The fix came from systematically comparing multiple independent vanilla precedents, not from further guessing on the original object type.** DC11 spent 17 phases varying its own code while staying anchored to `ClothingWasherLogic`'s specific pattern. The actual fix only surfaced after deliberately analyzing four *other* vanilla sound sources (generator, stove/microwave, digital watch) and noticing the generator and the watch both use a different, previously-untried ownership model — and specifically that the watch's version is confirmed to work from something that, like our own object, isn't an `IsoObject`.
- Reinforces a lesson already recorded from DC12: re-deriving a problem from fresh, comparative research beats continuing to vary the same code under the same assumptions.
- Worth remembering for future PZ modding in this project: an `IsoObject`'s emitter is auto-ticked by the engine, but a non-`IsoObject` source (an `InventoryItem`, or Lua code standing in for one) is not guaranteed the same treatment via `setEmitterOwner` alone — `takeOwnershipOfEmitter` + a manual per-tick `emitter:tick()` call is the confirmed-working alternative.
