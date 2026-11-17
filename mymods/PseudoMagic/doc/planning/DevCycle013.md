# DevCycle 013: Forever Light Ball

**Status:** VERIFIED (Phases 1-3 Work Complete and deployed; Phase 4 in-game testing pending)
**Start Date:** 2026-11-15
**Target Completion:** TBD
**Focus:** Add the Forever Light Ball: a Magic Light Ball that never burns out, can be summoned with the Ring of the Mage, and can be dismissed.

**Source documents:** none (user request in conversation). Related: `doc/planning/DevCycle005.md` (Magic Light Ball behaviour and summon/dismiss entries), `doc/planning/DevCycle012.md` (Magic Light Ball texture and icon).
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

Add a second light item, the Forever Light Ball. It is exactly like the Magic Light Ball (same light strength and distance, same tennis-ball shape, same drop-on-ground light, same pick-up behaviour, same secondary-hand equip when summoned), with these differences:

- it never expires (no drain, carried or on the ground);
- it can be dismissed from the inventory context menu, like the other summoned items.

## Desired Outcome

In game:

- the Ring of the Mage Summon submenu has a "Forever Light Ball" entry, which adds the item to the inventory and equips it in the secondary hand (as the Magic Light Ball does);
- the Forever Light Ball gives the same light as the Magic Light Ball when carried, and when dropped on the ground;
- it never runs down, however long it is carried or left on the ground, and it survives save/load;
- right-clicking it shows "Dismiss Forever Light Ball", which deletes it (and ends its light);
- the Magic Light Ball is unchanged: it still burns out after 20 game minutes and can still be summoned and dismissed.

---

## Research Summary

All from the current mod files (`PseudoMagic/42/media/...`):

- **Item** (`scripts/items/PseudoMagic_Items.txt:624`): `MagicLightBall` is `base:drainable`, `UseDelta = 0.005`, `UseWhileUnequipped = true`, `UseWhileEquipped = false`, `LightDistance = 15`, `LightStrength = 1.5`, `ActivatedItem = false`, tag `pseudomagic:magiclightball` (registered in `registries.lua`). The carried drain is done by the engine through `UseDelta`/`UseWhileUnequipped`.
- **Ground light is hard-wired to one item type.** `Utils.isLightBall(item)` in `lua/shared/PseudoMagic_LightBall_Utils.lua:49` compares the full type to `Utils.fullType = "PseudoMagic.MagicLightBall"`. It gates every light feature:
  - `PseudoMagic_LightBall_Drop.lua:12` (drop on ground adds a light);
  - `PseudoMagicLightBallClient.lua:10` (transfer to/from the floor sends light/extinguish commands);
  - `PseudoMagicLightBallServer.lua:24` and `:63` (`light` command validation; the per-minute check that removes the light if the item is gone).
  A Forever Light Ball would currently give **no ground light**, so this check must accept both types.
- **Ground drain** is done by `everyOneMinute` in `PseudoMagicLightBallServer.lua:54`: every tracked ball loses `UseDelta * Utils.usesPerMinute` uses per game minute and is deleted at zero. The Forever Light Ball must keep its light tracked (so the light is restored after load) but skip the drain and the delete.
- **Summon/dismiss menu** (`lua/client/PseudoMagic/PseudoMagicMenu.lua`): the `MAGIC_ITEMS` table drives both menus. An entry gets a Dismiss option unless it has `noDismiss = true` (only the robes do), and the UI text keys are built from `name`: `UI_PseudoMagic_Summon<name>` and `UI_PseudoMagic_DismissMagic<name>`. `equipSecondary = true` equips the ball when summoned. A Forever Light Ball entry needs no new menu code, only a table row plus two `UI.json` strings.
- **Translations:** item names are in `lua/shared/Translate/EN/ItemName.json`, menu text in `UI.json`.
- **Look:** the Magic Light Ball uses model `MagicLightBall` (vanilla tennis ball mesh, `WorldItems/LightBall` texture) and icon `Item_MagicLightBall.png`.

---

## Tasks

### Phase 1: Forever Light Ball item

**Status:** Work Complete (deployed; in-game check pending)

- [x] Decide how the item never expires (see Open Question 1) and record the decision here.
- [x] Add `item ForeverLightBall` to `PseudoMagic_Items.txt`, copying `MagicLightBall` (`LightDistance = 15`, `LightStrength = 1.5`, `Weight = 0.3`, `ActivatedItem = false`, `TorchCone = false`, `DisplayCategory = LightSource`) with the drain removed.
- [x] Give it a look (see Open Question 2): `Icon`, `StaticModel`, `WorldStaticModel`.
- [x] Add a tag (for example `pseudomagic:foreverlightball`) in `registries.lua` if the item keeps a tag, as `MagicLightBall` does.
- [x] Add `"PseudoMagic.ForeverLightBall": "Forever Light Ball"` to `ItemName.json`.
- [x] Update the comment block above the item to describe it.

### Phase 2: Ground light for both balls

**Status:** Work Complete (deployed; in-game check pending)

- [x] In `PseudoMagic_LightBall_Utils.lua`, make `Utils.isLightBall` true for both `PseudoMagic.MagicLightBall` and `PseudoMagic.ForeverLightBall` (for example a lookup table of full types), and keep `Utils.fullType` working for any other use.
- [x] Add a helper such as `Utils.isForever(item)`.
- [x] In `everyOneMinute` (`PseudoMagicLightBallServer.lua`), for a Forever Light Ball skip the drain and the delete-at-empty step, but keep the "item no longer on the square, remove the light" check.
- [x] Confirm the drop, pick-up and `light`/`extinguish`/`load` command paths need no other change (they use `isLightBall` only).
- [x] Confirm the saved light data (`ModData` key `PseudoMagicLightBall`) restores a Forever Light Ball's light after save and reload.

### Phase 3: Summon and dismiss

**Status:** Work Complete (deployed; in-game check pending)

- [x] Add `{ name = "ForeverLightBall", fullType = "PseudoMagic.ForeverLightBall", equipSecondary = true }` to `MAGIC_ITEMS` in `PseudoMagicMenu.lua`, next to the Magic Light Ball entry. Do not set `noDismiss`.
- [x] Add `UI_PseudoMagic_SummonForeverLightBall` ("Forever Light Ball") and `UI_PseudoMagic_DismissMagicForeverLightBall` ("Dismiss Forever Light Ball") to `UI.json`. (The dismiss key keeps the existing `DismissMagic<name>` pattern.)
- [x] Check the dismiss of a Forever Light Ball that is equipped, in a bag, or lying on the ground (see Notes and Risks).

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `utilities/CopyModToZomboid.bat PseudoMagic`; load a B42 test save with the mod.
- [ ] Summon a Forever Light Ball with the Ring of the Mage; confirm it appears in the inventory and is equipped in the secondary hand.
- [ ] Confirm the carried light matches the Magic Light Ball's.
- [ ] Carry it for much longer than 20 game minutes (use a sped-up game or debug time skip); confirm it does not run down or disappear.
- [ ] Drop it; confirm the ground light appears. Leave it for much longer than 20 game minutes; confirm it stays lit and is not deleted.
- [ ] Pick it up; confirm the ground light goes out and the ball is still usable.
- [ ] Save, quit, reload; confirm a dropped ball's light returns and the ball is intact.
- [ ] Right-click: confirm "Dismiss Forever Light Ball" appears and deletes it (equipped and not equipped), and its light ends.
- [ ] Confirm the Magic Light Ball still drains, burns out, summons and dismisses as before, and a summoned stack of both types behaves independently.
- [ ] Check the console/log for errors (missing model, texture, translation key).
- [ ] If multiplayer is available, repeat summon, drop, pick-up and dismiss on a server.

**Technical Notes (implementation, 2026-11-15):**
Open Question 1 taken as option A: `ForeverLightBall` is `base:drainable` with `UseDelta = 0`, `UseWhileUnequipped = false`, `UseWhileEquipped = false`. Whether the engine still lights a zero-`UseDelta` drainable when carried is **unverified** and is the first thing to check in game; fallback is a very small `UseDelta`. Open Question 2: reuses the `MagicLightBall` model and icon. Open Questions 3 and 4 as recommended. Changes: `PseudoMagic_Items.txt` (new item), `registries.lua` (tag), `ItemName.json`, `UI.json` (summon + dismiss), `PseudoMagicMenu.lua` (menu row), `PseudoMagic_LightBall_Utils.lua` (`isLightBall` accepts both, new `isForever`), `PseudoMagicLightBallServer.lua` (ground drain/delete skipped for Forever). Deployed with `CopyModToZomboid.bat PseudoMagic`.

Test results: record here. Final status of each phase is set by the user.

---

## Open Questions

1. **How should "never expires" be built?**
   - A. Keep `base:drainable` with `UseDelta` removed or 0 and `UseWhileUnequipped = false`, so nothing drains.
   - B. Make it a plain (non-drainable) item with light properties and no uses.
   **Recommendation:** try A first, because the carried light is known to work for a drainable ball (`MagicLightBall`). Whether the engine still lights a drainable item with zero `UseDelta`, and whether a non-drainable item lights at all when carried, is not verified; test this in Phase 1 before building the rest. (If the carried light needs `UseDelta`, use a very small value together with the server-side skip.)

2. **What does it look like?** It could reuse the Magic Light Ball's model and icon, or have its own texture and icon.
   **Recommendation:** reuse the existing model and icon for the first pass so the two can be told apart only by name, and let the user supply `ForeverLightBall` texture/icon PNGs if wanted. (Without a different look the two balls are hard to tell apart in the inventory.) The user decides.

3. **Dismiss behaviour on the ground:** "dismissed like many other summonable objects" is read as the inventory context-menu "Dismiss ..." option, which only works on items in the player's containers. A ball lying on the ground cannot be dismissed that way (it must be picked up first). Is that acceptable?
   **Recommendation:** yes, matching the other summoned items.

4. **Summon-menu position and cost:** place the entry right after the Magic Light Ball, with no cost or cooldown (as for the other entries)?
   **Recommendation:** yes.

---

## Notes and Risks

- **Ground light tracking:** the Forever Light Ball must be in the tracked `ModData` set so its light is restored on load, but must be exempt from the drain. Missing either half gives either no light after reload or a ball that disappears.
- **Widening `isLightBall`** affects every place it is used (drop, transfer, server validation). Test the Magic Light Ball again after the change (Phase 4).
- **Dismissing a dropped-then-picked-up ball:** the dismiss only deletes the inventory item (`dismissItem`); the ground light is removed by the pick-up transfer, so a ball that is picked up and then dismissed should have no light left. Confirm in Phase 3.
- **Dismissing a Forever Light Ball on the ground** is not supported (see Open Question 3).
- Nothing has been run in game. All statements above come from reading the current mod files.
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
