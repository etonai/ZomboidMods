# DevCycle 005: Porridge Combined Rice and Oatmeal Ingredients

**Status:** Abandoned
**Start Date:** 2026-06-29
**Target Completion:** Abandoned 2026-06-29
**Focus:** Abandoned attempt to replace the single-template shortcut with a custom porridge ingredient set drawn from vanilla rice and oatmeal ingredients.

---

## Abandonment Decision

**Decision Date:** 2026-06-29
**Decision:** Abandoned and reverted.

This DevCycle was implemented experimentally, but the implementation required full item overrides for every vanilla Rice/Oatmeal-compatible ingredient. The generated override file contained 188 copied vanilla item definitions for this mod alone. Because Project Zomboid item script loading resets existing item definitions before loading later item bodies, partial item snippets are not safe for this approach; preserving vanilla behavior requires copying full item blocks and editing only EvolvedRecipe.

That amount of overriding is too broad and too fragile for the desired ingredient-list improvement. The generated override file was removed, and the evolved recipes were restored to the DC4 Template = Rice behavior.

No DC5 script changes remain active.
---

## Goal

Fix `PseudoPorridge` ingredient eligibility so porridge can accept ingredients from both vanilla rice and vanilla oatmeal.

DC 4 switched porridge evolved recipes to `Template = Rice` to expose savory ingredients like meat. That was useful for confirming the source of the issue, but it still does not match the desired design. Porridge should not be forced to choose one vanilla template. It should have its own `Porridge` compatibility key populated from the combined vanilla `Rice` and `Oatmeal` ingredient sets.

## Desired Outcome

Players can add ingredients to porridge if those ingredients are valid for vanilla rice or vanilla oatmeal.

Expected behavior:

- Sweet/oatmeal-style add-ins remain available where vanilla items advertise `Oatmeal`.
- Savory/rice-style add-ins, including meat, become available where vanilla items advertise `Rice`.
- The porridge evolved recipes use a custom template, likely `Template = Porridge`.
- The allowed ingredient entries are supplied by mod-owned item override scripts that add `Porridge:N` entries to every vanilla item in the combined rice/oatmeal ingredient set.
- Existing DC 3 water-base item flow remains unchanged.
- Recipe quantities, nutrition, item names, and translations remain unchanged unless needed for the custom ingredient entries.

---

## Tasks

### Phase 1: Generate the Combined Ingredient Set

**Status:** Abandoned

- [ ] ABANDONED: Parse vanilla `media/scripts/generated/items/food.txt` and `drainable.txt` for every item with `EvolvedRecipe` containing `Oatmeal:`.
- [ ] ABANDONED: Parse vanilla `media/scripts/generated/items/food.txt` and `drainable.txt` for every item with `EvolvedRecipe` containing `Rice:`, `RicePot:`, or `RicePan:`.
- [ ] ABANDONED: Create the union of both item sets.
- [ ] ABANDONED: Preserve each item's vanilla amount for the matching source template:
  - use the item's `Oatmeal:N` value when it has one
  - otherwise use the item's `Rice:N` value
- [ ] ABANDONED: Preserve any vanilla condition suffix such as `|Cooked` if present on the source entry.
- [ ] ABANDONED: Document counts for oatmeal-only, rice-only, and overlapping ingredients.

**Technical Notes:**
Use structured parsing of item blocks rather than ad hoc manual lists. The result was generated from the current B42 scripts so it remains code-based. `RicePot` and `RicePan` entries are included because `Item.DoParam(EvolvedRecipe)` aliases them to the `Rice` template at load time.

### Phase 2: Decide Conflict Rules

**Status:** Abandoned

- [ ] ABANDONED: Decide how to handle items that have both `Oatmeal` and `Rice` entries with different values.
- [ ] ABANDONED: Decide whether oatmeal values should win for overlap items, because they represent the sweet/base-specific amount.
- [ ] ABANDONED: Decide whether any odd rice-compatible items should be excluded from porridge.
- [ ] ABANDONED: Decide whether the generated ingredient override file should be split by source, for example oatmeal-derived and rice-derived entries, or kept as one file.

**Technical Notes:**
Recommended rule: `Oatmeal` value wins when both entries exist, otherwise use `Rice`. Do not hand-prune in the first implementation unless a specific vanilla item is obviously broken in testing.

### Phase 3: Add Custom Porridge Ingredient Entries

**Status:** Abandoned

- [ ] ABANDONED: Create a mod-owned generated script file for ingredient compatibility, for example `PseudoPorridgeIngredientOverrides.txt`.
- [ ] ABANDONED: For each combined ingredient, override or extend the item definition to include `Porridge:N` in its `EvolvedRecipe` list.
- [ ] ABANDONED: Preserve the item's existing vanilla `EvolvedRecipe` entries when adding `Porridge:N`.
- [ ] ABANDONED: Ensure the script load behavior registers those items with evolved recipes whose `Template = Porridge`.
- [ ] ABANDONED: Keep this file generated or clearly marked as generated if created mechanically.

**Technical Notes:**
Project Zomboid stores evolved recipe membership on ingredient item definitions, not as a central list on the evolved recipe. This phase creates the custom list by attaching a `Porridge` entry to each allowed ingredient item.

### Phase 4: Update Porridge Evolved Recipes

**Status:** Abandoned

- [ ] ABANDONED: Change `PorridgeBowl` evolved recipe from `Template = Rice` to `Template = Porridge`.
- [ ] ABANDONED: Change `PorridgePan` evolved recipe from `Template = Rice` to `Template = Porridge`.
- [ ] ABANDONED: Change `PorridgePot` evolved recipe from `Template = Rice` to `Template = Porridge`.
- [ ] ABANDONED: Preserve DC 3 `BaseItem` and `ResultItem` values.
- [ ] ABANDONED: Preserve `AddIngredientIfCooked = true`.
- [ ] ABANDONED: Preserve `CanAddSpicesEmpty = true`.
- [ ] ABANDONED: Preserve `Cookable = true`.
- [ ] ABANDONED: Preserve `MaxItems = 3` unless implementation review identifies a strong reason to change it.

### Phase 5: Static Checks

**Status:** Abandoned

- [ ] ABANDONED: Confirm all porridge evolved recipes use `Template = Porridge`.
- [ ] ABANDONED: Confirm generated/override ingredient entries include both oatmeal-derived and rice-derived items.
- [ ] ABANDONED: Confirm representative oatmeal items have `Porridge` entries.
- [ ] ABANDONED: Confirm representative rice/meat items have `Porridge` entries.
- [ ] ABANDONED: Confirm existing recipe quantities and nutrition values are unchanged.
- [ ] ABANDONED: Confirm EN translation JSON files parse.
- [ ] ABANDONED: Confirm script braces are balanced.

### Phase 6: In-Game Verification

**Status:** Not Applicable - Abandoned

- [ ] NOT RUN: Launch Project Zomboid B42 with `PseudoPorridge` enabled and confirm no script parse errors.
- [ ] NOT RUN: Confirm bowl, pan, and pot porridge still craft.
- [ ] NOT RUN: Confirm a representative oatmeal-style ingredient can be added to porridge.
- [ ] NOT RUN: Confirm ground beef can be added to porridge.
- [ ] NOT RUN: Confirm at least one other rice/meat ingredient can be added to porridge.
- [ ] NOT RUN: Confirm seasonings/spices still behave acceptably.
- [ ] NOT RUN: Confirm ingredient values appear reasonable compared with vanilla oatmeal/rice source values.

---

## Open Questions

1. **Should the combined set be a union or an intersection?**
   Proposed decision: union. The user said porridge should draw ingredients from both rice and oatmeal, and the current problem is that one-template approaches exclude one side or the other.

2. **Should `Oatmeal` or `Rice` values win when both exist?**
   Proposed decision: `Oatmeal` wins for overlap items; otherwise use `Rice`.

3. **Should odd rice items be manually excluded?**
   Proposed decision: no manual pruning in the first implementation. Keep the implementation code-based and review oddities after testing.

---

## Notes and Risks

- This cycle intentionally replaces the DC 4 `Template = Rice` shortcut.
- The generated ingredient override file may be large because vanilla rice has many eligible ingredients.
- Overriding vanilla item definitions carries more compatibility risk than using a vanilla template.
- The benefit is that porridge finally gets a true custom ingredient set instead of being forced into one vanilla template.
- `PseudoPorridge` currently has older active DC1/DC2 planning documents marked `Work Complete`; this cycle is intentionally numbered DC5 and does not modify those documents.
- Per `mymods/PseudoPorridge/AGENTS.md`, implementation must not begin until explicitly requested after this DevCycle document is created.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Final Status:** Abandoned and reverted
**Phases Completed:** Implementation was attempted, then reverted.
**Work Deferred:** Future design needed for ingredient expansion without broad vanilla item overrides.

**Accomplishments:**
- Confirmed that a true custom $template template would require ingredient-side EvolvedRecipe entries.
- Confirmed that safe script-based item overrides require full copied item blocks because item scripts reset existing definitions.
- Generated and evaluated the Rice/Oatmeal union: 188 entries total, 36 oatmeal-only, 152 rice-derived, 0 overlap.
- Reverted active script changes after determining the override footprint was too large.

**Reverted Work:**
- Removed PseudoPorridgeIngredientOverrides.txt.
- Restored bowl, pan, and pot evolved recipes to Template = Rice from DC4.

**Metrics:**
- Active DC5 files added: 0
- Active DC5 recipe/template changes: 0
- In-game checks completed: 0

**Lessons / Notes:**
- Do not pursue the full item-block override approach for this problem unless the broad compatibility cost becomes acceptable.
- A future cycle should look for a smaller Lua/runtime registration hook or another low-override way to combine ingredient sets.


