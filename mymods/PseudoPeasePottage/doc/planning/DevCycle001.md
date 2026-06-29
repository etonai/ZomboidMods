# DevCycle 001: Crafted Pease Pottage Pot and Pan

**Status:** Planning
**Start Date:** 2026-06-29
**Target Completion:** TBD
**Focus:** Add pot and saucepan pease pottage recipes modeled on `PseudoPorridge` and `PseudoGrits`, without adding a bowl recipe.

---

## Goal

Create the first gameplay slice for `PseudoPeasePottage`: players can prepare pease pottage in a cooking pot or saucepan using cookware, water, and peas or dried peas.

This cycle should follow the established `PseudoPorridge` and `PseudoGrits` recipe structure, but with pease pottage-specific item IDs and recipe costs:

- `PeasePottagePot` uses water and 5 peas or dried peas.
- `PeasePottagePan` uses water and 2 peas or dried peas.
- No bowl item or bowl recipe should be added in this cycle.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can craft:

- `Pseudonymous.PeasePottagePot` from a cooking pot, water, and 5 valid pea/dried pea ingredients.
- `Pseudonymous.PeasePottagePan` from a saucepan, water, and 2 valid pea/dried pea ingredients.

Player-facing evolved recipe names:

- `Pease Pottage (crafted pot)`
- `Pease Pottage (crafted pan)`

Both evolved recipes should allow only the same additional ingredients that players can add to vanilla stew.

---

## Tasks

### Phase 1: Confirm Vanilla Pea Ingredients

**Status:** Planning

- [ ] Review vanilla fresh pea and dried pea item definitions before implementation:
  - `media/scripts/generated/items/food.txt:1984` defines `Base.GreenpeasSeed`, using the dried peas icon/model and `Tags = base:driedfood;base:isseed`.
  - `media/scripts/generated/items/food.txt:14387` defines `Base.Greenpeas`, a fresh garden pea item.
  - `media/scripts/generated/items/food.txt:14536` defines `Base.Peas`, a packaged/fresh pea item.
  - `media/scripts/generated/items/food.txt:4874` defines `Base.DriedSplitPeas`, which may be a related but distinct ingredient.
- [ ] Decide the exact recipe input set for "peas or dried peas."
- [ ] Decide whether item nutrition should be based on one ingredient type, separate recipes per ingredient type, or conservative handcrafted values.

**Technical Notes:**
The wording "peas or dried peas" likely maps to `Base.Peas` plus a dried pea item, but B42 also has `Base.Greenpeas` and `Base.GreenpeasSeed`. Implementation should not accidentally make the recipe consume seed packets or split peas unless that is intentional.

### Phase 2: Add Pease Pottage Base Items

**Status:** Planning

- [ ] Create mod-owned food items under `module Pseudonymous`.
- [ ] Add `Pseudonymous.PeasePottagePot`.
- [ ] Add `Pseudonymous.PeasePottagePan`.
- [ ] Base cookware/container behavior on the existing `PseudoPorridge` and `PseudoGrits` pot/pan items.
- [ ] Ensure pot and pan items return their cookware with `ReplaceOnUse`.
- [ ] Add English item names for both new items.
- [ ] Do not add `PeasePottageBowl`.

### Phase 3: Add Craft Recipes for Pease Pottage Bases

**Status:** Planning

- [ ] Add `MakePeasePottagePan`.
- [ ] Add `MakePeasePottagePot`.
- [ ] Mirror the established B42 recipe structure:
  - cookware input destroyed with condition inheritance
  - water input as a fluid mixture
  - pea/dried pea inputs consumed
- [ ] Use the established pan water amount from `PseudoPorridge` and `PseudoGrits`: `0.6` water.
- [ ] Use the established pot water amount from `PseudoPorridge` and `PseudoGrits`: `1.5` water.
- [ ] Require 2 peas or dried peas for `MakePeasePottagePan`.
- [ ] Require 5 peas or dried peas for `MakePeasePottagePot`.
- [ ] Add English recipe names for both setup recipes.
- [ ] Do not add a bowl craft recipe.

**Proposed Recipe Shape:**

```txt
craftRecipe MakePeasePottagePan
{
    timedAction = MixingBowl,
    time = 50,
    Tags = AnySurfaceCraft;Cooking,
    category = Cooking,
    xpAward = Cooking:3,
    inputs
    {
        item 1 [Base.Saucepan] flags[InheritCondition;ItemCount] mode:destroy,
        -fluid 0.6 categories[Water] mode:mixture,
        item 2 [Base.Peas;Base.GreenpeasSeed],
    }
    outputs
    {
        item 1 Pseudonymous.PeasePottagePan,
    }
}

craftRecipe MakePeasePottagePot
{
    timedAction = MixingBowl,
    time = 50,
    Tags = AnySurfaceCraft;Cooking,
    category = Cooking,
    xpAward = Cooking:3,
    inputs
    {
        item 1 [Base.Pot] mode:destroy flags[InheritCondition;ItemCount],
        -fluid 1.5 categories[Water] mode:mixture,
        item 5 [Base.Peas;Base.GreenpeasSeed],
    }
    outputs
    {
        item 1 Pseudonymous.PeasePottagePot,
    }
}
```

The bracketed ingredient list is a starting point, not a final decision, until Phase 1 confirms the intended pea IDs.

### Phase 4: Add Pease Pottage Evolved Recipes

**Status:** Planning

- [ ] Add `Pease Pottage (crafted pot)` as an evolved recipe using `Pseudonymous.PeasePottagePot`.
- [ ] Add `Pease Pottage (crafted pan)` as an evolved recipe using `Pseudonymous.PeasePottagePan`.
- [ ] Use stew-compatible evolved recipe behavior so players can add only ingredients that are valid for vanilla stew.
- [ ] Use `Template = Stew` if code review confirms B42 template matching provides the same ingredient inheritance used by `PseudoPorridge`/`PseudoGrits`.
- [ ] Use vanilla stew's `MaxItems = 6` unless implementation review shows a pease pottage-specific cap is needed.
- [ ] Add English context menu/evolved recipe translations.
- [ ] Do not add a bowl evolved recipe.

**Technical Notes:**
`PseudoPorridge` and `PseudoGrits` use `Template = Oatmeal` for breakfast-style toppings. Pease pottage should instead use the vanilla stew ingredient set. Vanilla stew is defined in `media/scripts/generated/evolvedrecipes.txt` with `Template = Stew`, `MaxItems = 6`, `Cookable = true`, and `MinimumWater = 0.9`; the pease pottage evolved recipes should copy the ingredient-eligibility behavior while using the mod-owned pot/pan base items.

### Phase 5: Static Review and In-Game Verification

**Status:** Planning

- [ ] Confirm all new script files are under `PseudoPeasePottage/42/media/scripts/`.
- [ ] Confirm translation files are under `PseudoPeasePottage/42/media/lua/shared/Translate/EN/`.
- [ ] Confirm no bowl item, bowl recipe, or bowl evolved recipe was added.
- [ ] Confirm all referenced vanilla item IDs exist.
- [ ] Confirm JSON translation files parse.
- [ ] Launch B42 with `PseudoPeasePottage` enabled and confirm there are no script parse errors.
- [ ] Craft `PeasePottagePan` from a saucepan, water, and 2 valid pea/dried pea ingredients.
- [ ] Craft `PeasePottagePot` from a cooking pot, water, and 5 valid pea/dried pea ingredients.
- [ ] Confirm evolved recipe ingredient behavior matches vanilla stew ingredient eligibility.
- [ ] Confirm adding ingredients preserves the intended pease pottage item and display name behavior.

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status.

---

## Open Questions

1. **Which vanilla items should count as "peas or dried peas"?**
   Proposed implementation target: `Base.Peas` and `Base.GreenpeasSeed`, with `Base.Greenpeas` considered if fresh garden peas should also count. `Base.DriedSplitPeas` should only be included if split peas are intended.

2. **Should pease pottage use soup or stew evolved recipe behavior?**
   Decision: use stew behavior. Players should only be able to add ingredients that are valid for vanilla stew.

3. **Should forged pots or copper saucepans be supported?**
   Proposed decision: defer, matching the initial `PseudoPorridge`/`PseudoGrits` pot and pan scope.

4. **Should pease pottage have a bowl version?**
   Decision: no. This cycle explicitly includes only `PeasePottagePot` and `PeasePottagePan`.

---

## Notes and Risks

- Per `mymods/PseudoPeasePottage/AGENTS.md`, agents should stop after creating this DevCycle document and wait for an explicit implementation request.
- The largest planning risk is ingredient identity. B42 has multiple pea-related items with very different weights and nutrition values.
- The recipe quantities are intentionally asymmetric and user-specified: pot = 5 ingredients, pan = 2 ingredients.
- Water amounts are proposed to match the already working `PseudoPorridge`/`PseudoGrits` pan and pot recipes unless Ed asks for different liquid costs.
- No implementation work has been performed in this cycle yet.

---

## Completion Summary

**Completion Date:** TBD
**Phases Completed:** None
**Work Deferred:** TBD

**Accomplishments:**
- TBD

**Metrics:**
- Files modified: TBD
- In-game checks completed: TBD

**Lessons / Notes:**
- TBD
