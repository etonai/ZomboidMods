# Microwave Audio Analysis

**Created:** 2026-09-14
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media42_20_4/`)
**Scope:** A focused analysis of the microwave, paying special attention to how it emits audio, in the same style as [claude_washingMachineAudioAnalysis.md](claude_washingMachineAudioAnalysis.md) and [claude_generatorAudioAnalysis.md](claude_generatorAudioAnalysis.md). The microwave turns out not to be its own object at all — it's a *mode* of the shared `IsoStove` class — and its sound code layers together elements from three different patterns already seen elsewhere in this investigation, plus at least two genuinely new ones (multi-tile "sprite grid origin" gating, and a completely separate non-emitter sound API for button-press sounds).

## Code Locations

| Purpose | File |
|---|---|
| Combined stove/microwave object (temperature, timer, sound) | `zombie42_20_4/iso/objects/IsoStove.java` |
| Microwave sound event bindings | `media42_20_4/scripts/generated/sounds/objects/sounds_object_microwave.txt` |
| Stove sound event bindings (some shared with the microwave — see Part 3) | `media42_20_4/scripts/generated/sounds/objects/sounds_object_stove.txt` |
| Emitter pool / ownership API | `zombie42_20_4/iso/IsoWorld.java` (`getFreeEmitter`, `setEmitterOwner`) |
| Simple non-emitter world-sound API used for the toggle click | `zombie.SoundManager` (`SoundManager.instance.PlayWorldSound(...)`) |

## Summary — There Is No `IsoMicrowave` Class

No `IsoMicrowave.java` exists in the decompiled sources. `CellLoader.java`'s tile-object factory (`DoTileObjectCreation()`) creates a plain `IsoStove` for a tile whose `CONTAINER` property is `"microwave"` just as readily as one whose property is the stove's own value — there is exactly one Java class, `IsoStove extends IsoObject implements Activatable` (`IsoStove.java:35`), and it branches internally on `isMicrowave()`/`isStove()` (both delegating to `this.getContainer().isMicrowave()`/`isStove()`, `IsoStove.java:428-434`) almost everywhere it matters, sound included. This is worth knowing on its own: "the microwave" in vanilla is not a distinct appliance type at the code level, it's a container-type flag on a shared class.

## Part 1 — What Triggers the Sound: State-Change, Not Per-Tick (Unlike the Fireplace/Generator)

`doSound()` (`IsoStove.java:214-268`) is the single method responsible for starting/stopping the running loop and the "finished" ding for **both** stove and microwave modes. Unlike `IsoFireplace`/`IsoGenerator` (both of which re-check `isPlaying(...)` on every single `update()` tick — see the generator analysis), `doSound()` is only called from **`setActivated(boolean b)`** (`IsoStove.java:384`, and propagated to other tiles of a multi-tile sprite via `syncSpriteGridObjects()`, `IsoStove.java:485`) — i.e. only exactly when the activation state actually changes, not continuously. This is the same one-shot-trigger style `ClothingWasherLogic` uses for its own main loop (see the washing-machine audio analysis) — a third real-world example of that pattern, alongside a fourth (the stove branch specifically) that still adds a defensive one-time re-check at the trigger moment:

```java
} else if (this.isStove()) {
    if (this.Activated()) {
        if (this.emitter == null) {
            this.emitter = IsoWorld.instance.getFreeEmitter(this.getX() + 0.5F, this.getY() + 0.5F, this.getZ());
            IsoWorld.instance.setEmitterOwner(this.emitter, this);
            this.soundInstance = this.emitter.playSoundLoopedImpl("StoveRunning");
        } else if (!this.emitter.isPlaying("StoveRunning")) {
            this.soundInstance = this.emitter.playSoundLoopedImpl("StoveRunning");
        }
    ...
```

The stove branch checks `!isPlaying("StoveRunning")` even when an emitter already exists — but only at the moment `doSound()` runs (on activation), not on every tick the way the fireplace/generator do. The microwave branch (below) doesn't even do that much — it unconditionally acquires a **fresh** emitter and starts a fresh loop every time it's turned on, after first stopping whatever the old one was playing.

## Part 2 — Starting the Microwave's Loop, and the "Cooking Metal" Branch

```java
if (this.isMicrowave()) {
    if (this.activated) {
        if (this.emitter != null) {
            if (this.soundInstance != -1L) {
                this.emitter.stopSound(this.soundInstance);
            }
            this.emitter.stopSoundByName("StoveTimer");
        }
        this.emitter = IsoWorld.instance.getFreeEmitter(this.getX() + 0.5F, this.getY() + 0.5F, PZMath.fastfloor(this.getZ()));
        IsoWorld.instance.setEmitterOwner(this.emitter, this);
        if (this.hasMetal()) {
            this.soundInstance = this.emitter.playSoundLoopedImpl("MicrowaveCookingMetal");
        } else {
            this.soundInstance = this.emitter.playSoundLoopedImpl("MicrowaveRunning");
        }
    } else if (this.soundInstance != -1L) {
        ...
```

- **Ownership pattern is the washer/fireplace style** (`setEmitterOwner`, `playSoundLoopedImpl`), not the generator's `takeOwnershipOfEmitter`/`playSoundImpl` style — the emitter stays in `IsoWorld`'s automatically-ticked pool. Across all four objects examined in this investigation (washer, fireplace, generator, now stove/microwave), the generator is the only one that manages its emitter's ticking manually; everything else relies on the engine's automatic per-frame tick.
- **A genuinely new detail: which sound loops depends on container contents, checked fresh at turn-on time.** `hasMetal()` (`IsoStove.java:270-287`) scans every item currently in the microwave's container for `item.getMetalValue() > 0.0F` or `item.hasTag(ItemTag.HAS_METAL)`, and if any is found, loops **`MicrowaveCookingMetal`** (`Object/Microwave/RunningMetal`) instead of the normal **`MicrowaveRunning`** (`Object/Microwave/Running`) — a distinct, presumably more alarming/sparking sound for the classic "don't put metal in the microwave" scenario. This check only runs once, at the moment the microwave is switched on — adding a metal item mid-cook wouldn't retroactively swap the sound, since nothing re-evaluates `hasMetal()` while already running (the per-tick `update()` loop only uses the cached `this.hasMetal` field for the *fire-hazard* mechanic, not to re-trigger `doSound()` — see Part 4).
- **Always a fresh emitter, not reused.** Every time the microwave is turned on, `this.emitter` is unconditionally reassigned to a brand-new `getFreeEmitter(...)` call, after first stopping the old emitter's tracked instance and its named `"StoveTimer"` sound. This is a third variation on emitter reuse across this investigation: the washer/fireplace only acquire a new emitter if they don't already have a live one (`soundInstance == -1L` / lazy `emitter == null` checks); the microwave branch never bothers to check `this.emitter == null` at all before replacing it.
- **Turning it off plays a "finished" ding through a *different*, disposable emitter — not the object's own `this.emitter`:**

```java
} else if (this.soundInstance != -1L) {
    if (this.emitter != null) {
        this.emitter.stopSound(this.soundInstance);
        this.emitter.stopSoundByName("StoveTimer");
        this.emitter = null;
    }
    this.soundInstance = -1L;
    if (this.container != null && this.container.isPowered()) {
        BaseSoundEmitter emitter = IsoWorld.instance.getFreeEmitter(this.getX() + 0.5F, this.getY() + 0.5F, PZMath.fastfloor(this.getZ()));
        emitter.playSoundImpl("MicrowaveTimerExpired", this);
    }
}
```

`this.emitter` is stopped and discarded (`= null`) first, and the `"MicrowaveTimerExpired"` (`Object/Microwave/Finished`) one-shot ding is played on a **separate, local, throwaway emitter** acquired fresh from the pool and never stored anywhere — a "fire and forget" one-shot pattern not seen in the washer, fireplace, or generator, all of which reuse their own persistent `this.emitter` for one-shots too. It also only plays at all if the container is still powered — turning off the microwave because power was lost produces no ding.

## Part 3 — The Ticking Countdown: a Second, Independently-Managed Sound Sharing the Stove's Name

Separately from the main Running/CookingMetal loop, there's a ticking "timer" sound while the countdown is active, maintained with the same per-tick self-healing pattern the fireplace/generator use for their *main* loop — except here it's layered on top of an already-running main loop, for a secondary sound:

```java
if (this.isSpriteGridOriginObject() && this.emitter != null) {
    if (this.Activated() && this.secondsTimer > 0) {
        if (!this.emitter.isPlaying("StoveTimer")) {
            this.emitter.playSoundImpl("StoveTimer", this);
        }
    } else if (this.emitter.isPlaying("StoveTimer")) {
        this.emitter.stopSoundByName("StoveTimer");
    }
}
```

This runs in `update()`, every tick, for **both** stove and microwave modes alike. Two things worth flagging:

- **The microwave has no `MicrowaveTimer`/`MicrowaveTimerTick` sound of its own** — it uses the literal same `"StoveTimer"` alias (`Object/Stove/Timer`) as the stove does, per `sounds_object_stove.txt:30-37`. `sounds_object_microwave.txt` only ever defines three sounds total (`MicrowaveRunning`, `MicrowaveCookingMetal`, `MicrowaveTimerExpired`) — the ticking countdown is deliberately shared, not duplicated, across both appliance modes.
- **Managed by name (`stopSoundByName`/`isPlaying(name)`), not by a tracked instance handle** — unlike the main loop, which tracks `this.soundInstance` (a `long` handle) precisely so it can be stopped exactly, the ticking sound is only ever referred to by its string alias. Both sounds coexist simultaneously on the **same** `this.emitter` — direct, in-source confirmation that one emitter can carry more than one concurrently-playing named sound at once, addressed independently (stop one without touching the other).

## Part 4 — Multi-Tile Sprites: Only the "Origin" Tile Owns Sound

`isSpriteGridOriginObject()` (`IsoStove.java:456-470`) checks whether this particular `IsoStove` instance is at grid position `(0,0)` of a multi-tile `IsoSpriteGrid` (large stoves/microwave setups can visually span more than one tile). Sound code checks this before doing anything (`doSound()`'s outer `else if (this.isSpriteGridOriginObject())` branch, and the ticking-timer check in `update()`) — **only the origin tile of a multi-tile object ever touches an emitter**, preventing every tile of the same physical appliance from independently playing its own copy of the same sound. `syncSpriteGridObjects(...)` (`IsoStove.java:472-...`) is what propagates activation/temperature/timer state to the other, non-origin tiles of the same grid and calls `doSound()` on each of them too — but since only the origin tile's `isSpriteGridOriginObject()` check passes, the non-origin calls are effectively no-ops for sound purposes. This is a genuinely new consideration not present in any single-tile object examined so far in this investigation (washer, fireplace, generator all appear to be single-tile).

## Part 5 — The Toggle Click: a Completely Different, Non-Emitter Sound API

```java
public void PlayToggleSound() {
    SoundManager.instance.PlayWorldSound(this.isMicrowave() ? "ToggleMicrowave" : "ToggleStove", this.getSquare(), 1.0F, 1.0F, 1.0F, false);
}
```

This is not the `BaseSoundEmitter`-based approach used everywhere else in this investigation at all — `SoundManager.instance.PlayWorldSound(...)` is a simpler, direct world-sound API taking the alias name and an `IsoGridSquare` position, with no emitter object involved, no ownership tracking, and no instance handle to stop later (it's a short, fire-once button-click sound with nothing to manage afterward). This is the first example in this investigation of that alternate, simpler API — worth remembering as a genuinely different, lower-ceremony way vanilla sometimes plays a positioned one-shot sound. `ToggleStove` resolves to `Object/Stove/Toggle` (`sounds_object_stove.txt:3-10`); **`ToggleMicrowave` was not found defined in any sound script in this repo** — its resolution couldn't be confirmed in this pass (possibly it falls through to a default/missing-sound handler, or is defined in compiled-only data not present here).

## Part 6 — The Metal Fire Hazard, and Why Sound Gets Force-Stopped Mid-Cook

```java
boolean canStartFire = GameServer.server || !GameClient.client;
if (canStartFire && this.Activated() && this.hasMetal && Rand.Next(Rand.AdjustForFramerate(200)) == Rand.AdjustForFramerate(100)) {
    this.secondsTimer = -1;
    if (this.emitter != null && this.soundInstance != -1L) {
        this.emitter.stopSound(this.soundInstance);
        this.soundInstance = -1L;
    }
    this.Toggle();
    this.setBroken(true);
    IsoFireManager.StartFire(this.container.sourceGrid.getCell(), this.container.sourceGrid, true, 10000);
}
```

Checked every `update()` tick while cooking metal: a random chance (using framerate-adjusted `Rand.Next`, evaluated server-side or on any non-networked-client instance) directly and explicitly stops the tracked `soundInstance` on the spot — **before** calling `Toggle()` (which would otherwise go through `setActivated`→`doSound()` and handle the stop/ding logic itself) — then sets the appliance broken and starts a real fire. This is a narrative-danger mechanic in the same spirit as the generator's condition-based backfire/fire/explosion chances (see the generator analysis), but implemented as a direct, immediate emitter stop rather than routing through the normal on/off sound machinery, presumably because the appliance is about to be forcibly deactivated and marked broken in the same breath, and the normal path's metal-check-driven sound selection would be moot anyway.

## Comparison Update — Four Vanilla Objects, at Least Five Sound-Management Variations

Extending the table from the generator analysis:

| | `ClothingWasherLogic` | `IsoFireplace` | `IsoGenerator` | `IsoStove` (microwave mode) |
|---|---|---|---|---|
| Emitter ownership | `setEmitterOwner` | `setEmitterOwner` | `takeOwnershipOfEmitter` | `setEmitterOwner` |
| Loop start method | `playSoundLoopedImpl` | `playSoundLoopedImpl` | `playSoundImpl` | `playSoundLoopedImpl` |
| Re-arm trigger | One-time, on state change (`soundInstance == -1L` gate) | Every tick (`!isPlaying`) | Every tick (`!isPlaying`) | **One-time, on state change** — no per-tick re-check for the main loop at all |
| Reuses existing emitter? | Yes, if live | Yes, if live | Yes, if live | **No — always acquires a fresh emitter on every turn-on** |
| One-shot "finished" sound | Same persistent emitter | *(not examined)* | Same persistent emitter | **A separate, disposable, never-stored emitter** |
| Secondary concurrent sound on the same emitter | None | None | None | **Yes — a by-name-only ticking countdown, independent of the tracked main-loop instance** |
| Button/UI sound | *(not examined)* | *(not examined)* | *(not examined)* | **A completely different, non-emitter API** (`SoundManager.PlayWorldSound`) |
| Multi-tile awareness | N/A (single-tile) | N/A (single-tile) | N/A (single-tile) | **Yes — only the sprite-grid origin tile touches sound** |

## Caveats / Uncertainties

- `ToggleMicrowave` could not be found defined in any sound script in this repo — its actual resolution (a real event, a fallback, or silently missing) is unconfirmed.
- As with every other object in this investigation, the actual FMOD event content (`Object/Microwave/Running`, `RunningMetal`, `Finished`, etc.) and the concrete `BaseSoundEmitter`/`FMODSoundEmitter` implementation are not present in this repo's decompiled sources.
- `SoundManager.PlayWorldSound`'s own implementation (arguments beyond the obvious position/volume ones, e.g. the trailing `false` boolean) was not traced in this pass — only its call site and the fact that it's a distinct API from the emitter-based approach were confirmed.
- Whether non-origin tiles of a multi-tile stove/microwave sprite grid have their own `this.emitter` field that simply never gets used, or never acquire one at all, wasn't traced further — `isSpriteGridOriginObject()`'s check happens before any emitter access, so it doesn't matter functionally, but the exact reason wasn't confirmed.
