# DevCycle 005: Magic Light Ball

**Status:** VERIFIED
**Start Date:** 2026-11-12
**Target Completion:** TBD
**Focus:** Add the Magic Light Ball, a tennis-ball-shaped light source that cannot be extinguished or refueled, burns for a fixed time, then disappears. It lights the area when carried and when dropped, following the approach of the PseudoButterCandle mod.

---

## Goal

Add a new light source item, "Magic Light Ball", to PseudoMagic. It looks like the vanilla `TennisBall` and behaves like the lit Butter Candle from `mymods/PseudoButterCandle`, with these differences: it is always lit, has no extinguish option, cannot be refueled, and vanishes when its fuel runs out.

## Desired Outcome

- A single item, `PseudoMagic.MagicLightBall`, uses the `TennisBall` icon and world model (`Icon = TennisBall`, `WorldStaticModel = TennisBall`; vanilla definition at `normal.txt:10157`).
- It is always giving light. It has no unlit state, no light/extinguish recipe or double-click action.
- Right-clicking it in the inventory shows "Dismiss Magic Light Ball", which deletes it (Phase 6).
- It cannot be refueled: it must not be accepted by any recipe or action that adds fuel to a drainable light source.
- Starting fuel lasts **2 minutes of game time** in Phase 1 (`UseDelta = 0.05`, 20 uses). After testing, this is raised to **20 minutes of game time** (Phase 4, `UseDelta = 0.005`, 200 uses). Both are derived from the Butter Candle's 8-hour design; see Research Summary.
- Light brightness and radius started matching the lit Butter Candle (`LightDistance = 5`, `LightStrength = 1.2`) and are raised in Phase 7 to `LightStrength = 1.5`, `LightDistance = 15`. The original values:  `LightDistance = 5`, `LightStrength = 1.2`, `TorchCone = false`, with a placed light of radius 5 and colour (0.8, 0.66, 0.45). These may be changed after testing.
- When dropped on the ground, it still lights the surrounding area, and the light moves or goes away when the ball is picked up, as the Butter Candle's does.
- When fuel reaches zero the item is deleted (carried, on the ground, or in a container) and any placed light is removed.

---

## Research Summary

Findings from reading `PseudoButterCandle` (code is in `mymods/PseudoButterCandle/PseudoButterCandle/42/media/`):

- **Item:** `ButterCandleLit` is `ItemType = base:drainable` with `LightDistance = 5`, `LightStrength = 1.2`, `TorchCone = false`, `ActivatedItem = false`, `UseWhileUnequipped = true`, `cantBeConsolided = true`, and `UseDelta = 0.0002083333`. It has `ReplaceOnDeplete = Base.TinCanEmpty`; leaving that out makes `DrainableComboItem` delete the item at 0 uses (`DrainableComboItem.java:~280`).
- **Carried light:** In the player's inventory the engine drains the item and produces light itself via `UseWhileUnequipped`; `ticksPerEquipUse` defaults to 30 (`DrainableComboItem.java:36, 268`).
- **Dropped light:** A dropped item gives no light by itself. The mod hooks `ISDropWorldItemAction.complete` (`PseudoButterCandle_Shared.lua`) to record the item in ModData and spawn an `IsoLightSource` through a light object (`PseudoButterCandle_LightObject.lua`). `ISInventoryTransferAction.perform` (`PseudoButterCandle_Client.lua`) sends light/extinguish commands when the item moves to or from the floor. The server file handles `light`, `extinguish`, and `load` commands and restores lights when a player connects; `LoadChunk` handling re-creates lights when a chunk streams in.
- **Dropped burn-down:** While on the ground, fuel is reduced by the server in `EveryTenMinutes` (`PseudoButterCandle_Server.lua`), by `UseDelta * 100` each time, and the item is removed when it reaches 0.
- **Tags:** Registered in `registries.lua` with `ItemTag.register(...)`; the lit candle is found by tag.
- **Burn time:** The candle is designed to last 8 hours (480 game minutes). With `UseDelta = 0.0002083333` a full candle has `floor(1 / 0.0002083333)` = 4800 uses, so one use is `480 / 4800` = 0.1 game minute (6 game seconds), or 10 uses per game minute. The ground drain agrees: `EveryTenMinutes` removes `UseDelta * 100` = 100 uses per 10 minutes, and 4800 / 10 per minute = 480 minutes.

**Burn-time derivation for the Magic Light Ball** (keeping the candle's use rate of 10 uses per game minute, so the carried and ground drains stay calibrated to the 8-hour design):

| Burn time | Uses (minutes x 10) | `UseDelta` (1 / uses) | Fuel removed per game minute on the ground |
|-----------|---------------------|-----------------------|--------------------------------------------|
| 2 minutes (Phase 1) | 20 | 0.05 | 0.5 (10 uses x 0.05) |
| 20 minutes (Phase 4) | 200 | 0.005 | 0.05 (10 uses x 0.005) |

Equivalently, 2 minutes is 1/240 of the candle's 8 hours, so the ball's `UseDelta` is the candle's `0.0002083333` x 240 = 0.05.

---

## Tasks

### Phase 1: Magic Light Ball Item (2-minute burn)

**Status:** Work Complete

- [x] Define `MagicLightBall` in `PseudoMagic_Items.txt`: `ItemType = base:drainable`, `DisplayCategory = LightSource`, `Icon = TennisBall`, `StaticModel`/`WorldStaticModel = TennisBall`, `Weight = 0.3` (the vanilla tennis ball weight; see Open Questions), `LightDistance = 5`, `LightStrength = 1.2`, `TorchCone = false`, `ActivatedItem = false`, `UseWhileUnequipped = true`, `UseWhileEquipped = false` (deviation: with it on, a held ball would take an extra use every 10 minutes on top of the engine's continuous drain; the lit candle leaves it at the default), `cantBeConsolided = true`
- [x] Set `UseDelta = 0.05` (20 uses at 10 uses per game minute = 2 game minutes; derivation in Research Summary)
- [x] Do not set `ReplaceOnDeplete`, `ReplaceOnExtinguish`, `ExtinguishItem`, or `DoubleClickRecipe`
- [x] Add `PseudoMagic.MagicLightBall` = "Magic Light Ball" to `ItemName.json`
- [x] Summoning and Dismiss entry: not added (not requested; see Open Questions)

**Technical Notes:**
Carried burn time comes from `ticksPerEquipUse` (30 ticks per use, scaled by game speed) and `UseDelta` (uses = `floor(1 / UseDelta)`). Because the ball keeps the Butter Candle's per-use rate and only changes the number of uses, the carried drain should land on 2 game minutes if the candle's carried drain is 8 hours. Confirm by timing it against the game clock and record the result here; the ground burn-down is separate (Phase 2).

### Phase 2: Dropped Light and Ground Burn-Down

**Status:** Work Complete

- [x] Add PseudoMagic client, server, and shared Lua modelled on PseudoButterCandle: ModData keyed per item ID, light object, drop hook (`ISDropWorldItemAction.complete`), transfer hook (`ISInventoryTransferAction.perform`), command handling, chunk-load restore, and load-on-join
- [x] Use PseudoMagic-prefixed names (module key, light object class, ModData key) so nothing collides with PseudoButterCandle if both mods are loaded
- [x] Register the `pseudomagic:magiclightball` tag in a `registries.lua` and put it on the item
- [x] Burn the ground item down on a timer fine enough for a 2-minute lifetime: `EveryOneMinute`, removing 10 uses' worth of fuel (`UseDelta * 10`) per minute (0.5 in Phase 1, 0.05 in Phase 4). `EveryTenMinutes` is too coarse
- [x] When fuel hits 0 on the ground, remove the placed light and the world item
- [x] Ensure light and item removal also happens when the ball is picked up and put into a container, and when the ball is dropped from a container or a hotbar slot

**Technical Notes:**
Reuse the Butter Candle structure but do not copy it blindly. It tracks the item by `getID()` in a square scan, and it never handles an item that burns out while carried, which is needed here because the carried item is also deleted at 0. The ground drain must use the same fuel units as the carried drain so picking up and dropping the ball does not reset or skip time.

**Implementation (Phases 1 and 2):** Item `MagicLightBall` in `PseudoMagic_Items.txt`; tag registered in `media/registries.lua`; Lua in `lua/shared/PseudoMagic_LightBall_Utils.lua` (helpers and light object), `lua/shared/PseudoMagic_LightBall_Drop.lua` (drop hook), `lua/client/PseudoMagic/PseudoMagicLightBallClient.lua` (transfer hook, server commands, load on join), and `lua/server/PseudoMagicLightBallServer.lua` (commands and the `EveryOneMinute` ground burn-down). Names use the `PseudoMagicLight` prefix and the `PseudoMagicLightBall` command module and ModData key. Ground burn-down subtracts `getUseDelta() * 10` per game minute. Untested: whether the engine also drains a ground item on its own (which would double the rate); watch for this in Phase 3.

### Phase 3: Initial Testing (2-minute ball)

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Spawn the item and confirm name, tennis ball icon, and ground model
- [ ] Confirm it lights the player when carried in the inventory, at the same brightness and radius as the lit Butter Candle
- [ ] Confirm it cannot be extinguished and has no light/extinguish menu entry
- [ ] Confirm it cannot be refueled (no recipe or action accepts it as fuel)
- [ ] Confirm it disappears after about 2 minutes of game time when carried
- [ ] Confirm that dropping it keeps the area lit, that the light follows the ball when it is picked up, and that it disappears after about 2 minutes while on the ground
- [ ] Confirm that dropping, picking up, and dropping again does not reset the remaining time
- [ ] Confirm behavior after saving and reloading with a ball on the ground (light restored, time preserved)
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

### Phase 4: Extend Burn Time to 20 Minutes

**Status:** Work Complete

- [x] After Phase 3 testing, change `UseDelta` from 0.05 to 0.005 so the ball lasts 20 minutes of game time (200 uses at 10 uses per minute)
- [x] Adjust the ground burn-down per-minute amount to match (0.5 to 0.05, i.e. `UseDelta * 10`)
- [ ] Re-run the burn-time checks from Phase 3 at the new duration (user)
- [ ] Review brightness and radius once more (user) and note any change the user requests

**Implementation:** `UseDelta` changed from 0.05 to 0.005 in `PseudoMagic_Items.txt`. The ground drain reads `getUseDelta() * 10`, so no Lua change was needed.

**Technical Notes:**
Derive the ground per-minute amount in Lua from the item's own `getUseDelta() * 10` instead of hard-coding it, so this phase is a one-line change to `UseDelta`.

### Phase 5: Summon the Magic Light Ball from the Ring of the Mage

**Status:** Work Complete

- [x] Add a "Magic Light Ball" entry to the Ring of the Mage's Summon submenu in `PseudoMagicMenu.lua`, adding `PseudoMagic.MagicLightBall` to the main inventory (synced for multiplayer, as for the other summoned items)
- [x] After summoning the ball, equip it automatically in the secondary hand
- [x] Add `UI_PseudoMagic_SummonLightBall` = "Magic Light Ball" to `UI.json`
- [x] Decide whether the ball also gets a "Dismiss" option (see Open Questions 4 and 7) and implement that decision: no Dismiss (recommended default; `noDismiss = true`)
- [ ] Test (user): summon with both hands empty, with the primary hand full, with the secondary hand already holding something, and with a two-handed item equipped

**Technical Notes:**
The Summon submenu and Dismiss options are driven by the `MAGIC_ITEMS` table (`PseudoMagicMenu.lua`), and `summonItem` currently only calls `inv:AddItem(fullType)` and `sendAddItemToContainer`. The plan is to give a table entry an optional flag (for example `equipSecondary = true`) so only the ball is equipped, and, if Dismiss is not wanted, a second flag that leaves it out of the Dismiss list.

For equipping, vanilla queues `ISEquipWeaponAction:new(character, item, maxTime, primary, twoHands, alwaysTurnOn)` (`media42_20_4/lua/shared/TimedActions/ISEquipWeaponAction.lua:277`); passing `primary = false, twoHands = false` equips the secondary hand and shows "Equip secondary". This is the multiplayer-safe path and handles whatever is already in the hand. The alternative, calling `playerObj:setSecondaryHandItem(item)` directly, is instant but vanilla only uses it in debug scenarios, and it may skip the sync and hand-clearing the timed action does. Prefer the timed action unless testing shows a problem.

**Implementation:** `MAGIC_ITEMS` entry `{ name = "LightBall", ..., noDismiss = true, equipSecondary = true }`. `summonItem` now takes the table entry and, when `equipSecondary` is set, queues `ISEquipWeaponAction:new(playerObj, item, 50, false, false)`. Dismiss options skip `noDismiss` entries. Open Question 7 was answered with the recommended default (no Dismiss); say so if you want it changed. Open Question 8 (busy hands) is to be observed in testing. (Superseded by Phase 6: `noDismiss` has since been removed and the ball now has a Dismiss option.)

Interaction with Phase 2: a ball held in the secondary hand is carried, so it is drained by the engine's carried drain and lights the player; `UseWhileEquipped = false` (Phase 1) keeps held and pocketed drain the same.

### Phase 6: Dismiss Option for the Magic Light Ball

**Status:** Work Complete

Reverses the Phase 5 default of "no Dismiss": the ball now gets the same "Dismiss" menu option as the other magic items.

- [x] Remove `noDismiss = true` from the `LightBall` entry in `MAGIC_ITEMS` (`PseudoMagicMenu.lua`), so it is included in the Dismiss list (keep `equipSecondary = true`)
- [x] Add `UI_PseudoMagic_DismissMagicLightBall` = "Dismiss Magic Light Ball" to `UI.json`
- [x] Remove the now-unused `noDismiss` handling from the `DISMISS_TEXT` loop (removed)
- [ ] Test (user): "Dismiss Magic Light Ball" appears only on the ball; it deletes the ball when it is held in the secondary hand, in the main inventory, and in a bag; the light stops when it is dismissed while carried; the ring's Summon submenu still lists it and still auto-equips it

**Technical Notes:**
The Dismiss option is built from `MAGIC_ITEMS` and `DISMISS_TEXT[fullType] = "UI_PseudoMagic_DismissMagic" .. name`, so for `name = "LightBall"` the key is `UI_PseudoMagic_DismissMagicLightBall`. The existing `dismissItem` already removes an equipped item from the hands (`removeFromHands`) before removing it from its container and syncing, so no new logic is expected. A carried ball emits light only through the engine, so deleting it ends the light with it.

Scope: the inventory context menu only. A ball lying on the ground is a world item with no inventory menu, so it cannot be dismissed there. Picking it up first gives the option. If the ball is dismissed while it has a placed light recorded (it can only be dismissed from inventory, where the pickup path already removed the light), no ModData cleanup should be needed; verify in testing.

### Phase 7: Increase Light Strength and Distance

**Status:** Work Complete

The Phase 3 and 4 testing is done and the ball should now light a bigger area than the Butter Candle it was modelled on.

- [x] Change `LightStrength` from 1.2 to 1.5 on `MagicLightBall` in `PseudoMagic_Items.txt`
- [x] Change `LightDistance` from 5 to 15 on `MagicLightBall`
- [x] Change the `Utils.lightDistance` fallback in `PseudoMagic_LightBall_Utils.lua` from 5 to 15, so the dropped-light default matches the item (the drop hook already passes `item:getLightDistance()`)
- [x] Update the item comment and the Desired Outcome to say the ball no longer matches the Butter Candle's light
- [ ] Test (user): carried light is visibly stronger and reaches farther; a dropped ball lights the same larger radius; the light still follows pickup and drop; check for visual or performance problems at distance 15

**Technical Notes:**
`LightDistance` and `LightStrength` are item properties that drive the carried light through the engine. The dropped light is made by Lua: `IsoLightSource.new(x, y, z, 0.8, 0.66, 0.45, radius)` (`PseudoMagic_LightBall_Utils.lua`) takes only a radius and colour, so on the ground only `LightDistance` matters and `LightStrength` has no effect unless the ground light is changed too. If the ground light should also look 25% stronger than the carried 1.2 baseline, the colour values (0.8, 0.66, 0.45) would need scaling; that is not in scope unless testing shows a mismatch.

A ball already lying on the ground in an existing save has its radius stored in ModData (`lightDistance` in the drop data), so it keeps the old radius of 5 until picked up and dropped again. Test with a freshly dropped ball.

---

## Open Questions

1. **Is the carried drain really 8 hours for the candle?**
   The 8-hour figure is the design target and matches the ground math (4800 uses at 10 per minute). The carried drain uses the engine tick counter (`ticksPerEquipUse = 30`), so Phase 3 confirms the ball's carried 2 minutes by timing it. If it is off, adjust `ticksPerEquipUse` for the ball rather than `UseDelta`.

2. **Which timer handles ground burn-down?**
   The Butter Candle uses `EveryTenMinutes`, which cannot resolve 2 minutes. Recommendation: use `EveryOneMinute` and subtract `UseDelta * 10` per minute.

3. **Weight?**
   Recommendation: 0.3 (vanilla `TennisBall`), unless a lighter value is wanted.

4. **Should the Ring of the Mage summon the Magic Light Ball, and should it get a Dismiss option?**
   Summoning is in scope (Phase 5). Dismiss is added in Phase 6; see question 7.

5. **Light colour?** (Strength and distance were raised in Phase 7.)
   The Butter Candle uses a warm candle colour (0.8, 0.66, 0.45). Recommendation: keep it for now, since brightness and radius are to match; change after testing if a "magic" colour is wanted.

6. **Dependency on PseudoButterCandle?**
   Recommendation: no dependency. Copy the pattern into PseudoMagic with its own names so the mod stands alone.

7. **Should the Magic Light Ball have a "Dismiss" option?**
   Resolved: yes. Phase 5 shipped with no Dismiss as a default, and the user then asked for one (Phase 6). Dismiss deletes the ball outright, so it acts as the way to end it early even though it cannot be extinguished or refueled.

8. **What if the secondary hand is busy or a two-handed item is equipped?**
   The timed action replaces the secondary item and a two-handed item would be unequipped. Recommendation: accept the vanilla behavior and record what happens in testing.

---

## Notes and Risks

- Risk: ground burn-down timing is the hardest part; the Butter Candle's 10-minute timer is too coarse, and per-minute server ticks in multiplayer need to stay in step with each client's carried drain.
- Risk: a carried ball that burns out must be deleted correctly from hands, containers, and hotbar attachments and synced in multiplayer.
- Risk: the Butter Candle mod hooks the same vanilla functions (`ISDropWorldItemAction.complete`, `ISInventoryTransferAction.perform`). If both mods are active, the hooks chain, so each must call the original and ignore items it does not own.
- Risk (Phase 5): auto-equipping replaces whatever is in the secondary hand, and a summoned ball starts burning immediately while carried, so a ball summoned and not used is wasted.
- Risk: `TennisBall` is a `base:normal` item; the new item is drainable, so its inventory tooltip and display (a fuel bar) will differ from the vanilla ball.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 003 and 004 (item definitions in `PseudoMagic_Items.txt`, text keys in `ItemName.json`).

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
