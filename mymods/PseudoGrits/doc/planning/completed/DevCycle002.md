# DevCycle 002: Grits Bowl and Batch Scaling Adjustments

**Status:** Work Complete
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Add a bowl-sized grits recipe and scale pan/pot grits recipes for larger batches.

---

## Goal

Adjust `PseudoGrits` after DC 1 by adding a bowl-scale grits item and recipe, then increasing the batch size and nutrition of existing pan and pot grits recipes.

The new `MakeGritsBowl` recipe should create a `Pseudonymous.GritsBowl` item with the same nutrition currently used by the DC 1 grits pan and pot items. After that, `GritsPan` should become a double batch, and `GritsPot` should become a five-times batch.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. Players can craft:

- `GritsBowl` from a bowl, water, and 24 units of cornmeal.
- `GritsPan` from a saucepan, water, and 48 units of cornmeal.
- `GritsPot` from a cooking pot, water, and 120 units of cornmeal.

All three output items should have nutrition that matches the amount of corrected cornmeal consumed by their recipe.

---

## Nutrition Baseline

DC 1 corrected `Base.Cornmeal2` to represent 20 units of dried corn:

```txt
HungerChange = -80.0,
Calories = 496.0,
Carbohydrates = 152.0,
Lipids = 11.2,
Proteins = 26.4,
```

Current DC 1 grits items use 24 units of cornmeal, which is 24/80 of corrected cornmeal nutrition:

```txt
HungerChange = -24.0,
Calories = 148.8,
Carbohydrates = 45.6,
Lipids = 3.36,
Proteins = 7.92,
```

DC 2 should use that current value as the bowl baseline.

---

## Tasks

### Phase 1: Add Grits Bowl Item and Recipe

**Status:** Work Complete

- [x] Add a new mod-owned food item: `Pseudonymous.GritsBowl`.
- [x] Add a new craft recipe: `MakeGritsBowl`.
- [x] Require a bowl or clay bowl, water, and 24 units of `Base.Cornmeal2`.
- [x] Use the current DC 1 grits nutrition for `GritsBowl`:
  - `HungerChange = -24.0`
  - `Calories = 148.8`
  - `Carbohydrates = 45.6`
  - `Lipids = 3.36`
  - `Proteins = 7.92`
- [x] Use the vanilla oatmeal bowl amount, `0.3` water.
- [x] Add English item and recipe translations for `GritsBowl` and `MakeGritsBowl`.
- [x] Add a `GritsBowl` evolved recipe for oatmeal-style toppings.

**Technical Notes:**
Vanilla oatmeal bowl creation uses `item 1 [Base.Bowl;Base.ClayBowl]`, `-fluid 0.3 categories[Water] mode:mixture`, and a dry ingredient input. This is the closest vanilla structure for `MakeGritsBowl`.

`GritsBowl` should be bowl-sized and should not return cookware through `ReplaceOnUse` unless implementation research shows vanilla bowl foods do so.

### Phase 2: Double Grits Pan Batch

**Status:** Work Complete

- [x] Update `Pseudonymous.GritsPan` nutrition to double the current DC 1 value.
- [x] Update `MakeGritsPan` to require double the current cornmeal amount: 48 units of `Base.Cornmeal2`.
- [x] Keep the saucepan and water requirements unchanged.
- [x] Confirm evolved recipe definition remains present after nutrition and ingredient amount changes.

**Target Nutrition:**

```txt
HungerChange = -48.0,
Calories = 297.6,
Carbohydrates = 91.2,
Lipids = 6.72,
Proteins = 15.84,
```

**Technical Notes:**
Current DC 1 `GritsPan` uses 24 cornmeal units and the bowl baseline nutrition. DC 2 changes it to a larger batch: 48 cornmeal units and 2x nutrition.

### Phase 3: Scale Grits Pot to Five-Times Batch

**Status:** Work Complete

- [x] Update `Pseudonymous.GritsPot` nutrition to five times the current DC 1 value.
- [x] Update `MakeGritsPot` to require five times the current cornmeal amount: 120 units of `Base.Cornmeal2`.
- [x] Keep the cooking pot and water requirements unchanged.
- [x] Confirm evolved recipe definition remains present after nutrition and ingredient amount changes.

**Target Nutrition:**

```txt
HungerChange = -120.0,
Calories = 744.0,
Carbohydrates = 228.0,
Lipids = 16.8,
Proteins = 39.6,
```

**Technical Notes:**
Current DC 1 `GritsPot` uses 24 cornmeal units and the bowl baseline nutrition. DC 2 changes it to the largest batch: 120 cornmeal units and 5x nutrition.

### Phase 4: Static Review and In-Game Verification

**Status:** Work Complete

- [x] Confirm `PseudoGritsItems.txt` contains `GritsBowl`, updated `GritsPan`, and updated `GritsPot` nutrition.
- [x] Confirm `PseudoGritsRecipes.txt` contains `MakeGritsBowl`, `MakeGritsPan` with 48 cornmeal units, and `MakeGritsPot` with 120 cornmeal units.
- [x] Confirm EN translation JSON files parse.
- [x] Confirm all referenced vanilla item IDs exist, including bowl and clay bowl item IDs.
- [ ] Launch B42 with `PseudoGrits` enabled and confirm there are no script parse errors.
- [ ] Craft `GritsBowl` from a bowl, water, and 24 units of cornmeal.
- [ ] Craft `GritsPan` from a saucepan, water, and 48 units of cornmeal.
- [ ] Craft `GritsPot` from a cooking pot, water, and 120 units of cornmeal.
- [ ] Confirm each item's nutrition matches the intended batch size.
- [ ] Confirm toppings/evolved recipe behavior remains acceptable for pan and pot grits, and for bowl grits if a bowl evolved recipe is added.

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should `GritsBowl` have an evolved recipe for toppings?**
   Decision: yes. Implemented `GritsBowl` as an oatmeal-template evolved recipe so bowl grits can receive the same style of toppings.

2. **Should water scale with batch size?**
   Decision: no. Kept existing pan/pot water amounts and used vanilla oatmeal bowl water for `MakeGritsBowl`.

3. **Should pan/pot grits be divisible into bowls?**
   Decision: deferred. DC 2 adds direct bowl crafting and batch scaling; bowl division can be its own cycle if needed.

---

## Notes and Risks

- Implementation was requested explicitly after this DevCycle document was created, satisfying the `mymods/PseudoGrits/AGENTS.md` planning stop rule.
- The biggest implementation risk is accidentally mixing two different unit bases: corrected cornmeal item nutrition versus recipe unit amounts. Use the current DC 1 grits value as the baseline, then multiply it by 1x, 2x, and 5x for bowl, pan, and pot respectively.
- `GritsPan` and `GritsPot` already exist from DC 1; this cycle should update them rather than create replacement item IDs.
- `GritsBowl` was added with item, recipe, evolved recipe, and translation entries.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** 1-4 static implementation work complete
**Work Deferred:** In-game verification remains pending before this cycle can be marked `Verified`.

**Accomplishments:**
- Added `Pseudonymous.GritsBowl` with the DC 1 24-unit grits nutrition baseline.
- Added `MakeGritsBowl`, using a bowl or clay bowl, 0.3 water, and 24 units of `Base.Cornmeal2`.
- Added a bowl evolved recipe using `Template = Oatmeal`.
- Updated `MakeGritsPan` to require 48 units of cornmeal and updated `GritsPan` nutrition to 2x baseline.
- Updated `MakeGritsPot` to require 120 units of cornmeal and updated `GritsPot` nutrition to 5x baseline.
- Added English translations for the new bowl item, craft recipe, and evolved recipe.

**Metrics:**
- Files modified: 7
- In-game checks completed: 0

**Lessons / Notes:**
- Batch nutrition now follows one visible rule: bowl = 24 units, pan = 48 units, pot = 120 units of corrected cornmeal.
- Static checks passed for script presence, referenced vanilla item IDs, and EN JSON parse validity.