# DevCycle 001: Crafted Pease Pottage Pot and Pan

**Status:** Work Complete
**Start Date:** 2026-06-29
**Target Completion:** TBD
**Focus:** Add pot and saucepan pease pottage recipes modeled on `PseudoPorridge` and `PseudoGrits`, without adding a bowl recipe.

---

## Goal

Create the first gameplay slice for `PseudoPeasePottage`: players can prepare pease pottage in a cooking pot or saucepan using cookware, water, and peas or dried peas.

This cycle follows the established `PseudoPorridge` and `PseudoGrits` recipe structure, but with pease pottage-specific item IDs and recipe costs:

- `PeasePottagePot` uses water and 8 peas or dried peas.
- `PeasePottagePan` uses water and 3 peas or dried peas.
- No bowl item or bowl recipe is added in this cycle.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can craft:

- `Pseudonymous.PeasePottagePot` from a cooking pot, water, and 8 valid pea/dried pea ingredients.
- `Pseudonymous.PeasePottagePan` from a saucepan, water, and 3 valid pea/dried pea ingredients.

Player-facing evolved recipe names:

- `Pease Pottage (crafted pot)`
- `Pease Pottage (crafted pan)`

Both evolved recipes should allow only the same additional ingredients that players can add to vanilla stew.

---

## Tasks

### Phase 1: Confirm Vanilla Pea Ingredients

**Status:** Work Complete

- [x] Review vanilla fresh pea and dried pea item definitions before implementation:
  - `media/scripts/generated/items/food.txt:1984` defines `Base.GreenpeasSeed`, using the dried peas icon/model and `Tags = base:driedfood;base:isseed`.
  - `media/scripts/generated/items/food.txt:14387` defines `Base.Greenpeas`, a fresh garden pea item.
  - `media/scripts/generated/items/food.txt:14536` defines `Base.Peas`, a packaged pea item.
  - `media/scripts/generated/items/food.txt:4874` defines `Base.DriedSplitPeas`, which is a related but distinct split pea ingredient.
- [x] Decide the exact recipe input set for "peas or dried peas."
- [x] Decide whether item nutrition should be based on one ingredient type, separate recipes per ingredient type, or conservative handcrafted values.

**Technical Notes:**
Implemented recipe inputs use `Base.Greenpeas` for fresh peas and `Base.GreenpeasSeed` for dried peas. `Base.Peas` is not included because EN translations identify it as `Packaged Peas`; `Base.DriedSplitPeas` is not included because it is a distinct split-pea item.

Pease pottage item nutrition uses `Base.Greenpeas` as the stable baseline because both recipe alternatives produce the same output item. `Base.Greenpeas` has `EvolvedRecipe = ...;Stew:4` and `HungerChange = -4.0`, so its nutrition block represents 4 stew-addable pea units. The pan recipe uses 3 pea units, and the pot recipe uses 8 pea units:

```txt
Base.Greenpeas per item, representing 4 pea units:
HungerChange = -4.0
Calories = 70.0
Carbohydrates = 13.125
Lipids = 0.0
Proteins = 3.5

Per pea unit, derived from Base.Greenpeas / 4:
HungerChange = -1.0
Calories = 17.5
Carbohydrates = 3.28125
Lipids = 0.0
Proteins = 0.875
```

Target output nutrition:

```txt
PeasePottagePan = 3 pea units:
HungerChange = -3.0
Calories = 52.5
Carbohydrates = 9.84375
Lipids = 0.0
Proteins = 2.625

PeasePottagePot = 8 pea units:
HungerChange = -8.0
Calories = 140.0
Carbohydrates = 26.25
Lipids = 0.0
Proteins = 7.0
```

### Phase 2: Add Pease Pottage Base Items

**Status:** Work Complete

- [x] Create mod-owned food items under `module Pseudonymous`.
- [x] Add `Pseudonymous.PeasePottagePot`.
- [x] Add `Pseudonymous.PeasePottagePan`.
- [x] Base cookware/container behavior on the existing `PseudoPorridge` and `PseudoGrits` pot/pan items.
- [x] Ensure pot and pan items return their cookware with `ReplaceOnUse`.
- [x] Add English item names for both new items.
- [x] Do not add `PeasePottageBowl`.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt`.

The new items reuse the pot/pan visual and container behavior pattern from `PseudoPorridge` and `PseudoGrits`: `PotFull`/`CookingPotRice_Ground` for the pot and `SaucepanFilled`/`WaterSaucepanRice` for the pan. Both are cookable, return their cookware with `ReplaceOnUse`, and use `EvolvedRecipeName = Pease Pottage`.

### Phase 3: Add Craft Recipes for Pease Pottage Bases

**Status:** Work Complete

- [x] Add `MakePeasePottagePan`.
- [x] Add `MakePeasePottagePot`.
- [x] Mirror the established B42 recipe structure:
  - cookware input destroyed with condition inheritance
  - water input as a fluid mixture
  - pea/dried pea inputs consumed
- [x] Use the established pan water amount from `PseudoPorridge` and `PseudoGrits`: `0.6` water.
- [x] Use the established pot water amount from `PseudoPorridge` and `PseudoGrits`: `1.5` water.
- [x] Require 3 peas or dried peas for `MakePeasePottagePan`.
- [x] Require 8 peas or dried peas for `MakePeasePottagePot`.
- [x] Add English recipe names for both setup recipes.
- [x] Do not add a bowl craft recipe.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/recipes/PseudoPeasePottageRecipes.txt`.

Implemented recipes:

```txt
craftRecipe MakePeasePottagePan
{
    inputs
    {
        item 1 [Base.Saucepan] flags[InheritCondition;ItemCount] mode:destroy,
        -fluid 0.6 categories[Water] mode:mixture,
        item 3 [Base.Greenpeas;Base.GreenpeasSeed],
    }
    outputs
    {
        item 1 Pseudonymous.PeasePottagePan,
    }
}

craftRecipe MakePeasePottagePot
{
    inputs
    {
        item 1 [Base.Pot] mode:destroy flags[InheritCondition;ItemCount],
        -fluid 1.5 categories[Water] mode:mixture,
        item 8 [Base.Greenpeas;Base.GreenpeasSeed],
    }
    outputs
    {
        item 1 Pseudonymous.PeasePottagePot,
    }
}
```

### Phase 4: Add Pease Pottage Evolved Recipes

**Status:** Work Complete

- [x] Add `Pease Pottage (crafted pot)` as an evolved recipe using `Pseudonymous.PeasePottagePot`.
- [x] Add `Pease Pottage (crafted pan)` as an evolved recipe using `Pseudonymous.PeasePottagePan`.
- [x] Use stew-compatible evolved recipe behavior so players can add only ingredients that are valid for vanilla stew.
- [x] Use `Template = Stew` if code review confirms B42 template matching provides the same ingredient inheritance used by `PseudoPorridge`/`PseudoGrits`.
- [x] Use vanilla stew's `MaxItems = 6` unless implementation review shows a pease pottage-specific cap is needed.
- [x] Add English context menu/evolved recipe translations.
- [x] Do not add a bowl evolved recipe.

**Technical Notes:**
Implemented in `PseudoPeasePottage/42/media/scripts/evolvedrecipes/PseudoPeasePottageEvolvedRecipes.txt`.

Both evolved recipes use `Template = Stew`, `MaxItems = 6`, and `Cookable = true`, with `BaseItem` and `ResultItem` pointed at the corresponding mod-owned pease pottage item. This mirrors the B42 template-inheritance approach used by `PseudoPorridge`/`PseudoGrits`, while targeting the vanilla stew ingredient set instead of oatmeal.

### Phase 5: Static Review and In-Game Verification

**Status:** Work Complete - requires in-game verification

- [x] Confirm all new script files are under `PseudoPeasePottage/42/media/scripts/`.
- [x] Confirm translation files are under `PseudoPeasePottage/42/media/lua/shared/Translate/EN/`.
- [x] Confirm no bowl item, bowl recipe, or bowl evolved recipe was added.
- [x] Confirm all referenced vanilla item IDs exist.
- [x] Confirm JSON translation files parse.
- [ ] Launch B42 with `PseudoPeasePottage` enabled and confirm there are no script parse errors.
- [ ] Craft `PeasePottagePan` from a saucepan, water, and 3 valid pea/dried pea ingredients.
- [ ] Craft `PeasePottagePot` from a cooking pot, water, and 8 valid pea/dried pea ingredients.
- [ ] Confirm evolved recipe ingredient behavior matches vanilla stew ingredient eligibility.
- [ ] Confirm adding ingredients preserves the intended pease pottage item and display name behavior.

**Technical Notes:**
Static checks completed with PowerShell and `rg`:

- New script and translation files exist under the expected `PseudoPeasePottage/42/media/` paths.
- `Base.Greenpeas`, `Base.GreenpeasSeed`, `Base.Pot`, and `Base.Saucepan` resolve in vanilla generated item scripts.
- EN JSON files parse with `ConvertFrom-Json`.
- No `PeasePottageBowl` item, recipe, or evolved recipe exists.

In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Which vanilla items should count as "peas or dried peas"?**
   Decision: use `Base.Greenpeas` and `Base.GreenpeasSeed`. Do not include `Base.Peas` or `Base.DriedSplitPeas` in this cycle.

2. **Should pease pottage use soup or stew evolved recipe behavior?**
   Decision: use stew behavior. Players should only be able to add ingredients that are valid for vanilla stew.

3. **Should forged pots or copper saucepans be supported?**
   Decision: defer, matching the initial `PseudoPorridge`/`PseudoGrits` pot and pan scope.

4. **Should pease pottage have a bowl version?**
   Decision: no. This cycle explicitly includes only `PeasePottagePot` and `PeasePottagePan`.

---

## Notes and Risks

- Implementation was requested explicitly after this DevCycle document was created, satisfying the `mymods/PseudoPeasePottage/AGENTS.md` planning stop rule.
- The recipe quantities are intentionally asymmetric and user-specified: pot = 8 ingredients, pan = 3 ingredients.
- Water amounts match the already working `PseudoPorridge`/`PseudoGrits` pan and pot recipes.
- The biggest remaining gameplay risk is whether `Base.GreenpeasSeed` is the desired dried pea item despite its gardening/seed identity and `CantEat = true` behavior. It is included because EN translations identify it as `Green Peas (Dried)`. Its per-item nutrition is very close to the per-unit nutrition derived from `Base.Greenpeas`, except `Carbohydrates = 3.25` versus `3.28125`, so outputs use the fresh green pea per-unit baseline for consistency.
- No in-game verification has been performed by the agent.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** 1-4 implementation phases; static checks in Phase 5
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Added `Pseudonymous.PeasePottagePot` and `Pseudonymous.PeasePottagePan` food items.
- Added `MakePeasePottagePot` and `MakePeasePottagePan` craft recipes using cookware, water, and `Base.Greenpeas` or `Base.GreenpeasSeed`.
- Added `PeasePottagePot` and `PeasePottagePan` evolved recipes with `Template = Stew`.
- Added English item, recipe, evolved recipe, and context menu translations.
- Confirmed no bowl item, recipe, or evolved recipe was added.

**Metrics:**
- Files modified: 8 (`PseudoPeasePottageItems.txt`, `PseudoPeasePottageRecipes.txt`, `PseudoPeasePottageEvolvedRecipes.txt`, `ItemName.json`, `Recipes.json`, `ContextMenu.json`, `EvolvedRecipeName.json`, `DevCycle001.md`)
- In-game checks completed: 0

**Lessons / Notes:**
- Pease pottage now follows the same pot/pan structure as `PseudoPorridge` and `PseudoGrits`, but uses stew-compatible evolved recipe ingredients instead of oatmeal-compatible toppings.