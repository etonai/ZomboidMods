# DevCycle 2026-05: Butter Candle Weight Increase

**Status:** Work Complete
**Start Date:** 2026-07-03
**Target Completion:** 2026-07-03
**Focus:** Ensure both unlit and lit Butter Candle items weigh `0.6`.

---

## Goal

Set the item weight of the Butter Candle mod's candle items so both `PseudoButterCandle.ButterCandle` and `PseudoButterCandle.ButterCandleLit` weigh `0.6`. This should make the crafted candle use the intended balance value for the tin can plus fat plus twig construction.

The change should be limited to item weight only. Recipes, icons, world models, lighting, extinguish behavior, placed-light persistence, and burn duration should remain unchanged.

## Desired Outcome

Both Butter Candle item states have:

```text
Weight = 0.6,
```

The unlit and lit candle should keep the same inventory behavior except for weight. Lighting and extinguishing should preserve the expected item state while keeping the intended weight on both sides of the conversion.

---

## Tasks

### Phase 1: Item Weight Update

**Status:** Work Complete

- [x] Inspect `PseudoButterCandle/42/media/scripts/items/PseudoButterCandle_Items.txt`.
- [x] Keep `PseudoButterCandle.ButterCandle` at `Weight = 0.6`.
- [x] Keep `PseudoButterCandle.ButterCandleLit` at `Weight = 0.6`.
- [x] Confirm no other item fields are changed as part of this cycle.

**Technical Notes:**
Current static inspection on 2026-07-03 shows both item states already have `Weight = 0.6`. The implementation should preserve those values and leave all unrelated fields unchanged.

### Phase 2: Static Verification

**Status:** Work Complete

- [x] Confirm both unlit and lit item definitions contain exactly one `Weight = 0.6` assignment each.
- [x] Confirm the recipe output still creates one `PseudoButterCandle.ButterCandle`.
- [x] Confirm light/extinguish recipes still convert between `ButterCandle` and `ButterCandleLit`.
- [x] Confirm no recipe cost, burn duration, icon, or model changes are introduced.

**Technical Notes:**
Use a focused diff against `PseudoButterCandle_Items.txt` and `PseudoButterCandle_Recipes.txt` if implementation touches either file.

### Phase 3: In-Game Verification

**Status:** Planning

- [ ] Confirm the unlit Butter Candle displays weight `0.6` in inventory.
- [ ] Confirm the lit Butter Candle displays weight `0.6` in inventory.
- [ ] Confirm lighting and extinguishing do not unexpectedly change weight or break item conversion.
- [ ] Confirm placed candle behavior remains unchanged.

**Technical Notes:**
Do not mark this cycle or any phase `Verified` until in-game behavior has been explicitly confirmed and the user approves the status.

---

## Notes and Risks

- The current script appears to have both weights set to `0.6`; despite the original wording of "increase," the concrete target for this cycle is `0.6`.
- Keep the scope narrow. Avoid touching the active model/texture experiments or any deferred FBX work.
- If another branch or manual edit has already changed the weights before implementation starts, record that clearly in the completion summary.

---

## Completion Summary

Implementation/static confirmation complete. Move this document to `doc/planning/completed/` after in-game verification or explicit deferral.

**Completion Date:** 2026-07-03
**Phases Completed:** Phase 1 and Phase 2
**Work Deferred:** Phase 3 in-game verification remains pending user testing/approval.

**Accomplishments:**
- Confirmed both `PseudoButterCandle.ButterCandle` and `PseudoButterCandle.ButterCandleLit` are set to `Weight = 0.6`.
- Left recipes, icons, world models, lighting behavior, placed-light persistence, and burn duration unchanged.

**Metrics:**
- Files modified: 1
- Item script changes: 0
- Static verification: Passed
- In-game verification: Pending

**Lessons / Notes:**
The requested `0.6` target was already present in the item script, so this cycle completed as documentation and static confirmation rather than a gameplay script edit.