# DevCycle002 - Rename Menu and Refine Spoilage Selection

Created: 2026-07-11
Status: Work Complete

## Goal

Update PseudoSalad with two focused behavior changes:

1. Change the context-menu label from `Make PseudoSalad` to `Create Ed's Salad`.
2. Change ingredient selection so stale ingredients are not automatically preferred over fresh ingredients.

The selection process should compare valid ingredients by the number of days remaining before they become totally rotten. This comparison should apply even when one candidate is fresh and another candidate is stale.

A stale ingredient with a long time remaining before total rot should not be chosen over a fresh ingredient with less time remaining before total rot.

## Desired Outcome

The player sees the action as `Create Ed's Salad`.

When PseudoSalad chooses among valid nonrotten candidates in a priority tier or fallback tier, it selects the item with the shortest remaining time before total rot, while still respecting the existing two-use-per-full-type limit unless no other ingredients are available.

## Tasks

- [x] Update the English context-menu translation to `Create Ed's Salad`.
- [x] Review any tooltip wording and decide whether it should reference Ed's Salad or remain generic.
- [x] Replace the freshness-first comparator with a rot-time comparator based on `item:getOffAgeMax() - item:getAge()`.
- [x] Ensure the comparator does not automatically prefer stale ingredients over fresh ingredients.
- [x] Preserve existing filtering rules:
  - nonrotten ingredients only,
  - no spices or extras,
  - cooked-only dangerous uncooked ingredients,
  - known-poison rejection,
  - priority buckets for egg, cooked fish/small bird protein, and vegetables/greens.
- [x] Preserve Phase 2 usage behavior:
  - prefer candidates used fewer than two times,
  - only exceed two uses of the same full type when no under-limit valid candidates remain.
- [x] Re-check selection flow for preferred tiers and fallback tiers after the comparator change.
- [x] Run available local validation and document any verification gaps.

## Notes and Risks

- Version scope remains Project Zomboid 42.19 and later only.
- The new selection definition is "shortest time until totally rotten", not "shortest time until stale" and not "stale before fresh".
- `item:getOffAgeMax() - item:getAge()` may be negative only for rotten or over-age items, but rotten ingredients should already be filtered out before selection.
- Do not mark this DevCycle `Verified` without explicit user approval.

## Phase 2 - Fix Leftover Ingredient After Add

Status: Work Complete

### Goal

Investigate and fix the bug where an ingredient can remain in the player's inventory after PseudoSalad finishes creating the salad.

The issue was noticed before DevCycle002 but was not captured in the original DC2 plan. It appears to happen frequently with cooked small bird meat, so that ingredient should be used as a primary reproduction case.

### Desired Outcome

After `Create Ed's Salad` completes, every ingredient that vanilla successfully added to the salad should be consumed or reduced exactly as vanilla `ISAddItemInRecipe` expects. The player should not be left with an extra ingredient copy or leftover source item unless vanilla intentionally leaves a valid partial-use remainder.

### Investigation Notes

- Small bird meat should be tested carefully because it appears to trigger the issue often.
- The current planner records intended ingredient use before `ISAddItemInRecipe` performs, so the implementation may be tracking planned use rather than successful vanilla consumption.
- The add loop refreshes candidate items before each add, but the queued action may still hold an item reference that vanilla partially consumes, replaces, or leaves in a state that affects the next continuation.
- Partial ingredient remainders are allowed. The fix should preserve vanilla evolved-recipe behavior and must not manually delete valid partial food left by `ISAddItemInRecipe`.
- If the first use of an ingredient leaves a valid partial item, PseudoSalad should prefer that same partial item as the second use of that ingredient type.

### Tasks

- [x] Reproduce or reason through the leftover ingredient case with cooked `Base.Smallbirdmeat`.
- [x] Review `ISAddItemInRecipe` behavior for full consumption, partial use, and item replacement after an add.
- [x] Check whether PseudoSalad's continuation action runs too early, records usage too early, or reuses stale item references.
- [x] Adjust the queue/continuation flow so ingredient usage is recorded only after vanilla add behavior succeeds, if needed.
- [x] Ensure the planner refreshes the base salad item and candidate ingredient list after each completed add.
- [x] Avoid manual ingredient deletion; valid partial-use leftovers are allowed.
- [x] Document that small bird meat and another ingredient type still require in-game validation because no game runtime is available here.
- [x] Update this phase's completion summary after implementation.

### Notes and Risks

- This phase should not change the DC2 rot-time selection rule unless the leftover bug is directly caused by selection state.
- Small bird meat may have item-specific evolved-recipe or partial-use behavior that differs from vegetables or eggs.
- Do not mark this phase or DevCycle002 `Verified` without explicit user approval.

## Completion Summary

Implemented the menu label change by updating `ContextMenu_PseudoSalad_MakeAutoSalad` to `Create Ed's Salad`. Tooltip text remains generic because it describes the behavior clearly without needing another name change.

Replaced the stale/fresh priority comparator with a total-rot-time comparator. Candidate selection now compares `item:getOffAgeMax() - item:getAge()` for all valid nonrotten ingredients, regardless of whether each item is fresh or stale. Existing filtering, priority bucket behavior, and Phase 2 two-use-per-full-type behavior were preserved.

Validation completed: `ContextMenu.json` parses successfully with `python -m json.tool`, and the changed Lua selection flow was reviewed locally. This environment still does not provide `lua` or `luac`, so Lua syntax and in-game behavior remain pending game-side verification.

Phase 2 implementation: reviewed vanilla `ISAddItemInRecipe` and 42.19 `EvolvedRecipe.addItem(...)`. Cooked `Base.Smallbirdmeat` uses `Salad:10|Cooked`, while the item has `HungerChange = -15.0`, so vanilla can leave a valid partial remainder after salad additions, especially with Cooking skill reducing ingredient consumption. Per user clarification, partial items are allowed and PseudoSalad should not delete them.

The implementation now wraps `ISAddItemInRecipe` with `PseudoSaladAddItemInRecipe` so PseudoSalad records ingredient usage only after vanilla `complete()` succeeds and the base salad's extra item count increases. This avoids counting planned additions that did not actually land and keeps the continuation flow aligned with vanilla item replacement/partial-use behavior. The planner still refreshes the base item and candidate list before each add.

Follow-up clarification implementation: when vanilla leaves the first used ingredient as a valid partial item, PseudoSalad records that item ID by full type and prefers it as the second use while that full type has only one successful add. This keeps partial small bird meat or other partial ingredients as the intended second use instead of merely allowing them to compete with other candidates.

Phase 2 validation: confirmed `ContextMenu.json` still parses, reviewed the Lua flow for removal calls, and confirmed PseudoSalad does not call `UseAndSync`, `Remove`, or manual cleanup on valid partial ingredients. Rechecked the partial-remainder selection path after the clarification. This environment still does not provide `lua` or `luac`, so Lua syntax and in-game behavior remain pending game-side verification.