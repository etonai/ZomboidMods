# DevCycle 003: Grits Happiness Parity

**Status:** Planning
**Start Date:** 2026-06-29
**Target Completion:** TBD
**Focus:** Update pan and pot grits evolved recipes to match vanilla rice-style base/result behavior for happiness handling.

---

## Goal

Adjust `PseudoGrits` so `GritsPan` and `GritsPot` use separate water-grits base items that convert into the final grits result items through evolved recipes.

This cycle mirrors the confirmed `PseudoPeasePottage` DC 2 fix. The intended behavior is vanilla rice-style evolved recipe flow: the setup craft recipe creates a prepared water/container base item, and adding an evolved recipe ingredient converts that base item into the final pan or pot food item.

The existing `GritsBowl` workflow is not part of this fix. It has no scripted `UnhappyChange = 20` penalty and already follows an oatmeal-style bowl pattern.

## Desired Outcome

`PseudoGrits` should continue to support bowl, pan, and pot grits, but pan and pot evolved recipe behavior should better match vanilla rice/pasta item conversion behavior.

Desired behavior:

- `MakeGritsPan` outputs a new intermediate item, likely `Pseudonymous.WaterSaucepanGrits`.
- `MakeGritsPot` outputs a new intermediate item, likely `Pseudonymous.WaterPotGrits`.
- `GritsPan` evolved recipe uses the pan intermediate as `BaseItem` and `Pseudonymous.GritsPan` as `ResultItem`.
- `GritsPot` evolved recipe uses the pot intermediate as `BaseItem` and `Pseudonymous.GritsPot` as `ResultItem`.
- Both pan and pot evolved recipes keep oatmeal-compatible ingredient behavior through `Template = Oatmeal`.
- Existing DC 2 batch sizes and nutrition remain unchanged:
  - bowl = 24 cornmeal units
  - pan = 48 cornmeal units
  - pot = 120 cornmeal units

---

## Tasks

### Phase 1: Confirm Current Script Shape

**Status:** Planning

- [ ] Review current `PseudoGritsItems.txt` definitions for `GritsBowl`, `GritsPan`, and `GritsPot`.
- [ ] Confirm `GritsPan` and `GritsPot` currently have `UnhappyChange = 20`.
- [ ] Confirm current `MakeGritsPan` and `MakeGritsPot` recipes output the final pan/pot items directly.
- [ ] Confirm current `GritsPan` and `GritsPot` evolved recipes use the same item as both `BaseItem` and `ResultItem`.
- [ ] Confirm current evolved recipes already include `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

### Phase 2: Add Intermediate Water-Grits Items

**Status:** Planning

- [ ] Add `Pseudonymous.WaterPotGrits`.
- [ ] Add `Pseudonymous.WaterSaucepanGrits`.
- [ ] Base pot behavior on vanilla `Base.WaterPotRice` / `Base.WaterPotPasta` structure where applicable.
- [ ] Base saucepan behavior on vanilla `Base.WaterSaucepanRice` / `Base.WaterSaucepanPasta` structure where applicable.
- [ ] Preserve cookware return behavior with `ReplaceOnUse = Base.Pot` and `ReplaceOnUse = Base.Saucepan`.
- [ ] Add English item names for the intermediate items.
- [ ] Add evolved recipe name translations if needed for item tooltip/ingredient display.

**Technical Notes:**
The intermediate items should carry the same batch nutrition as their corresponding final items so the evolved recipe conversion can copy/preserve the intended values in the same style as vanilla rice.

### Phase 3: Update Craft Recipes

**Status:** Planning

- [ ] Update `MakeGritsPan` to output `Pseudonymous.WaterSaucepanGrits` instead of `Pseudonymous.GritsPan`.
- [ ] Update `MakeGritsPot` to output `Pseudonymous.WaterPotGrits` instead of `Pseudonymous.GritsPot`.
- [ ] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [ ] Preserve current cornmeal amounts:
  - pan: 48 units of `Base.Cornmeal2`
  - pot: 120 units of `Base.Cornmeal2`
- [ ] Leave `MakeGritsBowl` unchanged.

### Phase 4: Update Evolved Recipes

**Status:** Planning

- [ ] Change `GritsPan` evolved recipe `BaseItem` to `Pseudonymous.WaterSaucepanGrits`.
- [ ] Keep `GritsPan` evolved recipe `ResultItem = Pseudonymous.GritsPan`.
- [ ] Change `GritsPot` evolved recipe `BaseItem` to `Pseudonymous.WaterPotGrits`.
- [ ] Keep `GritsPot` evolved recipe `ResultItem = Pseudonymous.GritsPot`.
- [ ] Keep `MaxItems = 3`.
- [ ] Keep `AddIngredientIfCooked = true`.
- [ ] Keep `CanAddSpicesEmpty = true`.
- [ ] Keep `Template = Oatmeal`.
- [ ] Leave `GritsBowl` evolved recipe unchanged unless implementation review finds a specific issue.

### Phase 5: Nutrition And Happiness Review

**Status:** Planning

- [ ] Confirm `WaterSaucepanGrits` nutrition matches final `GritsPan` nutrition:
  - `HungerChange = -48.0`
  - `Calories = 297.6`
  - `Carbohydrates = 91.2`
  - `Lipids = 6.72`
  - `Proteins = 15.84`
- [ ] Confirm `WaterPotGrits` nutrition matches final `GritsPot` nutrition:
  - `HungerChange = -120.0`
  - `Calories = 744.0`
  - `Carbohydrates = 228.0`
  - `Lipids = 16.8`
  - `Proteins = 39.6`
- [ ] Decide whether final `GritsPan` and `GritsPot` should keep `UnhappyChange = 20` for vanilla rice parity.
- [ ] Confirm the change does not alter `GritsBowl` nutrition or behavior.

**Technical Notes:**
Recommended decision: keep `UnhappyChange = 20` on the final pan/pot items and rely on the vanilla-style base-to-result conversion to reset unhappy/boredom before ingredient happiness adjustment.

### Phase 6: Static Checks

**Status:** Planning

- [ ] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [ ] Confirm pan/pot craft recipe outputs reference existing intermediate item IDs.
- [ ] Confirm pan/pot evolved recipe `BaseItem` and `ResultItem` values reference existing item IDs.
- [ ] Confirm EN translation JSON files parse.
- [ ] Confirm `GritsBowl` remains present and unchanged in recipe intent.
- [ ] Confirm `Template = Oatmeal` remains in all grits evolved recipes.
- [ ] Confirm script braces are balanced in modified script files.

### Phase 7: In-Game Verification

**Status:** Planning

- [ ] Launch Project Zomboid B42 with `PseudoGrits` enabled and confirm no script parse errors.
- [ ] Craft `GritsPan` flow from saucepan, water, and 48 units of cornmeal.
- [ ] Craft `GritsPot` flow from cooking pot, water, and 120 units of cornmeal.
- [ ] Add a normal oatmeal-compatible ingredient to pan grits and confirm happiness improves like the rice-style flow.
- [ ] Add a normal oatmeal-compatible ingredient to pot grits and confirm happiness improves like the rice-style flow.
- [ ] Confirm bowl grits still craft and accept oatmeal-compatible toppings.

---

## Open Questions

1. **Should bowl grits also get an intermediate item?**
   Proposed decision: no. The confirmed issue is the pan/pot `UnhappyChange = 20` plus same-item base/result setup. Bowl grits has no scripted `UnhappyChange = 20` and should remain unchanged unless testing reveals a separate issue.

2. **Should final pan/pot grits keep `UnhappyChange = 20`?**
   Proposed decision: yes, matching the vanilla rice pattern and the confirmed pease pottage DC 2 approach.

3. **Should this cycle change grits ingredient eligibility?**
   Proposed decision: no. Keep `Template = Oatmeal` and the existing oatmeal-compatible topping behavior.

---

## Notes and Risks

- This cycle should not change DC 2 batch sizes or nutrition values.
- The implementation should update existing pan/pot flows rather than introduce replacement final item IDs.
- The main behavior to verify in-game is whether the base-to-result conversion clears unhappy/boredom before the first ingredient adjustment, as expected from the pease pottage analysis.
- Per `mymods/PseudoGrits/AGENTS.md`, implementation must not begin until explicitly requested after this DevCycle document is created.

---

## Completion Summary

**Completion Date:** TBD
**Phases Completed:** None
**Work Deferred:** TBD

**Accomplishments:**
- TBD

**Metrics:**
- Files modified: TBD
- In-game checks completed: 0

**Lessons / Notes:**
- TBD
