# DevCycle 005: PseudoTortillas Load Error Fix

**Status:** VERIFIED
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Backfill documentation for the load-error investigation and fix that made `RawTortilla` and the raw tortilla recipes appear and load correctly in-game.

---

## Goal

Fix the PseudoTortillas mod load failure where the game loaded the tortilla recipes but failed during world dictionary initialization because `Pseudonymous.RawTortilla` could not be resolved.

## Desired Outcome

The mod loads without the `Make4RawTortillas item not found: Pseudonymous.RawTortilla` error. `RawTortilla` is registered before the raw tortilla craft recipes resolve their outputs, and the deployed mod matches the workspace copy.

---

## Background

After DevCycle 004, the mod appeared in the active mod list but the raw tortilla item and recipes were not showing up in-game. A captured game log at `docs/console.txt` showed that PseudoTortillas was loading, but world loading later failed during recipe output resolution.

The relevant console error was:

```text
ScriptManager.PostWorldDictionaryInit> Exception thrown
java.lang.Exception: Make4RawTortillas item not found: Pseudonymous.RawTortilla at OutputMapper.getItem(OutputMapper.java:98).
```

This showed that the craft recipe script was being read, but `RawTortilla` was not available in the script manager when recipe outputs were resolved.

---

## Tasks

### Phase 1: Inspect Load Failure

**Status:** Verified

- [x] Reviewed `docs/console.txt` for PseudoTortillas-specific load errors.
- [x] Confirmed `PseudoTortillas` appeared in the mod load sequence.
- [x] Identified the blocking error as `Make4RawTortillas item not found: Pseudonymous.RawTortilla`.
- [x] Distinguished unrelated vanilla/other-mod warnings from the actual PseudoTortillas failure.

**Technical Notes:**
The important distinction was that the recipe script was loading far enough for `Make4RawTortillas` to exist, while `Pseudonymous.RawTortilla` was absent at `PostWorldDictionaryInit`. That narrowed the fix to item registration and script-load structure rather than recipe visibility filters.

### Phase 2: Add B42 Metadata and Broaden Water Matching

**Status:** Verified

- [x] Added `versionMin=42.0` to `PseudoTortillas/42/mod.info` to match the B42 packaging pattern used by PseudoSaltRecipes.
- [x] Changed raw tortilla water inputs from exact `[Water]` to `categories[Water] mode:mixture`.
- [x] Kept ingredient quantities and recipe outputs unchanged.

**Technical Notes:**
These compatibility changes were conservative. The water input change follows vanilla B42 recipe patterns that accept water-category fluid mixtures, while `versionMin=42.0` documents that this mod targets build 42.

### Phase 3: Co-locate RawTortilla With Recipes

**Status:** Verified

- [x] Moved the `RawTortilla` item definition into `PseudoTortillas/42/media/scripts/recipes/PseudoTortillasRecipes.txt` above the raw tortilla craft recipes.
- [x] Left `PseudoTortillas/42/media/scripts/items/PseudoTortillasItems.txt` as an empty `module Pseudonymous { }` placeholder to avoid duplicate item definitions.
- [x] Preserved the `Pseudonymous.RawTortilla` item ID so existing recipe references and translations remain stable.
- [x] Preserved the cooking behavior: `IsCookable = true`, `MinutesToCook = 4`, `MinutesToBurn = 20`, and `ReplaceOnCooked = Base.Tortilla`.

**Technical Notes:**
This was a tactical load-order/registration fix. By defining `RawTortilla` in the same script file before the craft recipes, the item is registered before recipe output resolution asks for `Pseudonymous.RawTortilla`.

The current working structure is intentionally documented here because it differs from the cleaner conceptual layout where item definitions live in `media/scripts/items/`.

### Phase 4: Deploy and Verify Copy

**Status:** Verified

- [x] Deployed the mod with `utilities\CopyModToZomboid.bat PseudoTortillas`.
- [x] Verified the deployed copy under `C:\Users\edwar\Zomboid\mods\PseudoTortillas` matched the workspace copy by hash comparison.
- [x] Confirmed the deployed recipe script contains `item RawTortilla` before `craftRecipe MakeRawTortilla`.
- [x] User confirmed the fix is working in-game.

---

## Notes and Risks

- `RawTortilla` currently lives in the recipe script file, not the item script file. This is working and intentionally documented, but it is less clean than the original file organization.
- A future cleanup DevCycle can investigate why `PseudoTortillasItems.txt` did not register the item reliably and move `RawTortilla` back to `media/scripts/items/` if the underlying cause is found.
- The old item file remains present as an empty module placeholder, so future editors should not assume `PseudoTortillasItems.txt` contains the active item definition.

---

## Completion Summary

The load failure was traced to recipe output resolution failing to find `Pseudonymous.RawTortilla`. The fix co-located the `RawTortilla` item definition with the raw tortilla craft recipes, before the recipes that reference it. The mod was deployed with the batch file, the deployed copy was verified against the workspace, and the user confirmed the mod is now working in-game.