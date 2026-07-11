# DevCycle001 - Build PseudoSalad Auto Salad

Created: 2026-07-10
Status: In Progress

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

- [x] Create the PseudoSalad Lua module structure under the mod's `42/media/lua` tree for the 42.19+ scope.
- [x] Add context-menu integration for `Base.Bowl` and, if straightforward, `Base.ClayBowl`.
- [x] Locate the correct vanilla evolved recipe for `Base.Salad` or `Base.SaladClay`.
- [x] Gather candidate ingredients with `recipe:getItemsCanBeUse(player, baseItem, containerList)`.
- [x] Implement ingredient filtering:
  - nonrotten only,
  - no spices or extras,
  - egg bucket by `FoodType = Egg`,
  - protein bucket limited to cooked `Base.Smallbirdmeat` or cooked `Base.FishFillet`,
  - vegetable bucket by `FoodType = Vegetables` or `FoodType = Greens`.
- [x] Implement least-fresh nonrotten selection using age, off-age, and off-age-max comparisons from the AutoCook analysis.
- [x] Build the preferred six-step add plan: egg, egg, protein, protein, vegetable, vegetable.
- [x] Implement fallback filling when priority ingredients are unavailable, using the best available valid nonrotten, non-spice salad ingredients until the salad reaches six additions or no valid ingredients remain.
- [x] Queue inventory transfers and `ISAddItemInRecipe` actions, refreshing available items before each add.
- [x] Add a continuation action or equivalent queue flow so all six additions run in order.
- [x] Stop cleanly only when the salad is full or no valid fallback ingredients remain.
- [x] Verify in-game or through the closest available local validation that the mod loads and the action appears only when appropriate.
- [x] Document any implementation decisions that differ from `codex_autoCookPseudoSaladAnalysis.md`.

## Notes and Risks

- Version scope is Project Zomboid 42.19 and later only. AutoCook 42.13-specific code should be ignored unless it is needed to understand or support 42.19+ behavior.
- Raw eggs, fish fillets, and small bird meat are not valid salad ingredients unless cooked. Auto-cooking raw ingredients is out of scope for this first cycle unless explicitly added later.
- The current plan treats `FoodType = Greens` as vegetables so lettuce and kale can be selected.
- Priority ingredients are best-effort, not hard requirements. If eggs, cooked fish fillets, cooked small bird meat, or vegetables/greens are unavailable, the mod should continue filling with other valid nonrotten, non-spice salad ingredients.
- Do not mark this DevCycle `Verified` without explicit user approval.

## Phase 2 - Refine Ingredient Selection

Status: Planning

### Goal

Refine the PseudoSalad ingredient planner so each priority tier chooses the oldest valid ingredient while respecting a maximum of two additions per ingredient type.

### Rules

- At each tier of ingredient selection, choose the oldest valid ingredient available for that tier.
- "Oldest" means closest to spoilage among nonrotten ingredients, using the existing freshness/rot-time comparison.
- Do not add more than two pieces of the same ingredient type unless there are no other valid ingredients available to continue filling the salad.
- The two-piece limit applies across priority selections and fallback selections.
- If the preferred tier is unavailable, fallback selection should still choose the oldest valid nonrotten, non-spice ingredient that has been used fewer than two times.
- Only exceed the two-piece limit when every otherwise valid candidate has already been used twice and the salad still has open ingredient slots.

### Tasks

- [ ] Track per-full-type ingredient usage during the auto-salad plan.
- [ ] Update preferred tier selection to choose the oldest valid item whose type has been used fewer than two times.
- [ ] Update fallback selection to choose the oldest valid item whose type has been used fewer than two times.
- [ ] Add final fallback behavior that allows a third or later use of an ingredient type only when no under-limit valid candidates remain.
- [ ] Re-check the add loop after each ingredient because vanilla may partially consume or remove the source item.
- [ ] Update implementation notes and completion summary after Phase 2 work is done.

## Completion Summary

Implemented PseudoSalad.lua under the 42.19+ mod tree with context-menu integration for bowls/clay bowls, vanilla evolved-recipe lookup, priority ingredient buckets, fallback filling, inventory transfers, and a continuation action. Added English context-menu translations. Local validation completed with JSON parsing and code review against 42.19 ISAddItemInRecipe; no in-game verification was run in this environment.

Implementation decision: despite the original task wording mentioning common/media/lua, the Lua implementation was placed under 42/media/lua because this mod is explicitly scoped to Project Zomboid 42.19 and later.
