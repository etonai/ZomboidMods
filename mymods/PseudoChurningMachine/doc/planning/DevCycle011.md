# DevCycle 011: Fix Silent "Turn On" Audio

**Status:** Planning
**Start Date:** 2026-09-13
**Target Completion:** TBD
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
- [ ] Have Ed run both diagnostic calls in-game (via `utilities\CopyModToZomboid.bat PseudoChurningMachine`) and report which, if either, is actually audible.
- [ ] Based on the result, identify the real fix direction for Phase 3: if the object-emitter one-shot is audible, the bug is specific to looped playback; if only the character-emitter version is audible, the bug is specific to world-object emitters and the fix needs a different mechanism entirely (e.g. periodic one-shots from a character/positional source, or another approach not yet identified); if neither is audible, the sound event or a session-level setting is implicated and needs separate investigation.
- [ ] Remove the diagnostic code once the result is captured — it does not belong in the final fix.

**Technical Notes:**

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

---

## Notes and Risks

- This cycle is scoped narrowly to item #1 only. Items #2 and #8 from `doc/ideas/PseudoChurningMachineDC11Plus.md` are related (see that document's cross-references) but explicitly out of scope — if Phase 1 concludes the sound genuinely can't be fixed without adopting #8's "convert a real washer/dryer" approach, that conclusion should be reported back for a separate decision, not acted on unilaterally in this cycle.
- DevCycle 005 already tried and ruled out the most obvious fix (matching vanilla's exact Java call pattern, including `setEmitterOwner`). This cycle needs to find a genuinely different angle, which is why Phase 1 leads with a working in-repo precedent (`mymods/PseudoSaltWell`) instead of re-deriving from vanilla Java again.
- Per this project's own tracked ambiguity, "PseudoSaltWell" refers to two different mod directories that share a similar name — this cycle's working audio example is specifically `mymods/PseudoSaltWell` (the bare-named one), **not** `PseudoSaltWell42_19`.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
