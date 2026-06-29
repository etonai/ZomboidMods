# DevCycle 003: Porridge Happiness Parity

**Status:** Planning
**Start Date:** 2026-06-29
**Target Completion:** TBD
**Focus:** Update pan and pot porridge evolved recipes to match vanilla rice-style base/result behavior for happiness handling.

---

## Goal

Adjust `PseudoPorridge` so `PorridgePan` and `PorridgePot` use separate water-porridge base items that convert into the final porridge result items through evolved recipes.

This cycle mirrors the confirmed `PseudoPeasePottage` DC 2 fix. The intended behavior is vanilla rice-style evolved recipe flow: the setup craft recipe creates a prepared water/container base item, and adding an evolved recipe ingredient converts that base item into the final pan or pot food item.

The existing `PorridgeBowl` workflow is not part of this fix. It has no scripted `UnhappyChange = 20` penalty and already follows an oatmeal-style bowl pattern.

## Desired Outcome

`PseudoPorridge` should continue to support bowl, pan, and pot porridge, but pan and pot evolved recipe behavior should better match vanilla rice/pasta item conversion behavior.

Desired behavior:

- `MakePorridgePan` outputs a new intermediate item, likely `Pseudonymous.WaterSaucepanPorridge`.
- `MakePorridgePot` outputs a new intermediate item, likely `Pseudonymous.WaterPotPorridge`.
- `PorridgePan` evolved recipe uses the pan intermediate as `BaseItem` and `Pseudonymous.PorridgePan` as `ResultItem`.
- `PorridgePot` evolved recipe uses the pot intermediate as `BaseItem` and `Pseudonymous.PorridgePot` as `ResultItem`.
- Both pan and pot evolved recipes keep oatmeal-compatible ingredient behavior through `Template = Oatmeal`.
- Existing DC 2 batch sizes and nutrition remain unchanged:
  - bowl = 60 flour units
  - pan = 120 flour units
  - pot = 300 flour units

---

## Tasks

### Phase 1: Confirm Current Script Shape

**Status:** Planning

- [ ] Review current `PseudoPorridgeItems.txt` definitions for `PorridgeBowl`, `PorridgePan`, and `PorridgePot`.
- [ ] Confirm `PorridgePan` and `PorridgePot` currently have `UnhappyChange = 20`.
- [ ] Confirm current `MakePorridgePan` and `MakePorridgePot` recipes output the final pan/pot items directly.
- [ ] Confirm current `PorridgePan` and `PorridgePot` evolved recipes use the same item as both `BaseItem` and `ResultItem`.
- [ ] Confirm current evolved recipes already include `AddIngredientIfCooked = true`, `CanAddSpicesEmpty = true`, `Template = Oatmeal`, and `Cookable = true`.

### Phase 2: Add Intermediate Water-Porridge Items

**Status:** Planning

- [ ] Add `Pseudonymous.WaterPotPorridge`.
- [ ] Add `Pseudonymous.WaterSaucepanPorridge`.
- [ ] Base pot behavior on vanilla `Base.WaterPotRice` / `Base.WaterPotPasta` structure where applicable.
- [ ] Base saucepan behavior on vanilla `Base.WaterSaucepanRice` / `Base.WaterSaucepanPasta` structure where applicable.
- [ ] Preserve cookware return behavior with `ReplaceOnUse = Base.Pot` and `ReplaceOnUse = Base.Saucepan`.
- [ ] Add English item names for the intermediate items.
- [ ] Add evolved recipe name translations if needed for item tooltip/ingredient display.

**Technical Notes:**
The intermediate items should carry the same batch nutrition as their corresponding final items so the evolved recipe conversion can copy/preserve the intended values in the same style as vanilla rice.

### Phase 3: Update Craft Recipes

**Status:** Planning

- [ ] Update `MakePorridgePan` to output `Pseudonymous.WaterSaucepanPorridge` instead of `Pseudonymous.PorridgePan`.
- [ ] Update `MakePorridgePot` to output `Pseudonymous.WaterPotPorridge` instead of `Pseudonymous.PorridgePot`.
- [ ] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [ ] Preserve current flour amounts:
  - pan: 120 units of flour via `tags[base:flour]`
  - pot: 300 units of flour via `tags[base:flour]`
- [ ] Leave `MakePorridgeBowl` unchanged.

### Phase 4: Update Evolved Recipes

**Status:** Planning

- [ ] Change `PorridgePan` evolved recipe `BaseItem` to `Pseudonymous.WaterSaucepanPorridge`.
- [ ] Keep `PorridgePan` evolved recipe `ResultItem = Pseudonymous.PorridgePan`.
- [ ] Change `PorridgePot` evolved recipe `BaseItem` to `Pseudonymous.WaterPotPorridge`.
- [ ] Keep `PorridgePot` evolved recipe `ResultItem = Pseudonymous.PorridgePot`.
- [ ] Keep `MaxItems = 3`.
- [ ] Keep `AddIngredientIfCooked = true`.
- [ ] Keep `CanAddSpicesEmpty = true`.
- [ ] Keep `Template = Oatmeal`.
- [ ] Leave `PorridgeBowl` evolved recipe unchanged unless implementation review finds a specific issue.

### Phase 5: Nutrition And Happiness Review

**Status:** Planning

- [ ] Confirm `WaterSaucepanPorridge` nutrition matches final `PorridgePan` nutrition:
  - `HungerChange = -120.0`
  - `Calories = 100.0`
  - `Carbohydrates = 42.0`
  - `Lipids = 0.0`
  - `Proteins = 10.0`
- [ ] Confirm `WaterPotPorridge` nutrition matches final `PorridgePot` nutrition:
  - `HungerChange = -300.0`
  - `Calories = 250.0`
  - `Carbohydrates = 105.0`
  - `Lipids = 0.0`
  - `Proteins = 25.0`
- [ ] Decide whether final `PorridgePan` and `PorridgePot` should keep `UnhappyChange = 20` for vanilla rice parity.
- [ ] Confirm the change does not alter `PorridgeBowl` nutrition or behavior.

**Technical Notes:**
Recommended decision: keep `UnhappyChange = 20` on the final pan/pot items and rely on the vanilla-style base-to-result conversion to reset unhappy/boredom before ingredient happiness adjustment.

### Phase 6: Static Checks

**Status:** Planning

- [ ] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [ ] Confirm pan/pot craft recipe outputs reference existing intermediate item IDs.
- [ ] Confirm pan/pot evolved recipe `BaseItem` and `ResultItem` values reference existing item IDs.
- [ ] Confirm EN translation JSON files parse.
- [ ] Confirm `PorridgeBowl` remains present and unchanged in recipe intent.
- [ ] Confirm `Template = Oatmeal` remains in all porridge evolved recipes.
- [ ] Confirm script braces are balanced in modified script files.

### Phase 7: In-Game Verification

**Status:** Planning

- [ ] Launch Project Zomboid B42 with `PseudoPorridge` enabled and confirm no script parse errors.
- [ ] Craft `PorridgePan` flow from saucepan, water, and 120 units of flour.
- [ ] Craft `PorridgePot` flow from cooking pot, water, and 300 units of flour.
- [ ] Add a normal oatmeal-compatible ingredient to pan porridge and confirm happiness improves like the rice-style flow.
- [ ] Add a normal oatmeal-compatible ingredient to pot porridge and confirm happiness improves like the rice-style flow.
- [ ] Confirm bowl porridge still crafts and accepts oatmeal-compatible toppings.

---

## Open Questions

1. **Should bowl porridge also get an intermediate item?**
   Proposed decision: no. The confirmed issue is the pan/pot `UnhappyChange = 20` plus same-item base/result setup. Bowl porridge has no scripted `UnhappyChange = 20` and should remain unchanged unless testing reveals a separate issue.

2. **Should final pan/pot porridge keep `UnhappyChange = 20`?**
   Proposed decision: yes, matching the vanilla rice pattern and the confirmed pease pottage DC 2 approach.

3. **Should this cycle change porridge ingredient eligibility?**
   Proposed decision: no. Keep `Template = Oatmeal` and the existing oatmeal-compatible topping behavior.

---

## Notes and Risks

- This cycle should not change DC 2 batch sizes or nutrition values.
- The implementation should update existing pan/pot flows rather than introduce replacement final item IDs.
- The main behavior to verify in-game is whether the base-to-result conversion clears unhappy/boredom before the first ingredient adjustment, as expected from the pease pottage analysis.
- `PseudoPorridge` currently has older active DC1/DC2 planning documents marked `Work Complete`; this cycle is intentionally numbered DC3 and does not modify those documents.
- Per `mymods/PseudoPorridge/AGENTS.md`, implementation must not begin until explicitly requested after this DevCycle document is created.

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
