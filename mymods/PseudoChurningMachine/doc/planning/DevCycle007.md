# DevCycle 007: Butter Generation via Inventory

**Status:** Planning
**Start Date:** 2026-09-13
**Target Completion:** TBD
**Focus:** At the end of a completed Turn On cycle, for every 5L of milk removed (per DevCycle 006), place 1 stick of butter directly into the Churning Machine's own item inventory.

---

## Goal

Implement Step 7 of `PseudoChurningMachinePlan.md`: "at the end of a cycle, for every 5L of milk removed, place 1 stick of butter directly into the Churning Machine's own item inventory (the 20-encumbrance capacity discovered in DevCycle 004). No fullness value, no 'Get Butter' menu item, and no debug testing items are needed — the player retrieves butter by opening/looting the object directly."

This cycle builds directly on DevCycle 006's completed-cycle milk removal — it does not re-derive the 5L-increment math, it hooks into the same removal point and adds a butter-per-5L-removed side effect.

## Desired Outcome

- When a cycle completes naturally and milk is removed (per DevCycle 006's `completedCycle` path), the Churning Machine gains 1 "Butter" item in its own item inventory for every 5L of milk actually removed.
- Example: 12L in the container at cycle end -> 10L removed (per DC006) -> 2 Butter items added, 2L milk remains.
- Example: 3L in the container at cycle end -> 0L removed -> 0 Butter items added.
- Example: 20L (full) at cycle end -> 20L removed -> 4 Butter items added, container ends empty.
- Manually selecting "Turn Off" before the cycle completes produces **no** butter, matching DevCycle 006's existing no-removal behavior on early manual stop.
- Butter is retrieved the normal way — opening/looting the Churning Machine's own item inventory — no new menu option, no fullness value, no debug testing items.
- DevCycle 004's fluid interactions, DevCycle 005's Turn On/Off toggle/milk gate/auto-stop timer, and DevCycle 006's milk-removal-on-completion all continue to work unaffected.

---

## Tasks

### Phase 1: Research and design

**Status:** Planning

- [ ] **Resolve the biggest open risk before writing any code: confirm what item-inventory access is actually available on the built `ChurningMachine` entity right now, and whether it's ours or borrowed.** `PseudoChurningMachinePlan.md`'s Deferred/Out of Scope section and `doc/planning/completed/DevCycle004.md` Phase 5 Part A both flag, as an **unconfirmed** hypothesis, that the entity's usable 20-encumbrance item inventory may actually belong to a real vanilla `IsoClothingWasher`/`IsoCombinationWasherDryer` object that the tile is secretly being reclassified into (via the vanilla `appliances_laundry_01_0` tile's own baked properties) — not anything `entity_ChurningMachine.txt` itself declares. DevCycle 004's own Lessons/Notes explicitly warned: "The plan's inventory-based butter design... is currently riding on borrowed, not owned, functionality." This cycle needs to either (a) confirm the entity can reliably fetch a usable `ItemContainer` right now (e.g. via `entity:getItemContainer()` or `entity:getContainerByType("clothingwasher")`, both real Java methods on `IsoObject` — `zombie42_20_4/iso/IsoObject.java:2499` and `:5382`) and proceed on that basis, explicitly documenting the dependency as inherited/provisional per DevCycle 004's own flag, or (b) if no container is reliably obtainable, escalate back to Ed rather than guessing at a new `component ItemContainer` addition to the entity script (which the Plan explicitly says is deferred until after Step 11's tile investigation).
- [ ] Confirm the `Butter` item's full type ID (`Base.Butter` — `media42_20_4/scripts/generated/items/food.txt:4535`) and that `ItemContainer:AddItem("Base.Butter")` is a valid, already-shipping Lua call shape (confirmed real usage elsewhere, e.g. `crate:getContainer():AddItem("Base.PetrolCan")` in `media42_20_4/lua/client/Tests/TimedActionsTests.lua:749`).
- [ ] Decide exactly where the butter-adding logic hooks in: inside `stopMachine`'s existing `if completedCycle then ... end` block (`ChurningMachineCode.lua:29-37`), using the same `removable` value DevCycle 006 already computes — not a second, independent recomputation of "how much milk was removed."
- [ ] Confirm the butter-count math: `local butterCount = removable / 5.0` (should always be a whole number once `removable` is itself a multiple of 5, per DevCycle 006's own math and its Phase 4 float-imprecision fix) — decide whether to add a defensive `math.floor`/rounding here too, given DevCycle 006's own lesson that float storage can't be trusted to be perfectly clean.
- [ ] Confirm whether `ItemContainer:AddItem` needs to be called once per butter stick in a loop, or whether a count/stack parameter exists — check for a bulk-add form before assuming a loop is required.
- [ ] Confirm capacity behavior: what happens if the item inventory doesn't have room for all the butter produced (20-encumbrance capacity, per DevCycle 004)? Decide whether overflow butter is simply dropped, silently fails, or needs explicit handling — don't assume `AddItem` always succeeds without checking.

**Technical Notes:**

### Phase 2: Implement

**Status:** Planning

- [ ] Add butter-placement logic to `ChurningMachineCode.lua`, hooked into the existing `completedCycle` branch of `stopMachine`, per Phase 1's decisions.
- [ ] No new context menu option, no fullness/percentage tracking, no debug testing items — per the Plan's explicit scope for this step.

**Technical Notes:**

### Phase 3: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [ ] Fill with 12L, run a full cycle to completion, confirm 2 Butter items appear in the Churning Machine's inventory and 2L milk remains.
- [ ] Fill with exactly 20L, run a full cycle to completion, confirm 4 Butter items appear and the container ends empty.
- [ ] Fill with less than 5L (e.g. 3L), run a full cycle to completion, confirm 0 Butter items are added.
- [ ] Start a cycle, manually select "Turn Off" before it completes, confirm 0 Butter items are added (matching DevCycle 006's no-removal behavior).
- [ ] Confirm butter is retrievable by opening/looting the Churning Machine normally — no new menu option was added.
- [ ] Confirm DevCycle 004/005/006 behaviors are all still unaffected.
- [ ] If Phase 1 found the item inventory is riding on borrowed vanilla-appliance functionality, note whether that dependency behaved reliably during this testing, since it remains unresolved risk carried forward from DevCycle 004.

**Technical Notes:**

---

## Notes and Risks

- **Primary risk, inherited from DevCycle 004, not new to this cycle:** the item inventory this step depends on may not actually belong to the Churning Machine's own entity definition — it may be borrowed from a real vanilla washer/dryer classification that hasn't been confirmed or fixed (deferred to post-Step-11 per the Plan). If that hypothesis is later confirmed and fixed, this cycle's butter-placement code may need to be revisited once an explicit, mod-owned `component ItemContainer` is added.
- This cycle does not touch audio (deferred to Step 11), the Wash Menu/tile-reclassification question (deferred to post-Step-11), or "Add Liquid from Item" (deferred to DC 11).
- Sheep's milk mixing remains out of scope — cow's milk only, per the Plan.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
