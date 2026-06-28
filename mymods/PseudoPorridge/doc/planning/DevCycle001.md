# DevCycle 001: Crafted Porridge Pot and Pan

**Status:** Planning
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Add pot and saucepan porridge bases that behave like rice evolved recipes while accepting oatmeal-compatible toppings.

---

## Goal

Create the first gameplay slice for `PseudoPorridge`: players can prepare porridge in a cooking pot or saucepan, then add ingredients to it through evolved recipes named `Porridge (crafted pot)` and `Porridge (crafted pan)`.

The recipes should be based on the vanilla rice pot and rice saucepan flow, but the porridge base should start from a container, water, and flour. Once created, the porridge should accept any ingredient that vanilla `Bowl of Oatmeal` accepts.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can craft a pot or saucepan of porridge from the appropriate cookware, water, and flour, then add the same toppings or mix-ins that are valid for vanilla oatmeal.

The two player-facing evolved recipe names should be:

- `Porridge (crafted pot)`
- `Porridge (crafted pan)`

---

## Tasks

### Phase 1: Confirm Vanilla Source Patterns

**Status:** Planning

- [ ] Review vanilla rice setup recipes before implementation:
  - `media/scripts/generated/recipes/recipes_cooking.txt:233` defines `PlaceRiceInSaucepan2`.
  - `media/scripts/generated/recipes/recipes_cooking.txt:279` defines `PlaceRiceInCookingPot2`.
- [ ] Review vanilla oatmeal creation and topping behavior:
  - `media/scripts/generated/recipes/recipes_cooking.txt:537` defines `MakeBowlOfOatmeal`.
  - `media/scripts/generated/evolvedrecipes.txt:635` defines the `Oatmeal` evolved recipe.
- [ ] Confirm whether B42 evolved recipe ingredient eligibility is tied only to item `EvolvedRecipe` entries, or whether `Template = Oatmeal` can inherit ingredient eligibility automatically.

**Technical Notes:**
Vanilla rice setup is only the structural model for cookware plus water producing a prepared pot/pan food item. The saucepan recipe consumes `0.6` water and maps saucepans to `Base.WaterSaucepanRice`; the cooking pot recipe consumes `1.5` water and maps pots to `Base.WaterPotRice`. Porridge should not require `Base.Rice`.

Vanilla oatmeal creation uses a bowl or clay bowl, `0.3` water, and `item 10 [Base.OatsRaw]`, producing `Base.Oatmeal`. The vanilla `Oatmeal` evolved recipe uses `BaseItem = Base.Oatmeal`, `MaxItems = 3`, `ResultItem = Base.Oatmeal`, `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

### Phase 2: Add Porridge Base Items

**Status:** Planning

- [ ] Create mod-owned food items for the pot and pan porridge bases.
- [ ] Use `module Pseudonymous` for mod-owned items unless implementation research shows a stronger reason to place them in `module Base`.
- [ ] Choose item IDs that clearly distinguish pot and pan forms, such as `Pseudonymous.PorridgePot` and `Pseudonymous.PorridgePan`.
- [ ] Base item food/container behavior on vanilla `Base.RicePot` and `Base.RicePan`.
- [ ] Add English item names for the new items.

**Technical Notes:**
Vanilla rice container items are in `media/scripts/generated/items/food.txt`:

- `Base.RicePan` at line 6206.
- `Base.RicePot` at line 6266.
- `Base.WaterPotRice` at line 11269.
- `Base.WaterSaucepanRice` at line 11393.

### Phase 3: Add Craft Recipes for Porridge Bases

**Status:** Planning

- [ ] Add a craft recipe for cooking-pot porridge.
- [ ] Add a craft recipe for saucepan porridge.
- [ ] Follow the B42 rice recipe structure: cookware input destroyed with condition inheritance, water input as a fluid mixture, and dry food inputs consumed.
- [ ] Require flour and water as the porridge ingredients.
- [ ] Prefer `tags[base:flour]` for flour so vanilla wheat flour and cornflour both work, unless testing shows that is too broad.
- [ ] Decide final water and flour quantities during implementation; recommended starting point is to mirror rice water amounts and use an amount of flour that feels comparable to vanilla oatmeal's dry ingredient cost.
- [ ] Add English recipe names for the setup recipes.

**Technical Notes:**
Vanilla flour candidates:

- `Base.Flour2` at `media/scripts/generated/items/food.txt:5162`.
- `Base.Cornflour2` at `media/scripts/generated/items/food.txt:5130`.

Both should be checked for `base:flour` tagging before implementation.

### Phase 4: Add Porridge Evolved Recipes

**Status:** Planning

- [ ] Add `Porridge (crafted pot)` as an evolved recipe using the pot porridge base item.
- [ ] Add `Porridge (crafted pan)` as an evolved recipe using the pan porridge base item.
- [ ] Use the vanilla oatmeal behavior as the model: `MaxItems = 3`, `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true` unless testing indicates a mismatch.
- [ ] Determine the safest recipe IDs for the evolved recipes, such as `PorridgePot` and `PorridgePan`, with player-facing `Name` values set to the requested names.
- [ ] Add English context menu translations for both evolved recipe names.

**Technical Notes:**
Vanilla oatmeal-compatible ingredients are items whose `EvolvedRecipe` list contains `Oatmeal`, such as fruits, sugar, chocolate, butter, milk, ginger, and other sweet or breakfast-compatible items in `media/scripts/generated/items/food.txt`.

Important risk: If eligibility is tied to evolved recipe names rather than templates, a new `PorridgePot` or `PorridgePan` recipe will not automatically receive the vanilla oatmeal ingredient set. In that case, implementation must add the new recipe IDs to every vanilla item that currently contains `Oatmeal` in its `EvolvedRecipe` list, or find a cleaner B42-supported way to alias oatmeal ingredient eligibility.

### Phase 5: Static Review and In-Game Verification

**Status:** Planning

- [ ] Confirm all new script files are under `PseudoPorridge/42/media/scripts/`.
- [ ] Confirm translation files are under `PseudoPorridge/42/media/lua/shared/Translate/EN/`.
- [ ] Confirm all referenced item IDs exist or are defined by the mod.
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
   Recommended starting point: yes, use `tags[base:flour]`, matching the flexible flour approach used in nearby mod planning.

2. **Should porridge use vanilla rice item art/models or new custom art?**
   Recommended starting point: use rice pot/pan visuals for minimal scope, then add custom icons/models in a later cycle if the recipes feel good.

3. **Should porridge use rice in any form?**
   Decision: no. Rice recipes are a structural reference only; porridge should use flour and water, not `Base.Rice`.

4. **Should the pot and pan porridge be divisible into bowls?**
   Recommended starting point: defer bowl division to a later cycle unless this becomes necessary for gameplay feel.

---

## Notes and Risks

- Per `mymods/PseudoPorridge/AGENTS.md`, agents must stop after creating this DevCycle document and must not begin implementation until Ed explicitly requests it.
- `PseudoPorridge/42/media/scripts/` does not yet exist at cycle creation time, so implementation will likely need to create `items/`, `recipes/`, and `evolvedrecipes/` script folders.
- The main technical risk is oatmeal ingredient compatibility. Vanilla items list `Oatmeal` by evolved recipe name, so new porridge evolved recipe IDs may require item overrides or another compatibility strategy.
- The requested starting ingredients are interpreted as cookware plus water plus flour. Rice recipes are only a reference for the pot/pan preparation pattern.

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
