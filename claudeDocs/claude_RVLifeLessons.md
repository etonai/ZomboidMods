# RV Life Mod – Lessons: Teleporting and Unlimited Interior Power

**Created:** 2026-11-05
**Mod examined:** `notmymods/RV Life` (id `RVLife`, modversion 1.1, by @fredders / @ThePelona / @BuchoJefe; `versionMin=42.0`)
**Game build for engine checks:** v42.20.4 (`zombie42_20_4/`, `media42_20_4/`)
**Note:** The mod's license header forbids redistribution. This document describes the techniques only. It does not copy the mod's code beyond short excerpts.

Paths below are relative to `notmymods/RV Life/common/media/lua/`.

---

## 1. Summary

| Question | Answer |
|---|---|
| What is the "interior"? | **Not a standalone pregenerated map.** Each interior is a `.pzby` "basement" file (`media/binmap/*.pzby`, `media/basement_access/*.pzby`). The external **Basements** mod API stamps it into the world at **z = -1**, in a reserved block of the Muldraugh map. |
| How is the character teleported? | A plain `player:setX/setY/setZ` (plus `setLastX/Y/Z`) call. There is no loading screen and no vehicle-exit animation. The player's old position is saved in player modData for the return trip. |
| How is the interior powered? | Two layers: **(a)** a hidden, auto-refueled `Generator_Blue` placed at z = 0 directly above each interior (this is the layer that actually powers things), and **(b)** a Lua override of `IsoGridSquare:haveElectricity()` that returns `true` inside "power zones". Layer (b) has limited reach (see §4.3). |

---

## 2. Where the interiors live

### 2.1 Reserved area

`shared/RVLifeInterior/RVLifeMapData.lua`, `client/RVLifeUpdate.lua`, and `shared/ZombieCleaner.lua` agree on one rectangle:

- **X 16896 → 18432, Y 1024 → 2560** (`ZombieCleaner.lua:75-76`, `RVLifeMigration.lua:60`).
- `RVLifeUpdate.lua:83-85` sets `baseX, baseY = 16896, 1024`, with `matrixSeparation = 256` and a 32-tile spacing between individual interiors.
- I did not check these numbers against the actual Muldraugh map bounds. Calling the area the "far corner" is the user's description. The coordinates are consistent with the east/north edge, since low Y is north.

### 2.2 Grid layout (`RVLifeUpdate.lua:86-97`)

The area is divided into ten 8×8 "matrices", one per interior size. Each matrix holds 64 spawn slots:

| Matrix key | Size | Matrix key | Size |
|---|---|---|---|
| `0,0` | 5x8 | `0,1` | 5x5 |
| `1,0` | 5x10 | `0,2` | 6x5 |
| `2,0` | 5x11 | `0,3` | 4x5 |
| `3,0` | 5x6 | `0,4` | 4x4 |
| `4,0` | 5x8 (second matrix) | `1,1` | 6x14 |

The slot position is `startX + i*32, startY + j*32`. Each slot gets a name like `RVLife_5x8_17` and a record `{spawnName, x, y, occupied=false}` stored in `RVLifeMapData.RegisteredSpawns[dim]`.

Each slot is registered with the Basements API:

```lua
api:registerBasementSpawnLocation("Muldraugh, KY", spawnName, "Basement",
    x, y, -1, width, height, { Access = pzby })
```
(`RVLifeUpdate.lua:118-121`, and again on every entry in `RVLifeClient.lua:229-237`)

The `Access` value is a `.pzby` file chosen at random from `RVLifeMapData.AvailablePzby[dim]` (`RVLifeMapData.lua:110-169`). Some vehicles are pinned to a specific interior through `SpecificVehicleAssignments`. Each size also gets `api:addAccessDefinitions(...)` with `stairx=0, stairy=0, stairDir="N"`.

### 2.3 Vehicle → interior assignment

- Each supported vehicle script name maps to a size string through `VehicleDimensionMapping`. The table is merged from about 45 per-mod definition files (`modsToLoad`, `RVLifeMapData.lua:47-93`) so other vehicle mods can be supported.
- On first entry, `getNextAvailableSpawn(dim)` marks the first unoccupied slot as occupied. The slot name and `.pzby` are then stored in the **vehicle's** modData: `RVLife_spawnName`, `RVLife_pzby`, `RVLife_spawnDim` (`RVLifeClient.lua:196-220`). Later entries reuse them. Each vehicle therefore gets a persistent personal interior.
- `RegisteredSpawns` is persisted in global ModData `"RVLifeModData"` (`server/RVLifeServer.lua`, every ten in-game minutes). When a vehicle is destroyed, `OnVehicleDestroyed` frees the slot (`occupied=false`).

---

## 3. How the teleport works

All of this is in `client/RVLifeClient.lua`.

### 3.1 Entry points
- **Context menu:** `RVLifeFunction.CreateRVLifeContextMenu` is hooked to `OnFillWorldObjectContextMenu`. It adds "Enter" only when a supported vehicle is within 3 tiles (`minDistSq = 9`, same Z) and a free interior exists or one is already assigned. When the player is already inside, it adds "Exit" instead.
- **Vehicle radial menu:** `ISVehicleMenu.showRadialMenu` is wrapped on `OnGameStart`. The original runs first, then an Enter or Exit slice is added (`RVLife_HijackRadialMenu`).

### 3.2 Checks before entering (`GetInToVehicleRVLife`, lines 282-294)
1. A supported vehicle is nearby.
2. The player is not seated in a vehicle.
3. No zombie within ±10 tiles of the vehicle (`IsZombieNearby`).
4. The player has the vehicle key, or the vehicle is hotwired or has keys in the ignition. A per-vehicle `NoKeyRequired` list exempts some (trailers, for example).

### 3.3 The teleport itself (`GetInToRVLife`, lines 179-281)

1. Look up the vehicle's size and assigned slot (§2.3).
2. Re-register the slot with the Basements API.
3. Save a return record in **player** modData `RVLifeinterior`: `LinkedVehicleID`, `LinkedVehiclePos`, `PlayerLocation` (the position to return to), and `AssignedSpawnName`.
4. Move the player:

```lua
player:setX(x + 2);  player:setY(y + 3);  player:setZ(-1)   -- 4x4: (x+2, y+2)
player:setLastX(x + 2); player:setLastY(y + 3); player:setLastZ(-1)
```
   Setting the `Last*` values as well keeps the engine from interpolating or detecting a huge movement jump.
5. For two seconds (`OnTick`) `pushNearbyZombies` staggers any zombie within 2 tiles of the player. This covers the arrival case where the player is placed next to the vehicle's former neighbors.

### 3.4 Leaving (`GetOutFromRVLife`, lines 295-307)
Reads `PlayerLocation` back from modData and does the same `setX/Y/Z` plus `setLast*` calls. It then clears the saved location. If the record is missing it silently does nothing.

### 3.5 "Am I inside?" test (`CheckIfInRVLife`, line 308)
```lua
return z == -1 or z >= 100000
```
The check uses only the Z level: `z == -1` or `z >= 100000`. The mod adds no separate "inside" flag. The `>= 100000` branch is a guess on my part (a possible fallback for another dimension scheme). I could not confirm it from this code.

### 3.6 Supporting systems
- `shared/ZombieCleaner.lua` removes every zombie inside the reserved rectangle at z = 0 and z = -1, on load, every ten minutes, and every hour.
- `shared/RVLifeMigration.lua` swaps player-crafted tile sprites (`crafted_*`, `carpentry_*`) for `camping_01_16` near the player inside the area. This is a cleanup for older saves.

---

## 4. How the interior gets unlimited power

There are two cooperating mechanisms. Mechanism A is the one that provably works through the game engine.

### 4.1 Mechanism A: hidden, auto-refueled generator above each interior (`RVLifeClient.lua:315-345`)

`CheckAndMaintainGenerators` is registered on `EveryTenMinutes` (added inside an `OnLoadMapZones` handler). For **every registered spawn, occupied or not**, it looks at the square at `(spawn.x, spawn.y, z = 0)`. That is the same X/Y as the interior's corner, one level above it.

- **No generator there:** it creates one:
```lua
local genItem = instanceItem("Base.Generator_Blue")
local g = IsoGenerator.new(genItem, getCell(), square)
g:setCondition(100); g:setConnected(true); g:setActivated(true)
g:setFuel(100); g:setSprite(nil); g:transmitCompleteItemToClients()
```
  `setSprite(nil)` makes it invisible.
- **Generator already there:** it resets `setFuel(100)`, `setActivated(true)`, `setCondition(100)`.

Why this powers the interior (engine side, v42.20.4):

- `IsoGridSquare.haveElectricity()` (`IsoGridSquare.java:10458`) returns true when `chunk.isGeneratorPoweringSquare(x, y, z)` finds an active generator, unless the sandbox option disallows exterior generators and the square is flagged `exterior`.
- `IsoGenerator.isPoweringSquare` (`IsoGenerator.java:714-720`) is true when `z` is within `generatorVerticalPowerRange` of the generator's Z and the horizontal distance is within `generatorTileRange`. Both values come from sandbox options (`setGeneratorRange`, lines 111-115). `generatorVerticalPowerRange` defaults to 3 in the field initializer, and I did not check the sandbox default. **A generator at z = 0 therefore covers z = -1 as long as the vertical range is at least 1.**
- The generator sits at the interior's corner (the 0,0 tile). The interiors are at most 14 tiles long (6x14), so they depend on the tile range being large enough to reach the far end. I did not check the sandbox default for `generatorTileRange`.
- Because this is a real `IsoGenerator`, **all Java-side consumers see power**: `IsoLightSwitch`, fridges, stoves, radios and TVs, `IsoCarBatteryCharger`, and others.

Why the fuel is "unlimited":

- The generator burns fuel and condition normally (`IsoGenerator.java:215-224`). If fuel or condition reach 0 it switches off.
- The mod refills fuel and condition to the maximum every 10 in-game minutes. `setFuel` clamps its argument to 0–10 (`IsoGenerator.java:512`), so `setFuel(100)` just means "full". Each 10-minute top-up is a full tank, so the generator never runs dry unless the refill is skipped.
- The generator is also pre-connected and pre-activated, so the player never has to interact with it. It is invisible and sits at z = 0 over an unused area.

### 4.2 Mechanism B: Lua override of `haveElectricity` (`server/LocalPowerZone.lua`)

```lua
LocalPowerZone._oldHaveElectricity = IsoGridSquare.haveElectricity
function IsoGridSquare:haveElectricity()
    if LocalPowerZone:isInZone(self) then return true end
    return LocalPowerZone._oldHaveElectricity(self)
end
```

- `LocalPowerZone.GeneratePowerZones()` builds a list of rectangles `(x, y, x+w-1, y+h-1, z=-1)`, one per **occupied** slot. It runs on `OnLoadMapZones`, on `OnGameStart`, every ten minutes, when a vehicle is first assigned an interior, and when one is destroyed.
- `isInZone(sq)` is a plain bounds check on the square's X/Y/Z.
- The file starts with `if isClient() then return end`, so it runs only on the server or in singleplayer.

### 4.3 Caveat on Mechanism B (my analysis, not tested in game)

Overriding a Java method from Lua only affects **Lua callers** of that method. The engine's own Java code calls `haveElectricity()` directly and never sees the Lua replacement. In v42.20.4 the Java-side callers include `IsoLightSwitch` (lines 91, 429, 442), `ItemContainer`, `IsoObject`, `IsoLightSource`, `IsoRoomLight`, `ObjectAmbientEmitters`, `LightingJNI`, `DeviceData`, `Food`, and `IsoCarBatteryCharger`. In `media42_20_4/` only six Lua references (in four files: `ISVehicleMenu`, `ISButtonPrompt`, `ISWorldObjectContextMenu`, and a debug panel) would see the override.

Likely effect: the override probably makes Lua UI checks, such as context-menu options that require a powered square, report "powered". That would make sense for options that look at `square:haveElectricity()` directly. The actual lights, fridges and appliances depend on Mechanism A. **I have not verified in game which of the two mechanisms is doing the visible work. A test would be to disable the generator code and see whether the lights still turn on.**

---

## 5. Lessons and caveats for our own mods

1. **The Basements dependency is not in this repo.** The mod calls `Basements.getAPIv1()`, `registerBasementSpawnLocation`, and `addAccessDefinitions`, but `mod.info` has no `require=` line. No file in `zombie42_20_4`, `media42_20_4`, or `notmymods` defines these functions, so they come from a separate Basements mod that is not on disk here. I have not read its source, so the details of how it stamps `.pzby` files into the world are unverified.
2. **Teleporting is cheap.** The `setX/Y/Z` plus `setLast*` pattern is the whole trick. The hard parts are keeping the destination chunk loaded and preventing zombies from existing there, hence the cleaner.
3. **Power by generator is more robust than hacking `haveElectricity`.** An invisible, always-on, auto-refueled `IsoGenerator` plugs into every Java power check. Hooking `haveElectricity` in Lua only reaches Lua callers.
4. **Possible issues I noticed (not verified in game):**
   - `RVLifeUpdate.lua` restarts `spawnIndex` at 1 for each matrix. Two matrices use the 5x8 size (`0,0` and `4,0`), so both can produce spawn names `RVLife_5x8_1…64`. Name-based lookups (`getSpawnByName`) would then find the first match only.
   - `CheckAndMaintainGenerators` lives in a `client/` file. In multiplayer it would run on each client, and creating `IsoGenerator` objects on a client looks suspect. Only singleplayer and host-listen servers get a proper server-authoritative run. I did not test this.
   - Generators are maintained for **all** slots, including unoccupied ones, whenever the chunk is loaded. That is harmless but wasteful.
   - `GetOutFromRVLife` returns the player to the saved coordinates, not to the vehicle's current position. If the vehicle was moved while the player was inside (possible in multiplayer), the player lands at the old spot.
5. **License:** the mod forbids redistribution and modified versions. Treat this as study material only. Re-implement the ideas independently.

---

## 6. File index

| File | Role |
|---|---|
| `client/RVLifeClient.lua` | Menus, entry/exit teleport, zombie push, generator maintenance |
| `client/RVLifeUpdate.lua` | Builds spawn grid, registers basement spawns and access definitions |
| `server/RVLifeServer.lua` | Persists `RegisteredSpawns`; frees slots on vehicle destruction |
| `server/LocalPowerZone.lua` | `haveElectricity` override and power-zone list |
| `shared/RVLifeInterior/RVLifeMapData.lua` | Vehicle→size mapping, `.pzby` lists, spawn-allocation helpers |
| `shared/RVLifeInterior/modDefinitions/*.lua` | Per-vehicle-mod size and interior assignments |
| `shared/ZombieCleaner.lua` | Removes zombies in the reserved area |
| `shared/RVLifeMigration.lua` | Replaces old crafted tiles near the player in the reserved area |
| `media/binmap`, `media/basement_access` (`*.pzby`) | Interior layouts (binary, not examined) |
