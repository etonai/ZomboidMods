# DevCycle 002: Pease Pottage Happiness Parity

**Status:** Planning
**Start Date:** 2026-06-29
**Target Completion:** TBD
**Focus:** Fix pease pottage evolved-recipe happiness behavior so adding ingredients improves happiness like vanilla rice/pasta recipes.

---

## Goal

Adjust `PseudoPeasePottage` so `PeasePottagePot` and `PeasePottagePan` do not remain stuck with the scripted `UnhappyChange = 20` penalty when players add normal stew-compatible ingredients.

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

**Status:** Planning

- [ ] Review the two viable implementation strategies from the happiness analysis:
  - quick balance fix: lower/remove `UnhappyChange = 20` on `PeasePottagePot` and `PeasePottagePan`
  - vanilla-parity fix: introduce separate water-pottage base items that convert into final pease pottage result items through evolved recipes
- [ ] Confirm whether this cycle should implement the vanilla-parity approach as the preferred fix.
- [ ] Decide whether `AddIngredientIfCooked = true` should be added for rice/pasta-style parity.
- [ ] Decide whether `CanAddSpicesEmpty = true` should be added for rice/pasta-style spice behavior.

**Technical Notes:**
The recommended implementation is the vanilla-parity approach because it matches the engine behavior identified in `EvolvedRecipe.addItem`: a distinct base item allows the result item creation path to reset `UnhappyChange` and `BoredomChange` before the first ingredient is applied.

### Phase 2: Add Intermediate Water-Pottage Items

**Status:** Planning

- [ ] Add a pot intermediate item, likely `Pseudonymous.WaterPotPeasePottage`.
- [ ] Add a pan intermediate item, likely `Pseudonymous.WaterSaucepanPeasePottage`.
- [ ] Base the intermediate items on vanilla water rice/pasta container patterns where possible.
- [ ] Ensure the intermediate items return the correct cookware when consumed or emptied.
- [ ] Decide whether intermediate items should be player-facing in translations or hidden behind recipe flow names.
- [ ] Add English item names if required by game display behavior.

**Technical Notes:**
The intermediate items should represent the prepared water/pea mixture before evolved ingredients are added. They are not bowl items and should not add any bowl workflow.

### Phase 3: Update Craft Recipes

**Status:** Planning

- [ ] Update `MakePeasePottagePan` so it outputs the pan intermediate item instead of `Pseudonymous.PeasePottagePan`.
- [ ] Update `MakePeasePottagePot` so it outputs the pot intermediate item instead of `Pseudonymous.PeasePottagePot`.
- [ ] Preserve current ingredient counts:
  - `MakePeasePottagePan`: 3 `Base.Greenpeas` or `Base.GreenpeasSeed`
  - `MakePeasePottagePot`: 8 `Base.Greenpeas` or `Base.GreenpeasSeed`
- [ ] Preserve current water amounts:
  - pan: `0.6` water
  - pot: `1.5` water
- [ ] Preserve cookware condition inheritance and cookware destruction/replacement behavior.

### Phase 4: Update Evolved Recipes

**Status:** Planning

- [ ] Change `PeasePottagePan` evolved recipe `BaseItem` to the pan intermediate item.
- [ ] Keep `PeasePottagePan` evolved recipe `ResultItem = Pseudonymous.PeasePottagePan`.
- [ ] Change `PeasePottagePot` evolved recipe `BaseItem` to the pot intermediate item.
- [ ] Keep `PeasePottagePot` evolved recipe `ResultItem = Pseudonymous.PeasePottagePot`.
- [ ] Keep `Template = Stew` so ingredient eligibility remains tied to vanilla stew-compatible ingredients.
- [ ] Keep `MaxItems = 6` unless testing shows a reason to change it.
- [ ] Consider adding `AddIngredientIfCooked = true` if rice/pasta-style cooked additions are desired.
- [ ] Consider adding `CanAddSpicesEmpty = true` if empty-base spices should match rice/pasta behavior.

**Technical Notes:**
The main fix is the base/result split. The additional rice flags are useful parity candidates, but they are not the direct cause of the ground-beef happiness difference.

### Phase 5: Review Nutrition, Hunger, And Unhappiness Values

**Status:** Planning

- [ ] Confirm final `PeasePottagePan` nutrition still matches 3 pea units.
- [ ] Confirm final `PeasePottagePot` nutrition still matches 8 pea units.
- [ ] Decide whether final result items should keep `UnhappyChange = 20`, relying on the base-to-result reset during evolved recipe creation.
- [ ] Decide whether intermediate items need their own nutrition values or should carry/copy values into the final result as vanilla rice does.
- [ ] Confirm the change does not reintroduce the earlier green-pea per-unit nutrition error.

**Technical Notes:**
If the vanilla-parity path is used, keeping `UnhappyChange = 20` on final result items may be acceptable because the engine reset should clear it during evolved-recipe result creation. Static review should still verify this against the exact item flow.

### Phase 6: Static Checks

**Status:** Planning

- [ ] Confirm all new item IDs resolve inside `module Pseudonymous`.
- [ ] Confirm recipe outputs reference existing mod item IDs.
- [ ] Confirm evolved recipe `BaseItem` and `ResultItem` values reference existing mod item IDs.
- [ ] Confirm translation JSON files parse.
- [ ] Confirm no `PeasePottageBowl` item, recipe, evolved recipe, or translation was added.
- [ ] Confirm `Template = Stew` remains in both evolved recipes.

### Phase 7: In-Game Verification

**Status:** Planning

- [ ] Launch Project Zomboid B42 with `PseudoPeasePottage` enabled and confirm no script parse errors.
- [ ] Craft the pan intermediate/final flow from a saucepan, water, and 3 valid peas or dried peas.
- [ ] Craft the pot intermediate/final flow from a cooking pot, water, and 8 valid peas or dried peas.
- [ ] Add ground beef to vanilla pot of rice and record the happiness/unhappiness result.
- [ ] Add ground beef to pease pottage pot and confirm the happiness/unhappiness behavior now matches the intended rice-like behavior.
- [ ] Repeat the ground beef check for pease pottage pan.
- [ ] Confirm stew-compatible ingredient eligibility still works and non-stew ingredients are not newly allowed.

---

## Open Questions

1. **Should DC2 implement the full vanilla-parity fix or the simpler balance-only fix?**
   Current recommendation: full vanilla-parity fix with intermediate water-pottage items.

2. **Should pease pottage allow ingredient additions after cooking?**
   Vanilla rice uses `AddIngredientIfCooked = true`. This is probably desirable if the goal is rice/pasta parity, but it should be confirmed before implementation.

3. **Should pease pottage allow spices before other ingredients?**
   Vanilla rice uses `CanAddSpicesEmpty = true`. This may be desirable for parity, but it slightly broadens behavior beyond the current stew-template implementation.

4. **Should final result items keep `UnhappyChange = 20`?**
   If the intermediate item approach works as expected, the engine should clear the final result's unhappiness during evolved recipe conversion. Keeping the value may be acceptable for vanilla parity, but testing should confirm the actual behavior.

---

## Notes and Risks

- This cycle is intentionally focused on happiness/evolved-recipe behavior. It should not change the DC1 pot/pan-only scope or add a bowl workflow.
- The analysis suggests the major cause is the same-item `BaseItem`/`ResultItem` setup, not ground beef itself.
- The full vanilla-parity approach adds more item states, which increases script and translation surface area.
- If the intermediate items become visible in unexpected inventory contexts, their names, icons, and container behavior need extra polish.
- In-game verification is important because evolved recipe tooltip behavior can depend on runtime item replacement and ingredient ordering.

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
