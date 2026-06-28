# DevCycle 001: Crafted Porridge Pot and Pan

**Status:** Work Complete
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Add pot and saucepan porridge bases that behave like rice evolved recipes while accepting oatmeal-compatible toppings.

---

## Goal

Create the first gameplay slice for `PseudoPorridge`: players can prepare porridge in a cooking pot or saucepan, then add ingredients to it through evolved recipes named `Porridge (crafted pot)` and `Porridge (crafted pan)`.

The recipes are based on the vanilla rice pot and rice saucepan flow as a structural pattern only: cookware plus water plus a dry ingredient creates a prepared pot/pan food item. Porridge uses water and flour, not rice. Once created, the porridge accepts ingredients that vanilla `Bowl of Oatmeal` accepts.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can craft a pot or saucepan of porridge from the appropriate cookware, water, and flour, then add the same toppings or mix-ins that are valid for vanilla oatmeal.

The two player-facing evolved recipe names are:

- `Porridge (crafted pot)`
- `Porridge (crafted pan)`

---

## Tasks

### Phase 1: Confirm Vanilla Source Patterns

**Status:** Work Complete

- [x] Review vanilla rice setup recipes before implementation:
  - `media/scripts/generated/recipes/recipes_cooking.txt:233` defines `PlaceRiceInSaucepan2`.
  - `media/scripts/generated/recipes/recipes_cooking.txt:279` defines `PlaceRiceInCookingPot2`.
- [x] Review vanilla oatmeal creation and topping behavior:
  - `media/scripts/generated/recipes/recipes_cooking.txt:537` defines `MakeBowlOfOatmeal`.
  - `media/scripts/generated/evolvedrecipes.txt:635` defines the `Oatmeal` evolved recipe.
- [x] Confirm whether B42 evolved recipe ingredient eligibility is tied only to item `EvolvedRecipe` entries, or whether `Template = Oatmeal` can inherit ingredient eligibility automatically.

**Technical Notes:**
Vanilla rice setup is only the structural model for cookware plus water producing a prepared pot/pan food item. The saucepan recipe consumes `0.6` water and maps saucepans to `Base.WaterSaucepanRice`; the cooking pot recipe consumes `1.5` water and maps pots to `Base.WaterPotRice`. Porridge does not require `Base.Rice`.

Vanilla oatmeal creation uses a bowl or clay bowl, `0.3` water, and `item 10 [Base.OatsRaw]`, producing `Base.Oatmeal`. The vanilla `Oatmeal` evolved recipe uses `BaseItem = Base.Oatmeal`, `MaxItems = 3`, `ResultItem = Base.Oatmeal`, `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

Implementation note: `zombie42_11/scripting/objects/Item.java:3677` finalizes item evolved-recipe entries by adding an item to any evolved recipe whose `template` matches the item's `EvolvedRecipe` key. Because the porridge evolved recipes use `Template = Oatmeal`, vanilla items with `EvolvedRecipe = ...;Oatmeal:N;...` are registered for porridge as well.

### Phase 2: Add Porridge Base Items

**Status:** Work Complete

- [x] Create mod-owned food items for the pot and pan porridge bases.
- [x] Use `module Pseudonymous` for mod-owned items.
- [x] Add `Pseudonymous.PorridgePot` and `Pseudonymous.PorridgePan`.
- [x] Base item food/container behavior on vanilla `Base.RicePot` and `Base.RicePan`.
- [x] Add English item names for the new items.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/items/PseudoPorridgeItems.txt`.

The new items use vanilla rice pot/pan icons and world models for this first cycle. Both are cookable food items, return their cookware with `ReplaceOnUse`, and use `EvolvedRecipeName = Porridge` for ingredient naming.

### Phase 3: Add Craft Recipes for Porridge Bases

**Status:** Work Complete

- [x] Add a craft recipe for cooking-pot porridge.
- [x] Add a craft recipe for saucepan porridge.
- [x] Follow the B42 rice recipe structure: cookware input destroyed with condition inheritance, water input as a fluid mixture, and dry food inputs consumed.
- [x] Require flour and water as the porridge ingredients.
- [x] Use `tags[base:flour]` for flour so vanilla wheat flour and cornflour both work.
- [x] Use rice-recipe water amounts: `0.6` water for saucepan porridge and `1.5` water for cooking-pot porridge.
- [x] Add English recipe names for the setup recipes.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/recipes/PseudoPorridgeRecipes.txt`.

Vanilla flour candidates verified:

- `Base.Flour2` at `media/scripts/generated/items/food.txt:5162` has `Tags = base:flour;base:minoringredient`.
- `Base.Cornflour2` at `media/scripts/generated/items/food.txt:5130` has `Tags = base:flour;base:minoringredient`.

Implemented recipes:

```txt
craftRecipe MakePorridgePan
{
    inputs
    {
        item 1 [Base.Saucepan] flags[InheritCondition;ItemCount] mode:destroy,
        -fluid 0.6 categories[Water] mode:mixture,
        item 60 tags[base:flour],
    }
    outputs
    {
        item 1 Pseudonymous.PorridgePan,
    }
}

craftRecipe MakePorridgePot
{
    inputs
    {
        item 1 [Base.Pot] mode:destroy flags[InheritCondition;ItemCount],
        -fluid 1.5 categories[Water] mode:mixture,
        item 60 tags[base:flour],
    }
    outputs
    {
        item 1 Pseudonymous.PorridgePot,
    }
}
```

### Phase 4: Add Porridge Evolved Recipes

**Status:** Work Complete

- [x] Add `Porridge (crafted pot)` as an evolved recipe using the pot porridge base item.
- [x] Add `Porridge (crafted pan)` as an evolved recipe using the pan porridge base item.
- [x] Use the vanilla oatmeal behavior as the model: `MaxItems = 3`, `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.
- [x] Use recipe IDs `PorridgePot` and `PorridgePan`, with player-facing `Name` values set to the requested names.
- [x] Add English context menu translations for both evolved recipe names.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/evolvedrecipes/PseudoPorridgeEvolvedRecipes.txt` using `module Base`, matching the nearby `PseudoTortillas` evolved-recipe pattern.

The `Template = Oatmeal` implementation should make vanilla oatmeal-compatible ingredients available to both porridge evolved recipes. This is supported by `Item.OnScriptsLoaded` in `zombie42_11/scripting/objects/Item.java`, which registers an item recipe with any evolved recipe whose template matches the item's evolved-recipe key.

### Phase 5: Static Review and In-Game Verification

**Status:** Planning - requires in-game verification

- [x] Confirm all new script files are under `PseudoPorridge/42/media/scripts/`.
- [x] Confirm translation files are under `PseudoPorridge/42/media/lua/shared/Translate/EN/`.
- [x] Confirm all referenced vanilla item IDs exist.
- [x] Confirm JSON translation files parse.
- [ ] Launch B42 with `PseudoPorridge` enabled and confirm there are no script parse errors.
- [ ] Craft the pot porridge base from a pot, water, and flour.
- [ ] Craft the pan porridge base from a saucepan, water, and flour.
- [ ] Confirm oatmeal-compatible ingredients appear for both porridge evolved recipes.
- [ ] Confirm adding ingredients preserves the intended porridge item and display name behavior.

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should both wheat flour and cornflour count as flour?**
   Decision: yes, implemented with `tags[base:flour]`.

2. **Should porridge use vanilla rice item art/models or new custom art?**
   Decision: use rice pot/pan visuals for minimal scope in this cycle. Custom icons/models can be added in a later cycle if needed.

3. **Should porridge use rice in any form?**
   Decision: no. Rice recipes are a structural reference only; porridge uses flour and water, not `Base.Rice`.

4. **Should the pot and pan porridge be divisible into bowls?**
   Decision: deferred to a later cycle unless this becomes necessary for gameplay feel.

---

## Notes and Risks

- Implementation was requested explicitly after the DevCycle document was created, satisfying the `mymods/PseudoPorridge/AGENTS.md` planning stop rule.
- The main static-risk item was oatmeal ingredient compatibility. Code review indicates `Template = Oatmeal` inherits item eligibility from vanilla oatmeal ingredients.
- The implementation currently supports vanilla `Base.Pot` and `Base.Saucepan`, not `Base.PotForged` or `Base.SaucepanCopper`. Add forged/copper variants in a later cycle if desired.
- The recipes use `item 60 tags[base:flour]`. Since vanilla flour bags contain 60 units, each porridge item uses one full bag-equivalent. Nutrition is therefore set to match `Base.Flour2`: `HungerChange = -60.0`, `Calories = 50.0`, `Carbohydrates = 21.0`, `Lipids = 0.0`, and `Proteins = 5.0`.
- No in-game verification has been performed by the agent.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** 1-4 implementation phases; static checks in Phase 5
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Added `Pseudonymous.PorridgePot` and `Pseudonymous.PorridgePan` food items with nutrition based on one full vanilla flour bag.
- Added `MakePorridgePot` and `MakePorridgePan` craft recipes using cookware, water, and flour.
- Added `PorridgePot` and `PorridgePan` evolved recipes with player-facing names `Porridge (crafted pot)` and `Porridge (crafted pan)`.
- Added English item, recipe, evolved recipe, and context menu translations.

**Metrics:**
- Files modified: 8 (`PseudoPorridgeItems.txt`, `PseudoPorridgeRecipes.txt`, `PseudoPorridgeEvolvedRecipes.txt`, `ItemName.json`, `Recipes.json`, `ContextMenu.json`, `EvolvedRecipeName.json`, `DevCycle001.md`)
- In-game checks completed: none recorded in this document

**Lessons / Notes:**
- B42 evolved recipe templates are functional for ingredient eligibility: items with `EvolvedRecipe = Oatmeal:N` are added to any evolved recipe using `Template = Oatmeal` during script finalization.