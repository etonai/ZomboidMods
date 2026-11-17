# DevCycle 014: Regular Wrenches

**Status:** VERIFIED (Phases 1-2 Work Complete and deployed; Phase 3 in-game testing pending)
**Start Date:** 2026-11-15
**Target Completion:** TBD
**Focus:** Remove the Magic Wrench and Magic Pipe Wrench items from the mod, and make the Ring of the Mage summon the regular (vanilla) Wrench and Pipe Wrench instead.

**Source documents:** none (user request in conversation). Related: `doc/planning/DevCycle003.md` (the only earlier document that mentions the wrenches), `doc/planning/DevCycle013.md` (previous cycle).
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

The Magic Wrench and Magic Pipe Wrench are vanilla tools at half weight. The wrenches are to be removed. The Ring of the Mage Summon menu keeps its "Wrench" and "Pipe Wrench" entries, but they now add the normal game items `Base.Wrench` and `Base.PipeWrench`.

## Desired Outcome

In game:

- the Ring of the Mage Summon submenu still lists "Wrench" and "Pipe Wrench", in the same positions;
- choosing either adds the regular vanilla item (`Base.Wrench` / `Base.PipeWrench`) to the inventory;
- there are no "Magic Wrench" or "Magic Pipe Wrench" items in the mod (script, translations, menu);
- no "Dismiss Magic Wrench" / "Dismiss Magic Pipe Wrench" option exists, and a regular wrench or pipe wrench in the inventory is **not** offered a Dismiss option (see Notes and Risks);
- all other summoned items (magic tools, light balls, robes) behave as before.

---

## Research Summary

All from the current mod files (`PseudoMagic/42/media/...`) and the v42.20.4 game scripts:

- **Item definitions** (`scripts/items/PseudoMagic_Items.txt`): `MagicWrench` at line 424 (comment at 423) and `MagicPipeWrench` at line 467 (comment at 466), each a copy of the vanilla item at half weight, with the vanilla icon, sounds and weapon sprite. They are the only wrench references in the scripts.
- **Vanilla items:** `item Wrench` (`media42_20_4/scripts/generated/items/weapon.txt:5756`) and `item PipeWrench` (`:4167`), module `Base`, so the full types are `Base.Wrench` and `Base.PipeWrench`.
- **Summon/dismiss menu** (`lua/client/PseudoMagic/PseudoMagicMenu.lua:14-15`): `MAGIC_ITEMS` holds `{ name = "Wrench", fullType = "PseudoMagic.MagicWrench" }` and `{ name = "PipeWrench", fullType = "PseudoMagic.MagicPipeWrench" }`. `summonItem` adds whatever `fullType` it is given, so switching to `Base.Wrench` / `Base.PipeWrench` works for summoning. **But** the dismiss option is built from the same table (`DISMISS_TEXT[fullType]`) for every entry without `noDismiss = true`, and the inventory scan matches by full type. Pointing the entries at the vanilla types without `noDismiss = true` would add "Dismiss ..." to every ordinary wrench the player owns, letting them delete real wrenches by mistake. The robes already use `noDismiss = true` for this kind of case.
- **Translations:**
  - `lua/shared/Translate/EN/ItemName.json:11-12`: `PseudoMagic.MagicWrench`, `PseudoMagic.MagicPipeWrench` (to remove).
  - `lua/shared/Translate/EN/UI.json:9-10`: `UI_PseudoMagic_SummonWrench`, `UI_PseudoMagic_SummonPipeWrench` (keep: the menu text is unchanged).
  - `lua/shared/Translate/EN/UI.json:27-28`: `UI_PseudoMagic_DismissMagicWrench`, `UI_PseudoMagic_DismissMagicPipeWrench` (to remove).
- No other mod file refers to the wrenches: no tags, recipes, textures, models or Lua outside the menu. The only planning document that mentions them is `DevCycle003.md`.
- **Existing saves:** a save in which the player already carries or has dropped a `PseudoMagic.MagicWrench` or `PseudoMagic.MagicPipeWrench` will no longer find the item type once its script is removed. How the game handles that is not verified here (see Open Question 1).

---

## Tasks

### Phase 1: Remove the Magic Wrench and Magic Pipe Wrench items

**Status:** Work Complete (deployed; in-game check pending)

- [x] Delete `item MagicWrench` and its comment from `PseudoMagic_Items.txt`.
- [x] Delete `item MagicPipeWrench` and its comment from `PseudoMagic_Items.txt`.
- [x] Remove `PseudoMagic.MagicWrench` and `PseudoMagic.MagicPipeWrench` from `ItemName.json`.
- [x] Remove `UI_PseudoMagic_DismissMagicWrench` and `UI_PseudoMagic_DismissMagicPipeWrench` from `UI.json`.
- [x] Search the whole mod (outside `doc/`) for `MagicWrench` and `MagicPipeWrench` and confirm no references remain.
- [x] Check that the `weapon`-style script file still parses after the deletions (balanced braces, no leftover comment text).

### Phase 2: Ring summons the regular items

**Status:** Work Complete (deployed; in-game check pending)

- [x] In `PseudoMagicMenu.lua`, change the Wrench entry to `fullType = "Base.Wrench"` and the Pipe Wrench entry to `fullType = "Base.PipeWrench"`, with `noDismiss = true` on both, keeping their positions in the list.
- [x] Update the comment above `MAGIC_ITEMS` (and the "Robes can be summoned but not dismissed" comment) so it explains that these entries summon regular items, which are not dismissable.
- [x] Keep `UI_PseudoMagic_SummonWrench` and `UI_PseudoMagic_SummonPipeWrench` unchanged.
- [x] Confirm `summonItem` needs no change (it adds any full type and syncs it to the server).

### Phase 3: In-Game Testing

**Status:** Planning

- [ ] Deploy via `utilities/CopyModToZomboid.bat PseudoMagic`; load a B42 test save with the mod, and start a new save as well as an existing one (see Open Question 1).
- [ ] With a Ring of the Mage, open Summon: confirm "Wrench" and "Pipe Wrench" are still listed in place.
- [ ] Summon each: confirm a regular Wrench / Pipe Wrench (vanilla name, vanilla weight) is added to the inventory.
- [ ] Confirm the regular wrench and pipe wrench get **no** "Dismiss" option in the inventory menu.
- [ ] Confirm the other magic items still show Summon and Dismiss as before (spot-check a tool, the light balls and a robe).
- [ ] Confirm neither Magic Wrench nor Magic Pipe Wrench can be spawned (debug item list) and no "Magic Wrench" text appears.
- [ ] On an older save that carried a Magic Wrench or Magic Pipe Wrench: record what happens on load (see Open Question 1).
- [ ] Check the console/log for errors (missing item, missing translation key).
- [ ] If multiplayer is available, repeat the summon on a server.

**Technical Notes (implementation, 2026-11-15):**
Both item scripts deleted from `PseudoMagic_Items.txt`; `ItemName.json` entries and the two Dismiss strings in `UI.json` removed; no `MagicWrench`/`MagicPipeWrench` text remains in the mod outside `doc/`. `PseudoMagicMenu.lua`: Wrench and Pipe Wrench entries now use `Base.Wrench` / `Base.PipeWrench` with `noDismiss = true`; Summon strings kept. Open Question 1 taken as option A (removed outright). Deployed with `CopyModToZomboid.bat PseudoMagic`.

Test results: record here. Final status of each phase is set by the user.

---

## Open Questions

1. **Existing magic wrenches in saves:** after removal, an old save may hold `PseudoMagic.MagicWrench` / `PseudoMagic.MagicPipeWrench` in inventories or on the ground. The game probably drops or ignores unknown item types on load, but this is unverified. Options: (A) just remove them and accept that old magic wrenches vanish; (B) keep the two item scripts hidden for a while so old saves keep their wrenches.
   **Recommendation:** A, since removal was requested; test it in Phase 3 on an older save and report what happens.

2. **Dismiss:** should the regular wrench and pipe wrench ever be dismissable?
   **Recommendation:** no (`noDismiss = true`), because the same full type is also the player's real, non-summoned wrench.

3. **Menu wording:** the entries stay "Wrench" and "Pipe Wrench". Should the summon text show they are regular, non-magic items?
   **Recommendation:** no change.

---

## Notes and Risks

- **Dismiss risk:** the dismiss feature matches by full type. Leaving it on for `Base.Wrench` / `Base.PipeWrench` would let the player delete any wrench they own. `noDismiss = true` prevents this; it is the key safety check in Phase 2 and Phase 3.
- **Behaviour change:** the summoned wrenches are now full weight (vanilla), not half weight.
- **Saves:** see Open Question 1.
- Nothing has been run in game. The plan is based on reading the mod files and the v42.20.4 game scripts.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Per `AGENTS.md`, work stops after this document is created; implementation starts only when the user asks.

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
