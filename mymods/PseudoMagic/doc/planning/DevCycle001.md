# DevCycle 001: Initial Magic Items

**Status:** VERIFIED
**Start Date:** 2026-11-11
**Target Completion:** TBD
**Focus:** Implement the first three PseudoMagic items: Satchel of Holding, Pouch of Holding, and Magic Knife (with a "Dismiss" context menu option).

---

## Goal

Establish the PseudoMagic mod's content with the three items defined in `doc/ideas/magicitems.txt`. Two are bags derived from vanilla containers with large capacity and heavy weight reduction; one is a powerful knife that the player can dismiss (delete) from inventory via a context menu entry.

## Desired Outcome

- The player can obtain (at minimum via debug/item spawn) a Satchel of Holding, Pouch of Holding, and Magic Knife.
- The bags behave like their vanilla counterparts (equip slots, models, sounds) but with the specified capacity and weight reduction.
- The Magic Knife has the specified combat stats and a working "Dismiss" right-click option that removes it from inventory.
- The mod loads cleanly in-game (B42) with no console errors.

---

## Tasks

### Phase 1: Mod Scaffolding

**Status:** Work Complete

- [x] Verify mod structure under `PseudoMagic/42/` (`mod.info`, `poster.png`) and add `media/scripts/`, `media/lua/client/`, and translation folders as needed
- [x] Confirm `mod.info` fields (id `PseudonymousEdMagic`, name, description) are correct
- [x] Choose a module name / item-ID prefix for the new items and apply it consistently

**Technical Notes:**
Item scripts go in `media/scripts/`. Vanilla reference definitions (v42.20.4) are in `media42_20_4/scripts/generated/items/container.txt` and `weapon.txt`. Use `utilities/CopyModToZomboid.bat PseudoMagic` to deploy for testing.

### Phase 2: Satchel of Holding

**Status:** Work Complete

- [x] Define the item based on vanilla `Bag_HideSatchel` (container.txt:5545)
- [x] Set `Capacity = 50` and `WeightReduction = 95`
- [x] Give it a distinct display name (and icon if feasible; otherwise reuse the vanilla icon)
- [ ] Verify equip (satchel slot), model, and sounds work (in-game, Phase 5)

**Technical Notes:**
Vanilla values: `Capacity = 12`, `WeightReduction = 65`, `CanBeEquipped = base:satchel`, `ClothingItem = Bag_HideSatchel`, `ReplaceInPrimaryHand/SecondHand` models. Reusing the vanilla `ClothingItem` keeps the model and clothing XML without new assets. B42 uses `ItemType = base:container` syntax and namespaced values (e.g. `base:satchel`).

### Phase 3: Pouch of Holding

**Status:** Work Complete

- [x] Define the item based on vanilla `Bag_FannyPackFront_Hide` (container.txt:5409)
- [x] Set `Capacity = 20` and `WeightReduction = 95`
- [x] Decide how to handle the back-wear variant (`ClothingItemExtra = Base.Bag_FannyPackBack_Hide`, `ClothingExtraSubmenu`)
- [ ] Verify equip (front fanny-pack slot) and the front/back wear options (in-game, Phase 5)

**Technical Notes:**
Vanilla values: `Capacity = 1`, `WeightReduction = 65`, `CanBeEquipped = base:fannypackfront`. The vanilla item references a separate `Bag_FannyPackBack_Hide` item for the back variant; a magic equivalent may need its own back item (also 20/95) so the capacity carries over when worn on the back.

### Phase 4: Magic Knife

**Status:** Work Complete

- [x] Define the item based on vanilla `LargeKnife` (weapon.txt:17303)
- [x] Apply overrides: `ConditionLowerChanceOneIn = 99`, `ConditionMax = 99`, `CritDmgMultiplier = 3.0`, `CriticalChance = 50.0`, `MaxDamage = 3`
- [x] Ensure `MinDamage` is consistent with the new `MaxDamage` (see Open Questions)
- [x] Add an inventory context-menu option "Dismiss" for the Magic Knife only
- [x] "Dismiss" removes the knife from the player's inventory (including when it is equipped or inside a container); handle multiplayer correctly
- [x] Add translation entries for the item name and the "Dismiss" menu text

**Technical Notes:**
Vanilla `LargeKnife`: `ConditionLowerChanceOneIn = 15`, `ConditionMax = 10`, `CritDmgMultiplier = 3.0` (unchanged), `CriticalChance = 30.0`, `MaxDamage = 1.1`. Context menu via `Events.OnFillInventoryObjectContextMenu`; check the item's full type, then add the option. Removal must unequip from hands first if held.

### Phase 5: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load the mod in a B42 test save
- [ ] Spawn each item (debug item list) and confirm names, icons, and stats
- [ ] Confirm bag capacities, weight reduction, and equip behavior
- [ ] Confirm knife damage/crit behavior and condition durability
- [ ] Confirm "Dismiss" appears only on the Magic Knife and deletes it
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Implementation Notes

- Items: `PseudoMagic/42/media/scripts/items/PseudoMagic_Items.txt` (SatchelOfHolding, PouchOfHolding, PouchOfHoldingBack, MagicKnife). MinDamage kept at vanilla 0.6; Pouch has a back-wear item; no confirmation on Dismiss; items are debug-spawn only.
- Dismiss menu: `media/lua/client/PseudoMagic/PseudoMagicMenu.lua`.
- Translations: `media/lua/shared/Translate/EN/ItemName.json`, `UI.json`.
- Not yet run in-game; no icons/models of their own (vanilla reused).

## Open Questions

1. **How does the player obtain the items?**
   Recommendation: Out of scope for this cycle; spawn via debug only. Add a recipe or loot distribution in a later DevCycle.

2. **What should `MinDamage` be for the Magic Knife?**
   `magicitems.txt` only specifies `MaxDamage = 3`. Vanilla `LargeKnife` has a `MinDamage` below its 1.1 max. Recommendation: Keep the vanilla `MinDamage` unless it exceeds 3, otherwise pick a value slightly under 3. Confirm with Ed.

3. **Is the 95 weight reduction safe at high capacity?**
   Recommendation: Implement as specified; note that the Satchel (50) and Pouch (20) are intentionally powerful.

4. **Should "Dismiss" ask for confirmation?**
   Recommendation: No confirmation, matching the spec ("If selected, the Magic Knife is deleted"). Revisit if accidental deletion is a concern.

5. **Does the Pouch need a separate back-wear item?**
   Recommendation: Yes, mirror the vanilla front/back pair so capacity stays 20 either way.

---

## Notes and Risks

- Item property names and the `base:` namespace syntax follow v42.20.4; the mod targets Build 42 only.
- Risk: `ConditionMax = 99` with `ConditionLowerChanceOneIn = 99` makes the knife nearly indestructible; this is intended.
- Risk: reusing vanilla `ClothingItem` entries ties the models to vanilla assets; if those change in a future build the items may break.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.

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
