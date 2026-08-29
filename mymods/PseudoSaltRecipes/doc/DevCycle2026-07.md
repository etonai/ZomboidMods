# DevCycle 2026-07: Add Lacto-Fermented Onion items and recipes

**Status:** Work Complete
**Start Date:** 2026-08-28
**Target Completion:** 2026-08-28
**Focus:** Add a `LactoFermentedOnion` item/recipe family (empty jar, clay jar, glazed jar tiers) to `PseudoSaltRecipes`, following the repeatable formula in `claude_LactoFermentedVegetableRecipeAnalysis.md`.

---

## Goal

Add lacto-fermented onion items and recipes to `PseudoSaltRecipes`, using vanilla `Onion` (`media/scripts/generated/items/food.txt:14510`) as the base vegetable and following the formula already used for Cabbage/Cucumber/Carrot/Radish/Zucchini/Turnip/BellPepper/Garlic.

Per the formula's documented process (`claude_LactoFermentedVegetableRecipeAnalysis.md` "Mods involved"), the new item/recipe family should be added to `PseudoTestRecipes` first and verified in-game before being backported to `PseudoSaltRecipes`.

## Desired Outcome

`PseudoSaltRecipes` (and its `PseudoTestRecipes` staging copy) gain a complete `LactoFermentedOnion` family: 6 items (empty/clay/glazed jar fermented onion + matching stew outputs) and 3 crafting recipes (empty/clay/glazed jar), matching the existing vegetable families exactly in structure.

---

## Precomputed Formula Values (Onion)

Source: vanilla `Onion` at `media/scripts/generated/items/food.txt:14510`.

| Field | Vanilla value |
|---|---|
| HungerChange | -10.0 |
| Carbohydrates | 6.54 |
| Proteins | 0.77 |
| Lipids | 0.07 |
| Calories | 28.0 |

**Step 2 — pick N:** smallest whole N with `N * -10.0` in `[-36, -24]`. N=2 → -20 (out of range). N=3 → **-30** ✓. Use **N=3**.

**Step 3 — new item nutrition (N=3):**

| Field | Value |
|---|---|
| HungerChange | -30.0 |
| Carbohydrates | 19.62 |
| Proteins | 2.31 |
| Lipids | 0.21 |
| Calories | 84.0 |

These values apply identically to `LactoFermentedOnion`, `LactoFermentedOnionClayJar`, `LactoFermentedOnionGlazedJar`, and their three stew counterparts (per Steps 3, 6, 7 of the formula).

**Recipe vegetable input:** `item 3 [Base.Onion]` in all three `MakeFermentedOnions` recipe variants.

---

## Affected Files

Per the formula's two-mod process, work happens in `PseudoTestRecipes` first, then is backported to `PseudoSaltRecipes`:

| Mod | Items file | Recipes file |
|---|---|---|
| `PseudoTestRecipes` | `mymods/PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` | `mymods/PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` |
| `PseudoSaltRecipes` | `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt` | `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` |

Note: `PseudoSaltRecipes` also has a `common/` mirror of each file (`mymods/PseudoSaltRecipes/PseudoSaltRecipes/common/media/scripts/...`) alongside the `42/` copy. **Resolved during implementation:** that `common/` copy is already stale relative to `42/` (different `MinutesToCook`/`MinutesToBurn` values, missing the DC 2026-04 `JarWhite` model fix, no Garlic entries at all) — it is not being kept in sync, so it was left untouched, matching the DC 2026-04 precedent of only editing `42/` for this mod. By contrast, `PseudoTestRecipes/42/` and `PseudoTestRecipes/common/` were byte-identical before this cycle, so **both** copies were updated there to preserve that mod's existing parity.

---

## Tasks

### Phase 1: Add to PseudoTestRecipes

**Status:** Work Complete

- [x] Add `LactoFermentedOnion`, `LactoFermentedOnionClayJar`, `LactoFermentedOnionGlazedJar` items (Steps 4–7) to `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt`.
- [x] Add matching `JarOfOnionStew`, `ClayJarOfOnionStew`, `GlazedJarOfOnionStew` items (Step 6) — no recipe attached.
- [x] Add `MakeFermentedOnions`, `MakeClayJarFermentedOnions`, `MakeGlazedJarFermentedOnions` recipes (Step 8) to `PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`.
- [x] Mirror the same item/recipe additions into the `PseudoTestRecipes/common/` copies (confirmed they were kept in sync with `42/` before this cycle).

### Phase 2: In-Game Verification (Test Mod)

**Status:** Not started — deferred

- [ ] Load `PseudoTestRecipes`, confirm no script parse errors.
- [ ] Craft each jar tier of `LactoFermentedOnion` and confirm the recipe consumes the expected inputs (jar, 3 onions, salt, water) and produces the correct output item.
- [ ] Cook a fermented onion jar item and confirm it swaps to the correct stew item via `ReplaceOnCooked`.

### Phase 3: Backport to PseudoSaltRecipes

**Status:** Work Complete

- [x] Mirror the items into `PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`. (`common/` copy intentionally left untouched — see note above.)
- [x] Mirror the recipes into `PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`.
- [x] Re-checked brace balance and file encoding (UTF-8, no BOM) after editing, per the pattern used in DC 2026-04.

**Note:** Ed asked to implement directly rather than gating this cycle on in-game verification of the test mod first, so Phase 3 was done in parallel with Phase 1 rather than strictly after Phase 2 passed. Phase 2 (in-game verification) is deferred until Ed runs it.

### Phase 4: Verification (Main Mod)

**Status:** Work Complete (source-level); in-game verification deferred

- [x] Confirmed no `craftRecipe` was accidentally added for a `*Stew` item (stew items are cook-swap only, never crafted directly — see formula Step 8 "Stew items get no craftRecipe of their own"). Grep on the recipe file confirms outputs are only `LactoFermentedOnion`/`LactoFermentedOnionClayJar`/`LactoFermentedOnionGlazedJar`.
- [ ] Ask Ed to load `PseudoSaltRecipes` and confirm the onion family behaves the same as it did in the test mod.
- [x] Keep this DevCycle at `Work Complete` until Ed explicitly approves `Verified`.

---

## Notes and Risks

- All nutritional/N math above is precomputed from vanilla `Onion` data per the formula in `claude_LactoFermentedVegetableRecipeAnalysis.md`.
- DC 2026-04 revealed regular glass-jar fermented items should use a sealed vanilla preserved-food jar model (`Icon`/`WorldStaticModel`) rather than `JarWhite` as a static model, and there is no vanilla `CannedOnion` in that mapping table. **Resolved:** since `LactoFermentedGarlic` (already in `PseudoSaltRecipes`) is also an allium with no exact vanilla match and uses `Icon = JarWhite` / `WorldStaticModel = JarFoodLeeks_Ground`, the empty-jar `LactoFermentedOnion` and `JarOfOnionStew` reuse that same mapping as the closest allium analogue.
- The formula document's stated file paths for `PseudoSaltRecipes` (`mymods/PseudoSaltRecipes/42/media/scripts/...`) do not match the actual on-disk layout confirmed for this cycle (`mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/...`, plus a parallel `common/` copy) — the paths in **Affected Files** above were used instead.
- `PseudoTestRecipes` had already fallen behind `PseudoSaltRecipes` before this cycle started: the main mod already had a `LactoFermentedGarlic` family that had never been ported to the test mod, meaning the "test mod first" backport process documented in the formula was already not being followed in practice. The Onion family was added to both mods in the same pass.
- **Gap found and fixed after initial implementation:** the formula document (`claude_LactoFermentedVegetableRecipeAnalysis.md`) does not mention `Translate/EN/ItemName.json` or `Translate/EN/Recipes.json`, so the first implementation pass missed them. `PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/` has both files, keyed by full item ID (`Pseudonymous.LactoFermentedOnion` etc.) and bare recipe name (`MakeFermentedOnions` etc.) — every prior vegetable family has entries there, so the 6 item + 3 recipe entries for Onion were added to match, then the Workshop staging deploy was re-run. `PseudoTestRecipes` has no `Translate/` folder at all, so it was not affected by this gap. The formula document should probably be updated with a "Step 9: Translation strings" section so this isn't missed again for the next vegetable.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Open Questions

All resolved during implementation — see **Notes and Risks** above.

---

## Completion Summary

**Completion Date:** 2026-08-28
**Phases Completed:** 1, 3, 4 (source-level)
**Work Deferred:** Phase 2 and the in-game verification portion of Phase 4

**Accomplishments:**
- Added a complete `LactoFermentedOnion` family (6 items, 3 recipes) to both `PseudoTestRecipes` (`42/` and `common/`) and `PseudoSaltRecipes` (`42/` only — see `common/` note above), using vanilla `Onion` (N=3: HungerChange -30.0, Carbohydrates 19.62, Proteins 2.31, Lipids 0.21, Calories 84.0).
- Reused the `LactoFermentedGarlic` jar-model mapping (`Icon = JarWhite`, `WorldStaticModel = JarFoodLeeks_Ground`) for the empty-jar Onion tier as the closest allium precedent, since no vanilla `CannedOnion` exists.
- Verified brace balance and UTF-8-no-BOM encoding on all four edited files.
- Confirmed via grep that no `craftRecipe` outputs a `*Stew` item.

**Metrics:**
- Files modified: 6 (`PseudoTestRecipes/42/.../PseudoSaltItems.txt`, `PseudoTestRecipes/42/.../PseudoSaltRecipes.txt`, `PseudoTestRecipes/common/.../PseudoSaltItems.txt`, `PseudoTestRecipes/common/.../PseudoSaltRecipes.txt`, `PseudoSaltRecipes/PseudoSaltRecipes/42/.../PseudoSaltItems.txt`, `PseudoSaltRecipes/PseudoSaltRecipes/42/.../PseudoSaltRecipes.txt`) plus this DevCycle document.

**Lessons / Notes:**
- No in-game verification was performed — this is source-level implementation only. Ed should load both mods and confirm parse errors are absent, the recipes craft correctly, and the cook-to-stew swap works before approving `Verified`.
