# DevCycle 002: Magic Hammer, Ring of Summoning, and Dismiss Labels

**Status:** VERIFIED
**Start Date:** 2026-11-11
**Target Completion:** TBD
**Focus:** Add a Magic Hammer (with a "Dismiss Magic Hammer" menu option), rename the Magic Knife's menu option to "Dismiss Magic Knife", and add a Ring of Summoning that summons the Magic Hammer or Magic Knife.

---

## Goal

Extend PseudoMagic with a second magic weapon, the Magic Hammer, built from the vanilla `Hammer` with the same kind of boosts the Magic Knife has over `LargeKnife`. Make the "Dismiss" menu entries item-specific so it is clear which item is being deleted. Add a Ring of Summoning that can summon either magic weapon into the player's inventory.

## Desired Outcome

- A Magic Hammer exists with vanilla Hammer stats except for the Magic Knife-style boosts, and still works as a hammer (barricading, building, etc.).
- Right-clicking the Magic Hammer shows "Dismiss Magic Hammer"; selecting it deletes the hammer from inventory.
- Right-clicking the Magic Knife shows "Dismiss Magic Knife" instead of "Dismiss".
- A Ring of Summoning (a plain gold ring in every other respect) offers "Summon Hammer" and "Summon Knife", which add a Magic Hammer or Magic Knife to the player's inventory.

---

## Tasks

### Phase 1: Magic Hammer Item

**Status:** Work Complete

- [x] Define `MagicHammer` in `PseudoMagic_Items.txt`, based on vanilla `Hammer` (weapon.txt:2798)
- [x] Apply the same boosts the Magic Knife has over `LargeKnife`: `ConditionLowerChanceOneIn = 99`, `ConditionMax = 99`, `CritDmgMultiplier = 3.0`, `CriticalChance = 50.0`, `MaxDamage = 3`
- [x] Keep all other Hammer properties (including `Tags = base:hammer;...`, `CanBarricade`, `DoorDamage`, `MinDamage`, `WeaponSpritesByIndex`)
- [x] Add the `PseudoMagic.MagicHammer` entry to `ItemName.json`

**Technical Notes:**
Vanilla `Hammer` (v42.20.4): `ConditionLowerChanceOneIn = 30`, `ConditionMax = 10`, `CritDmgMultiplier = 3.0` (already the same), `CriticalChance = 20.0`, `MaxDamage = 1.0`, `MinDamage = 0.5`, `HeadCondition = 10`, `HeadConditionLowerChanceMultiplier = 2.0`. Vanilla uses `IconsForTexture = Hammer;Hammer_Forged` and `WeaponSpritesByIndex = Hammer;HammerForged`; copy these as-is (or fall back to a single `Icon`/`WeaponSprite` if the index-based properties misbehave outside the vanilla texture-selection logic). `OnBreak = OnBreak.Clawhammer` is kept.

### Phase 2: Dismiss Menu for Hammer and Knife Labels

**Status:** Work Complete

- [x] Generalize `PseudoMagicMenu.lua` to a table mapping item full type to its menu label key (`PseudoMagic.MagicKnife` and `PseudoMagic.MagicHammer`)
- [x] Add "Dismiss Magic Hammer" for the Magic Hammer, reusing the existing dismiss logic (unequip from hands, remove from container, `sendRemoveItemFromContainer`)
- [x] Change the Magic Knife label from "Dismiss" to "Dismiss Magic Knife"
- [x] Replace `UI_PseudoMagic_Dismiss` in `UI.json` with `UI_PseudoMagic_DismissMagicKnife` and `UI_PseudoMagic_DismissMagicHammer`
- [x] Handle a selection containing several magic items sensibly (one option per matching item type)

**Technical Notes:**
Current implementation: `media/lua/client/PseudoMagic/PseudoMagicMenu.lua` hardcodes `MAGIC_KNIFE_TYPE` and the single `UI_PseudoMagic_Dismiss` key. Recommended shape: `local DISMISS = { ["PseudoMagic.MagicKnife"] = "UI_PseudoMagic_DismissMagicKnife", ["PseudoMagic.MagicHammer"] = "UI_PseudoMagic_DismissMagicHammer" }`, with `findItem` returning the first match per type.

### Phase 3: Ring of Summoning

**Status:** Work Complete

- [x] Define the Ring of Summoning items based on the vanilla gold rings (`Ring_Right_MiddleFinger_Gold`, `Ring_Left_MiddleFinger_Gold`, `Ring_Right_RingFinger_Gold`, `Ring_Left_RingFinger_Gold`, clothing.txt:7573-7620), changing only the name
- [x] Cross-link the four variants via `ClothingItemExtra` / `ClothingItemExtraOption` using `PseudoMagic.`-qualified IDs, as vanilla does
- [x] Add `ItemName.json` entries naming all four variants "Ring of Summoning"
- [x] Add "Summon Hammer" and "Summon Knife" inventory context-menu options, shown only on Ring of Summoning items
- [x] "Summon Hammer" adds a `PseudoMagic.MagicHammer` to the player's main inventory; "Summon Knife" adds a `PseudoMagic.MagicKnife`
- [x] Add `UI_PseudoMagic_SummonHammer` and `UI_PseudoMagic_SummonKnife` to `UI.json`
- [x] Handle multiplayer correctly when adding the item (server-synced add)

**Technical Notes:**
Vanilla gold ring: `ItemType = base:clothing`, `Weight = 0.1`, `Icon = Ring_Gold`, `Cosmetic = true`, `WorldStaticModel = Ring_Gold_Ground`, `Tags = base:hasmetal;base:tinygoldscrap`, with a per-finger `BodyLocation`, `ClothingItem`, and `ClothingExtraSubmenu`. Each variant lists the other three in `ClothingItemExtra`. Reuse the vanilla `ClothingItem` entries so models need no new assets. Extend `PseudoMagicMenu.lua` (or add a sibling file) to detect Ring of Summoning full types and add the two options; summon via `playerObj:getInventory():AddItem("PseudoMagic.MagicHammer")` with `sendAddItemToContainer` for MP.

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Spawn a Magic Hammer; confirm name, icon, model, and stats
- [ ] Confirm it can build/barricade and remove barricades like a normal hammer, and satisfies recipes requiring a hammer
- [ ] Confirm "Dismiss Magic Hammer" appears only on the Magic Hammer and deletes it (held, in main inventory, and in a bag)
- [ ] Confirm "Dismiss Magic Knife" appears only on the Magic Knife and deletes it
- [ ] Spawn a Ring of Summoning; confirm it looks and wears like a gold ring (all finger variants) and is named "Ring of Summoning"
- [ ] Confirm "Summon Hammer" and "Summon Knife" appear only on the Ring of Summoning and add the correct item to inventory
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Implementation Notes

- Open-question recommendations adopted: Hammer HeadCondition 99 and MaxDamage 3 (MinDamage 0.5); base:hammer tag kept; ring usable worn or carried, unlimited summons; four ring variants (RingOfSummoning<Finger>), all named "Ring of Summoning".
- Items: PseudoMagic_Items.txt. Menu: PseudoMagicMenu.lua (dismiss table + ring summon). Text: ItemName.json, UI.json (UI_PseudoMagic_Dismiss replaced by per-item keys).
- Not yet run in-game.

## Open Questions

1. **Should the Magic Hammer's `HeadCondition` also be boosted?**
   The Magic Knife spec does not cover it because knives have no head condition, but the vanilla Hammer has `HeadCondition = 10`. Recommendation: raise `HeadCondition` to 99 to match `ConditionMax`, so the head does not become the limiting durability.

2. **Should the hammer's `MaxDamage = 3` apply?**
   Interpreting "same different stats" as the Knife's override list, including `MaxDamage = 3` (vanilla 1.0). Recommendation: yes; `MinDamage` stays at vanilla 0.5.

3. **Does a modded hammer satisfy "hammer" recipe requirements?**
   Recommendation: keep the vanilla `base:hammer` tag; confirm during testing.

4. **Should the Ring of Summoning be usable only while worn?**
   Recommendation: no; the Summon options work whether the ring is worn or just in inventory.

5. **Can the ring summon unlimited weapons?**
   Recommendation: yes, no cooldown or limit (use Dismiss to discard extras), matching the spec as written.

6. **One ring item or four finger variants?**
   Recommendation: mirror vanilla with four variants (all named "Ring of Summoning") so the player keeps the usual wear-on-which-finger options.

---

## Notes and Risks

- Risk: `IconsForTexture` / `WeaponSpritesByIndex` rely on vanilla texture-variant logic; verify the item displays correctly.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Risk: the four-variant ring means the menu must match all four full types; keep them in one lookup table.
- Builds on DevCycle 001 (item module `PseudoMagic`, dismiss menu in `PseudoMagicMenu.lua`).

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
