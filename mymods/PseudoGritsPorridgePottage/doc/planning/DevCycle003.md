# DevCycle 003: Investigate Porridge and Pease Pottage Balance

**Status:** Planning
**Start Date:** 2026-06-30
**Target Completion:** TBD
**Focus:** Investigate whether porridge hunger values are too high and whether pease pottage uses enough peas relative to calories.

---

## Goal

Investigate the hunger and calorie balance for porridge in `PseudoGritsPorridgePottage`.

The current porridge values look high on hunger reduction compared to their calories. One possible explanation is that vanilla flour has an unusually high hunger value compared to its calories, and the porridge recipes may have inherited that ratio directly.

## Desired Outcome

Decide whether porridge should keep its current hunger values and whether pease pottage should change pea quantities, hunger, or calories in a later implementation cycle.

Expected investigation output:

- Compare porridge hunger and calories against vanilla flour-related ingredients.
- Compare pease pottage recipe quantities against dry pea calories and hunger.
- Confirm whether porridge values are directly derived from flour values.
- Decide whether current porridge hunger is acceptable, or propose revised values.
- Decide whether current pease pottage pea counts are acceptable, or propose revised recipe quantities and nutrition values.
- Avoid changing item values during this investigation cycle unless Ed explicitly requests implementation.

---

## Current Reference Values

### Vanilla Dry Ingredient Values

Source: `media/scripts/generated/items/food.txt` unless otherwise noted.

| Ingredient | Item ID | HungerChange | Calories | Notes |
| --- | --- | ---: | ---: | --- |
| Flour | `Base.Flour2` | -60.0 | 50.0 | Has `Tags = base:flour;base:minoringredient`. |
| Corn flour | `Base.Cornflour2` | -60.0 | Not set in item block | Has `Tags = base:flour;base:minoringredient`; no explicit `Calories` line found in the vanilla item block. |
| Cornmeal, vanilla | `Base.Cornmeal2` | -20.0 | Not set in item block | Vanilla item has no `base:flour` tag and no explicit `Calories` line. |
| Cornmeal, combined mod override | `Base.Cornmeal2` | -80.0 | 496.0 | Defined in `PseudoGritsItems.txt`; this override is active when the combined mod is enabled. |

### Current Porridge Values

Source: `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/scripts/items/PseudoPorridgeItems.txt`.

| Porridge Item | HungerChange | Calories | Notes |
| --- | ---: | ---: | --- |
| `Pseudonymous.PorridgeBowl` | -60.0 | 50.0 | Matches `Base.Flour2` exactly. |
| `Pseudonymous.WaterSaucepanPorridge` | -120.0 | 100.0 | 2x flour-style values. |
| `Pseudonymous.PorridgePan` | -120.0 | 100.0 | 2x flour-style values. |
| `Pseudonymous.WaterPotPorridge` | -300.0 | 250.0 | 5x flour-style values. |
| `Pseudonymous.PorridgePot` | -300.0 | 250.0 | 5x flour-style values. |

### Recipe Quantities

Source: `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/scripts/recipes/PseudoPorridgeRecipes.txt`.

| Recipe | Flour Input | Output | Current Hunger/Calories Pattern |
| --- | ---: | --- | --- |
| `MakePorridgeBowl` | 60 units tagged `base:flour` | `PorridgeBowl` | 1x `Base.Flour2` values: -60 hunger, 50 calories. |
| `MakePorridgePan` | 120 units tagged `base:flour` | `WaterSaucepanPorridge` | 2x `Base.Flour2` values: -120 hunger, 100 calories. |
| `MakePorridgePot` | 300 units tagged `base:flour` | `WaterPotPorridge` | 5x `Base.Flour2` values: -300 hunger, 250 calories. |

### Seed and Dry Crop Values

Source: `media/scripts/generated/items/food.txt`.

| Item | Item ID | HungerChange | Calories | Notes |
| --- | --- | ---: | ---: | --- |
| Barley seed | `Base.BarleySeed` | -5.0 | Not set in item block | `CantEat = true`; one of the flour inputs. |
| Rye seed | `Base.RyeSeed` | -5.0 | Not set in item block | `CantEat = true`; one of the flour inputs. |
| Wheat seed | `Base.WheatSeed` | -5.0 | Not set in item block | `CantEat = true`; one of the flour inputs. |
| Dry corn / corn seed | `Base.CornSeed` | -4.0 | 24.8 | Used to make corn flour or cornmeal. |
| Dry pea / green pea seed | `Base.GreenpeasSeed` | -1.0 | 17.5 | Used by pease pottage recipes as a dried pea equivalent. |

Only `BarleySeed`, `RyeSeed`, and `WheatSeed` were found with `HungerChange = -5.0` and no explicit `Calories` line among seed-like item blocks in `food.txt`.

### Milling and Grinding Inputs

Sources: `media/scripts/generated/entities/agricultural/workstations/entity_stone_quern_craftRecipe.txt` and `media/scripts/generated/entities/agricultural/workstations/entity_stone_mill_craftRecipe.txt`.

| Recipe | Input | Output | Hunger Math |
| --- | --- | --- | --- |
| `GrindFlour` / `MillFlour` | 12 `Base.WheatSeed`, `Base.RyeSeed`, or `Base.BarleySeed` | 1 `Base.Flour2` | 12 x -5 = -60, matching flour hunger. |
| `GrindCornflour` / `MillCornflour` | 20 `Base.CornSeed` | 1 `Base.Cornflour2` | 20 x -4 = -80, but vanilla corn flour is -60 hunger. |
| `GrindCornmeal` / `MillCornmeal` | 20 `Base.CornSeed` | 1 `Base.Cornmeal2` | 20 x -4 = -80, matching the combined mod cornmeal override but not vanilla cornmeal. |

### Current Pease Pottage Values

Sources: `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/scripts/items/PseudoPeasePottageItems.txt` and `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/scripts/recipes/PseudoPeasePottageRecipes.txt`.

| Pease Pottage Item | Recipe Input | HungerChange | Calories | Notes |
| --- | ---: | ---: | ---: | --- |
| `Pseudonymous.WaterSaucepanPeasePottage` | 3 `Base.Greenpeas` or `Base.GreenpeasSeed` | -3.0 | 52.5 | Matches 3 dry peas at 17.5 calories each. |
| `Pseudonymous.PeasePottagePan` | Result after adding ingredients | -3.0 | 52.5 | Same base nutrition as water-base saucepan item. |
| `Pseudonymous.WaterPotPeasePottage` | 8 `Base.Greenpeas` or `Base.GreenpeasSeed` | -8.0 | 140.0 | Matches 8 dry peas at 17.5 calories each. |
| `Pseudonymous.PeasePottagePot` | Result after adding ingredients | -8.0 | 140.0 | Same base nutrition as water-base pot item. |

### Pease Pottage Question

A cup of dry peas is around 230 calories. If a cooking pot of pease pottage is intended to represent roughly that amount of dry peas, the current pot recipe may be low:

- `Base.GreenpeasSeed` is `HungerChange = -1.0`, `Calories = 17.5`.
- Current pot recipe uses 8 peas/dry peas.
- 8 x 17.5 = 140 calories, matching the current pot item calories.
- 230 / 17.5 = 13.14, so a 230-calorie pot would imply about 13 dry peas if using vanilla dry pea calories.
- A proportional saucepan amount would be about 5 dry peas if saucepan remains smaller than the pot by roughly the current 3:8 ratio.

Possible pease pottage balance directions to investigate:

- Increase `MakePeasePottagePot` from 8 peas/dry peas to about 13.
- Increase `MakePeasePottagePan` from 3 peas/dry peas to about 5.
- Update pease pottage calories to about 230 for pot and about 87.5 for saucepan if using 13/5 dry peas.
- Update pease pottage hunger to match the new dry pea counts if continuing the current 1 pea = -1 hunger pattern.
- Consider whether fresh `Base.Greenpeas` and dry `Base.GreenpeasSeed` should be interchangeable in the same quantity, since their calorie profiles differ.

### Working Hypothesis

The porridge hunger issue may originate upstream from the vanilla grain seed and flour data rather than from porridge itself.

Observed chain:

- `Base.WheatSeed`, `Base.RyeSeed`, and `Base.BarleySeed` each have `HungerChange = -5.0` and no listed calories.
- 12 of those seeds make 1 `Base.Flour2`.
- 12 x -5 hunger = -60 hunger, exactly matching `Base.Flour2`.
- `Base.Flour2` has only 50 calories, so the flour hunger is high relative to calories.
- Porridge then copies/scales `Base.Flour2`, giving the bowl -60 hunger and 50 calories.

Possible balance directions to investigate:

- Wheat/rye/barley seeds may have too much hunger for seed-sized inputs.
- Flour may need different calories if its hunger remains -60.
- Flour may need lower hunger if its calories remain 50.
- Milling flour may need more than 12 wheat/rye/barley seeds if the intended output is a meaningful bulk flour item.
- Porridge may still need independent values if vanilla flour data is not a good gameplay basis for cooked porridge.

### Recommendation

Recommendation: do not override vanilla `Base.WheatSeed`, `Base.RyeSeed`, `Base.BarleySeed`, or `Base.Flour2` in `PseudoGritsPorridgePottage`.

Reasoning:

- The grain seed/flour relationship looks suspicious, but changing those vanilla items would be a broad agricultural/economy rebalance outside the scope of this combined food mod.
- Porridge is the actual player-facing issue in this mod, and its current values are extreme compared with vanilla cooked grain foods.
- Vanilla `Base.Oatmeal` is `HungerChange = -10.0`, `Calories = 300.0`.
- Vanilla `Base.RiceBowl` is `HungerChange = -12.0`, `Calories = 160.0`.
- Vanilla `Base.PastaBowl` is `HungerChange = -12.0`, `Calories = 330.0`.
- Current `Pseudonymous.PorridgeBowl` is `HungerChange = -60.0`, `Calories = 50.0`, which makes it much more filling than comparable cooked grain bowls while providing far fewer calories.

Recommended DC 4 implementation:

| Porridge Item | Current Hunger | Recommended Hunger | Current Calories | Recommended Calories | Reason |
| --- | ---: | ---: | ---: | ---: | --- |
| `Pseudonymous.PorridgeBowl` | -60.0 | -10.0 | 50.0 | 300.0 | Match vanilla oatmeal, since porridge is closest to oatmeal in gameplay role. |
| `Pseudonymous.WaterSaucepanPorridge` | -120.0 | -20.0 | 100.0 | 600.0 | Two bowl-equivalents. |
| `Pseudonymous.PorridgePan` | -120.0 | -20.0 | 100.0 | 600.0 | Two bowl-equivalents. |
| `Pseudonymous.WaterPotPorridge` | -300.0 | -50.0 | 250.0 | 1500.0 | Five bowl-equivalents. |
| `Pseudonymous.PorridgePot` | -300.0 | -50.0 | 250.0 | 1500.0 | Five bowl-equivalents. |

Secondary recommendation: record the wheat/rye/barley seed concern as a separate future balance topic, possibly for a farming or milling-focused mod. If that work happens later, investigate whether grain seeds should have lower hunger, explicit calories, or whether flour should require more than 12 seeds. That broader change should not block the porridge fix.

### Ed's Disagreement

Ed disagrees with the recommended porridge calorie values above, while leaving the recommendation text unchanged for comparison.

Reasoning:

- A bowl of Cream of Wheat is approximately 120 calories.
- Because of that real-world comparison, 300 calories for a bowl of porridge seems too high.
- Ed does not currently agree that porridge should copy vanilla oatmeal's 300-calorie value, even if oatmeal is the closest vanilla gameplay template.
- A future implementation cycle should revisit the calorie recommendation before changing item values.

### Agreed Direction After Review

Ed and Codex agree that a bowl of flour porridge should not satisfy more hunger than vanilla oatmeal.

Reasoning chain:

- Vanilla `Base.Oatmeal` has `HungerChange = -10.0` and `Calories = 300.0`.
- Current `Pseudonymous.PorridgeBowl` has `HungerChange = -60.0` and `Calories = 50.0`.
- The `-60` porridge hunger value appears to come from copying/scaling `Base.Flour2`.
- `Base.Flour2` appears to get its `-60` hunger from the flour milling recipe: 12 wheat/rye/barley seeds at `-5` hunger each.
- That seed-to-flour chain is suspicious, because wheat/rye/barley seeds have `HungerChange = -5.0` and no listed calories, while dry corn is only `-4` hunger with 24.8 calories and dry pea is only `-1` hunger with 17.5 calories.
- Therefore, the current porridge value should not be treated as evidence that a porridge bowl is a larger or denser serving. It may simply be downstream from questionable vanilla grain seed/flour values.
- For gameplay, plain flour porridge should not outperform oatmeal on hunger satisfaction.
- For calories, porridge should not copy vanilla oatmeal's 300 calories if the better real-world comparison is a plain wheat porridge or Cream of Wheat style serving around 120 calories.

Agreed candidate values for a future implementation cycle:

| Porridge Item | Current Hunger | Agreed Hunger | Current Calories | Agreed Calories | Reason |
| --- | ---: | ---: | ---: | ---: | --- |
| `Pseudonymous.PorridgeBowl` | -60.0 | -10.0 | 50.0 | 120.0 | Hunger capped at vanilla oatmeal; calories based on a plain wheat porridge / Cream of Wheat style serving. |
| `Pseudonymous.WaterSaucepanPorridge` | -120.0 | -20.0 | 100.0 | 240.0 | Two bowl-equivalents. |
| `Pseudonymous.PorridgePan` | -120.0 | -20.0 | 100.0 | 240.0 | Two bowl-equivalents. |
| `Pseudonymous.WaterPotPorridge` | -300.0 | -50.0 | 250.0 | 600.0 | Five bowl-equivalents. |
| `Pseudonymous.PorridgePot` | -300.0 | -50.0 | 250.0 | 600.0 | Five bowl-equivalents. |

This keeps porridge useful, but prevents it from being more filling than oatmeal while having far fewer calories. It also avoids making broad vanilla overrides to wheat/rye/barley seeds or flour inside this combined food mod.

---

## Tasks

### Phase 1: Code Reference Review

**Status:** Planning

- [ ] Confirm the vanilla `Base.Flour2`, `Base.Cornflour2`, and `Base.Cornmeal2` hunger and calorie values.
- [ ] Confirm the combined mod's active `Base.Cornmeal2` override values.
- [ ] Confirm current porridge item hunger and calorie values.
- [ ] Confirm porridge recipe input quantities.
- [ ] Confirm pease pottage recipe input quantities and current calories/hunger values.
- [ ] Confirm which seeds have `HungerChange = -5.0` and no listed calories.
- [ ] Confirm flour, corn flour, and cornmeal milling/grinding input quantities.

### Phase 2: Balance Analysis

**Status:** Planning

- [ ] Determine whether porridge intentionally mirrors vanilla flour values.
- [ ] Evaluate whether wheat/rye/barley seed hunger is too high relative to corn seed and green pea seed values.
- [ ] Evaluate whether pease pottage should use about 13 dry peas per pot to represent about 230 calories of dry peas.
- [ ] Compare porridge hunger/calorie ratio against oatmeal or other cooked grain foods if useful.
- [ ] Decide whether flour's low calorie value should drive porridge calories, or whether cooked porridge should use independent values.
- [ ] Consider whether flour should require more than 12 wheat/rye/barley seeds.
- [ ] Identify one or more candidate revised hunger/calorie sets if current values feel wrong.
- [ ] Identify one or more candidate revised pease pottage recipe quantities and nutrition values if current values feel low.

### Phase 3: Recommendation

**Status:** Work Complete

- [x] Document the recommended porridge hunger values.
- [x] Document whether calories should change with hunger values.
- [x] Decide whether the recommendation should become a DC 4 implementation cycle.
- [ ] Document the recommended pease pottage recipe quantities and nutrition values.

---

## Notes and Risks

- This DevCycle is investigative only.
- `Cornflour2` has the same vanilla hunger as `Flour2`, but its script block does not set calories explicitly.
- Vanilla `Cornmeal2` differs from the combined mod's `Cornmeal2` override; any comparison must state which version is being used.
- The current porridge values appear to scale directly from `Base.Flour2`: bowl = 1x, pan = 2x, pot = 5x.
- Flour hunger appears to come directly from 12 grain seeds at -5 hunger each, but flour calories do not have an obvious seed-calorie source because those seed blocks omit calories.
- Ed is leaning toward wheat/rye/barley seeds having too high a hunger value and possibly toward flour requiring more than 12 seeds.
- Ed disagrees with the 300-calorie bowl recommendation because a bowl of Cream of Wheat is approximately 120 calories.
- Ed and Codex now agree on candidate porridge values of -10 hunger / 120 calories per bowl, scaling to -20 / 240 for saucepan and -50 / 600 for pot.
- Pease pottage should also be investigated: a cup of dry peas is around 230 calories, which may imply increasing pot input from 8 dry peas to about 13 and saucepan input from 3 to about 5.
- Per the planning process, this cycle should not be marked `Verified` without explicit user approval.

---

## Completion Summary

**Completion Date:** TBD
**Verification Date:** TBD
**Phases Completed:** Phase 3 recommendation drafted; investigation remains open.
**Work Deferred:** TBD.

**Accomplishments:**
- Added recommendation to adjust porridge locally to oatmeal-style hunger/calorie values and defer broad seed/flour rebalance.
- Added agreed candidate values after review: bowl -10 hunger / 120 calories, saucepan -20 / 240, pot -50 / 600.
- Added pease pottage investigation notes for dry pea calorie targets and possible recipe quantity changes.

**Verification:**
- TBD.
