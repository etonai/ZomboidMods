# DevCycle 002: Carried-Animal Weight Reflects Real Body Weight

**Status:** Verified
**Start Date:** 2026-07-07
**Target Completion:** TBD
**Focus:** A carried animal's encumbrance should equal its real body weight (the same number shown on the in-world Animal Info panel) — not a vanilla game-balance constant, and not flattened to near-zero.

> **Note:** This cycle went through several rounds of diagnosis before landing on the actual goal. Phases 1-2 (encumbrance rate mismatch) and Phase 3 (dropping the `animalSize` growth-stage term) were real fixes to real problems found along the way, but Phase 4 is the one that reflects what was actually wanted throughout: carry weight tracking the animal's real weight, not any vanilla carry-weight formula. The sections below are kept in order as a record of that process rather than rewritten to look like the destination was known from the start.

---

## Goal

DC1 deliberately left `Base.Animal` item weight untouched, expecting vanilla's per-species/per-size weight scaling to behave the same whether the animal sits in a hand slot or in a bag. In-game testing showed encumbrance actually grew by an unreasonable amount per animal picked up. The initial read of this (see Root Cause below) was that carrying an item *unequipped* skips a weight discount vanilla applies to *equipped* items — true, and Phases 1-2 fixed exactly that. Further testing revealed the deeper issue: vanilla's whole carry-weight formula (`baseEncumbrance * animalSize`) was never meant to track an animal's real weight in the first place — it's a hand-tuned per-species balance constant. What was actually wanted (per direct user clarification) was carry weight equal to the animal's *real* body weight (`AnimalData.getWeight()`), full stop — see Phase 4.

This is explicitly **not** what Backpack Barnyard does (flattening every animal's weight to `0.01`, discarding any distinction between a chick and a cow) — the whole reason this mod exists instead of using that one. The fix is to reflect the animal's true weight, not erase it or substitute a game-balance number for it.

## Root Cause (from code)

- The player's total carried weight is computed in `IsoGameCharacter.getInventoryWeight()` (`zombie42_19/characters/IsoGameCharacter.java:11980-12001`). For each inventory item it picks one of three rates:
  - hotbar-attached → `item.getHotbarEquippedWeight()`
  - **equipped** (worn or in a hand slot) → `item.getEquippedWeight()`
  - **everything else** (sitting loose in a container/bag) → `item.getUnequippedWeight()`
- `InventoryItem.getEquippedWeight()` = `(actualWeight + contentsWeight) * ZomboidGlobals.equippedOrWornEncumbranceMultiplier` (`InventoryItem.java:3684-3686`). `getUnequippedWeight()` = `actualWeight + contentsWeight`, i.e. **no discount** (`InventoryItem.java:3688-3690`).
- `EquippedOrWornEncumbranceMultiplier = 0.3` (`media/lua/shared/defines.lua:60`). Vanilla applies this discount to anything held/worn — it's a general mechanic, not animal-specific.
- Vanilla `ISPickupAnimal` puts the animal item into **both hand slots**, so `isEquipped()` is true and the 0.3× rate applies. DC1's `ISHoldAnimalPickup` deliberately leaves the item sitting in inventory (that's the entire point of the mod) — but that means the exact same item now falls into the "everything else" branch and is charged the full, undiscounted rate. Same animal, same `actualWeight`, ~3.33× more encumbrance than vanilla. **This is the "unreasonable growth" observed in testing** — it is not a bug in animal growth/size simulation (that theory from the original draft of this cycle was checked and ruled out: `AnimalData.growUp()` mutates a separate body-weight field used only for meat yield, unrelated to `InventoryItem` weight).
- The animal's `actualWeight` itself — `baseEncumbrance * animalSize`, set once in `AnimalInventoryItem.initAnimalData()` (`zombie42_19/inventory/types/AnimalInventoryItem.java:109`) — was never the problem. That's the animal's real, per-species/per-size "normal weight," identical to what vanilla uses. The bug is entirely about *which rate* (0.3× equipped vs 1.0× unequipped) gets applied to it, not the base value.
- `initAnimalData()` runs from two places: `setAnimal()` (pickup) and `load()` (every save load). Any fix that only touches pickup-time weight will be silently overwritten back to the raw, undiscounted `baseEncumbrance * animalSize` the next time the game reloads — same durability concern DC1's investigation already flagged, still applies here.

## Desired Outcome

Picking up an animal via `ISHoldAnimalPickup` costs the player encumbrance equal to the animal's **real body weight** (`AnimalData.getWeight()`) — the same number the Animal Info panel shows on the ground — and this holds true across save/reload. A cow still costs meaningfully more to carry than a chick; nothing is flattened to a nominal constant, and nothing is tied to a vanilla game-balance value unrelated to actual mass.

---

## Tasks

### Phase 1: Apply the Equipped-Weight Discount at Pickup

**Status:** Work Complete

- [x] In `ISHoldAnimalPickup:complete()` (`mymods/HoldAnimals/HoldAnimals/42/media/lua/shared/TimedActions/Animals/ISHoldAnimalPickup.lua`), after `invItem:setAnimal(self.animal)` (which sets `actualWeight = baseEncumbrance * animalSize` via vanilla `initAnimalData()`), rescale it: read the current `getActualWeight()`, multiply by `ZomboidGlobals.EquippedOrWornEncumbranceMultiplier`, and write it back with `setWeight()`/`setActualWeight()`, plus `setCustomWeight(true)` so nothing else silently recomputes it from the item script default
- [x] Confirm `ZomboidGlobals.EquippedOrWornEncumbranceMultiplier` is readable from Lua the same way vanilla Lua call sites use it (e.g. `media/lua/shared/TimedActions/ISTakeFuel.lua:105`, `media/lua/shared/TimedActions/ISTakeWaterAction.lua:188` both reference it directly as `ZomboidGlobals.EquippedOrWornEncumbranceMultiplier`) rather than hardcoding `0.3`, so the mod stays correct if that global is ever tuned

**Technical Notes:**
Implemented in `mymods/HoldAnimals/HoldAnimals/42/media/lua/shared/HoldAnimals/HoldAnimals_WeightUtils.lua` as `HoldAnimals.WeightUtils.applyNormalWeight(item)`, called from `ISHoldAnimalPickup:complete()` right after `setAnimal()` and before `AddItem()`. The math: vanilla equipped cost = `actualWeight * 0.3`. Our item is charged at the unequipped rate (`* 1.0`). So pre-multiplying `actualWeight` itself by `ZomboidGlobals.EquippedOrWornEncumbranceMultiplier` at pickup makes the unequipped-rate charge land on the same final number vanilla's equipped-rate charge would have produced. This preserves relative weight differences between species/sizes (nothing is flattened), matches vanilla's real cost, and needed no changes to any equip-detection logic.

### Phase 2: Keep the Discount Applied Across Save/Load

**Status:** Work Complete

- [x] Added an `OnCreatePlayer`/`OnGameStart` hook (in the same `HoldAnimals_WeightUtils.lua`) that walks the player's inventory (recursively — main inventory, worn containers, and any nested container-item's inventory) and re-applies `applyNormalWeight` to any `Base.Animal` item found, since `AnimalInventoryItem.load()` unconditionally re-runs `initAnimalData()` on load and would otherwise silently restore the raw, undiscounted `baseEncumbrance * animalSize`
- [x] Detect target items with `instanceof(item, "AnimalInventoryItem")` — sufficient and unambiguous, since HoldAnimals only ever creates this one item type (no need for Backpack Barnyard's elaborate name/category/moddata fallback chain)
- [x] Guard against double-discounting: `applyNormalWeight` reads/writes a `HoldAnimals_NormalWeightApplied` flag in the item's `getModData()` and returns immediately if already set, so repeated `OnGameStart` firings (or calling it more than once for any other reason) cannot compound the discount

**Technical Notes:**
Structured as one shared function, `HoldAnimals.WeightUtils.applyNormalWeight(item)`, called from both `ISHoldAnimalPickup:complete()` and the load-time inventory walk (`HoldAnimals.WeightUtils.applyToPlayer(playerObj)`, wired to `Events.OnCreatePlayer`/`Events.OnGameStart`), so the idempotency guard only lives in one place. Mod-data persists across save/load like any other item mod-data, so the flag survives reloads correctly. This mirrors Backpack Barnyard's `applyWeightDeep` + `OnCreatePlayer`/`OnGameStart` re-stamp pattern structurally, but the function computes a discounted-real-weight instead of a flat constant, and is idempotent via mod-data rather than being safe-by-virtue-of-always-setting-the-same-constant.

### Phase 3: Drop `animalSize` From the Weight Formula

**Status:** Work Complete

- [x] Change the weight source from `item:getActualWeight()` (vanilla's `baseEncumbrance * animalSize`) to `baseEncumbrance` alone, read via `AnimalDefinitions.animals[animal:getAnimalType()].baseEncumbrance`, keeping the `* ZomboidGlobals.EquippedOrWornEncumbranceMultiplier` discount from Phase 1
- [x] Fall back to the old `getActualWeight()`-based value if the animal type can't be resolved from `AnimalDefinitions.animals` (defensive — shouldn't normally trigger)

**Technical Notes:**
User testing after Phase 1/2 shipped found carried animals still felt far heavier than what the in-world Animal Info panel showed for the same animal (that panel displays `AnimalData.getWeight()`, real body weight in kg — a completely different, unrelated number from carry-weight `baseEncumbrance * animalSize`; these were never linked in vanilla). Investigating the size term specifically: `animalSize` (`IsoAnimal.getAnimalSize()` → `AnimalData.getSize()`) is scoped **per growth stage**, not across the whole lifecycle — e.g. `chick` is defined with `minSize = 0.9, maxSize = 1` (`media/lua/shared/Definitions/animal/ChickenDefinitions.lua:92-93`), meaning a baby chick sits at ~90-100% of *its own stage's* size range, not "small" the way the formula's name implies. Per user direction, `animalSize` is dropped from HoldAnimals' carry-weight formula entirely — carry weight is now purely `baseEncumbrance * EquippedOrWornEncumbranceMultiplier`, a flat per-species value (chick ≈ 3, hen ≈ 6, cow ≈ 39) that keeps the vanilla equip-discount (confirmed to be a general mechanic applying to any held/worn item, not animal-specific) but no longer varies with growth stage. Implemented in `HoldAnimals_WeightUtils.lua`'s new `getBaseEncumbrance(item)` helper.

### Phase 4: Use the Animal's Real Weight, Not `baseEncumbrance` at All

**Status:** Work Complete

- [x] Replace the `baseEncumbrance`-based formula with the animal's real body weight, read via `animal:getData():getWeight()`
- [x] Drop the `EquippedOrWornEncumbranceMultiplier` discount — the goal is no longer "match vanilla's equipped-carry cost," it's "carry weight equals the animal's actual weight"
- [x] Keep the same fallback-to-`getActualWeight()` safety net if the animal/body-weight data can't be resolved

**Technical Notes:**
Phase 3 was still the wrong target: `baseEncumbrance` (per-species, e.g. chick = 10) was never meant to correlate with grams/kg in the first place — it's a fixed vanilla game-balance constant, not a mass. After Phase 3 shipped, user testing showed a ~30g chick still carrying at encumbrance 3 (`10 * 0.3`), which is what exposed this: the actual goal all along was for carry weight to track the animal's *real* weight, not to reproduce any vanilla carry-weight formula (baseEncumbrance-based or otherwise). `getRealWeight(item)` in `HoldAnimals_WeightUtils.lua` now reads `animal:getData():getWeight()` directly — the same number the in-world Animal Info panel shows (`ISAnimalUI.lua:109-112`) — with no `baseEncumbrance` and no equip-discount involved. This is a one-time snapshot at pickup (matching vanilla's own carry-weight, which also doesn't dynamically update while held), not a continuously-updating value; see Open Questions.

---

## Open Questions

1. **Is there a cleaner way to make the game treat the item as "equipped" for weight purposes, instead of manually pre-multiplying by the discount?**
   Investigated `isFakeEquipped()`/`getAttachedSlot()` (`InventoryItem.java:4291`, `:5405-5421`) as a possible alternative — both are narrowly scoped (key rings, hotbar-attached items respectively) and not a good fit for an animal sitting in a normal inventory slot. No cleaner hook was found. Recommendation: proceed with the pre-multiply approach from Phase 1.

2. **Should the rescale read `ZomboidGlobals.EquippedOrWornEncumbranceMultiplier` live, or cache it once?**
   Superseded by Phase 4 — the multiplier is no longer used at all.

3. **Should carried weight keep updating as the animal actually grows heavier while held (it continues to be simulated — `AnimalInventoryItem.update()` keeps ticking the underlying `IsoAnimal`), or stay a one-time snapshot from pickup?**
   Recommendation: leave it as a one-time snapshot for now (Phase 4, as implemented) — this matches vanilla's own carry-weight behavior, which also never updates after pickup. Revisit only if long-carry-duration weight drift turns out to matter in practice (e.g. carrying a chick for many in-game days while it's actively growing toward `hen`).

---

## Notes and Risks

- **Risk:** The idempotency guard relies on `getModData()` correctly persisting across save/load for `AnimalInventoryItem` — believed true (mod-data is standard PZ item persistence) but not yet confirmed in-game. If it doesn't persist, the discount would either double-apply (if the flag is lost but `applyNormalWeight` still no-ops incorrectly) or need re-derivation from a canonical source instead. Needs explicit testing: save, reload twice, check weight is stable on the second reload.
- **Risk:** `setCustomWeight(true)` side effects are still unverified beyond weight recalculation — worth a save/reload sanity check.
- **Out of scope for this cycle:** vehicle/trailer grab-to-inventory, batch pickup, MP verification. Same deferred scope as DC1.
- Depends on: [[DevCycle001]] (`doc/planning/completed/DevCycle001.md`) for the pickup action and context menu wiring this cycle modifies.

---

## Completion Summary

**Completion Date:** 2026-07-07
**Phases Completed:** Phase 1, Phase 2, Phase 3, Phase 4 (implementation only — not yet in-game verified)
**Work Deferred:** None for this cycle's scope.

**Accomplishments:**
- `HoldAnimals.WeightUtils.applyNormalWeight(item)`: sets a carried `Base.Animal` item's weight to the animal's real body weight (`animal:getData():getWeight()`), idempotently via mod-data. (Superseded two earlier formulas within this same cycle: first `baseEncumbrance * animalSize` discounted by the vanilla equip-rate, then `baseEncumbrance` alone discounted — see Phases 1-3.)
- `HoldAnimals.WeightUtils.applyToPlayer(playerObj)` + `OnCreatePlayer`/`OnGameStart` hooks: re-applies this recursively across a player's inventory after load, countering `AnimalInventoryItem.load()` resetting weight to vanilla's raw `baseEncumbrance * animalSize`.
- `ISHoldAnimalPickup:complete()` now calls `applyNormalWeight` on the newly created item before adding it to inventory.

**Metrics:**
- Files added: 1 (`HoldAnimals_WeightUtils.lua`)
- Files modified: 1 (`ISHoldAnimalPickup.lua`)

**Lessons / Notes:**
- This cycle took three formula iterations (Phases 1-2, then 3, then 4) to reach the actual goal. In hindsight, "carry weight tracking the animal's real weight" should have been asked directly and explicitly at the start of this cycle, rather than inferred from "encumbrance grew by an unreasonable amount" and later "just baseEncumbrance without the animal size" — both of which read as refinements to vanilla's carry-weight formula rather than a rejection of using that formula's basis (`baseEncumbrance`) at all.
- This has not yet been run in-game. Per project verification rules, status is `Work Complete`, not `Verified` — that requires user confirmation.
