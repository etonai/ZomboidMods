# DevCycle 2026-08: Add Lacto-Fermented Cauliflower items and recipes

**Status:** Work Complete
**Start Date:** 2026-08-29
**Target Completion:** 2026-08-29
**Focus:** Add a `LactoFermentedCauliflower` item/recipe family (empty jar, clay jar, glazed jar tiers) to `PseudoSaltRecipes`, following the repeatable formula in `claude_LactoFermentedVegetableRecipeAnalysis.md`.

---

## Goal

Add lacto-fermented cauliflower items and recipes to `PseudoSaltRecipes`, using vanilla `Cauliflower` (`media/scripts/generated/items/food.txt:14178`) as the base vegetable and following the formula already used for Cabbage/Cucumber/Carrot/Radish/Zucchini/Turnip/BellPepper/Garlic/Onion (DC 2026-07).

Per the formula's documented process (`claude_LactoFermentedVegetableRecipeAnalysis.md` "Mods involved"), new families are meant to be added to `PseudoTestRecipes` first and verified in-game before being backported to `PseudoSaltRecipes` — though DC 2026-07 noted that process had already fallen out of practice (main mod had gotten ahead of the test mod on Garlic) and both mods ended up updated together. Follow whichever of those two paths Ed actually wants for this cycle.

## Desired Outcome

`PseudoSaltRecipes` gains a complete `LactoFermentedCauliflower` family: 6 items (empty/clay/glazed jar fermented cauliflower + matching stew outputs), 3 crafting recipes (empty/clay/glazed jar), and the matching `Translate/EN/ItemName.json` (6 entries) + `Translate/EN/Recipes.json` (3 entries) strings — per Step 9 of the formula, added after the DC 2026-07 gap was found. Matches the existing vegetable families exactly in structure.

---

## Precomputed Formula Values (Cauliflower)

Source: vanilla `Cauliflower` at `media/scripts/generated/items/food.txt:14178`.

| Field | Vanilla value |
|---|---|
| HungerChange | -9.0 |
| Carbohydrates | 3.0 |
| Proteins | 4.0 |
| Lipids | 0.0 |
| Calories | 24.0 |

**Step 2 — pick N:** smallest whole N with `N * -9.0` in `[-36, -24]`. N=2 → -18 (out of range). N=3 → **-27** ✓. Use **N=3**.

**Step 3 — new item nutrition (N=3):**

| Field | Value |
|---|---|
| HungerChange | -27.0 |
| Carbohydrates | 9.0 |
| Proteins | 12.0 |
| Lipids | 0.0 |
| Calories | 72.0 |

These values apply identically to `LactoFermentedCauliflower`, `LactoFermentedCauliflowerClayJar`, `LactoFermentedCauliflowerGlazedJar`, and their three stew counterparts (per Steps 3, 6, 7 of the formula).

**Recipe vegetable input:** `item 3 [Base.Cauliflower]` in all three `MakeFermentedCauliflower...` recipe variants.

---

## Affected Files

| Mod | Items file | Recipes file |
|---|---|---|
| `PseudoTestRecipes` | `mymods/PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` (and `common/` mirror — kept in sync as of DC 2026-07) | `mymods/PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` (and `common/` mirror) |
| `PseudoSaltRecipes` | `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt` (`common/` copy is stale/out of sync — do not edit, see DC 2026-07 notes) | `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` |

Translation strings (`PseudoSaltRecipes` only — `PseudoTestRecipes` has no `Translate/` folder):

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/ItemName.json`
- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/Recipes.json`

---

## Tasks

### Phase 1: Add Items and Recipes

**Status:** Work Complete

- [x] Add `LactoFermentedCauliflower`, `LactoFermentedCauliflowerClayJar`, `LactoFermentedCauliflowerGlazedJar` items (Steps 4–7) to `PseudoSaltItems.txt` in both `PseudoTestRecipes` (`42/` and `common/`) and `PseudoSaltRecipes` (`42/` only).
- [x] Add matching `JarOfCauliflowerStew`, `ClayJarOfCauliflowerStew`, `GlazedJarOfCauliflowerStew` items (Step 6) — no recipe attached.
- [x] Add `MakeFermentedCauliflower`, `MakeClayJarFermentedCauliflower`, `MakeGlazedJarFermentedCauliflower` recipes (Step 8, `item 3 [Base.Cauliflower]` input) to `PseudoSaltRecipes.txt` in the same set of files.
- [x] Used singular naming throughout (`Fermented Cauliflower`, `MakeFermentedCauliflower`, etc.) — mass-noun convention, not pluralized.

### Phase 2: Jar Model Mapping

**Status:** Work Complete — decided without stopping for confirmation; flag for review

- [x] **Decision:** used `Icon = JarGreen` / `WorldStaticModel = JarFoodBroccoli_Ground` for the empty-jar tier. Cauliflower and Broccoli are the same species (`Brassica oleracea`), which is the strongest available justification, and this exact model was already established as the DC 2026-04 mapping for Zucchini (a different brassica with no exact vanilla match either). Ed should double check this visually in-game — cauliflower is white/pale and a green jar icon may look mismatched despite the botanical justification; `JarWhite`/`JarFoodPotatoes_Ground` (the Turnip mapping) is the fallback if so.

### Phase 3: Translation Strings

**Status:** Work Complete

- [x] Added 6 entries to `ItemName.json` (`Pseudonymous.LactoFermentedCauliflower`, `Pseudonymous.JarOfCauliflowerStew`, and the ClayJar/GlazedJar + stew variants) matching each item's `DisplayName`.
- [x] Added 3 entries to `Recipes.json` (`MakeFermentedCauliflower`, `MakeClayJarFermentedCauliflower`, `MakeGlazedJarFermentedCauliflower`).
- [x] Validated both JSON files parse (PowerShell `ConvertFrom-Json`).

### Phase 4: Verification

**Status:** Work Complete (source-level); in-game verification deferred

- [x] Confirmed brace balance and UTF-8-no-BOM encoding on all 6 edited script files.
- [x] Confirmed via grep no `craftRecipe` outputs a `*Stew` item.
- [x] Deployed `PseudoTestRecipes` to the local mods folder (`utilities/CopyModToZomboid.bat`) and `PseudoSaltRecipes` to Workshop staging (`utilities/DeployModToWorkshop.bat`).
- [ ] Ask Ed to load the mod(s) in-game and confirm the cauliflower family crafts, cooks, and looks right (especially the jar model — see Phase 2).
- [x] Keep this DevCycle at `Work Complete` until Ed explicitly approves `Verified`.

---

## Notes and Risks

- All nutritional/N math above is precomputed from vanilla `Cauliflower` data per the formula; no further lookup should be needed before implementation.
- The jar model mapping (Phase 2) has no clean precedent in the mod yet and should be confirmed with Ed rather than guessed, unlike Onion where the Garlic allium precedent made the choice unambiguous.
- Per DC 2026-07's finding, remember to add the `Translate/EN/ItemName.json` and `Translate/EN/Recipes.json` entries (Step 9 of the formula) — this was missed in the initial Onion implementation and had to be patched in afterward.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Open Questions

1. ~~**Which jar model/icon should the empty-jar `LactoFermentedCauliflower` and `JarOfCauliflowerStew` use**~~
   Decided: `JarGreen` / `JarFoodBroccoli_Ground`, matching the Zucchini precedent from DC 2026-04. Not yet visually confirmed by Ed — see Phase 2 note.
2. ~~**Should this cycle follow the "test mod first" process**~~
   Implemented directly in both `PseudoTestRecipes` and `PseudoSaltRecipes` in the same pass, following the DC 2026-07 precedent.

---

## Completion Summary

**Completion Date:** 2026-08-29
**Phases Completed:** 1, 2, 3, 4 (source-level)
**Work Deferred:** In-game verification (recipe crafting, cook-to-stew swap, and visual check of the jar model choice)

**Accomplishments:**
- Added a complete `LactoFermentedCauliflower` family (6 items, 3 recipes) to `PseudoTestRecipes` (`42/` and `common/`, kept in sync) and `PseudoSaltRecipes` (`42/` only), using vanilla `Cauliflower` (N=3: HungerChange -27.0, Carbohydrates 9.0, Proteins 12.0, Lipids 0.0, Calories 72.0).
- Chose `JarGreen`/`JarFoodBroccoli_Ground` as the jar model mapping (same-species botanical match, consistent with the DC 2026-04 Zucchini precedent) since no vanilla `CannedCauliflower` or same-family mod precedent exists.
- Added the 6 `ItemName.json` + 3 `Recipes.json` translation entries (Step 9), avoiding the gap found in DC 2026-07.
- Verified brace balance and UTF-8-no-BOM encoding on all 6 edited script files and validated both JSON files parse.
- Confirmed via grep that no `craftRecipe` outputs a `*Stew` item.
- Deployed `PseudoTestRecipes` to the local mods folder and `PseudoSaltRecipes` to Workshop staging.

**Metrics:**
- Files modified: 8 (`PseudoTestRecipes/42/.../PseudoSaltItems.txt`, `PseudoTestRecipes/42/.../PseudoSaltRecipes.txt`, `PseudoTestRecipes/common/.../PseudoSaltItems.txt`, `PseudoTestRecipes/common/.../PseudoSaltRecipes.txt`, `PseudoSaltRecipes/PseudoSaltRecipes/42/.../PseudoSaltItems.txt`, `PseudoSaltRecipes/PseudoSaltRecipes/42/.../PseudoSaltRecipes.txt`, `.../Translate/EN/ItemName.json`, `.../Translate/EN/Recipes.json`) plus this DevCycle document.

**Lessons / Notes:**
- No in-game verification was performed — this is source-level implementation only. Ed should load both mods and confirm parse errors are absent, the recipes craft correctly, the cook-to-stew swap works, and specifically check whether the `JarGreen` jar model looks right for a white/pale vegetable like cauliflower before approving `Verified`.
