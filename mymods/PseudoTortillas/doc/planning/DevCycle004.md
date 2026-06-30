# DevCycle 004: Minimal Raw Tortilla Recipes

**Status:** Planning
**Start Date:** 2026-06-30
**Target Completion:** TBD
**Focus:** Simplify raw tortilla crafting by removing tool and fat requirements, shortening raw tortilla spoilage, replacing the current timed action, and adding 1x and 8x batch recipes.

---

## Goal

Update the PseudoTortillas mod so raw tortillas can be made with fewer requirements and more flexible batch sizes. The existing `MakeRawTortillas` recipe should be renamed/replaced as `Make4RawTortillas`, no longer require a rolling pin or baking fat, and explicitly produce 4 raw tortillas. The recipe timed action should move from `SliceMeat_Surface` to `Making`, matching the desired generic food-prep fussing action. Raw tortillas should spoil faster to reflect their uncooked state.

## Desired Outcome

The mod provides three consistently named raw tortilla batch sizes: `MakeRawTortilla`, `Make4RawTortillas`, and `Make8RawTortillas`. All raw tortilla recipes use flour/cornflour and water only, without a rolling pin, baking fat, or salt. Raw tortilla recipes use `timedAction = Making` instead of `SliceMeat_Surface`. `RawTortilla` has `DaysFresh = 1` and `DaysTotallyRotten = 2`.

---

## Tasks

### Phase 1: Simplify Existing Recipe

**Status:** Planning

- [ ] Rename or replace `MakeRawTortillas` with `Make4RawTortillas` for the 4x recipe.
- [ ] Remove the kept rolling pin and baking fat inputs from `Make4RawTortillas`.
- [ ] Keep flour/cornflour as the dry ingredient input.
- [ ] Keep water as the fluid input.
- [ ] Ensure `Make4RawTortillas` explicitly outputs `item 4 Pseudonymous.RawTortilla`.

**Technical Notes:**
The implementation target is `PseudoTortillas/42/media/scripts/recipes/PseudoTortillasRecipes.txt`. Current `MakeRawTortillas` inputs include `item 1 tags[base:rollingpin] mode:keep flags[MayDegrade]`, `item 60 tags[base:flour]`, `item 3 tags[base:bakingfat]`, and `-fluid 0.25 [Water]`. This cycle removes the rolling pin and baking fat requirements while converting the existing 4-tortilla recipe identity to the explicit `Make4RawTortillas` name.

### Phase 2: Add Batch Size Recipes

**Status:** Planning

- [ ] Create a new recipe that makes 1 raw tortilla.
- [ ] Create a new recipe that makes 8 raw tortillas.
- [ ] Use this mod's existing `Make...` naming convention for tortilla recipes, while keeping batch size explicit in the recipe names.
- [ ] Set the 1x recipe water input to `-fluid 0.1 [Water]`.
- [ ] Scale or choose the 4x and 8x water inputs from that 0.1 baseline unless compatibility testing indicates a better value.
- [ ] Give each recipe a distinct recipe identifier and clear translation text if needed.
- [ ] Confirm all new recipes output `Pseudonymous.RawTortilla`.

**Technical Notes:**
The existing 4x recipe currently uses `item 60 tags[base:flour]` and `-fluid 0.25 [Water]`. Vanilla recipe names such as `Get6Cookies` and `Get6Biscuits` show the value of making batch size clear in the recipe identifier. This mod has been using `Make...` names, so keep that convention while making the batch size names consistent: `MakeRawTortilla` for the singular 1x recipe, `Make4RawTortillas` for the 4x recipe, and `Make8RawTortillas` for the 8x recipe. Do not keep the ambiguous old `MakeRawTortillas` name once the 1x and 8x recipes exist. The 1x recipe should use 15 flour units and `-fluid 0.1 [Water]`. Use that 0.1 water baseline when deciding the 4x and 8x water quantities, unless script compatibility testing indicates a better value. Translation updates may be needed in `PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`.

### Phase 3: Replace Timed Action With Making

**Status:** Planning

- [ ] Replace `timedAction = SliceMeat_Surface` with `timedAction = Making` in the renamed 4x recipe.
- [ ] Use `timedAction = Making` for `MakeRawTortilla`, `Make4RawTortillas`, and `Make8RawTortillas`.
- [ ] Document that `Making` was selected because it better fits generic tortilla prep than slicing meat.

**Technical Notes:**
The current recipe uses `timedAction = SliceMeat_Surface`, which reads as cutting meat rather than making simple raw tortillas. Use `timedAction = Making`, a vanilla B42 action used by generic cooking and baking tasks such as `MakeTortillaChips` in `media/scripts/generated/recipes/recipes_cooking.txt`.

### Phase 4: Shorten Raw Tortilla Freshness

**Status:** Planning

- [ ] Change `RawTortilla` `DaysFresh` from 3 to 1.
- [ ] Change `RawTortilla` `DaysTotallyRotten` from 5 to 2.
- [ ] Leave cooking behavior, cooked replacement, and nutrition values unchanged unless a script compatibility issue requires adjustment.

**Technical Notes:**
The implementation target is `PseudoTortillas/42/media/scripts/items/PseudoTortillasItems.txt`. The requested spoilage values are explicit: `DaysFresh = 1` and `DaysTotallyRotten = 2`.

### Phase 5: Static Verification

**Status:** Planning

- [ ] Confirm no raw tortilla recipe requires `tags[base:rollingpin]`.
- [ ] Confirm no raw tortilla recipe requires `tags[base:bakingfat]`.
- [ ] Confirm no raw tortilla recipe requires `Base.Salt`.
- [ ] Confirm no raw tortilla recipe uses `timedAction = SliceMeat_Surface`.
- [ ] Confirm all raw tortilla recipes use `timedAction = Making`.
- [ ] Confirm raw tortilla outputs exist for `MakeRawTortilla`, `Make4RawTortillas`, and `Make8RawTortillas`.
- [ ] Confirm `RawTortilla` spoilage values are `DaysFresh = 1` and `DaysTotallyRotten = 2`.

**Technical Notes:**
Static verification should inspect the recipe and item scripts directly. Deployment and in-game verification can be performed after implementation if requested.

---

## Open Questions

*None at cycle start.*

---

## Notes and Risks

- Do not mark this cycle `Verified` without Ed's explicit approval.
- Per `mymods/PseudoTortillas/AGENTS.md`, agents should stop after creating this DevCycle document and wait for an explicit implementation request.
- The 1x recipe water input is explicitly `-fluid 0.1 [Water]`; larger batch water amounts should be chosen from that baseline.
- `Making` is the selected replacement timed action for raw tortilla recipes.
- This cycle intentionally reverses the previous rolling pin and baking fat requirements for raw tortillas.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** TBD
**Phases Completed:** TBD
**Work Deferred:** TBD

**Accomplishments:**
- TBD

**Metrics:**
- Files modified: TBD

**Lessons / Notes:**
TBD










