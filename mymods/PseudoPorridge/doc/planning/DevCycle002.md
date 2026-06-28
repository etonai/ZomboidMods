# DevCycle 002: Porridge Bowl and Batch Scaling Adjustments

**Status:** Work Complete
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Add a bowl-sized porridge recipe and scale pan/pot porridge recipes for larger batches.

---

## Goal

Adjust `PseudoPorridge` after DC 1 by adding a bowl-scale porridge item and recipe, then increasing the batch size and nutrition of the existing pan and pot porridge recipes.

The new `MakePorridgeBowl` recipe should create a `Pseudonymous.PorridgeBowl` item with the same nutrition currently used by the DC 1 porridge pan and pot items. After that, `PorridgePan` should become a double batch, and `PorridgePot` should become a five-times batch.

This follows the same design pattern recently used for `PseudoGrits` DC 2.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. Players can craft:

- `PorridgeBowl` from a bowl, water, and 60 units of flour.
- `PorridgePan` from a saucepan, water, and 120 units of flour.
- `PorridgePot` from a cooking pot, water, and 300 units of flour.

All three output items should have nutrition that matches the amount of flour consumed by their recipe.

---

## Nutrition Baseline

DC 1 changed porridge to use 60 units of flour, which is one full vanilla flour bag. The current porridge nutrition therefore matches `Base.Flour2`:

```txt
HungerChange = -60.0,
Calories = 50.0,
Carbohydrates = 21.0,
Lipids = 0.0,
Proteins = 5.0,
```

DC 2 should use that current DC 1 value as the bowl baseline.

---

## Tasks

### Phase 1: Add Porridge Bowl Item and Recipe

**Status:** Work Complete

- [x] Add a new mod-owned food item: `Pseudonymous.PorridgeBowl`.
- [x] Add a new craft recipe: `MakePorridgeBowl`.
- [x] Require a bowl or clay bowl, water, and 60 units of flour.
- [x] Use the current DC 1 porridge nutrition for `PorridgeBowl`:
  - `HungerChange = -60.0`
  - `Calories = 50.0`
  - `Carbohydrates = 21.0`
  - `Lipids = 0.0`
  - `Proteins = 5.0`
- [x] Use the vanilla oatmeal bowl amount, `0.3` water.
- [x] Add English item and recipe translations for `PorridgeBowl` and `MakePorridgeBowl`.
- [x] Add a `PorridgeBowl` evolved recipe for oatmeal-style toppings.

**Technical Notes:**
Vanilla oatmeal bowl creation uses `item 1 [Base.Bowl;Base.ClayBowl]`, `-fluid 0.3 categories[Water] mode:mixture`, and a dry ingredient input. This is the closest vanilla structure for `MakePorridgeBowl`.

`PorridgeBowl` should be bowl-sized and should return an empty bowl on use if that matches the chosen vanilla bowl-food pattern.

### Phase 2: Double Porridge Pan Batch

**Status:** Work Complete

- [x] Update `Pseudonymous.PorridgePan` nutrition to double the bowl baseline.
- [x] Update `MakePorridgePan` to require double the bowl flour amount: 120 units of flour.
- [x] Keep the saucepan and water requirements unchanged.
- [x] Confirm evolved recipe definition remains present after nutrition and ingredient amount changes.

**Target Nutrition:**

```txt
HungerChange = -120.0,
Calories = 100.0,
Carbohydrates = 42.0,
Lipids = 0.0,
Proteins = 10.0,
```

**Technical Notes:**
Current DC 1 `PorridgePan` uses 60 flour units and the bowl baseline nutrition. DC 2 changes it to a larger batch: 120 flour units and 2x nutrition.

### Phase 3: Scale Porridge Pot to Five-Times Batch

**Status:** Work Complete

- [x] Update `Pseudonymous.PorridgePot` nutrition to five times the bowl baseline.
- [x] Update `MakePorridgePot` to require five times the bowl flour amount: 300 units of flour.
- [x] Keep the cooking pot and water requirements unchanged.
- [x] Confirm evolved recipe definition remains present after nutrition and ingredient amount changes.

**Target Nutrition:**

```txt
HungerChange = -300.0,
Calories = 250.0,
Carbohydrates = 105.0,
Lipids = 0.0,
Proteins = 25.0,
```

**Technical Notes:**
Current DC 1 `PorridgePot` uses 60 flour units and the bowl baseline nutrition. DC 2 changes it to the largest batch: 300 flour units and 5x nutrition.

### Phase 4: Static Review and In-Game Verification

**Status:** Work Complete

- [x] Confirm `PseudoPorridgeItems.txt` contains `PorridgeBowl`, updated `PorridgePan`, and updated `PorridgePot` nutrition.
- [x] Confirm `PseudoPorridgeRecipes.txt` contains `MakePorridgeBowl`, `MakePorridgePan` with 120 flour units, and `MakePorridgePot` with 300 flour units.
- [x] Confirm EN translation JSON files parse.
- [x] Confirm all referenced vanilla item IDs exist, including bowl and clay bowl item IDs.
- [ ] Launch B42 with `PseudoPorridge` enabled and confirm there are no script parse errors.
- [ ] Craft `PorridgeBowl` from a bowl, water, and 60 units of flour.
- [ ] Craft `PorridgePan` from a saucepan, water, and 120 units of flour.
- [ ] Craft `PorridgePot` from a cooking pot, water, and 300 units of flour.
- [ ] Confirm each item's nutrition matches the intended batch size.
- [ ] Confirm toppings/evolved recipe behavior remains acceptable for bowl, pan, and pot porridge.

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should water scale with batch size?**
   Proposed decision: no, matching the recent `PseudoGrits` work. Use vanilla oatmeal bowl water for `MakePorridgeBowl`, and keep the existing pan/pot water amounts unchanged.

2. **Should pan/pot porridge be divisible into bowls?**
   Proposed decision: defer. This cycle adds direct bowl crafting and batch scaling; bowl division can be a later cycle if needed.

---

## Notes and Risks

- Implementation was requested explicitly after this DevCycle document was created, satisfying the `mymods/PseudoPorridge/AGENTS.md` planning stop rule.
- The biggest implementation risk is mixing two unit bases: flour item nutrition versus recipe flour units. Use the current DC 1 porridge value as the bowl baseline, then multiply it by 1x, 2x, and 5x for bowl, pan, and pot respectively.
- `PorridgePan` and `PorridgePot` already exist from DC 1; this cycle should update them rather than create replacement item IDs.
- `PorridgeBowl` was added with item, recipe, evolved recipe, and translation entries.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** 1-4 static implementation work complete
**Work Deferred:** In-game verification remains pending before this cycle can be marked `Verified`.

**Accomplishments:**
- Added `Pseudonymous.PorridgeBowl` with the DC 1 60-unit flour nutrition baseline.
- Added `MakePorridgeBowl`, using a bowl or clay bowl, 0.3 water, and 60 units of flour.
- Added a bowl evolved recipe using `Template = Oatmeal`.
- Updated `MakePorridgePan` to require 120 units of flour and updated `PorridgePan` nutrition to 2x baseline.
- Updated `MakePorridgePot` to require 300 units of flour and updated `PorridgePot` nutrition to 5x baseline.
- Added English translations for the new bowl item, craft recipe, and evolved recipe.

**Metrics:**
- Files modified: 8
- In-game checks completed: 0

**Lessons / Notes:**
- Batch nutrition now follows one visible rule: bowl = 60 units, pan = 120 units, pot = 300 units of flour.
- Static checks passed for script presence, referenced vanilla item IDs, and EN JSON parse validity.
