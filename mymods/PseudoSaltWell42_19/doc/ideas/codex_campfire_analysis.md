# Campfire Error Analysis - Speculative Notes

**Created:** 2026-06-24  
**Game version in log:** Project Zomboid 42.19.0  
**Input files:** `doc/ideas/errorCampfire.txt`, `doc/console.txt`

## Short Version

The campfire crash is probably not caused by oven/cooking logic. The error is happening while vanilla campfire code tries to create the campfire inventory container.

The strongest clue is this console line:

```text
No implementation found for function: new(class java.lang.String campfire,
class zombie.iso.IsoGridSquare ...,
class zombie.iso.objects.IsoThumpable Campfire:camping_01_6:camping_01_6:...,
class java.lang.Double 1.0,
class java.lang.Double 1.0))
```

Vanilla `SCampfireGlobalObject:addContainer()` calls:

```lua
container = ItemContainer.new("campfire", square, isoObject, 1, 1)
```

That is at `media/lua/server/Camping/SCampfireGlobalObject.lua:103`.

In B42.19's Java source, `ItemContainer` has constructors for:

- `ItemContainer(int id, String containerName, IsoGridSquare square, IsoObject parent)`
- `ItemContainer(String containerName, IsoGridSquare square, IsoObject parent)`
- `ItemContainer(int id)`
- `ItemContainer()`

Those are in `zombie42_19/inventory/ItemContainer.java:119-145`.

There is no Java constructor matching:

```text
String, IsoGridSquare, IsoThumpable, Double, Double
```

So the crash is probably a B42.19 vanilla/mod compatibility bug around this Lua call, exposed when the parent object is an `IsoThumpable`.

## Why The Parent Being `IsoThumpable` Matters

The console says the parent passed into `ItemContainer.new()` is:

```text
zombie.iso.objects.IsoThumpable Campfire:camping_01_6:camping_01_6
```

That is important because B42's visible build object starts life as a thumpable. The vanilla campfire build recipe then appears intended to replace/normalize the build result into the campfire global-object system.

The relevant vanilla flow:

- `media/scripts/generated/entities/outdoors/entity_campfire.txt:14` sets `OnCreate = BuildRecipeCode.campfire.OnCreate`.
- `media/lua/server/BuildRecipeCode/buildRecipeCode.lua:511-523` creates a campfire global object, calls `luaObject:addObject()`, then calls `luaObject:addContainer()`.
- `media/lua/server/Camping/SCampfireGlobalObject.lua:73` creates the actual campfire object with `IsoObject.new(square, "camping_01_6", "Campfire")`.
- `media/lua/server/Camping/SCampfireGlobalObject.lua:100-104` then creates the `campfire` container.

The intended parent for the container therefore seems to be a normal `IsoObject`, not the temporary recipe `IsoThumpable`.

But the failing log shows the container call is still seeing an `IsoThumpable`. That suggests one of these is happening:

1. The campfire global object is resolving `getIsoObject()` to the build recipe's thumpable instead of the `IsoObject` created by `addObject()`.
2. `addObject()` is not replacing/adding the expected normal `IsoObject` before `addContainer()` runs.
3. The square contains multiple "Campfire" / `camping_01_6` objects, and lookup order returns the thumpable first.
4. B42.19's exposed Lua constructor call is stale: vanilla Lua still passes five args, but Java only exposes the three-arg/one-arg/no-arg constructors.

The last possibility is especially suspicious because the constructor failure includes the trailing `1.0, 1.0`. Even with a normal `IsoObject`, `ItemContainer.new("campfire", square, isoObject, 1, 1)` does not correspond to a Java constructor shown in `ItemContainer.java`.

## Relationship To The Salt Well Sprite

The user's hunch about the sprite is plausible, but probably not in the simple sense of "the well sprite directly breaks campfires."

Current mod well placement uses:

```lua
holeSprite = "pseudoed_01_6";
holeName = "SaltwaterWell";
self.javaObject = IsoThumpable.new(cell, self.sq, holeSprite, north, self);
```

That is in `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/server/BuildingObjects/ISLocationBasedHole.lua:42-59`.

The mod is not directly creating `camping_01_6` in the Lua source I checked. However, `PseudoSaltWell/42/mod.info` declares:

```text
pack=pseudoed_salt_01
tiledef=pseudoed_salt_01 8724
```

and the `common/media/pseudoed_salt_01.tiles` file appears to contain a very large amount of copied vanilla tile metadata, starting with vanilla-looking tiles such as `appliances_cooking_01`. That is odd for a small salt-well tile pack.

Speculation: if the custom tile pack was created by copying a large vanilla/campfire-oriented tiles file, it may include accidental properties or index mappings that interfere with vanilla sprite definitions. This could make a custom sprite behave like a container/campfire-ish object, or make the game load unexpected properties for sprites in the same tile namespace/index space.

This does not yet prove the campfire error is caused by `pseudoed_01_6`, because the failing object in the stack trace is still explicitly `Campfire:camping_01_6`. But the custom tile pack is worth auditing because it is the main mod-side thing that looks structurally risky.

## Why Ovens Do Not Fail

The user noted ovens do not produce the same error. That fits the trace.

Ovens are stove/fireplace objects with their own object classes and container setup. This crash is specifically in:

```text
Lua(Vanilla).addContainer(SCampfireGlobalObject.lua:103)
```

The failing system is the campfire global-object container path, not generic cooking.

## Existing Campfires Also Error

The console includes repeated campfire global-object load/add messages and repeated errors at `SCampfireGlobalObject.lua:103`, including after existing campfire objects are loaded from the save.

Examples:

- `doc/console.txt:1282-1287`
- `doc/console.txt:1604-1609`
- `doc/console.txt:5549-5554`

This means the problem is not limited to the first attempt to build a new campfire. It can also happen when the campfire system tries to sync or repair a campfire's container later.

## Most Likely Causes, Ranked

1. **B42.19 vanilla API mismatch in campfire container creation.**  
   `SCampfireGlobalObject.lua` passes five args to `ItemContainer.new()`, but decompiled B42.19 Java only shows constructors with four, three, one, or zero args. This is the cleanest explanation for the exact "No implementation found" message.

2. **The global-object lookup is binding to the recipe `IsoThumpable` instead of the normalized `IsoObject`.**  
   The error reports an `IsoThumpable Campfire`, which is not what `SCampfireGlobalObject:addObject()` creates. This may be a separate bug or the result of object lookup order when both the temporary thumpable and new campfire object exist on the same square.

3. **The copied tile pack contains accidental vanilla/campfire metadata.**  
   The salt well tile file is unexpectedly huge and includes many vanilla-looking tile definitions. If it was copied from a broad vanilla tile sheet, the custom tile pack may carry properties/indexes that should not be in the mod.

4. **A stale save has malformed campfire global objects.**  
   The log shows `campfire: removing luaObject ...` and existing campfires loading. If earlier test builds produced bad campfire records, a clean test save may behave differently.

## Suggested Tests

1. **Disable only PseudoSaltWell and test vanilla campfire build/access in the same PZ build.**  
   If vanilla still crashes, this is almost certainly a B42.19 vanilla campfire bug.

2. **Enable PseudoSaltWell in a brand-new save and build a campfire before placing any salt well.**  
   If it crashes, the issue is likely mod load/tile metadata or vanilla API mismatch, not a placed well object.

3. **Temporarily remove `pack=pseudoed_salt_01` / `tiledef=pseudoed_salt_01 8724` from `mod.info` and test campfire again.**  
   If campfires stop crashing, the tile pack is implicated.

4. **Rebuild `pseudoed_salt_01.tiles` so it contains only the custom salt well tile definitions.**  
   The current file appears to contain much more than the mod needs.

5. **Patch-test vanilla campfire Lua locally by removing the trailing dimensions from the constructor call.**  
   For diagnosis only, change:

   ```lua
   ItemContainer.new("campfire", square, isoObject, 1, 1)
   ```

   to:

   ```lua
   ItemContainer.new("campfire", square, isoObject)
   ```

   If the error changes or disappears, the immediate crash is confirmed as the `ItemContainer` constructor signature.

## Current Working Theory

The immediate failure is the `ItemContainer.new()` call in vanilla campfire code. B42.19's Lua calls it as if a five-argument constructor exists, but the Java class visible in this repo does not expose that constructor. The presence of `IsoThumpable Campfire` in the failing arguments adds a second clue: campfire creation/access may be operating on the build recipe thumpable rather than the normalized campfire `IsoObject`.

The salt well sprite/tile pack may be related if the copied `.tiles` file accidentally changed tile properties or sprite registration in a way that affects vanilla campfire placement. It is not proven by the trace, but it is suspicious enough to audit before chasing deeper gameplay code.
