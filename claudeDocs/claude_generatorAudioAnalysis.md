# Generator Audio Analysis

**Created:** 2026-09-14
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media42_20_4/`)
**Scope:** A focused look at how `IsoGenerator` (the portable generator appliance) produces its running sound, following the same approach as [claude_washingMachineAudioAnalysis.md](claude_washingMachineAudioAnalysis.md). The generator turns out to use a **materially different** emitter-management pattern from either the washer (`ClothingWasherLogic`) or the fireplace (`IsoFireplace`) examined previously — it's a genuinely third precedent for how a vanilla `IsoObject` maintains a continuous running sound.

## Code Locations

| Purpose | File |
|---|---|
| Generator object (fuel, condition, power distribution, sound) | `zombie42_20_4/iso/objects/IsoGenerator.java` |
| Emitter pool / ownership API | `zombie42_20_4/iso/IsoWorld.java` (`getFreeEmitter`, `takeOwnershipOfEmitter`, `returnOwnershipOfEmitter`, `setEmitterOwner`) |
| FMOD event bindings | `media42_20_4/scripts/generated/sounds/objects/sounds_object_generator.txt` |
| Per-item sound customization (`SoundRadius`, `SoundVolume`, `GeneratorSound`) | Generator item scripts (`Item.getSoundRadius()`/`getSoundVolume()`, `zombie42_20_4/scripting/objects/Item.java`); tile property `GeneratorSound` read via `getSprite().getProperties()` |

## Summary

`IsoGenerator extends IsoObject` (`IsoGenerator.java:43`) — a hard-coded Java appliance, same family as the washer/dryer and fireplace. Its sound design is considerably more elaborate than the washer's simple Running/Finished pair: eight distinct sound events (`Loop`, `Starting`, `Stopping`, `FailedToStart`, `Backfire`, `AddFuel`, `Repair`, `Connect`), doubled into an "Old Generator" variant set selectable per-tile. But the single most important finding, for anyone comparing this against the washer, is structural: **the generator explicitly removes its emitter from `IsoWorld`'s automatically-ticked pool and manages it entirely by hand**, whereas the washer and fireplace both leave their emitter in that pool and let the engine tick it for free. This is a real, previously-unexamined third pattern.

## Part 1 — Starting and Maintaining the Loop

### The self-healing per-tick check (same family as `IsoFireplace`, not `ClothingWasherLogic`)

`IsoGenerator.update()` (`IsoGenerator.java:159-273`), called every tick while the generator exists in the world:

```java
if (this.isActivated()) {
    if (!GameServer.server && (this.emitter == null || !this.emitter.isPlaying(this.getSoundPrefix() + "Loop"))) {
        this.playGeneratorSound("Loop");
    }
    ...
```

Like `IsoFireplace.updateSound()` (see the washing-machine audio analysis), this re-checks `isPlaying(...)` **every single tick** and re-triggers if the named sound isn't currently detected as playing — a self-healing pattern, not a one-time "did I already start this" flag. This is the second independent vanilla precedent for that pattern (fireplace, now generator), reinforcing that it's the more defensive of the two loop-maintenance styles found across this whole investigation (the other being `ClothingWasherLogic`'s one-time `soundInstance == -1L` gate).

### `getSoundPrefix()` — sound events are chosen per-tile, not per-script-component

```java
public String getSoundPrefix() {
    if (this.getSprite() == null) {
        return "Generator";
    }
    PropertyContainer props = this.getSprite().getProperties();
    return props.has("GeneratorSound") ? props.get("GeneratorSound") : "Generator";
}
```

The actual sound alias played is `getSoundPrefix() + "Loop"` (or `+"Starting"`, `+"Backfire"`, etc.) — normally `"Generator" + "Loop"` = `"GeneratorLoop"`, but a tile carrying a `GeneratorSound` sprite property (e.g. set to `"OldGenerator"`) would instead resolve to `"OldGeneratorLoop"` and so on for every suffix. `sounds_object_generator.txt` defines both full sets side by side (`GeneratorLoop`/`OldGeneratorLoop`, etc.) — a visually older generator tile plays a distinctly different, presumably more worn-sounding, event without any Lua or extra Java branching, purely by which prefix its tile property selects.

### Starting the sound — `playSoundImpl`, not `playSoundLoopedImpl`

```java
private void playGeneratorSound(String suffix) {
    if (!GameServer.server) {
        if (this.emitter == null) {
            this.emitter = IsoWorld.instance.getFreeEmitter(this.getXi() + 0.5F, this.getYi() + 0.5F, this.getZi());
            IsoWorld.instance.takeOwnershipOfEmitter(this.emitter);
        }
        this.playGeneratorSound(this.emitter, suffix);
    }
}

private void playGeneratorSound(BaseSoundEmitter emitter, String suffix) {
    emitter.playSoundImpl(this.getSoundPrefix() + suffix, this);
}
```

Two things stand out against the washer's equivalent code:

- **`playSoundImpl`, the plain/one-shot play method, is used even for the continuous `"...Loop"` event** — not `playSoundLoopedImpl`, the dedicated looped-playback method `ClothingWasherLogic`/`IsoFireplace` both use. This strongly implies the actual looping behavior for `Object/Generator/Running` (and `Object/OldGenerator/Running`) is authored as a self-looping event inside the FMOD project itself, with the Java/Lua side only responsible for making sure *some* instance of it is playing (via the per-tick `isPlaying` re-check above) rather than explicitly managing loop iteration. This can't be confirmed further since FMOD bank content isn't in this repo's decompiled sources, but it's a real, code-visible design choice distinct from the washer's approach.
- **`IsoWorld.instance.takeOwnershipOfEmitter(this.emitter)`** is called immediately after acquiring the emitter — not `setEmitterOwner`. This is the crux structural difference; see Part 2.

## Part 2 — Ownership: `takeOwnershipOfEmitter` vs. `setEmitterOwner`

`IsoWorld.java` exposes two entirely different things a caller can do with a freshly-acquired emitter, and the generator and washer each pick a different one:

```java
public void takeOwnershipOfEmitter(BaseSoundEmitter emitter) {
    this.currentEmitters.remove(emitter);
}

public void setEmitterOwner(BaseSoundEmitter emitter, IsoObject object) {
    if (emitter != null && object != null) {
        if (!this.emitterOwners.containsKey(emitter)) {
            this.emitterOwners.put(emitter, object);
        }
    }
}
```

- **The washer/fireplace pattern (`setEmitterOwner`)** only records, in a side lookup table (`emitterOwners`), which `IsoObject` a given emitter "belongs to" — for the purpose of `IsoWorld.update()`'s automatic reclaim loop later nulling out `owner.emitter` when the emitter empties out (see the washing-machine audio analysis, Part 1). Critically, it does **not** remove the emitter from `currentEmitters` — the emitter stays in the engine's own automatically-ticked pool, and `IsoWorld.update()` calls `e.tick()` on it every ~30ms without the object ever having to ask.
- **The generator pattern (`takeOwnershipOfEmitter`)** does the opposite: it immediately **removes** the emitter from `currentEmitters`, taking it out of the engine's automatic tick loop entirely. From that point on, *nothing* ticks that emitter unless the generator itself does it.

And the generator does, explicitly, every single `update()` call:

```java
if (GameClient.client) {
    this.emitter.tick();
    return;
}
...
if (this.emitter != null) {
    this.emitter.tick();
}
```

(The `GameClient.client` branch — a multiplayer client receiving a networked generator's state — ticks and returns early, skipping the fuel/condition/backfire simulation that only the authoritative side should run; the final unconditional `emitter.tick()` at the bottom of `update()` covers the singleplayer/server-owning-client case.)

**This is the single most important, actionable finding of this analysis: an object that calls `takeOwnershipOfEmitter` takes on full responsibility for calling `emitter:tick()` itself, every tick, for as long as it wants that emitter to do anything at all.** Skipping that call — e.g. an incomplete port of this pattern into Lua that copies `getFreeEmitter`/`takeOwnershipOfEmitter` but forgets the manual `tick()` — would produce exactly the "engine says it's playing, nothing is heard" symptom this project's own Churning Machine investigation spent many DevCycles chasing, though for a different underlying reason than anything found there (the Churning Machine's code always used `setEmitterOwner`, not `takeOwnershipOfEmitter`, so its emitter should have remained in the automatically-ticked pool the whole time — this distinction just wasn't something that investigation examined, since it never compared against the generator's pattern).

### Returning ownership on cleanup

```java
@Override
public void removeFromWorld() {
    AllGenerators.remove(this);
    if (this.emitter != null) {
        this.emitter.stopAll();
        IsoWorld.instance.returnOwnershipOfEmitter(this.emitter);
        this.emitter = null;
    }
    super.removeFromWorld();
}
```

Symmetric with `takeOwnershipOfEmitter`: when the generator is removed from the world, it explicitly stops all sounds on its emitter and hands it back (`returnOwnershipOfEmitter`, `IsoWorld.java:476-488`), which re-adds it to either `freeEmitters` (if it's already empty) or `currentEmitters` (if something is still playing on it, letting the engine finish ticking it down normally). Neither the washer nor the fireplace has an equivalent explicit hand-back — because they never took the emitter out of the automatic pool in the first place; `IsoWorld.update()`'s own reclaim loop (checking `e.isEmpty()`) handles their emitters' eventual return passively.

## Part 3 — The Full Sound Event Set

`sounds_object_generator.txt` defines, per prefix (`Generator`/`OldGenerator`):

| Suffix | FMOD event | `distanceMax` | Trigger |
|---|---|---|---|
| `Loop` | `Object/Generator/Running` | 100 | Continuous, while `isActivated()`, self-healing per-tick check |
| `Starting` | `Object/Generator/Startup` | 100 | `setActivated(true)` (or networked equivalent on a client) |
| `Stopping` | `Object/Generator/Shutdown` | 100 | `setActivated(false)`, after `stopAllSounds()` |
| `FailedToStart` | `Object/Generator/StartupFail` | 100 | `failToStart()` — called from elsewhere (e.g. an out-of-fuel start attempt) |
| `Backfire` | `Object/Generator/Backfire` | 100 | Random per-hour chance, scaled by low `condition` (see Part 4) |
| `AddFuel` | `Object/Generator/AddFuel` | *(none set)* | Not examined further in this pass — presumably a refuel-action one-shot |
| `Repair` | `Object/Generator/Repair` | *(none set)* | Not examined further — presumably a repair-action one-shot |
| `Connect` | `Object/Generator/Connect` | *(none set)* | Not examined further — presumably a plug-in/connect-action one-shot |

**`distanceMax = 100` is worth flagging on its own:** unlike the washer's `sounds_object_clothingwasher.txt` (which sets no distance-related field at all on either of its two sounds), several of the generator's sound definitions explicitly declare a maximum audible distance right in the plain-text script — proving that at least some FMOD attenuation/range data *is* visible outside the compiled bank, for objects whose sound designer chose to set it here rather than (or in addition to) inside the FMOD project itself. `AddFuel`/`Repair`/`Connect` — all short, close-range interaction sounds — pointedly don't set one, consistent with them not needing long-range audibility the way the ambient running loop and the loud startup/shutdown/backfire events do.

`Starting`/`Stopping` are triggered directly from `setActivated(boolean)` (`IsoGenerator.java:526-556`), and mirrored in `syncIsoObjectReceive` (`IsoGenerator.java:608-637`) for the networked case — a client receiving a state change from the server re-derives which sound to play (`Starting` if `activated` became true, `Stopping` — after `stopAllSounds()` — if it became false) rather than the server ever telling it directly which sound to play. `stopAllSounds()` (`IsoGenerator.java:754-760`) just calls `emitter.stopAll()`, unconditionally silencing everything on the shared emitter (the loop included) before the `Stopping` one-shot plays on top of the now-quiet emitter.

## Part 4 — Backfire: a Condition-Driven Random One-Shot, Layered on the Same Emitter

Once per elapsed in-game hour (`IsoGenerator.java:192-262`), alongside fuel/condition depletion math, there's a chance of a "backfire" scaled by how run-down the generator's `condition` is:

```java
if (this.condition <= 20) {
    bBackfire = Rand.Next(5) == 0;       // 1-in-5 per hour
} else if (this.condition <= 30) {
    bBackfire = Rand.Next(10) == 0;      // 1-in-10 per hour
} else if (this.condition <= 40) {
    bBackfire = Rand.Next(15) == 0;      // 1-in-15 per hour
}

if (bBackfire) {
    if (GameServer.server) {
        GameServer.PlayWorldSoundServer(this.getSoundPrefix() + "Backfire", this.getSquare(), 40.0F, -1);
    } else {
        this.playGeneratorSound("Backfire");
    }
    WorldSoundManager.instance.addSound(this, this.square.getX(), this.square.getY(), this.square.getZ(), 40, 60, false, 0.0F, 15.0F);
}
```

Two audio-relevant details:

- **The dedicated server plays the sound differently** — `GameServer.PlayWorldSoundServer(...)` (a broadcast-to-clients mechanism) rather than a local `emitter.playSoundImpl(...)` call, since a dedicated server has no local audio device (consistent with every other object examined across this whole investigation always gating emitter code behind `!GameServer.server`).
- **The backfire's gameplay sound-radius registration uses a notably higher `stressMod` (15.0F)** than the continuous loop's own registration below (which uses the 1.0F-equivalent default) — a one-off loud bang is deliberately modeled as far more startling to nearby zombies/animals than the steady running hum, on top of also being flagged as `stressHumans=false, stressAnimals=false` at the base (same `addSound` call shape as the washer's registration, just with different radius/volume/stressMod arguments, not different flags).
- Low condition can also (independently of backfire) start a fire or explode the generator entirely (`IsoGenerator.java:246-256`) — worth knowing as context for why `Backfire` exists narratively (an audible warning sign before a worse outcome), though the fire/explosion path itself has no distinct sound code beyond what `IsoFireManager.StartFire`/`explode` already handle elsewhere.

## Part 5 — World Sound Registration (Gameplay, Not Audio)

```java
Item item = ScriptManager.instance.getItem(this.getGeneratorItemType());
int soundRadius = 20;
int soundVolume = 20;
if (item != null) {
    if (item.getSoundRadius() > 0) { soundRadius = item.getSoundRadius(); }
    if (item.getSoundVolume() > 0) { soundVolume = item.getSoundVolume(); }
}
if (this.getSquare().getRoom() != null) {
    soundRadius /= 2;
}
WorldSoundManager.instance.addSoundRepeating(this, PZMath.fastfloor(this.getX()), PZMath.fastfloor(this.getY()), PZMath.fastfloor(this.getZ()), soundRadius, soundVolume, false);
```

Called every tick while activated, same `WorldSoundManager.addSoundRepeating` mechanism documented in the washing-machine audio analysis (a re-registered, pooled "loud point" for zombie/animal awareness — not audio). Two differences from the washer's version worth noting:

- **Radius and volume are data-driven per generator item**, via `Item.getSoundRadius()`/`getSoundVolume()` script fields (falling back to a flat `20`/`20` if unset or non-positive) — the washer hardcodes its 10/20-tile radius directly in Java with no per-item customization axis at all.
- **Being indoors halves the radius** (`soundRadius /= 2` if `getSquare().getRoom() != null`) — a refinement not present anywhere in the washer's equivalent code, modeling a generator running inside a building as quieter to the outside world than one running in the open.

## Comparison Table — Three Vanilla Patterns for a Continuous `IsoObject` Sound

| | `ClothingWasherLogic` (Washer/Dryer) | `IsoFireplace` | `IsoGenerator` |
|---|---|---|---|
| Emitter ownership | `setEmitterOwner` — stays in `IsoWorld`'s auto-ticked pool | `setEmitterOwner` — stays in the auto-ticked pool | `takeOwnershipOfEmitter` — **removed** from the pool |
| Who calls `emitter.tick()` | The engine, automatically, every ~30ms | The engine, automatically | **The object itself**, every `update()` call |
| Loop start method | `playSoundLoopedImpl` | `playSoundLoopedImpl` | `playSoundImpl` (event presumed self-looping) |
| Re-arm guard | One-time `soundInstance == -1L` gate | Per-tick `!isPlaying(name)` re-check | Per-tick `!isPlaying(name)` re-check |
| Cleanup on removal | None explicit — passive reclaim via `IsoWorld.update()`'s `isEmpty()` sweep | Not examined in this pass | Explicit `stopAll()` + `returnOwnershipOfEmitter()` |
| Distinct sound events | 2 (`Running`, `Finished`) | 1 (`Running`, name overridable via `CraftBenchSounds`) | 8 per prefix, ×2 prefixes (`Generator`/`OldGenerator`) |
| Per-instance sound customization | None | None found | `GeneratorSound` tile property (event prefix); `SoundRadius`/`SoundVolume` item fields (gameplay radius only) |

## Caveats / Uncertainties

- As with every other object examined in this investigation, the actual FMOD event content (`Object/Generator/Running` etc.) and the concrete `FMODSoundEmitter`/`BaseSoundEmitter.tick()` implementation are not present in this repo's decompiled sources — confirmed only that `distanceMax` is sometimes authored in the plain-text sound script rather than solely inside the compiled bank, which is new information relative to the washer's own (distance-field-free) sound script.
- Not traced in this pass: `AddFuel`, `Repair`, and `Connect` — their exact trigger sites (presumably player-timed-action Lua code, analogous to the churning-relevant `CraftBenchSounds`-driven `StartCraft` sounds found in the washing-machine audio analysis) weren't followed further, since they're one-shot interaction sounds rather than part of the continuous-running-sound mechanism this analysis focused on.
- Whether `playSoundImpl`'s target event is genuinely authored as a self-looping FMOD event (as inferred from the code using the non-Looped play method for a sound literally named `...Loop`) is an inference from the Java call site, not something confirmed from the FMOD project itself.
