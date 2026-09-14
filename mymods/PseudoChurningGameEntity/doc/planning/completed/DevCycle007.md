# DevCycle 007: Butter Generation via Inventory

**Status:** Verified (2026-09-13) — Ed confirmed all Phase 3 tests pass
**Start Date:** 2026-09-13
**Target Completion:** 2026-09-13
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

**Status:** Work Complete

- [x] **Resolve the biggest open risk before writing any code: confirm what item-inventory access is actually available on the built `ChurningMachine` entity right now, and whether it's ours or borrowed.** — **Confirmed our own entity script grants no item container at all; if one exists in-game it is borrowed, per DevCycle 004's unconfirmed hypothesis, not proven false or true here.** See notes below — this narrows the risk but does not eliminate it without an in-game check.
- [x] Confirm the `Butter` item's full type ID and that `ItemContainer:AddItem("Base.Butter")` is a valid, already-shipping Lua call shape.
- [x] Decide exactly where the butter-adding logic hooks in.
- [x] Confirm the butter-count math and whether defensive rounding is warranted.
- [x] Confirm whether `ItemContainer:AddItem` needs to be called once per butter stick in a loop, or whether a count/stack parameter exists.
- [x] Confirm capacity behavior: what happens if the item inventory doesn't have room for all the butter produced.

**Technical Notes:**

**Item-container risk — narrowed, not eliminated: re-reading `entity_ChurningMachine.txt` in full confirms it declares no item-container-granting component whatsoever.** The entity has `UiConfig`, `ContextMenuConfig`, `FluidContainer`, `SpriteConfig`, and `CraftRecipe` — nothing else. Broadening the search, **no scripted `entity` anywhere in `media42_20_4/scripts/generated/entities/` declares any kind of item-container component either** (grepping for `component Container`/`ContainerConfig`/`ItemContainerScript` across that whole directory returns nothing) — item inventories on world objects appear to be an exclusively hardcoded-Java-class feature in this engine version, not something the scripted-entity system exposes at all. This is new, concrete evidence directly relevant to DevCycle 004's unconfirmed hypothesis: it means there is no path by which our entity script could be granting itself an item container "by accident" through some overlooked scripted mechanism — **if the built object does have a working item inventory, it can only be because it's genuinely being treated as the real hardcoded `IsoClothingWasher`/`IsoCombinationWasherDryer` class**, exactly as DevCycle 004 Phase 5 Part A theorized. This still isn't a live in-game confirmation (that requires Phase 3 testing), but it does rule out "our own script is unintentionally granting a container" as an alternative explanation — strengthening rather than replacing the existing hypothesis.

**Decision: proceed on the existing (borrowed, unconfirmed-but-strengthened) container, accessed via `entity:getItemContainer()`, and treat a missing container defensively rather than assuming it's always present.** `IsoObject.getItemContainer()` (`zombie42_20_4/iso/IsoObject.java:2499-2501`) is a plain public getter returning the object's `container` field, and is confirmed as a real, already-shipping Lua call shape via many vehicle-part/bag examples (e.g. `media42_20_4/lua/shared/Items/SpawnItems.lua:151` — `bag:getItemContainer():AddItem("Base.BaseballBat")`). Since our own script grants nothing, this is the only candidate. The code must check for `nil` before using it (`if itemContainer then ... end`) rather than assuming it always exists, since the underlying mechanism is unconfirmed and, per the Plan's own deferred item, may not survive if Step 11+'s tile investigation changes the entity's classification later.

**`Base.Butter` and `AddItem` — both confirmed real.** `media42_20_4/scripts/generated/items/food.txt:4535` declares `item Butter { ItemType = base:food, ... }`, giving the full type ID `Base.Butter`. `ItemContainer:AddItem(String type)` (`zombie42_20_4/inventory/ItemContainer.java:547`) is a real Java method, and the exact Lua call shape `container:AddItem("Base.X")` is already shipping in multiple places (`media42_20_4/lua/shared/Items/SpawnItems.lua:151`, `media42_20_4/lua/client/Tutorial/Steps.lua:1327` among others).

**Hook point — decided: inside `stopMachine`'s existing `completedCycle` branch, reusing `removable`.** `ChurningMachineCode.lua:29-37` (DevCycle 006) already computes `removable` and calls `fluidContainer:removeFluid(removable, false)` only when `completedCycle` is true and `removable > 0`. Butter placement belongs in that same `if removable > 0 then ... end` block, right after the `removeFluid` call, using the same `removable` value — not a separate re-derivation of how much milk was consumed.

**Butter-count math — `removable / 5.0`, with defensive rounding kept given DevCycle 006's own lesson.** Since `removable` is already the *output* of DevCycle 006's Phase 4 epsilon-floor fix (`math.floor(amount / 5.0 + 0.0001) * 5.0`), it should always be a clean multiple of 5 in principle — but `removable / 5.0` is itself a fresh floating-point division that could in theory yield something like `1.9999999` instead of a clean `2`. Decision: apply the same defensive pattern DevCycle 006 already established rather than trusting the division to be exact — `local butterCount = math.floor(removable / 5.0 + 0.0001)`.

**`AddItem` requires a loop — confirmed no bulk/count form exists.** `ItemContainer.java` declares `AddItem(InventoryItem)`, `AddItem(String type)`, and two `AddItem(String type, float useDelta[, boolean synchSpawn])` overloads (lines 467, 547, 593, 617) — every one adds exactly one item and none accepts a quantity/count. A `for i = 1, butterCount do itemContainer:AddItem("Base.Butter") end` loop is required.

**Capacity/overflow — confirmed `AddItem(String type)` does not enforce any weight/encumbrance cap, so no overflow-handling code is needed.** Read `ItemContainer.AddItem(InventoryItem item)` in full (`ItemContainer.java:467-506`, the method the string-based overload ultimately calls): it unconditionally appends to `this.items` with no capacity or weight check anywhere in its body. The only method in this class that *does* check weight against capacity is the separate `AddItemBlind(InventoryItem item)` (`ItemContainer.java:516-535`, `if (item.getWeight() + this.getCapacityWeight() > this.getCapacity()) return null;`), which is a different method this cycle has no reason to use. **Decision: don't add any overflow-prevention logic — call `AddItem("Base.Butter")` in a plain loop and let it succeed unconditionally, matching how every other vanilla `AddItem` call site in the codebase behaves.** This does mean a full 20L cycle (4 butter sticks, ~1.2kg per the item's `Weight = 0.3` in `food.txt:4539`) could in principle push the container's displayed weight over its nominal capacity, but that's consistent with vanilla's own general looseness here (many containers can be over-stuffed via scripted `AddItem`), not a gap specific to this feature, and matches the Plan's explicit instruction to keep this step simple (no fullness value, no debug items).

### Phase 2: Implement

**Status:** Work Complete — implementation done, in-game verification pending (Phase 3)

- [x] Add butter-placement logic to `ChurningMachineCode.lua`, hooked into the existing `completedCycle` branch of `stopMachine`, per Phase 1's decisions.
- [x] No new context menu option, no fullness/percentage tracking, no debug testing items — per the Plan's explicit scope for this step.

**Technical Notes:**

Implemented exactly per Phase 1's decisions (`ChurningMachineCode.lua:29-42`), nested inside the existing `if removable > 0 then` block right after `fluidContainer:removeFluid(removable, false)`:
```lua
local itemContainer = entity:getItemContainer()
if itemContainer then
    local butterCount = math.floor(removable / 5.0 + 0.0001)
    for i = 1, butterCount do
        itemContainer:AddItem("Base.Butter")
    end
end
```
- Reuses `removable` directly — no separate recomputation of how much milk was consumed.
- `entity:getItemContainer()` is checked for `nil` before use, per Phase 1's decision to treat the borrowed/unconfirmed container defensively — if it's ever absent (e.g. the object isn't actually being reclassified the way DevCycle 004 theorized), butter is silently skipped rather than crashing, and the milk is still removed either way.
- No overflow/capacity check was added, per Phase 1's finding that `AddItem(String)` doesn't enforce one and no other vanilla call site does either.
- No new context menu option, fullness value, or debug items were added — this phase touched only `stopMachine`'s existing `completedCycle` branch.

### Phase 3: In-game verification

**Status:** Verified — Ed confirmed all tests pass

- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] Fill with 12L, run a full cycle to completion, confirm 2 Butter items appear in the Churning Machine's inventory and 2L milk remains.
- [x] Fill with exactly 20L, run a full cycle to completion, confirm 4 Butter items appear and the container ends empty.
- [x] Fill with less than 5L (e.g. 3L), run a full cycle to completion, confirm 0 Butter items are added.
- [x] Start a cycle, manually select "Turn Off" before it completes, confirm 0 Butter items are added (matching DevCycle 006's no-removal behavior).
- [x] Confirm butter is retrievable by opening/looting the Churning Machine normally — no new menu option was added.
- [x] Confirm DevCycle 004/005/006 behaviors are all still unaffected.
- [x] If Phase 1 found the item inventory is riding on borrowed vanilla-appliance functionality, note whether that dependency behaved reliably during this testing. — **It behaved reliably: `entity:getItemContainer()` returned a usable container and `AddItem("Base.Butter")` worked every time butter was expected.** This is the first live, in-game confirmation that the container Step 7 depends on is actually reachable and functional — it does not confirm or refute *why* it exists (DevCycle 004's borrowed-vanilla-classification hypothesis remains otherwise untested), only that it's currently reliable to use.

**Technical Notes:**

All cases passed, including the borrowed-container dependency flagged as this cycle's primary risk in Phase 1 — see the last checklist item above.

---

## Notes and Risks

- **Primary risk, inherited from DevCycle 004, not new to this cycle:** the item inventory this step depends on may not actually belong to the Churning Machine's own entity definition — it may be borrowed from a real vanilla washer/dryer classification that hasn't been confirmed or fixed (deferred to post-Step-11 per the Plan). If that hypothesis is later confirmed and fixed, this cycle's butter-placement code may need to be revisited once an explicit, mod-owned `component ItemContainer` is added.
- This cycle does not touch audio (deferred to Step 11), the Wash Menu/tile-reclassification question (deferred to post-Step-11), or "Add Liquid from Item" (deferred to DC 11).
- Sheep's milk mixing remains out of scope — cow's milk only, per the Plan.

---

## Completion Summary

**Completion Date:** 2026-09-13

**Phases Completed:** 1-3, all Verified. Every line of the Desired Outcome was tested and confirmed working — no unmet goals.

**Work Deferred:** None new. Pre-existing deferrals (audio to Step 11, Wash Menu/tile-reclassification to post-Step-11, "Add Liquid from Item" to DC 11) were untouched and out of scope, as planned.

**Accomplishments:**
- Butter generation wired directly into DevCycle 006's existing completed-cycle milk-removal path — 1 stick of "Base.Butter" per 5L of milk removed, added to the Churning Machine's own item inventory via `entity:getItemContainer():AddItem(...)`.
- Verified exact test cases: 12L->2 butter (2L remains), 20L->4 butter (empty), <5L->0 butter, manual early "Turn Off"->0 butter.
- Confirmed butter is retrievable the normal way (opening/looting the object) with no new menu option added, matching the Plan's explicit simplicity requirement.
- Confirmed DevCycle 004/005/006 behaviors all remain unaffected.
- **First live confirmation that the item-inventory dependency flagged since DevCycle 004 is currently reliable to use** — `getItemContainer()` returned a working container in every test, and `AddItem` succeeded every time. This doesn't resolve *why* the container exists (the borrowed-vanilla-classification hypothesis is still otherwise unconfirmed and still deferred to post-Step-11), but it confirms the mechanism this cycle needed actually works today.

**Metrics:** 1 in-game test round, all cases passed on the first attempt — no bugs found or fixed this cycle (unlike DevCycle 006's float-imprecision surprise).

**Lessons / Notes:**
- Building on a previous cycle's exact hook point and reused variable (DevCycle 006's `removable`) rather than re-deriving the same value avoided introducing a second source of truth for "how much milk was consumed" — worth continuing for Step 10's cycle-time change and any future steps that touch the same `stopMachine` function.
- The item-inventory risk flagged in Phase 1 (borrowed, unconfirmed vanilla-appliance container) did not block this cycle in practice, but it's still an open question for the Plan's post-Step-11 tile investigation — if that investigation later replaces the borrowed container with an explicit mod-owned one, this cycle's `entity:getItemContainer()` call should keep working unchanged (it's a generic accessor, not tied to any specific implementation), but it's worth re-testing butter placement once that investigation lands.
