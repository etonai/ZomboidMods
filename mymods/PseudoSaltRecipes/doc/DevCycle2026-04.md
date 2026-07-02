# DevCycle 2026-04: Fix regular glass jar fermented food models

**Status:** Work Complete
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Replace non-working `JarWhite` static models on regular glass-jar fermented foods with sealed vanilla preserved-food jar models.

---

## Goal

Fix the regular glass-jar food models in `PseudoSaltRecipes`. The PseudoKimchi fix showed that `JarWhite` is not a valid static/world model for a glass jar food item, even though it can be used as an icon. `PseudoSaltRecipes` has the same inherited pattern on its regular glass-jar fermented vegetables and regular glass-jar stew outputs.

Ed approved implementation after reviewing this DevCycle.

## Desired Outcome

All regular glass-jar fermented food items in `PseudoSaltRecipes` render with sealed jar models instead of missing or invalid `JarWhite` models. The implementation should follow the verified PseudoKimchi approach:

```txt
Icon = <vanilla preserved jar icon>,
WorldStaticModel = <vanilla sealed preserved-food jar model>,
```

and remove invalid lines like:

```txt
StaticModel = JarWhite,
```

The clay jar and glazed clay jar variants should remain unchanged unless implementation finds a concrete problem with them.

---

## Background

PseudoKimchi DC3 verified this pattern for glass jar kimchi:

```txt
Icon = JarGreen,
WorldStaticModel = JarFoodCabbage_Ground,
```

and removed:

```txt
StaticModel = JarWhite,
WorldStaticModel = JarWhite,
```

That fixed the same model family issue for a cabbage-based fermented food while keeping the item visually sealed. Open jar models such as `JarFoodGreen_Open` were explicitly rejected for Kimchi and should not be used for this cycle either.

---

## Affected File

Primary target:

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`

The source file was updated. The installed mod copy was not updated because the approval request to write outside the workspace was rejected.

---

## Affected Regular Glass-Jar Items

The following regular glass-jar fermented items currently use `Icon = JarWhite` and `StaticModel = JarWhite`:

| Fermented item | Display name |
|---|---|
| `LactoFermentedCabbage` | Jar of Sauerkraut |
| `LactoFermentedCucumber` | Jar of Fermented Cucumbers |
| `LactoFermentedCarrot` | Jar of Fermented Carrots |
| `LactoFermentedRadish` | Jar of Fermented Radishes |
| `LactoFermentedZucchini` | Jar of Fermented Zucchini |
| `LactoFermentedTurnip` | Jar of Fermented Turnip |
| `LactoFermentedBellPepper` | Jar of Fermented Bell Pepper |
| `LactoFermentedGarlic` | Jar of Fermented Garlic |

The following regular glass-jar stew outputs also use `Icon = JarWhite` and `StaticModel = JarWhite`:

| Stew item | Display name |
|---|---|
| `JarOfCabbageStew` | Jar of Salty Cabbage Stew |
| `JarOfPickledCucumberStew` | Jar of Fermented Cucumber Stew |
| `JarOfCarrotStew` | Jar of Fermented Carrot Stew |
| `JarOfRadishStew` | Jar of Fermented Radish Stew |
| `JarOfZucchiniStew` | Jar of Fermented Zucchini Stew |
| `JarOfTurnipStew` | Jar of Fermented Turnip Stew |
| `JarOfBellPepperStew` | Jar of Fermented Bell Pepper Stew |
| `JarOfGarlicStew` | Jar of Fermented Garlic Stew |

This cycle should focus on those 16 regular glass-jar items. Clay and glazed jar variants already use `ClayJar`, `ClayJar_Fired`, or `GlazedClayJar` models and are out of scope unless testing shows otherwise.

---

## Vanilla Evidence

Vanilla B42 sealed preserved vegetable jars use `WorldStaticModel` and generally omit `StaticModel`:

```txt
item CannedCabbage
{
    Icon = JarGreen,
    WorldStaticModel = JarFoodCabbage_Ground,
}
```

Other sealed preserved-food examples include:

| Vanilla item | Icon | Sealed model |
|---|---|---|
| `CannedBellPepper` | `JarBrown` | `JarFoodBellPeppers_Ground` |
| `CannedBroccoli` | `JarGreen` | `JarFoodBroccoli_Ground` |
| `CannedCabbage` | `JarGreen` | `JarFoodCabbage_Ground` |
| `CannedCarrots` | `JarBrown` | `JarFoodCarrots_Ground` |
| `CannedLeek` | `JarWhite` | `JarFoodLeeks_Ground` |
| `CannedPotato` | `JarWhite` | `JarFoodPotatoes_Ground` |
| `CannedRedRadish` | `JarBrown` | `JarFoodRadish_Ground` |
| `CannedTomato` | `JarBrown` | `JarFoodTomatoes_Ground` |

Open preserved-food jars use `JarFood*_Open` static/world models. Those are out of scope here because Ed wants sealed jar visuals.

---

## Proposed Model Mapping

Use direct vanilla matches when available and closest sealed analogues when there is no exact preserved-food jar in vanilla.

| PseudoSaltRecipes family | Proposed icon | Proposed sealed model | Confidence |
|---|---|---|---|
| Cabbage / sauerkraut | `JarGreen` | `JarFoodCabbage_Ground` | Direct vanilla match |
| Carrot | `JarBrown` | `JarFoodCarrots_Ground` | Direct vanilla match |
| Radish | `JarBrown` | `JarFoodRadish_Ground` | Direct vanilla match |
| Bell pepper | `JarBrown` | `JarFoodBellPeppers_Ground` | Direct vanilla match |
| Cucumber | `JarGreen` | `JarFoodCabbage_Ground` | Implemented closest green sealed jar analogue; no vanilla canned cucumber |
| Zucchini | `JarGreen` | `JarFoodBroccoli_Ground` | Implemented closest alternate green sealed jar analogue; no vanilla canned zucchini |
| Turnip | `JarWhite` | `JarFoodPotatoes_Ground` | Closest pale root vegetable jar |
| Garlic | `JarWhite` | `JarFoodLeeks_Ground` | Closest pale allium jar |

For each family, apply the selected mapping to both the fermented glass jar item and its glass jar stew output unless Ed decides the stew items should use a separate cooked/stew visual strategy.

---

## Tasks

### Phase 1: Confirm Scope and Mapping

**Status:** Work Complete

- [x] Re-read `PseudoSaltItems.txt` and confirm the complete list of regular glass-jar items using `StaticModel = JarWhite`.
- [x] Confirm all affected regular glass-jar items return `Base.EmptyJar` and are separate from clay/glazed jar variants.
- [x] Re-check vanilla sealed preserved-food model names in `media/scripts/generated/items/food.txt`.
- [x] Decide final model/icon mapping for cucumber, zucchini, turnip, and garlic where there is no exact vanilla preserved-food equivalent.
- [x] Confirm no `JarFood*_Open` model should be used in this cycle.

### Phase 2: Update Regular Glass-Jar Items

**Status:** Work Complete

- [x] Update `LactoFermentedCabbage` and `JarOfCabbageStew` using the cabbage sealed jar model.
- [x] Update `LactoFermentedCucumber` and `JarOfPickledCucumberStew` using the approved cucumber mapping.
- [x] Update `LactoFermentedCarrot` and `JarOfCarrotStew` using the carrot sealed jar model.
- [x] Update `LactoFermentedRadish` and `JarOfRadishStew` using the radish sealed jar model.
- [x] Update `LactoFermentedZucchini` and `JarOfZucchiniStew` using the approved zucchini mapping.
- [x] Update `LactoFermentedTurnip` and `JarOfTurnipStew` using the approved turnip mapping.
- [x] Update `LactoFermentedBellPepper` and `JarOfBellPepperStew` using the bell pepper sealed jar model.
- [x] Update `LactoFermentedGarlic` and `JarOfGarlicStew` using the approved garlic mapping.
- [x] Remove `StaticModel = JarWhite` from all affected regular glass-jar items.
- [x] Add or update `WorldStaticModel` with the approved sealed model for each affected item.
- [x] Leave clay/glazed jar items unchanged unless a concrete issue is found.

### Phase 3: Encoding and Installed-Copy Safety

**Status:** Work Complete

- [x] After editing, ensure `PseudoSaltItems.txt` is UTF-8 without BOM.
- [x] Check the first bytes of the edited file; it should start with `6D 6F 64 75` (`modu`) or another expected non-BOM script byte sequence.
- [ ] If updating the installed mod copy for testing, ensure that copy is also UTF-8 without BOM.
- [x] Document whether the installed copy was updated.

### Phase 4: Verification

**Status:** Work Complete

- [x] Read back the edited item script.
- [x] Check brace balance.
- [x] Confirm no `StaticModel = JarWhite` remains on regular glass-jar fermented/stew items.
- [x] Confirm no `JarFood*_Open` model was introduced.
- [x] Confirm clay/glazed jar model lines remain unchanged unless intentionally edited.
- [ ] Launch or ask Ed to launch with `PseudoSaltRecipes` enabled and verify regular glass-jar items render as sealed preserved-food jars.
- [x] Keep this DevCycle at `Work Complete` until Ed explicitly approves `Verified`.

---

## Notes and Risks

- Ed approved implementation; source changes are now complete.
- The key lesson from PseudoKimchi is that `JarWhite` should not be treated as a static/world model. It may remain an icon where vanilla uses it as an icon, but model fields should use sealed preserved-food model names.
- Some fermented foods did not have exact vanilla canned/preserved equivalents. Implemented mappings are recorded below.
- The regular glass-jar stew items may not represent sealed canned food perfectly, but using sealed jar models is still preferable to invalid `JarWhite` model references and keeps the visual language consistent with Ed's kimchi decision.
- Avoid open jar models in this cycle.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Completion Summary

**Completion Date:** 2026-07-01
**Status:** Work Complete
**Files modified:**

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`
- `mymods/PseudoSaltRecipes/doc/DevCycle2026-04.md`

**Implemented mappings:**

| Family | Icon | WorldStaticModel |
|---|---|---|
| Cabbage / sauerkraut | `JarGreen` | `JarFoodCabbage_Ground` |
| Cucumber | `JarGreen` | `JarFoodCabbage_Ground` |
| Carrot | `JarBrown` | `JarFoodCarrots_Ground` |
| Radish | `JarBrown` | `JarFoodRadish_Ground` |
| Zucchini | `JarGreen` | `JarFoodBroccoli_Ground` |
| Turnip | `JarWhite` | `JarFoodPotatoes_Ground` |
| Bell pepper | `JarBrown` | `JarFoodBellPeppers_Ground` |
| Garlic | `JarWhite` | `JarFoodLeeks_Ground` |

**Verification results:**

- Edited source file starts with `6D 6F 64 75` (`modu`), so no UTF-8 BOM is present.
- Brace balance passed: 62 opening braces and 62 closing braces.
- No `JarFood*_Open` model was introduced.
- No `StaticModel = JarWhite` remains in the edited `42` item file.
- Installed mod copy was not updated because the approval request to write outside the workspace was rejected.

**Work Deferred:**

- Installed-copy update for game testing.
- In-game render verification with `PseudoSaltRecipes` enabled.
- Ed approval before marking `Verified`.