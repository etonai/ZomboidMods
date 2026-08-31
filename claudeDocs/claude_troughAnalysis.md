# Animal Feeding Trough Analysis

**Created:** 2026-08-31
**Game Version:** Project Zomboid 42.20.4 (decompiled Java) / current `media/` Lua
**Sources:**
- `zombie42_20_4/iso/objects/IsoFeedingTrough.java`
- `media/lua/server/FeedingTrough/SFeedingTroughGlobalObject.lua`
- `media/lua/server/FeedingTrough/BuildingObjects/ISFeedingTrough.lua`
- `media/lua/shared/FeedingTrough/Definitions/FeedingTroughDefinitions.lua`
- `media/lua/client/FeedingTrough/ISUI/ISFeedingTroughMenu.lua`
- `media/lua/shared/FeedingTrough/TimedActions/ISAddWaterToTrough.lua`
- `media/lua/shared/FeedingTrough/TimedActions/ISEmptyWaterInTrough.lua`
- `zombie42_20_4/ai/states/animals/AnimalEatState.java`

## Overview

Feeding troughs are farm objects (`IsoFeedingTrough`, built via `ISFeedingTrough`) that let players stock food or water for penned animals. They come in four buildable variants defined in `FeedingTroughDefinitions.lua`: `simple`, `double`, `doublemetal`, `triplemetal`, and `quadmetal`, each with its own sprite set and `maxFeed` / `maxWater` capacity (e.g. `simple` = 25 feed / 50 water, `quadmetal` = 200 feed / 100 water). Larger troughs can span multiple tiles via a sprite grid, with one tile acting as the "master" and the rest as "slaves" (`isSlave()` in `IsoFeedingTrough.java:389`) that mirror the master's contents.

## The Core Mechanic: Food and Water Are Mutually Exclusive

This is enforced structurally, not just by a game-balance rule — a trough literally cannot hold both an `ItemContainer` (solid food items) and a `FluidContainer` (water) at the same time. Only one of the two components exists on the object at any given moment.

### Two Components, Never Both

`IsoFeedingTrough` extends `IsoObject` and can carry:
- an `ItemContainer` (`this.container`, type `"trough"`) — holds discrete `Food` items or `DrainableComboItem` animal-feed items
- a `FluidContainer` (a `GameEntity` component, added via `createFluidContainer()`) — holds water/tainted water

The switch between the two is arbitrated by `checkContainer()` (`IsoFeedingTrough.java:60-68`):

```java
public void checkContainer() {
    if (this.getFluidContainer() != null && !this.getFluidContainer().isEmpty()) {
        this.setContainer(null);
    } else if (this.getContainer() == null) {
        ItemContainer container1 = new ItemContainer();
        container1.type = "trough";
        this.setContainer(container1);
    }
}
```

Logic: if the fluid container exists and has water in it, the item container is forcibly cleared (`setContainer(null)`). Otherwise, if there's no item container, one is created. This runs every `update()` tick (`IsoFeedingTrough.java:156-160`), so the state self-corrects continuously.

### Adding Food Removes Water

`onFoodAdded()` (`IsoFeedingTrough.java:283-300`) is the food-side trigger. Its first line is:

```java
public void onFoodAdded() {
    this.removeFluidContainer();
    ...
}
```

Any water present is destroyed outright the moment food is placed — there's no partial state where both exist.

### Adding Water Overwrites Food (via `checkContainer`)

`addWater()` (`IsoFeedingTrough.java:435-440`) adds fluid to the `FluidContainer` and then calls `checkContainer()`, which — per the logic above — nulls out the item container as soon as `water > 0`. Any food items sitting in the container are simply dropped (the `ItemContainer` reference is discarded, not gracefully returned to the world).

Note this means adding **any** amount of water, even a trickle, immediately evicts food — the trough doesn't wait for a "full" threshold.

### Removing Food Restores the Fluid Container

`onRemoveFood()` (`IsoFeedingTrough.java:302-308`):

```java
public void onRemoveFood() {
    ...
    if (this.getContainer().isEmpty()) {
        this.createFluidContainer();
    }
}
```

Once the last food item is removed, the trough re-creates its `FluidContainer`, becoming water-capable again.

### Rain Water Also Displaces Food

`FluidContainer` has `setRainCatcher(0.55F)` (`IsoFeedingTrough.java:501`), so troughs passively collect rain like any open fluid container. `checkWaterFromRain()` (`IsoFeedingTrough.java:162-166`), called every `update()`:

```java
public void checkWaterFromRain() {
    if (this.getContainer() != null && !this.getContainer().isEmpty() && this.getFluidContainer() != null) {
        this.removeFluidContainer();
    }
}
```

This is a defensive check in the *other* direction: if food exists but a fluid container also exists (e.g. transient state), the fluid container is removed so rain can't silently accumulate water underneath stored food. Combined with `checkContainer()`, the two methods keep the two states from ever coexisting even under rain/tick timing edge cases.

### Item Filtering

`isItemAllowedInContainer()` (`IsoFeedingTrough.java:108-111`) restricts what can go into the item container to `Food` instances or `DrainableComboItem`s that have a non-empty `getAnimalFeedType()` (e.g. animal feed bags) — arbitrary items can't be dumped in.

### Fluid Filtering

`createFluidContainer()` (`IsoFeedingTrough.java:497-507`) whitelists only `FluidType.Water` and `FluidType.TaintedWater` — other liquids (e.g. petrol) cannot be poured into a trough via `ISAddWaterToTrough`.

## Multi-Tile Troughs Share One Logical State

For sprite-grid troughs (`double`, `triplemetal`, etc.), only the "master" tile actually owns a `container`/`FluidContainer` (`IsoFeedingTrough.java:101-105`, `checkContainer` called only on non-slaves via `addToWorld`). Slave tiles have `linkedX`/`linkedY` pointing at the master and delegate overlay/appearance lookups to it (`checkOverlay`, `IsoFeedingTrough.java:310-359`). So the food/water exclusivity rule applies to the whole multi-tile structure as a single unit, not per-tile.

## Overlay Sprites Reflect Fill State

`checkOverlay()` picks one of two overlay sprite tiers per type (`spriteFoodOverlay1/2`, `spriteWaterOverlay1/2` from the definition table) based on fill percentage thresholds:
- Water: overlay tier 1 if `10 < amount < max/2`, tier 2 if `amount >= max/2`
- Food: overlay tier 1 if `1 < amount < max/2`, tier 2 if `amount >= max/2`

Since only one of food/water can be present, only one overlay type is ever rendered on a given trough at a time — visually reinforcing the exclusivity (a trough never shows "half food, half water" styling).

## Player Interactions

- **Adding water**: `ISFeedingTroughMenu.onAddWater` → `ISAddWaterToTrough` timed action (`media/lua/shared/FeedingTrough/TimedActions/ISAddWaterToTrough.lua`). Pours from a held fluid-source item in 1-unit increments per `timePerUse` (10 game-time units), calling `luaObject:addWater(toremove)` server-side each increment. Supports "add all" via `relaunch()`, which re-equips the next full water container from inventory when the current one empties.
- **Emptying water**: `ISFeedingTroughMenu.onEmptyWater` → `ISEmptyWaterInTrough` timed action, duration scales with `getWater() * 4`. Calls `luaObject:emptyWater()` on completion, which sets `self.water = 0`.
- **Adding food**: not a dedicated timed action in the files reviewed — food items are placed via the normal container drag/drop UI, gated by `isItemAllowedInContainer`.
- **Debug-only actions** (`AnimalContextMenu.cheat` gate in `ISFeedingTroughMenu.lua:53-67`): instantly fill/empty food or water for testing.

## Animal Consumption

Animals interact with troughs via `IsoAnimal.eatFromTrough` / `drinkFromTrough` fields, driven by `AnimalEatState` (`zombie42_20_4/ai/states/animals/AnimalEatState.java`). On the `idleActionEnd` animation event, the state checks which of `drinkFromTrough`/`drinkFromRiver`/`drinkFromPuddle` vs. `eatFromGround`/general eating applies and dispatches to `animal.getData().drink()` or `.eat()` accordingly — so an animal's approach behavior already distinguishes "this trough is a water source" from "this trough is a food source," consistent with the object never being both simultaneously.

## Summary

The food/solid vs. water/liquid exclusivity on feeding troughs isn't a UI restriction — it's structural at the `GameEntity`/component level: a trough has either an `ItemContainer` or a `FluidContainer`, never both, and four separate code paths (`checkContainer`, `checkWaterFromRain`, `onFoodAdded`, `onRemoveFood`) continuously enforce that invariant from every direction (adding food, adding water, rain, and removal). This is a deliberate design constraint rather than an oversight, likely both for simplicity (one overlay/one state to render) and to mirror real-world trough usage (you wash out and repurpose a trough rather than mixing feed and water in it).
