# DevCycle 001: Basic Multi-Animal Pickup

**Status:** Verified
**Start Date:** 2026-07-07
**Target Completion:** TBD
**Focus:** Let the player pick up an animal into inventory (instead of both hands) without altering its weight, primarily to make moving chicks around practical.

---

## Goal

Right now, vanilla Project Zomboid lets a player carry exactly one animal at a time, held in both hands via the vanilla pickup action. This DevCycle implements HoldAnimals' core feature: picking up an animal into a normal inventory container (main inventory or a worn bag) instead of the hand slots, so the player can carry more than one animal simultaneously. Unlike Backpack Barnyard (analyzed in `doc/ideas/claude_BackpackBarnyardAnalysis.md`), HoldAnimals will not zero out or otherwise modify animal item weight — vanilla weight and encumbrance rules apply as-is. This keeps the feature naturally scoped to light animals (chicks) rather than turning livestock into weightless cargo.

## Desired Outcome

A player can right-click a nearby animal, choose "Pick Up Animal" (or similar), and have it placed into their inventory as a `Base.Animal` item — freeing both hands — using unmodified vanilla item weight. The player can repeat this for a second, third, etc. animal, limited only by normal carry weight/encumbrance. No vehicle/trailer integration, no batch pickup, and no weight manipulation in this cycle.

---

## Tasks

### Phase 1: Single Animal Pickup-to-Inventory Action

**Status:** Work Complete

- [x] Create a timed action (`ISHoldAnimalPickup`) modeled on vanilla's own `ISPickupAnimal.lua`, minus the hand-forcing calls
- [x] On `complete()`, instance a `Base.Animal` item (`instanceItem("Base.Animal")`), call `setAnimal(animal)`, and `AddItem()` it into the player's main inventory
- [x] Clear the animal from the world/square (`removeFromWorld`, `removeFromSquare`, `setSquare(nil)`) and detach it from any attached-player state, mirroring vanilla pickup cleanup
- [x] Ensure the action does not force the new item into a hand slot
- [x] Verify vanilla item weight for `Base.Animal` is left untouched — no custom weight setters called anywhere in this action

**Technical Notes:**
Once the actual vanilla source was located (`media/lua/shared/TimedActions/Animals/ISPickupAnimal.lua` — this ships with the base game, distinct from Backpack Barnyard's client-side copy of the same name), it turned out to be the better reference than Backpack Barnyard, since it's the exact action already wired into every vanilla pickup entry point.

Implemented at `mymods/HoldAnimals/HoldAnimals/42/media/lua/shared/TimedActions/Animals/ISHoldAnimalPickup.lua`. It is a line-for-line copy of vanilla `ISPickupAnimal` with two omissions in `complete()`:
- `forceDropHeavyItems(self.character)` — vanilla drops other heavy items to make room in hand slots for the animal; not needed since the animal never occupies a hand slot here.
- `self.character:setPrimaryHandItem(nil/invItem)` / `setSecondaryHandItem(nil/invItem)` — this is the actual mechanism that limited vanilla to one carried animal: each pickup unequips whatever was in hand and re-equips the new animal into both hands. The item was always added to inventory either way (`AddItem`), so omitting these two lines is the entire fix — inventory items are unaffected, hands stay free, and multiple `Base.Animal` items can coexist in inventory.
- No weight setters at all (vanilla already sizes `Base.Animal` weight as `baseEncumbrance * animalSize` in `AnimalInventoryItem.initAnimalData()`, in Java) — chicks/babies get small `animalSize`, so they're cheap to carry without any mod intervention. `canBePicked()` (`IsoAnimal.java`) only gates on `adef.canBePicked` and a weight-vs-strength check — it does not care whether the player is already holding an animal.

### Phase 2: Context Menu Integration

**Status:** Work Complete

- [x] Wire the existing vanilla "Pick Up Animal" entry points (world context menu submenu and the animal radial menu) to queue `ISHoldAnimalPickup` instead of vanilla `ISPickupAnimal`

**Technical Notes:**
Implemented at `mymods/HoldAnimals/HoldAnimals/42/media/lua/client/HoldAnimals/HoldAnimals_PickupOverride.lua`.

Deviated from the plan's original approach (hook `OnFillWorldObjectContextMenu` and/or wrap `AnimalContextMenu.doMenu` to add a *new* "Pick Up Animal" option, following Backpack Barnyard's pattern). Reading vanilla `ISAnimalContextMenu.lua` showed both the world submenu (`AnimalContextMenu.doMenu`) and the radial menu (`AnimalContextMenu.showRadialMenu`) already build their "Pick Up Animal" option by calling a single shared function, `AnimalContextMenu.onPickupAnimal`. Overriding that one function to queue `ISHoldAnimalPickup` instead of `ISPickupAnimal` covers every vanilla pickup entry point at once, with no duplicate menu entries and no need to reimplement animal-collection/distance-check logic vanilla already has. This is simpler than the planned approach and was used instead.

---

## Open Questions

1. **Does Phase 1 need a full timed action, or can chick pickup be instant?**
   Recommendation: Keep the timed action (short duration is fine, e.g. reuse vanilla's ~30-tick pickup time) for consistency with vanilla animal-handling feel and to reuse the existing `ISBaseTimedAction` pattern cleanly. Duration can be tuned later.

2. **Is a small-radius "pick up nearby chicks" batch option in scope for this cycle, or deferred?**
   Recommendation: Defer to a future DevCycle. Phase 1+2 alone (single pickup, repeatable) already satisfies "hold more than one animal." Batch pickup is a convenience layer, not core to the goal, and pulling in `BB_SPBatchPickupAnimals.lua`-style radius scanning adds scope this cycle doesn't need yet.

---

## Notes and Risks

- **Risk:** Since `ISHoldAnimalPickup` never equips the animal into a hand slot, any vanilla/UI code that expects a carried animal to be reachable via `getPrimaryHandItem()`/`getSecondaryHandItem()` (rather than found via inventory search) won't see it. Not observed as an issue in the read code (`AnimalContextMenu.doInventoryMenu`, feed/water/kill-from-inventory flows all operate on the `Base.Animal` item itself, not hand slots), but worth watching for in play-testing.
- **Risk:** `sendPickupAnimal` is called unmodified for MP sync; this cycle hasn't been tested in multiplayer.
- **Out of scope for this cycle:** vehicle/trailer grab-to-inventory, batch pickup, "Move Animal To" submenu, any weight modification. These may become later DevCycles if desired.
- Depends on: `doc/ideas/claude_BackpackBarnyardAnalysis.md` for the initial reference analysis; superseded in practice by vanilla's own `ISPickupAnimal.lua`/`ISAnimalContextMenu.lua` once those were found (see Phase 1/2 Technical Notes).

---

## Completion Summary

**Completion Date:** 2026-07-07
**Phases Completed:** Phase 1, Phase 2 (implementation only — not yet in-game verified)
**Work Deferred:** None for this cycle's scope; batch pickup and trailer/MP support remain open questions for a future cycle.

**Accomplishments:**
- `ISHoldAnimalPickup` timed action: picks an animal up into inventory without forcing hand slots and without touching item weight.
- `AnimalContextMenu.onPickupAnimal` override: routes every existing vanilla "Pick Up Animal" entry point (world context menu, radial menu) through the new action.

**Metrics:**
- Files added: 2 (`ISHoldAnimalPickup.lua`, `HoldAnimals_PickupOverride.lua`)

**Lessons / Notes:**
- The most useful reference turned out to be vanilla's own `media/lua/shared/TimedActions/Animals/ISPickupAnimal.lua` and `media/lua/client/ISUI/Animal/ISAnimalContextMenu.lua`, not the Backpack Barnyard mod — worth checking for a vanilla equivalent before leaning on a third-party mod as the primary reference next time.
- The one-line-of-reasoning root cause: vanilla already lets multiple `Base.Animal` items sit in inventory simultaneously (nothing in `IsoAnimal.canBePicked()` or `AnimalInventoryItem` prevents it); the *only* thing stopping multi-animal carrying was `ISPickupAnimal:complete()` unconditionally re-equipping the newest animal into both hand slots on every pickup. Removing that reassignment was sufficient — no weight utility, batch-pickup scanner, or new menu was needed to hit this cycle's goal.
- This has not yet been run in-game. Per project verification rules, status is `Work Complete`, not `Verified` — that requires user confirmation.
