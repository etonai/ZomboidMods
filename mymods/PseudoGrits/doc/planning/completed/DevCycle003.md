# DevCycle 003: Grits Happiness Parity

**Status:** Work Complete
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Update pan and pot grits evolved recipes to match vanilla rice-style base/result behavior for happiness handling.

---

## Goal

Adjust `PseudoGrits` so `GritsPan` and `GritsPot` use separate water-grits base items that convert into the final grits result items through evolved recipes.

This cycle mirrors the confirmed `PseudoPeasePottage` DC 2 fix. The intended behavior is vanilla rice-style evolved recipe flow: the setup craft recipe creates a prepared water/container base item, and adding an evolved recipe ingredient converts that base item into the final pan or pot food item.

The existing `GritsBowl` workflow is not part of this fix. It has no scripted `UnhappyChange = 20` penalty and already follows an oatmeal-style bowl pattern.

## Desired Outcome

`PseudoGrits` continues to support bowl, pan, and pot grits, while pan and pot evolved recipe behavior now better matches vanilla rice/pasta item conversion behavior.

Implemented behavior:

- `MakeGritsPan` outputs `Pseudonymous.WaterSaucepanGrits`.
- `MakeGritsPot` outputs `Pseudonymous.WaterPotGrits`.
- `GritsPan` evolved recipe uses `Pseudonymous.WaterSaucepanGrits` as `BaseItem` and `Pseudonymous.GritsPan` as `ResultItem`.
- `GritsPot` evolved recipe uses `Pseudonymous.WaterPotGrits` as `BaseItem` and `Pseudonymous.GritsPot` as `ResultItem`.
- Both pan and pot evolved recipes keep oatmeal-compatible ingredient behavior through `Template = Oatmeal`.
- Existing DC 2 batch sizes and nutrition remain unchanged:
  - bowl = 24 cornmeal units
  - pan = 48 cornmeal units
  - pot = 120 cornmeal units

---

## Tasks

### Phase 1: Confirm Current Script Shape

**Status:** Work Complete

- [x] Review current `PseudoGritsItems.txt` definitions for `GritsBowl`, `GritsPan`, and `GritsPot`.
- [x] Confirm `GritsPan` and `GritsPot` currently have `UnhappyChange = 20`.
- [x] Confirm current `MakeGritsPan` and `MakeGritsPot` recipes output the final pan/pot items directly.
- [x] Confirm current `GritsPan` and `GritsPot` evolved recipes use the same item as both `BaseItem` and `ResultItem`.
- [x] Confirm current evolved recipes already include `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

**Technical Notes:**
Pre-implementation review confirmed the same-item pan/pot evolved recipe shape targeted by this cycle.

### Phase 2: Add Intermediate Water-Grits Items

**Status:** Work Complete

- [x] Add `Pseudonymous.WaterPotGrits`.
- [x] Add `Pseudonymous.WaterSaucepanGrits`.
- [x] Base pot behavior on vanilla `Base.WaterPotRice` / `Base.WaterPotPasta` structure where applicable.
- [x] Base saucepan behavior on vanilla `Base.WaterSaucepanRice` / `Base.WaterSaucepanPasta` structure where applicable.
- [x] Preserve cookware return behavior with `ReplaceOnUse = Base.Pot` and `ReplaceOnUse = Base.Saucepan`.
- [x] Add English item names for the intermediate items.
- [x] Add evolved recipe name translations if needed for item tooltip/ingredient display.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/items/PseudoGritsItems.txt` and EN translation JSON files.

The intermediate items carry the same batch nutrition as their corresponding final items so the evolved recipe conversion can copy/preserve intended values in the same style as vanilla rice.

### Phase 3: Update Craft Recipes

**Status:** Work Complete

- [x] Update `MakeGritsPan` to output `Pseudonymous.WaterSaucepanGrits` instead of `Pseudonymous.GritsPan`.
- [x] Update `MakeGritsPot` to output `Pseudonymous.WaterPotGrits` instead of `Pseudonymous.GritsPot`.
- [x] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [x] Preserve current cornmeal amounts:
  - pan: 48 units of `Base.Cornmeal2`
  - pot: 120 units of `Base.Cornmeal2`
- [x] Leave `MakeGritsBowl` unchanged.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/recipes/PseudoGritsRecipes.txt`.

### Phase 4: Update Evolved Recipes

**Status:** Work Complete

- [x] Change `GritsPan` evolved recipe `BaseItem` to `Pseudonymous.WaterSaucepanGrits`.
- [x] Keep `GritsPan` evolved recipe `ResultItem = Pseudonymous.GritsPan`.
- [x] Change `GritsPot` evolved recipe `BaseItem` to `Pseudonymous.WaterPotGrits`.
- [x] Keep `GritsPot` evolved recipe `ResultItem = Pseudonymous.GritsPot`.
- [x] Keep `MaxItems = 3`.
- [x] Keep `AddIngredientIfCooked = true`.
- [x] Keep `CanAddSpicesEmpty = true`.
- [x] Keep `Template = Oatmeal`.
- [x] Leave `GritsBowl` evolved recipe unchanged unless implementation review finds a specific issue.

**Technical Notes:**
Implemented in `PseudoGrits/42/media/scripts/evolvedrecipes/PseudoGritsEvolvedRecipes.txt`.

### Phase 5: Nutrition And Happiness Review

**Status:** Work Complete

- [x] Confirm `WaterSaucepanGrits` nutrition matches final `GritsPan` nutrition:
  - `HungerChange = -48.0`
  - `Calories = 297.6`
  - `Carbohydrates = 91.2`
  - `Lipids = 6.72`
  - `Proteins = 15.84`
- [x] Confirm `WaterPotGrits` nutrition matches final `GritsPot` nutrition:
  - `HungerChange = -120.0`
  - `Calories = 744.0`
  - `Carbohydrates = 228.0`
  - `Lipids = 16.8`
  - `Proteins = 39.6`
- [x] Decide whether final `GritsPan` and `GritsPot` should keep `UnhappyChange = 20` for vanilla rice parity.
- [x] Confirm the change does not alter `GritsBowl` nutrition or behavior.

**Technical Notes:**
Decision: keep `UnhappyChange = 20` on the final pan/pot items and rely on the vanilla-style base-to-result conversion to reset unhappy/boredom before ingredient happiness adjustment.

### Phase 6: Static Checks

**Status:** Work Complete

- [x] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [x] Confirm pan/pot craft recipe outputs reference existing intermediate item IDs.
- [x] Confirm pan/pot evolved recipe `BaseItem` and `ResultItem` values reference existing item IDs.
- [x] Confirm EN translation JSON files parse.
- [x] Confirm `GritsBowl` remains present and unchanged in recipe intent.
- [x] Confirm `Template = Oatmeal` remains in all grits evolved recipes.
- [x] Confirm script braces are balanced in modified script files.

**Technical Notes:**
Static checks completed with PowerShell and `rg`. JSON translation files parse, key references are present, and script braces are balanced.

### Phase 7: In-Game Verification

**Status:** Work Complete - requires in-game verification

- [ ] Launch Project Zomboid B42 with `PseudoGrits` enabled and confirm no script parse errors.
- [ ] Craft `GritsPan` flow from saucepan, water, and 48 units of cornmeal.
- [ ] Craft `GritsPot` flow from cooking pot, water, and 120 units of cornmeal.
- [ ] Add a normal oatmeal-compatible ingredient to pan grits and confirm happiness improves like the rice-style flow.
- [ ] Add a normal oatmeal-compatible ingredient to pot grits and confirm happiness improves like the rice-style flow.
- [ ] Confirm bowl grits still craft and accept oatmeal-compatible toppings.

**Technical Notes:**
In-game verification remains pending. Agents may record implementation as `Work Complete`, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should bowl grits also get an intermediate item?**
   Decision: no. The confirmed issue is the pan/pot `UnhappyChange = 20` plus same-item base/result setup. Bowl grits remains unchanged.

2. **Should final pan/pot grits keep `UnhappyChange = 20`?**
   Decision: yes, matching the vanilla rice pattern and the confirmed pease pottage DC 2 approach.

3. **Should this cycle change grits ingredient eligibility?**
   Decision: no. Keep `Template = Oatmeal` and the existing oatmeal-compatible topping behavior.

---

## Notes and Risks

- This cycle does not change DC 2 batch sizes or nutrition values.
- The implementation updates existing pan/pot flows rather than introducing replacement final item IDs.
- The main behavior to verify in-game is whether the base-to-result conversion clears unhappy/boredom before the first ingredient adjustment, as expected from the pease pottage analysis.
- Per `mymods/PseudoGrits/AGENTS.md`, this implementation was started only after explicit user request.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** 1-6 implementation/static review phases; Phase 7 prepared for in-game verification
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Added `Pseudonymous.WaterPotGrits` and `Pseudonymous.WaterSaucepanGrits` intermediate base items.
- Updated pan/pot craft recipes to output the intermediate water-grits items.
- Updated pan/pot evolved recipes to convert intermediate water-grits items into final grits items.
- Preserved oatmeal-compatible evolved recipe behavior.
- Left `GritsBowl` unchanged.
- Added English item and evolved recipe name translations for the intermediate items.

**Metrics:**
- Files modified: 6 (`PseudoGritsItems.txt`, `PseudoGritsRecipes.txt`, `PseudoGritsEvolvedRecipes.txt`, `ItemName.json`, `EvolvedRecipeName.json`, `DevCycle003.md`)
- In-game checks completed: 0

**Lessons / Notes:**
- Pan/pot grits now use the same base/result item pattern as the confirmed pease pottage fix while preserving the existing bowl workflow.
