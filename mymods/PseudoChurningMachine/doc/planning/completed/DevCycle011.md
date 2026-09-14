# DevCycle 011: Fix Silent "Turn On" Audio

**Status:** Closed — Incomplete
**Start Date:** 2026-09-13
**Target Completion:** TBD
**Closed Date:** 2026-09-14
**Focus:** Fix item #1 only from `doc/ideas/PseudoChurningMachineDC11Plus.md` — the Churning Machine's "Turn On" running sound still doesn't play. Nothing else from that analysis document is in scope for this cycle.

---

## Goal

Make the Churning Machine's running sound (`ClothingWasherRunning`) actually audible while a cycle is active, fixing item #1 of `doc/ideas/PseudoChurningMachineDC11Plus.md`. That analysis already tried matching the vanilla `ClothingWasherLogic.updateSound()` Java pattern exactly (`IsoWorld.instance:getFreeEmitter()`, `IsoWorld.instance:setEmitterOwner()`, `emitter:playSoundLoopedImpl()`) in DevCycle 005 Phase 6, and it stayed silent — so this cycle needs a genuinely new angle, not a repeat of that fix.

**New lead, provided by Ed:** `mymods/PseudoSaltWell` (the bare-named mod directory — **not** `PseudoSaltWell42_19`, a separate, differently-versioned mod directory that happens to share a similar name) successfully plays audio when a player fills a container with saltwater brine from the well. That confirms at least one working, in-repo precedent for triggering sound from mod Lua — worth comparing directly against what the Churning Machine does differently, rather than only re-deriving from vanilla Java as DevCycle 005 did.

## Desired Outcome

- Selecting "Turn On" on a Churning Machine with milk in it produces an audible looped running sound.
- The sound continues for the duration of the cycle and stops when the machine stops (whether by "Turn Off" or natural completion) — matching the behavior DevCycle 005/006 already built the on/off logic around, just now actually audible.
- No other Churning Machine behavior changes — milk gate, milk removal on completion (DevCycle 006), butter generation (DevCycle 007), and the 10-minute cycle duration (DevCycle 010) are all out of scope and must keep working exactly as before.
- Item #2 (Wash Menu / reclassification) and item #8 (converting a real washer/dryer) from the analysis doc are explicitly **not** in scope here — this cycle only targets making the *current* scripted-entity approach's sound work, not adopting a different architecture. If Phase 1's research finds this can't be fixed without addressing #8, that's a valid conclusion to report back, not a license to implement #8 in this cycle.

---

## Tasks

### Phase 1: Research — find what's actually different about the working example

**Status:** Work Complete

- [x] Read `mymods/PseudoSaltWell`'s working audio code in full and compare it against `ChurningMachineCode.lua`'s `startMachine`. **Confirmed real, concrete difference: character emitter + `Player`-category sound vs. world-object emitter + `Object`-category sound** — see notes below.
- [x] Ruled out "the emitter needs manual per-frame maintenance we're not doing" as a cause.
- [x] Ruled out `Core.soundDisabled` (global sound-disable flag) as a cause.
- [x] Investigated whether a per-category volume-slider difference could explain it — inconclusive from source alone, see notes.
- [ ] **Not resolvable by further source reading: an isolated in-game test is still needed to actually isolate the remaining candidates** (deferred to the new Phase 2, added specifically for this — see below).

**Technical Notes:**

**Confirmed real difference #1 — character emitter vs. world-object emitter.** `mymods/PseudoSaltWell`'s working sound (`42/media/lua/shared/TimedActions/ISFillPotFromWell.lua:56` and `ISFillKettleFromWell.lua:56`) is `self.character:getEmitter():playSound("GetWaterFromTap")` — obtained from `IsoGameCharacter.getEmitter()` (`zombie42_20_4/characters/IsoGameCharacter.java:1579-1581`), a single emitter allocated once per character and reused (`this.emitter`), not fetched fresh from a shared pool. The Churning Machine's `startMachine` instead calls `IsoWorld.instance:getFreeEmitter(x, y, z)` (`zombie42_20_4/iso/IsoWorld.java:445-461`), which pulls from a shared `freeEmitters` pool (or allocates a new one) and returns a plain `BaseSoundEmitter`, not tied to any character. This is the same object-vs-character distinction DevCycle 005 Phase 1 already flagged as "new, unproven ground for this project" before ever implementing it — this analysis confirms it's *still* the one meaningfully untested path, now backed by a second, independent working counter-example (`PseudoSaltWell`, not just vanilla Java).

**Ruled out — manual emitter ticking.** Re-confirmed `IsoWorld.update()` (`zombie42_20_4/iso/IsoWorld.java:2990-3014`) ticks every emitter in its `currentEmitters` list automatically (roughly every 30ms), and `getFreeEmitter()` adds every emitter it returns to that same list (`IsoWorld.java:454`) — regardless of whether it was requested from Java or Lua. There is no separate per-tick maintenance a caller is expected to perform. This specific hypothesis (considered but not confirmed in the original DC11+ analysis doc) is now ruled out with certainty.

**Ruled out — `Core.soundDisabled` (all sound globally disabled).** Both code paths are gated by the exact same flag: `IsoWorld.getFreeEmitter()` creates a `DummySoundEmitter` (a no-op stub) instead of a real `FMODSoundEmitter` when `Core.soundDisabled` is true (`IsoWorld.java:448`), and `IsoGameCharacter`'s own emitter allocation uses the identical check (`this.emitter = !Core.soundDisabled && !GameServer.server ? new CharacterSoundEmitter(this) : new DummyCharacterSoundEmitter(this)`, `IsoGameCharacter.java:783`). Since `PseudoSaltWell`'s character-based sound is confirmed audible in the same testing environment, `Core.soundDisabled` must be `false` — which rules this out as an explanation for the object-emitter case too, since it's the same global flag.

**Investigated, inconclusive — sound category / master-volume grouping.** Found a real, confirmed difference: `ClothingWasherRunning` is declared `category = Object` (`media42_20_4/scripts/generated/sounds/objects/sounds_object_clothingwasher.txt:3-5`), while `GetWaterFromTap` is `category = Player` (`media42_20_4/scripts/generated/sounds/player/sounds_player_getwater.txt:30-32`) — a real, confirmed difference between the two sounds, not the emitter mechanism. However, tracing further into `GameSound.java` (`zombie42_20_4/audio/GameSound.java:13-20, 61-63`) found that the actual per-slider volume grouping is a separate `master` field (`GameSound.MasterVolume`, e.g. `Primary`/`Music`/`Ambient`/`VehicleEngine`, surfaced in options via `ISGameSoundVolumeControl.lua:143-150`) that defaults to `Primary` and is **not** automatically derived from `category` — and neither sound script declares an explicit `master` field, so by the visible source both should default to the same `Primary` master-volume group. This means the category difference is real but its consequence (if any) isn't provable from source alone — it's plausible `category = Object` still affects something else (e.g. 3D distance-based attenuation baked into the compiled FMOD event itself, which isn't visible in any decompiled source here) but this couldn't be confirmed or ruled out further by reading code.

**Bottom line for Phase 2:** the single most concrete, actionable next step is an isolated in-game test distinguishing the character-emitter-vs-object-emitter question from the looped-vs-one-shot question — e.g., temporarily trying `IsoWorld.instance:getFreeEmitter(x,y,z):playSound(...)` (non-looped, one-shot) from the Churning Machine's "Turn On" path to see if *any* Lua-triggered object emitter is audible at all, and separately trying the proven character-emitter pattern (even if only as a diagnostic, not necessarily the final design) to confirm the sound event itself isn't the problem. This isn't resolvable by more source reading — FMOD bank data (which would show any baked-in distance/attenuation settings on the `Object/ClothingWasher/Running` event) isn't present in this repo's decompiled sources.

### Phase 2: Diagnostic test — isolate the real cause in-game before committing to a fix

**Status:** Planning

Phase 1 could not determine, from source alone, whether the object-vs-character emitter distinction (or the looped-vs-one-shot distinction, or something else entirely, like FMOD-internal attenuation on the specific event) is the actual cause — it narrowed the field but didn't resolve it. This phase adds temporary, clearly-marked diagnostic code to gather that evidence in-game, rather than guessing at Phase 3's real fix.

**Diagnostic code added** (`ChurningMachineCode.lua`, inside `startMachine`, marked `DC011 Phase 2 DIAGNOSTIC (temporary - remove...)`):
```lua
-- (1) one-shot, non-looped sound from a world-object emitter
IsoWorld.instance:getFreeEmitter(square:getX() + 0.5, square:getY() + 0.5, square:getZ()):playSound("ClothingWasherFinished")
-- (2) the proven character-emitter pattern (mirrors mymods/PseudoSaltWell's working call)
if playerObj then
    playerObj:getEmitter():playSound("GetWaterFromTap")
end
```
- Test (1) reuses `ClothingWasherFinished` (`media42_20_4/scripts/generated/sounds/objects/sounds_object_clothingwasher.txt:12-19`) — same `Object` category as the currently-silent `ClothingWasherRunning`, but a one-shot, non-looped sound — to isolate "object emitters don't work from Lua at all" from "looped playback specifically doesn't work."
- Test (2) reuses `GetWaterFromTap`, the exact sound `mymods/PseudoSaltWell` already proved audible via a character emitter, called the same way (`playerObj:getEmitter():playSound(...)`) — confirmed safe to call here since `startMachine` needed `playerObj` threaded in from `onToggleOption` (previously only took `entity`; both callers updated).
- Both fire once, immediately, when "Turn On" is selected — Ed should listen for two distinct one-shot sounds (a washer "finished" chime and a tap/water sound) right when starting a cycle, separate from the (still silent) looped running sound this cycle is ultimately trying to fix.

- [x] Temporarily add a one-shot, non-looped call from a world-object emitter to the Churning Machine's "Turn On" path — e.g. `IsoWorld.instance:getFreeEmitter(x, y, z):playSound(...)` using a sound already confirmed to exist — to test whether *any* Lua-triggered object emitter is audible at all, independent of looping.
- [x] Temporarily add the proven character-emitter pattern (`entity's nearby playerObj:getEmitter():playSound(...)`, mirroring `PseudoSaltWell`'s working call) triggered from the same "Turn On" path, to confirm the *sound event itself* isn't the problem and that a Lua-triggered emitter of some kind can play it audibly.
- [x] Have Ed run both diagnostic calls in-game (after Phase 5's crash fix) and report which, if either, is actually audible. — **Result: neither was audible.** No crash this time, but no sound at all from either test (1) or test (2).
- [ ] Based on the result, identify the real fix direction for Phase 3 — **this result was the "neither is audible" case anticipated above: a session-level setting or something outside the emitter-type distinction is now implicated, not simply "object emitters are broken."** See notes below for the concrete next diagnostic step this points to, before any Phase 3 fix is attempted.
- [ ] Remove the diagnostic code once the result is captured — it does not belong in the final fix.

**Technical Notes:**

**"Neither audible" reopens the question Phase 1 couldn't resolve from source, and specifically implicates something session-level rather than emitter-type-specific.** Test (2) used the exact call shape (`playerObj:getEmitter():playSound("GetWaterFromTap")`) already proven to work in `mymods/PseudoSaltWell` — the entire reason it was chosen as a diagnostic was that it was a known-working precedent. If that same call, on the same sound, produces no audio here, the most likely explanations are no longer about *which emitter mechanism* is used (object vs. character) — both were just tried and both were silent — but about something specific to **this game session's current state** at the moment of testing: e.g. an audio setting changed since `PseudoSaltWell` was last actually tested (not just recalled), the specific test character/location having some audio-suppressing condition, or something about the build-cheat/debug context these tests have consistently been run under (every error log in this DevCycle and DevCycle 005 shows `BuildCheat is active`).

**Concrete next step, not yet performed: re-test `mymods/PseudoSaltWell`'s own fill-from-well action right now, in this same session, before changing any more Churning Machine code.** If that sound *is* still audible, the problem is genuinely specific to the Churning Machine's code path or context (worth continuing to dig there). If it's now *also* silent, that's strong evidence of a session-level regression (an audio setting, or something about this specific save/session) that has nothing to do with the Churning Machine's code at all — which would mean Phase 3 shouldn't proceed on a code-fix basis until that's ruled in or out.

### Phase 3: Implement the real fix

**Status:** Planning

- [ ] Apply the fix indicated by Phase 2's diagnostic result. Deliberately left unspecified until that evidence exists, rather than pre-committing to a specific code change here.
- [ ] If Phase 2 shows world-object emitters are the problem and a character-based approach is the only reliable option, work out how to keep the sound tied to the machine's location (not just the player) for the duration of the cycle — since a plain one-shot `character:getEmitter():playSound(...)` played once at "Turn On" would not loop or persist after the player walks away, unlike the current (silent) looped-emitter design.

**Technical Notes:**

### Phase 4: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Select "Turn On" with milk in the container and confirm the running sound is actually audible.
- [ ] Confirm the sound continues for the duration of a cycle and stops correctly on both manual "Turn Off" and natural completion.
- [ ] Confirm DevCycle 006 (milk removal on completion) and DevCycle 007 (butter generation) are unaffected.
- [ ] Confirm the 10-minute cycle duration (DevCycle 010) is unaffected.
- [ ] Confirm the Phase 2 diagnostic code was fully removed and no debug/test sound calls remain.

**Technical Notes:**

### Phase 5: Fix a pre-existing `onSelect` parameter-order bug surfaced by the Phase 2 diagnostic

**Status:** Work Complete — fix applied, in-game re-verification pending (back to Phase 2)

- [x] Diagnose the crash reported by Ed when selecting "Turn On" after Phase 2's diagnostic code was added.
- [x] Trace the real `addGetUpOption` calling convention precisely (Java + Lua) rather than trusting the existing code comment.
- [x] Fix `turnOnOffMenu`'s `onSelect` closure signature.
- [ ] Ed to re-run Phase 2's diagnostic test now that this crash is fixed — neither diagnostic sound could have played before, since the crash happened before `startMachine` finished, killing both diagnostic calls before they ran on the first attempt (test (1), the object-emitter one-shot, sits before the crash at line 66, so it likely *did* fire once — but test (2), the character-emitter call, is exactly what crashed, so Ed has not yet actually heard it).

**The error, as reported by Ed:**
```
Lua fail. Message: Object tried to call nil in startMachine
    Lua((MOD:PseudonymousEd's Churning Machine)).startMachine(ChurningMachineCode.lua:66)
    Lua((MOD:PseudonymousEd's Churning Machine)).onToggleOption(ChurningMachineCode.lua:77)
    Lua((MOD:PseudonymousEd's Churning Machine)).onSelect(ChurningMachineCode.lua:93)
    Lua(Vanilla).perform(ISWaitWhileGettingUp.lua:43)
```
Line 66 was `playerObj:getEmitter():playSound("GetWaterFromTap")` — the Phase 2 diagnostic's character-emitter test, the first place in this mod's history that `playerObj` was ever actually used for anything.

**Root cause — a real, pre-existing bug in `turnOnOffMenu`'s `onSelect` closure that has existed since DevCycle 005, invisible until now because `playerObj` was never dereferenced before.** Traced the exact `addGetUpOption` calling convention end to end, not assumed:
1. `ISContextMenuWrapper.addGetUpOption(name, target, onSelect, params...)` (`zombie42_20_4/ui/ISUIWrapper/ISContextMenuWrapper.java:151-165`) builds `combinedParams = [onSelect, target, params...]` and calls the Lua-side `ISContextMenu:onGetUpAndThen` with those combined params — meaning **`target` (our `entity`) is passed through as the first real argument, not dropped.**
2. `ISContextMenu:onGetUpAndThen(onSelect, p1, p2, ...)` (`media42_20_4/lua/client/ISUI/ISContextMenu.lua:1046-1055`) receives `p1 = entity`, `p2 = playerObj` (our one trailing param), and calls `action:setOnComplete(onSelect, p1, p2, ...)`.
3. `ISWaitWhileGettingUp:perform()` (`media42_20_4/lua/shared/TimedActions/ISWaitWhileGettingUp.lua:41-44`) eventually calls `self.onCompleteFunc(a.p1, a.p2, ...)` — i.e. **our `onSelect` function is actually invoked as `onSelect(entity, playerObj)`, two arguments, not one.**

DevCycle 005's original code (and its own comment) assumed `onSelect` would receive exactly one argument (`playerObj`) and wrote `local function onSelect(pObj) ChurningMachineCode.onToggleOption(entity, pObj) end`. Since Lua silently drops the correspondence between extra call-site arguments and a function's declared parameters, `pObj` was actually binding to the **first** of the two real arguments — `entity` — with the real `playerObj` silently discarded as an unused second argument. This bug has been present since DevCycle 005 but had **zero observable effect** until DevCycle 011 Phase 2, because nothing between DevCycle 005 and DevCycle 010 ever used the `playerObj` value passed through `onToggleOption` -> `startMachine` for anything — it was DC011 Phase 2's diagnostic `playerObj:getEmitter():playSound(...)` call that first tried to actually use it, and crashed because it was silently holding the Churning Machine `entity` (an `IsoObject`, with no `getEmitter()` method) instead of a real `IsoPlayer`.

**Fix applied** (`ChurningMachineCode.lua:92-99`): changed `local function onSelect(pObj)` to `local function onSelect(_, pObj)` — accepting and discarding the first (`entity`, redundant with the closure's own captured `entity`) argument, and correctly binding `pObj` to the second (real `playerObj`) argument. Updated the surrounding comment, which had stated the opposite (and now-disproven) claim about `target` not being forwarded.

**Verification note:** this fix could only be found by actually tracing the real calling convention rather than trusting DevCycle 005's original comment, which was itself the root cause. Ed needs to re-run Phase 2's diagnostic test now that `startMachine` can run to completion without crashing.

### Phase 6: Root cause found (a debug setting, not a code bug), diagnostic cleanup, and the running sound doesn't stop after 10 minutes

**Status:** Work Complete — fixes applied, in-game re-verification pending

- [x] Root cause of item #1's entire silence mystery identified by Ed: the **"Invisible" debug option** also suppresses player-caused noise. With it disabled, both Phase 2 diagnostic sounds played correctly. **This means the original looped `ClothingWasherRunning` sound was never actually broken by any code in this mod** — DevCycle 005's original implementation (matching vanilla's `emitter`/`setEmitterOwner`/`playSoundLoopedImpl` pattern) was working all along.
- [x] Remove the `GetWaterFromTap` (character-emitter) diagnostic call, per Ed's request.
- [x] Also remove the `ClothingWasherFinished` (object-emitter) diagnostic call — not explicitly requested, but Phase 2's own task list already called for removing all diagnostic code once the result was captured, and it now has been.
- [x] Diagnose and fix the new problem Ed found once real audio was audible: the looped running sound doesn't stop when the cycle completes after 10 minutes.
- [ ] Ed to re-test a full cycle end-to-end and confirm the running sound now stops correctly at both natural completion and manual "Turn Off."

**Diagnostic code removed** (`ChurningMachineCode.lua`, `startMachine`) — both temporary one-shot calls and their comments deleted; `startMachine` is back to just starting the real looped sound and tracking the machine's state.

**Running-sound-doesn't-stop — root cause not fully provable from source, but fixed using the same mechanism vanilla itself uses for this exact sound, not a generic guess.** `stopMachine` was calling `emitter:stopOrTriggerSoundByName(RUNNING_SOUND)` — DevCycle 005/006's original implementation, chosen because it's a real, valid method. Re-checked whether `ByName` is reliable for stopping an active loop: found one real vanilla counter-example that *does* use it successfully for a looped ambient sound (`ObjectAmbientEmitters.java:638-640`, `TreeAmbianceLogic.stopPlaying`), so `ByName` isn't inherently broken for loops in general — but re-reading `ClothingWasherLogic.java` in full (the exact object this mod's sound code has always modeled itself on) shows the real washer/dryer does **not** use `ByName` to stop its own running sound: it captures the numeric instance handle returned by `playSoundLoopedImpl` (`this.soundInstance = ...emitter.playSoundLoopedImpl("ClothingWasherRunning")`) and later stops that specific instance via `emitter.stopOrTriggerSound(this.soundInstance)` — the long-handle overload, not the by-name one. Our code discarded that return value entirely and relied on `ByName` instead, deviating from vanilla's own proven mechanism for this specific sound without a clear reason to.

**Fix applied:** added a new tracking table, `ChurningMachineCode.soundInstances` (keyed the same way as `ChurningMachineCode.emitters`/`.active`, by `machineKey`). `startMachine` now captures `local soundInstance = emitter:playSoundLoopedImpl(RUNNING_SOUND)` and stores it; `stopMachine` now calls `emitter:stopOrTriggerSound(soundInstance)` (the handle-based overload) instead of `stopOrTriggerSoundByName`, matching `ClothingWasherLogic`'s own exact mechanism for this exact sound.

**Honesty check — this fix is evidence-backed but not proven to be the definitive cause, and a second, real, previously-documented explanation exists and wasn't ruled out.** DevCycle 005's own Notes and Risks already flagged a known limitation: `ChurningMachineCode.emitters`/`.active` are plain, non-persisted Lua tables, so if a machine were left "running" across a save/reload (or, newly relevant, across the Phase 5 crash — which happened *after* `startMachine`'s core state-setting lines had already executed, meaning a machine could have been left genuinely running with a live looping emitter at the moment of that crash), the Lua-side tracking could be lost while a live sound instance keeps looping with no reference left to stop it — which would look exactly like "the noise didn't stop," independent of which stop method is used, because there'd be no tracked emitter/instance to call it on at all. **This fix addresses the mechanism (right method for this sound) but does not rule out an orphaned instance from an earlier test also being the cause, or a contributing factor.** Recommend Ed's re-test be a single continuous run (start a fresh cycle, don't reuse a machine that was involved in an earlier crashed/interrupted test) to cleanly verify this fix in isolation.

### Phase 7: No sound at all on re-test — fixed the stale-state risk directly rather than waiting on confirmation

**Status:** Work Complete — fix applied, in-game re-verification pending

- [x] Rather than requiring Ed to check which menu label appeared (a real diagnostic question, but one this fix makes moot either way), applied a direct, self-healing fix for the known stale-state risk flagged in Phase 6: `ModData.churningMachineRunning` persists across mod reloads/crashes, but the Lua-side `ChurningMachineCode.active` registry does not (DevCycle 005's own documented limitation) — so a machine left "running" in `ModData` from the Phase 5 crash, with no live tracked instance in the current session, would silently take the "Turn Off" branch and produce no sound, exactly matching "no sound at all."
- [x] Fixed `isRunning(entity)` to reconcile the two: it now returns `true` only if `ModData.churningMachineRunning` is `true` **and** the machine has a live entry in `ChurningMachineCode.active` for the current session. If `ModData` says running but there's no live tracked instance, it self-heals by clearing `ModData.churningMachineRunning`/`churningMachineStartHour` and reporting not-running — so the next right-click correctly offers "Turn On" again instead of staying stuck.
- [x] Ed to re-test. — **Ruled out.** Ed confirmed: menu correctly said "Turn On," clicking it flipped the menu to "Turn Off" (confirming `startMachine` ran, state transitions are correct, and this wasn't a stale-`ModData` machine — Ed has been building fresh Churning Machines for each test), no error appeared in the log, and there was still no sound. The stale-state hypothesis is fully ruled out; this is a genuinely new problem — see Phase 8.

**Technical Notes:**

Applied directly to `isRunning` (`ChurningMachineCode.lua:15-27`), the single function both `onToggleOption` and `turnOnOffMenu` already call to decide Turn On vs. Turn Off — no other call site needed updating. This is a general hardening, not specific to any one machine: any Churning Machine left "running" in a prior session/crash with no live sound behind it will now self-correct the first time its menu is checked or toggled, rather than needing a fresh tile to work around.

### Phase 8: Genuinely silent start on a fresh machine, all prior hypotheses ruled out — re-testing with a minimal, isolated diagnostic instead of guessing further

**Status:** Planning

By this point, every hypothesis that could explain silence without a live in-game check has been ruled out: milk is present (not the gate), state transitions correctly (Turn On -> Turn Off, so `startMachine` runs, not the stale-`ModData` issue Phase 7 fixed), no error appears in the log (not a crash), and this is confirmed on a freshly-built machine (not carried-over state from the Phase 5 crash). The confusing part, as Ed pointed out directly: the exact same object-emitter, one-shot call (`ClothingWasherFinished`) was confirmed audible earlier in this very DevCycle, using nearly identical code to what's running now.

Rather than making another blind code change, re-added exactly that same, already-proven diagnostic call as a direct A/B check against the current session — if it plays now, the problem is specific to the real `ClothingWasherRunning` sound/loop itself; if it doesn't, something session-level has changed again (a setting, e.g. `Invisible` or a volume slider toggled back), unrelated to any code in this mod.

- [ ] Temporarily re-add the one-shot `ClothingWasherFinished` object-emitter call (already proven audible once in this DevCycle) to `startMachine`, alongside the real `ClothingWasherRunning` loop.
- [x] Ed to test once and report: did the one-shot `ClothingWasherFinished` chime play this time? — **No.** Ed heard nothing from the Churning Machine, but could clearly hear their own character filling a container at the `PseudoSaltWell` well at the same time. **This is the "no" branch: nothing Lua-triggered from an object emitter is audible right now, while a character-emitter sound plays fine in the same moment** — the same character-vs-object asymmetry the whole DevCycle started with, now reproduced *after* Invisible was already confirmed disabled. See notes below for the new leading hypothesis this points to.
- [ ] Remove the diagnostic call once a session-level cause is found or ruled out — not removed yet, still needed for further live testing.

**Technical Notes:**

**Diagnostic code added** (`ChurningMachineCode.lua`, inside `startMachine`, marked `DC011 Phase 8 DIAGNOSTIC (temporary - remove once re-confirmed)`): the exact one-shot `IsoWorld.instance:getFreeEmitter(...):playSound("ClothingWasherFinished")` call from Phase 2, re-added right after the real looped sound is started, so both can be directly compared in the same test.

**New leading hypothesis: a second, separate debug/cheat toggle — distinct from `Invisible` — specifically suppressing object/world-emitter sounds while leaving player-caused sounds untouched.** `Invisible` was confirmed to suppress *both* diagnostics together earlier in this DevCycle, and disabling it made both audible at once — that was a real, confirmed fix for that specific symptom. This new result reproduces the *original* character-vs-object split (character audible, object silent) that the whole DevCycle started from, but now with `Invisible` already off. The most likely explanation, not yet confirmed: a different debug/cheat option is active that specifically mutes world-object-sourced sound (as opposed to player/character-sourced sound) — Project Zomboid's debug menu has several such toggles beyond `Invisible` (e.g. sandbox/admin "silent"-type cheats), and this project's own earlier test logs have consistently shown `BuildCheat is active`, confirming debug/cheat mode is generally in use during this testing. **Not yet checked: whether any other debug option is enabled besides the already-disabled `Invisible`.**

**Ed's direction (2026-09-14): stop chasing this line of investigation. Revert the code to the exact state that produced "both diagnostic sounds audible" (the confirmed-good result right after Phase 5's crash fix, before Phase 6 touched anything), then make changes incrementally and re-test after each one, rather than continuing to layer changes and hypotheses.** See Phase 9.

### Phase 9: Revert to the last confirmed-good state; proceed incrementally from there

**Status:** Work Complete — reverted, in-game re-verification pending

Per Ed's direction, stopped chasing the session-level-setting hypothesis (Phase 8) and reverted `ChurningMachineCode.lua` back to the exact state that last produced a confirmed-good result: **both diagnostic sounds audible**, right after Phase 5's crash fix, before any of Phase 6/7/8's changes.

- [x] Revert `ChurningMachineCode.lua` to the Phase 5 state: `onSelect(_, pObj)` crash fix kept (a real, necessary bug fix, unrelated to the audio investigation); Phase 2's two diagnostic calls (`ClothingWasherFinished` one-shot, `GetWaterFromTap` character-emitter) restored; `stopMachine` reverted to `stopOrTriggerSoundByName` (Phase 6's `soundInstances`-table/handle-based change removed); `isRunning`'s Phase 7 self-heal reconciliation removed (back to the simple `ModData.churningMachineRunning == true` check); Phase 8's redundant second diagnostic call removed (Phase 2's version covers the same test).
- [ ] Ed to re-test from this exact known-good baseline and confirm both diagnostic sounds are audible again, as a checkpoint before any further changes.
- [ ] From here, proceed incrementally: one change at a time, re-test after each, rather than layering multiple hypotheses/fixes before the next real-world result comes back.

**What was kept (not reverted) and why:** the Phase 5 `onSelect(_, pObj)` fix is a real, separately-traced, confirmed bug (the wrong argument was being bound, causing the "Object tried to call nil" crash) — unrelated to why sound is or isn't audible, and reverting it would reintroduce a crash whenever `playerObj` is used. Everything else introduced since the last confirmed-good checkpoint (Phases 6-8) has been reverted.

**Technical Notes:**

`ChurningMachineCode.lua` is now byte-for-byte the version from immediately after Phase 5's fix. `ChurningMachineCode.soundInstances` (added in Phase 6) is removed entirely, and `stopMachine`/`startMachine` no longer reference it.

### Phase 10: Incremental step 1 — remove the `GetWaterFromTap` diagnostic, keep everything else from the confirmed-good checkpoint

**Status:** Work Complete — change applied, in-game re-verification pending

**Checkpoint result confirmed by Ed:** from the Phase 9 revert, both sounds played — the `GetWaterFromTap` character-emitter sound first, then (after it finished) the `ClothingWasherFinished` object-emitter one-shot. Sequential, not simultaneous.

Per Ed's explicit direction, made exactly one incremental change from that confirmed-good baseline:

- [x] Removed the `GetWaterFromTap`/`playerObj:getEmitter()` diagnostic block from `startMachine`. Nothing else changed — the object-emitter one-shot (`ClothingWasherFinished`) and the real looped `ClothingWasherRunning` sound are untouched, and `stopMachine`/`isRunning` remain exactly as reverted in Phase 9.
- [ ] Ed to re-test and confirm the `ClothingWasherFinished` one-shot (and the looped running sound) are still audible with the water-tap sound gone.

**Technical Notes:**

`startMachine` (`ChurningMachineCode.lua:47-63`) now only calls the real `RUNNING_SOUND` loop and the one remaining diagnostic (`ClothingWasherFinished`). `playerObj` is still a parameter (needed by the call site/`onToggleOption`) but is no longer used inside `startMachine`.

### Phase 11: Confirm causation, not just correlation, before theorizing why

**Status:** Work Complete — change applied, in-game re-verification pending

**Result of Phase 10:** with `GetWaterFromTap` removed, the `ClothingWasherFinished` object-emitter sound went silent too (though the rest of the machine — including milk-to-butter conversion — worked correctly). Ed also reported a useful new detail from the Phase 9 checkpoint: the two sounds were heard **sequentially, not simultaneously** — `GetWaterFromTap` first, then `ClothingWasherFinished` after it finished — even though `ClothingWasherFinished` is the earlier line in code (`ChurningMachineCode.lua:62`, before `GetWaterFromTap` at the time, lines 65-67). Ed's hypothesis: something about triggering the character-emitter sound "activates" the sound-emitter system in a way that just calling the object-emitter sound alone doesn't.

Before investigating *why*, re-added the exact `GetWaterFromTap` call as a single-variable test — if it restores the `ClothingWasherFinished` sound, that confirms real causation (not a fluke/coincidence) and narrows the next investigation considerably.

- [x] Re-added `playerObj:getEmitter():playSound("GetWaterFromTap")` back into `startMachine`, unchanged from its earlier form, with nothing else touched.
- [ ] Ed to re-test and confirm the object-emitter sound is audible again with this one change restored.

**Technical Notes:**

If this confirms the correlation, worth noting for the next step: the mismatch between code order (object-emitter call first) and perceived audio order (character-emitter sound heard first) suggests a plausible mechanism — a freshly-created `FMODSoundEmitter` (the very first one drawn from `IsoWorld`'s `freeEmitters` pool in a session, since `getFreeEmitter()` creates a `new FMODSoundEmitter()` when the pool is empty, `zombie42_20_4/iso/IsoWorld.java:445-456`) may have some one-time startup/registration latency before its `playSound` call is actually dispatched to FMOD, and the several-second-long `GetWaterFromTap` sound may simply be providing enough elapsed real time for that latency to resolve before anything reclaims the object emitter as "empty." This is a hypothesis to test next, not yet confirmed.

### Phase 12: Ed's own doubt reframes the whole investigation — isolate the real loop from both diagnostics entirely

**Status:** Work Complete — change applied, in-game re-verification pending

**Ed's report on Phase 11:** heard the tap sound, but then "the sound continues forever," and is no longer certain whether the second sound is actually `ClothingWasherFinished` or just the tail end of `GetWaterFromTap` — the two sound similar. This is an important catch: **"continues forever" does not match either one-shot diagnostic — it matches the description of the real, looped `ClothingWasherRunning` sound**, which has been present and unconditionally called in every version of this code since Phase 5 (it was never the thing being added/removed across Phases 9-11 — only the two diagnostics were). It's entirely possible the real fix (item #1's original goal) has actually been working all along since Ed disabled `Invisible`, and every test since has just been Ed trying to pick out which of several similar-sounding, near-simultaneous sounds was which — understandably difficult by ear alone.

Rather than keep varying the diagnostics, stripped them both out entirely, leaving *only* the real `ClothingWasherRunning` loop with nothing else layered on top, to test it in complete isolation.

- [x] Removed both remaining diagnostic calls (`ClothingWasherFinished` object-emitter one-shot, `GetWaterFromTap` character-emitter one-shot) from `startMachine`. Only `emitter:playSoundLoopedImpl(RUNNING_SOUND)` remains.
- [ ] Ed to test and report: with nothing else playing, is a continuous washer-running sound audible on "Turn On"?

**Technical Notes:**

`startMachine` (`ChurningMachineCode.lua:47-57`) is now back to exactly the DevCycle 005 implementation, with no diagnostic code of any kind — the real, original, previously-believed-silent implementation, tested completely on its own for the first time in this whole troubleshooting thread.

### Phase 13: Isolate the real question cleanly — real loop + character sound, no more `ClothingWasherFinished`

**Status:** Work Complete — change applied, in-game re-verification pending

**Phase 12 result:** the bare `ClothingWasherRunning` loop alone, with no diagnostic sounds at all, was confirmed silent — ruling out the possibility that the real fix had been working all along and Ed was just misidentifying which sound was which.

Per Ed's direction, dropped `ClothingWasherFinished` from any further testing entirely (not the appropriate sound for this mod anyway, and it was the source of the "which sound is that" ambiguity in Phase 11). This directly matches the agreed plan's Step 1: test the real loop together with only `GetWaterFromTap`, isolating the actual question — does a character-emitter sound make the real object-emitter loop audible — with no other sound in the mix to confuse the result.

- [x] Added `playerObj:getEmitter():playSound("GetWaterFromTap")` back into `startMachine`, with no `ClothingWasherFinished` call present at all this time.
- [ ] Ed to test and report: with only the real loop and this one character sound, is a continuous washer-running sound now audible?

**Technical Notes:**

If confirmed audible, per the agreed plan this would confirm the "character sound primes something" mechanism, and the next step would be finding a way to reproduce that priming effect without a stray, thematically-wrong "getting water" sound permanently shipping in the mod — not yet decided how, pending this result.

### Phase 14: Test `GetWaterFromTap` completely alone — does it "never end" on its own?

**Status:** Work Complete — change applied, in-game re-verification pending

**Phase 13 result reframed the whole investigation:** Ed directly compared the sound heard in-mod against a real vanilla Clothing Washer's actual running sound, and they don't match — what's been heard as "continuing forever" since Phase 9 may just be `GetWaterFromTap` itself never stopping, not our `ClothingWasherRunning` loop at all. Combined with Phase 12's clean result (the real loop alone produced nothing), this raises real doubt that the loop has ever been confirmed audible in this DevCycle — the "both sounds audible" checkpoint (Phase 9) may have actually been one sound (`GetWaterFromTap`, non-terminating) plus a brief, separately-heard `ClothingWasherFinished` one-shot, with the real loop never actually contributing anything audible.

- [x] Removed the `emitter:playSoundLoopedImpl(RUNNING_SOUND)` call entirely from this test — `startMachine` now creates and owns the object emitter (unused) but plays nothing through it. Only `playerObj:getEmitter():playSound("GetWaterFromTap")` remains.
- [x] Ed to test and report: does `GetWaterFromTap`, played completely alone with no loop sound anywhere in the mix, still "never end"? — **Confirmed: yes, `GetWaterFromTap` continues indefinitely, completely on its own, with no `ClothingWasherRunning` loop anywhere in the mix.** This is intrinsic to that sound/call, not an artifact of combining it with this mod's own loop.

**Conclusion — two separate findings, not one:**
1. **`GetWaterFromTap` never stopping is real and reproducible in isolation**, and not caused by this mod's own code re-triggering it. Confirmed by direct code inspection (see below) that `startMachine` calls `playSound("GetWaterFromTap")` exactly once per "Turn On" — `checkRunningMachines` (the only code that runs repeatedly, every `Events.OnTick`) only ever calls `stopMachine`, never anything that could re-trigger this sound. The non-terminating behavior is therefore intrinsic to the `GetWaterFromTap` FMOD event/call itself (possibly authored as a sustained/looping event at the audio level, independent of the Java-side `playSound`-vs-`playSoundLoopedImpl` distinction, which may only govern how the returned handle is tracked, not what the underlying audio content does), not a bug in this mod's triggering logic. `mymods/PseudoSaltWell`'s own `ISFillPotFromWell.lua`/`ISFillKettleFromWell.lua` call it the exact same way with no explicit stop either — this may simply never have been noticed there because that action's own short lifecycle moves on quickly.
2. **This mod's actual target sound, `ClothingWasherRunning`, has never been confirmed audible at any point in this entire DevCycle.** Every earlier "success" (Phase 9's "both sounds audible" checkpoint) is now understood to have likely been `GetWaterFromTap` (non-terminating) plus, in that one test, a separately-heard `ClothingWasherFinished` one-shot — not the real loop. Phase 12 (loop alone, no diagnostics) already showed silence; this phase's isolation of `GetWaterFromTap` removes the last piece of ambiguity about what was actually being heard. The real fix for item #1 remains unconfirmed and unresolved.

**Technical Notes:**

`GetWaterFromTap`'s non-terminating behavior is a real, separate, interesting finding but is **not the thing this DevCycle is trying to fix** — it was only ever a diagnostic tool borrowed from `PseudoSaltWell` to test whether *any* Lua-triggered sound was audible. Continuing to use it as a diagnostic is no longer useful now that it's known to behave anomalously on its own; next steps should stop relying on it (or on human hearing at all, given how much confusion has resulted from similar-sounding one-shots) and move toward an objective, logged check of `ClothingWasherRunning`'s own state instead.

### Phase 15: Drop `GetWaterFromTap` entirely — refocus on `ClothingWasherRunning` with an objective, logged check

**Status:** Work Complete — change applied, in-game re-verification pending

Per Ed's direction, stopped investigating `GetWaterFromTap`'s own non-terminating behavior (a real but separate finding, not this DevCycle's actual goal) and refocused entirely on the real target: `ClothingWasherRunning`. Given how much confusion has resulted from judging success by ear (similar-sounding one-shots, uncertain durations, a checkpoint that turned out to be misattributed), switched to an objective, logged diagnostic instead of another listening test.

- [x] Removed the `GetWaterFromTap` call entirely from `startMachine`.
- [x] Restored `emitter:playSoundLoopedImpl(RUNNING_SOUND)` — the real, actual sound this DevCycle exists to fix.
- [x] Added a `print()` statement right after starting it, logging `emitter:isPlaying(RUNNING_SOUND)`'s actual boolean result — this asks the engine directly whether it considers the sound to be playing, removing human hearing from the loop entirely for this check.
- [x] Ed to test and paste back the exact log line. — **Result:** `isPlaying(ClothingWasherRunning) = true`. The engine confirms the sound genuinely is playing — this was never a triggering bug. The problem is that it plays with no audible output, which points at something audio-side rather than a Lua-level failure to start it.

**Technical Notes:**

This is a diagnostic, not a fix — `print()` output and the temporary log line will be removed once the real problem is understood. `emitter:isPlaying(String alias)` is a real method on `BaseSoundEmitter` (`zombie42_20_4/audio/BaseSoundEmitter.java`, alongside the `long`-handle overload). Since it logged `true`, see Phase 16 for the concrete audio-side lead this result points to.

### Phase 16: A real, concrete lead found by re-reading vanilla in full — the missing `ClothingWasherLoaded` FMOD parameter

**Status:** Work Complete — change applied, in-game re-verification pending

**Phase 15 confirmed the sound genuinely plays (`isPlaying = true`) but produces no audible output** — ruling out a Lua-side triggering failure and pointing at something in how the audio itself is configured/routed. Re-read `ClothingWasherLogic.updateSound()` (`zombie42_20_4/iso/objects/ClothingWasherLogic.java:192-207`) in full again, line by line, rather than just the lines this mod's code already mirrors:

```java
if (this.soundInstance == -1L) {
    this.getObject().emitter = IsoWorld.instance
        .getFreeEmitter(this.getObject().getXi() + 0.5F, this.getObject().getYi() + 0.5F, this.getObject().getZi());
    IsoWorld.instance.setEmitterOwner(this.getObject().emitter, this.getObject());
    this.soundInstance = this.getObject().emitter.playSoundLoopedImpl("ClothingWasherRunning");
    ItemContainer container = this.getContainer();
    boolean bHasNoisyItems = this.hasNoisyItems(container);
    this.getObject().emitter.setParameterValueByName(this.soundInstance, "ClothingWasherLoaded", bHasNoisyItems ? 1.0F : 0.0F);
```

Every line up through `playSoundLoopedImpl` has been present in this mod's code since DevCycle 005. **The final line — `setParameterValueByName(soundInstance, "ClothingWasherLoaded", ...)` — has never been included, in any version of this mod's code, in this entire DevCycle.** `BaseSoundEmitter.setParameterValueByName(long, String, float)` (`zombie42_20_4/audio/BaseSoundEmitter.java:38`) is a real, plain method. This is a concrete, evidence-backed candidate: if the `Object/ClothingWasher/Running` FMOD event routes its actual audible mix through this parameter (a plausible FMOD authoring pattern — an uninitialized parameter can leave an event instance in an undefined or zero-gain branch while still technically "playing"), never setting it would exactly explain "plays, but silent."

- [x] Captured `playSoundLoopedImpl`'s return value (`soundInstance`) again, and added `emitter:setParameterValueByName(soundInstance, "ClothingWasherLoaded", 0.0)` immediately after starting the loop — using `0.0` (vanilla's "not noisy" value) since this mod has no equivalent "noisy items" concept.
- [x] Ed to test and report whether the running sound is now audible, and check the `isPlaying` log line still reads `true`. — **Still not audible with `0.0`.** `isPlaying(ClothingWasherRunning) = true` confirmed twice (two separate "Turn On" tests in the same log). Ruled out `0.0` specifically; see Phase 17 for testing `1.0`.

**Technical Notes:**

`0.0` was chosen arbitrarily as *a* valid value to test whether setting the parameter *at all* matters, not because `0.0` is necessarily the "correct" value for this mod's use case — since it didn't change anything, `1.0` is the next value to try before concluding this parameter isn't the answer at all.

### Phase 17: Try `ClothingWasherLoaded = 1.0` — the only other value vanilla ever uses

**Status:** Work Complete — change applied, in-game re-verification pending

- [x] Changed `setParameterValueByName(soundInstance, "ClothingWasherLoaded", 0.0)` to `1.0` — the other value vanilla's own `bHasNoisyItems ? 1.0F : 0.0F` ternary can produce. Nothing else changed.
- [x] Ed to test and report whether the running sound is now audible. — **Still not audible with `1.0`.** `isPlaying(ClothingWasherRunning) = true` confirmed again. Both of the only two values vanilla ever uses for this parameter have now been tried, with no change either time.

**Technical Notes:**

`ClothingWasherLoaded` is ruled out as the cause of the silence — both `0.0` and `1.0` tried, `isPlaying` confirmed `true` throughout, no audible change either time. This parameter is not the fix.

**Where this leaves the investigation, confirmed so far across Phases 15-17:**
- The sound is genuinely playing according to the engine (`isPlaying(ClothingWasherRunning) = true`, confirmed on every single test since Phase 15) — this has never been a Lua-side triggering failure.
- The `ClothingWasherLoaded` FMOD parameter, the one concrete difference found between this mod's code and vanilla's, does not affect audibility at either of its two valid values.
- Ed has independently confirmed a real vanilla Clothing Washer's running sound *is* audible in the same game session — ruling out a session-wide settings/mute issue (e.g. `Invisible`, volume sliders) as the explanation for this specific silence.
- Position/setup code (coordinates, `setEmitterOwner`, `playSoundLoopedImpl`) matches vanilla's own `ClothingWasherLogic.updateSound()` exactly, line for line, aside from the now-ruled-out parameter call.

**Proposed next step, not yet implemented (per Ed's explicit instruction to update this document without starting a new fix):** swap only the sound name — temporarily play a different, known-good looped sound (one confirmed to use the same `playSoundLoopedImpl` method, not the different `playAmbientLoopedImpl` method `TreeAmbianceLogic` uses) through this exact same object-emitter code path. This isolates a question never yet directly tested: is looped playback from a Lua-created world-object emitter broken in general, or is something specific to the `Object/ClothingWasher/Running` FMOD event (not visible in any decompiled source available to this project) the actual cause. Awaiting Ed's go-ahead before implementing.

---

## Notes and Risks

- This cycle is scoped narrowly to item #1 only. Items #2 and #8 from `doc/ideas/PseudoChurningMachineDC11Plus.md` are related (see that document's cross-references) but explicitly out of scope — if Phase 1 concludes the sound genuinely can't be fixed without adopting #8's "convert a real washer/dryer" approach, that conclusion should be reported back for a separate decision, not acted on unilaterally in this cycle.
- DevCycle 005 already tried and ruled out the most obvious fix (matching vanilla's exact Java call pattern, including `setEmitterOwner`). This cycle needs to find a genuinely different angle, which is why Phase 1 leads with a working in-repo precedent (`mymods/PseudoSaltWell`) instead of re-deriving from vanilla Java again.
- Per this project's own tracked ambiguity, "PseudoSaltWell" refers to two different mod directories that share a similar name — this cycle's working audio example is specifically `mymods/PseudoSaltWell` (the bare-named one), **not** `PseudoSaltWell42_19`.

---

## Completion Summary

**Closed as incomplete, by Ed's direction (2026-09-14).** The Desired Outcome ("Turn On" produces an audible looped running sound) was never met — re-read line by line, this remains unmet, not deferred scope, per this project's own Completion Rules. Closing anyway because Ed explicitly asked to close it and start fresh with DevCycle 012, not because the gap was resolved or accepted as final.

**Completion Date:** 2026-09-14

**Phases Completed:** Phases 1-17 all reached "Work Complete" (research/diagnostics/reverts/incremental tests), but none of them produced the actual goal — an audible `ClothingWasherRunning` loop. Phase 5's `onSelect(_, pObj)` parameter-order bug fix is the one durable, unrelated code fix that came out of this cycle and remains in place.

**Work Deferred:** The entire original goal (audible running sound) carries forward to DevCycle 012, which starts from a different angle — grounding the next round of hypotheses in `claudeDocs/claude_washingMachineAudioAnalysis.md` (a fresh, detailed read of vanilla's own `updateSound()` mechanics) rather than continuing to vary this mod's own code by trial and error. DC11 Phase 17's own proposed-but-not-implemented next step (swap the sound name for a known-good looped sound, to isolate "any looped object-emitter playback" from "this specific FMOD event") is carried forward as DC12's starting point.

**Accomplishments:**
- Confirmed (Phase 15-17, via `isPlaying()`) that the sound is genuinely triggered and reported "playing" by the engine — this was never a Lua-side triggering failure.
- Ruled out `Invisible` debug mode (confirmed a real, if incomplete, contributing factor early on), session-wide mute/volume settings (a real vanilla washer was confirmed audible in the same session), and both values of the `ClothingWasherLoaded` FMOD parameter.
- Fixed a real, separate, pre-existing bug: `turnOnOffMenu`'s `onSelect` closure was silently binding the wrong argument (`entity` instead of `playerObj`) due to a misunderstood `addGetUpOption` calling convention — traced end-to-end through Java and Lua and fixed (Phase 5). This bug predated this DevCycle (present since DevCycle 005) and had no observable effect until this cycle's diagnostics first tried to use `playerObj`.
- Identified `GetWaterFromTap` (from `mymods/PseudoSaltWell`) as a non-terminating sound when triggered via `character:getEmitter():playSound(...)` — a real, reproducible, but out-of-scope finding that caused significant confusion across Phases 9-14 before being isolated and dropped as a diagnostic tool.

**Metrics:** 17 phases, 2 real code changes retained (the `onSelect` fix, and the still-silent `ClothingWasherLoaded` parameter call carried into the code as a faithful match to vanilla even though it didn't fix anything). Goal not met.

**Lessons / Notes:**
- Judging audio success by ear, across multiple similar-sounding one-shot diagnostics, produced real, costly confusion (Phases 9-14) — the pivot to an engine-reported, logged check (`isPlaying()`, Phase 15) was a better method and should be the default going forward, not a last resort.
- This cycle repeatedly hit a real ceiling: the FMOD event content and the concrete `FMODSoundEmitter` implementation are not present in this repo's decompiled sources, so several plausible hypotheses (baked-in attenuation, parameter routing, minimum-distance cutoffs) could not be confirmed or ruled out from code alone. DevCycle 012 should weight cheap in-game tests over further source-reading once a hypothesis reaches that ceiling, rather than continuing to re-read the same Java files.
- Incremental, single-variable changes with a re-test after each (Ed's Phase 9 direction) is the right process discipline for this kind of bug and should continue in DevCycle 012.
