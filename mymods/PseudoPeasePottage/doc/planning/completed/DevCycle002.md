# DevCycle 002: Pease Pottage Happiness Parity

**Status:** Verified
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Fix pease pottage evolved-recipe happiness behavior so adding ingredients improves happiness like vanilla rice/pasta recipes.

---

## Goal

Adjust `PseudoPeasePottage` so `PeasePottagePot` and `PeasePottagePan` do not remain stuck with the scripted `UnhappyChange = 20` penalty when players add normal stew-compatible ingredients.

This cycle will use the vanilla-parity approach: introduce separate water-pottage base items that convert into the final pease pottage result items through evolved recipes, matching the way vanilla rice works.

The target behavior is based on the analysis in:

`doc/ideas/claude_peasePottageHappinessAnalysis.md`

That analysis found that vanilla rice improves quickly because its evolved recipe starts from a separate water-rice base item and produces a result item. During that base-to-result conversion, the game engine resets result item unhappiness and boredom before applying the first ingredient's normal happiness adjustment.

## Desired Outcome

Pease pottage should behave more like vanilla rice and pasta when used as an evolved recipe base:

- Adding the first normal valid ingredient, such as `Base.MincedMeat`, should produce a noticeable happiness improvement instead of leaving the food strongly unhappy.
- Pease pottage should still use stew-compatible ingredient eligibility through `Template = Stew`.
- The mod should continue to provide only pot and pan pease pottage items; no bowl item is added in this cycle.
- Existing recipe quantities remain unchanged:
  - pan uses water and 3 peas or dried peas
  - pot uses water and 8 peas or dried peas

---

## Tasks

### Phase 1: Choose Final Fix Strategy

**Status:** Verified

- [x] Review the two viable implementation strategies from the happiness analysis:
  - quick balance fix: lower/remove `UnhappyChange = 20` on `PeasePottagePot` and `PeasePottagePan`
  - vanilla-parity fix: introduce separate water-pottage base items that convert into final pease pottage result items through evolved recipes
- [x] Confirm whether this cycle should implement the vanilla-parity approach as the preferred fix.
- [x] Decide whether `AddIngredientIfCooked = true` should be added for rice/pasta-style parity.
- [x] Decide whether `CanAddSpicesEmpty = true` should be added for rice/pasta-style spice behavior.

**Technical Notes:**
Decision: implement the vanilla-parity approach. The recipes should match the way vanilla rice works, using distinct water-pottage base items that convert into final pease pottage result items.

Because the target is rice-style parity, both evolved recipes include:

```txt
AddIngredientIfCooked = true,
CanAddSpicesEmpty = true,
```

The distinct base item allows the result item creation path in `EvolvedRecipe.addItem` to reset `UnhappyChange` and `BoredomChange` before the first ingredient is applied.

### Phase 2: Add Intermediate Water-Pottage Items

**Status:** Verified

- [x] Add a pot intermediate item, likely `Pseudonymous.WaterPotPeasePottage`.
- [x] Add a pan intermediate item, likely `Pseudonymous.WaterSaucepanPeasePottage`.
- [x] Base the intermediate items on vanilla water rice/pasta container patterns where possible.
- [x] Ensure the intermediate items return the correct cookware when consumed or emptied.
- [x] Decide whether intermediate items should be player-facing in translations or hidden behind recipe flow names.
- [x] Add English item names if required by game display behavior.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt`.

Added:

- `Pseudonymous.WaterPotPeasePottage`
- `Pseudonymous.WaterSaucepanPeasePottage`

The intermediate items use vanilla rice-style cookware behavior and player-facing names:

- `Cooking Pot with Pease Pottage`
- `Saucepan with Pease Pottage`

They preserve the current pottage nutrition values: pot = 8 pea units, pan = 3 pea units.

### Phase 3: Update Craft Recipes

**Status:** Verified

- [x] Update `MakePeasePottagePan` so it outputs the pan intermediate item instead of `Pseudonymous.PeasePottagePan`.
- [x] Update `MakePeasePottagePot` so it outputs the pot intermediate item instead of `Pseudonymous.PeasePottagePot`.
- [x] Preserve current ingredient counts:
  - `MakePeasePottagePan`: 3 `Base.Greenpeas` or `Base.GreenpeasSeed`
  - `MakePeasePottagePot`: 8 `Base.Greenpeas` or `Base.GreenpeasSeed`
- [x] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [x] Preserve cookware condition inheritance and cookware destruction/replacement behavior.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/recipes/PseudoPeasePottageRecipes.txt`.

Craft recipe outputs now produce the intermediate bases:

```txt
MakePeasePottagePan -> Pseudonymous.WaterSaucepanPeasePottage
MakePeasePottagePot -> Pseudonymous.WaterPotPeasePottage
```

### Phase 4: Update Evolved Recipes

**Status:** Verified

- [x] Change `PeasePottagePan` evolved recipe `BaseItem` to the pan intermediate item.
- [x] Keep `PeasePottagePan` evolved recipe `ResultItem = Pseudonymous.PeasePottagePan`.
- [x] Change `PeasePottagePot` evolved recipe `BaseItem` to the pot intermediate item.
- [x] Keep `PeasePottagePot` evolved recipe `ResultItem = Pseudonymous.PeasePottagePot`.
- [x] Keep `Template = Stew` so ingredient eligibility remains tied to vanilla stew-compatible ingredients.
- [x] Keep `MaxItems = 6` unless testing shows a reason to change it.
- [x] Add `AddIngredientIfCooked = true` to match vanilla rice behavior.
- [x] Add `CanAddSpicesEmpty = true` to match vanilla rice behavior.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/evolvedrecipes/PseudoPeasePottageEvolvedRecipes.txt`.

Current evolved recipe flow:

```txt
Pseudonymous.WaterSaucepanPeasePottage -> Pseudonymous.PeasePottagePan
Pseudonymous.WaterPotPeasePottage -> Pseudonymous.PeasePottagePot
```

Both evolved recipes retain `Template = Stew` and include the rice-style flags.

### Phase 5: Review Nutrition, Hunger, And Unhappiness Values

**Status:** Verified

- [x] Confirm final `PeasePottagePan` nutrition still matches 3 pea units.
- [x] Confirm final `PeasePottagePot` nutrition still matches 8 pea units.
- [x] Decide whether final result items should keep `UnhappyChange = 20`, relying on the base-to-result reset during evolved recipe creation.
- [x] Decide whether intermediate items need their own nutrition values or should carry/copy values into the final result as vanilla rice does.
- [x] Confirm the change does not reintroduce the earlier green-pea per-unit nutrition error.

**Technical Notes:**
The intermediate items and final result items all retain the existing DC1 nutrition values:

```txt
PeasePottagePan / WaterSaucepanPeasePottage = 3 pea units:
HungerChange = -3.0
Calories = 52.5
Carbohydrates = 9.84375
Lipids = 0.0
Proteins = 2.625

PeasePottagePot / WaterPotPeasePottage = 8 pea units:
HungerChange = -8.0
Calories = 140.0
Carbohydrates = 26.25
Lipids = 0.0
Proteins = 7.0
```

Final result items keep `UnhappyChange = 20`, matching the vanilla rice pattern where the result item has scripted unhappiness but the evolved recipe conversion can reset it during runtime.

### Phase 6: Static Checks

**Status:** Verified

- [x] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [x] Confirm recipe outputs reference existing mod item IDs.
- [x] Confirm evolved recipe `BaseItem` and `ResultItem` values reference existing mod item IDs.
- [x] Confirm translation JSON files parse.
- [x] Confirm no `PeasePottageBowl` item, recipe, evolved recipe, or translation was added.
- [x] Confirm `Template = Stew` remains in both evolved recipes.

**Technical Notes:**
Static checks completed with PowerShell and `rg`:

- `Pseudonymous.WaterPotPeasePottage` and `Pseudonymous.WaterSaucepanPeasePottage` are defined in the item script.
- Craft recipe outputs reference the new intermediate item IDs.
- Evolved recipe base/result IDs reference existing mod item IDs.
- EN JSON translation files parse with `ConvertFrom-Json`.
- No `PeasePottageBowl` IDs were added.
- Both evolved recipes still use `Template = Stew`.
- Script brace counts are balanced for the modified script files.

### Phase 7: In-Game Verification

**Status:** Verified

- [ ] Launch Project Zomboid B42 with `PseudoPeasePottage` enabled and confirm no script parse errors.
- [ ] Craft the pan intermediate/final flow from a saucepan, water, and 3 valid peas or dried peas.
- [ ] Craft the pot intermediate/final flow from a cooking pot, water, and 8 valid peas or dried peas.
- [ ] Add ground beef to vanilla pot of rice and record the happiness/unhappiness result.
- [ ] Add ground beef to pease pottage pot and confirm the happiness/unhappiness behavior now matches the intended rice-like behavior.
- [ ] Repeat the ground beef check for pease pottage pan.
- [ ] Confirm stew-compatible ingredient eligibility still works and non-stew ingredients are not newly allowed.

**Technical Notes:**
Verification approved by Ed on 2026-06-29.

---

## Open Questions

1. **Should DC2 implement the full vanilla-parity fix or the simpler balance-only fix?**
   Decision: implement the full vanilla-parity fix with intermediate water-pottage items.

2. **Should pease pottage allow ingredient additions after cooking?**
   Decision: yes. Vanilla rice uses `AddIngredientIfCooked = true`, and this cycle targets rice-style behavior.

3. **Should pease pottage allow spices before other ingredients?**
   Decision: yes. Vanilla rice uses `CanAddSpicesEmpty = true`, and this cycle targets rice-style behavior.

4. **Should final result items keep `UnhappyChange = 20`?**
   Decision: yes for this implementation. The final items keep `UnhappyChange = 20`, relying on the vanilla-style base-to-result conversion path to reset unhappy/boredom during evolved recipe use.

---

## Notes and Risks

- This cycle is intentionally focused on happiness/evolved-recipe behavior. It does not change the DC1 pot/pan-only scope or add a bowl workflow.
- The analysis suggests the major cause is the same-item `BaseItem`/`ResultItem` setup, not ground beef itself.
- The full vanilla-parity approach adds more item states, which increases script and translation surface area.
- If the intermediate items become visible in unexpected inventory contexts, their names, icons, and container behavior may need extra polish.
- In-game verification is important because evolved recipe tooltip behavior can depend on runtime item replacement and ingredient ordering.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** 1-6 implementation/static review phases; Phase 7 prepared for in-game verification
**Work Deferred:** None.

**Accomplishments:**
- Added `Pseudonymous.WaterPotPeasePottage` and `Pseudonymous.WaterSaucepanPeasePottage` intermediate base items.
- Updated craft recipes to output the intermediate water-pottage items.
- Updated evolved recipes to convert intermediate water-pottage items into final pease pottage items.
- Added rice-style `AddIngredientIfCooked = true` and `CanAddSpicesEmpty = true` flags.
- Added English item and evolved recipe name translations for the intermediate items.
- Confirmed static references, translation JSON parsing, preserved nutrition values, and no bowl workflow additions.

**Metrics:**
- Files modified: 6 (`PseudoPeasePottageItems.txt`, `PseudoPeasePottageRecipes.txt`, `PseudoPeasePottageEvolvedRecipes.txt`, `ItemName.json`, `EvolvedRecipeName.json`, `DevCycle002.md`)
- In-game checks completed: confirmed by Ed on 2026-06-29

**Lessons / Notes:**
- The rice-style base/result split is now represented directly in the mod scripts, so runtime testing should focus on whether the engine clears unhappy/boredom as expected when the first ingredient converts the water-pottage base into the final pease pottage item.


