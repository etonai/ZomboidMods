# DevCycle 002: Translation JSON Load Crash Fix

**Status:** Work Complete
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Diagnose and fix the translation JSON load crash reported while enabling PseudoKimchi in `docs/console.txt`.

---

## Goal

Fix the startup/load crash reported with PseudoKimchi enabled. The console log shows Project Zomboid loading `PseudoKimchi` and then failing inside the B42 translation loader with:

```txt
Caused by: org.json.JSONException: A JSONObject text must begin with '{' at 1 [character 2 line 1]
    zombie.core.Translator.tryFillMapFromFile(Translator.java:274)
    zombie.core.Translator.tryFillMapFromMods(Translator.java:298)
```

This indicates that one of the enabled mod translation files was not acceptable to B42's JSON loader. The crash appeared immediately after `loading PseudoKimchi`, but implementation found the malformed leading bytes in an already-enabled dependency/mod-set file rather than in PseudoKimchi's own source files.

## Desired Outcome

The enabled mod set used with PseudoKimchi no longer contains translation JSON files with malformed leading bytes. PseudoKimchi remains unchanged unless an actual malformed PseudoKimchi translation file is found.

---

## Evidence From Console Log

Relevant log sequence from `docs/console.txt`:

- `LOG  : Mod f:0> loading PseudoKimchi`
- `LOG  : General f:0> texturepack: loading pseudoed_salt_03`
- `ERROR: General f:0> KahluaThread.luaMainloop> Exception thrown`
- `Caused by: org.json.JSONException: A JSONObject text must begin with '{' at 1 [character 2 line 1]`
- Stack enters `zombie.core.Translator.tryFillMapFromFile` and `zombie.core.Translator.tryFillMapFromMods`.

Local investigation findings:

- `mymods/PseudoKimchi/PseudoKimchi/42/` contains item and recipe scripts, but no `media/lua/shared/Translate/.../*.json` files.
- The installed copy at `C:/Users/edwar/Zomboid/mods/PseudoKimchi/` also contains no translation JSON files.
- B42 `zombie42_19/core/Translator.java` probes `media/lua/shared/Translate/<LANG>/<Name>.json` in every enabled mod common/version directory.
- Installed enabled-mod translation JSON files parsed successfully, but byte-level inspection found a UTF-8 BOM at the start of `C:/Users/edwar/Zomboid/mods/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`.
- The matching workspace source file also had the same BOM: `mymods/PseudoTortillas/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`.

---

## Tasks

### Phase 1: Locate the Malformed Translation File

**Status:** Work Complete

- [x] Search the active deployed PseudoKimchi mod folder used by the game for `media/lua/shared/Translate/` files.
- [x] Search the source tree again for any newly added `.json` files before implementation.
- [x] Identify any enabled-mod translation JSON file whose first bytes are not clean brace-first UTF-8.
- [x] Check common copied-template mistakes, including files that are valid-looking JSON but begin with a BOM.
- [x] Record the exact bad file path in this DevCycle before editing it.

**Implementation Notes:**
No malformed PseudoKimchi translation file was found. The bad leading bytes were found in the enabled mod set at:

- `C:/Users/edwar/Zomboid/mods/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`
- `mymods/PseudoTortillas/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`

Both files began with `EF BB BF 7B`, meaning a UTF-8 BOM appeared before the opening `{`.

### Phase 2: Fix or Remove Invalid Translation Files

**Status:** Work Complete

- [x] Remove malformed leading bytes from the identified translation JSON file.
- [x] Apply the same correction to the workspace source file and the installed copy loaded by the game.
- [x] Do not add unnecessary PseudoKimchi translation files; inline script display names remain sufficient for the current PseudoKimchi implementation.

**Implementation Notes:**
Rewrote the PseudoTortillas `Recipes.json` file as UTF-8 without BOM in both locations:

- `mymods/PseudoTortillas/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`
- `C:/Users/edwar/Zomboid/mods/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`

No PseudoKimchi source files were changed because PseudoKimchi had no translation JSON file to repair.

### Phase 3: Verification

**Status:** Work Complete

- [x] Validate installed enabled-mod translation JSON files with a JSON parser.
- [x] Confirm installed translation JSON files are brace-first and no longer begin with UTF-8, UTF-16 LE, or UTF-16 BE BOM bytes.
- [x] Confirm the corrected PseudoTortillas `Recipes.json` starts with `7B 0A 20 20` in both workspace and installed copies.
- [ ] Relaunch Project Zomboid with PseudoKimchi enabled and confirm the `JSONObject text must begin with '{'` crash is gone.
- [ ] Check the new console log for any remaining PseudoKimchi warnings or errors.
- [x] Keep this DevCycle at `Work Complete` after implementation until Ed approves `Verified`.

**Verification Notes:**
Local validation completed. The installed `Translate` JSON scan reported that all installed translation JSON files are brace-first, have no BOM detected, and parse with PowerShell `ConvertFrom-Json`. The game was not relaunched during this cycle, so this is not marked `Verified`.

---

## Implemented Fix

The implemented fix removes the UTF-8 BOM from the enabled-mod translation file that matched the B42 translator failure mode:

- Before: `EF BB BF 7B`
- After: `7B 0A 20 20`

PseudoKimchi did not contain a malformed translation JSON file in either the workspace source copy or the installed copy. The crash occurred while PseudoKimchi was being enabled, but the concrete malformed leading bytes were in `PseudoTortillas` translation JSON, which was part of the enabled mod set in the console log.

---

## Notes and Risks

- The console line immediately before the exception is `texturepack: loading pseudoed_salt_03`; this appears unrelated to the JSON exception because the stack trace points to translation loading.
- Other enabled mods override translation files, and B42 loads translation maps across all enabled mods. A crash after `loading PseudoKimchi` can therefore be caused by another enabled mod's translation file during the same reset/load pass.
- If the crash persists after relaunch, collect a fresh `console.txt` and repeat the byte-level scan against the currently enabled installed mod set.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Completion Summary

**Completion Date:** 2026-07-01
**Status:** Work Complete
**Files modified:**

- `mymods/PseudoTortillas/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`
- `C:/Users/edwar/Zomboid/mods/PseudoTortillas/42/media/lua/shared/Translate/EN/Recipes.json`

**Work Deferred:**

- In-game relaunch verification with PseudoKimchi enabled.
- Review of a fresh console log after relaunch.
