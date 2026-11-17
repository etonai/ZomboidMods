# DevCycle 015: Ring of the Mage Cleanse

**Status:** VERIFIED (Phases 1-2 Work Complete and deployed; Phase 3 in-game testing pending)
**Start Date:** 2026-11-16
**Target Completion:** TBD
**Focus:** Add a "Cleanse" menu item to the Ring of the Mage that completely cleans the character: body, worn clothing, and carried weapons and containers. The character is not wet afterward.

**Source documents:** `doc/ideas/RingAutoCleanAnalysis.md` (code analysis of how the game cleans the character, clothing, weapons and containers; decisions on its section 8 are recorded in that file). Related: `doc/planning/DevCycle014.md` (previous cycle).
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)
**Scope:** single-player. Multiplayer is out of scope for this cycle.

---

## Goal

Add a menu entry to the Ring of the Mage context menu (alongside Summon, Bind Location, Teleport and Transit). Choosing it removes all blood and dirt from the character and from the items they carry, with no water, soap or timed action needed.

## Desired Outcome

In game, after choosing "Cleanse" from the ring menu:

- the character's body has no blood and no dirt (all body parts);
- every worn and carried clothing item has no blood and no dirt, and its Dirty and Bloody tooltip values are 0;
- every carried weapon has a blood level of 0;
- every carried container (bag) has no blood and no dirt;
- the character's body and clothes are **not wet** afterward (the vanilla wash makes clothing fully wet; this does not);
- worn makeup is left on;
- the on-screen character model shows the clean result without needing to re-equip anything.

---

## Research Summary

Details, file names and line numbers are in `doc/ideas/RingAutoCleanAnalysis.md`. The points that decide this plan:

- **Where the data lives:**
  - body: `playerObj:getHumanVisual()` holds blood and dirt per body part (`HumanVisual.java:278-310`);
  - clothing and bags: each item's own visual holds blood and dirt per covered body part (`BloodClothingType.getCoveredParts(item:getBloodClothingType())`), read and written with `item:getBlood/setBlood/getDirt/setDirt(part, ...)` (`InventoryItem.java:4156-4177`); `Clothing` also keeps summary fields cleared with `setDirtiness(0)` and `setBloodLevel(0)`;
  - weapons: one `bloodLevel` (0 to 1), cleared with `setBloodLevel(0)` (`HandWeapon.java:2284`).
- **What vanilla does per target** (`ISWashYourself.lua:31-49`, `ISWashClothing.lua:125-175`): per-part `setBlood(part, 0)` and `setDirt(part, 0)`, then the summary fields, then item and visual syncs, then a model refresh (`resetModel`, `OnClothingUpdated`).
- **Wetness:** vanilla sets clothing wetness to 100 as a side effect of washing (`ISWashClothing.lua:140-143`). That call is simply left out. For "not wet afterward", the relevant fields are `Clothing:getWetness/setWetness(percent)` (`Clothing.java:815-820`) and per-body-part wetness, `BodyPart:getWetness/setWetness` (`BodyPart.java:1918-1922`). The game's own test script writes body-part wetness through `playerObj:getBodyDamage():getBodyParts():get(i):setWetness(...)` (`client/LastStand/AReallyCDDAy.lua:75-76`) and the overall stat through `getStats():set(CharacterStat.WETNESS, ...)` (`:74`).
- **Items in scope:** the vanilla menu only looks at the top level of the main inventory (`getItemsFromCategory`, non-recursive). Items inside bags need the recursive lookup `getAllCategoryRecurse` (`ItemContainer.java:1699`).
- **Menu:** `PseudoMagic/42/media/lua/client/PseudoMagic/PseudoMagicMenu.lua` builds the ring menu in `onFillInventoryObjectContextMenu` and already adds the Summon, Bind Location, Teleport and Transit entries when a ring is present (`hasRing`). A new entry follows the same pattern as `addTeleportMenus` and `addTransitMenu`; the text goes in `lua/shared/Translate/EN/UI.json`.
- **Decisions already made** (recorded in the analysis document, section 8): clean everything (body, clothing, weapons, containers); do not make clothes wet; leave makeup alone.

---

## Tasks

### Phase 1: Cleaning function

**Status:** Work Complete (deployed; in-game check pending)

- [x] Create a new client script, for example `PseudoMagic/42/media/lua/client/PseudoMagic/PseudoMagicCleanse.lua`, holding one function `PseudoMagicCleanse.cleanse(playerObj)`.
- [x] Body: for each `BloodBodyPartType` (`BloodBodyPartType.MAX:index()` entries, as `ISWashYourself.lua:72` loops them) set blood and dirt to 0 on `playerObj:getHumanVisual()`. Use the per-part calls the game uses; do not use `removeBlood()`/`removeDirt()` unless testing shows no difference (Open Question 3).
- [x] Clothing: for every `Clothing` item the character has (worn and carried), for each covered part set `setBlood(part, 0)` and `setDirt(part, 0)`, then `setDirtiness(0)` and `setBloodLevel(0)`. Do not touch makeup items.
- [x] Containers: for every carried `InventoryContainer`, for each covered part set `setBlood(part, 0)` and `setDirt(part, 0)`, then `setBloodLevel(0)`.
- [x] Weapons: for every carried `HandWeapon`, `setBloodLevel(0)`.
- [x] Wetness: do not call `setWetness(100)`. Make sure the character is not wet afterward (see Open Question 1).
- [x] Scope of the item search: decide per Open Question 2, then collect items accordingly.
- [x] Refresh: call `playerObj:resetModel()` (or `resetModelNextFrame()`), `playerObj:updateHandEquips()`, and `triggerEvent("OnClothingUpdated", playerObj)` so the model and tooltips update, as `ISWashClothing:perform/complete` do. In single-player no network sync is needed.
- [x] Guard against nil visuals (`item:getVisual()` can be nil; `InventoryItem.getBlood` already returns 0 then, but `setBlood` does nothing).

### Phase 2: Menu entry and text

**Status:** Work Complete (deployed; in-game check pending)

- [x] In `PseudoMagicMenu.lua`, inside the `if hasRing then` block of `onFillInventoryObjectContextMenu`, add a "Cleanse" option that calls `PseudoMagicCleanse.cleanse(playerObj)`. Place it with the other ring entries.
- [x] Add `UI_PseudoMagic_Cleanse` ("Cleanse") to `UI.json`. Keep the wording neutral and consistent with the other ring entries.
- [x] Decide whether the option is always available or greyed out when there is nothing to clean (Open Question 4).
- [x] Make sure the new script is loaded: client scripts in the `client/PseudoMagic/` folder are loaded automatically; use `require` in `PseudoMagicMenu.lua` if the menu file needs the function at load time (as it does for `PseudoMagic/PseudoMagicTeleport`).
- [x] Deploy via `utilities/CopyModToZomboid.bat PseudoMagic`.

### Phase 3: In-Game Testing

**Status:** Planning

- [ ] Get a Ring of the Mage; load a B42 single-player test save with the mod.
- [ ] Make the character dirty and bloody: debug blood/dirt tools, or fight and run through mud. Confirm the body, clothing, a weapon and a bag show blood or dirt (tooltips, character model).
- [ ] Choose "Cleanse"; confirm the model shows no blood or dirt on the body and clothes.
- [ ] Check item tooltips: Dirty and Bloody bars gone on every clothing item; weapon and bag no longer bloody.
- [ ] Confirm the clothing and character are not wet afterward, including starting from dry and from already-wet clothes (per Open Question 1).
- [ ] Confirm worn makeup is still worn.
- [ ] Confirm items inside a bag are cleaned (if Open Question 2 says yes).
- [ ] Confirm the character can still equip, unequip, and put on and remove clothing normally afterward, and that nothing visual is stuck.
- [ ] Choose "Cleanse" when nothing is dirty; confirm no error.
- [ ] Check the console/log for errors.

**Technical Notes (implementation, 2026-11-16):**
New `lua/client/PseudoMagic/PseudoMagicCleanse.lua` (`PseudoMagicCleanse.cleanse(playerObj)`); `PseudoMagicMenu.lua` requires it and adds a "Cleanse" option inside the `hasRing` block after Transit; `UI_PseudoMagic_Cleanse` added to `UI.json`. Open Questions taken as recommended: (1) all clothing `setWetness(0)`, every body part `setWetness(0)` and the `CharacterStat.WETNESS` stat set to its minimum; (2) recursive item search (`getAllCategoryRecurse` for Clothing, Container, Weapon); (3) per-part calls for the body; (4) option always shown; (5) rags/bandages untouched; (6) free and instant. Makeup is not touched. Refresh uses `resetModel()`, `updateHandEquips()` and the `OnClothingUpdated` event. Deployed with `CopyModToZomboid.bat PseudoMagic`. API names (`getAllCategoryRecurse`, `BodyPart:setWetness`, `CharacterStat:getMinimumValue`, `resetModel`) come from reading the source and are unconfirmed in game; check the console on first use.

Test results: record here. Final status of each phase is set by the user.

---

## Open Questions

1. **"Not wet afterward": never add wetness, or also dry the character?** The wash action makes clothing wet; this feature must not. If the character is already wet before cleansing, should it be dried?
   **Recommendation:** make the character not wet afterward in every case: clothing `setWetness(0)` on every clothing item, body-part `setWetness(0)` for each body part, and the character's wetness stat set to its minimum. This takes the request literally ("should not be wet afterward"). Confirm that already-wet characters should be dried.
2. **How far into the inventory?** "Completely" suggests everything, including items inside bags. The vanilla menu only handles the main inventory.
   **Recommendation:** include items inside bags using `getAllCategoryRecurse` for "Clothing", "Weapon" and "Container". The cost of visiting every item once per use has not been measured and is small for a one-off menu action.
3. **`removeBlood()`/`removeDirt()` or per-part calls for the body?** The one-call versions are simpler; vanilla uses per-part calls and the one-call versions have not been checked for missing side effects.
   **Recommendation:** per-part calls, as vanilla does.
4. **Greyed out when clean?** Show the entry always, or disable it with a tooltip when nothing needs cleaning?
   **Recommendation:** always available, for simplicity.
5. **Dirty rags and bandages** carried in the inventory (items that turn into clean ones when washed, `getItemAfterCleaning()`). Vanilla replaces them with the clean item. The request names clothing, weapons and containers only.
   **Recommendation:** leave them alone, as they are not part of the request.
6. **Cost or delay?** The menu action is free and instant by default.
   **Recommendation:** free and instant.

---

## Notes and Risks

- **Body and clothing are separate data.** Clearing only the body leaves worn clothes bloody; all four targets (body, clothing, weapons, containers) must be handled. This is the main thing to check in testing.
- **Model refresh.** If the model is not refreshed, the character may keep looking dirty until the next equip change. The refresh calls in Phase 1 are included for this reason.
- **Nothing has been run in game.** The plan rests on reading the v42.20.4 source (see the analysis document); API names should be confirmed on first run.
- **Multiplayer** is out of scope, so no network syncing is planned. Making this work on a server would need `player:syncVisuals()` and item-field syncs, and is for a later cycle if wanted.
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
