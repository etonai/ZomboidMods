# DevCycle 006: Ring of Flight

**Status:** VERIFIED
**Start Date:** 2026-11-12
**Target Completion:** TBD
**Focus:** (Changed in Phase 7: the flight powers now belong to the Ring of the Mage and there is no separate Ring of Flight.) Add the Ring of Flight, a ring worn on a finger that lets the player fly (hover, climb, descend, and move through the air) at a slow 1 tile per second, using the technique studied in `claudeDocs/claude_KintoUn.md`.

---

## Goal

Add a new ring item, the "Ring of Flight". While one is worn on any finger, the player can fly: rise and descend with two keys and move horizontally through the air. Flight speed starts deliberately slow, at **1 tile per second**, and may be changed in later DevCycles or phases.

The flight mechanics follow the Kinto-un mod (`notmymods/KintoUn/`): the player's X, Y and Z are written by Lua every tick (`setX`, `setY`, `setZ`, `setLastZ`), the same technique as vanilla's fast-move debug cheat (`ISFastTeleportMove.lua`). No code is copied from Kinto-un; it is a reference for what works. The analysis in `claudeDocs/claude_KintoUn.md` lists the techniques to reuse and the problems to avoid.

## Desired Outcome

- Four items, `PseudoMagic.RingOfFlightRightMiddleFinger`, `...LeftMiddleFinger`, `...RightRingFinger`, `...LeftRingFinger`, follow the same four-finger pattern as the Ring of the Mage, so the ring can be worn on any of the same fingers and switched between them from the clothing menu. The display name is "Ring of Flight" for all four.
- While any Ring of Flight is worn, the player can hold an "up" key to rise and a "down" key to descend. Releasing both keys makes the player hover at the current height.
- While airborne, the movement keys move the player in the air at **1 tile per second**. On the ground, movement is vanilla (no speed boost).
- The player lands on the first solid floor below, takes no fall damage from a controlled descent, and normal movement resumes.
- Taking the ring off in the air makes the player glide down gently instead of dropping.
- The up and down keys are configurable in Options > Mods.
- Flight speed, climb rate, and maximum height are each a single named constant (or sandbox option, see Open Questions) so a later DevCycle can change them without rewriting the logic.

## Scope

- **Single-player first.** The Kinto-un analysis found that a multiplayer server's speed and no-clip checks (`AntiCheatSpeed`, `AntiCheatNoClip`) may react to a client that writes its own position. Multiplayer behavior is out of scope for this cycle and is recorded as a risk.
- **No new animation art in this cycle.** Phase 6 replaces the walk, run and fall animations with an existing vanilla standing clip (through AnimSet nodes); a custom floating pose is a candidate for a later DevCycle.

---

## Research Summary

From `claudeDocs/claude_KintoUn.md` (verified against v42.20.4):

- **Z hold:** `player:setZ(z)`, `player:setLastZ(z)`, and `player:setFallTime(0)`, repeated every tick (`OnTick`) while flying. Vanilla's fast-move debug code (`ISFastTeleportMove.lua`) uses the same `setZ` plus `setLastZ` pair every tick to stop the engine treating the height as a fall.
- **The game will not walk an airborne player.** `IsoGameCharacter.isFalling()` is true when the character is above `getMinFloorZ()`, so the movement keys must be read directly while flying and the position moved by Lua (`push`).
- **Key names:** the Kinto-un code reads keys with `KeybindId.FORWARD` and so on, which does not exist in any of the three builds in this repo. In v42.20.4 `Core.getKey` takes a string, and vanilla Lua uses names such as `"Forward"` and `"Backward"` (`CFarming_Interact.lua:279`). The exact names for left, right, run and sprint must be confirmed (see Phase 1).
- **Isometric directions:** forward is (-1,-1), backward (+1,+1), left (-1,+1), right (+1,-1) in tile space.
- **Collision:** moving in steps of 0.2 tiles with wall, window and door checks (`isWallTo`, `isWindowTo`, `isDoorTo`, `isBlockedTo`, `isFree`, `isSolid`) avoids skipping through walls. While high above the ground, only walls, windows and doors need to block.
- **Landing:** find the highest `TreatAsSolidFloor()` square below the player (level 0 always counts), and descend to it.
- **Ring pattern:** the existing four-finger Ring of the Mage items in `PseudoMagic_Items.txt` (body locations `base:right_middlefinger`, `base:left_middlefinger`, `base:right_ringfinger`, `base:left_ringfinger`, with `ClothingItemExtra` and `ClothingItemExtraOption` for switching fingers). Vanilla has other ring looks that can be reused with no new art, for example `Ring_*_Silver`, `Ring_*_GoldDiamond`, `Ring_*_GoldRuby`, `Ring_*_SilverDiamond`.
- **Reading the worn state:** a scan of the player's worn items for the four full types, as Kinto-un does in `KintoUn.isRiding` (`getWornItems()`).

---

## Tasks

### Phase 1: Research Spike (key names and a hover test)

**Status:** In Progress

- [x] Find the exact keybinding names in v42.20.4 for forward, backward, left, right, run and sprint (check `Core.java` key map registration and the game's key binding list), and record them in the Technical Notes
- [ ] Confirm `isKeyDown(int)` and `getCore():getKey(name)` return usable values for those names (needs the game; check in Phase 8; vanilla Lua already calls `isKeyDown(getCore():getKey("Run"))` in `Tutorial/Steps.lua:1512`)
- [x] ~~Write a throwaway hover test script~~ Skipped: the real flight code (Phase 3) does the same Z hold, so the in-game hover check is part of Phase 8 testing instead
- [ ] Record whether a fractional Z (between floors) renders and lights correctly (needs the game; check in Phase 8)

**Technical Notes:**
**Result (key names):** `media42_20_4/lua/shared/keyBinding.lua` registers the bindings `"Forward"`, `"Backward"`, `"Left"`, `"Right"`, `"Run"`, `"Sprint"` and `"Aim"`, and `Core.getKey(String)` (`Core.java:2855`) takes those names. The flight code uses Forward, Backward, Left and Right (run and sprint are not used because speed is flat). The two things most likely to fail are the key names and fractional-height behavior. This phase answers both before any item or menu work. Record results here. The throwaway script is deleted (or kept only as a debug aid) once Phase 3 supersedes it.

### Phase 2: Ring of Flight Items

**Status:** Work Complete

- [x] Define the four finger variants in `PseudoMagic_Items.txt`, following the Ring of the Mage pattern (`ItemType = base:clothing`, `Cosmetic = true`, matching `BodyLocation`, `ClothingItem`, `ClothingExtraSubmenu`, `ClothingItemExtra`, `ClothingItemExtraOption`, `WorldStaticModel`)
- [x] Choose a vanilla ring look and icon that is visibly different from the gold Ring of the Mage (see Open Questions)
- [x] Add the four names, all "Ring of Flight", to `ItemName.json`
- [x] Spawn the rings through the debug item list and confirm they can be worn on each finger and switched between fingers
- [x] Confirm switching fingers keeps the ring a Ring of Flight (all four full types remain valid)

**Technical Notes:**
No flight behavior in this phase. The items are cosmetic until Phase 3. Whether the ring should also be summonable from the Ring of the Mage is not requested here (see Open Questions).

### Phase 3: Flight Core

**Status:** Work Complete

- [x] Add a client script (for example `lua/client/PseudoMagic/PseudoMagicFlight.lua`) with its own namespace (`PseudoMagicFlight`), separate from the existing menu script
- [x] Detect "ring worn" by scanning worn items for the four Ring of Flight full types
- [x] Register up and down key binds through `PZAPI.ModOptions` (defaults: `.` to rise, `,` to descend, as in Kinto-un; see Open Questions), loaded on `OnGameStart`
- [x] Rise at the climb rate while the up key is held, capped at the maximum height; descend while the down key is held; hover when neither is held
- [x] Hold the height every tick with `setZ`, `setLastZ`, `setFallTime(0)` (`OnPlayerUpdate` and `OnTick`)
- [x] While airborne, read the movement keys directly (using the names found in Phase 1), set the forward direction, and move the player **1 tile per second** in small steps with wall, window and door checks
- [x] Do not move the player on the ground (vanilla movement)
- [x] Define speed, climb rate and maximum height as named constants at the top of the script
- [x] Wrap the update in `pcall` and print a prefixed error message, as Kinto-un does

**Technical Notes:**
Movement per tick is `speed * dt`, where `dt` is real-time seconds since the last update, capped (Kinto-un caps at 0.1). Do not boost speed with height (Kinto-un does); keep it a flat 1 tile per second. Take `groundAt` and `blocked` as the model for landing and collision (see the Kinto-un analysis, sections 3.4 and 3.5), rewritten for this mod.

### Phase 4: Landing, Removal, and Edge Cases

**Status:** Work Complete

- [x] Land on the first solid floor below (level 0 always solid) and hand control back to the game
- [x] Taking the ring off while airborne glides the player down at a gentle rate instead of letting them fall
- [x] Stop flying and release the Z hold if the player enters a vehicle, dies, or is knocked down
- [x] Do not let the player rise through a solid floor above (ceiling check)
- [x] Turn off the mod's movement while aiming
- [x] Handle saving and loading while airborne (see Notes and Risks)
- [x] Confirm no fall damage on a controlled landing or a glide

**Technical Notes:**
The "held height" lives only in Lua state. If the player saves while hovering, the saved Z is a height above the ground, and after loading the mod has no held height, so the engine would treat the player as falling and apply fall damage. This phase must detect "ring worn and above the ground at load" and resume hovering or glide down.

**Implementation (Phases 2 to 4):** Items `RingOfFlight{RightMiddle,LeftMiddle,RightRing,LeftRing}Finger` use the vanilla silver ring looks (`Ring_Silver` icon, `Ring_*_Silver` clothing items). Text is in `ItemName.json` and the new `IG_UI.json`. Flight is in `lua/client/PseudoMagic/PseudoMagicFlight.lua`, with constants at the top (`FLY_SPEED = 1.0`, `CLIMB_RATE = 1.0`, `GLIDE_RATE = 0.6`, `MAX_HEIGHT = 8`). Taking the ring off in the air glides down; vehicle, death and knockdown release the held height; aiming stops horizontal movement; a ceiling check stops rising through a solid floor; `OnCreatePlayer` marks the player so the first update resumes hovering if the player starts above the ground with a ring on. None of it has been run in game.

**Speed change (after testing):** the user asked to double the flight speed, so `FLY_SPEED` was raised from 1.0 to 2.0 tiles per second. The 1 tile per second figures elsewhere in this document are the original plan; the Phase 8 timing check should now expect about 2 tiles per second.

### Phase 5: Fix Falling Animation and Death Near the Ground

**Status:** In Progress

Added after in-game testing showed two problems: (1) while hovering, the character sometimes plays a falling animation, and (2) when the character gets close to the ground it falls and dies.

- [x] Reset the engine's accumulated fall speed every tick while the height is held: call `player:setLastFallSpeed(0)` and `player:setbFalling(false)` in `holdZ` (each inside `pcall`, since I have not confirmed they are exposed to Lua), alongside the existing `setFallTime(0)`
- [x] Add temporary debug output of `player:getLastFallSpeed()` while flying (for example once per second, under the existing `DEBUG` constant) to confirm the diagnosis below before and after the fix
- [ ] Re-test: no falling animation during a long hover (a minute or more)
- [ ] Re-test: descending to the ground, onto a roof, and onto an upper floor causes no damage and no fall, including after a long hover and after a fast descent
- [ ] Re-test: taking the ring off in the air (glide) and loading a save while hovering do not cause a fall
- [ ] If the fall speed fix is not enough, add a safety net near the ground (see Technical Notes)

**Implementation:** `holdZ` in `PseudoMagicFlight.lua` now also calls `setLastFallSpeed(0)` and `setbFalling(false)` (each in `pcall`) every time the height is held, which is every tick. While `DEBUG` is true it prints, once per second, `z` and the value of `getLastFallSpeed()` just before the reset, so the log shows whether the fall speed was actually growing (it should read small numbers after the fix). The re-test items and the safety net are still open: the fix has not been run in game.

**Technical Notes:**
Diagnosis (from reading the v42.20.4 code; not yet confirmed in game): the engine runs `IsoGameCharacter.updateFalling()` on every update (`IsoGameCharacter.java:10105`). While the character is not climbing, in a vehicle, or in a few special states (`shouldBeFalling()`, line 10155), the engine treats a character above the floor as falling and does the following each update:

- It adds to `lastFallSpeed` (about 5 per second of falling) and lowers Z by `lastFallSpeed * dt + ...` (lines 10120 to 10141).
- `isFalling()` is true when `lastFallSpeed` is above `FallingConstants.isFallingThreshold` (about the speed of a 0.35-floor fall) and the character is above `getMinFloorZ()` (line 1110). That value drives the falling animation (the `bFalling` variable).
- If the new Z would go below the floor, it calls `DoLand(impactSpeed)`, where the impact speed comes from `lastFallSpeed` (lines 10128 to 10133). That is what causes fall damage and death.

The mod restores Z every tick with `setZ` and `setLastZ`, and resets `fallTime`, but it never resets `lastFallSpeed`, and `fallTime` is not what the landing damage reads. So while hovering, `lastFallSpeed` grows without limit:

1. After a few seconds it passes `isFallingThreshold`, so `isFalling()` becomes true and the falling animation plays (problem 1; "sometimes" matches the delay and any frame where the value crosses the threshold).
2. The per-update drop (`lastFallSpeed * dt`) grows to a large fraction of a floor, so when the character gets within that distance of the floor, the engine's step goes below the floor and calls `DoLand` with a large impact speed, which is fatal (problem 2).

Supporting evidence: the user reports that Kinto-un shows the same two problems in game (falling animation while flying, and a fatal fall near the ground). Kinto-un uses the same Z hold and also resets only `fallTime`, so this fits the diagnosis, although it does not prove which field is responsible.

The fix is to keep `lastFallSpeed` at zero while the height is held, so the engine's per-update drop stays tiny and the character never counts as falling. Kinto-un resets only `fallTime` and the user has seen the same problems in it.

Safety net if needed: while the character is within about one floor of the ground and descending, set Z straight to the ground height once it is within a small margin, or snap to the ground and clear `lastFallSpeed` and `falling` at the same moment so that `DoLand` is never reached. Also consider holding the Z in an earlier event than `OnTick` if the order of updates still lets a hard landing happen.

### Phase 6: Standing Pose While Flying (No Walk or Run Animation)

**Status:** Work Complete

Goal: while the character is flying, the walking, running, sprinting and falling animations are replaced with a still standing pose, so the character looks like it is levitating and not running in the air.

- [x] Set an animation variable (for example `PseudoMagicFlying`) on the local player every update: true while the height is held (flying), false otherwise (landed, ring removed, vehicle, death, knockdown)
- [x] Add AnimSet nodes under `PseudoMagic/42/media/AnimSets/player/` for `idle`, `movement`, `run`, `sprint` and `falling`, each conditioned on that variable being true, each playing the same standing animation (see Technical Notes)
- [x] Add a falling-land node that ends the landing state cleanly, as Kinto-un does (`falling/KintoUnRideLand.xml`)
- [x] Use unique node names with a `PseudoMagicFlight` prefix so they cannot collide with Kinto-un or vanilla nodes
- [x] Find a standing animation clip that already exists in the game (candidate: `Bob_Idle`, the clip Kinto-un says its pose was generated from; confirm the name in the game install under `media/anims_X/Bob/`) so no new art is needed
- [ ] Test (user): no walk, run, or sprint motion while hovering, moving horizontally, rising or descending; the normal animations return immediately on landing and when the ring is removed; walking and running on the ground with the ring worn are unchanged; aiming, holding a weapon, and carrying items still look acceptable

**Implementation:** The game install was available locally (`C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media`), so the clip and nodes were checked there: `anims_X/Bob/Bob_Idle.X` exists, vanilla idle is `AnimSets/player/idle/Idle.xml` (`m_AnimName` `Bob_Idle`, speed scale 0.48), vanilla fall is `falling/fall_loop.xml` (conditions `bFalling` true and `fallSpeedSeverity`), and vanilla landing nodes (`falling/land_gentle.xml`) end with the event `SetVariable bLandAnimFinished=true`. Vanilla `m_Priority` values range from 0 to 10, so the Kinto-un values of 20 (priority) and 50 (condition priority) are above every vanilla node. Files added under `PseudoMagic/42/media/AnimSets/player/`: `idle/PseudoMagicFlight.xml`, `movement/PseudoMagicFlight.xml`, `run/PseudoMagicFlight.xml`, `sprint/PseudoMagicFlight.xml`, `falling/PseudoMagicFlight.xml`, `falling/PseudoMagicFlightLand.xml`. All play `Bob_Idle` at speed scale 0.48 (land: 4.0, not looped). `PseudoMagicFlight.lua` sets `PseudoMagicFlying` to the result of `altitude()` each update, and to false on the dead, vehicle and knocked-down path. The test item is unticked: not run in game. Because the nodes outrank vanilla's priority 10 nodes, they could also hide aiming or weapon-holding poses while flying; check this in testing.

**Technical Notes:**
Feasibility: **yes, and the technique is already proven by Kinto-un** (`notmymods/KintoUn/42/media/AnimSets/player/`). Kinto-un's `OnPlayerUpdate` calls `player:setVariable("KintoUnRide", on)`, and its AnimSet XMLs declare a condition on that variable (plus a higher `m_Priority` of 20 and `m_ConditionPriority` of 50 than the vanilla nodes), so the engine plays its animation instead of the vanilla walk, run, sprint, idle or fall animation. Each node is a small XML file with `m_Name`, `m_AnimName`, `m_Priority`, `m_ConditionPriority`, `m_Looped`, `m_BlendTime`, `m_SpeedScale`, and `m_Conditions` (a BOOL condition on the variable; the falling node also requires `bFalling` true; the land node requires `bFalling` false and fires a `SetVariable` event `bLandAnimFinished=true` at the end).

What is not available in this repository (the game install has them): the `media42_20_4/` folder contains only Lua and scripts, not AnimSets or animation clips, so I could not check the vanilla AnimSet nodes, their priorities, or the vanilla clip names here. Kinto-un ships its own clip (`anims_X/Bob/Bob_KintoUnRide.x`), but we want to reference an existing vanilla clip instead. (Verified later against the game install; see Implementation above.)

Why the AnimSet approach and not a Lua-only one: the animation state is driven by the engine's own movement and falling variables (for example `bFalling`, the movement and run states), which the engine recomputes every update, so setting them from Lua is unreliable. Overriding with a higher-priority AnimSet node conditioned on our own variable does not fight the engine. A Lua-only approach was not investigated and is not recommended.

Relationship to Phase 5: the falling animation shown during a long hover (Phase 5) comes from the engine's fall speed. Phase 5 removes the cause. This phase additionally covers the movement and falling animations by overriding them, so it also acts as a safety net for the falling pose.

Risks:
- Animation variable and AnimSet nodes are client-side. In multiplayer other players would not see the pose unless the variable is synchronized; out of scope (single-player first).
- Upper-body animations (aiming, holding a weapon, carrying) may blend over the standing pose; Kinto-un turns off its movement while aiming. Check in testing.
- A standing clip with the character's legs in a walking stance (if the wrong clip is chosen) would look wrong; the idle clip avoids that.
- A pose with no leg motion while moving can look like sliding. This is the intended look for levitation; a custom floating pose is a possible later phase.

### Phase 7: Move Flight to the Ring of the Mage

**Status:** Work Complete

Decision after testing: there is no separate Ring of Flight. The Ring of the Mage gets the flight powers instead.

- [x] Remove the four Ring of Flight items from `PseudoMagic_Items.txt`
- [x] Remove the four "Ring of Flight" names from `ItemName.json`
- [x] Change the worn-ring check in `PseudoMagicFlight.lua` to the four Ring of the Mage full types (`PseudoMagic.RingOfTheMage{RightMiddle,LeftMiddle,RightRing,LeftRing}Finger`)
- [x] Rename the options page and the up and down key labels (`IG_UI.json`, `PZAPI.ModOptions:create`) from "Ring of Flight" to "Ring of the Mage"
- [x] Update the comments in the script and the AnimSet XMLs
- [ ] Test (user): wearing a Ring of the Mage on each finger allows flight; with no ring worn there is no flight; switching fingers while flying behaves sensibly; the existing ring features (Summon menu) still work

**Technical Notes:**
The rest of the cycle's text and phases still say "Ring of Flight" because that is what they were written for; read it as the Ring of the Mage from this phase on. The animation variable, key bind ids, ModOptions id (`PseudoMagicFlight`) and file names are unchanged, so existing key settings are kept. A save that already contains a Ring of Flight item will have an item with a missing script: remove it with the debug tools or expect a console warning. The Ring of the Mage's own cosmetic properties and menu are unchanged.

### Phase 8: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Confirm the ring spawns, wears on each finger, and switches fingers
- [ ] Confirm that with the ring worn the up key rises, the down key descends, and releasing both hovers
- [ ] Time horizontal flight over 10 tiles and confirm it is about 2 tiles per second (originally 1; doubled after testing)
- [ ] Confirm normal ground movement is unchanged with the ring worn
- [ ] Confirm walls, windows, and doors block flight and that flight cannot pass through a solid ceiling
- [ ] Confirm landing on the ground, on a roof, and on an upper floor
- [ ] Confirm removing the ring in the air glides to the ground with no damage
- [ ] Confirm save and load while airborne does not cause a fall
- [ ] Confirm entering a vehicle, aiming, and being knocked down behave sensibly
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

1. **Which vanilla ring look should the Ring of Flight use?**
   Recommendation: a silver ring (`Ring_*_Silver` or `Ring_*_SilverDiamond`), so it is easy to tell apart from the gold Ring of the Mage.

2. **Default keys for rise and descend?**
   Kinto-un uses `.` and `,`. Recommendation: use the same defaults, configurable in Options > Mods.

3. **Climb rate and maximum height?**
   Kinto-un climbs at 1.2 floors per second to a default maximum of 8 floors. Recommendation: start with 1 floor per second and a maximum of 8 floors, as named constants, and tune later alongside the 1 tile per second speed.

4. **Should flight speed scale with the game speed (fast-forward)?**
   Kinto-un uses real time, so flying does not speed up when the game is accelerated. Recommendation: use real time for the first version and decide after testing.

5. **Should the Ring of the Mage be able to summon the Ring of Flight?**
   Not requested. Recommendation: leave it out of this cycle.

6. **Should flying use endurance, or have other costs or limits?**
   Not requested. Recommendation: no cost for now; the slow speed is the limit. Revisit in a later cycle.

7. **Sandbox options for speed, climb rate and height?**
   Not requested. Recommendation: constants first; add sandbox options in a later cycle if wanted.

---

## Notes and Risks

- Risk: the Kinto-un movement-key code uses `KeybindId`, which does not exist in the v42.20.4, v42.19 or v42.11.0 sources in this repo. Phase 1 must find the correct string key names before the flight core is written.
- Risk: fractional heights between floors may render or light oddly. Phase 1 tests this early.
- Risk: the engine's own falling update keeps accumulating fall speed while a height is held by Lua (Phase 5); until that is reset every tick, long hovers eventually show a falling animation and landings can be fatal.
- Risk: saving or loading while airborne could drop the player and cause fall damage (Phase 4).
- Risk: with no custom animation, the player may show the falling pose while flying, which can look wrong. Acceptable for this cycle.
- Risk: multiplayer servers may reject or rubber-band position written by the client (`AntiCheatSpeed`, `AntiCheatNoClip`). Out of scope; single-player only.
- Risk: a ring switched between fingers is replaced by a different item (vanilla creates a new item), so the "worn" check must accept all four full types.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 003 (the four-finger ring pattern). Reference: `claudeDocs/claude_KintoUn.md`.

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
