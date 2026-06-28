# DevCycle 001: Cornmeal Balance and Crafted Grits Pot and Pan

**Status:** Planning
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Correct vanilla cornmeal nutrition and add pot/saucepan grits recipes modeled on `PseudoPorridge`.

---

## Goal

Create the first gameplay slice for `PseudoGrits`: rebalance vanilla `Base.Cornmeal2` so its nutrition matches the dried corn it represents, then add grits recipes that mirror the `PseudoPorridge` pot and saucepan flow.

The grits recipes should use cookware, water, and cornmeal. They should create pot and pan grits items that can receive oatmeal-style sweet/breakfast toppings through evolved recipes, matching the `PseudoPorridge` approach unless implementation research shows a better grits-specific pattern.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. Vanilla cornmeal has corrected nutrition based on dried corn. A player can craft grits in a cooking pot or saucepan using water and 24 units of cornmeal, then add toppings using evolved recipes similar to `PseudoPorridge`.

Expected player-facing evolved recipe names:

- `Grits (crafted pot)`
- `Grits (crafted pan)`

---

## Tasks

### Phase 1: Confirm Vanilla Corn and Cornmeal Data

**Status:** Planning

- [ ] Review vanilla dried corn data:
  - `media/scripts/generated/items/food.txt:1942` defines `Base.CornSeed` as dried corn.
- [ ] Review vanilla cornmeal data:
  - `media/scripts/generated/items/food.txt:5146` defines `Base.Cornmeal2`.
- [ ] Confirm the safest B42 script pattern for overwriting a vanilla item from a mod script file.
- [ ] Decide whether the override should preserve all vanilla `Base.Cornmeal2` fields except nutrition, or fully restate the item.

**Technical Notes:**
Vanilla dried corn is `Base.CornSeed`, with `EvolvedRecipeName = DriedCorn` and these nutrition values per unit:

```txt
HungerChange = -4.0,
Calories = 24.8,
Carbohydrates = 7.6,
Lipids = 0.56,
Proteins = 1.32,
```

Vanilla `Base.Cornmeal2` currently has `HungerChange = -20.0` but no explicit calories/macros in the viewed block. This cycle should overwrite cornmeal so the full cornmeal item equals 20 units of dried corn:

```txt
HungerChange = -80.0,
Calories = 496.0,
Carbohydrates = 152.0,
Lipids = 11.2,
Proteins = 26.4,
```

### Phase 2: Add Cornmeal Override

**Status:** Planning

- [ ] Add a mod script file that overwrites vanilla `Base.Cornmeal2`.
- [ ] Preserve vanilla cornmeal identity and behavior: `DisplayCategory`, `ItemType`, `Weight`, `Icon`, `EvolvedRecipe`, `FoodType`, `CantEat`, `Spice`, `Tooltip`, `WorldStaticModel`, and `Tags` should remain compatible with the vanilla item.
- [ ] Set cornmeal nutrition to match 20 units of dried corn:
  - `HungerChange = -80.0`
  - `Calories = 496.0`
  - `Carbohydrates = 152.0`
  - `Lipids = 11.2`
  - `Proteins = 26.4`
- [ ] Document the override clearly in the script file or DevCycle notes so future maintenance understands why vanilla cornmeal was touched.

**Technical Notes:**
Recommended file location: `PseudoGrits/42/media/scripts/items/PseudoGritsItems.txt`.

Implementation should verify whether B42 requires an explicit `Override = true` field, a full restatement in `module Base`, or another established override pattern. Do not assume override syntax without checking against the codebase or a known working mod pattern.

### Phase 3: Add Grits Base Items

**Status:** Planning

- [ ] Create mod-owned food items for pot and pan grits bases.
- [ ] Use `module Pseudonymous` for mod-owned items unless implementation research shows a better local convention.
- [ ] Add item IDs such as `Pseudonymous.GritsPot` and `Pseudonymous.GritsPan`.
- [ ] Base cookware behavior on `PseudoPorridge` and vanilla rice pot/pan items.
- [ ] Use grits nutrition matching 24 units of dried corn/cornmeal input:
  - `HungerChange = -96.0`
  - `Calories = 595.2`
  - `Carbohydrates = 182.4`
  - `Lipids = 13.44`
  - `Proteins = 31.68`
- [ ] Add English item names for the new grits items.

**Technical Notes:**
The grits recipe uses 24 units of cornmeal. Since the corrected cornmeal item represents 20 dried corn units, using 24 units of cornmeal represents 24 dried corn units for nutrition purposes.

### Phase 4: Add Craft Recipes for Grits Bases

**Status:** Planning

- [ ] Add a craft recipe for cooking-pot grits.
- [ ] Add a craft recipe for saucepan grits.
- [ ] Mirror `PseudoPorridge` recipe structure:
  - cookware input destroyed with condition inheritance
  - water input as a fluid mixture
  - dry ingredient input consumed
- [ ] Use 24 units of `Base.Cornmeal2` as the dry ingredient.
- [ ] Start from `PseudoPorridge` water amounts unless testing suggests a grits-specific adjustment:
  - `0.6` water for saucepan grits
  - `1.5` water for cooking-pot grits
- [ ] Add English recipe names for the setup recipes.

**Technical Notes:**
Reference implementation: `mymods/PseudoPorridge/PseudoPorridge/42/media/scripts/recipes/PseudoPorridgeRecipes.txt`.

Recommended first-pass recipe IDs:

- `MakeGritsPan`
- `MakeGritsPot`

### Phase 5: Add Grits Evolved Recipes

**Status:** Planning

- [ ] Add `Grits (crafted pot)` as an evolved recipe using the pot grits base item.
- [ ] Add `Grits (crafted pan)` as an evolved recipe using the pan grits base item.
- [ ] Mirror `PseudoPorridge` evolved recipe behavior unless implementation testing shows a better fit:
  - `MaxItems = 3`
  - `AddIngredientIfCooked = true`
  - `CanAddSpicesEmpty = true`
  - `Template = Oatmeal`
  - `Cookable = true`
- [ ] Add English context menu translations for both evolved recipe names.

**Technical Notes:**
`PseudoPorridge` relies on B42 evolved-recipe template behavior: `zombie42_11/scripting/objects/Item.java:3677` registers items to evolved recipes whose `template` matches the item's `EvolvedRecipe` key. Using `Template = Oatmeal` should allow oatmeal-compatible toppings for grits too.

### Phase 6: Static Review and In-Game Verification

**Status:** Planning

- [ ] Confirm all new script files are under `PseudoGrits/42/media/scripts/`.
- [ ] Confirm translation files are under `PseudoGrits/42/media/lua/shared/Translate/EN/`.
- [ ] Confirm all referenced vanilla item IDs exist.
- [ ] Confirm JSON translation files parse.
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
   Recommended starting point: yes. This cycle is about nutrition correction and grits recipes, not broadening cornmeal's other recipe uses.

2. **Should grits use oatmeal-compatible toppings?**
   Recommended starting point: yes, mirror `PseudoPorridge` with `Template = Oatmeal` so sweet/breakfast toppings work.

3. **Should grits use custom art/models?**
   Recommended starting point: no. Reuse the same pot/pan visual strategy as `PseudoPorridge` for this first cycle.

4. **Should grits support forged pots or copper saucepans?**
   Recommended starting point: defer. Match `PseudoPorridge` first, then add cookware variants in a later cycle if desired.

---

## Notes and Risks

- Per `mymods/PseudoGrits/AGENTS.md`, agents must stop after creating this DevCycle document and must not begin implementation until Ed explicitly requests it.
- The highest-risk implementation detail is vanilla item overwrite syntax for `Base.Cornmeal2`. Verify the correct B42 mod override pattern before editing the item script.
- Nutrition targets are code-based from vanilla `Base.CornSeed`, which represents dried corn.
- The grits item nutrition is intentionally high because the recipe uses 24 units of cornmeal, and the corrected cornmeal item represents dried corn nutrition rather than its current vanilla placeholder values.
- No implementation has been performed in this cycle document creation step.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** TBD
**Phases Completed:** TBD
**Work Deferred:** TBD

**Accomplishments:**
- TBD

**Metrics:**
- Files modified: TBD
- In-game checks completed: TBD

**Lessons / Notes:**
- TBD