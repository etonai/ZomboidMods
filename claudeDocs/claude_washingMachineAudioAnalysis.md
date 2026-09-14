# Washing Machine Audio Analysis

**Created:** 2026-09-14
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media42_20_4/`)
**Scope:** Follow-up to [claude_washingMachineAnalysis.md](claude_washingMachineAnalysis.md), digging specifically into how `ClothingWasherLogic` produces the "machine running" audio — what plays, when, through which emitter, and how it interacts with the in-world zombie/animal sound-propagation system. The dryer (`ClothingDryerLogic`) uses the identical mechanism minus one feature (noted below), so it's covered by comparison rather than a full separate pass.

## Code Locations

| Purpose | File |
|---|---|
| Washer running/finished sound logic | `zombie42_20_4/iso/objects/ClothingWasherLogic.java` (`updateSound()`, lines 192-223) |
| Dryer running/finished sound logic (near-identical, no load-noise check) | `zombie42_20_4/iso/objects/ClothingDryerLogic.java` (`updateSound()`, lines 130-157) |
| Emitter allocation/ownership | `zombie42_20_4/iso/IsoWorld.java` (`getFreeEmitter(x,y,z)` line 458, `setEmitterOwner()` line 468) |
| Emitter interface (abstract — actual playback is in the FMOD-backed implementation, not present in this decompile) | `zombie42_20_4/audio/BaseSoundEmitter.java` |
| Gameplay sound-radius / zombie & animal attraction | `zombie42_20_4/WorldSoundManager.java` (`addSoundRepeating(...)` overloads, `addSound(...)` core, lines 84-226) |
| FMOD event bindings (script → sound-bank event names) | `media42_20_4/scripts/generated/sounds/objects/sounds_object_clothingwasher.txt` |

## Two Separate Audio Systems at Play

The washer's "running" sound is actually **two independent systems** that both get driven from the same `updateSound()` call each tick. It's easy to conflate them, but they serve different purposes and one of them isn't even audio in the traditional sense:

1. **The FMOD emitter** (`this.getObject().emitter`) — this is what the player actually *hears*: a positioned, looping sound source attached to the washer's world tile.
2. **`WorldSoundManager.addSoundRepeating(...)`** — this is the **gameplay sound-radius system**, the same one used for gunshots, car alarms, and footsteps. It doesn't play any audio itself; it registers a "loud point" in the world that zombies/animals can hear and path toward, and that the sandbox `hearing` option scales.

A washer can theoretically have one without the other in edge cases (e.g. `Core.soundDisabled` swaps in a `DummySoundEmitter` that plays nothing, but the world-sound registration still runs every tick since it's gated on `!GameClient.client`, not on sound being enabled).

## Part 1 — The FMOD Emitter (what you hear)

`ClothingWasherLogic.updateSound()` (lines 192-223) is called from `update()` on every tick the object exists (line 64), not gated behind the once-per-minute logic that drives the wash formulas — so sound state is checked/maintained far more frequently than the gameplay math.

### Starting the loop

```java
if (this.isActivated()) {
    if (!GameServer.server) {
        if (this.getObject().emitter != null && this.getObject().emitter.isPlaying("ClothingWasherFinished")) {
            this.getObject().emitter.stopOrTriggerSoundByName("ClothingWasherFinished");
        }

        if (this.soundInstance == -1L) {
            this.getObject().emitter = IsoWorld.instance
                .getFreeEmitter(this.getObject().getXi() + 0.5F, this.getObject().getYi() + 0.5F, this.getObject().getZi());
            IsoWorld.instance.setEmitterOwner(this.getObject().emitter, this.getObject());
            this.soundInstance = this.getObject().emitter.playSoundLoopedImpl("ClothingWasherRunning");
            ItemContainer container = this.getContainer();
            boolean bHasNoisyItems = this.hasNoisyItems(container);
            this.getObject().emitter.setParameterValueByName(this.soundInstance, "ClothingWasherLoaded", bHasNoisyItems ? 1.0F : 0.0F);
        }
    }
    ...
```

Key points:

- **Client-only.** The whole emitter branch is skipped `if (GameServer.server)` — a dedicated server has no audio device and never touches `emitter`. The emitter/`soundInstance` fields exist per-client (or in singleplayer, per-instance), not as authoritative game state.
- **First-tick pause of the finished jingle.** If a leftover `ClothingWasherFinished` one-shot is still playing on this object's emitter (e.g. the player toggled the machine back on immediately after it finished, before the jingle ended), it's cut off with `stopOrTriggerSoundByName`.
- **Emitter allocation is lazy and pooled.** `this.soundInstance == -1L` (i.e. "no loop currently owned") is the only condition needed to (re)acquire an emitter — it doesn't check whether `this.getObject().emitter` is already non-null. `IsoWorld.getFreeEmitter(x, y, z)` (`IsoWorld.java:458`) pulls a `BaseSoundEmitter` from a shared pool (`freeEmitters`) rather than constructing a new object each time; if the pool is empty it creates either an `FMODSoundEmitter` or, if `Core.soundDisabled` is set, a no-op `DummySoundEmitter` (`IsoWorld.java:445-456`). The emitter is positioned at the washer's tile center (`getXi() + 0.5F, getYi() + 0.5F`), so it's a **positional/3D sound**, not a flat ambient loop — volume and stereo panning fall off with player distance the same way any world sound would.
- **`setEmitterOwner`** (`IsoWorld.java:468`) just registers the object in an `emitterOwners` map so the engine can look up which `IsoObject` a given emitter belongs to; it doesn't affect playback itself.
- **The loop itself:** `playSoundLoopedImpl("ClothingWasherRunning")` starts (and keeps looping) the FMOD event bound to the alias `ClothingWasherRunning`. Per `sounds_object_clothingwasher.txt`:

  ```
  sound ClothingWasherRunning
  {
      category = Object,
      clip { event = Object/ClothingWasher/Running }
  }
  ```

  This is a thin alias — the actual waveform, loop points, and any pitch/filter layers live inside the FMOD Studio project/bank (`Object/ClothingWasher/Running` event), which isn't part of the Lua/Java source tree and wasn't inspected in this pass.
- **The load-noise parameter.** Immediately after starting the loop, `hasNoisyItems(container)` is evaluated once and pushed into the FMOD event as a named parameter, `ClothingWasherLoaded` (0.0 or 1.0), via `setParameterValueByName(soundInstance, "ClothingWasherLoaded", ...)`. This is presumably how the event's own FMOD Studio graph switches to a louder/clunkier "stuff banging around" audio layer when the drum is loaded with heavy or hard items — but the parameter's *effect* is defined inside the FMOD project, not in code, so that specific behavior (e.g. does it just increase volume, or swap in a distinct sample layer) isn't verifiable from source.
- **The parameter is a one-time snapshot, not live.** `hasNoisyItems()` is only checked once, at the moment the loop starts (inside the `soundInstance == -1L` branch). If the player adds/removes noisy items *while the wash is already running* (which the wash-cycle logic actually forbids — see `isItemAllowedInContainer`/`isRemoveItemAllowedFromContainer` in the main analysis doc, both of which return `false` while activated), the parameter is never re-evaluated for that cycle. In practice this is moot since the container is locked during a running cycle, but it means there's no code path that updates the parameter mid-cycle even if that lock were bypassed (e.g. by a mod).

### `hasNoisyItems()` — what counts as "noisy"

```java
private boolean hasNoisyItems(ItemContainer container) {
    ...
    float nonClothingWeight = 0.0F;
    for (InventoryItem item : items) {
        if (!(item instanceof Clothing)) {
            nonClothingWeight += item.getActualWeight();
        } else if (item.getBodyLocation() == ItemBodyLocation.SHOES) {
            return true;
        }
    }
    return nonClothingWeight >= 5.0F;
}
```

Two independent triggers, either one is sufficient:

- **Any shoes** in the load (`Clothing` whose `ItemBodyLocation` is `SHOES`) — instantly `true`, regardless of weight. This matches the real-world "sneakers banging around the drum" trope directly.
- **Non-clothing item weight ≥ 5.0** — summed `getActualWeight()` across every item in the container that isn't a `Clothing` instance (loose coins, keys, a phone left in a pocket, etc., assuming the game allows non-clothing items in the washer container at all — the main analysis doc notes non-clothing items *are* processed by the cycle logic for blood/mod-data cleaning, so this is consistent).
- Clothing items that aren't shoes contribute nothing to either check, no matter how many are loaded.

### Stopping the loop / playing the finished stinger

```java
} else if (this.soundInstance != -1L && this.getObject().emitter != null) {
    this.getObject().emitter.stopOrTriggerSound(this.soundInstance);
    this.soundInstance = -1L;
    if (this.cycleFinished) {
        this.cycleFinished = false;
        this.getObject().emitter.playSoundImpl("ClothingWasherFinished", this.getObject());
    }
}
```

This branch runs whenever `isActivated()` is `false` but a loop handle is still held (covers both "player manually turned it off" and "cycle completed and `setActivated(false)` fired automatically" from `cycleFinished()`):

- `stopOrTriggerSound(soundInstance)` stops the specific loop instance (by handle, not by name — relevant if a future change ever allowed two instances on one emitter).
- `soundInstance` is reset to `-1L`, which is what re-arms the "start the loop" branch next time `isActivated()` becomes `true`.
- **Only if the stop was due to a completed cycle** (`this.cycleFinished` — set by `cycleFinished()` when the 90-in-game-minute timer elapses, *not* set when the player manually flips it off early) does the one-shot `ClothingWasherFinished` event play, via `playSoundImpl(..., this.getObject())` (an object-anchored one-shot, distinct from the looped call). Turning the machine off manually mid-cycle is silent — no stinger. This is the same flag/branch that the "start" section races against (a leftover `ClothingWasherFinished` from a very-quickly-restarted cycle gets interrupted, as covered above).

`sounds_object_clothingwasher.txt` binds this alias too:

```
sound ClothingWasherFinished
{
    category = Object,
    clip { event = Object/ClothingWasher/Finished }
}
```

## Part 2 — World Sound Registration (zombie/animal attraction, not audio)

Immediately after the emitter block, still inside `updateSound()`, gated only on not being a game **client** (so this half runs on the server and in singleplayer, mirroring how the emitter half runs only on the client/singleplayer side — the two halves are almost, but not exactly, complementary):

```java
if (!GameClient.client) {
    int radius = this.hasNoisyItems(this.getContainer()) ? 20 : 10;
    WorldSoundManager.instance
        .addSoundRepeating(this, this.getObject().square.x, this.getObject().square.y, this.getObject().square.z, radius, 10, false);
}
```

- **This call is made every tick the washer is running**, not once at cycle start — `WorldSoundManager.addSound(...)` (the common backend, `WorldSoundManager.java:107-208`) allocates a new `WorldSound` entry from an object pool each time and registers it into the surrounding chunks' `soundList`s. The `repeating=true` flag passed down (via the `addSoundRepeating` overload chain, lines 84-88 → 210-214) marks the entry so the population/zombie-pathing system treats it as an ongoing rather than instantaneous noise, but the registration call itself is still re-issued continuously — this is a pooled/re-registered pattern rather than a persistent single handle.
- **`hasNoisyItems()` is re-checked here on every call**, unlike the FMOD parameter which is snapshotted once — so the *gameplay* sound radius genuinely reflects the current load noise-worthiness in real time (10 tiles normally, 20 tiles if shoes/≥5kg of non-clothing items are loaded), even though the *audio* parameter driving the FMOD layer does not update after the loop starts. This is a real asymmetry between the two systems worth flagging: a player could, through some means, change the load's noisiness mid-cycle and the zombie-attraction radius would react while the audible sound would not (though as noted above, normal item-lock rules prevent this from happening through the ordinary UI).
- **Volume argument is a flat `10`**, not derived from anything about the load.
- **`stressHumans` is passed `false`**, and `stressAnimals` defaults to `false` in this overload chain, so the resulting `flags` is just the base `4` (`WorldSoundManager.java:123-132`) — the washer's noise attracts/reveals to zombies via the normal sound-radius mechanism but is not flagged to specifically stress (spook) nearby survivor NPCs or animals the way e.g. a gunshot is.
- This registration is **entirely separate from whether the player can hear anything** — a `Core.soundDisabled` client, a dedicated server with zero players nearby, or a deafened character all still generate this world-sound entry every tick the washer runs, because it's gated on `GameClient.client`/server role, not on any audio subsystem state.

## Comparison to the Dryer

`ClothingDryerLogic.updateSound()` (`ClothingDryerLogic.java:130-157`) is structurally identical with two differences:

| | Washer | Dryer |
|---|---|---|
| Load-noise FMOD parameter | Yes — `ClothingWasherLoaded` set once at loop start based on `hasNoisyItems()` | No — `playSoundLoopedImpl("ClothingDryerRunning")` is called with no follow-up parameter call |
| World-sound radius | Variable: 10, or 20 if `hasNoisyItems()` | Fixed at `10` unconditionally |
| Sound aliases | `ClothingWasherRunning` / `ClothingWasherFinished` | `ClothingDryerRunning` / `ClothingDryerFinished` |

Everything else — lazy emitter acquisition, the `soundInstance == -1L` re-arm gate, cutting off a leftover finished-jingle on restart, playing the finished stinger only when `cycleFinished` (not on manual stop) — is line-for-line the same pattern. This confirms the "noisy load" feature (shoes/heavy items rattling around) is washer-specific and intentionally not modeled for the dryer.

## Combination Washer/Dryer

`IsoCombinationWasherDryer` (per the main analysis doc) owns one `ClothingWasherLogic` and one `ClothingDryerLogic` instance and delegates to whichever is active. Since each logic instance carries its own `soundInstance`/`emitter` fields and `updateSound()` implementation, switching modes doesn't require any special audio-handoff code — only one of the two logic instances is ever `isActivated()` at a time, so only one's `updateSound()` branch does anything, and the other's `else` branch (soundInstance still `-1L`, so it's a no-op) is inert.

## Caveats / Uncertainties

- **The FMOD event content itself (`Object/ClothingWasher/Running`, `Object/ClothingWasher/Finished`) is not inspectable from source.** `sounds_object_clothingwasher.txt` only maps a Java-facing alias name to an FMOD Studio event path; the actual waveform, loop region, layering (e.g. how `ClothingWasherLoaded` changes the mix), and volume/attenuation curve live in the compiled FMOD bank, which isn't part of this decompiled Java/Lua source tree.
- **`FMODSoundEmitter` itself was not found in the decompiled source set** (only its abstract parent `BaseSoundEmitter` and the `DummySoundEmitter` fallback path were locatable) — so the concrete implementations of `playSoundLoopedImpl`, `stopOrTriggerSound`, and `setParameterValueByName` (native FMOD API calls, presumably via JNI) could not be examined; only their call sites and contracts (from the abstract class) are confirmed.
- **Whether `ClothingWasherLoaded` changes volume, swaps a sample layer, or does something else** is inferred from naming and the shoes/weight heuristic, not confirmed from any inspectable FMOD parameter-to-audio mapping.
- The exact `radius`/`volume` units used by `WorldSoundManager` (tiles, and an internal loudness scale respectively) were taken at face value from the `addSound` signature and the sandbox `hearing` multiplier logic (`WorldSoundManager.java:162-174`); the multiplier table itself (`getHearingMultiplier(hearing)`) was not opened in this pass.
