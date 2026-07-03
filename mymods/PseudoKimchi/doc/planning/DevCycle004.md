# DevCycle 004: English Translation Files

**Status:** Verified
**Start Date:** 2026-07-02
**Target Completion:** 2026-07-02
**Focus:** Add `media/lua/shared/Translate/EN` JSON files for PseudoKimchi using `PseudoGritsPorridgePottage` as the working example.

---

## Goal

Add English translation JSON files to `PseudoKimchi` so item names, craft recipe names, and evolved recipe ingredient names are defined through the B42 translation system instead of relying only on inline script display fields.

Use `mymods/PseudoGritsPorridgePottage/` as the reference for folder structure, file names, JSON shape, key naming, and formatting.

## Desired Outcome

`PseudoKimchi` has clean English translation files under:

```txt
PseudoKimchi/42/media/lua/shared/Translate/EN/
```

The files should load without translation parser errors, should be UTF-8 without BOM, and should cover all current PseudoKimchi player-facing item and recipe names.

---

## Reference Mod

Primary reference:

- `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/lua/shared/Translate/EN/ItemName.json`
- `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/lua/shared/Translate/EN/Recipes.json`
- `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/lua/shared/Translate/EN/EvolvedRecipeName.json`
- `mymods/PseudoGritsPorridgePottage/PseudoGritsPorridgePottage/42/media/lua/shared/Translate/EN/ContextMenu.json`

PseudoKimchi needed `ItemName.json`, `Recipes.json`, and `EvolvedRecipeName.json`. `ContextMenu.json` was checked during implementation and was not added because PseudoKimchi does not currently own any custom context-menu keys.

---

## Target PseudoKimchi Scripts

Item source:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`

Recipe source:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/recipes/PseudoKimchiRecipes.txt`

Current item ids:

| Item key | English text |
|---|---|
| `Pseudonymous.KentuckyKimchi` | `Jar of Kentucky Kimchi` |
| `Pseudonymous.KentuckyKimchiClayJar` | `Clay Jar of Kentucky Kimchi` |
| `Pseudonymous.KentuckyKimchiGlazedJar` | `Glazed Jar of Kentucky Kimchi` |

Current recipe ids:

| Recipe key | English text |
|---|---|
| `MakeKentuckyKimchi` | `Make Jar of Kentucky Kimchi` |
| `MakeClayJarKentuckyKimchi` | `Make Clay Jar of Kentucky Kimchi` |
| `MakeGlazedJarKentuckyKimchi` | `Make Glazed Jar of Kentucky Kimchi` |

Current evolved recipe ingredient display text:

| Item key | English text |
|---|---|
| `Pseudonymous.KentuckyKimchi` | `Kentucky Kimchi` |
| `Pseudonymous.KentuckyKimchiClayJar` | `Kentucky Kimchi` |
| `Pseudonymous.KentuckyKimchiGlazedJar` | `Kentucky Kimchi` |

---

## Implemented Files

Created:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/ItemName.json`
- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/Recipes.json`
- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/EvolvedRecipeName.json`

Not created:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/ContextMenu.json`

`ContextMenu.json` was not added. Vanilla already provides the general evolved recipe menu keys for `Soup`, `Stew`, `Stir fry`, `Sandwich`, `Burger`, `Salad`, `Taco`, and `Burrito`.

---

## Implemented Translation Content

### `ItemName.json`

```json
{
  "Pseudonymous.KentuckyKimchi": "Jar of Kentucky Kimchi",
  "Pseudonymous.KentuckyKimchiClayJar": "Clay Jar of Kentucky Kimchi",
  "Pseudonymous.KentuckyKimchiGlazedJar": "Glazed Jar of Kentucky Kimchi"
}
```

### `Recipes.json`

```json
{
  "MakeKentuckyKimchi": "Make Jar of Kentucky Kimchi",
  "MakeClayJarKentuckyKimchi": "Make Clay Jar of Kentucky Kimchi",
  "MakeGlazedJarKentuckyKimchi": "Make Glazed Jar of Kentucky Kimchi"
}
```

### `EvolvedRecipeName.json`

```json
{
  "Pseudonymous.KentuckyKimchi": "Kentucky Kimchi",
  "Pseudonymous.KentuckyKimchiClayJar": "Kentucky Kimchi",
  "Pseudonymous.KentuckyKimchiGlazedJar": "Kentucky Kimchi"
}
```

---

## Tasks

### Phase 1: Confirm Translation Scope

**Status:** Verified

- [x] Re-read the PseudoKimchi item and recipe scripts before editing.
- [x] Re-check the `PseudoGritsPorridgePottage` translation JSON examples.
- [x] Confirm the exact translation keys for item names, craft recipes, and evolved recipe ingredient names.
- [x] Confirm whether `ContextMenu.json` is unnecessary for this cycle.

**Implementation Notes:**
Confirmed that the current mod only needs item name, craft recipe, and evolved recipe ingredient translations. No custom PseudoKimchi context-menu keys were found or added.

### Phase 2: Add EN Translation Files

**Status:** Verified

- [x] Create the `PseudoKimchi/42/media/lua/shared/Translate/EN/` directory tree if it does not already exist.
- [x] Add `ItemName.json` with all three PseudoKimchi item display names.
- [x] Add `Recipes.json` with all three PseudoKimchi craft recipe names.
- [x] Add `EvolvedRecipeName.json` with all three PseudoKimchi evolved recipe ingredient names.
- [x] Keep JSON formatting consistent with `PseudoGritsPorridgePottage`.
- [x] Avoid adding unrelated translation files or placeholder keys.

**Implementation Notes:**
Added exactly three translation files under `PseudoKimchi/42/media/lua/shared/Translate/EN/`. No `ContextMenu.json` file was added.

### Phase 3: Encoding and Parser Safety

**Status:** Verified

- [x] Ensure every new translation JSON file is UTF-8 without BOM.
- [x] Confirm each file begins with `{` as the first byte.
- [x] Parse each JSON file locally.
- [x] Check for trailing commas or malformed JSON.

**Verification Notes:**
All three new files begin with `7B 0A 20 20`, parse successfully with PowerShell `ConvertFrom-Json`, and contain three keys each.

### Phase 4: Verification

**Status:** Verified

- [x] Read back all new translation files.
- [x] Confirm the keys match current item and recipe ids exactly.
- [x] Confirm no existing PseudoKimchi item, recipe, model, or balance behavior was changed.
- [x] Launch or ask Ed to launch with PseudoKimchi enabled and check `console.txt` for translation-loader errors.
- [x] Ed approved DC4 as complete, so this DevCycle is marked `Verified`.

---

## Notes and Risks

- Ed explicitly requested implementation of DC4.
- PseudoKimchi DC2 already showed that B42's translation loader is sensitive to malformed leading bytes. New JSON files were written brace-first without a UTF-8 BOM.
- Inline `DisplayName` and `EvolvedRecipeName` script fields remain in place unless testing shows they conflict with translation files.
- Ed approved DC4 as complete on 2026-07-02.

---

## Completion Summary

**Completion Date:** 2026-07-02
**Status:** Verified
**Files modified:**

- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/ItemName.json`
- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/Recipes.json`
- `mymods/PseudoKimchi/PseudoKimchi/42/media/lua/shared/Translate/EN/EvolvedRecipeName.json`
- `mymods/PseudoKimchi/doc/planning/DevCycle004.md`

**Accomplishments:**

- Added English item name translations for all three Kentucky Kimchi jar items.
- Added English craft recipe translations for all three Kentucky Kimchi recipes.
- Added evolved recipe ingredient translations for all three Kentucky Kimchi jar items.
- Left `ContextMenu.json` uncreated because no PseudoKimchi-owned context-menu key is currently needed.
- Verified the new translation files parse as JSON and are brace-first UTF-8 without BOM.

**Work Deferred:**

- Installed-copy update for game testing, if needed.
- Completed by Ed before marking this cycle `Verified`.