# DevCycle 006: Salad-Style Sweet and Savory Grits

**Status:** Work Complete
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Make neutral grits first, then choose sweet or savory when adding ingredients.

---

## Goal

Make Grits behave like vanilla salad/fruit salad: the initial craft creates a neutral base item, and the evolved-recipe menu offers separate sweet and savory outcomes when valid ingredients are available.

The earlier DC6 implementation split the initial craft recipes into sweet and savory versions. That was the wrong level of choice. This revision moves the choice to the evolved recipe layer:

- Crafting creates neutral grits for bowl, pan, and pot.
- Adding ingredients to neutral grits can create sweet grits or savory grits.
- Sweet evolved recipes use Template = Oatmeal.
- Savory evolved recipes use Template = Stew.
- No DC5-style vanilla item overrides are used.

## Desired Outcome

Players see neutral craft entries such as Make Grits, not separate Make Sweet Grits and Make Savory Grits recipes.

Expected behavior:

- MakeGritsBowl creates a neutral bowl of grits.
- MakeGritsPan creates a neutral saucepan water-base grits item.
- MakeGritsPot creates a neutral cooking pot water-base grits item.
- When valid ingredients are available, the evolved recipe menu offers sweet grits and/or savory grits options from the neutral base item.
- Sweet options use Template = Oatmeal.
- Savory options use Template = Stew.
- Pan and pot keep the DC3 water-base conversion behavior so the first ingredient converts the neutral water-base item into the final sweet/savory pan or pot item.

---

## Tasks

### Phase 1: Neutral Craft Recipes

**Status:** Work Complete

- [x] Restore one neutral bowl craft recipe: MakeGritsBowl.
- [x] Restore one neutral pan craft recipe: MakeGritsPan.
- [x] Restore one neutral pot craft recipe: MakeGritsPot.
- [x] Keep existing ingredient and water quantities.
- [x] Output neutral base items from the initial craft step.

### Phase 2: Sweet and Savory Result Items

**Status:** Work Complete

- [x] Keep neutral legacy/current base item definitions.
- [x] Add sweet and savory bowl result items.
- [x] Add sweet and savory pan result items.
- [x] Add sweet and savory pot result items.
- [x] Remove unused sweet/savory water-base variant item definitions from active script files.
- [x] Preserve existing nutrition, hunger, cooking, and container behavior from current grits items.

### Phase 3: Salad-Style Evolved Recipes

**Status:** Work Complete

- [x] Add sweet bowl evolved recipe using the neutral bowl base item and Template = Oatmeal.
- [x] Add savory bowl evolved recipe using the neutral bowl base item and Template = Stew.
- [x] Add sweet pan evolved recipe using the neutral saucepan water-base item and Template = Oatmeal.
- [x] Add savory pan evolved recipe using the neutral saucepan water-base item and Template = Stew.
- [x] Add sweet pot evolved recipe using the neutral cooking pot water-base item and Template = Oatmeal.
- [x] Add savory pot evolved recipe using the neutral cooking pot water-base item and Template = Stew.
- [x] Preserve AddIngredientIfCooked = true.
- [x] Preserve CanAddSpicesEmpty = true.
- [x] Preserve Cookable = true.
- [x] Preserve MaxItems = 3.

### Phase 4: Translations

**Status:** Work Complete

- [x] Restore neutral craft recipe translations.
- [x] Add sweet and savory item translations.
- [x] Add sweet and savory evolved recipe name translations.
- [x] Add sweet and savory context menu translations keyed by evolved recipe object name.
- [x] Keep context menu values short, for example Sweet Grits and Savory Grits.

### Phase 5: Static Checks

**Status:** Work Complete

- [x] Confirm three active neutral craft recipes exist.
- [x] Confirm six active evolved recipes exist.
- [x] Confirm sweet evolved recipes use only Template = Oatmeal.
- [x] Confirm savory evolved recipes use only Template = Stew.
- [x] Confirm no active evolved recipe uses Template = Rice.
- [x] Confirm no DC5 generated override files exist.
- [x] Confirm script braces are balanced.
- [x] Confirm EN translation JSON files parse.

### Phase 6: In-Game Verification

**Status:** Pending In-Game Verification

- [ ] Launch Project Zomboid B42 with PseudoGrits enabled and confirm no script parse errors.
- [ ] Confirm neutral bowl, pan, and pot grits craft entries appear.
- [ ] Confirm separate sweet/savory craft entries do not appear at the initial craft step.
- [ ] Confirm sweet grits can be created from neutral grits when oatmeal-style ingredients are available.
- [ ] Confirm savory grits can be created from neutral grits when stew-style ingredients are available.
- [ ] Confirm pan and pot variants convert from neutral water-base items into final sweet/savory items when ingredients are added.
- [ ] Confirm context menu labels show Sweet Grits and Savory Grits rather than raw translation keys.

---

## Notes and Risks

- This cycle intentionally avoids item override generation.
- The active design is modeled after vanilla salad/fruit salad: one base item can feed multiple evolved recipe outcomes.
- Existing saves may contain neutral or earlier sweet/savory items from prior test builds. Legacy neutral items remain defined.
- Per mymods/PseudoGrits/AGENTS.md, this cycle should not be marked Verified without explicit user approval.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** Phases 1-5
**Work Deferred:** Phase 6 in-game verification remains for Ed.

**Accomplishments:**
- Restored neutral craft recipes for bowl, pan, and pot.
- Moved sweet/savory selection to evolved recipes, matching the vanilla salad/fruit salad pattern.
- Added six evolved recipes: three sweet using Template = Oatmeal, three savory using Template = Stew.
- Kept pan and pot neutral water-base conversion behavior.
- Removed unused sweet/savory water-base variant item definitions.
- Updated EN item, recipe, evolved recipe, and context-menu translations.

**Metrics:**
- Active craft recipes: 3
- Active evolved recipes: 6
- Active sweet/savory result item definitions: 6
- In-game checks completed: 0

**Lessons / Notes:**
- The player choice should happen when choosing an evolved recipe outcome, not when crafting the neutral base food.
