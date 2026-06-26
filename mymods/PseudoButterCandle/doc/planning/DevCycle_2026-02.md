# DevCycle 2026-02: Butter Candle Partial Butter Consumption

**Status:** Work Complete
**Start Date:** 2026-06-26
**Target Completion:** 2026-06-26
**Focus:** Change the butter candle crafting recipe so it consumes 24 units of `Base.Butter` instead of destroying one whole butter item.

---

## Goal

Update `CraftButterCandle` so the recipe consumes a measured amount of butter rather than deleting any butter item outright. The current recipe uses `item 1 [Base.Butter] mode:destroy`, which allows a partially used block of butter to produce a full eight-hour butter candle.

The gameplay goal is to make the candle's material cost match the actual amount of butter available. A partially used butter item should only be valid if it still has enough remaining butter units for the candle.

## Desired Outcome

`CraftButterCandle` requires 24 units of `Base.Butter`, one twig, and one empty tin can. A full or sufficiently remaining butter item can produce a butter candle, while a butter item with less than 24 units remaining cannot produce a full candle.

The recipe should follow the same B42 quantity-input style used by butter-consuming cooking recipes, rather than treating butter as a single disposable object.

---

## Tasks

### Phase 1: Recipe Quantity Update

**Status:** Work Complete

- [x] Update `CraftButterCandle` in `PseudoButterCandle/42/media/scripts/recipes/PseudoButterCandle_Recipes.txt`.
- [x] Replace `item 1 [Base.Butter] mode:destroy` with a 24-unit butter requirement.
- [x] Keep twig and empty tin can consumption unchanged.
- [x] Confirm the output remains one `PseudoButterCandle.ButterCandle`.

**Technical Notes:**
Current recipe input:

```text
item 1 [Base.Butter] mode:destroy,
```

Target recipe input:

```text
item 24 [Base.Butter],
```

This mirrors the quantity-based approach documented for `MakeRawTortillas`, where butter is treated as an ingredient with usable units instead of a whole object that must always be destroyed.

### Phase 2: Static Review

**Status:** Work Complete

- [x] Confirm `Base.Butter` is still the correct vanilla item identifier.
- [x] Confirm the recipe script still parses structurally after the input change.
- [x] Check that no translation changes are required, since the visible recipe name remains `Make Butter Candle`.

**Technical Notes:**
Use `MakeRawTortillas` as the model for treating butter as a quantity-based recipe input rather than a whole item destroyed by the recipe.

### Phase 3: In-Game Verification

**Status:** Planning

- [ ] Confirm `CraftButterCandle` appears in the Survival crafting category.
- [ ] Confirm a butter item with at least 24 units remaining can craft one butter candle.
- [ ] Confirm a partially used butter item with less than 24 units remaining cannot craft one full butter candle.
- [ ] Confirm crafting consumes only the intended butter amount and still consumes one twig and one empty tin can.
- [ ] Confirm the crafted candle still lights, extinguishes, places, emits light, and drains as before.

**Technical Notes:**
This cycle should stop at `Work Complete` after implementation and static checks. Do not mark the cycle or phase `Verified` until in-game behavior has been explicitly confirmed and the user approves the status.

---

## Notes and Risks

- This is a balance fix, not a candle burn-duration change. The eight-hour full candle behavior should remain unchanged.
- If B42 treats `item 24 [Base.Butter]` differently from the documented tortilla plan, the recipe may need a follow-up adjustment after in-game testing.
- Existing crafted butter candles should not need migration because the change affects crafting inputs only.

---

## Completion Summary

**Completion Date:** 2026-06-26
**Phases Completed:** Phase 1 and Phase 2
**Work Deferred:** Phase 3 in-game verification remains pending user testing/approval.

**Accomplishments:**
- Updated `CraftButterCandle` to require 24 units of `Base.Butter` instead of destroying one whole butter item.
- Left twig, empty tin can, output item, recipe name, category, and candle burn behavior unchanged.

**Metrics:**
- Files modified: 2
- Static verification: Passed
- In-game verification: Pending

**Lessons / Notes:**
Quantity-based butter input better matches the intended material cost: a partially used butter item should not create a full eight-hour butter candle unless it has at least 24 units remaining.


