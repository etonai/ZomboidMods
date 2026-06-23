# DevCycle 001: Backfill missing item data in PseudoTestRecipes

**Status:** Planning
**Start Date:** 2026-06-22
**Target Completion:** TBD
**Focus:** Restore the nutrition/weight/spoilage-chain fields that exist in `PseudoSaltRecipes` but were dropped when the same items were carried over into `PseudoTestRecipes/42`, without losing the newer fixes Test already made (namespaced tags, `ItemType = base:food`, expanded recipes).

---

## Goal

`PseudoTestRecipes` exists to test recipes before they graduate into `PseudoSaltPreservation` (the `PseudoSaltRecipes` mod folder; mod id `PseudoSaltPreservation`). A prior comparison of the two mods found that for the ten items both mods share — `SaltedFishFillet`, `SaltCuredFishFillet`, `SaltedVenison`, `SaltCuredVenison`, `SaltedBeef`, `SaltCuredBeef`, `SaltedSteak`, `SaltCuredSteak`, `SaltedRabbitmeat`, `SaltCuredRabbitmeat` — the `PseudoSaltRecipes/42` definitions carry `Weight`, `HungerChange`, `Calories`/`Carbohydrates`/`Lipids`/`Proteins`, `BadCold`, and a `ReplaceOnRotten` link from the raw salted item to its cured counterpart, none of which are present on the matching items in `PseudoTestRecipes/42`. Recipes are not missing anything — `PseudoTestRecipes` already has more recipes than `PseudoSaltRecipes` (fixed naming, more meat-type coverage, plus the whole lacto-fermentation set) — this cycle is scoped to item data only.

While preparing this cycle, a second issue surfaced that has to be resolved first: `PseudoTestRecipes` has a `mod.info` only inside `42/` (`PseudoTestRecipes/42/mod.info`), the same pattern `PseudoSaltRecipes` uses. There is no mod-root `mod.info` next to `common/`. `PseudoTestRecipes/common/media/scripts/{items,recipes}/PseudoSalt*.txt` still contain the *old*, pre-Test content, byte-for-byte matching `PseudoSaltRecipes/common`.

**Confirmed by the user: `common/` is live.** It is not an orphaned leftover — the game loads it alongside `42/`. That means right now this mod ships two conflicting definitions of every shared item/recipe name in the same `Pseudonymous` module: the stale, pre-Test values from `common/`, and the newer Test values from `42/`. Whichever one the game's loader resolves last (or this causes an outright duplicate-definition error) is a real, currently-shipping bug independent of the missing-data question this cycle started from. Phase 1 changes from "investigate and confirm" to "reconcile `common/` to match `42/`."

## Desired Outcome

`PseudoTestRecipes/common/` and `PseudoTestRecipes/42/` no longer define conflicting versions of the same items/recipes — `common/`'s stale `PseudoSalt*.txt` files are brought into agreement with `42/`'s current content (recipes, new meat items, field conventions) as the single source of truth. On top of that, the items both mods share with `PseudoSaltRecipes` carry the same nutrition, weight, `BadCold`, and raw→cured `ReplaceOnRotten` data as `PseudoSaltRecipes/42`, using Test's current field conventions (`ItemType = base:food`, namespaced lowercase `Tags`) rather than reverting those fixes — applied identically to both `common/` and `42/` so they stay in sync. Any decision that affects gameplay balance (shelf-life/thirst model) is raised as an explicit choice for the user, not silently picked.

---

## Tasks

### Phase 1: Reconcile `common/` to match `42/`

**Status:** Planning

- [ ] Replace `PseudoTestRecipes/common/media/scripts/items/PseudoSaltItems.txt` with the current `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` content (all the newer meat items, `ItemType`/namespaced-tag conventions, current shelf-life model) instead of the stale `PseudoSaltRecipes`-matching content it has now.
- [ ] Replace `PseudoTestRecipes/common/media/scripts/recipes/PseudoSaltRecipes.txt` with the current `PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` content (fixed `MakeSaltedFillet` naming, full animal-style mapper, lacto-fermentation recipes).
- [ ] Decide what to do with `PseudoTestRecipes/common/media/scripts/recipes/PseudoSaltRecipes.old` — it's already inert (a `.old` extension isn't a script file PZ loads) but sits next to files that do load; remove it or leave it as historical reference, whichever the user prefers.
- [ ] After reconciling, treat `common/` and `42/` as needing to change together for the rest of this cycle — every edit in Phase 2 and Phase 3 below applies to both copies, not just `42/`.

**Technical Notes:**
This has to land before Phase 2, since editing `42/` alone while `common/` is confirmed live and still defines the same item/recipe names with the old values would leave the conflict in place rather than fixing it. Found via `diff`: `PseudoTestRecipes/common/media/scripts/items/PseudoSaltItems.txt` and `.../recipes/PseudoSaltRecipes.txt` are currently identical to the corresponding `PseudoSaltRecipes/common` files, not to `PseudoTestRecipes/42`. Once reconciled, the safest way to keep them in sync going forward is worth a follow-up thought (e.g. is one of the two folders supposed to be authoritative with the other generated/copied from it?) — not solved in this cycle, just flagged.

### Phase 2: Backfill nutrition, weight, and cold-spoilage fields

**Status:** Planning

Apply each of the following to both `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` and `PseudoTestRecipes/common/media/scripts/items/PseudoSaltItems.txt` (kept identical per Phase 1).

- [ ] `SaltedFishFillet` — add `Weight = 0.2`, `HungerChange = -25`, `Calories = 205`, `Carbohydrates = 1`, `Lipids = 12`, `Proteins = 28.52`.
- [ ] `SaltCuredFishFillet` — add `HungerChange = -25`, `Calories = 205`, `Carbohydrates = 1`, `Lipids = 12`, `Proteins = 28.52` (Test already sets its own `Weight = 0.14`, close to Salt's `0.16` — keep Test's value unless Phase 3 decides otherwise).
- [ ] `SaltedVenison` — add `Weight = 0.51`, `BadCold = true`, `HungerChange = -80`, `Calories = 440`, `Carbohydrates = 0`, `Lipids = 18.7`, `Proteins = 62.62`.
- [ ] `SaltCuredVenison` — add `BadCold = true`, `HungerChange = -80`, `Calories = 440`, `Carbohydrates = 0`, `Lipids = 18.7`, `Proteins = 62.62` (keep Test's existing `Weight = 0.35`).
- [ ] `SaltedBeef` — add `Weight = 0.51`, `BadCold = true`, `HungerChange = -80`, `Calories = 440`, `Carbohydrates = 0`, `Lipids = 18.7`, `Proteins = 62.62`.
- [ ] `SaltCuredBeef` — add `BadCold = true`, `HungerChange = -80`, `Calories = 440`, `Carbohydrates = 0`, `Lipids = 18.7`, `Proteins = 62.62` (keep Test's existing `Weight = 0.35`).
- [ ] `SaltedSteak` — add `Weight = 0.31`, `BadCold = true`, `HungerChange = -40`, `Calories = 220`, `Carbohydrates = 0`, `Lipids = 9.35`, `Proteins = 31.62`.
- [ ] `SaltCuredSteak` — add `BadCold = true`, `HungerChange = -40`, `Calories = 220`, `Carbohydrates = 0`, `Lipids = 9.35`, `Proteins = 31.62` (keep Test's existing `Weight = 0.21`).
- [ ] `SaltedRabbitmeat` — add `Weight = 0.31`, `BadCold = true`, `HungerChange = -30`, `Calories = 969`, `Carbohydrates = 20`, `Lipids = 20`, `Proteins = 185`.
- [ ] `SaltCuredRabbitmeat` — add `BadCold = true`, `HungerChange = -30`, `Calories = 969`, `Carbohydrates = 20`, `Lipids = 20`, `Proteins = 185` (keep Test's existing `Weight = 0.21`).

**Technical Notes:**
Source of truth for every value above is `mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`. Do not copy `Type = Food` or unnamespaced `Tags`/`FishMeat` from that file — Test's `ItemType = base:food` and namespaced lowercase tags (`base:fishmeat`, etc.) are the newer, correct convention and should be kept as-is. `SaltedBeef`/`SaltedSteak`/`SaltCuredBeef`/`SaltCuredSteak` already carry `FishingLure = true` in both mods — no change needed there.

### Phase 3: Decide the raw→cured spoilage chain and shelf-life model

**Status:** Planning

- [ ] Decide whether to add `ReplaceOnRotten = Pseudonymous.SaltCured<X>` back onto the five raw `Salted*` items (`SaltedFishFillet`, `SaltedVenison`, `SaltedBeef`, `SaltedSteak`, `SaltedRabbitmeat`), matching `PseudoSaltRecipes`'s rot-into-cured-form chain.
- [ ] Decide whether to keep Test's current flat `DaysFresh = 240` / `DaysTotallyRotten = 540` / `ThirstChange = 10` model, or restore Salt's two-tier model (`DaysFresh = 7` / `DaysTotallyRotten = 14` raw, `90` / `180` cured, no `ThirstChange`).
- [ ] Apply whichever combination is chosen consistently across all ten items.

**Technical Notes:**
Not treated as an automatic backfill because these two fields look like deliberate experiments made while testing in this mod, not omissions — restoring them without checking would silently undo balance changes the user may have made on purpose. See Open Questions below for the actual decision.

---

## Open Questions

1. **Should the raw→cured `ReplaceOnRotten` chain be restored in `PseudoTestRecipes`?**
   In `PseudoSaltRecipes`, a raw `Salted*` item rots into its `SaltCured*` counterpart instead of just rotting away; `PseudoTestRecipes` currently has no such link, so the cured items exist but are only reachable some other way (not yet checked — possibly only via direct crafting, not natural aging).
   Recommendation: restore it. It is core to the "salt preservation" concept this whole item family is testing, and there's no sign Test meant to remove it — it's more likely a casualty of the item rewrite that also added `ItemType`/namespaced tags.

2. **Should Test keep its longer flat shelf life (`240`/`540` days, `ThirstChange = 10`) or revert to Salt's shorter two-tier model (`7`/`14` raw, `90`/`180` cured, no thirst)?**
   This is a real balance difference, not an oversight artifact — Test's numbers are deliberately different in shape (single tier, much longer, adds thirst) from Salt's (two-tier, much shorter, no thirst).
   Recommendation: keep Test's model and treat it as the candidate to promote into `PseudoSaltRecipes` later, rather than reverting Test to match Salt — but this is a gameplay-balance call, not a code-correctness one, so defer to the user rather than deciding it here.

3. **Now that `common/` is confirmed live, should this mod keep maintaining two parallel copies of the same files (`common/` and `42/`) at all, or collapse to one going forward?**
   Phase 1 reconciles them for this cycle, but having two copies that must be hand-kept in sync is itself a standing risk of exactly the kind of drift this cycle exists to fix.
   Recommendation: worth a future DevCycle to either confirm there's a structural reason both must exist (e.g. a B41/B42 split where `common/` is meant to serve builds other than 42, in which case keeping them identical is the right call), or collapse to a single source. Not resolved here — out of scope for a data-backfill cycle.

---

## Notes and Risks

- This cycle intentionally does not touch recipes — the prior comparison found `PseudoTestRecipes`'s recipes are already a strict superset/improvement over `PseudoSaltRecipes`'s (fixed `Make Salted Fillet` naming bug, added Venison to the chicken-style mapper, full 12-meat animal-style mapper, plus the entire lacto-fermentation recipe set). Only item stat data is in scope.
- This cycle also does not extend the cure chain to the eight newer meats Test added beyond the original five (`SaltedChicken`, `SaltedChickenFillet`, `SaltedPork`, `SaltedPorkChop`, `SaltedTurkeyFillet`, `SaltedMuttonChop`, `SaltedSmallbirdmeat`, `SaltedSmallanimalmeat`) — none of those have a `SaltCured*` counterpart item at all yet, so there is nothing to "backfill" for them; giving them a cured tier would be new content, not missing data, and is a candidate for a future DevCycle if wanted.
- Since `common/` is confirmed live, the duplicate item/recipe definitions between it and `42/` (pre-Phase-1) may already have been causing a load-time error or silently-wrong values in-game — worth checking game logs for duplicate-definition warnings if this mod has been run before this cycle's fix.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*
