# Washing Machine Analysis

**Created:** 2026-08-30
**Updated:** 2026-08-30 — re-verified against Project Zomboid 42.20.4
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media/`). Originally analyzed against 42.19. All cycle-timing formulas (90-in-game-minute cycle, per-minute water/blood/dirt/wetness math) are unchanged. Two things did move/change and are corrected below: `toggleClothingWasher` shifted from line 4961 to line 4966 in `ISWorldObjectContextMenuLogic.java` (the file grew ~400 lines from unrelated additions elsewhere), and `ClothingWasherLogic`/`ClothingDryerLogic` had a cosmetic refactor (a `GameTime.checkHours()` helper replaced inline bounds-checking, and the FMOD sound-parameter call was renamed) with no behavioral change.

## Summary

Unlike the [Butter Churn](claude_butterChurn.md) or the [Amphora](claude_amphoraAnalysis.md),
the washing machine (`ClothingWasher`) is **not** a scripted `entity` at all — it's a
legacy hard-coded `IsoObject` subclass, placed in the world as a Moveable/appliance object
(furniture placed from an item, like a fridge or stove), with its runtime behavior written
directly in Java rather than in the entity-component/craft-recipe script system. There is
no `craftRecipe`/`CraftBench` script file to point to for it; the whole cycle is driven by
`ClothingWasherLogic.update()`.

There are three related in-world objects sharing the same underlying logic classes:

| Object | Java class | Notes |
|---|---|---|
| Washing machine | `IsoClothingWasher` | washer only |
| Clothes dryer | `IsoClothingDryer` | dryer only |
| Combination washer/dryer | `IsoCombinationWasherDryer` | one object, switchable between washer and dryer mode |
| Stacked washer/dryer | `IsoStackedWasherDryer` | not examined in this pass — presumably a visual/placement variant only |

## Code Locations

| Purpose | File |
|---|---|
| Washing machine object (container, power draw, save/load) | `zombie42_20_4/iso/objects/IsoClothingWasher.java` |
| Washing cycle logic (the actual wash process) | `zombie42_20_4/iso/objects/ClothingWasherLogic.java` |
| Dryer object | `zombie42_20_4/iso/objects/IsoClothingDryer.java` |
| Drying cycle logic | `zombie42_20_4/iso/objects/ClothingDryerLogic.java` |
| Combined washer/dryer object (mode-switching wrapper) | `zombie42_20_4/iso/objects/IsoCombinationWasherDryer.java` |
| Shared interface both logic classes implement | `zombie42_20_4/iso/objects/interfaces/IClothingWasherDryerLogic.java` |
| Context-menu Turn On/Off option, availability checks | `zombie42_20_4/iso/ISWorldObjectContextMenuLogic.java` (`toggleClothingWasher`, line 4966) |
| UI strings | `media/lua/shared/Translate/EN/Moveables.json`, `media/lua/shared/Translate/EN/UI.json`, `media/lua/shared/Translate/EN/SurvivalGuide.json` |
| Sounds | `media/scripts/generated/sounds/objects/sounds_object_largecontainers.txt` |

## How It's Used

The washing machine is turned on/off via a context-menu option
(`ISWorldObjectContextMenuLogic.toggleClothingWasher`, line 4966-onward), which adds a
"Turn On" / "Turn Off" entry that calls back into
`ISWorldObjectContextMenu.onToggleClothingWasher` → `IsoClothingWasher.setActivated()`.
Before allowing "Turn On" to actually work, it's greyed out (`notAvailable = true`) unless
**both** of the following hold (line 5000):

```java
if (!object.getContainer().isPowered() || object.getFluidAmount() <= 0.0F) {
    option.rawset("notAvailable", true);
    ...
}
```

- **Powered**: the container must be electrically powered (main power or a nearby
  generator — `couldBePoweredByGenerator()` returns `true` and power draw while running is
  `0.09` generator-fuel units, `getGeneratorPowerConsumption()`).
- **Fluid**: `object.getFluidAmount() > 0` — the washer must be plumbed/filled with water
  (drawn from its own `FluidContainer`, i.e. `getObject().useFluid(...)`, presumably backed
  by the house's plumbing when placed on a valid water tile, though the plumbing hookup
  itself wasn't traced further in this pass).
- No detergent/soap item is required anywhere in this code path — cleanliness is handled
  purely by the elapsed-time formulas below.

## The Wash Cycle (`ClothingWasherLogic`)

`ClothingWasherLogic.update()` (`zombie42_20_4/iso/objects/ClothingWasherLogic.java`) runs
every game tick while the object exists in the world, but only does meaningful work once
per elapsed **in-game minute**, and only while `isActivated()` is true:

```java
private final float cycleLengthMinutes = 90.0F;
...
float worldAgeHours = (float) GameTime.getInstance().getWorldAgeHours();
...
float elapsedHours = worldAgeHours - this.lastUpdate;
int elapsedMinutes = (int) (elapsedHours * 60.0F);
if (elapsedMinutes >= 1) {
    this.lastUpdate = worldAgeHours;
    this.getObject().useFluid(1 * elapsedMinutes);   // 1 fluid unit per in-game minute
    ...
}
```

Per elapsed in-game minute while running, for every item currently in the
`"clothingwasher"` container:

- **Water usage:** 1 fluid unit consumed per in-game minute (so a full 90-minute cycle
  uses 90 units of water total, assuming it runs uninterrupted).
- **Clothing items** (`instanceof Clothing`):
  - Blood level reduced by `elapsedMinutes * 2` (scaled `/100` inside `removeBlood`).
  - Dirtiness reduced by `elapsedMinutes * 2` (scaled `/100` inside `removeDirt`).
  - Wetness is force-set to `100.0` every update tick (the clothes get and stay soaking wet
    for the whole cycle — this is what a subsequent dryer, or just time, later removes).
- **Non-clothing items with an `ItemAfterCleaning` mod-data entry** (e.g. items that can be
  "cleaned" into a different item type): a `CleaningProgress` counter accumulates by
  `elapsedMinutes * 3` on the first tick, then `elapsedMinutes * 2` on subsequent ticks,
  until it reaches 100, at which point the item is replaced in-place with the
  `ItemAfterCleaning` result item.
- **Any `InventoryContainer` item with blood on it** (e.g. a bloody bag) has its blood level
  reduced by `elapsedMinutes * 2 / 100`.

### Cycle Duration

`cycleFinished()` tracks when the wash started (`startTime`, an in-game-hours timestamp
captured the first update after activation) and turns the machine off automatically once:

```java
float elapsedHours = (float) GameTime.getInstance().getWorldAgeHours() - this.startTime;
int elapsedMinutes = (int) (elapsedHours * 60.0F);
if (elapsedMinutes < 90.0F) {
    return false;
}
this.cycleFinished = true;
this.setActivated(false);
```

**A wash cycle takes 90 in-game minutes** (`cycleLengthMinutes = 90.0F`) — i.e. exactly
**1.5 in-game hours**, measured against `GameTime.getWorldAgeHours()` (the game's actual
world clock, not a fixed real-time or tick-based timer as with the Butter Churn's bench
system). This means the wash duration scales directly with the sandbox "Day Length"
setting: at the default day length, 1.5 in-game hours is roughly **3.75 real-world minutes**
(1 in-game hour ≈ 2.5 real minutes at the default 1-hour-per-day setting); a slower/faster
day length setting proportionally lengthens/shortens the real time it takes.

When the cycle completes, the machine deactivates itself, plays a `ClothingWasherFinished`
sound, and the clothes are left in the (now clean, still wet) state — they are **not**
automatically dried; drying is the separate `ClothingDryerLogic` process (also gated behind
a `cycleLengthMinutes = 90.0F` in-game-clock cycle) which removes wetness (`wetness -=
elapsedMinutes` per in-game minute) and, for items with an `ItemWhenDry` mapping, eventually
swaps them for their dry counterpart once a per-item `WetCooldown` timer reaches zero.

## Combination Washer/Dryer

`IsoCombinationWasherDryer` is a single physical object that owns **both**
`ClothingWasherLogic` and `ClothingDryerLogic` instances and delegates to whichever one is
currently active (`setModeWasher()` / `setModeDryer()`), retagging the shared container
between `"clothingwasher"` and `"clothingdryer"` type when switching. Both underlying cycles
still use the same 90-in-game-minute duration; the combination unit just prevents needing
two separate objects.

## Comparison to Other Analyzed Objects

| | Butter Churn | Amphora | Washing Machine |
|---|---|---|---|
| Implementation | Scripted `entity` + `CraftBench` recipe | Scripted `entity`, `FluidContainer` only | Hard-coded `IsoObject` Java class |
| Passive process? | Yes — bench-tick recipe (`churn_butter`) | No | Yes — Java `update()` loop |
| Time unit for its process | In-game **seconds**, advanced at a fixed real-time tick rate (`EntitySimulation`, independent of Day Length) | N/A | In-game **minutes**, measured against the actual world clock (`GameTime.getWorldAgeHours()`), so it *does* scale with the sandbox Day Length setting |
| Duration | 500 in-game seconds (~8m20s game-clock / ~21 real seconds) | N/A | 90 in-game minutes (1.5 in-game hours) |
| Requires power? | No | No | Yes (electricity or generator) |
| Requires water/fluid? | Yes (consumed as recipe input, one-shot) | N/A (it *is* the fluid storage) | Yes (continuously drained, 1 unit/in-game minute) |

## Caveats / Uncertainties

- How the washer's `FluidContainer`/`getFluidAmount()` is actually filled (plumbing hookup
  to a water-supplied building vs. a manually filled tank) was not traced in this pass —
  only the consumption side (`useFluid`) was examined.
- `IsoStackedWasherDryer` was found but not opened; based on the naming and the pattern of
  the other two variants, it is assumed to be a placement/visual variant rather than having
  distinct cycle logic, but this was not confirmed from code.
- The 90-minute cycle length is a single hard-coded constant per logic class
  (`cycleLengthMinutes`, unused as a variable in the actual comparison — the literal `90.0F`
  is what's checked in `cycleFinished()`); no sandbox option, skill, or item-count factor was
  found that changes it.
- **42.20.4 note:** `ClothingWasherLogic`/`ClothingDryerLogic`'s `lastUpdate` bounds-check was
  refactored into a shared `GameTime.checkHours(lastUpdate, worldAgeHours)` helper (previously
  inline `if`/`else if`), and the "is machine loaded with noisy items" sound parameter is now
  set via `emitter.setParameterValueByName(...)` instead of looking up a `FMODManager`
  parameter description object first. Both are refactors only — the elapsed-time math, cycle
  length, and all per-minute formulas above are unchanged.
