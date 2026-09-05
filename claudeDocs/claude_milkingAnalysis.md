# Milking System Analysis (Cows)

**Created:** 2026-09-05
**Game Version:** Project Zomboid 42.20.4 (decompiled Java) / current `media/` Lua
**Purpose:** Understand the vanilla milking pipeline well enough to build a mod that lets the player milk a cow into a container that is **not** in the player's inventory (e.g. a bucket/trough/churn sitting on the ground or built into a structure).

**Sources:**
- `media/lua/shared/TimedActions/Animals/ISMilkAnimal.lua`
- `media/lua/client/ISUI/Animal/ISAnimalContextMenu.lua`
- `zombie42_20_4/characters/animals/IsoAnimal.java`
- `zombie42_20_4/characters/animals/datas/AnimalBreed.java`
- `zombie42_20_4/inventory/ItemContainer.java`
- `zombie42_20_4/entity/components/fluids/FluidContainer.java`
- `zombie42_20_4/ai/states/player/PlayerMilkAnimalState.java`
- `media/lua/shared/Definitions/animal/CowDefinitions.lua`
- `claude_troughAnalysis.md` (existing analysis of a world object with its own `FluidContainer`)
- `mymods/PseudoButterChurner/.../AutoButterChurnCode.lua` (existing precedent in this project for manipulating a world item's `FluidContainer` directly)

## Overview

Milking is implemented as a timed action (`ISMilkAnimal`) layered on top of one Java engine method, `IsoAnimal.milkAnimal(IsoGameCharacter, InventoryItem)`. The engine method itself has **no dependency on the container being in the player's inventory** — it just needs any `InventoryItem` reference with a `FluidContainer` component. Every restriction that ties milking to "a bucket in your inventory" lives in the Lua layer (context menu construction, `ISMilkAnimal:isValid()`/`:milk()`), not in the underlying game logic. That's the key fact that makes a "milk into a non-inventory container" mod straightforward.

## The Data Model

### Where milk comes from: `AnimalData` / `AnimalBreed`

- Each cow's `AnimalBreed` (`CowDefinitions.lua`) sets `milkType = "CowMilk"` — a fluid type, not an item type. All three cow breeds (`angus`, `simmental`, `holstein`) share `CowMilk` but differ in `maxMilk` gene ranges (angus 0.05–0.2, simmental 0.3–0.5, etc.), meaning yield is genetic/breed-driven, not fixed.
- `IsoAnimal.getData().getMilkQuantity()` is the current available milk pool on the animal (regenerates over time, presumably via `updateLastTimeMilked()`); `canBeMilked()` reflects `AnimalDefinitions.canBeMilked` (species-level flag); `readyToBeMilked()` (`IsoAnimal.java:3292`) is `milkQty > 1.0F && canBeMilked()`.
- `getMilkType()` (`IsoAnimal.java:1842`) just proxies `getBreed().milkType`.

### The actual transfer: `IsoAnimal.milkAnimal()`

```java
// IsoAnimal.java:1852
public InventoryItem milkAnimal(IsoGameCharacter chr, InventoryItem bucket) {
    float minQty = Math.min(0.1F,
        !bucket.isEquipped() && !chr.isEquippedClothing(bucket)
            ? chr.getFreeInventoryCapacity()
            : chr.getFreeInventoryCapacity() / (float)ZomboidGlobals.equippedOrWornEncumbranceMultiplier);
    if (this.data.milkQty < minQty) return null;

    if (!bucket.getFluidContainer().isFull() && !(minQty <= 0.0F)) {
        this.getData().updateLastTimeMilked();
        this.getData().canHaveMilk = true;
        float quantity = bucket.getFluidContainer().getAmount();
        bucket.getFluidContainer().addFluid(this.getBreed().getMilkType(), minQty);
        quantity = bucket.getFluidContainer().getAmount() - quantity;
        this.getData().setMilkQuantity(this.data.milkQty - quantity);
        this.milkRemoved++;
        // grants Husbandry XP, occasionally raises animal stress, ...
    }
    return bucket;
}
```

Important observations:
1. **`bucket` is just an `InventoryItem`.** The method calls `bucket.getFluidContainer().addFluid(...)` directly. It never calls `chr.getInventory().contains(bucket)` or anything that verifies the item is actually held by the character. Any `InventoryItem` with a `FluidContainer` component works, wherever it physically "lives" (player inventory, floor, embedded in a world object).
2. **The only place `chr` is used to gate the transfer is `getFreeInventoryCapacity()`**, which caps how much milk can be added per tick based on how much *carrying capacity* the player has free — a vestigial anti-cheese constraint from the assumption that the bucket occupies inventory weight. If the container is not in the player's inventory, this constraint no longer models anything real, but it isn't strictly blocking (a player with some free capacity still gets milk transferred each tick; a player with a fully-loaded inventory would get `minQty <= 0` and nothing added). A modded action can bypass this by either accepting the vanilla cap (harmless, just occasionally throttles) or reimplementing the transfer with `FluidContainer.addFluid()`/`transferFrom()` directly instead of calling `milkAnimal()`.
3. **XP and stress side effects are tied to `chr`, not to the bucket**, so a modded action retains full Husbandry XP gain and animal-stress mechanics regardless of where the milk ends up.

### `FluidContainer` doesn't care about ownership either

`FluidContainer.java` is a `Component` that can be attached to the `owner` field of either an `InventoryItem` **or** an `IsoWorldInventoryObject` (an item instance sitting in the world, e.g. on the ground or inside a custom placed object) — see `getRainCatcher()`, `getUiName()`, and `isMultiTileMoveable()`, all of which explicitly branch on `this.getOwner() instanceof InventoryItem` vs `instanceof IsoWorldInventoryObject`. `addFluid()`, `removeFluid()`, `transferTo()`/`transferFrom()` are all plain instance methods with no inventory/ownership checks at all — they only look at capacity, whitelist/blacklist filters, and `inputLocked`/`canPlayerEmpty` flags.

This is exactly the mechanism `claude_troughAnalysis.md` documents for `IsoFeedingTrough`: a world object (`IsoObject` subclass) can own a `FluidContainer` directly, entirely independent of any player's inventory, and existing vanilla code (`ISAddWaterToTrough`) already pours fluid from a held item into such a world-owned `FluidContainer` via `luaObject:addWater(toremove)` → the object's own `FluidContainer.addFluid()`.

This project's own `PseudoButterChurner` mod (`AutoButterChurnCode.lua`) independently confirms the same pattern works for milk specifically: it manipulates `item:getFluidContainer():addFluid("CowMilk", amount)` on an `InventoryItem` sitting inside a world entity's item slot (a `Resources` component resource, not the player's inventory) with no special-casing needed for the milk fluid type.

## Where the "must be in inventory" Constraint Actually Lives (Lua, not Java)

### `ISAnimalContextMenu.lua`

- Line 202-203: the milk submenu is only populated from `playerInv:getAvailableFluidContainer(animal:getData():getBreed():getMilkType())` — i.e. it enumerates **only the player's own `ItemContainer`** (`ItemContainer.getAvailableFluidContainer()`, `ItemContainer.java:2803`, which iterates `this.items` — the container's own item list).
- Line 218-222: if `playerObj:hasFullInventory()`, the whole milk option is disabled outright (`notAvailable = true`) — this is a pure inventory-weight gate that has nothing to do with whether a valid container exists elsewhere.
- Line 864 (`AnimalContextMenu.onMilkAnimal`) walks the character to the cow and queues `ISMilkAnimal:new(chr, animal, bucket, right, all)` — `bucket` is whatever `InventoryItem` was chosen from the submenu above.

### `ISMilkAnimal.lua` (the timed action)

- `isValid()` (line 5-7): requires `not self.character:hasFullInventory()` — again a pure carry-weight gate, unrelated to the bucket's own capacity.
- `milk()` (line 57-118): if the current bucket becomes full/missing and `self.all` was set, it re-searches with `self.character:getInventory():getFirstAvailableFluidContainer(...)` and `self.character:getInventory():getItemsFromFullType(...)` — **both scoped to the character's own `ItemContainer`**. This is the "auto-swap to next empty bucket" convenience feature, and it's the main place a world-container-based rewrite needs new logic (there is no "next container" to look for on the ground/in a fixed structure — capacity is just whatever the single target container has).
- `stress()` (line 14-55): on high stress, spills the bucket and **removes it from the character's inventory and drops it on the ground** (`self.character:getInventory():Remove(self.bucket)`, `sendRemoveItemFromContainer`, `AddWorldInventoryItem`). This logic assumes the bucket started in inventory; a rewrite targeting a fixed world container should instead just call `removeFluid()` on that container in place (no need to "drop" something already outside the inventory).
- `start()`/`update()`/`animEvent()` drive the milking animation via character variables (`milkanimal`, `milkanimalout`, `milkAnim`, `AnimalSizeX/Y`) and call `self.animal:milkAnimal(self.character, self.bucket)` once per `timePerLiter` (40 game-time units) tick on the server, then `sendServerCommandV("animal", "setMilk", ...)` to sync the animal's remaining milk to clients. None of this is inventory-dependent — it operates on `self.bucket`, whatever `InventoryItem` that happens to reference.

### `PlayerMilkAnimalState.java`

Purely an animation-state mirror (`milkanimal`, `animal`, `AnimalSizeY`, `milkAnim` variables synced client authoritative → replicated), no inventory logic at all. The milking animation plays regardless of where the target container lives.

## Implication for a "Milk Into a Non-Inventory Container" Mod

Given the above, the vanilla restriction to "bucket must be in your inventory" is a **UI/Lua-layer choice, not an engine limitation**. A mod has two viable strategies, in increasing order of how much vanilla code is reused:

### Option A — Reuse `ISMilkAnimal` almost as-is, but target a world-owned `InventoryItem`

Write a derived/parallel timed action (based directly on `ISMilkAnimal.lua`) whose `self.bucket` is not fetched from `character:getInventory()` but instead resolved from:
- an `IsoWorldInventoryObject` sitting on a nearby tile (a dropped bucket you don't pick up), or
- an `InventoryItem` embedded in a custom placed object's item/resource slot (the same pattern `IsoFeedingTrough` and `PseudoButterChurner`'s churn already use).

Everything downstream — `self.animal:milkAnimal(self.character, self.bucket)`, `bucket:sendSyncEntity(nil)`, `bucket:setJobDelta(...)` for the fill-progress overlay — keeps working unmodified, since `milkAnimal()` only calls `bucket.getFluidContainer()` methods. Changes needed relative to vanilla:
- `isValid()` / the "no container" bailout: drop the `hasFullInventory()` checks (irrelevant once the bucket isn't inventory weight) and instead validate that the world container/object still exists and is in range.
- `stress()`'s spill-and-drop logic: since the bucket is never "in" the character, skip the `Inventory:Remove`/`AddWorldInventoryItem` steps — just call `self.bucket:getFluidContainer():removeFluid()` in place, and possibly knock over/disturb the world object visually instead.
- The "auto pick next bucket when full" branch (`self.all`) doesn't apply to a single fixed world container — a full container should simply stop the action (`forceComplete`/`forceStop`) as vanilla already does when no container is available at all.
- Context menu construction: instead of enumerating `playerInv:getAvailableFluidContainer(...)`, enumerate nearby world objects/`IsoWorldInventoryObject`s within milking range (`animal:getSquare():DistTo(...) < 3`, matching `isValid()`'s own range check) that have a compatible empty/partial `FluidContainer` for `animal:getData():getBreed():getMilkType()`.

### Option B — Bypass `milkAnimal()` entirely, drive the `FluidContainer` transfer yourself

Since `milkAnimal()`'s only real logic (beyond the fluid transfer) is XP grant, stress change, and depleting `animal:getData()`'s milk pool, a mod could instead:
1. Check `animal:getData():getMilkQuantity() >= someAmount` and `animal:canBeMilked()`.
2. Call `targetContainer:getFluidContainer():addFluid(animal:getBreed():getMilkType(), amount)` directly on the world object's/embedded item's `FluidContainer` (exactly as `AutoButterChurnCode.lua` already does for `CowMilk`), clamped by `getFreeCapacity()`.
3. Manually replicate the side effects: `animal:getData():setMilkQuantity(animal:getData():getMilkQuantity() - amount)`, `animal:getData():updateLastTimeMilked()`, Husbandry XP via `GameServer.addXp(...)`/`chr:getXp():AddXP(...)`, and occasional `animal:changeStress(...)`.

This gives full control (e.g. letting the cow "free-drip" into a trough over time without a player-driven timed action at all — a passive milking stall), at the cost of re-implementing bookkeeping vanilla already provides for free via `milkAnimal()`.

**Recommendation:** Option A is the lower-risk path for a player-initiated "milk the cow into that bucket over there" interaction, since it reuses the vanilla animation/timing/XP/stress pipeline verbatim and only replaces where `self.bucket` comes from and how "no more room" is handled. Option B is better suited to an automated/passive structure (e.g. a "milking stall" the cow stands in that fills a trough on its own, mirroring how `IsoFeedingTrough` already lets animals interact with a world `FluidContainer` without any player action).

## Container Compatibility Notes

- `FluidType`/`Fluid.CowMilk` — no whitelist/blacklist restrictions were found specific to milk; any `FluidContainer` without a blocking whitelist accepts it as long as `canAddFluid()` passes (capacity, blend compatibility with existing contents, no `inputLocked`).
- `ISAnimalContextMenu.lua:34-62` shows the game already treats `Fluid.AnimalMilk` as a generic "any species' milk" fluid alias alongside the breed-specific type (e.g. `CowMilk`) when matching feed/food eligibility — worth checking if a custom trough/churn should accept both the specific and generic milk fluids the same way vanilla feed-checking logic does.
- A custom target container only needs a `FluidContainer` component (script-defined via `FluidContainerScript`, i.e. any item or `IsoObject` with `[FluidContainer] ... [/FluidContainer]` in its script definition) — it does not need to be an `InventoryItem` subtype used anywhere else in vanilla; a bespoke "milk pail on a stand" object works exactly like `IsoFeedingTrough`'s `FluidContainer`.

## Summary

Milking a cow into a container outside the player's inventory is **not blocked by the engine** — `IsoAnimal.milkAnimal()` and `FluidContainer` operate on any `InventoryItem`/owner reference regardless of location, exactly the pattern `IsoFeedingTrough` (vanilla) and this project's own `PseudoButterChurner` mod (`AutoButterChurnCode.lua`) already exploit for water and milk respectively. The vanilla restriction to "must be a bucket you're carrying" is entirely a Lua-layer choice in `ISAnimalContextMenu.lua` (context menu enumeration + `hasFullInventory()` gates) and `ISMilkAnimal.lua` (inventory-scoped container lookup and stress-spill logic). A mod can fork `ISMilkAnimal` to target a world-placed or object-embedded `FluidContainer` instead of an inventory item, reusing the vanilla animation, timing, XP, and stress systems unmodified — this is Option A above, and the recommended approach for a player-driven "milk into that bucket/trough over there" feature.
