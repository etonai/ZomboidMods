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

### Phase 2: Incremental Port via PseudoTestRecipes

**Status:** Planning

`PseudoTestRecipes` currently contains only one recipe (`MakeSaltedFillet`) and is confirmed working in-game. `PseudoSaltRecipes` has 15 recipes and does not load cleanly. Rather than debugging the full mod directly, drive the rest of this cycle by porting recipes/items from `PseudoSaltRecipes` into `PseudoTestRecipes` one at a time, verifying in-game after each addition. The first recipe/item that breaks the test mod identifies the incompatibility; fix it in the test mod first, confirm it works, then carry the fix back to `PseudoSaltRecipes`.

**Process for each increment:**
1. Pick the next untested recipe (and its required items) from `PseudoSaltRecipes`.
2. Copy it into `PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` (and matching items into `PseudoTestItems.txt`).
3. Load the test mod in B42 and check the console for parse errors.
4. If it fails, isolate and fix the issue in the test mod; record the cause and fix in `claudeDocs/claude_PseudoTestRecipesChangelog.md`.
5. If it succeeds, mark the recipe as ported and move to the next one.
6. Once all recipes have been ported and verified individually in the test mod, apply the accumulated fixes to `PseudoSaltRecipes` and re-verify the full mod.

**Porting order and status:**
- [x] `MakeSaltedFillet` — already ported, confirmed working
- [ ] `SaltMeatChickenStyle` — ported into test mod, awaiting in-game load verification
- [ ] `SaltMeatAnimalStyle` — ported into test mod, awaiting in-game load verification
- [ ] `MakeSauerkraut` — ported into test mod (with `LactoFermentedCabbage` and `JarOfCabbageStew`), awaiting in-game load verification. First fermentation recipe — also exercises the fluid input and `mode:keep` open questions below.
- [ ] `MakeClayJarSauerkraut`
- [ ] `MakeGlazedJarSauerkraut`
- [ ] `MakeFermentedCucumbers`
- [ ] `MakeClayJarFermentedCucumbers`
- [ ] `MakeGlazedJarFermentedCucumbers`
- [ ] `MakeFermentedCarrots`
- [ ] `MakeClayJarFermentedCarrots`
- [ ] `MakeGlazedJarFermentedCarrots`
- [ ] `MakeFermentedRadishes`
- [ ] `MakeClayJarFermentedRadishes`
- [ ] `MakeGlazedJarFermentedRadishes`
- [ ] Backport all confirmed fixes to `PseudoSaltRecipes` and do a full-mod load verification

**Technical Notes:**
Key files: `mymods/PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`, `mymods/PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` (test mod — edit these first); `mymods/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`, `mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt` (main mod — receives fixes once confirmed). Reference working mod at `notmymods/VanillaCraftableFoods/42/` for valid B42 patterns.

---

## Open Questions

1. **Fluid input `mode:keep` on the wildcard container**
   Current: `item 1 [*] mode:keep,` — VanillaCraftableFoods never applies `mode:keep` to the `[*]` fluid container. This may be invalid in B42 and could silently prevent the recipe from appearing or functioning.
   Recommendation: Test in `PseudoTestRecipes` when porting `MakeSauerkraut` (the first fermentation recipe) — try removing `mode:keep` from the `[*]` container if it fails to load or appear.

2. **`TaintedWater` as a fluid input type**
   Current: `-fluid 1.0 [Water;TaintedWater]` — unconfirmed whether `TaintedWater` is a valid fluid identifier for recipe inputs in B42.
   Recommendation: Check `media/scripts/generated/` for valid fluid type names. Test in `PseudoTestRecipes` alongside the `mode:keep` question; if unconfirmed, reduce to `[Water]` only and restore later once confirmed.

---

## Notes and Risks

- The test mod (`mymods/PseudoTestRecipes/`) is the primary working surface for Phase 2. It currently loads cleanly with one recipe; recipes are ported into it one at a time (see Phase 2 porting order) rather than debugging the full `PseudoSaltRecipes` mod directly. Fixes are only backported to `PseudoSaltRecipes` once confirmed working in the test mod.
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
