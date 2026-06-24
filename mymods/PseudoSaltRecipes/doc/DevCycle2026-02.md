# DevCycle 2026-02: Verify default nutrition values on Salted items

**Status:** Work Complete
**Start Date:** 2026-06-23
**Target Completion:** TBD
**Focus:** Go through every `Salted*` item in `PseudoSaltRecipes` and verify each has correct default nutrition values, since in-game testing showed `SaltedBeef` had no nutrition while `SaltedChicken` did.

---

## Goal

Ed observed in-game that a crafted `SaltedBeef` had no nutrition, while a crafted `SaltedChicken` did. Default nutrition values on an item are overridden at craft time if the crafting recipe inherits nutrition from the input item (e.g. via `InheritFood`), but they still matter as the item's static/default values otherwise. We need to check every `Salted*` item definition for default nutrition values and find out why `SaltedBeef` and `SaltedChicken` behave differently.

## Desired Outcome

A confirmed account of which `Salted*` items have default nutrition values set and which don't, why `SaltedBeef` is missing them while `SaltedChicken` isn't, and whether any items found missing defaults need them added — distinguishing between items where missing defaults are harmless (because a recipe always overrides them at craft time) and items where it's a real bug.

---

## Tasks

### Phase 1: Audit nutrition fields on all Salted items

**Status:** Work Complete

- [x] List every `Salted*` item in `PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt` and record which nutrition-related fields (`HungerChange`, `Calories`, `Carbohydrates`, `Lipids`, `Proteins`) are present vs. absent on each.
- [x] Identify why `SaltedBeef` has no nutrition values while `SaltedChicken` does — compare the two item definitions directly.
- [x] For each `Salted*` item, determine whether its crafting recipe(s) use `InheritFood`/`InheritFoodAge` (which overrides nutrition at craft time) — check `PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`.
- [x] Cross-reference findings against the corresponding items in `PseudoSaltRecipes/common/` to confirm consistency between `42/` and `common/`.
- [x] Record findings as a clear list: items missing default nutrition values, and for each, whether it's covered by recipe-time inheritance (harmless) or a genuine gap (needs fixing).

**Technical Notes:**

**Items missing default nutrition fields** (`HungerChange`, `Calories`, `Carbohydrates`, `Lipids`, `Proteins` all absent) — identical in both `42/` and `common/`:
- `SaltedFishFillet`, `SaltedVenison`, `SaltedBeef`, `SaltedSteak`, `SaltedRabbitmeat`

**Items that already have all five fields** — also identical in both `42/` and `common/`:
- `SaltedChicken`, `SaltedChickenFillet`, `SaltedPork`, `SaltedPorkChop`, `SaltedTurkeyFillet`, `SaltedMuttonChop`, `SaltedSmallbirdmeat`, `SaltedSmallanimalmeat`

This is the same 5-vs-8 split found in `PseudoTestRecipes/doc/planning/DevCycle001.md`: the original five `Salted*` items never had macro fields written into the item script, while the eight meats added later all do.

**Why `SaltedBeef` showed no nutrition in-game while `SaltedChicken` did:** Every `Salted*` item is produced by a `craftRecipe` (`MakeSaltedFillet`, `SaltMeatChickenStyle`, or `SaltMeatAnimalStyle` in `PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`) whose meat input carries `flags[InheritFood;ItemCount]`. Per `zombie42_19/entity/components/crafting/recipe/CraftRecipeData.java:1494-1497`, that flag triggers `Food.copyFoodFromSplit()` → `copyNutritionFromSplit()` (`zombie42_19/inventory/types/Food.java:2672-2686`), which **unconditionally overwrites** `HungChange`/`Calories`/`Carbohydrates`/`Lipids`/`Proteins` (plus a few other fields) on the output item from the live input meat's values, every time, regardless of which recipe or meat type is involved. `SaltMeatChickenStyle` and `SaltMeatAnimalStyle` both use this same flag on their meat inputs, so a `SaltedBeef` crafted through either recipe should be overwritten from `Base.Beef`'s nutrition (which is fully populated — `HungerChange = -80.0`, `Calories = 440.0`, `Carbohydrates = 0.0`, `Lipids = 18.7`, `Proteins = 62.62`, confirmed in `media/scripts/generated/items/food.txt:9746-9772`) just as reliably as `SaltedChicken` is from `Base.Chicken`.

**Conclusion:** the craft-time inheritance mechanism itself doesn't distinguish Beef from Chicken — both recipes apply it the same way. The empty nutrition Ed observed on `SaltedBeef` is consistent with the item not having gone through this craft-recipe path (e.g. spawned via debug/sandbox tools, or any other code path that constructs the item directly) — in that case it falls back to the item script's own static defaults, and `SaltedBeef` (like the other four original items) has none, while `SaltedChicken` does. This confirms the five items above are a genuine gap worth fixing for any non-craft code path, even though normal crafting will keep overriding them.

**Recommended default values, sourced from each item's vanilla counterpart** (`media/scripts/generated/items/food.txt`), for Phase 2's consideration:
| Item | HungerChange | Calories | Carbohydrates | Lipids | Proteins | Source |
|---|---|---|---|---|---|---|
| `SaltedFishFillet` | -25.0 | 205.0 | 1.0 | 12.0 | 28.52 | `Base.FishFillet` (food.txt:6850-6854) |
| `SaltedVenison` | -80.0 | 440.0 | 0.0 | 18.7 | 62.62 | `Base.Venison` (food.txt:9735-9739) |
| `SaltedBeef` | -80.0 | 440.0 | 0.0 | 18.7 | 62.62 | `Base.Beef` (food.txt:9763-9767) |
| `SaltedSteak` | -40.0 | 220.0 | 0.0 | 9.35 | 31.62 | `Base.Steak` (food.txt:9791-9795) |
| `SaltedRabbitmeat` | -30.0 | 969.0 | 20.0 | 20.0 | 185.0 | `Base.Rabbitmeat` (food.txt:10150-10154) |

This DevCycle's Phase 1 is audit-only — no item files were modified. Phase 2 (not yet scoped) would be where these defaults get added, if Ed decides they're worth adding given they're inert during normal crafting.

### Phase 2: Add default nutrition values to the five gapped Salted items

**Status:** Planning

- [ ] `SaltedFishFillet` — add `HungerChange = -25.0`, `Calories = 205.0`, `Carbohydrates = 1.0`, `Lipids = 12.0`, `Proteins = 28.52`.
- [ ] `SaltedVenison` — add `HungerChange = -80.0`, `Calories = 440.0`, `Carbohydrates = 0.0`, `Lipids = 18.7`, `Proteins = 62.62`.
- [ ] `SaltedBeef` — add `HungerChange = -80.0`, `Calories = 440.0`, `Carbohydrates = 0.0`, `Lipids = 18.7`, `Proteins = 62.62`.
- [ ] `SaltedSteak` — add `HungerChange = -40.0`, `Calories = 220.0`, `Carbohydrates = 0.0`, `Lipids = 9.35`, `Proteins = 31.62`.
- [ ] `SaltedRabbitmeat` — add `HungerChange = -30.0`, `Calories = 969.0`, `Carbohydrates = 20.0`, `Lipids = 20.0`, `Proteins = 185.0`.
- [ ] Apply the same additions to the matching items in `PseudoSaltRecipes/common/media/scripts/items/PseudoSaltItems.txt`, since Phase 1 confirmed `common/` mirrors `42/` for these items.

**Technical Notes:**
Values are sourced from each item's vanilla counterpart in `media/scripts/generated/items/food.txt` — see the table in Phase 1's Technical Notes for exact line references. These defaults only matter outside the normal craft-recipe path (e.g. debug/sandbox spawning) — `InheritFood` on the crafting recipes will continue to overwrite them at craft time, per Phase 1's findings.

---

## Open Questions

*None at cycle start.*

---

## Notes and Risks

- Phase 1 is verification-by-reading only — no files are modified in this phase.
- Default nutrition values matter even when a recipe overrides them at craft time, since the same item definition could be referenced by other recipes or contexts that don't apply that override.

---

## Completion Summary

*Fill in when the cycle closes.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**
-

**Metrics:**
-

**Lessons / Notes:**
