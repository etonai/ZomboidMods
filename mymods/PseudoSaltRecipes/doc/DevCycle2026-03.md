# DevCycle 2026-03: Add lacto-fermented garlic to PseudoSaltRecipes

**Status:** Work Complete
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Use `claude_LactoFermentedVegetableRecipeAnalysis.md` to add fermented garlic items and recipes to the `PseudoSaltRecipes` mod.

---

## Goal

Add garlic to the existing lacto-fermented vegetable system in `PseudoSaltRecipes`. The new garlic family should follow the same item, stew, jar-tier, and recipe pattern documented in `mymods/PseudoSaltRecipes/doc/claude_LactoFermentedVegetableRecipeAnalysis.md`.

This cycle is scoped to garlic only. It produces the same complete unit of work used by the existing fermented vegetable families: three jarred fermented garlic items, three cooked stew variants, and three matching craft recipes.

## Desired Outcome

`PseudoSaltRecipes` contains a complete fermented garlic family for B42. Players can make fermented garlic in a glass jar, clay jar, or glazed clay jar, each recipe uses the same garlic count and nutrition formula, each jarred item cooks into its matching stew item, and each consumed item returns the matching jar type.

---

## Tasks

### Phase 1: Confirm Garlic Formula Inputs

**Status:** Work Complete

- [x] Verify vanilla `Base.Garlic` stats in `media/scripts/generated/items/food.txt`.
- [x] Compute the whole-number garlic count `N` using the documented formula.
- [x] Compute fermented garlic nutrition values from `N * vanilla garlic stats`.
- [x] Record the exact garlic stats and calculated values in this DevCycle before implementation.

**Technical Notes:**
Source analysis: `mymods/PseudoSaltRecipes/doc/claude_LactoFermentedVegetableRecipeAnalysis.md`.

Verified `Base.Garlic` in `media/scripts/generated/items/food.txt`: `HungerChange = -5.0`, `Calories = 14.0`, `Carbohydrates = 3.27`, `Lipids = 0.035`, and `Proteins = 0.385`.

Formula result:

| Field | Value |
|---|---:|
| `N` | 5 |
| `HungerChange` | -25.0 |
| `Calories` | 70.0 |
| `Carbohydrates` | 16.35 |
| `Lipids` | 0.175 |
| `Proteins` | 1.925 |

### Phase 2: Add Fermented Garlic Items

**Status:** Work Complete

- [x] Add `LactoFermentedGarlic` for the glass jar variant.
- [x] Add `LactoFermentedGarlicClayJar` for the clay jar variant.
- [x] Add `LactoFermentedGarlicGlazedJar` for the glazed clay jar variant.
- [x] Add `JarOfGarlicStew`, `ClayJarOfGarlicStew`, and `GlazedJarOfGarlicStew`.
- [x] Ensure every fermented garlic item has `ReplaceOnUse` and `ReplaceOnCooked` values matching its jar tier.
- [x] Ensure every cooked stew item returns the matching jar and does not define its own craft recipe.

**Technical Notes:**
Implemented in `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`, following the existing fermented vegetable family pattern.

Jar mapping:

| Fermented item | Cooked output | Returned jar |
|---|---|---|
| `LactoFermentedGarlic` | `JarOfGarlicStew` | `Base.EmptyJar` |
| `LactoFermentedGarlicClayJar` | `ClayJarOfGarlicStew` | `Base.ClayJar` |
| `LactoFermentedGarlicGlazedJar` | `GlazedJarOfGarlicStew` | `Base.ClayJarGlazed` |

All six items use the garlic formula values from Phase 1. The three fermented jar items use `DaysFresh = 120`, `DaysTotallyRotten = 240`, `IsCookable = TRUE`, and `ReplaceOnCooked`; the three stew items use `DaysFresh = 3`, `DaysTotallyRotten = 5`, `BadCold = false`, and `GoodHot = true`.

### Phase 3: Add Fermented Garlic Recipes

**Status:** Work Complete

- [x] Add `MakeFermentedGarlic`.
- [x] Add `MakeClayJarFermentedGarlic`.
- [x] Add `MakeGlazedJarFermentedGarlic`.
- [x] Use `item 5 [Base.Garlic] flags[InheritFoodAge;ItemCount] mode:destroy` in all three recipes.
- [x] Use `item 3 [Base.Salt]` and `-fluid 1.0 [Water;TaintedWater]` in all three recipes.
- [x] Ensure jar inputs and outputs match their jar tier.

**Technical Notes:**
Implemented in `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`, mirroring the existing sauerkraut/cucumber/carrot/radish pattern.

Recipe mapping:

| Recipe | Jar input | Output |
|---|---|---|
| `MakeFermentedGarlic` | `Base.EmptyJar` | `Pseudonymous.LactoFermentedGarlic` |
| `MakeClayJarFermentedGarlic` | `Base.ClayJar` | `Pseudonymous.LactoFermentedGarlicClayJar` |
| `MakeGlazedJarFermentedGarlic` | `Base.ClayJarGlazed` | `Pseudonymous.LactoFermentedGarlicGlazedJar` |

### Phase 4: Verification and Documentation

**Status:** Work Complete

- [x] Read back all edited item and recipe scripts.
- [x] Check the garlic family against the documented 6-items/3-recipes pattern.
- [x] Confirm no `*GarlicStew` item has a `craftRecipe`.
- [x] Check brace balance in edited scripts.
- [x] Update this DevCycle with implementation notes and any deviations.

**Technical Notes:**
In-game verification may require Ed. Do not mark this cycle `Verified` without explicit user permission.

Verification results:

| Check | Result |
|---|---:|
| Garlic item blocks | 6 |
| Garlic recipe blocks | 3 |
| Garlic stew craft recipes | 0 |
| Item script brace balance | Passed |
| Recipe script brace balance | Passed |

No in-game load/craft test was run in this cycle.

---

## Open Questions

1. ~~**Should garlic recipe names be singular or plural?**~~
   **Resolved:** Used singular `Garlic` because garlic is usually treated as a mass/ingredient name, and `MakeFermentedGarlic` reads more naturally than `MakeFermentedGarlics`.

2. ~~**Should this be implemented in `PseudoTestRecipes` first or directly in `PseudoSaltRecipes`?**~~
   **Resolved:** Implemented directly in `PseudoSaltRecipes` because Ed explicitly requested implementation of this DevCycle for the `PseudoSaltRecipes` mod.

---

## Notes and Risks

- Garlic is a vanilla food/spice item with `FoodType = Herb`; the fermented output follows the existing fermented vegetable family and uses `FoodType = Vegetables`.
- The computed `Lipids = 0.175` and `Proteins = 1.925` are more precise than most existing item values. They were preserved exactly to follow the documented formula.
- Current `PseudoSaltRecipes` paths are nested under `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/...`; implementation used these actual repository paths rather than the shorter paths in older analysis docs.
- This cycle is recorded as `Work Complete`, not `Verified`, because in-game verification remains pending Ed's approval/testing.

---

## Completion Summary

**Completion Date:** 2026-07-01
**Phases Completed:** All
**Work Deferred:** In-game load/craft/cook verification.

**Accomplishments:**
- Added three jarred fermented garlic items for glass, clay, and glazed clay jars.
- Added three matching cooked garlic stew items.
- Added three matching B42 craft recipes.
- Confirmed the garlic family matches the documented 6-items/3-recipes pattern.

**Metrics:**
- Files modified: 3
- Items added: 6
- Recipes added: 3

**Lessons / Notes:**
The garlic formula uses `N = 5`, producing `HungerChange = -25.0`, `Calories = 70.0`, `Carbohydrates = 16.35`, `Lipids = 0.175`, and `Proteins = 1.925`. No separate craft recipes are needed for the stew items; they are reached through `ReplaceOnCooked` from the fermented jar items.