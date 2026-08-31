# Drying Rack Analysis

**Created:** 2026-08-31
**Game Version:** Project Zomboid 42.20.4 (decompiled Java) / current `media/` scripts
**Sources:**
- `zombie42_20_4/entity/components/crafting/DryingCraftLogic.java`
- `zombie42_20_4/entity/components/crafting/CraftLogic.java`
- `zombie42_20_4/entity/components/crafting/DryingLogic.java` / `DryingLogicSystem.java` (unused-by-vanilla alternative, see §6)
- `zombie42_20_4/scripting/entity/components/crafting/DryingLogicScript.java`
- `media/scripts/generated/entities/agricultural/workstations/entity_Drying_Rack.txt`
- `media/scripts/generated/entities/agricultural/workstations/entity_Herb_Drying_Rack.txt`
- `media/scripts/generated/entities/agricultural/workstations/entity_Drying_Rack_craftRecipe.txt`
- `media/scripts/generated/entities/agricultural/workstations/entity_Herb_Drying_Rack_craftRecipe.txt`
- `media/scripts/generated/entities/animals/workstations/entity_leather_prep.txt`
- `media/scripts/entities/agricultural/workstations/entity_Drying_Rack_xuiSkin.txt`

## Overview

There are two families of drying rack in the game, both built from the same generic component pair (`component Resources` + `component DryingCraftLogic`), just pointed at different recipe tags, resource counts, and overlay art:

| Family | Entities | Recipe tag(s) | Slot count | Domain |
|---|---|---|---|---|
| Agricultural | `Drying_Rack`, `Simple_Drying_Rack` | `DryingRackGrain` | `Item@Input@20` / `Item@Output@20@StackAny` | Grain/fiber crops (corn, wheat, flax, tobacco, hemp, rye, barley, sunflower) |
| Agricultural | `Herb_Drying_Rack`, `Simple_Herb_Drying_Rack` | `DryingRackHerb` | `Item@Input@20` / `Item@Output@20@StackAny` | Herbs, peppers, seeds, petals, hay (basil, chamomile, roses, lavender, jalapeños, grass→hay, etc.) |
| Animal/leather | `DryingRackLarge`, `DryingRackMedium`, `DryingRackSmall` | `DryLeatherLarge`/`Medium`/`Small` | `Item@Input@1` / `Item@Output@1` | Animal hides → cured leather, by species |

Each entity is built by the player via a normal `component CraftRecipe` (sticks + twine/rope + tools), then used as a standing workstation: right-click, load it with matching items, and it converts them into a different item after real time passes.

## The "Transformation" Illusion — How It Actually Works

The requested mechanic — "take items from inventory, and over time it looks like the rack turns them into a different item" — is not literal item mutation. It is three independent systems working together, and understanding the seam between them is the key to reusing this pattern:

### 1. Items are consumed into an abstract `Resources` slot, not placed as visible objects

```
component Resources
{
    group craft_inputs
    {
        Item@Input@20,
    }
    group craft_outputs
    {
        Item@Output@20@StackAny,
    }
}
```

`Item@Input@20` declares a `Resources` group that can hold up to 20 of a single item type as an entity-level "resource," entirely separate from the world/player inventory rendering pipeline. When the player interacts with the rack (via the `ISEntityWindow` UI, gated by the `xuiSkin`'s `LuaWindowClass = ISEntityWindow`), items dragged in leave the player's inventory and become resource counts on the entity — they are not spawned as loose `IsoWorldInventoryObject`s on the tile, so nothing about the rack's rendering changes just from loading it. The `@StackAny` modifier on the output group lets the output resource accept any item as a container regardless of stacking rules, since it starts empty and will hold whatever the recipe eventually creates.

### 2. `DryingCraftLogic` is the generic single-recipe crafting engine, driving a real "consume then create" recipe

```java
public class DryingCraftLogic extends CraftLogic {
    ...
    private DryingCraftLogic() {
        super(ComponentType.DryingCraftLogic);
    }
```

`DryingCraftLogic` is a thin subclass of the engine's generic `CraftLogic` component (`CraftLogic.java`) — the same base class backing ordinary crafting benches. `CraftLogic.onStart()` (`CraftLogic.java:521-527`) calls `craftData.createRecipeOutputs(true, null, null)` up front (reserving/pre-validating the eventual output) and tracks progress via a `CraftRecipeData` in `craftDataInProgress`. Ticking happens in `CraftLogicSystem` (the generic engine driver), which repeatedly calls the overridden `onUpdate()` until `elapsedTime >= recipe.getTime()`, at which point `CraftLogic` fires `luaCallOnCreate()`/actually swaps input resources for output resources.

So the input item is genuinely **destroyed** (`mode:destroy` on the recipe's `inputs` block) and the output item is genuinely **created** from scratch once the timer elapses — matching by recipe tag, not by any "morph in place" object identity. Nothing about the original `InventoryItem` survives; a brand new item is instantiated.

### 3. `SpriteOverlayConfig` is what makes it *look* continuous

Each entity declares one `SpriteOverlayConfig` `style` block per crop/hide variety (`Corn`, `Wheat`, `Tobacco`, `Herb`, `DeerLeather`, `PigLeather`, etc.), each with three fixed progress tiers — `progress 0`, `progress 50`, `progress 100` — each naming a different sprite row per facing (`face S` / `face E`):

```
component SpriteOverlayConfig
{
    style Corn { progress 0 {...} progress 50 {...} progress 100 {...} }
    style Wheat { ... }
    ...
}
```

The active `style` is selected by the currently-running recipe's own `overlayStyle` field:

```
craftRecipe DryCorn
{
    time = 172800,
    Tags = DryingRackGrain,
    overlayStyle = Corn,
    inputs { item variable[1:20] [Base.Corn] flags[ItemCount] mode:destroy, }
    outputs { item variable[1:20] Base.CornSeed, }
}
```

`CraftLogic.onUpdate()` (`CraftLogic.java:530`) calls `this.updateSpriteOverlay((int)(this.getProgress(...) * 100.0))` every tick, which picks the nearest progress tier (0/50/100) for the recipe's `overlayStyle` and swaps the rack's rendered sprite row accordingly. This is the entire "growing more dried-looking over time" visual — three discrete art states per crop type, driven purely off `elapsedTime / recipe.getTime()`, with **no connection at all** to the actual `InventoryItem` object. The player never sees the specific stalks/leaves they put in; they see generic "empty → half-dried → fully-dried" art for whichever crop-tagged style is active.

### Putting it together

The full illusion, end to end:
1. Player opens the rack's `ISEntityWindow` and drags a matching item (e.g. `Base.Corn`) into the input `Resources` slot — it vanishes from their inventory into an abstract per-entity count.
2. `DryingCraftLogic`/`CraftLogic` finds a matching `craftRecipe` by tag query (`DryingRackGrain`) whose `inputs` match what's in the slot, starts it, and begins accruing `elapsedTime` each tick (see §4 for the rate modifiers).
3. Every tick, the rack's own on-map sprite is re-picked from `SpriteOverlayConfig` using that recipe's `overlayStyle` and the current 0/50/100% bucket — giving continuous visual feedback despite the underlying state being a single float counter.
4. At `elapsedTime >= time`, the input resource count is decremented (destroyed) and the recipe's `outputs` are created fresh in the output `Resources` slot (`Base.CornSeed`) — a completely different item, ready for the player to collect via the same UI.

## 4. Real-Time Pacing: Weather and Temperature Modify the Timer

`DryingCraftLogic.onUpdate()` doesn't just add a fixed amount of elapsed time per tick — it wraps the generic `CraftLogic` timer with two environmental modifiers, tracked per in-progress `CraftRecipeData` (so multiple concurrent crafts, e.g. across linked racks, are paced independently):

**Wetness (rain/snow pauses progress):**
```java
if (ClimateManager.getInstance().getPrecipitationIntensity() > 0.0F && this.getGameEntity().isOutside()) {
    double snowModifier = ClimateManager.getInstance().getPrecipitationIsSnow() ? 0.5 : 1.0;
    double rainAmount = 0.001 * precipitationIntensity * snowModifier * secondsPerTick;
    wetness = min(wetness + rainAmount, 1.0);
} else if (wetness > 0.0) {
    double dryingAmount = 2.0E-4 * dryingFactor * secondsPerTick;
    wetness = max(wetness - dryingAmount, 0.0);
}
if (wetness > 0.0) {
    craftRecipeData.setElapsedTime(previousTickElapsedTime); // frozen, no progress this tick
} else {
    craftRecipeData.setElapsedTime(previous + secondsPerTick * dryingFactor);
}
```
An outdoor rack caught in rain/snow accumulates "wetness" instead of drying progress; while wet > 0, `elapsedTime` is simply held at last tick's value (full pause), and wetness itself drains back down afterward at a rate also scaled by `dryingFactor`.

**Temperature (`getDryingFactor()`):**
```java
float temperature = CraftUtil.getEntityTemperature(entity);
temperature = clamp(temperature, 0, 40);
temperature /= 20.0F;
if (temperature < 1.0F) temperature *= temperature;  // quadratic falloff below 20°C
return temperature;
```
This produces a multiplier: 0x at ≤0°C (fully halts drying), 1.0x at 20°C, up to 2.0x at 40°C, with a quadratic (not linear) falloff between 0–20°C so cold conditions punish progress disproportionately. This multiplier scales elapsed-time accrual directly, so a rack left out in a Kentucky summer noticeably outpaces one in freezing weather. `recipe.time` (172800s = 48h for grain/fiber, 86400s = 24h for herbs) is therefore a *baseline at 20°C*, not a hard duration.

**Player-facing feedback:** `doProgressTooltip()` and `getStatusIconsForInputItem()` surface all of this directly — a tooltip line for Temperature (Frozen/Cold/Normal/Warm/Hot text), a Wetness % when relevant, and a Drying Rate (`1.0x` etc., or `Paused (Wet, TemperatureCold)` when either condition blocks progress), plus small hot/cold/wet status icons overlaid on the in-progress item in the UI.

## 5. Recipe Batching: `variable[1:20]`

Both agricultural drying-rack recipes use `item variable[1:20] [Base.X] flags[ItemCount] mode:destroy` for inputs and `item variable[1:20] Base.Y` for outputs — a single recipe definition that can consume/produce anywhere from 1 to 20 items in one batch (matching the `Item@Input@20`/`Item@Output@20@StackAny` slot capacity), input and output counts moving together 1:1. This is why one rack can dry a large pile of, say, wheat sheaves as a single timed batch rather than needing 20 separate recipe instances — `CraftLogic`'s `canStack`/stacking checks (`CraftLogic.java:460`) accept `StackAny` outputs regardless of the batch size. The leather-drying racks, by contrast, use `Item@Input@1`/`Item@Output@1` — no batching, one hide at a time — since hides aren't meant to stack.

## 6. An Unused Alternative: `DryingLogic` / `DryingLogicSystem`

The engine also ships a separate, more elaborate component — `DryingLogic`/`DryingLogicSystem` (`zombie42_20_4/entity/components/crafting/DryingLogic.java`, `DryingLogicSystem.java`) — that **no currently-loaded entity script actually uses** (a repo-wide search for `component DryingLogic` in `media/` turned up nothing; only `DryingCraftLogic` is referenced by real entities). It's worth knowing about as a road-not-taken:

- Supports up to 16 independent parallel "drying slots" per entity (`DryingLogic.DryingSlot[16]`), each with its own recipe/elapsedTime/progress, rather than one shared batch counter.
- Supports a genuinely separate **fuel** input/output resource group alongside the drying input/output group (`fuelInputsGroupName`/`fuelOutputsGroupName`), with its own recipe tag query (`fuelRecipeTagQuery`) — i.e. the rack could require burning something to run at all, tracked independently of the item(s) being dried.
- Uses `Family.all(ComponentType.DryingLogic, ComponentType.Resources)` bucket-based ECS ticking (`DryingLogicSystem.java:40`) rather than `CraftLogic`'s single-recipe-at-a-time model.

Given this project's history with `SGlobalObjectSystem` vs. hand-rolled `ModData` ticking (see `PseudoButterChurner` DevCycle 1, Phase 17's notes), this is the same category of tradeoff: a more powerful, already-written vanilla system (`DryingLogic`) exists but is unused and unproven in a shipped entity, versus the simpler, confirmed-working `DryingCraftLogic`/`CraftLogic` pattern that every actual drying rack in the game uses. Building on `DryingCraftLogic` means following a well-trodden, verified path (12 recipe files already lean on it in this build); building on `DryingLogic` means being the first to actually exercise a component that, per the decompiled build, no vanilla content currently loads — real risk that it has never been run end-to-end in a shipping configuration.

## Summary

Drying racks don't transform an item in place — they run an ordinary "consume input, wait, create output" `CraftRecipe` (the same primitive as any crafting bench) through `DryingCraftLogic`, a `CraftLogic` subclass that adds weather/temperature pacing on top of the timer. The appearance of gradual transformation comes entirely from `SpriteOverlayConfig`'s three-tier (0/50/100%) progress art, selected via the running recipe's `overlayStyle` tag and redrawn every tick from `elapsedTime / recipe.getTime()` — a visual layer with no structural link to the actual item objects being destroyed and created underneath it. Any mod wanting this same "watch it slowly turn into something else" effect should follow this exact three-part shape: `component Resources` (item-as-count storage, decoupled from world rendering) + `component DryingCraftLogic`/`CraftRecipe` (the real consume/create logic and timing) + `component SpriteOverlayConfig` with progress tiers tied to the recipe's `overlayStyle` (the purely cosmetic illusion of continuity).
