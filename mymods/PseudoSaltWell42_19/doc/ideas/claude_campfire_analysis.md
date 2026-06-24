# Campfire Error Analysis

**Created:** 2026-06-23 (revised)
**Version:** Project Zomboid 42.19 (decompiled reference in `zombie42_19/`)
**Source:** `mymods/PseudoSaltWell42_19/doc/ideas/errorCampfire.txt`,
`mymods/PseudoSaltWell42_19/doc/console.txt`

**Correction to first draft:** an earlier version of this document concluded the
bug was a vanilla engine issue independent of the mod. Ed confirmed the error
does **not** occur with the mod disabled, which rules that theory out — Lua
content mods cannot change a Java constructor's available overloads, so if
the same 5-argument `ItemContainer.new(...)` call only fails with the mod
loaded, the mod must be changing something else that the build path depends
on. Investigating further turned up a concrete, mod-side cause below.

## The Error

`console.txt` (~line 1282, repeated ~line 1604):

```
ERROR: General      f:5176> Lua(Vanilla).addContainer> Exception thrown
java.lang.RuntimeException: No implementation found for function: new(class java.lang.String campfire,
class zombie.iso.IsoGridSquare ..., class zombie.iso.objects.IsoThumpable Campfire:camping_01_6:..., 
class java.lang.Double 1.0, class java.lang.Double 1.0)) at MultiLuaJavaInvoker.call

Stack trace:
    Lua(Vanilla).addContainer(SCampfireGlobalObject.lua:103)
    Lua(Vanilla).OnCreate(buildRecipeCode.lua:520)   -- BuildRecipeCode.campfire.OnCreate
    Lua(Vanilla).setInfo(ISBuildIsoEntity.lua:739)
    Lua(Vanilla).create(ISBuildIsoEntity.lua:584)
    Lua(Vanilla).perform(ISBuildAction.lua:229)
```

The failing object is literally a vanilla `Campfire:camping_01_6`, built
through vanilla's own `BuildRecipeCode.campfire.OnCreate` →
`SCampfireGlobalObject:addContainer()`
(`media/lua/server/Camping/SCampfireGlobalObject.lua:103`):

```lua
container = ItemContainer.new("campfire", square, isoObject, 1, 1)
```

`zombie42_19/inventory/ItemContainer.java` only exposes 0/1/3/4-argument
constructors — nothing matching `(String, IsoGridSquare, IsoObject, Double,
Double)`. On its own, that line should fail identically whether or not any
mod is loaded, since Java constructor overloads are fixed at compile time and
can't be altered by a Lua/content mod. **That's the part the first draft got
wrong**: the line itself isn't the variable — something about the campfire
*global object system* finding/processing this object differently when the
mod is active is what makes this code path actually run (or run twice) only
in that case.

## Root Cause: `pseudoed_salt_01.tiles` Ships the Entire Vanilla Tile-Properties Database

`PseudoSaltWell\common\media\pseudoed_salt_01.tiles` is a binary TileZed
"tile properties" export (`tdef` format). Extracting the embedded tileset
names shows it isn't scoped to the mod's own art — it contains property
blocks for **~190 vanilla tilesheets** (`appliances_cooking_01`,
`furniture_storage_01`, every `location_*` set, `walls_*`, `floors_*`,
`vegetation_*`, etc.), and the mod's own `pseudoed_01` tileset is just the
*last* entry, tacked on at the very end of the file.

Critically, it includes a full property block for vanilla's own `camping_01`
tileset (the real campfire/camping tiles), starting around the
`camping_01` / `camping_01.png` marker, with entries like:

```
BlocksPlacement
solidtrans
CanScrap
Material
Stone
ScrapSize
Small
container
campfire
lightB / lightG / lightR
lightswitch
```

i.e. it re-declares (from the modder's own TileZed project snapshot) the same
`container = campfire` property pairing vanilla uses to mark camping tiles as
campfire objects — for the *vanilla* tileset, not the mod's own.

This is a classic TileZed export mistake: TileZed dumps tile properties for
every tileset referenced in the current project, not just the tileset you
intended to ship. Since the well's sprite was created by copying the
`camping_01` tile, that tileset was loaded in the TileZed project, so its
*entire* property table got swept into the exported `.tiles` file alongside
the mod's own tile.

By contrast, the mod's actual own tile entries (found right after the
`pseudoed_01` / `pseudoed_01.png` marker near the end of the file) carry only
`CustomName = "Saltwater Well"` (and a `CustomName = "Clay Kiln"` entry for
what looks like a planned/future tile) — no `container`/`campfire` property
at all. So the well object itself isn't being mis-detected as a campfire.
What's happening is broader: the mod is shipping a duplicate, independently
generated copy of vanilla's entire tile property table (including
`camping_01`'s campfire-related properties) inside its own `.tiles` file.

When Project Zomboid loads this mod, it merges this redundant property data
on top of/alongside the real vanilla tile-properties table. A duplicate or
mismatched-generation copy of the `camping_01` properties is consistent with
double-registering or corrupting whatever data the campfire global-object
system (`SCampfireSystem` / `SGlobalObjects` "campfire") uses to attach
container behavior to camping tiles — which is exactly the system that ends
up invoking the broken 5-argument `ItemContainer.new(...)` call. Without the
mod, vanilla's tile property table is internally consistent and this call
path apparently isn't exercised the same way (or vanilla's own container
plumbing for campfires takes a different, working route that the duplicate
data disrupts).

## Why Ovens Are Unaffected

There's no oven-equivalent global-object Lua file pulling from this
property table in the same way, and (per the tileset list above)
`appliances_cooking_01` — the oven's tileset — has no campfire/container
overlap with `camping_01`. The duplication problem is specific to whichever
vanilla tilesets got swept into this export, and ovens aren't on that list in
a conflicting way.

## Relation to the Saltwater Well Sprite

Ed's original hypothesis — "I copied the campfire sprite for the well, maybe
that's the problem" — was directionally right, just not in the way first
suspected. It's not that the *well's own tile* (`pseudoed_01_6`) carries
leftover campfire properties (it doesn't — it only has `CustomName`). It's
that the **TileZed project used to make that copy** still had the vanilla
`camping_01` tileset loaded, and exporting tile properties from that project
swept the *entire* vanilla tileset library into the mod's own `.tiles` file.

## Suggested Next Steps

1. **Confirm in TileZed/WorldEd**: open the project that generated
   `pseudoed_salt_01.tiles` and check whether export was done via "export
   tile properties for this tileset only" vs. "export all" / a Lots Pack
   wide export. The fix is almost certainly to re-export scoped to only the
   `pseudoed_01` tileset, or hand-edit the `.tiles` file to strip every
   block except the `pseudoed_01` one.
2. **Verify the fix**: after re-exporting/trimming, reload the mod and try
   building/accessing a vanilla campfire again — the `ItemContainer.new`
   exception should disappear once vanilla's `camping_01` properties are no
   longer being redundantly shipped by the mod.
3. **No sprite/graphics changes needed** — the well's own tile properties
   are clean; this is purely a packaging/export issue with the `.tiles`
   file, not a property set on the well sprite itself.
