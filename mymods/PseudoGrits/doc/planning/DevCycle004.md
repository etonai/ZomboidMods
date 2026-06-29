# DevCycle 004: Grits Savory Ingredient Eligibility

**Status:** Work Complete
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Allow grits evolved recipes to accept savory add-ins such as meat instead of being limited to oatmeal-style toppings and seasonings.

---

## Goal

Update `PseudoGrits` evolved recipe ingredient eligibility so players can add savory ingredients, including meat, to grits.

Current grits evolved recipes use `Template = Oatmeal`. That template makes sense for sweet oatmeal-style toppings, but it does not include common savory/meat add-ins. Vanilla meat items such as ground beef, chicken, bacon, ham, pork chop, and steak commonly advertise `Rice` and/or `Stew` evolved recipe entries, not `Oatmeal` entries.

This cycle should make grits behave more like a savory grain base. The recommended implementation is to change grits evolved recipe templates from `Oatmeal` to `Rice`, preserving the DC 3 rice-style base/result item flow.

## Desired Outcome

Players should be able to add savory ingredients to grits, including representative meat items such as:

- `Base.MincedMeat` / Ground Beef
- chicken items with `Rice` evolved recipe entries
- bacon items with `Rice` evolved recipe entries
- ham items with `Rice` evolved recipe entries
- steak or pork items with `Rice` evolved recipe entries

The mod should preserve the existing DC 3 item flow:

- `MakeGritsBowl` continues to output `Pseudonymous.GritsBowl`.
- `MakeGritsPan` continues to output `Pseudonymous.WaterSaucepanGrits`.
- `MakeGritsPot` continues to output `Pseudonymous.WaterPotGrits`.
- Pan/pot evolved recipes continue converting water-grits bases into final grits items.

---

## Tasks

### Phase 1: Confirm Ingredient Eligibility Cause

**Status:** Work Complete

- [x] Confirm all current grits evolved recipes use `Template = Oatmeal`.
- [x] Confirm representative meat items have `Rice` evolved recipe entries but no `Oatmeal` evolved recipe entries.
- [x] Confirm current `AddIngredientIfCooked = true` and `CanAddSpicesEmpty = true` flags are already present and are not the limiting factor.
- [x] Confirm the DC 3 base/result flow should remain unchanged.

**Technical Notes:**
Initial review found `Base.MincedMeat` has `Rice:20` and no `Oatmeal` entry. Other meats follow the same general pattern: they are compatible with recipes such as `Rice`, `Stew`, `Pasta`, `Stir fry`, and sandwiches, but not oatmeal.

### Phase 2: Choose Template Strategy

**Status:** Work Complete

- [x] Decide whether grits should use `Template = Rice` for all three evolved recipes.
- [x] Consider `Template = Stew` as an alternative if the desired ingredient set should match stew more closely than rice.
- [x] Record whether losing any oatmeal-only sweet toppings is acceptable for a savory grits direction.
- [x] Confirm whether bowl, pan, and pot grits should all use the same savory template.

**Technical Notes:**
Decision: use `Template = Rice` for `GritsBowl`, `GritsPan`, and `GritsPot`. Grits are a grain base, and vanilla `Rice` ingredient entries include the meat-style add-ins the player expects.

### Phase 3: Update Evolved Recipes

**Status:** Work Complete

- [x] Change `GritsBowl` evolved recipe from `Template = Oatmeal` to `Template = Rice`.
- [x] Change `GritsPan` evolved recipe from `Template = Oatmeal` to `Template = Rice`.
- [x] Change `GritsPot` evolved recipe from `Template = Oatmeal` to `Template = Rice`.
- [x] Preserve `BaseItem` and `ResultItem` values from DC 3.
- [x] Preserve `AddIngredientIfCooked = true`.
- [x] Preserve `CanAddSpicesEmpty = true`.
- [x] Preserve `Cookable = true`.

### Phase 4: Review Capacity And Balance

**Status:** Work Complete

- [x] Decide whether `MaxItems = 3` should remain for bowl grits.
- [x] Decide whether pan grits should move from `MaxItems = 3` to vanilla rice pan's `MaxItems = 4`.
- [x] Decide whether pot grits should move from `MaxItems = 3` to vanilla rice pot's `MaxItems = 5`.
- [x] Confirm no nutrition values or craft recipe ingredient amounts should change in this cycle.

**Technical Notes:**
Decision: keep the initial implementation narrowly focused on ingredient eligibility. Changing `MaxItems` can be included only if desired for rice parity, but it is not required to fix the inability to add meat.

### Phase 5: Static Checks

**Status:** Work Complete

- [x] Confirm all grits evolved recipes now use the chosen savory template.
- [x] Confirm pan/pot DC 3 water-base flow is unchanged.
- [x] Confirm craft recipe quantities are unchanged.
- [x] Confirm EN translation JSON files still parse.
- [x] Confirm script braces are balanced.

### Phase 6: In-Game Verification

**Status:** Work Complete - requires in-game verification

- [ ] Launch Project Zomboid B42 with `PseudoGrits` enabled and confirm no script parse errors.
- [ ] Confirm grits bowl, pan, and pot still craft.
- [ ] Confirm ground beef can be added to grits.
- [ ] Confirm at least one chicken item can be added to grits.
- [ ] Confirm at least one bacon/ham/steak-style item can be added to grits.
- [ ] Confirm seasonings/spices still behave acceptably.
- [ ] Confirm any expected sweet oatmeal-only toppings are either intentionally unavailable or documented as deferred.

---

## Open Questions

1. **Should grits switch to `Template = Rice` or `Template = Stew`?**
   Decision: `Template = Rice`, because grits are a grain base and vanilla meat add-ins already support rice.

2. **Should bowl grits change too?**
   Decision: yes. The user described grits generally, and bowl grits should not remain limited to oatmeal toppings if pan/pot grits become savory.

3. **Should sweet oatmeal-only toppings be preserved somehow?**
   Decision: not in this cycle. B42 evolved recipes expose one template field; preserving both sweet oatmeal and savory rice sets may require a separate custom compatibility strategy.

---

## Notes and Risks

- This cycle should not change grits nutrition, recipe quantities, or the DC 3 water-base item flow.
- Switching from `Oatmeal` to `Rice` may remove items that only advertise `Oatmeal`, such as some sweet fruit/sugar-style toppings.
- The main player-facing target is savory compatibility, especially meat.
- Per `mymods/PseudoGrits/AGENTS.md`, implementation must not begin until explicitly requested after this DevCycle document is created.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** 1-5 implementation/static review phases; Phase 6 prepared for in-game verification
**Work Deferred:** In-game verification remains pending and should be handled before marking the cycle Verified.

**Accomplishments:**
- Changed `GritsBowl`, `GritsPan`, and `GritsPot` evolved recipes from `Template = Oatmeal` to `Template = Rice` so savory rice-compatible ingredients such as meat can be offered.
- Preserved DC 3 base/result item flow, recipe quantities, nutrition values, and rice-style flags.

**Metrics:**
- Files modified: 2 (`PseudoGritsEvolvedRecipes.txt`, `DevCycle004.md`)
- In-game checks completed: 0

**Lessons / Notes:**
- Switching to `Template = Rice` should expose meat and other savory rice-compatible ingredients, but may drop oatmeal-only sweet toppings.

