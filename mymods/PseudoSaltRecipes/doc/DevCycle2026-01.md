# DevCycle 2026-01: Bring PseudoSaltRecipes up to date with PseudoTestRecipes

**Status:** Work Complete
**Start Date:** 2026-06-23
**Target Completion:** TBD
**Focus:** Confirm `PseudoSaltRecipes` has nothing that `PseudoTestRecipes` lacks, then manually port `PseudoTestRecipes`'s content into `PseudoSaltRecipes` and test the result in-game.

---

## Goal

`PseudoTestRecipes` is the testing ground for recipe/item changes that eventually graduate into `PseudoSaltRecipes` (the mod that actually ships, mod id `PseudoSaltPreservation`). `PseudoTestRecipes` is expected to be ahead — it has more items and more recipes. Before Ed manually copies that newer content over, we need a clear, file-by-file account of any item, recipe, or field that exists in `PseudoSaltRecipes` but is *not* present in `PseudoTestRecipes` in some form. Anything found there is a real risk of being silently dropped during the copy.

## Desired Outcome

A written comparison (in this document or a linked analysis doc) that lists, for every file pair between the two mods:
- content unique to `PseudoSaltRecipes` with no equivalent in `PseudoTestRecipes` (the actual risk this phase is checking for)
- content unique to `PseudoTestRecipes` (expected/not a concern, but noted for completeness)

Once that's confirmed, Ed manually copies the files (Phase 2) and tests in-game (Phase 3).

---

## Tasks

### Phase 1: Verify nothing in PseudoSaltRecipes is missing from PseudoTestRecipes

**Status:** Work Complete

- [x] Compare `42/media/scripts/items/PseudoSaltItems.txt` between both mods — list items/fields present in Salt but absent in Test.
- [x] Compare `42/media/scripts/recipes/PseudoSaltRecipes.txt` between both mods — list recipes present in Salt but absent in Test.
- [x] Compare `42/mod.info` between both mods.
- [x] Compare `common/media/scripts/items/PseudoSaltItems.txt` between both mods.
- [x] Compare `common/media/scripts/recipes/PseudoSaltRecipes.txt` between both mods.
- [x] Note `PseudoTestRecipes/common/media/scripts/recipes/PseudoSaltRecipes.old` — confirm whether `PseudoSaltRecipes` has an equivalent `.old` file or any other content not covered by the above.
- [x] Record findings as a clear list: anything in Salt missing from Test (the actual gap to flag), and a short note on what's new in Test (expected, informational only).

**Technical Notes:**

**Items present in Salt but missing from Test (the real gap — present in both `42/` and `common/` items files):**
- `SaltCuredFishFillet`, `SaltCuredVenison`, `SaltCuredBeef`, `SaltCuredSteak`, `SaltCuredRabbitmeat`, `BrinedPorkCrock`, `BrinedSaltPorkCrock`

These seven all belong to the `ReplaceOnRotten` cure/brine chain (a raw `Salted*` item rotting into a `SaltCured*`/`BrinedSaltPorkCrock` item). None of them is ever a `craftRecipe` output in either mod — they only exist as rot targets. Per the existing `PseudoTestRecipes/doc/planning/DevCycle001.md` (Phase 1, "Decision" note), this is an intentional, already-made project decision: the cure-chain mechanic is being removed, not preserved, and `PseudoTestRecipes` already reflects the target end state by simply not having these items. **This is not an oversight to copy over in Phase 2** — copying these seven items (or the `ReplaceOnRotten` lines that reference them) back in would reintroduce a mechanic that's already been decided against.

**Field-level check on items both mods share:** confirmed via diff that every difference on shared items (`SaltedFishFillet`, `SaltedVenison`, `SaltedBeef`, `SaltedSteak`, `SaltedRabbitmeat`, etc.) is Test *adding* data Salt doesn't have (`Weight`, `BadCold`, updated `DaysFresh`/`DaysTotallyRotten`, namespaced `Tags`, `ItemType = base:food`) — nothing shared is present in Salt and absent in Test.

**Recipes:** no `craftRecipe` name exists in Salt's `42/` or `common/` recipes file that is missing from the corresponding Test file. Salt's `common/` recipe file has the pre-fix names with spaces (`Make Salted Fillet`, `Salt Meat ChickenStyle`, `Salt Meat AnimalStyle`) — a known naming bug already fixed in Test's `MakeSaltedFillet`/`SaltMeatChickenStyle`/`SaltMeatAnimalStyle`, not new content unique to Salt.

**`mod.info`:** differs only in `name`, `id` (`PseudoSaltPreservation` vs `PseudoTestRecipes`), and `description` — these are mod-identity fields that are expected to differ and must be set manually to Salt's values during Phase 2, not copied from Test.

**`poster.png`:** identical file size (5682 bytes) in both — no concern.

**`PseudoSaltRecipes.old`:** both mods have a `common/media/scripts/recipes/PseudoSaltRecipes.old` file, and the two differ in content (Test's `.old` is missing a `SaltMeat`/`GetSalt` recipe block that Salt's `.old` has). However, the `.old` extension means neither is loaded by the game — this is dead/historical reference content in both mods, not currently-shipping functionality. Flagging for awareness only; not a gap that affects Phase 2's copy.

**Summary — nothing in PseudoSaltRecipes is missing from PseudoTestRecipes**, with one explicit exception that is an intentional removal, not a gap: the seven cure/brine-chain items. Phase 2 should not restore them.

### Phase 2: Manually copy PseudoTestRecipes content into PseudoSaltRecipes

**Status:** Complete

- [X] Ed manually copies the relevant files/content from `PseudoTestRecipes` into `PseudoSaltRecipes`.

**Technical Notes:**
This phase is performed by Ed, not by an agent.

### Phase 3: Test PseudoSaltRecipes in-game

**Status:** Work Complete

- [X] Ed tests the updated `PseudoSaltRecipes` mod in-game.

**Technical Notes:**
This phase is performed by Ed, not by an agent.

---

## Open Questions

*None at cycle start.*

---

## Notes and Risks

- Phase 1 is verification-by-reading only — no files are modified in this phase.
- Phases 2 and 3 are manual, user-performed steps; this document tracks them but an agent should not perform the copy or claim in-game verification.

---

## Completion Summary

**Completion Date:** 2026-06-23
**Phases Completed:** All (1, 2, 3)
**Work Deferred:** None.

**Accomplishments:**
- Phase 1: confirmed nothing in `PseudoSaltRecipes` is missing from `PseudoTestRecipes`, aside from the seven cure/brine-chain items whose absence in Test is an intentional, already-decided removal (see Phase 1 Technical Notes).
- Phase 2: Ed manually copied the relevant content from `PseudoTestRecipes` into `PseudoSaltRecipes`.
- Phase 3: Ed tested the updated `PseudoSaltRecipes` mod in-game.

**Metrics:**
- Files compared in Phase 1: items (`42/` and `common/`), recipes (`42/` and `common/`), `mod.info`, `poster.png`, `PseudoSaltRecipes.old`.

**Lessons / Notes:**
This DevCycle's status is recorded as **Work Complete**, not **Verified** — per the project's verification-authority rule, an agent does not set a DevCycle to `Verified` without explicit user permission. Let me know if you want this cycle marked `Verified` and/or moved into a `completed/` folder.
