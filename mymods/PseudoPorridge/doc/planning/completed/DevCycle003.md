# DevCycle 003: Porridge Happiness Parity

**Status:** Work Complete
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Update pan and pot porridge evolved recipes to match vanilla rice-style base/result behavior for happiness handling.

---

## Goal

Adjust `PseudoPorridge` so `PorridgePan` and `PorridgePot` use separate water-porridge base items that convert into the final porridge result items through evolved recipes.

This cycle mirrors the confirmed `PseudoPeasePottage` DC 2 fix. The intended behavior is vanilla rice-style evolved recipe flow: the setup craft recipe creates a prepared water/container base item, and adding an evolved recipe ingredient converts that base item into the final pan or pot food item.

The existing `PorridgeBowl` workflow is not part of this fix. It has no scripted `UnhappyChange = 20` penalty and already follows an oatmeal-style bowl pattern.

## Desired Outcome

`PseudoPorridge` continues to support bowl, pan, and pot porridge, while pan and pot evolved recipe behavior now better matches vanilla rice/pasta item conversion behavior.

Implemented behavior:

- `MakePorridgePan` outputs `Pseudonymous.WaterSaucepanPorridge`.
- `MakePorridgePot` outputs `Pseudonymous.WaterPotPorridge`.
- `PorridgePan` evolved recipe uses `Pseudonymous.WaterSaucepanPorridge` as `BaseItem` and `Pseudonymous.PorridgePan` as `ResultItem`.
- `PorridgePot` evolved recipe uses `Pseudonymous.WaterPotPorridge` as `BaseItem` and `Pseudonymous.PorridgePot` as `ResultItem`.
- Both pan and pot evolved recipes keep oatmeal-compatible ingredient behavior through `Template = Oatmeal`.
- Existing DC 2 batch sizes and nutrition remain unchanged:
  - bowl = 60 flour units
  - pan = 120 flour units
  - pot = 300 flour units

---

## Tasks

### Phase 1: Confirm Current Script Shape

**Status:** Work Complete

- [x] Review current `PseudoPorridgeItems.txt` definitions for `PorridgeBowl`, `PorridgePan`, and `PorridgePot`.
- [x] Confirm `PorridgePan` and `PorridgePot` currently have `UnhappyChange = 20`.
- [x] Confirm current `MakePorridgePan` and `MakePorridgePot` recipes output the final pan/pot items directly.
- [x] Confirm current `PorridgePan` and `PorridgePot` evolved recipes use the same item as both `BaseItem` and `ResultItem`.
- [x] Confirm current evolved recipes already include `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

**Technical Notes:**
Pre-implementation review confirmed the same-item pan/pot evolved recipe shape targeted by this cycle.

### Phase 2: Add Intermediate Water-Porridge Items

**Status:** Work Complete

- [x] Add `Pseudonymous.WaterPotPorridge`.
- [x] Add `Pseudonymous.WaterSaucepanPorridge`.
- [x] Base pot behavior on vanilla `Base.WaterPotRice` / `Base.WaterPotPasta` structure where applicable.
- [x] Base saucepan behavior on vanilla `Base.WaterSaucepanRice` / `Base.WaterSaucepanPasta` structure where applicable.
- [x] Preserve cookware return behavior with `ReplaceOnUse = Base.Pot` and `ReplaceOnUse = Base.Saucepan`.
- [x] Add English item names for the intermediate items.
- [x] Add evolved recipe name translations if needed for item tooltip/ingredient display.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/items/PseudoPorridgeItems.txt` and EN translation JSON files.

The intermediate items carry the same batch nutrition as their corresponding final items so the evolved recipe conversion can copy/preserve intended values in the same style as vanilla rice.

### Phase 3: Update Craft Recipes

**Status:** Work Complete

- [x] Update `MakePorridgePan` to output `Pseudonymous.WaterSaucepanPorridge` instead of `Pseudonymous.PorridgePan`.
- [x] Update `MakePorridgePot` to output `Pseudonymous.WaterPotPorridge` instead of `Pseudonymous.PorridgePot`.
- [x] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [x] Preserve current flour amounts:
  - pan: 120 units of flour via `tags[base:flour]`
  - pot: 300 units of flour via `tags[base:flour]`
- [x] Leave `MakePorridgeBowl` unchanged.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/recipes/PseudoPorridgeRecipes.txt`.

### Phase 4: Update Evolved Recipes

**Status:** Work Complete

- [x] Change `PorridgePan` evolved recipe `BaseItem` to `Pseudonymous.WaterSaucepanPorridge`.
- [x] Keep `PorridgePan` evolved recipe `ResultItem = Pseudonymous.PorridgePan`.
- [x] Change `PorridgePot` evolved recipe `BaseItem` to `Pseudonymous.WaterPotPorridge`.
- [x] Keep `PorridgePot` evolved recipe `ResultItem = Pseudonymous.PorridgePot`.
- [x] Keep `MaxItems = 3`.
- [x] Keep `AddIngredientIfCooked = true`.
- [x] Keep `CanAddSpicesEmpty = true`.
- [x] Keep `Template = Oatmeal`.
- [x] Leave `PorridgeBowl` evolved recipe unchanged unless implementation review finds a specific issue.

**Technical Notes:**
Implemented in `PseudoPorridge/42/media/scripts/evolvedrecipes/PseudoPorridgeEvolvedRecipes.txt`.

### Phase 5: Nutrition And Happiness Review

**Status:** Work Complete

- [x] Confirm `WaterSaucepanPorridge` nutrition matches final `PorridgePan` nutrition:
  - `HungerChange = -120.0`
  - `Calories = 100.0`
  - `Carbohydrates = 42.0`
  - `Lipids = 0.0`
  - `Proteins = 10.0`
- [x] Confirm `WaterPotPorridge` nutrition matches final `PorridgePot` nutrition:
  - `HungerChange = -300.0`
  - `Calories = 250.0`
  - `Carbohydrates = 105.0`
  - `Lipids = 0.0`
  - `Proteins = 25.0`
- [x] Decide whether final `PorridgePan` and `PorridgePot` should keep `UnhappyChange = 20` for vanilla rice parity.
- [x] Confirm the change does not alter `PorridgeBowl` nutrition or behavior.

**Technical Notes:**
Decision: keep `UnhappyChange = 20` on the final pan/pot items and rely on the vanilla-style base-to-result conversion to reset unhappy/boredom before ingredient happiness adjustment.

### Phase 6: Static Checks

**Status:** Work Complete

- [x] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [x] Confirm pan/pot craft recipe outputs reference existing intermediate item IDs.
- [x] Confirm pan/pot evolved recipe `BaseItem` and `ResultItem` values reference existing item IDs.
- [x] Confirm EN translation JSON files parse.
- [x] Confirm `PorridgeBowl` remains present and unchanged in recipe intent.
- [x] Confirm `Template = Oatmeal` remains in all porridge evolved recipes.
- [x] Confirm script braces are balanced in modified script files.

**Technical Notes:**
Static checks completed with PowerShell and `rg`. JSON translation files parse, key references are present, and script braces are balanced.

### Phase 7: In-Game Verification

**Status:** Work Complete - requires in-game verification

- [ ] Launch Project Zomboid B42 with `PseudoPorridge` enabled and confirm no script parse errors.
- [ ] Craft `PorridgePan` flow from saucepan, water, and 120 units of flour.
- [ ] Craft `PorridgePot` flow from cooking pot, water, and 300 units of flour.
- [ ] Add a normal oatmeal-compatible ingredient to pan porridge and confirm happiness improves like the rice-style flow.
- [ ] Add a normal oatmeal-compatible ingredient to pot porridge and confirm happiness improves like the rice-style flow.
- [ ] Confirm bowl porridge still crafts and accepts oatmeal-compatible toppings.

**Technical Notes:**
In-game verification remains pending. Agents may record implementation as `Work Complete`, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Should bowl porridge also get an intermediate item?**
   Decision: no. The confirmed issue is the pan/pot `UnhappyChange = 20` plus same-item base/result setup. Bowl porridge remains unchanged.

2. **Should final pan/pot porridge keep `UnhappyChange = 20`?**
   Decision: yes, matching the vanilla rice pattern and the confirmed pease pottage DC 2 approach.

3. **Should this cycle change porridge ingredient eligibility?**
   Decision: no. Keep `Template = Oatmeal` and the existing oatmeal-compatible topping behavior.

---

## Notes and Risks

- This cycle does not change DC 2 batch sizes or nutrition values.
- The implementation updates existing pan/pot flows rather than introducing replacement final item IDs.
- The main behavior to verify in-game is whether the base-to-result conversion clears unhappy/boredom before the first ingredient adjustment, as expected from the pease pottage analysis.
- `PseudoPorridge` currently has older active DC1/DC2 planning documents marked `Work Complete`; this cycle is intentionally numbered DC3 and does not modify those documents.
- Per `mymods/PseudoPorridge/AGENTS.md`, this implementation was started only after explicit user request.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** 1-6 implementation/static review phases; Phase 7 prepared for in-game verification
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Added `Pseudonymous.WaterPotPorridge` and `Pseudonymous.WaterSaucepanPorridge` intermediate base items.
- Updated pan/pot craft recipes to output the intermediate water-porridge items.
- Updated pan/pot evolved recipes to convert intermediate water-porridge items into final porridge items.
- Preserved oatmeal-compatible evolved recipe behavior.
- Left `PorridgeBowl` unchanged.
- Added English item and evolved recipe name translations for the intermediate items.

**Metrics:**
- Files modified: 6 (`PseudoPorridgeItems.txt`, `PseudoPorridgeRecipes.txt`, `PseudoPorridgeEvolvedRecipes.txt`, `ItemName.json`, `EvolvedRecipeName.json`, `DevCycle003.md`)
- In-game checks completed: 0

**Lessons / Notes:**
- Pan/pot porridge now use the same base/result item pattern as the confirmed pease pottage fix while preserving the existing bowl workflow.
