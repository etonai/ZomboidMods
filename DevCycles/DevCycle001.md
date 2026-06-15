# DevCycle 001: Fix PseudoSaltRecipes for B42

**Status:** In Progress
**Start Date:** 2026-06-14
**Target Completion:** TBD
**Focus:** Port the PseudoSaltRecipes mod from B41 to B42 so it loads and functions correctly in-game.

---

## Goal

PseudoSaltRecipes was written for B41 and does not work in B42. This cycle covers identifying all B42 incompatibilities, applying the necessary fixes, and verifying that the mod loads cleanly and that its core recipes are functional in-game.

A prior session completed a first round of fixes (documented in `claudeDocs/claude_PseudoSaltRecipesPortingHandoff.md`). This cycle picks up from that state and drives the mod to a working, verified state.

## Desired Outcome

The mod loads without parse errors in B42. The salt-cured meat recipes and lacto-fermentation recipes are accessible and functional in-game. No console errors or crashes caused by this mod.

---

## Tasks

### Phase 1: Initial B42 Syntax Fixes

**Status:** Work Complete

- [x] Remove spaces from all 15 recipe names (PascalCase conversion)
- [x] Remove `OnCreate` callbacks (`CutFillet`, `CutChicken`, `CutAnimal`) — B41-only, removed in B42
- [x] Update tag syntax to `base:` namespace prefix and lowercase (`tags[base:sharpknife;base:meatcleaver]`)
- [x] Add missing `itemMapper` entry for `Base.Chicken` → `Pseudonymous.SaltedChicken` in `SaltMeatAnimalStyle`
- [x] Add `ItemType = base:food` to all 44 food items in `PseudoSaltItems.txt`
- [x] Add `versionMin=42.0` to `mod.info`

**Technical Notes:**
All fixes were derived by comparing against the working mod `notmymods/VanillaCraftableFoods/42/` and confirmed against vanilla game files in `media/scripts/generated/`. A parallel test mod (`mymods/PseudoTestRecipes/`) was used to isolate and verify each fix. Full discovery log is in `claudeDocs/claude_PseudoTestRecipesChangelog.md`.

---

### Phase 2: Load Verification and Remaining Issues

**Status:** Planning

- [ ] Load the mod in B42 and check the console for parse errors at startup
- [ ] Audit all `Tags =` lines in `PseudoSaltItems.txt` — confirm all use `base:` namespace prefix (e.g. `Tags = base:fishmeat`)
- [ ] Investigate fluid input syntax on fermentation recipes — see Open Questions below
- [ ] Verify `InheritFoodAge` flag is valid and functional in B42 fermentation recipes
- [ ] Determine whether `DisplayType` is required for jar/crock items in the crafting UI

**Technical Notes:**
Key files: `mymods/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`, `mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`. Reference working mod at `notmymods/VanillaCraftableFoods/42/` for valid B42 patterns.

---

## Open Questions

1. **Fluid input `mode:keep` on the wildcard container**
   Current: `item 1 [*] mode:keep,` — VanillaCraftableFoods never applies `mode:keep` to the `[*]` fluid container. This may be invalid in B42 and could silently prevent the recipe from appearing or functioning.
   Recommendation: Test removing `mode:keep` from the `[*]` container. If fermentation recipes still fail, this is a likely culprit.

2. **`TaintedWater` as a fluid input type**
   Current: `-fluid 1.0 [Water;TaintedWater]` — unconfirmed whether `TaintedWater` is a valid fluid identifier for recipe inputs in B42.
   Recommendation: Check `media/scripts/generated/` for valid fluid type names. If unconfirmed, reduce to `[Water]` only and restore later once confirmed.

---

## Notes and Risks

- The test mod (`mymods/PseudoTestRecipes/`) exists for isolated testing. Use it to verify syntax questions before modifying the main mod files.
- The `common/media/scripts/` directory contains old B41 files. They are not loaded by the game and should be left untouched.
- `claudeDocs/claude_PseudoSaltRecipesPortingHandoff.md` is the authoritative record of what was changed in Phase 1 and why.

---

## Completion Summary

*Fill in when the cycle closes.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Lessons / Notes:**
