# DevCycle 009: Satchel Upgrade and Magic Robes

**Status:** Planning
**Start Date:** 2026-11-13
**Target Completion:** TBD
**Focus:** Make the Satchel of Holding bigger and lighter to carry, and add two new robes: the Magic Robe and the Magic Warm Robe.

---

## Goal

1. Raise the Satchel of Holding's `Capacity` from 50 to 100 and its `WeightReduction` from 95 to 97.
2. Add two new wearable items, `MagicRobe` and `MagicWarmRobe`, using the definitions Ed wrote in `doc/ideas/magicrobe.txt`.

## Desired Outcome

- The Satchel of Holding holds 100 capacity and reduces the weight of its contents by 97%.
- The Pouch of Holding items are not changed.
- A Magic Robe and a Magic Warm Robe can be spawned and worn in game. They have the stats from the idea file, show proper names, and look like the vanilla Black Robe.
- Existing PseudoMagic items keep working.

---

## Research Summary

- **Satchel today:** `SatchelOfHolding` in `PseudoMagic/42/media/scripts/items/PseudoMagic_Items.txt` has `Capacity = 50` and `WeightReduction = 95`. The comment above the item also says "Capacity 50 and WeightReduction 95" and must be updated.
- **"0.97" is read as 97.** In item scripts `WeightReduction` is a percentage (vanilla satchel 65, ours 95), so "0.97" is taken to mean 97%. A literal 0.97 would be a 0.97% reduction, the opposite of the intent. See Open Questions.
- **Robe stats come from `doc/ideas/magicrobe.txt`.** The file contains vanilla `BlackRobe` and `Jacket_Black` as references, and the two new items. The new items are based on `BlackRobe`:

| Stat | BlackRobe (vanilla) | MagicRobe | MagicWarmRobe |
|---|---|---|---|
| BiteDefense | none | 100 | 100 |
| ScratchDefense | none | 100 | 100 |
| Insulation | 0.3 | 0.3 | 0.9 |
| RunSpeedModifier | 0.9 | 0.95 | 0.95 |
| WaterResistance | none | 0.9 | 0.9 |
| WindResistance | 0.2 | 0.9 | 0.9 |

  Both reuse `ClothingItem = BlackRobe` (vanilla model and clothing XML), `Icon = Robe_Judge`, `BodyLocation = base:bathrobe`, `BloodLocation = Trousers;Shirt`, `FabricType = Cotton`, `WorldStaticModel = Dress_Long_Ground`, and the tags `base:ripclothingcotton;base:noragdoll`.
- **Name keys:** display names live in `PseudoMagic/42/media/lua/shared/Translate/EN/ItemName.json` (for example `"PseudoMagic.SatchelOfHolding": "Satchel of Holding"`). The robes need entries there.
- **Items go inside the module.** The idea file lists the items without the `module PseudoMagic` wrapper; they are added to `PseudoMagic_Items.txt` inside the existing module (where `Base` is imported).

---

## Tasks

### Phase 1: Satchel Upgrade

**Status:** Work Complete

- [x] In `PseudoMagic_Items.txt`, change `SatchelOfHolding` to `Capacity = 100` and `WeightReduction = 97`
- [x] Update the comment above the item to match
- [x] Check `doc/ideas/magicitems.txt` and other docs for the old numbers (50 and 95) and update or note them (updated `magicitems.txt`; DevCycle001 is history and left as written)

**Technical Notes:**
Only the Satchel changes. The Pouch of Holding and its back-wear variant stay at capacity 20 and reduction 95.

### Phase 2: Magic Robes

**Status:** Work Complete

- [x] Add `MagicRobe` to `PseudoMagic_Items.txt` with the stats in the table above
- [x] Add `MagicWarmRobe` to `PseudoMagic_Items.txt` with the stats in the table above (differs from `MagicRobe` only in `Insulation = 0.9`)
- [x] Add display names to `ItemName.json`: `PseudoMagic.MagicRobe` ("Magic Robe") and `PseudoMagic.MagicWarmRobe` ("Magic Warm Robe")
- [x] Add a short comment above each item, in the style of the existing items
- [x] Confirm that `base:bathrobe` is a valid body location, and that `BlackRobe` is the correct `ClothingItem` name, in the v42.20.4 scripts (`media42_20_4/`) (confirmed: `clothing.txt:234-240`)

**Technical Notes:**
No `Weight` is set in the idea file, so the default weight applies, as for vanilla `BlackRobe`. Whether the robes should be lighter is in Open Questions.

### Phase 3: Summon Robes from the Ring of the Mage

**Status:** Work Complete

- [x] In `PseudoMagicMenu.lua`, add `MagicRobe` and `MagicWarmRobe` to the ring's Summon submenu, after the existing entries
- [x] Give the robe entries a flag (for example `noDismiss = true`) and skip them when building `DISMISS_TEXT`, so no "Dismiss Magic Robe" option appears for either robe
- [x] Add text keys to `UI.json`: `UI_PseudoMagic_SummonRobe` ("Magic Robe") and `UI_PseudoMagic_SummonWarmRobe` ("Magic Warm Robe"); add no Dismiss keys
- [x] Summoning only adds the robe to the inventory (as for the tools); it is not worn automatically
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`

**Technical Notes:**
`MAGIC_ITEMS` drives both the Summon submenu and the Dismiss options (`DISMISS_TEXT` is built from it, and `scan()` only offers a dismiss for types in `DISMISS_TEXT`). Skipping the robes when `DISMISS_TEXT` is built is enough to leave them out of Dismiss; the Summon loop needs no change. The existing Dismiss text keys follow the pattern `UI_PseudoMagic_DismissMagic<name>`, which the robes simply will not have.

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Right-click a Ring of the Mage; confirm the Summon submenu lists "Magic Robe" and "Magic Warm Robe" and that each adds the right robe to the inventory
- [ ] Right-click a summoned robe; confirm there is no Dismiss option
- [ ] Spawn a Satchel of Holding; confirm capacity 100 and the 97% weight reduction (check the container tooltip and the carried weight with a heavy load)
- [ ] Spawn the Pouch of Holding and confirm it is unchanged
- [ ] Spawn and wear a Magic Robe and a Magic Warm Robe; confirm names, icons, model, and stats in the item tooltip
- [ ] Confirm the robes' bite and scratch defense, and that the Warm Robe's insulation is higher
- [ ] Confirm the robes can be worn together with the usual clothing, and that they do not conflict with other items in the bathrobe slot
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

1. **WeightReduction value:** "0.97" is assumed to mean `WeightReduction = 97` (percent). Say so if a different value was intended.
2. **Robe weight:** the idea file sets no `Weight`, so the default applies. Should the robes be given an explicit weight (for example lighter than vanilla)?
3. **Existing Satchels:** items already spawned in a save take their stats from the script, so they should pick up the new capacity; confirm in testing.
4. **Obtaining the robes:** like the other PseudoMagic items, these are debug-spawn only unless a recipe or loot is requested later.

---

## Notes and Risks

- Risk: `BiteDefense = 100` and `ScratchDefense = 100` make the robes near-immune to bites and scratches. This is the requested design, but it is a large balance step compared to the Satchel change.
- Risk: the robes share the `base:bathrobe` body location, so they cannot be worn together with a vanilla bathrobe or other items in that slot.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Follows DevCycle 008 (still in progress); the two cycles touch different files apart from `PseudoMagic_Items.txt` and `ItemName.json`.

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
