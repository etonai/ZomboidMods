# DevCycle 2026-05: Remove duplicate meat salting recipe and add English translations

**Status:** Work Complete
**Start Date:** 2026-07-03
**Target Completion:** 2026-07-03
**Focus:** Clean up the duplicate meat salting recipe and add B42-style English translation files for `PseudoSaltRecipes`.

---

## Goal

Remove one redundant salting recipe from `PseudoSaltRecipes` and make the mod's English names explicit through translation files. `SaltMeatChickenStyle` currently overlaps with `SaltMeatAnimalStyle`, while the item display names still live only in the item script. This cycle should simplify the recipe list and bring the mod closer to the clean B42 translation pattern used by `PseudoSaltWell42_19`.

## Desired Outcome

`PseudoSaltRecipes` has one animal meat salting recipe path, with no duplicate recipe entry for the same salted rabbit/beef/steak/venison outputs. The mod also has English translation JSON files under `media/lua/shared/Translate/EN/`, with item names and recipe names mapped from the existing script values so the displayed English text is centralized and easy to maintain.

---

## Background

Current recipe file:

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`

Current item file:

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`

Reference translation style:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/Translate/EN/ContextMenu.json`

`PseudoSaltRecipes` had no `media/lua/shared/Translate/EN/` directory at cycle start. Other B42 mod folders in this workspace use JSON translation files such as `ItemName.json`, `Recipes.json`, `ContextMenu.json`, and `EvolvedRecipeName.json`.

---

## Tasks

### Phase 1: Remove Duplicate Meat Recipe

**Status:** Work Complete

- [x] Re-read `PseudoSaltRecipes.txt` and confirm the active recipe blocks for `SaltMeatChickenStyle` and `SaltMeatAnimalStyle`.
- [x] Remove the `SaltMeatChickenStyle` `craftRecipe` block.
- [x] Confirm `SaltMeatAnimalStyle` still covers the salted outputs that `SaltMeatChickenStyle` produced: `SaltedRabbitmeat`, `SaltedBeef`, `SaltedSteak`, and `SaltedVenison`.
- [x] Confirm `SaltMeatAnimalStyle` also continues to cover chicken, pork, turkey, mutton, small bird, and small animal meat outputs.
- [x] Check brace balance after the recipe block removal.

**Technical Notes:**
`SaltMeatChickenStyle` was misleadingly named and only mapped rabbit, beef, steak, and venison. `SaltMeatAnimalStyle` already maps those same base meats plus the broader animal-meat set, so keeping both produced duplicate salting choices for the shared meats.

Implemented in the active B42 recipe script only:

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`

Post-removal verification found `SaltMeatAnimalStyle` still maps:

- `Pseudonymous.SaltedRabbitmeat = Base.Rabbitmeat`
- `Pseudonymous.SaltedVenison = Base.Venison`
- `Pseudonymous.SaltedBeef = Base.Beef`
- `Pseudonymous.SaltedSteak = Base.Steak`
- `Pseudonymous.SaltedChickenFillet = Base.ChickenFillet`
- `Pseudonymous.SaltedChicken = Base.Chicken`
- `Pseudonymous.SaltedPork = Base.Pork`
- `Pseudonymous.SaltedPorkChop = Base.PorkChop`
- `Pseudonymous.SaltedTurkeyFillet = Base.TurkeyFillet`
- `Pseudonymous.SaltedMuttonChop = Base.MuttonChop`
- `Pseudonymous.SaltedSmallbirdmeat = Base.Smallbirdmeat`
- `Pseudonymous.SaltedSmallanimalmeat = Base.Smallanimalmeat`

Recipe brace balance after removal: 80 opening braces and 80 closing braces.

### Phase 2: Add English Translation Files

**Status:** Work Complete

- [x] Create `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/`.
- [x] Add `ItemName.json` entries for every item defined in `PseudoSaltItems.txt`, using the existing `DisplayName` values as the English text.
- [x] Add `Recipes.json` entries for every remaining `craftRecipe` in `PseudoSaltRecipes.txt`, using clear English recipe names.
- [x] Add `ContextMenu.json` only if implementation finds custom context menu keys or B42 recipe context keys that need it; otherwise document that no context menu translations were required.
- [x] Keep JSON formatting consistent with `PseudoSaltWell42_19`: simple object files, readable indentation, and no legacy `_EN.txt` translation format.
- [x] Validate each JSON file can be parsed.

**Technical Notes:**
Added translation files:

- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/ItemName.json`
- `mymods/PseudoSaltRecipes/PseudoSaltRecipes/42/media/lua/shared/Translate/EN/Recipes.json`

`ItemName.json` has 61 entries, matching all 61 items found in `PseudoSaltItems.txt`.

`Recipes.json` has 26 entries, matching all 26 remaining active B42 `craftRecipe` blocks after removing `SaltMeatChickenStyle`.

No `ContextMenu.json` was added because neither active B42 script contains `ContextMenu_` keys or custom Lua context menu translation keys. This follows the planned rule: add context-menu translations only when there are context-menu keys to translate.

Phase 2 covers all current item families:

- Salted fish and salted meats.
- Glass jar, clay jar, and glazed clay jar fermented vegetables.
- Matching cooked stew outputs for the fermented vegetable families.

No item IDs were renamed and no `DisplayName` lines were removed. Translation values mirror current `DisplayName` text.

### Phase 3: Verification and Documentation

**Status:** Work Complete

- [x] Read back the edited recipe script and translation files.
- [x] Confirm `SaltMeatChickenStyle` no longer appears in active B42 recipe scripts.
- [x] Confirm no duplicate salted meat recipe remains for rabbit, beef, steak, or venison.
- [x] Confirm every item ID from `PseudoSaltItems.txt` has an `ItemName.json` entry.
- [x] Confirm every remaining recipe ID from `PseudoSaltRecipes.txt` has a `Recipes.json` entry.
- [x] Confirm JSON syntax is valid.
- [x] Update this DevCycle with implementation notes, verification results, and any deferred in-game testing.

**Technical Notes:**
Do not mark this cycle `Verified` without Ed's explicit approval. File-level verification passed, so this cycle is recorded as `Work Complete` pending in-game/user verification.

Verification results:

| Check | Result |
|---|---:|
| `SaltMeatChickenStyle` present | No |
| `SaltMeatAnimalStyle` present | Yes |
| Recipe brace balance | Passed, 80 / 80 |
| Item script item IDs | 61 |
| `ItemName.json` entries | 61 |
| Missing item translations | 0 |
| Extra item translations | 0 |
| Active recipe IDs | 26 |
| `Recipes.json` entries | 26 |
| Missing recipe translations | 0 |
| Extra recipe translations | 0 |
| JSON parse check | Passed |
| Active `ContextMenu_` keys found | 0 |

---

## Open Questions

1. ~~**Should common-side scripts be updated too?**~~
   **Resolved:** This implementation updated only the active B42 path under `PseudoSaltRecipes/42/`. The `common/` copy was not changed because the cycle target and verification tasks were scoped to the B42 scripts.

2. ~~**Should translation files replace `DisplayName` lines or supplement them?**~~
   **Resolved:** Translation files supplement existing `DisplayName` lines for this cycle. Keeping `DisplayName` lines avoids unnecessary behavior risk while adding the B42-style translation layer.

---

## Notes and Risks

- `PseudoSaltRecipes` currently keeps its DevCycle documents directly in `doc/`, so this file follows that existing local convention rather than creating a new `doc/planning/` folder.
- Translation coverage was generated from the actual active B42 scripts.
- Recipe-name translation wording is intentionally plain and functional. Ed may still choose to revise display wording after in-game review.
- Installed-copy updates and in-game verification were not performed in this cycle.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Completion Summary

**Completion Date:** 2026-07-03
**Phases Completed:** All
**Work Deferred:** In-game verification and installed-copy update, if needed.

**Accomplishments:**
- Removed duplicate `SaltMeatChickenStyle` from the active B42 recipe script.
- Kept `SaltMeatAnimalStyle` as the single animal-meat salting recipe path.
- Added B42-style English `ItemName.json` translation coverage for all active mod items.
- Added B42-style English `Recipes.json` translation coverage for all remaining active recipes.
- Confirmed no context-menu translation file was needed for the current active B42 scripts.

**Metrics:**
- Files modified: 4
- Recipes removed: 1
- Translation entries added: 87 total, 61 item entries and 26 recipe entries

**Lessons / Notes:**
`SaltMeatChickenStyle` was not a chicken recipe in practice. It duplicated the rabbit, beef, steak, and venison subset already handled by `SaltMeatAnimalStyle`, so removing it simplifies the crafting surface without removing any salted meat output.