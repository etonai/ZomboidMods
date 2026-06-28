# DevCycle 001: Cornmeal Balance and Crafted Grits Pot and Pan

**Status:** Work Complete
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Correct vanilla cornmeal nutrition and add pot/saucepan grits recipes modeled on `PseudoPorridge`.

---

## Goal

Create the first gameplay slice for `PseudoGrits`: rebalance vanilla `Base.Cornmeal2` so its nutrition matches the dried corn it represents, then add grits recipes that mirror the `PseudoPorridge` pot and saucepan flow.

The grits recipes use cookware, water, and cornmeal. They create pot and pan grits items that can receive oatmeal-style sweet/breakfast toppings through evolved recipes, matching the `PseudoPorridge` approach.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. Vanilla cornmeal has corrected nutrition based on dried corn. A player can craft grits in a cooking pot or saucepan using water and 24 units of cornmeal, then add toppings using evolved recipes similar to `PseudoPorridge`.

Player-facing evolved recipe names:

- `Grits (crafted pot)`
- `Grits (crafted pan)`

---

## Tasks

### Phase 1: Confirm Vanilla Corn and Cornmeal Data

**Status:** Work Complete

- [x] Review vanilla dried corn data:
  - `media/scripts/generated/items/food.txt:1944` defines `Base.CornSeed` as dried corn.
- [x] Review vanilla cornmeal data:
  - `media/scripts/generated/items/food.txt:5146` defines `Base.Cornmeal2`.
- [x] Confirm the safest B42 script pattern for overwriting a vanilla item from a mod script file.
- [x] Decide whether the override should preserve all vanilla `Base.Cornmeal2` fields except nutrition, or fully restate the item.

**Technical Notes:**
Vanilla dried corn is `Base.CornSeed`, with `EvolvedRecipeName = DriedCorn` and these nutrition values per unit:

```txt
HungerChange = -4.0,
Calories = 24.8,
Carbohydrates = 7.6,
Lipids = 0.56,
Proteins = 1.32,
```

Vanilla `Base.Cornmeal2` had `HungerChange = -20.0` but no explicit calories/macros in the viewed block. This cycle overwrites cornmeal so the full cornmeal item equals 20 units of dried corn:

```txt
HungerChange = -80.0,
Calories = 496.0,
Carbohydrates = 152.0,
Lipids = 11.2,
Proteins = 26.4,
```

Implementation note: `ScriptType.Item` has `ResetExisting` in `zombie42_11/scripting/ScriptType.java`, and `ScriptBucket.LoadScripts` resets an existing item before loading later script bodies for the same item key. The mod therefore restates `module Base { item Cornmeal2 { ... } }` fully in `PseudoGritsItems.txt`.

### Phase 2: Add Cornmeal Override

**Status:** Work Complete

- [x] Add a mod script file that overwrites vanilla `Base.Cornmeal2`.
- [x] Preserve vanilla cornmeal identity and behavior: `DisplayCategory`, `ItemType`, `Weight`, `Icon`, `EvolvedRecipe`, `FoodType`, `CantEat`, `Spice`, `Tooltip`, `WorldStaticModel`, and `Tags` remain compatible with the vanilla item.
- [x] Set cornmeal nutrition to match 20 units of dried corn:
  - `HungerChange = -80.0`
  - `Calories = 496.0`
  - `Carbohydrates = 152.0`
  - `Lipids = 11.2`
  - `Proteins = 26.4`
- [x] Document the override in this DevCycle so future maintenance understands why vanilla cornmeal was touched.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/items/PseudoGritsItems.txt`.

The `Base.Cornmeal2` override is a full item restatement in `module Base`, preserving vanilla non-nutrition behavior and adding corrected nutrition fields.

### Phase 3: Add Grits Base Items

**Status:** Work Complete

- [x] Create mod-owned food items for pot and pan grits bases.
- [x] Use `module Pseudonymous` for mod-owned items.
- [x] Add `Pseudonymous.GritsPot` and `Pseudonymous.GritsPan`.
- [x] Base cookware behavior on `PseudoPorridge` and vanilla rice pot/pan items.
- [x] Use grits nutrition matching 24 units out of the corrected 80-unit cornmeal item:
  - `HungerChange = -24.0`
  - `Calories = 148.8`
  - `Carbohydrates = 45.6`
  - `Lipids = 3.36`
  - `Proteins = 7.92`
- [x] Add English item names for the new grits items.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/items/PseudoGritsItems.txt`.

The grits recipe uses 24 units of corrected cornmeal. Since corrected cornmeal has `HungerChange = -80.0`, the recipe consumes 24/80 of a full cornmeal item, so the grits pot/pan nutrition is 30% of `Base.Cornmeal2`.

### Phase 4: Add Craft Recipes for Grits Bases

**Status:** Work Complete

- [x] Add a craft recipe for cooking-pot grits.
- [x] Add a craft recipe for saucepan grits.
- [x] Mirror `PseudoPorridge` recipe structure:
  - cookware input destroyed with condition inheritance
  - water input as a fluid mixture
  - dry ingredient input consumed
- [x] Use 24 units of `Base.Cornmeal2` as the dry ingredient.
- [x] Start from `PseudoPorridge` water amounts:
  - `0.6` water for saucepan grits
  - `1.5` water for cooking-pot grits
- [x] Add English recipe names for the setup recipes.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/recipes/PseudoGritsRecipes.txt`.

Implemented recipes:

```txt
craftRecipe MakeGritsPan
{
    inputs
    {
        item 1 [Base.Saucepan] flags[InheritCondition;ItemCount] mode:destroy,
        -fluid 0.6 categories[Water] mode:mixture,
        item 24 [Base.Cornmeal2],
    }
    outputs
    {
        item 1 Pseudonymous.GritsPan,
    }
}

craftRecipe MakeGritsPot
{
    inputs
    {
        item 1 [Base.Pot] mode:destroy flags[InheritCondition;ItemCount],
        -fluid 1.5 categories[Water] mode:mixture,
        item 24 [Base.Cornmeal2],
    }
    outputs
    {
        item 1 Pseudonymous.GritsPot,
    }
}
```

### Phase 5: Add Grits Evolved Recipes

**Status:** Work Complete

- [x] Add `Grits (crafted pot)` as an evolved recipe using the pot grits base item.
- [x] Add `Grits (crafted pan)` as an evolved recipe using the pan grits base item.
- [x] Mirror `PseudoPorridge` evolved recipe behavior:
  - `MaxItems = 3`
  - `AddIngredientIfCooked = true`
  - `CanAddSpicesEmpty = true`
  - `Template = Oatmeal`
  - `Cookable = true`
- [x] Add English context menu translations for both evolved recipe names.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/evolvedrecipes/PseudoGritsEvolvedRecipes.txt`.

`PseudoPorridge` relies on B42 evolved-recipe template behavior: `zombie42_11/scripting/objects/Item.java:3677` registers items to evolved recipes whose `template` matches the item's `EvolvedRecipe` key. Using `Template = Oatmeal` should allow oatmeal-compatible toppings for grits too.

### Phase 6: Static Review and In-Game Verification

**Status:** Planning - requires in-game verification

- [x] Confirm all new script files are under `PseudoGrits/42/media/scripts/`.
- [x] Confirm translation files are under `PseudoGrits/42/media/lua/shared/Translate/EN/`.
- [x] Confirm all referenced vanilla item IDs exist.
- [x] Confirm JSON translation files parse.
- [ ] Launch B42 with `PseudoGrits` enabled and confirm there are no script parse errors.
- [ ] Confirm vanilla cornmeal uses corrected nutrition in-game.
- [ ] Craft the pot grits base from a pot, water, and 24 units of cornmeal.
- [ ] Craft the pan grits base from a saucepan, water, and 24 units of cornmeal.
- [ ] Confirm oatmeal-compatible ingredients appear for both grits evolved recipes.
- [ ] Confirm adding ingredients preserves the intended grits item and display name behavior.

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should cornmeal overwrite preserve vanilla `EvolvedRecipe = Soup:6;Stew:6` only?**
   Decision: yes. This cycle corrects nutrition without broadening cornmeal's other recipe uses.

2. **Should grits use oatmeal-compatible toppings?**
   Decision: yes, mirrored `PseudoPorridge` with `Template = Oatmeal` so sweet/breakfast toppings work.

3. **Should grits use custom art/models?**
   Decision: no. Reused the same pot/pan visual strategy as `PseudoPorridge` for this first cycle.

4. **Should grits support forged pots or copper saucepans?**
   Decision: deferred. Match `PseudoPorridge` first, then add cookware variants in a later cycle if desired.

---

## Notes and Risks

- Implementation was requested explicitly after the DevCycle document was created, satisfying the `mymods/PseudoGrits/AGENTS.md` planning stop rule.
- The highest-risk implementation detail was vanilla item overwrite syntax for `Base.Cornmeal2`; code review supports the full restatement approach because item script loading resets existing bodies for duplicate item keys.
- Nutrition targets are code-based from vanilla `Base.CornSeed`, which represents dried corn.
- The grits item nutrition is based on 24/80 of corrected cornmeal nutrition, because the recipe consumes 24 units from a cornmeal item with `HungerChange = -80.0`.
- The implementation currently supports vanilla `Base.Pot` and `Base.Saucepan`, not `Base.PotForged` or `Base.SaucepanCopper`. Add forged/copper variants in a later cycle if desired.
- No in-game verification has been performed by the agent.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** 1-5 implementation phases; static checks in Phase 6
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Overrode `Base.Cornmeal2` nutrition to match 20 units of dried corn.
- Added `Pseudonymous.GritsPot` and `Pseudonymous.GritsPan` food items with nutrition based on 24/80 of corrected cornmeal.
- Added `MakeGritsPot` and `MakeGritsPan` craft recipes using cookware, water, and 24 units of cornmeal.
- Added `GritsPot` and `GritsPan` evolved recipes with player-facing names `Grits (crafted pot)` and `Grits (crafted pan)`.
- Added English item, recipe, evolved recipe, and context menu translations.

**Metrics:**
- Files modified: 8 (`PseudoGritsItems.txt`, `PseudoGritsRecipes.txt`, `PseudoGritsEvolvedRecipes.txt`, `ItemName.json`, `Recipes.json`, `ContextMenu.json`, `EvolvedRecipeName.json`, `DevCycle001.md`)
- In-game checks completed: none recorded in this document

**Lessons / Notes:**
- B42 item script duplicate handling with `ResetExisting` supports full vanilla item restatement as an override strategy for `Base.Cornmeal2`.
- B42 evolved recipe templates are functional for ingredient eligibility: items with `EvolvedRecipe = Oatmeal:N` are added to any evolved recipe using `Template = Oatmeal` during script finalization.