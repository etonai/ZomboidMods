# Butter Churn ("Churn Bucket") Analysis

**Created:** 2026-08-30
**Game Version:** Project Zomboid 42.19 (decompiled sources in `zombie42_19/`, scripts in `media/`)

## Summary

The "Butter Churn" is an in-world craftable entity (internal name `ChurnBucket`, in-game
display name "Churn Bucket" / crafting-menu category "Butter Churn"). It is a workstation
built by the player that converts milk into butter passively, using the game's generic
entity-crafting-bench system (the same underlying system used by things like drying racks,
mash tuns, and furnaces), not the player's active "timed action" crafting system.

## Code Locations

| Purpose | File |
|---|---|
| Entity definition (build recipe, sprite, UI hookup) | `media/scripts/generated/entities/animals/workstations/entity_butter_churn.txt` |
| xuiSkin (icon / display name binding, source of truth — hand-authored) | `media/scripts/entities/animals/workstations/entity_butter_churn_xuiSkin.txt` |
| Churning recipe (milk → butter) | `media/scripts/generated/entities/animals/craftRecipes/recipes_butter_churn.txt` |
| `Butter` item definition | `media/scripts/generated/items/food.txt` (line 4535) |
| UI strings ("Butter Churn", "Churn Butter", tooltip) | `media/lua/shared/Translate/EN/IG_UI.json` (line 7089), `media/lua/shared/Translate/EN/Recipes.json` (lines 1217, 1841), `media/lua/shared/Translate/EN/Tooltip.json` (line 92) |
| Entity crafting-bench runtime (elapsed-time accumulation) | `zombie42_19/entity/components/crafting/CraftLogicSystem.java` |
| Recipe data model (`time` field, remaining-time display) | `zombie42_19/entity/components/crafting/CraftRecipeComponent.java` |
| Recipe script class (`getTime()`) | `zombie42_19/scripting/entity/components/crafting/CraftRecipe.java` |
| Real-time/game-time conversion constant | `zombie42_19/entity/EntitySimulation.java` |

## Entity Definition

`media/scripts/generated/entities/animals/workstations/entity_butter_churn.txt`:

```
entity ChurnBucket
{
    component UiConfig
    {
        xuiSkin = default,
        entityStyle = ES_ChurnBucket,
        uiEnabled = true,
    }
    component CraftBench
    {
        Recipes = ChurnBucket,
    }
    component SpriteConfig { ... row = crafted_05_72 ... }
    component CraftRecipe          // <-- this is the BUILD recipe for the churn itself
    {
        timedAction = BuildWoodenStructureMedium,
        time = 50,
        category = Farming,
        Tooltip = Tooltip_craft_churnBucketDesc,
        xpAward = Woodwork:10,
        inputs
        {
            item 1 tags[base:hammer] mode:keep flags[Prop1;MayDegradeVeryLight],
            item 2 [Base.Plank],
            item 2 [Base.Nails],
        }
    }
}
```

Two different "recipes" are involved here and it's easy to conflate them:

1. **Building the Churn Bucket itself** — the `component CraftRecipe` block above, a normal
   player *timed action* craft (hammer + 2 planks + 2 nails, Woodworking XP, uses
   `BuildWoodenStructureMedium`). Its `time = 50` is an ordinary timed-action duration.
2. **Using the built churn to make butter** — the `component CraftBench { Recipes =
   ChurnBucket }` line says this entity hosts recipes tagged `ChurnBucket`, which is a
   separate, passive, bench-hosted recipe: `churn_butter` (see below). This is *not* a
   character timed action — it runs automatically on the workstation over time.

## The Churning Recipe

`media/scripts/generated/entities/animals/craftRecipes/recipes_butter_churn.txt`:

```
craftRecipe churn_butter
{
    time = 500,
    Tags = ChurnBucket,
    category = Farming,
    inputs
    {
        item 1 [*],
        -fluid 5.0 [CowMilk;SheepMilk] mode:mixture,
    }
    outputs
    {
        item 1 Base.Butter,
    }
}
```

- `Tags = ChurnBucket` links this recipe to the `ChurnBucket` entity's `CraftBench`
  component, so it only runs on a built Churn Bucket.
- `item 1 [*]` — a wildcard container item goes into the bench (any item slot; in
  practice this is the container that is carrying the milk being churned).
- `-fluid 5.0 [CowMilk;SheepMilk] mode:mixture` — consumes 5.0 units of fluid from that
  container, drawn from Cow Milk and/or Sheep Milk (the `mode:mixture` flag means the two
  milk types can be combined to reach the 5.0 total — the same pattern used elsewhere for
  water-based recipes, e.g. `recipes_cooking.txt`, `recipes_baking.txt`).
- Output: **1x `Base.Butter`** (`media/scripts/generated/items/food.txt:4535`) — Weight
  0.3, 3200 Calories, used as an `EvolvedRecipe` ingredient boost for Pancakes, Sandwich,
  Stir Fry, Pasta, Taco, Burrito, Toast, Oatmeal, Soup, and Stew.
- No skill requirement, no XP award, no `timedAction` — confirming this recipe is handled
  by the passive bench-crafting system rather than the character timed-action system.

## How Long Churning Takes

Because `churn_butter` has no `timedAction`, it is processed by the entity **crafting bench
tick system**, not the player action-duration system. The mechanism, traced through the
decompiled Java:

1. `CraftLogicSystem.updateCraftLogic()` (`zombie42_19/entity/components/crafting/CraftLogicSystem.java:77`)
   advances the recipe's progress every simulation tick:
   ```java
   craftData.setElapsedTime(craftData.getElapsedTime() + EntitySimulation.getGameSecondsPerTick());
   ```
2. `EntitySimulation` (`zombie42_19/entity/EntitySimulation.java`) defines the tick rate:
   ```java
   private static final double SECONDS_PER_TICK = 0.1;      // 1 simulation tick = 0.1 real seconds
   public static double getGameSecondsPerTick() { return 2.4; } // each tick advances the in-game clock by 2.4 in-game seconds
   ```
   That is a fixed ratio of **24 in-game seconds per 1 real-world second**, independent of
   the actual sandbox "Day Length" setting (this constant is hard-coded here, not read from
   `SandboxOptions`).
3. `CraftRecipeComponent` compares elapsed time against the recipe's `time` field and shows
   a remaining-time readout by treating `time` as a count of seconds, decomposed into
   `ss / mm / hh / dd` (`zombie42_19/entity/components/crafting/CraftRecipeComponent.java:807-811`):
   ```java
   int timeRemaining = craftRecipeData.getRecipe().getTime() - (int) craftRecipeData.getElapsedTime();
   int ss = timeRemaining % 60;
   int mm = timeRemaining / 60 % 60;
   int hh = timeRemaining / 3600 % 24;
   int dd = Math.floorDiv(timeRemaining, 86400);
   ```
   This confirms `time = 500` is measured in **in-game seconds**.

Putting it together for `churn_butter`'s `time = 500`:

- **In-game clock time to churn a batch of butter: 500 seconds = 8 minutes 20 seconds**
  (`mm:ss` = `08:20`), as it would display on the workstation's remaining-time readout.
- **Real-world wall-clock time (at the fixed 24 in-game-seconds-per-real-second bench tick
  rate):** 500 ÷ 24 ≈ **20.8 real seconds**, assuming the churn bucket keeps being simulated
  continuously (i.e., stays loaded/active — see caveat below).

Unlike character-performed timed-action crafts, this bench recipe's duration is **not**
affected by the character's Farming/Cooking skill — `CraftRecipe.getTime(IsoGameCharacter)`
(the skill-scaled variant, in `zombie42_19/scripting/entity/components/crafting/CraftRecipe.java:199-207`)
is only used for player-performed timed-action recipes; the passive bench path in
`CraftRecipeComponent`/`CraftLogicSystem` calls the unscaled `getTime()` instead.

### Caveats / Uncertainties
- The 2.4-in-game-seconds-per-tick constant is hard-coded in `EntitySimulation`, and
  simulation ticks only run for entities being actively simulated (in a loaded cell, not
  necessarily requiring the churn bucket be on-screen). Whether a churn continues
  progressing while far outside the loaded area, or across a save/reload, was not verified
  from code inspection alone and would need in-game testing to confirm.
- Whether the sandbox "Day Length" multiplier indirectly affects `EntitySimulation`'s tick
  rate elsewhere (e.g., via a different code path not seen in this pass) was not fully ruled
  out; the constant itself is not sourced from `SandboxOptions` in the code examined.
