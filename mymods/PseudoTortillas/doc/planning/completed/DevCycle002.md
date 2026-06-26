# DevCycle 002: Allow Lard in Raw Tortillas

**Status:** Work Complete
**Start Date:** 2026-06-26
**Target Completion:** TBD
**Focus:** Let the raw tortilla recipe accept vanilla baking-fat items as alternatives to butter.

---

## Goal

Update the `MakeRawTortillas` recipe so players can use vanilla baking-fat items for the fat component. This keeps the tortilla recipe aligned with B42 baking recipes that use `tags[base:bakingfat]`.

## Desired Outcome

The mod loads without script errors, and `MakeRawTortillas` accepts 3 units of any item tagged `base:bakingfat` while leaving the existing flour/cornflour, salt, water, output, and cooking behavior unchanged.

---

## Tasks

### Phase 1: Update the Fat Input

**Status:** Work Complete

- [x] Change the raw tortilla recipe fat input from `item 3 [Base.Butter]` to a 3-unit tag-based baking-fat input.
- [x] Implemented as `item 3 tags[base:bakingfat]`.
- [x] Leave flour/cornflour as `item 60 tags[base:flour]`.
- [x] Leave salt, water, and output count unchanged.

**Technical Notes:**
Vanilla `Base.Butter` is defined in `media/scripts/generated/items/food.txt:4535` and carries `Tags = base:bakingfat;base:minoringredient`. Vanilla `Base.Lard` is defined in `media/scripts/generated/items/food.txt:13200` and carries `Tags = base:bakingfat`. Several vanilla baking recipes use `tags[base:bakingfat]`, so this cycle should follow that broader vanilla pattern rather than listing individual fat items.

### Phase 2: Static Verification and Deploy

**Status:** Work Complete

- [x] Confirm `PseudoTortillasRecipes.txt` contains `item 3 tags[base:bakingfat]`.
- [x] Confirm no other recipe inputs or outputs changed.
- [x] Deploy the mod with `utilities/CopyModToZomboid.bat PseudoTortillas` after implementation.

**Technical Notes:**
The deploy batch mirrors `mymods/PseudoTortillas/PseudoTortillas` into the Project Zomboid mods folder and excludes docs. It may require permission because it writes outside the workspace.

---

## Open Questions

*None at cycle start.*

---

## Notes and Risks

- Do not mark this cycle `Verified` without Ed's explicit approval.
- Ed decided to use `tags[base:bakingfat]`, so the implementation should intentionally accept the same broad baking-fat family used by vanilla baking recipes.
- Per `mymods/PseudoTortillas/AGENTS.md`, agents should stop after creating this DevCycle document and wait for an explicit implementation request.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** 2026-06-26
**Phases Completed:** All implementation, static verification, and deployment tasks
**Work Deferred:** In-game verification is not recorded; do not mark Verified without Ed approval.

**Accomplishments:**
- Changed `MakeRawTortillas` to accept `item 3 tags[base:bakingfat]` instead of only `Base.Butter`.
- Deployed the updated mod with `utilities/CopyModToZomboid.bat PseudoTortillas`.

**Metrics:**
- Files modified: 2 (`PseudoTortillasRecipes.txt`, `DevCycle002.md`)
- Deployments: 1 successful robocopy deployment; 4 files copied, 0 failures

**Lessons / Notes:**
Static verification confirmed the recipe still uses 60 flour/cornflour units, 1 salt, 0.25 water, and outputs 4 raw tortillas; only the fat input changed.
