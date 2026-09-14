# DevCycle 012: Fresh Look at Silent Running Audio — Is the Object Model Itself the Problem?

**Status:** Closed — Incomplete
**Start Date:** 2026-09-14
**Target Completion:** TBD
**Closed Date:** 2026-09-14

---

## Goal

Take a genuinely fresh angle on the still-unresolved problem from DevCycle 011: the Churning Machine produces no audible sound while running, even though the engine confirms (`isPlaying()`) that `ClothingWasherRunning` is actually triggered on the emitter. DevCycle 011 spent 17 phases treating the Churning Machine as if it were a hard-coded `IsoClothingWasher`-style object and mimicking `ClothingWasherLogic`'s Java code from Lua, without success. This cycle does not treat that framing, or any of DC11's specific next-step proposals, as a good starting point just because DC11 arrived at them — it starts over from what kind of object the Churning Machine actually is and how vanilla sound-capable workstations of that same kind actually work.

## Desired Outcome

- Selecting "Turn On" on a Churning Machine with milk in it produces an audible looped running sound, confirmed by ear (not just `isPlaying() == true`, which DC11 already established is insufficient evidence of audibility on its own).
- The sound continues for the duration of the cycle and stops when the machine stops (Turn Off or natural completion) — the on/off *logic* already works (DC005/006 built it, DC011 confirmed transitions are correct); only audibility remains unproven.
- No other Churning Machine behavior changes — milk gate, milk removal on completion (DC006), butter generation (DC007), and the 10-minute cycle duration (DC010) stay exactly as they are.
- If this cycle concludes the current scripted-entity approach cannot be made audible at all, that is a valid outcome to report back for a separate decision — not a license to unilaterally adopt DC11+'s item #8 ("convert a real washer/dryer") in this cycle.

---

## Tasks

### Phase 1: Research — what kind of object is the Churning Machine, actually, and how do real objects of that kind handle sound?

**Status:** Work Complete

DC11 never questioned whether the Churning Machine (a scripted `entity`, defined in `entity_ChurningMachine.txt` via the `component`-based entity system — `UiConfig`, `ContextMenuConfig`, `FluidContainer`, `SpriteConfig`, `CraftRecipe`) is even the same *kind* of object as `IsoClothingWasher`, the hard-coded Java class every single phase of DC11 tried to imitate. It isn't, and that mismatch is a real, previously unexamined candidate explanation.

- [x] **Confirmed a real class-hierarchy mismatch.** `zombie.entity.GameEntity` (`zombie42_20_4/entity/GameEntity.java:49`, the Lua-exposed class backing this mod's `entity`, per `LuaManager.java:1883` — `setExposed(GameEntity.class)`) is a standalone `public abstract class GameEntity` with its own `getSquare()`/`getComponent()` API — it does **not** extend `zombie.iso.IsoObject`. Every sound mechanism DC11 copied from — `ClothingWasherLogic`, `IsoFireplace.updateSound()` — is written against `IsoObject`, and `IsoWorld.setEmitterOwner(BaseSoundEmitter, IsoObject)` (`IsoWorld.java:468`) only accepts an `IsoObject`. This mod's code calls `IsoWorld.instance:setEmitterOwner(emitter, entity)` passing a `GameEntity` where Java expects an `IsoObject` — a type this object was never designed to be. Not yet confirmed exactly what Kahlua does when this type mismatch occurs (silently no-op, since `setEmitterOwner`'s body is `if (emitter != null && object != null) { ... }` — no exception is thrown from the visible Java code itself if `object` comes through as something unexpected; or Kahlua's own dispatch layer could behave some other way not traceable from this repo's sources). No error has ever been observed at this call site in any DC11 test, which itself needs explaining rather than assumed harmless.
- [x] **Confirmed the entity-component system has its own dedicated sound mechanism, and this mod uses none of it.** `CraftBenchSounds` (`zombie42_20_4/entity/components/sounds/CraftBenchSounds.java`, `CraftBenchSound.java`) is a script-declared component: real vanilla entities (Drying Rack, Leather Prep, Cooking Pit — see e.g. `media42_20_4/scripts/generated/entities/agricultural/workstations/entity_Drying_Rack.txt:492-497`) declare `component CraftBenchSounds { AddInput = ..., RemoveInput = ..., StartCraft = ... }`, queried via `entity:getComponent(ComponentType.CraftBenchSounds):getSoundName(id, param1)`. `entity_ChurningMachine.txt` has no such component, and `ChurningMachineCode.lua` never calls `getComponent(ComponentType.CraftBenchSounds)` — the mod's sound code has always bypassed the entity system's own sound hookup entirely in favor of reimplementing `IsoObject`'s mechanism from scratch.
- [x] **Confirmed that hookup doesn't cover this use case anyway.** Every real usage of `CraftBenchSounds` found (`ISGenericCraftStart.lua:19-27`, `ISItemSlotAddAction.lua`, `ISItemSlotRemoveAction.lua`) plays its sound through `self.character:playSound(soundName)` — a one-shot, player-character-emitter sound tied to a player-performed timed action (starting a craft, adding/removing an item) — never a continuous ambient loop tied to the workstation itself for the duration of unattended processing. `CraftLogicSystem.java` (the actual passive bench-tick engine driving both the vanilla Butter Churn's `churn_butter` recipe and, by the same mechanism, this mod's milk-to-butter conversion) contains **no** sound-related code at all. The only vanilla objects with a continuous "Running" loop are `ClothingWasherLogic`/`ClothingDryerLogic` and `IsoFireplace` — all three are hard-coded `IsoObject` subclasses with a native Java `update()` override ticking every frame, which a `GameEntity` has no equivalent of. **There is no found vanilla precedent for a scripted, component-based entity maintaining a continuous ambient sound loop for an unattended process — the thing this mod is trying to do may be unprecedented, not just miscopied.**
- [x] **Found a materially different, more defensive vanilla pattern than the one DC11 fixated on.** `IsoFireplace.updateSound()` (`zombie42_20_4/iso/objects/IsoFireplace.java:335-354`) — also `IsoObject`-based, but closer in spirit to a workstation than the Washer — re-checks every tick with `if (!this.emitter.isPlaying(soundName)) { this.soundInstance = this.emitter.playSoundLoopedImpl(soundName); }`. This is a **self-healing, ask-the-engine-fresh-every-time** pattern, distinct from `ClothingWasherLogic`'s one-time `soundInstance == -1L` gate that every phase of DC11 copied. It assumes nothing about the loop staying alive on its own and just keeps re-asserting it. Notably, `IsoFireplace` *also* consults `CraftBenchSounds.getSoundName("Running", null)` first (falling back to a hardcoded `"FireplaceRunning"` if absent) — i.e. even a legacy `IsoObject` that participates in the entity/craft-bench system checks that component for a running-sound override, which is at least suggestive that `"Running"` as an id is a real, if lightly-used, convention in this component system, even though no entity script in this codebase was found declaring it.
- [x] Re-confirmed (no new information beyond what DC11 already found): the `category = Object` vs `category = Player` sound-script distinction, and the fact that the FMOD event content and `FMODSoundEmitter`'s real implementation aren't in this repo's decompiled sources. Not re-investigating either — DC11 already established these are dead ends / unresolvable from source.

**Bottom line for Phase 2:** the strongest fresh, evidence-backed hypothesis is that a `GameEntity`-backed object has no native per-tick hook analogous to `IsoObject.update()`, so nothing is actually maintaining the emitter/loop the way vanilla's Java code does for every object that has one — and this mod's `startMachine` only ever sets the loop up once. Whether or not `setEmitterOwner`'s type mismatch matters on its own, the complete absence of any Lua-side equivalent of `IsoFireplace`'s per-tick `isPlaying(name)` re-check-and-retrigger is a concrete, testable gap this mod's code has never had.

### Phase 2: Diagnostic — does the loop actually survive, and does ownership registration matter?

**Status:** Work Complete — result: hypothesis refuted

- [x] Add a repeated (not one-shot), engine-reported diagnostic: log `emitter:isPlaying(RUNNING_SOUND)` on a timer (e.g. every few seconds via `Events.OnTick`, not just once immediately after `startMachine`, which is all DC11 Phase 15 ever checked) for the full duration of a running cycle. If it ever flips to `false` before "Turn Off"/natural completion, the loop is dying silently mid-cycle — direct evidence for the "nothing re-arms it" hypothesis.
- [x] Ed ran a cycle and reported the log output: **`isPlaying(ClothingWasherRunning) = true` on all 8 checks logged (roughly 40 seconds of coverage, spaced 5s apart, ending only when the game session itself exited — not a machine stop)**. It never once read `false`. Ed heard nothing from the machine the whole time.
- [ ] Separately (single-variable, one change at a time): try dropping the `IsoWorld.instance:setEmitterOwner(emitter, entity)` call entirely for one test — **deliberately not done yet**; held in reserve for Phase 4 if Phase 3's result doesn't already answer the ownership-registration question (see Phase 4).
- [ ] Remove diagnostic code once the investigation concludes — do not let temporary code accumulate across phases the way DC011's did.

**Technical Notes:**

Implemented in `ChurningMachineCode.lua`:
- `ChurningMachineCode.lastSoundCheckMs` (new table, keyed by `machineKey`) tracks when each running machine's sound state was last logged.
- `checkRunningMachines` (already running every `Events.OnTick`) now also logs `isPlaying(RUNNING_SOUND)` for each active machine, throttled to once per `SOUND_CHECK_INTERVAL_MS` (5000ms) so it doesn't spam every tick. The first check fires on the tick immediately after `startMachine` runs (matching DC011 Phase 15's original immediate check), then repeats every 5 seconds for as long as the machine is in `ChurningMachineCode.active`.
- `startMachine`'s old DC011 Phase 15 one-shot `print` (checked once, immediately after starting) was removed — the new repeated check in `checkRunningMachines` subsumes it (its first tick covers the same "immediately after start" case) and adds the ongoing checks DC11 never had.
- `lastSoundCheckMs[key]` is cleared in `stopMachine` (covers both manual "Turn Off" and natural completion) and reset in `startMachine`, so a machine's next run starts its own fresh throttle window.
- The `setEmitterOwner` removal test (this phase's second bullet) has deliberately **not** been implemented yet — it's a separate single-variable change to try after seeing this diagnostic's result, not before.

### Phase 3 (superseded): Self-healing, per-tick re-arm — modeled on `IsoFireplace`

**Status:** Not Applicable — ruled out by Phase 2's own evidence

This phase's own contingency plan said: *"If Phase 2 shows the loop genuinely never drops ... and this alone doesn't explain the silence, treat that as evidence against this hypothesis rather than implementing a fix for a problem that isn't happening."* Phase 2's result is exactly that case — `isPlaying()` never dropped, across 8 checks and ~40 seconds. A self-healing re-arm would have nothing to re-arm; implementing it now would not change anything observable. Left in the document, marked Not Applicable, rather than deleted, so the reasoning trail stays visible.

### Phase 4: Isolate "this specific sound" from "any looped object-emitter sound from this `GameEntity`"

**Status:** Planning

Phase 2's result rules out "the loop silently dies mid-cycle" but doesn't explain why a sound the engine insists is playing produces no audio. The remaining fresh, unexplored angle from Phase 1 is the `GameEntity`-vs-`IsoObject` type mismatch at `setEmitterOwner(emitter, entity)` — this mod's `entity` is a `GameEntity`, but every piece of vanilla code this mechanism was copied from expects a real `IsoObject`. This phase tests that directly rather than theorizing further from source.

- [ ] Temporarily swap `RUNNING_SOUND` from `"ClothingWasherRunning"` to a different, known-good sound that is also `Object`-category and played via `playSoundLoopedImpl` — through the exact same code path (same `getFreeEmitter`/`setEmitterOwner`/emitter, same `GameEntity`). Nothing else in `startMachine`/`stopMachine` changes.
- [ ] Ed to test and report: is the substitute sound audible?
  - **If audible:** the problem is specific to the `ClothingWasherRunning` / `Object/ClothingWasher/Running` FMOD event itself (e.g. some baked-in routing/attenuation quirk in that particular event) — not the object-emitter mechanism in general. Next step would be trying yet another substitute or reconsidering the event choice, not the ownership/type-mismatch angle below.
  - **If also silent:** no looped sound is audible through a `GameEntity`-owned object emitter at all, which points at the `GameEntity`/`IsoObject` type mismatch as the real root cause — `isPlaying()` reflects FMOD's own internal bookkeeping for the channel, but the channel may never be properly attached to a real, positioned emitter the way it would be for an actual `IsoObject`, because `setEmitterOwner` was never designed to accept what it's being given.
- [ ] Only if that result doesn't already answer it, single-variable next step: drop `setEmitterOwner` entirely (from Phase 2's held-in-reserve bullet) and re-test, to probe directly whether ownership registration is doing anything for this object type.
- [ ] Remove the substitute-sound diagnostic once the result is captured.

**Technical Notes:**

### Phase 5: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Select "Turn On" with milk in the container and confirm the running sound is audible by ear.
- [ ] Confirm the sound continues for the duration of a cycle and stops correctly on both manual "Turn Off" and natural completion.
- [ ] Confirm DC006 (milk removal on completion), DC007 (butter generation), and DC010 (10-minute cycle duration) are unaffected.
- [ ] Confirm all temporary diagnostic code from Phases 1-4 has been fully removed.

**Technical Notes:**

---

## Notes and Risks

- This cycle does not treat DC011's conclusions, or its own proposed next step (swapping in a substitute known-good sound), as presumptively good ideas — DC011 is closed as incomplete precisely because 17 phases of that reasoning never found the fix. Phase 1's research here started over from the object model itself rather than extending DC11's framing.
- This cycle does still avoid blindly re-testing what DC011 established with real in-game evidence (not just reasoning): `Invisible` debug mode, session-wide mute/volume settings, manual emitter ticking, and both values of the `ClothingWasherLoaded` parameter were all ruled out by actual observed test results, not assumption — there's a difference between "don't inherit DC11's untested ideas" and "ignore DC11's confirmed findings."
- Phase 2's evidence ruled out the self-healing re-arm hypothesis (old Phase 3) before it was ever implemented — `isPlaying()` never dropped. Phase 4's substitute-sound test was chosen next because it directly distinguishes the two remaining live hypotheses (event-specific problem vs. `GameEntity`/`IsoObject` mismatch) rather than guessing at either one first.
- Item #2 (Wash Menu / reclassification) and item #8 (converting a real washer/dryer) from `doc/ideas/PseudoChurningMachineDC11Plus.md` remain out of scope, same as DC011 — if this cycle concludes the sound genuinely can't be fixed within the current scripted-entity approach, report that back for a separate decision rather than acting on it here.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

**Closed as incomplete, by Ed's direction (2026-09-14).** The Desired Outcome (audible running sound from the current `GameEntity`-based Churning Machine) was never met. Closing because the diagnostic evidence, combined with how much time the audio bug has now consumed across DC11 and DC12, points toward a different, bigger-scope fix (converting the machine to reuse a real vanilla washer/dryer object, per `doc/ideas/PseudoChurningMachineDC11Plus.md` item #8) rather than continuing to debug within the scripted-entity approach — that's a new DevCycle (DC13), not a continuation of this one.

**Completion Date:** 2026-09-14

**Phases Completed:** Phase 1 (research) and Phase 2 (diagnostic) both reached Work Complete with real, evidence-backed results. Phase 3 (self-healing re-arm) was marked Not Applicable once Phase 2's evidence ruled out its premise before it was ever built. Phases 4 (substitute-sound isolation test) and 5 (verification) were never started.

**Work Deferred:** The entire original goal (audible running sound from the scripted `entity`) is not carried forward as-is — DC13 pivots to a different architecture (a real `IsoObject`-backed washer/dryer, per idea #8) rather than continuing to chase audibility within the `GameEntity` approach. Phase 4's substitute-sound test remains a valid diagnostic if DC13's new direction is ever abandoned and this approach is revisited, but is not scheduled.

**Accomplishments:**
- Found and confirmed a real, previously unexamined class-hierarchy mismatch: this mod's `entity` is a `zombie.entity.GameEntity`, while every vanilla sound mechanism DC11 copied from (`ClothingWasherLogic`, `IsoFireplace`, and `IsoWorld.setEmitterOwner`'s own parameter type) is written against the unrelated `zombie.iso.IsoObject`.
- Found that the entity-component system's own dedicated sound mechanism (`CraftBenchSounds`) only supports one-shot, player-triggered sounds (via `character:playSound(...)`) and is never used by any vanilla entity for a continuous ambient loop — meaning there may be no working vanilla precedent at all for what this mod was attempting.
- Ran a continuous (not one-shot) `isPlaying()` diagnostic across a real test cycle: the engine reported the sound as playing on every one of 8 checks (~40 seconds), yet nothing was audible — ruling out "the emitter silently drops mid-cycle" as the explanation, and by extension ruling out a self-healing per-tick re-arm (modeled on `IsoFireplace`) as a fix, without having to build it first to find that out.
- A separate copy of the mod, `mymods/PseudoChurningGameEntity`, was created by Ed to prototype further; reviewed it and flagged (and documented in its own README) that it currently shares internal names (entity, xuiSkin, Lua globals) with `PseudoChurningMachine` and can't run alongside it yet without renaming.

**Metrics:** 2 of 5 planned phases completed with real results; 1 phase avoided entirely (self-healing re-arm) because the diagnostic evidence showed it wouldn't have helped — a good outcome for the process, even though the cycle's own goal wasn't met.

**Lessons / Notes:**
- The single most valuable result of this cycle was negative evidence obtained cheaply (a logging diagnostic) that prevented building a fix (Phase 3) for a problem that wasn't actually occurring. Preferring engine-reported checks over by-ear judgment, and testing hypotheses before implementing fixes for them, both paid off directly here.
- Re-deriving the problem from the object model itself (rather than extending DC11's IsoObject-centric framing) surfaced the `GameEntity`/`IsoObject` mismatch — a genuinely new, well-grounded lead DC11 never found in 17 phases of staying within that framing. This validates the "fresh look" instruction that opened this cycle: re-research, don't just extend the prior cycle's assumptions.
- `doc/ideas/PseudoChurningMachineDC11Plus.md` item #8 had already anticipated, before this cycle even started, that a class-hierarchy/architecture mismatch might make the running sound "moot rather than fixed" by any in-place Lua change — this cycle's independent research arrived at the same conclusion from source, which is a useful cross-check that the idea document's original reasoning holds up.
