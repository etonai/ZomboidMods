# DevCycle 001: Backfill missing item data in PseudoTestRecipes

**Status:** Planning
**Start Date:** 2026-06-22
**Target Completion:** TBD
**Focus:** Restore the `Weight`/`BadCold` fields that exist in `PseudoSaltRecipes` but were dropped when the same items were carried over into `PseudoTestRecipes/42`, without losing the newer fixes Test already made (namespaced tags, `ItemType = base:food`, expanded recipes, `InheritFood`-based nutrition, and the removal of the `ReplaceOnRotten` cure-chain mechanic).

---

## Goal

`PseudoTestRecipes` exists to test recipes before they graduate into `PseudoSaltPreservation` (the `PseudoSaltRecipes` mod folder; mod id `PseudoSaltPreservation`). A prior comparison of the two mods found that for the items both mods share — `SaltedFishFillet`, `SaltedVenison`, `SaltedBeef`, `SaltedSteak`, `SaltedRabbitmeat` — the `PseudoSaltRecipes/42` definitions carry `Weight`, `HungerChange`, `Calories`/`Carbohydrates`/`Lipids`/`Proteins`, and `BadCold`, none of which are present on the matching items in `PseudoTestRecipes/42`. **Phase 1 narrowed this**: the `HungerChange`/`Calories`/`Carbohydrates`/`Lipids`/`Proteins` fields are overwritten at craft time anyway by Test's `InheritFood`-flagged recipes, so only `Weight` and `BadCold` are real gaps.

**Decision: the `ReplaceOnRotten` cure-chain mechanic is being removed, not restored.** `PseudoSaltRecipes` also defines `SaltCuredFishFillet`, `SaltCuredVenison`, `SaltCuredBeef`, `SaltCuredSteak`, `SaltCuredRabbitmeat`, and `BrinedSaltPorkCrock` (plus `BrinedPorkCrock`, which only exists to rot into the latter) — every one of these items exists *solely* as a `ReplaceOnRotten` target; none is ever a `craftRecipe` output in either mod. `PseudoTestRecipes/42/` already has none of these items, which is exactly consistent with this decision (this is also what I'd flagged earlier in the cycle as an unexplained gap — it's now explained: not a regression, the intended end state). So this cycle does not need to add a cure-chain to Test; it just needs to make sure `42/`'s already-correct state (no cured/brined items, no `ReplaceOnRotten`) is what gets backfilled and then copied to `common/`, not Salt's old chain.

Recipes themselves are not missing anything — `PseudoTestRecipes` already has more recipes than `PseudoSaltRecipes` (fixed naming, more meat-type coverage, the entire lacto-fermentation set, and three fermentation recipes — Zucchini, Turnip, Bell Pepper — that Salt doesn't even have yet) — this cycle is scoped to item data only.

While preparing this cycle, a second issue surfaced: `PseudoTestRecipes` has a `mod.info` only inside `42/` (`PseudoTestRecipes/42/mod.info`), the same pattern `PseudoSaltRecipes` uses. There is no mod-root `mod.info` next to `common/`. `PseudoTestRecipes/common/media/scripts/{items,recipes}/PseudoSalt*.txt` still contain the *old*, pre-Test content, byte-for-byte matching `PseudoSaltRecipes/common`.

**Confirmed by the user: `common/` is live.** It is not an orphaned leftover — the game loads it alongside `42/`. That means right now this mod ships two conflicting definitions of every shared item/recipe name in the same `Pseudonymous` module: the stale, pre-Test values from `common/`, and the newer Test values from `42/`. That's a real, currently-shipping bug independent of the missing-data question this cycle started from, and it does need fixing — but **not first**. `42/` is where every edit in this cycle actually happens; `common/` only needs to end up matching whatever `42/` looks like once it's finished. Reconciling `common/` before the backfill (Phases 1–2) would mean copying broken data over and then having to re-copy it again after every fix — `common/` is brought into sync last, in Phase 3, once `42/` is done.

## Desired Outcome

The five shared items in `PseudoTestRecipes/42/` carry the same `Weight` and `BadCold` as `PseudoSaltRecipes/42` (nutrition/hunger fields intentionally excluded — see Phase 1), using Test's current field conventions (`ItemType = base:food`, namespaced lowercase `Tags`, `InheritFood`-based nutrition, no `ReplaceOnRotten`/cured-item chain) rather than reverting those fixes. Once `42/` is correct, `PseudoTestRecipes/common/` is brought into agreement with it — including no longer carrying the cured/brined items or the `ReplaceOnRotten` chain it currently still has — so the mod no longer ships two conflicting definitions of the same items/recipes. Any remaining gameplay-balance decision (shelf-life/thirst model) is raised as an explicit choice for the user, not silently picked.

---

## Tasks

### Phase 1: Backfill weight and cold-spoilage fields on `42/`

**Status:** Planning

**Scope correction:** the macro/hunger fields (`HungerChange`, `Calories`, `Carbohydrates`, `Lipids`, `Proteins`) originally planned for this phase are **not actually missing data** — dropped. Confirmed in `zombie/entity/components/crafting/recipe/CraftRecipeData.java:1132` and `zombie/inventory/types/Food.java:2392-2416`: Test's recipes use `flags[InheritFood;ItemCount]` on the raw-meat input, which makes `copyNutritionFromSplit` overwrite `BaseHunger`/`HungChange`/`Calories`/`Carbohydrates`/`Lipids`/`Proteins` on the crafted output from the input meat's live values at craft time, every time. Whatever static numbers sit in the item script for those five fields get clobbered immediately on crafting, so hardcoding `PseudoSaltRecipes`'s numbers here would be inert for the actual craft path. (`PseudoSaltRecipes`'s old recipe only used `InheritFoodAge` — freshness only, not nutrition — which is why *that* mod still needs them hardcoded.) `copyFoodFromSplit` does not touch `Weight`, and has nothing to do with type-level flags like `BadCold` or `ReplaceOnRotten`, so those remain real gaps below.

Edit only `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` in this phase — `common/` is not touched until Phase 3.

- [ ] `SaltedFishFillet` — add `Weight = 0.2`.
- [ ] `SaltedVenison` — add `Weight = 0.51`, `BadCold = true`.
- [ ] `SaltedBeef` — add `Weight = 0.51`, `BadCold = true`.
- [ ] `SaltedSteak` — add `Weight = 0.31`, `BadCold = true`.
- [ ] `SaltedRabbitmeat` — add `Weight = 0.31`, `BadCold = true`.

**Technical Notes:**
Source of truth for every value above is `mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`. Do not copy `Type = Food`, unnamespaced `Tags`/`FishMeat`, or `ReplaceOnRotten` from that file — Test's `ItemType = base:food`, namespaced lowercase tags (`base:fishmeat`, etc.), and the removal of the cure-chain mechanic are the newer, correct conventions and should be kept as-is. Only these five items are in scope — `SaltCuredFishFillet`/`SaltCuredVenison`/`SaltCuredBeef`/`SaltCuredSteak`/`SaltCuredRabbitmeat`/`BrinedPorkCrock`/`BrinedSaltPorkCrock` don't exist in `42/` and should stay that way (see the cure-chain removal decision above). `SaltedBeef`/`SaltedSteak` already carry `FishingLure = true` in both mods — no change needed there. Worth double-checking whether `SaltMeatChickenStyle`/`SaltMeatAnimalStyle` (which also use `InheritFood`) cover all five items here the same way `MakeSaltedFillet` does for the fish fillet, to make sure the "macros are inherited, don't hardcode" reasoning actually applies uniformly and isn't assuming one recipe's behavior for items actually produced by a different one.

### Phase 2: Apply the finalized shelf-life values to `42/`

**Status:** Planning

Still editing only `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` — `common/` still isn't touched.

**Decision:** salting is meant to produce a long-lasting survival food, not a short-lived one — confirms the direction of Test's flat model over Salt's old short raw-tier numbers, but Test's specific `240`/`540` is being tuned down. New values: `DaysFresh = 150`, `DaysTotallyRotten = 360`. `ThirstChange = 10` is unchanged.

- [ ] Change every item in `42/` currently set to `DaysFresh = 240` / `DaysTotallyRotten = 540` to `DaysFresh = 150` / `DaysTotallyRotten = 360`. That's all 13 `Salted*` items, not just the original five: `SaltedFishFillet`, `SaltedVenison`, `SaltedBeef`, `SaltedSteak`, `SaltedRabbitmeat`, `SaltedChicken`, `SaltedChickenFillet`, `SaltedPork`, `SaltedPorkChop`, `SaltedTurkeyFillet`, `SaltedMuttonChop`, `SaltedSmallbirdmeat`, `SaltedSmallanimalmeat`.

**Technical Notes:**
Salt's old two-tier model (short raw life rotting into a longer-lived cured item) doesn't carry over now that the cured tier is gone — this is one number per item, not a chain. Scope is wider than Phase 1's five items because Phase 1 only needed `Weight`/`BadCold` on the original five (the eight newer meats already have those), but this shelf-life value is shared by all 13 `Salted*` items currently at `240`/`540`.

### Phase 3: Reconcile `common/` to match the finished `42/`

**Status:** Planning

- [ ] Replace `PseudoTestRecipes/common/media/scripts/items/PseudoSaltItems.txt` with the now-finished `PseudoTestRecipes/42/media/scripts/items/PseudoSaltItems.txt` content (post Phase 1–2: newer meat items, `ItemType`/namespaced-tag conventions, the `Weight`/`BadCold` backfill, and whatever Phase 2 decided for shelf life) — replacing the stale `PseudoSaltRecipes`-matching content `common/` has now. This is also where the cured/brined items (`SaltCuredFishFillet`, `SaltCuredVenison`, `SaltCuredBeef`, `SaltCuredSteak`, `SaltCuredRabbitmeat`, `BrinedPorkCrock`, `BrinedSaltPorkCrock`) and every `ReplaceOnRotten` reference actually disappear from `common/` — they're removed as a side effect of overwriting with `42/`'s content, not as a separate deletion step.
- [ ] Replace `PseudoTestRecipes/common/media/scripts/recipes/PseudoSaltRecipes.txt` with the current `PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` content (fixed `MakeSaltedFillet` naming, full animal-style mapper, lacto-fermentation recipes) — this file isn't touched by Phase 1–2, so it can be copied over as-is.
- [ ] Decide what to do with `PseudoTestRecipes/common/media/scripts/recipes/PseudoSaltRecipes.old` — it's already inert (a `.old` extension isn't a script file PZ loads) but sits next to files that do load; remove it or leave it as historical reference, whichever the user prefers.

**Technical Notes:**
Doing this last means `common/` only gets copied to once, with finished content, instead of being patched in parallel with `42/` through two rounds of edits. Found via `diff`: `PseudoTestRecipes/common/media/scripts/items/PseudoSaltItems.txt` and `.../recipes/PseudoSaltRecipes.txt` are currently identical to the corresponding `PseudoSaltRecipes/common` files, not to `PseudoTestRecipes/42` — confirming there's nothing in the current `common/` worth preserving or merging, it's a straight overwrite. The safest way to keep them in sync going forward is worth a follow-up thought (e.g. is one of the two folders supposed to be authoritative with the other generated/copied from it?) — not solved in this cycle, just flagged (see Open Question 3).

---

## Open Questions

*No open questions remain — both have been decided.*

1. ~~Shelf-life model~~ — **Resolved:** `DaysFresh = 150`, `DaysTotallyRotten = 360`, `ThirstChange = 10` unchanged. See Phase 2.

2. ~~Should `common/` and `42/` collapse to one going forward?~~ — **Resolved: keep both live.**
   ED: Keep them both live. Last time I tried removing common, there was an error. That may have been fixed, but it is not worth investigating.

---

## Notes and Risks

- This cycle intentionally does not touch recipes — `PseudoTestRecipes`'s recipes are already a strict superset/improvement over `PseudoSaltRecipes`'s (fixed `MakeSaltedFillet` naming bug, added Venison to the chicken-style mapper, full 12-meat animal-style mapper, the entire lacto-fermentation recipe set, plus Zucchini/Turnip/Bell Pepper recipes Salt doesn't have at all). Only item stat data is in scope.
- The cure-chain mechanic (`ReplaceOnRotten` from a raw `Salted*` item into a `SaltCured*`/`BrinedSaltPorkCrock` item) is being removed project-wide, not restored — see the Goal section. `PseudoTestRecipes/42/` is already in the target end state (no cured/brined items, no `ReplaceOnRotten`); this cycle just needs to avoid reintroducing it while backfilling `Weight`/`BadCold`, and Phase 3 carries that removal into `common/` as a side effect of the overwrite.
- `PseudoSaltRecipes` itself (both `common/` and `42/`) still defines the cured/brined items and the `ReplaceOnRotten` chain — removing the mechanic there is out of scope for this `PseudoTestRecipes` DevCycle, but it's a real follow-up: a separate DevCycle under `PseudoSaltRecipes/doc/planning/` (which doesn't exist yet either) would need to delete `SaltCuredFishFillet`, `SaltCuredVenison`, `SaltCuredBeef`, `SaltCuredSteak`, `SaltCuredRabbitmeat`, `BrinedPorkCrock`, `BrinedSaltPorkCrock`, and every `ReplaceOnRotten` line, to bring that mod in line with the same decision.
- This cycle does not give the eight newer meats Test added beyond the original five (`SaltedChicken`, `SaltedChickenFillet`, `SaltedPork`, `SaltedPorkChop`, `SaltedTurkeyFillet`, `SaltedMuttonChop`, `SaltedSmallbirdmeat`, `SaltedSmallanimalmeat`) a cured tier — moot now that cured tiers are being removed rather than added.
- Since `common/` is confirmed live, the duplicate item/recipe definitions between it and `42/` (until Phase 3 lands) may already have been causing a load-time error or silently-wrong values in-game — worth checking game logs for duplicate-definition warnings if this mod has been run before this cycle's fix. This also means the conflict stays live through Phases 1–2 of this cycle, not just before it; that's an accepted tradeoff for not re-editing `common/` twice, not an oversight.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*
