# DevCycle 002: Plain Food Unhappiness Adjustment

**Status:** Verified
**Start Date:** 2026-06-30
**Target Completion:** 2026-06-30
**Focus:** Set plain grits, porridge, and pease pottage unhappiness to 0.

---

## Goal

Adjust the combined mod so plain grits, plain porridge, and pease pottage match oatmeal-style unhappiness rather than rice-style unhappiness.

The source values used `UnhappyChange = 20` on pan and pot items, matching rice. Ed clarified that these foods should behave more like oatmeal for unhappiness, with plain versions using `UnhappyChange = 0`.

## Desired Outcome

Plain grits, porridge, and pease pottage no longer add unhappiness when eaten from saucepan or cooking pot variants.

Expected behavior:

- Neutral/plain grits pan and pot items use `UnhappyChange = 0`.
- Neutral/plain porridge pan and pot items use `UnhappyChange = 0`.
- Pease pottage pan and pot items use `UnhappyChange = 0`.
- Sweet and savory grits/porridge variants are not changed by this cycle.

---

## Tasks

### Phase 1: Identify Target Items

**Status:** Verified

- [x] Identify neutral/plain grits items with `UnhappyChange = 20`.
- [x] Identify neutral/plain porridge items with `UnhappyChange = 20`.
- [x] Identify pease pottage items with `UnhappyChange = 20`.
- [x] Confirm sweet/savory grits and porridge variants are outside this minor edit.

### Phase 2: Script Edit

**Status:** Verified

- [x] Set plain grits pan and pot item `UnhappyChange` values to 0.
- [x] Set plain porridge pan and pot item `UnhappyChange` values to 0.
- [x] Set pease pottage pan and pot item `UnhappyChange` values to 0.
- [x] Leave recipes, evolved recipes, and translations unchanged.

### Phase 3: Static Checks

**Status:** Verified

- [x] Confirm target plain item values are now `UnhappyChange = 0`.
- [x] Confirm script braces remain balanced.
- [x] Confirm EN translation JSON files still parse.

### Phase 4: In-Game Verification

**Status:** Verified

- [x] Launch Project Zomboid B42 with `PseudoGritsPorridgePottage` enabled.
- [x] Confirm plain grits no longer adds unhappiness.
- [x] Confirm plain porridge no longer adds unhappiness.
- [x] Confirm pease pottage no longer adds unhappiness.

---

## Notes and Risks

- This is intentionally a small balance correction, not a recipe redesign.
- Sweet and savory grits/porridge pan and pot variants still have their previous values unless a later cycle changes them.
- Per the planning process, this cycle should not be marked `Verified` without explicit user approval.

---

## Completion Summary

**Completion Date:** 2026-06-30
**Verification Date:** 2026-06-30
**Phases Completed:** Phases 1-4
**Work Deferred:** None.

**Accomplishments:**
- Updated plain grits, porridge, and pease pottage pan/pot unhappiness values from 20 to 0.
- Left sweet/savory grits and porridge variants unchanged.

**Verification:**
- Static target value checks passed.
- Script brace balance checks passed.
- EN translation JSON parse checks passed.
- Ed approved declaring DC 2 verified.
