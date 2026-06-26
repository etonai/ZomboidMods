# DevCycle 2026-03: Baking Fat Butter Candle Input

**Status:** Work Complete
**Start Date:** 2026-06-26
**Target Completion:** 2026-06-26
**Focus:** Broaden `CraftButterCandle` so any item tagged `base:bakingfat` can provide the candle fat, not only `Base.Butter`.

---

## Goal

Update the butter candle crafting plan so `CraftButterCandle` accepts any baking fat item supported by Project Zomboid's `base:bakingfat` tag. The current recipe requires `item 24 [Base.Butter]`, which keeps the recipe tied specifically to butter even though vanilla B42 already groups butter, lard, margarine, and cooking oils under the baking fat tag.

The gameplay goal is to keep the same material cost while making the recipe more flexible and consistent with existing baking recipes.

## Desired Outcome

`CraftButterCandle` should require 24 units of any item tagged `base:bakingfat`, plus one `Base.Twigs` and one `Base.TinCanEmpty`. The output remains one `PseudoButterCandle.ButterCandle`, and all candle lighting, placement, burn duration, icons, and world-model behavior remain unchanged.

---

## Tasks

### Phase 1: Recipe Input Generalization

**Status:** Work Complete

- [x] Update `PseudoButterCandle/42/media/scripts/recipes/PseudoButterCandle_Recipes.txt`.
- [x] Replace the butter-specific input `item 24 [Base.Butter],` with a tag-based baking fat input.
- [x] Keep the required amount at 24 units unless static review shows tagged baking fats need a different unit convention.
- [x] Keep twig and empty tin can consumption unchanged.
- [x] Confirm the output remains one `PseudoButterCandle.ButterCandle`.

**Technical Notes:**
Current recipe input:

```text
item 24 [Base.Butter],
```

Implemented target input:

```text
item 24 tags[base:bakingfat],
```

Vanilla recipe references show `tags[base:bakingfat]` is already used in `media/scripts/generated/recipes/recipes_baking.txt`, including quantity-based inputs such as `item 1 tags[base:bakingfat]` and `item 2 tags[base:bakingfat]`.

### Phase 2: Static Review

**Status:** Work Complete

- [x] Confirm the vanilla `base:bakingfat` tag exists on the intended fat items.
- [x] Confirm `Base.Butter`, `Base.Lard`, `Base.Margarine`, `Base.OilOlive`, and `Base.OilVegetable` are covered by the tag in B42 script data.
- [x] Confirm no translation updates are required because the recipe name stays `Make Butter Candle`.
- [x] Confirm the recipe script does not accidentally broaden twig, tin can, output, lighting, or burn behavior.

**Technical Notes:**
Static source check found the tag on these vanilla items in `media/scripts/generated/items/food.txt`:

- `Base.Butter`
- `Base.Lard`
- `Base.Margarine`
- `Base.OilOlive`
- `Base.OilVegetable`

### Phase 3: In-Game Verification

**Status:** Planning

- [ ] Confirm `CraftButterCandle` appears in the Survival crafting category.
- [ ] Confirm butter can still craft a butter candle when at least 24 units are available.
- [ ] Confirm lard can craft a butter candle when at least 24 units are available.
- [ ] Confirm margarine can craft a butter candle when at least 24 units are available.
- [ ] Confirm olive oil and vegetable oil behavior is acceptable if their tagged quantity handling differs from solid fats.
- [ ] Confirm crafting still consumes one twig and one empty tin can.
- [ ] Confirm the crafted candle still lights, extinguishes, places, emits light, and drains as before.

**Technical Notes:**
This cycle should stop at `Work Complete` after implementation and static checks. Do not mark the cycle or phase `Verified` until in-game behavior has been explicitly confirmed and the user approves the status.

---

## Notes and Risks

- `base:bakingfat` includes both solid fats and oils. If liquid oils use different quantity semantics from butter/lard/margarine, this may need a follow-up balance adjustment.
- The visible item name remains `Butter Candle` even if crafted from lard, margarine, or oil. That is acceptable for this cycle unless user-facing naming becomes confusing in play.
- This cycle should not alter burn duration, lighting behavior, icons, world models, or placed-light persistence.

---

## Completion Summary

Implementation and static review complete. Move this document to `doc/planning/completed/` after in-game verification or explicit deferral.

**Completion Date:** 2026-06-26
**Phases Completed:** Phase 1 and Phase 2
**Work Deferred:** Phase 3 in-game verification remains pending user testing/approval.

**Accomplishments:**
- Updated `CraftButterCandle` to require `item 24 tags[base:bakingfat]` instead of `item 24 [Base.Butter]`.
- Left twig, empty tin can, output item, recipe name, lighting behavior, placement behavior, and burn duration unchanged.

**Metrics:**
- Files modified: 2
- Recipe diff: one input line changed
- Static verification: Passed
- In-game verification: Pending

**Lessons / Notes:**
The vanilla `base:bakingfat` tag covers butter, lard, margarine, olive oil, and vegetable oil in B42. In-game testing should confirm whether liquid oils feel acceptable at the same 24-unit cost as solid fats.