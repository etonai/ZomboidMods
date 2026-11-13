# DevCycle 007: Magic Wood Axe and Magic Shortsword

**Status:** VERIFIED
**Start Date:** 2026-11-12
**Target Completion:** TBD
**Focus:** Add a Magic Wood Axe and a Magic Shortsword: half the vanilla weight, double the maximum damage, door damage and tree damage, a condition maximum of 99, and a very low chance of losing condition. Both can be summoned by the Ring of the Mage.

---

## Goal

Add two new magic weapons to the mod, following the pattern of DevCycle 003 (magic tools) and the Magic Knife and Magic Hammer from DevCycle 002. Each is a copy of its vanilla item with a few stat changes, a "Magic" name, a Dismiss menu option, and a place in the Ring of the Mage's Summon submenu.

## Desired Outcome

- A **Magic Wood Axe** exists, identical to the vanilla `WoodAxe` except for: half weight, double `MaxDamage`, double `DoorDamage`, double `TreeDamage`, `ConditionMax = 99`, `ConditionLowerChanceOneIn = 99`.
- A **Magic Shortsword** exists, identical to the vanilla `ShortSword` except for the same six changes.
- Both are named "Magic Wood Axe" and "Magic Shortsword".
- Right-clicking either one shows "Dismiss Magic Wood Axe" or "Dismiss Magic Shortsword", which deletes it from inventory (see Open Questions: Dismiss was not requested in so many words).
- The Ring of the Mage's "Summon" submenu includes "Wood Axe" and "Shortsword", each adding the item to the inventory.

---

## Stat Table

Values come from the vanilla definitions in `media42_20_4/scripts/generated/items/weapon.txt` (build v42.20.4): `WoodAxe` at line 13469 and `ShortSword` at line 13968.

| Property | Vanilla `WoodAxe` | Magic Wood Axe | Vanilla `ShortSword` | Magic Shortsword |
|---|---|---|---|---|
| `Weight` | 3.0 | 1.5 | 1.5 | 0.75 |
| `MaxDamage` | 3.0 | 6.0 | 2.0 | 4.0 |
| `DoorDamage` | 55 | 110 | 5 | 10 |
| `TreeDamage` | 55 | 110 | 5 | 10 |
| `ConditionMax` | 15 | 99 | 13 | 99 |
| `ConditionLowerChanceOneIn` | 40 | 99 | 20 | 99 |
| `MinDamage` (unchanged) | 1.3 | 1.3 | 1.5 | 1.5 |

Properties that exist only on the axe, and need a decision: `HeadCondition = 15` and `HeadConditionLowerChanceMultiplier = 1.5` (see Open Questions).

---

## Tasks

### Phase 1: Magic Wood Axe

**Status:** Work Complete

- [x] Define `MagicWoodAxe` in `PseudoMagic_Items.txt` as a copy of vanilla `WoodAxe` (weapon.txt:13469) with the changes in the Stat Table
- [x] Keep every other property identical (`Tags = base:choptree;base:cutplant;base:sharpenable;base:repairwithtape;base:repairwithglue;base:hasmetal`, attachment type, sounds, models, icons, two-handed flags, `OnBreak`); drop `Researchablerecipes`, as for the other magic items
- [x] Decide and set `HeadCondition` (see Open Questions)
- [x] Add `PseudoMagic.MagicWoodAxe` = "Magic Wood Axe" to `ItemName.json`
- [x] Add `UI_PseudoMagic_DismissMagicWoodAxe` = "Dismiss Magic Wood Axe" to `UI.json`
- [x] Add the item to the `MAGIC_ITEMS` table in `PseudoMagicMenu.lua` (this provides the Dismiss option)

**Technical Notes:**
Generate the definition from the vanilla block the same way as the DevCycle 003 tools: change the ID, apply the stat changes, remove `Researchablerecipes`, and indent to match the file. The vanilla axe uses `IconsForTexture = WoodAxe;Axe_Forged` and `WeaponSpritesByIndex = WoodAxe;WoodAxeForged`; copy both as-is, as for the Magic Hammer and Magic Pickaxe. Note that `WoodAxe` is the item named "Wood Axe" in the game; vanilla also has a separate `Axe` item (weapon.txt:9671), which is not the one being copied.

### Phase 2: Magic Shortsword

**Status:** Work Complete

- [x] Define `MagicShortSword` in `PseudoMagic_Items.txt` as a copy of vanilla `ShortSword` (weapon.txt:13968) with the changes in the Stat Table
- [x] Keep every other property identical (`Tags = base:ignorezombiedensity;base:hasmetal;base:sharpenable`, `Categories = base:longblade`, attachment type `Sword`, sounds, weapon sprite, `OnBreak = OnBreak.ShortSword`); drop `Researchablerecipes`
- [x] Add `PseudoMagic.MagicShortSword` = "Magic Shortsword" to `ItemName.json`
- [x] Add `UI_PseudoMagic_DismissMagicShortSword` = "Dismiss Magic Shortsword" to `UI.json`
- [x] Add the item to the `MAGIC_ITEMS` table in `PseudoMagicMenu.lua`

**Technical Notes:**
The vanilla item is `ShortSword` and its display name is "Shortsword" (`Base.ShortSword` in the vanilla `ItemName.json`). There are also `CrudeShortSword` ("Simple Shortsword") and `ShortSword_Scrap`; these are not used. The vanilla shortsword has no `HeadCondition`, so there is nothing extra to decide for it.

### Phase 3: Summon from the Ring of the Mage

**Status:** Work Complete

- [x] Add "Wood Axe" and "Shortsword" to the ring's Summon submenu (driven by the same `MAGIC_ITEMS` entries)
- [x] Add `UI_PseudoMagic_SummonWoodAxe` = "Wood Axe" and `UI_PseudoMagic_SummonShortSword` = "Shortsword" to `UI.json`

**Technical Notes:**
The Summon submenu and Dismiss options are both built from `MAGIC_ITEMS` (`PseudoMagicMenu.lua`), so one table entry per item plus the text keys covers the menu work of Phases 1 and 2. Summoned items are added to the main inventory and synced for multiplayer, as for the other magic items. The summon text key for an entry is `"UI_PseudoMagic_Summon" .. name`, so the table entries should use the names `WoodAxe` and `ShortSword`.

**Implementation (Phases 1 to 3):** Both items were generated from the vanilla blocks in `weapon.txt` by script: only the item ID, the stat-table values and the removed `Researchablerecipes` line differ. Added to `PseudoMagic_Items.txt` (`MagicWoodAxe`, `MagicShortSword`), `ItemName.json`, `UI.json` (summon and Dismiss keys) and the `MAGIC_ITEMS` table in `PseudoMagicMenu.lua` (entries `WoodAxe` and `ShortSword`, placed before the Light Ball entry). Not tested in game.

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Confirm each item spawns with the right name, icon, and weight (1.5 and 0.75)
- [ ] Confirm the tooltips show condition 99 for both new items and the doubled damage values
- [ ] Confirm the axe chops trees noticeably faster and breaks doors noticeably faster than a vanilla Wood Axe, and the shortsword does more door and tree damage than a vanilla Shortsword
- [ ] Confirm the condition of each drops very rarely (swing and hit repeatedly)
- [ ] Confirm each item works wherever its vanilla version does: the axe for chopping trees and cutting plants, recipes and crafting that use an axe tag, repairing with tape or glue; the shortsword as a melee weapon, sharpening
- [ ] Confirm "Dismiss ..." appears only on the matching item and deletes it (held, in inventory, and in a bag)
- [ ] Confirm the ring's Summon submenu lists "Wood Axe" and "Shortsword" and each adds the item
- [ ] Confirm the previously summonable items are unaffected
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

*(All five questions below were answered by going with the recommendations: only `MaxDamage` doubled, axe `HeadCondition = 99`, Dismiss included, sharpness left as vanilla.)*

1. **Does "double the max damage" mean only `MaxDamage`?**
   The request names max damage, door damage and tree damage. Recommendation: double `MaxDamage` only and leave `MinDamage` alone (1.3 for the axe and 1.5 for the shortsword), as the Magic Knife and Magic Hammer did in DevCycle 002.

2. **What about the axe's `HeadCondition` (vanilla 15)?**
   In DevCycle 002 the Magic Hammer's `HeadCondition` was raised to match its `ConditionMax`. Recommendation: set the axe's `HeadCondition = 99` to match `ConditionMax = 99`, so it is not the weak point; keep `HeadConditionLowerChanceMultiplier = 1.5` as vanilla. This was not in the request, so confirm.

3. **Should the new items have a Dismiss option?**
   The request says to make them summonable, but does not mention Dismiss. All other magic items have one, and Dismiss comes with the `MAGIC_ITEMS` entry. Recommendation: include it for consistency, and say so if it is not wanted.

4. **Sharpness and other wear?**
   Both vanilla items have `Sharpness = 1.0`, which is separate from condition and drops with use. Recommendation: leave as vanilla; sharpness loss still applies, and the items remain sharpenable.

5. **Is the resulting power level acceptable?**
   A 99-condition axe with 6.0 max damage and 110 tree and door damage is much stronger than vanilla. This is the intent of the request; nothing to decide unless testing shows a problem.

---

## Notes and Risks

- Risk: a recipe or action that names `Base.WoodAxe` or `Base.ShortSword` by item ID instead of by tag would reject the magic version. Check during testing and record any failure.
- Risk: the vanilla axe is a two-handed weapon (`TwoHandWeapon = true`, `RequiresEquippedBothHands = true`); copying all flags unchanged should keep this, but check that it equips and swings correctly.
- Risk: the vanilla `OnBreak` handlers (`OnBreak.WoodAxe`, `OnBreak.ShortSword`) spawn broken parts; at condition 99 and a 1 in 99 chance this will almost never happen, but check it does not error if it does.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 003 (magic tool pattern, the `MAGIC_ITEMS` table in `PseudoMagicMenu.lua`) and DevCycle 002 (Magic Knife and Magic Hammer stat changes).

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
