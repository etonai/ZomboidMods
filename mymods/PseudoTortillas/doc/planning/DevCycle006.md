# DevCycle 006: Soft Taco Evolved Recipe Menu Duplication

**Status:** Planning
**Start Date:** 2026-07-02
**Target Completion:** TBD
**Focus:** Investigate and fix the Soft Taco evolved-recipe behavior where creating a Soft Taco becomes a vanilla taco and causes duplicate menu entries after the first ingredient is added.

---

## Goal

Fix the Soft Taco workflow so a tortilla-based soft taco does not turn into the same vanilla taco state that creates duplicate menu items after the first ingredient is added.

## Desired Outcome

Players can start with a vanilla tortilla, create a Soft Taco path, and continue adding ingredients without seeing duplicate or confusing taco menu entries. The recipe should preserve the intended soft taco identity, menu text, and behavior through the ingredient-addition flow.

---

## Problem Statement

The current evolved recipe is:

```text
module Base
{
    evolvedrecipe SoftTaco
    {
        BaseItem = Base.Tortilla,
        MaxItems = 5,
        ResultItem = Base.TacoRecipe,
        AddIngredientIfCooked = true,
        Name = Soft Taco,
        Template = Taco,
    }
}
```

In-game behavior shows that once a Soft Taco is created, it becomes a taco. After the first ingredient is added, the player sees two menu items. This suggests the Soft Taco evolved recipe is colliding with the vanilla taco evolved-recipe/template behavior, likely because it uses `ResultItem = Base.TacoRecipe` and/or `Template = Taco`.

The first fix attempt will be manual. This DevCycle documents the intended investigation and manual adjustment plan only.

---

## Tasks

### Phase 1: Reproduce and Characterize the Menu Duplication

**Status:** Planning

- [ ] Start with a vanilla `Base.Tortilla`.
- [ ] Use the current Soft Taco evolved recipe to add the first ingredient.
- [ ] Record the exact two menu entries that appear after the first ingredient is added.
- [ ] Confirm whether both menu entries route to the same `Base.TacoRecipe` item or to different evolved recipe definitions.
- [ ] Note whether the duplication appears only after the first ingredient or also on an empty tortilla.

### Phase 2: Compare Vanilla Taco Evolved Recipes

**Status:** Planning

- [ ] Inspect vanilla evolved recipe definitions for tacos and related tortilla/burrito recipes.
- [ ] Identify the vanilla `Taco` template behavior and its expected `BaseItem`, `ResultItem`, and display name handling.
- [ ] Determine whether `Template = Taco` automatically causes the Soft Taco path to inherit vanilla taco menu entries.
- [ ] Determine whether `ResultItem = Base.TacoRecipe` is the point where Soft Taco becomes indistinguishable from vanilla taco.

### Phase 3: Manual First Fix Attempt

**Status:** Planning

- [ ] Manually adjust the Soft Taco evolved recipe to avoid the duplicate menu behavior.
- [ ] Keep the first attempt intentionally small and reversible.
- [ ] Prefer a script-only change before adding new items or Lua behavior.
- [ ] Preserve the desired player-facing concept: tortilla plus ingredients creates a Soft Taco.
- [ ] Avoid changing raw tortilla creation or cooked tortilla behavior during this cycle.

### Phase 4: Test In Game

**Status:** Planning

- [ ] Deploy the manually adjusted mod with the project batch file.
- [ ] Load the game with PseudoTortillas enabled.
- [ ] Confirm the world loads without script errors.
- [ ] Create a Soft Taco from a tortilla and add at least one ingredient.
- [ ] Confirm only the intended menu entry appears after the first ingredient is added.
- [ ] Confirm continued ingredient additions still work.

### Phase 5: Document Result

**Status:** Planning

- [ ] Record the manual change that was attempted.
- [ ] Record whether the duplicate menu entry was fixed.
- [ ] Record any remaining issues or side effects.
- [ ] If successful, update this DevCycle to `Work Complete` pending user verification.
- [ ] If unsuccessful, document the next likely fix path.

---

## Notes and Risks

- The current Soft Taco definition intentionally uses `Template = Taco`, but this may be exactly what makes the result behave like the vanilla taco path.
- Using `ResultItem = Base.TacoRecipe` may make Soft Taco indistinguishable from the vanilla taco once the first ingredient is added.
- A cleaner final fix may require a dedicated soft taco result item, a distinct evolved recipe template, or a different naming/result strategy.
- This cycle is explicitly for the manual first attempt. Do not broaden the work into a full evolved-recipe framework unless the manual fix fails and the user approves that next step.

---

## Completion Summary

Not started. This DevCycle is a planning document for the manual first attempt to fix Soft Taco evolved-recipe menu duplication.