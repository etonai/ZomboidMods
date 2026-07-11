# AutoCook Analysis for PseudoSalad

Created: 2026-07-10

Version scope: PseudoSalad is only intended for Project Zomboid 42.19 and later. AutoCook's 42.13-specific work is out of scope unless it is needed to understand or support 42.19+ behavior.

## Scope

This document analyzes `notmymods/AutoCook` as a reference for PseudoSalad. The practical goal is a new PseudoSalad behavior that automatically creates a basic salad with exactly 3 ingredient types, each added twice, preferring:

1. eggs,
2. one additional protein type, either small bird meat or fish fillets,
3. vegetables, selected by least fresh nonrotten vegetable first.

Extras such as salt, mayonnaise, herbs, pickles, and other spices should not be automatically added.

## AutoCook Structure

AutoCook is a client-side Lua mod. The core files under `notmymods/AutoCook/common/media/lua/client/` are:

- `AutoCook.lua`: selection, queueing, duplicate tracking, and repeated add loop.
- `AutoCook_Diets.lua`: item comparison strategies, including freshness and leftovers sorting.
- `AutoCook_RISCookMenuInsertion.lua`: context-menu insertion for eligible evolved recipes.
- `ISContinue.lua`: small timed action that calls back into AutoCook after each add action.
- `ISCharacterCook.lua`: settings UI and persisted player `modData`.

The 42.13 folder contains a smaller copy of the same main behavior. For PseudoSalad, 42.13-specific work should be ignored unless it clarifies behavior needed for Project Zomboid 42.19 and later. The common version is the more complete reference because it includes menu integration, settings UI, diet modes, and active context insertion.

## Core AutoCook Flow

AutoCook adds a context-menu option for base items that have available evolved recipes. It calls:

```lua
local evorecipes = RecipeManager.getEvolvedRecipe(baseItem, player, containerList, false)
local items = recipe:getItemsCanBeUse(player, baseItem, containerList)
local autoCook = AutoCook:new(player, recipe, baseItem)
local option = context:addOption(..., autoCook, AutoCook.continue)
```

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook_RISCookMenuInsertion.lua:8-10`, `:35-47`, `:68-72`.

The add loop is in `AutoCook:continue()`:

- reads the base meal's existing `extraItems`,
- asks vanilla for usable items through `recipe:getItemsCanBeUse(...)`,
- chooses one item with `chooseItem(...)`,
- transfers the item and base item to player inventory if needed,
- calls `ISAddItemInRecipe:new(...)`,
- queues `ISContinue:new(...)` to repeat.

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook.lua:96-174`.

This is the strongest pattern to reuse: let vanilla decide what can be added, then only override the selection policy.

## Vanilla Salad Constraints

Vanilla salad is an evolved recipe:

```txt
evolvedrecipe Salad
{
    BaseItem = Base.Bowl,
    MaxItems = 6,
    ResultItem = Base.Salad,
    Name = Make Salad,
    Template = Salad,
}
```

Reference: `media/scripts/generated/evolvedrecipes.txt:220-227`.

There is also `SaladClay` using `Base.ClayBowl` and `Base.SaladClay`.

Reference: `media/scripts/generated/evolvedrecipes.txt:229-236`.

The `MaxItems = 6` exactly supports PseudoSalad's target of 3 ingredient types, each used twice.

The generated salad item returns an empty bowl on use.

Reference: `media/scripts/generated/items/food.txt:6326-6351`.

## Vanilla Validity and Item Use

The engine's `EvolvedRecipe.getItemsCanBeUse(...)` iterates the evolved recipe item list and all reachable containers, then asks `checkItemCanBeUse(...)` whether each item is valid.

Reference: `zombie42_11/scripting/objects/EvolvedRecipe.java:142-171`.

For food ingredients, vanilla rejects:

- rotten food unless the character has Cooking 7+ or the item has `ProduceSack`,
- burnt food,
- frozen food when the recipe disallows frozen items,
- ingredients when the base already has `maxItems`.

Reference: `zombie42_11/scripting/objects/EvolvedRecipe.java:177-224`.

When adding a normal food ingredient, vanilla:

- creates the result item if the base item is not already the result,
- adds hunger, nutrition, thirst, and mood effects to the result,
- subtracts the used portion from the ingredient,
- calls `UseAndSync()` when the ingredient is effectively consumed,
- records the ingredient full type in `extraItems`.

Reference: `zombie42_11/scripting/objects/EvolvedRecipe.java:245-306`, `:307-430`.

This means PseudoSalad can add the same inventory item twice if enough hunger value remains. It does not necessarily need two separate eggs or two separate vegetables for "used twice"; the evolved recipe use amount determines whether the source item survives the first add.

## AutoCook Selection Logic

AutoCook has three important selection behaviors:

1. It filters candidates for food, known poison, dangerous uncooked food in non-cookable recipes, spice policy, and rotten policy.
2. It tracks previously used item types with `usedItems`.
3. It groups candidates by number of prior uses, so lower-use ingredients are considered before higher-use duplicates.

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook.lua:219-292`, `:320-340`.

Defaults:

```lua
AutoCook.MaxDuplicate = 2
AutoCook.UseRotten = true
AutoCook.PrioritizeVariety = true
```

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook.lua:11`, `:23`, `:28`.

For PseudoSalad, `MaxDuplicate = 2` is useful, but `UseRotten = true` is not. PseudoSalad should hard reject rotten ingredients.

AutoCook's default freshness comparator selects the item closest to losing freshness; if both are stale, it selects the item closest to rot:

```lua
local agingDelta = leftItem:getOffAge() - age
local rottingDelta = leftItem:getOffAgeMax() - age
...
if newAgingDelta > 0 and (newAgingDelta < agingDelta or agingDelta < 0)
   or (agingDelta < 0 and newRottingDelta > 0 and ...)
then
    return rightItem
end
```

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook_Diets.lua:3-18`.

This is a good starting point for "least fresh nonrotten vegetable." For PseudoSalad, the comparator should be scoped to vegetable candidates only and should first exclude `item:isRotten()`.

## Protein and Egg Findings

Cooked eggs are directly valid salad ingredients:

- `Base.EggBoiled`: `EvolvedRecipe = ... Salad:10 ...`, `FoodType = Egg`.
- `Base.EggOmelette`: `EvolvedRecipe = ... Salad:20 ...`, `FoodType = Egg`.
- `Base.EggPoached`: `EvolvedRecipe = ... Salad:10 ...`, `FoodType = Egg`.
- `Base.EggScrambled`: `EvolvedRecipe = ... Salad:20 ...`, `FoodType = Egg`.

Reference: `media/scripts/generated/items/food.txt:5340-5414`.

Raw egg and wild eggs are valid for salad only when cooked:

- `Base.Egg`: `Salad:7|Cooked`, `DangerousUncooked = true`, `IsCookable = true`.
- `Base.WildEggs`: `Salad:7|Cooked`, `DangerousUncooked = true`, `IsCookable = true`.

Reference: `media/scripts/generated/items/food.txt:5416-5440`, `:5454-5475`.

Fish fillets and small bird meat are also valid for salad only when cooked:

- `Base.FishFillet`: `Salad:10|Cooked`, `FoodType = Fish`.
- `Base.Smallbirdmeat`: `Salad:10|Cooked`, `FoodType = Game`.

Reference: `media/scripts/generated/items/food.txt:6834-6858`, `:10189-10208`.

PseudoSalad should not assume raw proteins can be added to salad. The first implementation should either require cooked eggs/protein or explicitly document that cooking is out of scope.

## Vegetable Findings

Many salad-appropriate vegetables use `FoodType = Vegetables`, including tomato, cabbage, leek, carrot, broccoli, cauliflower, cucumber, onion, spinach, turnip, zucchini, tofu, and others.

Examples:

- `Base.Tomato`: `Salad:6`, `FoodType = Vegetables`.
- `Base.Cabbage`: `Salad:12`, `FoodType = Vegetables`.
- `Base.Leek`: `Salad:6`, `FoodType = Vegetables`.
- `Base.Spinach`: `Salad:5`, `FoodType = Vegetables`.

Reference: `media/scripts/generated/items/food.txt:91-105`, `:145-159`, `:14440-14455`, `:14757-14767`.

Some very salad-like items are not `FoodType = Vegetables`. For example:

- `Base.Kale`: `Salad:8`, `FoodType = Greens`.
- `Base.Lettuce`: `Salad:5`, `FoodType = Greens`.

Reference: `media/scripts/generated/items/food.txt:14414-14437`, `:14467-14482`.

Recommendation: PseudoSalad should treat both `FoodType = Vegetables` and `FoodType = Greens` as vegetables for the user's goal. Otherwise lettuce and kale would be skipped, which is probably not intended for a salad mod.

## Extras and Spices

AutoCook has spice support, including smart spice settings and a max spice count. PseudoSalad should not copy that behavior.

AutoCook allows spices if `allowSpice()` passes and then counts them separately.

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook.lua:201-216`, `:176-178`.

The vanilla item data marks many salad extras as `Spice = true`, including mayonnaise, remoulade, seeds, herbs, pickles, peppers, and similar small additions.

Examples:

- `Base.MayonnaiseFull`: `EvolvedRecipe = ... Salad:2 ...`, `Spice = true`.
- `Base.RemouladeFull`: `EvolvedRecipe = ... Salad:2`, `Spice = true`.
- `Base.Garlic`: `Salad:1`, `FoodType = Herb`, `Spice = true`.
- `Base.Pickles`: `Salad:2`, `Spice = true`.

Reference: `media/scripts/generated/items/food.txt:253-267`, `:279-302`, `:14341-14352`, `:14647-14657`.

PseudoSalad should reject any candidate where `item:isSpice()` is true.

## Recommended PseudoSalad Design

Use AutoCook's queueing shape, but replace the generalized diet selector with a deterministic salad plan.

Suggested flow:

1. Add a context option only for `Base.Bowl` and optionally `Base.ClayBowl`.
2. Use `RecipeManager.getEvolvedRecipe(baseItem, player, containerList, false)` and select the recipe whose result is `Base.Salad` or `Base.SaladClay`.
3. Call `recipe:getItemsCanBeUse(player, baseItem, containerList)` to get vanilla-valid candidates.
4. Build candidate buckets:
   - eggs: `item:getFoodType() == "Egg"`, nonrotten, not spice, cooked if raw item requires cooked state.
   - protein: `item:getFullType() == "Base.Smallbirdmeat"` or `item:getFullType() == "Base.FishFillet"`, nonrotten, not spice, cooked.
   - vegetables: `item:getFoodType() == "Vegetables"` or `"Greens"`, nonrotten, not spice.
5. Pick one ingredient type from each bucket:
   - egg: least fresh nonrotten egg if multiple are available.
   - protein: least fresh nonrotten protein; if both small bird and fish exist, choose the one closest to rot/stale first.
   - vegetable: least fresh nonrotten vegetable.
6. Add each selected type twice, for exactly six total add actions.
7. Stop when six ingredients have been added or when a required bucket cannot satisfy the plan.

The plan should track counts by full type, like AutoCook's `usedItems`, but the target sequence should be explicit:

```lua
plannedTypes = {
    eggFullType,
    eggFullType,
    proteinFullType,
    proteinFullType,
    vegetableFullType,
    vegetableFullType,
}
```

Before each add action, refresh `recipe:getItemsCanBeUse(...)`, then choose an item matching the next planned full type. Refreshing matters because the first add can partially consume or fully consume the source item.

## Suggested Freshness Comparator

For nonrotten foods:

1. Prefer items that are still fresh but have the smallest `getOffAge() - getAge()`.
2. If both are already stale, prefer the smallest `getOffAgeMax() - getAge()`.
3. Tie-break by smaller remaining hunger value, then stable full type/name.

This follows AutoCook's default selector while avoiding rotten ingredients.

Reference: `notmymods/AutoCook/common/media/lua/client/AutoCook_Diets.lua:3-18`.

## Open Implementation Decisions

- Fallback behavior: If eggs or protein are unavailable, should PseudoSalad still create a vegetable-only salad, or should it mark the action unavailable? The user wording says "always tries to include eggs," which suggests graceful fallback may be acceptable, but the planned "basic salad with 3 ingredients" implies all three buckets should normally be required.
- Cooked requirement: The first implementation should likely require cooked eggs/protein. Auto-cooking raw egg, fish, or small bird meat would be a separate feature.
- Vegetable scope: I recommend including `FoodType = Greens` with `Vegetables` because lettuce and kale are salad-appropriate but not tagged as `Vegetables`.
- Bowl scope: Supporting both bowl and clay bowl is easy because vanilla has both salad recipes; if the mod should only target basic bowls, restrict to `Base.Bowl`.

## Bottom Line

AutoCook is useful as a queueing and vanilla-validation reference, not as a selector to copy wholesale. PseudoSalad should keep:

- context-menu insertion on eligible base items,
- `recipe:getItemsCanBeUse(...)`,
- inventory transfer before adding,
- `ISAddItemInRecipe`,
- continuation after each add,
- duplicate counting by full type.

PseudoSalad should replace:

- generalized diet/freshness selection,
- spice handling,
- rotten allowance,
- auto-craft ingredient logic,
- user-configurable broad cooking modes.

The correct PseudoSalad core is a deterministic six-step salad plan: two egg additions, two cooked fish/small-bird protein additions, and two least-fresh nonrotten vegetable/green additions, with no spices or extras.
