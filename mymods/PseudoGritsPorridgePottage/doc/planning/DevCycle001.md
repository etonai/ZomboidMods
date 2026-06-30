# DevCycle 001: Combine Grits, Porridge, and Pease Pottage

**Status:** Verified
**Start Date:** 2026-06-30
**Target Completion:** 2026-06-30
**Focus:** Combine PseudoGrits, PseudoPorridge, and PseudoPeasePottage into one mod.

---

## Goal

Create a single Project Zomboid B42 mod, `PseudoGritsPorridgePottage`, that contains the working content from:

- `PseudoGrits`
- `PseudoPorridge`
- `PseudoPeasePottage`

The combined mod should preserve the behavior of the three separate mods while giving players one mod to enable instead of three.

## Desired Outcome

Players can enable `PseudoGritsPorridgePottage` and get all recipes, items, evolved recipes, translations, and expected gameplay behavior from the three source mods.

Expected behavior:

- Grits content works as it does in the current `PseudoGrits` mod.
- Porridge content works as it does in the current `PseudoPorridge` mod.
- Pease pottage content works as it does in the current `PseudoPeasePottage` mod.
- The combined mod has its own `mod.info`, poster, script files, translation files, and folder structure.
- Item, recipe, evolved recipe, and translation keys do not conflict with each other.
- The combined mod can be tested independently without requiring the three source mods to be enabled.

---

## Tasks

### Phase 1: Source Mod Inventory

**Status:** Verified

- [x] Identify the active script files, translation files, poster, and metadata used by `PseudoGrits`.
- [x] Identify the active script files, translation files, poster, and metadata used by `PseudoPorridge`.
- [x] Identify the active script files, translation files, poster, and metadata used by `PseudoPeasePottage`.
- [x] Note any completed DevCycle behavior that must be preserved, especially sweet/savory evolved recipe behavior for grits and porridge.

### Phase 2: Combined Mod Structure

**Status:** Verified

- [x] Confirm the `PseudoGritsPorridgePottage/42` mod folder structure.
- [x] Create or update the required `media/scripts` subdirectories.
- [x] Create or update the required `media/lua/shared/Translate/EN` subdirectories.
- [x] Keep the combined mod independent from the three source mod folders.

### Phase 3: Script Merge

**Status:** Verified

- [x] Copy or merge grits item definitions into the combined mod.
- [x] Copy or merge grits craft recipes into the combined mod.
- [x] Copy or merge grits evolved recipes into the combined mod.
- [x] Copy or merge porridge item definitions into the combined mod.
- [x] Copy or merge porridge craft recipes into the combined mod.
- [x] Copy or merge porridge evolved recipes into the combined mod.
- [x] Copy or merge pease pottage item definitions into the combined mod.
- [x] Copy or merge pease pottage craft recipes into the combined mod.
- [x] Copy or merge pease pottage evolved recipes into the combined mod.
- [x] Preserve module names and item IDs unless a conflict requires an intentional rename.

### Phase 4: Translation Merge

**Status:** Verified

- [x] Merge EN item name translations.
- [x] Merge EN recipe translations.
- [x] Merge EN evolved recipe name translations.
- [x] Merge EN context menu translations.
- [x] Confirm JSON syntax remains valid after merging.
- [x] Confirm visible names stay clear and consistent with the source mods.

### Phase 5: Metadata and Packaging

**Status:** Verified

- [x] Review `mod.info` name, id, poster, and description.
- [x] Confirm the mod ID remains `PseudoGritsPorridgePottage`.
- [x] Confirm the Workshop-facing name clearly communicates the included foods.
- [x] Confirm the poster is present and appropriate for the combined mod.
- [x] Update README or local documentation if needed.

### Phase 6: Static Checks

**Status:** Verified

- [x] Confirm all expected script files exist in the combined mod.
- [x] Confirm all expected translation files exist in the combined mod.
- [x] Confirm item, recipe, and evolved recipe blocks have balanced braces.
- [x] Confirm EN translation JSON files parse.
- [x] Search for accidental references to source mod folders or obsolete generated files.
- [x] Confirm no source mod files were modified while building the combined mod.

### Phase 7: In-Game Verification

**Status:** Verified

- [x] Launch Project Zomboid B42 with only `PseudoGritsPorridgePottage` enabled.
- [x] Confirm the game loads without script or translation errors.
- [x] Confirm grits recipes and evolved recipe behavior work.
- [x] Confirm porridge recipes and evolved recipe behavior work.
- [x] Confirm pease pottage recipes and evolved recipe behavior work.
- [x] Confirm the three original separate mods are not required for the combined mod to function.

---

## Notes and Risks

- This cycle is about combining existing working mods, not redesigning their gameplay.
- The source mods should remain unchanged unless Ed explicitly requests changes to them.
- Scripts were copied into the combined mod under their original source filenames to keep provenance clear.
- Translation JSON files were merged because the game expects one EN file per translation category in this mod folder.
- The combined mod keeps the `Pseudonymous` module and existing item IDs from the source mods.
- `mod.info` was corrected from `Peas Pottage` to `Pease Pottage` for consistency with source content.
- Ed explicitly approved marking this cycle Verified on 2026-06-30.

---

## Completion Summary

**Completion Date:** 2026-06-30
**Verification Date:** 2026-06-30
**Phases Completed:** Phases 1-7
**Work Deferred:** None.

**Accomplishments:**
- Created the combined script and translation folder structure.
- Copied grits, porridge, and pease pottage item, craft recipe, and evolved recipe script files into the combined mod.
- Merged EN item, recipe, evolved recipe name, and context menu translations.
- Corrected combined mod metadata spelling to `Pease Pottage`.
- Replaced the template README with a README for `PseudoGritsPorridgePottage`.

**Verification:**
- Static file presence checks passed.
- Translation JSON parse checks passed.
- Script brace balance checks passed.
- Ed approved declaring DC 1 verified.
