# DevCycle 004: Magic Screwdriver and Ring Fire Starting

**Status:** VERIFIED
**Start Date:** 2026-11-12
**Target Completion:** TBD
**Focus:** Add a Magic Screwdriver that follows the same rules as the DevCycle 003 magic tools: half weight, a Dismiss menu, and summonable from the Ring of the Mage. Also give the Ring of the Mage the tags that let it start fires.

---

## Goal

Add the Magic Screwdriver to the mod using the same approach as the nine tools from DevCycle 003: a copy of the vanilla item at half weight, with a "Dismiss Magic Screwdriver" option and a place in the Ring of the Mage's Summon submenu.

## Desired Outcome

- A Magic Screwdriver exists, identical to the vanilla `Screwdriver` except for half the weight and the "Magic" name.
- Right-clicking it shows "Dismiss Magic Screwdriver", which deletes it from inventory.
- The Ring of the Mage carries the tags `base:startfire` and `base:hasmetal` and works as a fire starter that never runs out (see Phase 4: `UseDelta = 0` was tried and failed).
- The Ring of the Mage's "Summon" submenu includes "Screwdriver", which adds a Magic Screwdriver to the inventory.

---

## Tasks

### Phase 1: Magic Screwdriver Item and Dismiss Menu

**Status:** Work Complete

- [x] Define `MagicScrewdriver` in `PseudoMagic_Items.txt` as a copy of vanilla `Screwdriver` (weapon.txt:18169) with `Weight` halved from 0.5 to 0.25
- [x] Keep every other property (stats, `Tags = base:screwdriver;base:hasmetal`, attachment type, sounds, models, icons) identical to vanilla; drop `Researchablerecipes`, as for the other magic tools
- [x] Add `PseudoMagic.MagicScrewdriver` = "Magic Screwdriver" to `ItemName.json`
- [x] Add `UI_PseudoMagic_DismissMagicScrewdriver` = "Dismiss Magic Screwdriver" to `UI.json`
- [x] Add the item to the `MAGIC_ITEMS` table in `PseudoMagicMenu.lua` (this provides the Dismiss option)

**Technical Notes:**
Generate the definition from the vanilla block the same way as the DC 3 tools: change the ID, halve `Weight`, remove `Researchablerecipes`, and indent to match the file. Vanilla uses `IconsForTexture = Screwdriver_Blue;Screwdriver`, copied as-is. The existing dismiss logic is reused unchanged.

### Phase 2: Summon from the Ring of the Mage

**Status:** Work Complete

- [x] Add "Screwdriver" to the ring's Summon submenu (driven by the same `MAGIC_ITEMS` entry)
- [x] Add `UI_PseudoMagic_SummonScrewdriver` = "Screwdriver" to `UI.json`

**Technical Notes:**
The Summon submenu and Dismiss options are both built from `MAGIC_ITEMS`, so one table entry plus the text keys covers both phases' menu work. Summoned items are added to the main inventory and synced for multiplayer, as before.

### Phase 3: Ring of the Mage Fire-Starting Tags

**Status:** Work Complete

- [x] Add the tag `base:startfire` to all four Ring of the Mage finger variants in `PseudoMagic_Items.txt`
- [x] Ensure the tag `base:hasmetal` is present on all four (it already is)
- [x] ~~Add `UseDelta = 0` to all four variants~~ (tried; had no effect, replaced in Phase 4)
- [x] Keep the existing `base:tinygoldscrap` tag (see Open Questions)

**Technical Notes:**
Current ring tags: `Tags = base:hasmetal;base:tinygoldscrap`. Target: `Tags = base:hasmetal;base:tinygoldscrap;base:startfire`, plus `UseDelta = 0`. Vanilla fire-starting checks use `ItemTag.START_FIRE` (for example `ISWorldObjectContextMenu.lua:1653` and `ISCampingMenu.lua:117`). The camping check also requires `item:getCurrentUses() > 0`; in `InventoryItem.java` a non-drainable item defaults to `uses = 1`, so the ring should pass it. Vanilla start-fire items (`Lighter`, `Matches`) are `base:drainable`, with `UseDelta` 0.03125 and 0.1; the ring is `base:clothing`, so whether a `UseDelta` of 0 is honored, and whether fire starting consumes anything from a non-drainable item, must be confirmed in testing.

### Phase 4: Make the Ring a Non-Consumable Fire Starter

**Status:** Work Complete

Added after in-game testing showed that starting a fire with the ring deleted it.

- [x] Remove `UseDelta = 0` from all four ring variants
- [x] Add `KeepOnDeplete = true` to all four ring variants
- [x] Add `PseudoMagicRingRefill.lua` (client), which resets a ring at 0 uses back to 1

**Technical Notes:**
Root cause: fire-starting actions call `UseAndSync()` on the starter (`ISLightFromLiterature.lua:59`, `ISLightFromPetrol.lua:45`). The ring is a non-drainable `Clothing` item with `uses = 1`, so `InventoryItem.Use` (`InventoryItem.java:~1316`) took it to 0 and removed it. `UseDelta` is only read by `DrainableComboItem`, so it did nothing on the ring. Making the ring drainable is not an option: the item class follows `ItemType`, and a drainable ring would no longer be wearable clothing.

Fix: `KeepOnDeplete = true` makes `Use()` return early at 0 uses instead of removing the item. That alone would leave the ring at 0 uses, and `ISCampingMenu.lua:117` requires `getCurrentUses() > 0`, so the camping menu would stop offering it after one fire. The refill script scans the player's inventory for `START_FIRE` items every 10 ticks (`OnPlayerUpdate`) and sets any ring at 0 uses back to 1.

Known risk: a short window (up to 10 ticks) exists right after a fire where the ring reads 0 uses. Testing must include starting two fires back to back.

### Phase 5: Fix Ring Refill Script Error

**Status:** In Progress

Added after in-game testing of Phase 4 produced a Lua error on every refill scan.

- [x] Fix the `getAllTagRecurse` call in `PseudoMagicRingRefill.lua:17` so it passes the required result list
- [ ] Redeploy and confirm the console log no longer shows the error
- [ ] Re-test the Phase 4 behavior (ring survives a fire and is offered again)

**Technical Notes:**
Console error (repeats from `onPlayerUpdate`):

```
ERROR: General      f:10 at KahluaThread.flushErrorMessage      > expected 2 arguments, got 1
    Lua((MOD:PseudonymousEd's Magic Items)).refillRings(PseudoMagicRingRefill.lua:17)
    Lua((MOD:PseudonymousEd's Magic Items)).onPlayerUpdate(PseudoMagicRingRefill.lua:30)
```

Cause: line 17 calls `getInventory():getAllTagRecurse(ItemTag.START_FIRE)` with one argument. In `ItemContainer.java:1736` the only tag overload is `getAllTagRecurse(ItemTag itemTag, ArrayList<InventoryItem> result)`, which takes two. (`getAllTypeRecurse` has a one-argument overload at line 1931; the tag version does not.) Because the error fires inside the refill scan, the ring is never refilled, so Phase 4's fix is not yet working. Fix applied: line 17 now passes `ArrayList.new()` as the second argument, the same pattern vanilla uses (`ISAnimalContextMenu.lua:246`). Redeploy and re-test are pending, so the phase stays In Progress. The Phase 4 design is otherwise unchanged.

### Phase 6: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Confirm the Magic Screwdriver spawns with the right name, icon, and 0.25 weight
- [ ] Confirm it works wherever a vanilla screwdriver does (crafting, disassembling, electronics, vehicle work) and is accepted by recipes
- [ ] Confirm "Dismiss Magic Screwdriver" appears only on it and deletes it (held, in inventory, and in a bag)
- [ ] Confirm the ring's Summon submenu lists "Screwdriver" and adds the item
- [ ] Confirm the ring (worn and carried) lets the player light a campfire or other fire and is never used up
- [ ] Confirm two fires in a row work with the same ring (refill timing), and that burning a corpse also works
- [ ] Confirm no per-tick performance hit with many items in inventory
- [ ] Confirm the ring still wears normally on all four fingers
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

1. **Is the weight 0.25 acceptable?**
   Half of the vanilla 0.5 is exactly 0.25, so no rounding is needed. Recommendation: use 0.25.

2. **Keep `base:tinygoldscrap` on the ring?**
   The request lists `base:startfire;base:hasmetal`. Recommendation: keep the existing `base:tinygoldscrap` and add `base:startfire`, so the ring changes only by addition.

3. **Does `UseDelta = 0` work on a clothing item?**
   Resolved: no. It has no effect on a non-drainable item, and the ring was consumed. Replaced by `KeepOnDeplete` plus a refill script (Phase 4).

---

## Notes and Risks

- Risk: the refill script polls every 10 ticks; if the camping menu opens inside that gap the ring may be missing from the starter list. Verify in testing.
- Risk: a recipe or action that names `Base.Screwdriver` by item ID instead of the `base:screwdriver` tag will reject the magic version. Check during testing and record any failure.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 003 (magic tool pattern, `MAGIC_ITEMS` table in `PseudoMagicMenu.lua`).

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** [YYYY-MM-DD]
**Phases Completed:** [List or "All"]
**Work Deferred:** [What was not done and why, or "None"]

**Accomplishments:**
- [What was built or changed]

**Metrics:**
- Files modified: [N]

**Lessons / Notes:**
[Anything worth remembering for future cycles.]
