# DevCycle 003: Ring of the Mage and Magic Tools

**Status:** VERIFIED
**Start Date:** 2026-11-11
**Target Completion:** TBD
**Focus:** Rename the Ring of Summoning to the Ring of the Mage, add nine half-weight magic tools with Dismiss menus, and make the ring able to summon them.

---

## Goal

Rename the ring to its final name, then grow the set of magic items with the nine tools the player is most likely to want on hand: shovel, saw, crowbar, pickaxe, wrench, pipe wrench, sledgehammer, jack, and tire iron. The tools behave like their vanilla originals but weigh half as much, can each be dismissed, and can each be summoned by the ring.

## Desired Outcome

- The ring is named "Ring of the Mage" everywhere the player sees it.
- Nine new magic tools exist, each identical to its vanilla counterpart except for half the weight and the "Magic" name.
- Each magic tool has a "Dismiss Magic <Tool>" right-click option that deletes it from inventory.
- The Ring of the Mage can summon every magic tool (and still the Magic Hammer and Magic Knife).

---

## Tasks

### Phase 1: Rename Ring of Summoning to Ring of the Mage

**Status:** Work Complete

- [x] Change the display name to "Ring of the Mage" for all four finger variants in `ItemName.json`
- [x] Rename the item IDs `RingOfSummoning<Finger>` to `RingOfTheMage<Finger>` in `PseudoMagic_Items.txt`, including the `ClothingItemExtra` cross-references
- [x] Update the ring type table (`RING_TYPES`) in `PseudoMagicMenu.lua` to the new IDs
- [x] Update DevCycle 002 references only if needed for accuracy (completed documents otherwise stay as written)

**Technical Notes:**
Display names live in `media/lua/shared/Translate/EN/ItemName.json`; IDs in `media/scripts/items/PseudoMagic_Items.txt`. Renaming the IDs breaks any existing save that holds the old rings, which is acceptable at this stage of development (see Open Questions).

### Phase 2: Magic Tools

**Status:** Work Complete

- [x] Define each item in `PseudoMagic_Items.txt` as a copy of its vanilla counterpart with `Weight` halved:

| Magic item | Vanilla item | Source | Weight |
|---|---|---|---|
| Magic Shovel | `Shovel` | weapon.txt:9190 | 2.0 → 1.0 |
| Magic Saw | `Saw` | normal.txt:3503 | 1.0 → 0.5 |
| Magic Crowbar | `Crowbar` | weapon.txt:7529 | 2.0 → 1.0 |
| Magic Pickaxe | `PickAxe` | weapon.txt:10286 | 3.0 → 1.5 |
| Magic Wrench | `Wrench` | weapon.txt:5756 | 1.0 → 0.5 |
| Magic Pipe Wrench | `PipeWrench` | weapon.txt:4167 | 1.5 → 0.75 |
| Magic Sledgehammer | `Sledgehammer` | weapon.txt:13265 | 6.0 → 3.0 |
| Magic Jack | `Jack` | normal.txt:11764 | 1.5 → 0.75 |
| Magic Tire Iron | `TireIron` | weapon.txt:5216 | 1.5 → 0.75 |

- [x] Keep every other property (stats, `Tags`, attachment types, sounds, models, icons) identical to vanilla so recipes, vehicle work, and tool checks still accept the item
- [x] Add `ItemName.json` entries for all nine ("Magic Shovel", "Magic Saw", "Magic Crowbar", "Magic Pickaxe", "Magic Wrench", "Magic Pipe Wrench", "Magic Sledgehammer", "Magic Jack", "Magic Tire Iron")
- [x] Add a `Dismiss Magic <Tool>` entry for each in the `DISMISS_TEXT` table in `PseudoMagicMenu.lua`, and the matching `UI_PseudoMagic_DismissMagic<Tool>` keys in `UI.json`

**Technical Notes:**
Vanilla definitions are in `media42_20_4/scripts/generated/items/weapon.txt` and `normal.txt`. Copy each block in full and change only the item ID and `Weight`. The Jack is `ItemType = base:normal` (not a weapon); the dismiss logic already works on any inventory item. Items that use `IconsForTexture` / `WeaponSpritesByIndex` (Crowbar, PickAxe, Sledgehammer variants) are copied as-is, as for the Magic Hammer in DevCycle 002. The existing dismiss code (unequip, remove from container, `sendRemoveItemFromContainer`) is reused unchanged.

### Phase 3: Summon Magic Tools from the Ring of the Mage

**Status:** Work Complete

- [x] Add every new magic tool to the ring's summon list
- [x] Group the ring's summon options under a single "Summon" submenu (Hammer, Knife, Shovel, Saw, Crowbar, Pickaxe, Wrench, Pipe Wrench, Sledgehammer, Jack, Tire Iron) instead of eleven top-level entries
- [x] Drive the submenu from a table of `{ fullType, textKey }` entries so future items are one-line additions
- [x] Add the UI text keys to `UI.json`
- [x] Summoned items are added to the main inventory and synced for multiplayer (as for Hammer/Knife)

**Technical Notes:**
`PseudoMagicMenu.lua` currently adds "Summon Hammer" and "Summon Knife" as top-level options via `summonItem(playerObj, fullType)`. Replace them with one "Summon" option that opens a submenu built with `ISContextMenu:getNew(context)` and `context:addSubMenu(option, sub)` (the same pattern PseudoTransporter uses in `PseudoTransporterMenu.lua`). The existing `UI_PseudoMagic_SummonHammer` / `SummonKnife` keys are replaced by a `UI_PseudoMagic_Summon` submenu label plus per-item names.

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Confirm the ring is named "Ring of the Mage" in all four finger variants and still wears correctly
- [ ] Confirm each of the nine tools spawns with the right name, icon, and half weight
- [ ] Confirm each tool works for its vanilla purpose (dig, saw, pry, mine, repair, vehicle jack/tire work, sledge walls and so on) and satisfies relevant recipe or action requirements
- [ ] Confirm each "Dismiss Magic <Tool>" appears only on its tool and deletes it (held, in inventory, and in a bag)
- [ ] Confirm the ring's "Summon" submenu lists all eleven items and each adds the right item
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Implementation Notes

- Open-question recommendations adopted: exact half weights (no rounding needed); ring item IDs renamed to `RingOfTheMage<Finger>`; single "Summon" submenu; base Sledgehammer and Saw only; no combat boosts.
- Tool definitions were generated from the v42.20.4 vanilla blocks (Weight halved, `Researchablerecipes` dropped, ID changed) and appended to `PseudoMagic_Items.txt`.
- `PseudoMagicMenu.lua` now drives both Dismiss and Summon from one `MAGIC_ITEMS` table. `UI.json` summon keys changed from "Summon Hammer"/"Summon Knife" to submenu entries ("Hammer", "Knife", ...).
- DevCycle 002 left as written. Not yet run in-game.

## Open Questions

1. **How should "halved, round down if necessary" apply to the weights?**
   Every vanilla weight halves cleanly to at most two decimals (the smallest is 0.75). Recommendation: use the exact halves in the table above, so no rounding is needed. If whole-number weights are wanted instead, say so and the 0.5, 0.75, and 1.5 values would round down.

2. **Should the ring's item IDs be renamed along with its display name?**
   Recommendation: yes, rename to `RingOfTheMage<Finger>` for consistency; the mod is still in development so there is little save-compatibility cost.

3. **Flat list or submenu for eleven summon options?**
   Recommendation: a single "Summon" submenu to keep the right-click menu short.

4. **Which Sledgehammer and Saw variants?**
   Vanilla also has `Sledgehammer2` (forged) and other saws (`GardenSaw`, `SmallSaw`, `CrudeSaw`). Recommendation: base only `Sledgehammer` and `Saw`, since those are the standard versions.

5. **Do the tools need any combat boosts like the Magic Knife and Hammer?**
   The request says "mostly identical" apart from weight. Recommendation: no boosts; weight only.

---

## Notes and Risks

- Risk: a copied vanilla `Tags` list or property that is tied to a specific vanilla item ID (for example recipe inputs that name `Base.Crowbar` rather than a tag) will not accept the magic version. Check recipe and action requirements during testing and note any that fail.
- Risk: the vehicle Jack and Tire Iron may be matched by item type in vehicle mechanics code rather than by tag; verify in a vehicle during testing.
- Risk: renaming ring IDs invalidates rings in existing test saves.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 002 (Ring, Magic Hammer, dismiss and summon menus in `PseudoMagicMenu.lua`).

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
