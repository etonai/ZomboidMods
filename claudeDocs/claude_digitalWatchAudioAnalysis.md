# Digital Watch (Alarm Clock Wristwatch) Audio Analysis

**Created:** 2026-09-14
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media42_20_4/`)
**Scope:** How the digital wristwatch emits its alarm sound, continuing the same investigation as [claude_washingMachineAudioAnalysis.md](claude_washingMachineAudioAnalysis.md), [claude_generatorAudioAnalysis.md](claude_generatorAudioAnalysis.md), and [claude_microwaveAudioAnalysis.md](claude_microwaveAudioAnalysis.md). The watch is a **fourth, structurally distinct** sound architecture: it's not an `IsoObject` at all (unlike the washer/fireplace/generator/stove) and not a scripted `GameEntity` either (unlike the Amphora/Butter Churn/this project's own Churning Machine) — it's a plain carried **`InventoryItem`**, and its sound is driven by a centralized manager class (`ItemSoundManager`) that ticks a shared pool of emitters on the items' behalf, rather than any object managing its own.

## Code Locations

| Purpose | File |
|---|---|
| Watch/alarm-clock-clothing item logic (scheduling, ringing, sound) | `zombie42_20_4/inventory/types/AlarmClockClothing.java` |
| Digital watch item definitions (`WristWatch_*_Digital*`, `WristWatch_*_Expensive`) | `media42_20_4/scripts/generated/items/alarmclockclothing.txt` |
| Central sound-item registry/pool (drives `updateSound(emitter)` calls) | `zombie42_20_4/inventory/ItemSoundManager.java` |
| Alarm sound event bindings | `media42_20_4/scripts/generated/sounds/player/sounds_player_alarm.txt` |
| Shared alarm-clock interface (`AlarmClockClothing` and the plain `AlarmClock` item both implement it) | `zombie.inventory.types.IAlarmClock` (referenced, not opened in this pass) |

## Summary — Not an `IsoObject`, Not a `GameEntity`: It's an `InventoryItem`

`AlarmClockClothing extends Clothing implements IAlarmClock` (`AlarmClockClothing.java:37`) — the digital wristwatch items (`WristWatch_Right_DigitalBlack`, `WristWatch_Left_DigitalRed`, `WristWatch_Right_Expensive`, etc., all `ItemType = base:alarmclockclothing` in `alarmclockclothing.txt`) are all instances of this one Java class, distinguished only by data (icon, sprite, weight). Being a wearable clothing item rather than a placed world object, it has no `update()` tick from `IsoObject`'s per-object processing at all — instead it opts into a **separate, item-specific processing list** (`shouldUpdateInWorld()` → `true` while `alarmSet`), and its actual sound is played through an emitter it doesn't own or manage itself, handed to it once per frame by a central registry.

## Part 1 — What "Digital" Actually Means Here

```java
public AlarmClockClothing(String module, String name, String itemType, String texName, String palette, String spriteName) {
    super(module, name, itemType, texName, palette, spriteName);
    this.itemType = ItemType.ALARM_CLOCK_CLOTHING;
    if (this.fullType.contains("Classic")) {
        this.isDigital = false;
    }
    this.randomizeAlarm();
}
```

`isDigital` (`AlarmClockClothing.java:46`) defaults `true` and is only ever flipped `false` if the item's full type name contains `"Classic"` — i.e. every `WristWatch_*_Classic*` (Black/Brown/Military/Gold analog watches) is **not** digital, while every `WristWatch_*_Digital*` and the `WristWatch_*_Expensive` variant remain digital. This matters because of `randomizeAlarm()` (`AlarmClockClothing.java:72-80`):

```java
private void randomizeAlarm() {
    if (!Core.lastStand) {
        if (this.isDigital()) {
            this.alarmHour = Rand.Next(0, 23);
            this.alarmMinutes = (int)Math.floor(Rand.Next(0, 59) / 10) * 10;
            this.alarmSet = Rand.Next(15) == 1;
        }
    }
}
```

**Only digital watches ever get a randomized alarm at spawn (1-in-15 chance) — analog "Classic" watches never ring at all**, since `isDigital()` gates the whole block. This is a real, item-identity-driven behavioral difference, not just a visual/icon difference between the watch variants — it's the direct, literal answer to why *this specific item* ("the digital watch") is worth analyzing separately from "a watch" in general: only the digital ones make noise.

## Part 2 — Scheduling: When Does It Actually Start Ringing

```java
@Override
public void update() {
    if (this.alarmSet) {
        int minutes = GameTime.instance.getMinutes();
        if (GameServer.server || GameClient.client) {
            minutes = minutes / 10 * 10;
        }
        if (!this.isRinging() && this.forceDontRing != minutes && this.alarmHour == GameTime.instance.getHour() && this.alarmMinutes == minutes) {
            this.ringSince = GameTime.getInstance().getWorldAgeHours();
            if (GameServer.server) { this.syncAlarmClock(); }
        }
        if (this.isRinging()) {
            ...
        }
    }
}
```

- Only runs at all while `shouldUpdateInWorld()` returns `true`, which is simply `this.alarmSet` (`AlarmClockClothing.java:104-107`) — an alarm-clock item with no alarm set does nothing every tick, not even a cheap check.
- The alarm minute is rounded down to the nearest 10 in multiplayer contexts (`minutes / 10 * 10`) — matching `randomizeAlarm()`'s own alarm-minute generation, which is also always a multiple of 10 — presumably to reduce how many distinct alarm times need network-synced precision.
- `forceDontRing` is a one-shot suppression: once an alarm has rung and been dismissed (`stopRinging()`, `AlarmClockClothing.java:414-427`), `forceDontRing` is set to the current rounded minute so the very same still-matching minute doesn't immediately re-trigger it; it's cleared back to `-1` the next time the current minute no longer matches.
- Once ringing starts (`ringSince` set to the current world-age-hours timestamp), the object registers itself for actual sound processing: `ItemSoundManager.addItem(this)` (`AlarmClockClothing.java:138`), called every tick while `isRinging()` and not on a dedicated server.
- The alarm auto-stops after 0.5 in-game hours if nothing else stops it first (`this.ringSince + 0.5 < worldAgeHours`, `AlarmClockClothing.java:128`), or immediately if `getAlarmSquare()` can no longer resolve a position for it at all (e.g. the item ceased to exist somewhere trackable).
- While ringing, it also separately re-registers into the ordinary `WorldSoundManager` gameplay sound-radius system every tick (`addSoundRepeating(null, sq.getX(), sq.getY(), sq.getZ(), this.getSoundRadius(), 3, false)`, `AlarmClockClothing.java:134`) — the same non-audio zombie/animal-awareness mechanism documented in the washing-machine and generator analyses, just with `source = null` instead of `this`, since the "source" here is a carried item, not a placed `IsoObject`.

## Part 3 — `ItemSoundManager`: A Fourth, Centralized Sound-Management Architecture

This is the most structurally novel finding of this analysis. Every prior object examined (washer, fireplace, generator, stove/microwave) acquires and manages its **own** emitter directly, in its **own** `update()`/`doSound()` code. The watch does not — it registers itself with a single, static, game-wide manager (`ItemSoundManager.java`) and waits to be serviced:

```java
public static void addItem(InventoryItem item) {
    if (!GameServer.server) {
        if (item != null && !items.contains(item)) {
            ...
            if (!toAdd.contains(item)) { toAdd.add(item); }
        }
    }
}

public static void update() {
    ...
    if (!toAdd.isEmpty()) {
        for (int i = 0; i < toAdd.size(); i++) {
            InventoryItem item = toAdd.get(i);
            items.add(item);
            BaseSoundEmitter emitter = IsoWorld.instance.getFreeEmitter();
            IsoWorld.instance.takeOwnershipOfEmitter(emitter);
            emitters.add(emitter);
        }
        toAdd.clear();
    }
    ...
    for (int i = 0; i < items.size(); i++) {
        InventoryItem item = items.get(i);
        BaseSoundEmitter emitter = emitters.get(i);
        ItemContainer container = getExistingContainer(item);
        if (container != null || item.getWorldItem() != null && item.getWorldItem().getWorldObjectIndex() != -1) {
            if (item.getSoundLimiterGroupID() != null) {
                item.registerWithSoundLimiter(instanceLimiter);
            } else {
                item.updateSound(emitter);
                emitter.tick();
            }
        } else {
            removeItem(item);
        }
    }
    ...
}
```

- **`takeOwnershipOfEmitter` is used here too** — the same ownership call the generator uses (see the generator analysis), and for the identical underlying reason: this emitter is *not* going to be automatically ticked by `IsoWorld.update()`'s own per-frame sweep, because `ItemSoundManager.update()` calls `emitter.tick()` itself, explicitly, right after `item.updateSound(emitter)` (line 116 above). This is now the **third** confirmed real-code example of "an object/manager that calls `takeOwnershipOfEmitter` must manually tick its own emitter every frame or nothing plays" — reinforcing that as a genuine, load-bearing rule of this sound system, not a one-off generator quirk.
- **One emitter per registered item, pooled and reused** for as long as the item stays registered — added via `getFreeEmitter()`/`takeOwnershipOfEmitter()` when first added, explicitly stopped and returned via `returnOwnershipOfEmitter()` (mirroring the generator's own cleanup pattern) once the item calls `removeItem(this)` (i.e. `stopRinging()`).
- **An item stops being serviced if it's no longer reachable** — `getExistingContainer(item)` returning `null` and the item not being a valid placed world item both cause silent, automatic `removeItem(item)` — e.g. if a ringing watch gets destroyed or otherwise falls out of any container/world-placement the manager can still resolve.
- **A separate "sound limiter group" system exists for deduplicating identical concurrent sounds** (`item.getSoundLimiterGroupID()`, `SoundInstanceLimiter`) — if a group ID is set, only the single closest-to-player item in that group actually gets a real, ticked emitter (`getEmitterForSoundLimiterGroup`, also via `takeOwnershipOfEmitter`), presumably to avoid e.g. a pile of a dozen identical ringing alarm clocks each playing a full, separate copy of the same sound. Not examined further in this pass, and the plain digital watch doesn't appear to use it (its `updateSound` override takes only an emitter, matching the *non*-limiter-group call path) — but worth knowing this mechanism exists for other, possibly-stackable sound-emitting items.

## Part 4 — `updateSound(emitter)`: Two Different Emitter Targets Depending on Who's Carrying It

```java
@Override
public void updateSound(BaseSoundEmitter emitter) {
    assert !GameServer.server;
    IsoGridSquare sq = this.getAlarmSquare();
    if (sq != null) {
        emitter.setPos(sq.x + 0.5F, sq.y + 0.5F, sq.z);
        if (this.alarmSound == null || "".equals(this.alarmSound)) {
            this.alarmSound = "AlarmClockLoop";
        }
        if (this.isInLocalPlayerInventory()) {
            this.playerOwner = this.getOwnerPlayer(this.getContainer());
            BaseCharacterSoundEmitter currentEmitter = this.playerOwner.getEmitter();
            if (!currentEmitter.isPlaying(this.ringSound)) {
                this.ringSound = currentEmitter.playSound(this.alarmSound, this.playerOwner);
            }
        } else if (!emitter.isPlaying(this.ringSound)) {
            this.ringSound = emitter.playSoundImpl(this.alarmSound, sq);
        }
        if (GameClient.client && sendEvery.Check() && this.isInLocalPlayerInventory()) {
            WorldSoundManager.instance.addSound(null, sq.x, sq.y, sq.z, this.getSoundRadius(), 3, false, 0.0F, 1.0F);
        }
        this.wakeUpPlayers(sq);
    }
}
```

- **If the local player is wearing/carrying the ringing watch, the sound is played through the *player's own character emitter*** (`this.playerOwner.getEmitter()`, a `BaseCharacterSoundEmitter`) — completely bypassing the `emitter` parameter `ItemSoundManager` handed it. This is the exact same character-emitter mechanism documented in the washing-machine audio analysis (the `PseudoSaltWell`-style `character:getEmitter():playSound(...)` pattern) — confirmed here as a real, current, vanilla-native use of it too, not something unique to that other mod's own code.
- **Otherwise** (the watch is sitting in the world, in a container, on another character, etc.) **it plays through the pooled emitter `ItemSoundManager` provided**, positioned at `getAlarmSquare()`'s coordinates via `emitter.setPos(...)` — this is the "normal," object-style positional path.
- **Re-arming is by stored instance handle, not by name** — `this.ringSound` is a `long` handle (from whichever `playSound(...)`/`playSoundImpl(...)` call last started it), and both branches guard with `!emitter.isPlaying(this.ringSound)` before starting a new one. This is closer to `ClothingWasherLogic`'s own handle-based tracking style than to the fireplace/generator's by-*name* `isPlaying(string)` re-checks — a real, meaningful difference: a handle uniquely identifies *that specific instance*, while a name-based check would match *any* currently-playing instance of that alias, which matters here since the same alias could in principle be playing on a completely different emitter.
- **The alarm sound name is configurable per-item** (`this.alarmSound`, set from the item script's `AlarmSound = WatchAlarmLoop` field — not shown directly read in this excerpt, but declared in `alarmclockclothing.txt` for every watch variant), defaulting to `"AlarmClockLoop"` if unset. All digital watch items in this mod's item file set it explicitly to `WatchAlarmLoop`, resolving to `Character/Survival/AlarmWatchRinging` (`sounds_player_alarm.txt:23-31`, `category = Player`, `distanceMax = 150`) — a `Player`-category sound, consistent with it being played through a character emitter in the common case.

## Part 5 — Waking Sleeping Players: A Non-Audio Effect Triggered Alongside the Sound

```java
private void wakeUpPlayers(IsoGridSquare sq) {
    if (!GameServer.server) {
        int radius = this.getSoundRadius();
        ...
        for (int i = 0; i < IsoPlayer.numPlayers; i++) {
            IsoPlayer player = IsoPlayer.players[i];
            if (player != null && !player.isDead() && player.getCurrentSquare() != null && !player.hasTrait(CharacterTrait.DEAF)) {
                ...
                if (!(distSq > radius * radius)) {
                    this.wakeUp(player);
                }
            }
        }
    }
}

private void wakeUp(IsoPlayer chr) {
    if (chr.asleep) {
        SoundManager.instance.setMusicWakeState(chr, "WakeNormal");
        SleepingEvent.instance.wakeUp(chr);
    }
}
```

Called every `updateSound()` tick while ringing, independent of which emitter path was taken above. This directly iterates every local player (not via `WorldSoundManager`'s zombie-facing sound-radius system at all) checking distance (scaled by `getHearDistanceModifier()`) and the `DEAF` trait, and wakes any sleeping one within range. This is a good example — like the washing machine's dual "FMOD emitter vs. `WorldSoundManager` gameplay registration" split, and the generator's fire/explosion mechanic layered on its backfire sound — of a vanilla sound event also driving a distinct, audio-independent gameplay effect on the side, using its own separate distance/eligibility logic rather than reusing any of the sound-radius machinery already in play for the same ring.

## Comparison Update — Five Architectures Now Examined

| | `ClothingWasherLogic` | `IsoFireplace` | `IsoGenerator` | `IsoStove` (microwave) | `AlarmClockClothing` (watch) |
|---|---|---|---|---|---|
| Underlying type | `IsoObject` | `IsoObject` | `IsoObject` | `IsoObject` | **`InventoryItem`** |
| Who acquires/owns the emitter | The object itself | The object itself | The object itself | The object itself | **A central manager (`ItemSoundManager`)**, per registered item |
| Emitter ownership call | `setEmitterOwner` | `setEmitterOwner` | `takeOwnershipOfEmitter` | `setEmitterOwner` | `takeOwnershipOfEmitter` |
| Who calls `emitter.tick()` | The engine, automatically | The engine, automatically | The object itself, every `update()` | The engine, automatically | **The manager**, once per registered item, every `ItemSoundManager.update()` |
| Loop start method | `playSoundLoopedImpl` | `playSoundLoopedImpl` | `playSoundImpl` | `playSoundLoopedImpl` | `playSound`/`playSoundImpl` (one-shot API, re-armed by handle check) |
| Re-arm guard | One-time handle gate | Per-tick by-name check | Per-tick by-name check | One-time, on state change | **Per-tick by-*handle* check** (`isPlaying(long)`, not `isPlaying(String)`) |
| Can switch emitter type at runtime | No | No | No | No | **Yes** — character emitter if locally worn, pooled object-style emitter otherwise |
| Registration model | Self-contained | Self-contained | Self-contained | Self-contained | **Opt-in list membership** (`addItem`/`removeItem`), auto-evicted if unreachable |

## Caveats / Uncertainties

- `IAlarmClock` (the shared interface `AlarmClockClothing` and the plain `AlarmClock` item both implement) was referenced but not opened in this pass — it's reasonable to assume the plain (non-clothing, e.g. a nightstand alarm clock item) `AlarmClock` class shares most of this same `ItemSoundManager`-driven mechanism, but that wasn't directly confirmed here.
- `SoundInstanceLimiter`/sound-limiter-group deduplication was found and described structurally but not traced into its own implementation file — not confirmed whether any watch/alarm-clock item actually sets a limiter group ID in practice (the digital watch's own `updateSound(BaseSoundEmitter)` override, without the `SoundLimiterParams` parameter, matches the *non*-limiter-group call path in `ItemSoundManager.update()`, suggesting it doesn't).
- As with every object in this investigation, the actual FMOD event content (`Character/Survival/AlarmWatchRinging`, etc.) and `BaseCharacterSoundEmitter`/`FMODSoundEmitter`'s concrete implementations are not present in this repo's decompiled sources.
- `getOwnerPlayer(ItemContainer)` and `isInLocalPlayerInventory()` — the exact logic for determining "is this the local player's own carried item" — were used but not opened/traced in this pass; taken at face value from their names and call context.
