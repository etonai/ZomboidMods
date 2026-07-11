# DevCycle001 - Build PseudoSalad Auto Salad

Created: 2026-07-10
Status: Planning

## Goal

Build the first working PseudoSalad implementation for Project Zomboid 42.19+ based on `doc/ideas/codex_autoCookPseudoSaladAnalysis.md`.

The mod should automatically create a basic salad from a bowl using a priority-first six-add plan:

1. one egg ingredient type, added twice,
2. one additional protein type, either cooked small bird meat or cooked fish fillet, added twice,
3. one vegetable or green ingredient type, selected as the least fresh nonrotten candidate, added twice.

If one or more priority ingredient buckets are unavailable, the mod should still fill the salad with the best available valid nonrotten, non-spice salad ingredients rather than failing the whole action.

The mod must not automatically add extras or spices such as salt, mayonnaise, herbs, seeds, pickles, or other `item:isSpice()` ingredients.

## Desired Outcome

The player can use a PseudoSalad context-menu action on a valid bowl or clay bowl to queue vanilla evolved-recipe add actions that produce a salad matching the planned ingredient rules.

The implementation should rely on vanilla evolved-recipe validation where practical, especially `RecipeManager.getEvolvedRecipe(...)`, `recipe:getItemsCanBeUse(...)`, and `ISAddItemInRecipe`.

## Tasks

- [ ] Create the PseudoSalad Lua module structure under the mod's `common/media/lua` tree.
- [ ] Add context-menu integration for `Base.Bowl` and, if straightforward, `Base.ClayBowl`.
- [ ] Locate the correct vanilla evolved recipe for `Base.Salad` or `Base.SaladClay`.
- [ ] Gather candidate ingredients with `recipe:getItemsCanBeUse(player, baseItem, containerList)`.
- [ ] Implement ingredient filtering:
  - nonrotten only,
  - no spices or extras,
  - egg bucket by `FoodType = Egg`,
  - protein bucket limited to cooked `Base.Smallbirdmeat` or cooked `Base.FishFillet`,
  - vegetable bucket by `FoodType = Vegetables` or `FoodType = Greens`.
- [ ] Implement least-fresh nonrotten selection using age, off-age, and off-age-max comparisons from the AutoCook analysis.
- [ ] Build the preferred six-step add plan: egg, egg, protein, protein, vegetable, vegetable.
- [ ] Implement fallback filling when priority ingredients are unavailable, using the best available valid nonrotten, non-spice salad ingredients until the salad reaches six additions or no valid ingredients remain.
- [ ] Queue inventory transfers and `ISAddItemInRecipe` actions, refreshing available items before each add.
- [ ] Add a continuation action or equivalent queue flow so all six additions run in order.
- [ ] Stop cleanly only when the salad is full or no valid fallback ingredients remain.
- [ ] Verify in-game or through the closest available local validation that the mod loads and the action appears only when appropriate.
- [ ] Document any implementation decisions that differ from `codex_autoCookPseudoSaladAnalysis.md`.

## Notes and Risks

- Version scope is Project Zomboid 42.19 and later only. AutoCook 42.13-specific code should be ignored unless it is needed to understand or support 42.19+ behavior.
- Raw eggs, fish fillets, and small bird meat are not valid salad ingredients unless cooked. Auto-cooking raw ingredients is out of scope for this first cycle unless explicitly added later.
- The current plan treats `FoodType = Greens` as vegetables so lettuce and kale can be selected.
- Priority ingredients are best-effort, not hard requirements. If eggs, cooked fish fillets, cooked small bird meat, or vegetables/greens are unavailable, the mod should continue filling with other valid nonrotten, non-spice salad ingredients.
- Do not mark this DevCycle `Verified` without explicit user approval.

## Completion Summary

Not started.
