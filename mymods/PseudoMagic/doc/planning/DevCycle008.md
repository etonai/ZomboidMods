# DevCycle 008: Ring of the Mage Teleportation

**Status:** In Progress
**Start Date:** 2026-11-12
**Target Completion:** TBD
**Focus:** Give the Ring of the Mage teleportation: a "Bind Location" menu to remember up to seven places, and a "Teleport" menu to travel to any bound place.

---

## Goal

Add two new submenus to the Ring of the Mage's right-click menu, next to the existing "Summon" submenu:

1. **Bind Location** with the options "Bind Location 1" to "Bind Location 7". Choosing one stores the player's current position (x, y, and floor) in that slot.
2. **Teleport** with the options "Teleport to Location 1" to "Teleport to Location 7". Choosing one moves the player to the position stored in that slot.

The mod must therefore keep track of up to seven sets of coordinates, saved with the game, so that a location bound in one play session can be used in a later one.

## Desired Outcome

- Right-clicking a Ring of the Mage shows "Bind Location" and "Teleport" submenus alongside "Summon".
- "Bind Location N" (N = 1 to 7) records the player's current tile (x, y) and floor (z) in slot N, replacing anything already in that slot.
- "Teleport to Location N" moves the player to the stored position. A slot with nothing bound cannot be used (see Open Questions for how it is shown).
- Bound locations are saved with the game and are still there after saving and reloading.
- Teleporting works from any finger variant of the ring, and teleporting does not leave the player stuck in a vehicle, in mid-air, or inside a wall.
- The existing ring features (Summon, flight) keep working.

## Scope

- **Single-player first.** In multiplayer the server validates position changes (see Research Summary), so a client-only teleport may be reverted or flagged. Multiplayer support is out of scope for this cycle and is recorded as a risk.
- No casting cost, cooldown, or limit on distance is requested. Questions about these are listed in Open Questions.

---

## Research Summary

Checked against v42.20.4 (`zombie42_20_4/` Java, `media42_20_4/` Lua):

- **The teleport call exists.** `IsoGameCharacter.teleportTo(int newX, int newY, int newZ)` (`IsoGameCharacter.java:17388`) exits any vehicle first (`ensureNotInVehicle`), clamps Z to -32 to 31, sets X, Y, Z and the last X and Y, and then calls `ensureOnTile()`. Overloads taking floats truncate to whole tiles (`fastfloor`). Vanilla Lua already calls `getPlayer():teleportTo(x, y, z)` (for example in `ISAdminMessage.lua:84` and `ISPVPLogToolUI.lua:134`), so it is available to Lua.
- **Coordinates are whole tiles.** `teleportTo` takes integers, so a bound position is a tile (x, y) plus a floor (z). The player lands at the tile, not at an exact sub-tile position.
- **Multiplayer checks.** `GameServer.sendTeleport` (`GameServer.java:~1335`) records the teleport (`AntiCheatNoClip.teleport(player)`) and resets the player's network state; a teleport made only on the client is something the server's no-clip and speed checks (`network/anticheats/AntiCheatNoClip.java`, `AntiCheatSpeed.java`) may reject. This is why multiplayer is out of scope for now.
- **Storage options.** Mod data persists with the thing it is attached to: `player:getModData()` is saved with the character, and global `ModData.getOrCreate("PseudoMagicTeleport")` is saved with the world. The Butter Candle and Light Ball mods already use global `ModData` for their data. Which one is right depends on whether bound locations should survive the character's death (see Open Questions).
- **PseudoTransporter already teleports the player, and was tested in game.** `mymods/PseudoTransporter/` (DevCycle 001, tested by Ed in game on 2026-11-06, who reported that it works) moves the player with plain property writes, not `teleportTo`: `playerObj:setX(x); setY(y); setZ(z)` followed by `setLastX(x); setLastY(y); setLastZ(z)` (`PseudoTransporter.lua`, `PT.transportTo`). Setting the `Last*` values too stops the engine treating the move as a huge jump (the same pattern as RV Life, `claudeDocs/claude_RVLifeLessons.md` section 3.3). That is the proven method for this project, so Phase 3 uses it rather than `teleportTo`.
- **PseudoTransporter's arrival-square rule.** `pickArrival` tries the destination tile and its eight neighbours (offsets 0,0; 0,1; 1,0; 0,-1; -1,0; 1,1; -1,-1; 1,-1; -1,1), takes the first loaded square where `sq:isFree(false)` is true, and arrives at the centre of it (`x + 0.5`, `y + 0.5`). If no square is loaded (the destination chunk is not loaded) it falls back to the raw coordinates plus 0.5. This answers the safety question for a destination that is blocked or not loaded.
- **Unloaded destinations.** `getGridSquare` returns nil for an unloaded chunk, so stored coordinates are the source of truth, and the plain coordinate write is used as the fallback. PseudoTransporter's Phase 6 long-distance results were not recorded, so behavior over a very long distance (load time, falling, stalls) is still unconfirmed and stays on this cycle's test list.
- **Disabled menu entries.** PseudoTransporter greys out an unavailable option with `option.notAvailable = true` and a tooltip made with `ISWorldObjectContextMenu.addToolTip()` and assigned to `option.toolTip` (`PseudoTransporterMenu.lua`, and `PseudoTransporterBadge.lua` for the inventory menu). The same pattern applies to unbound Teleport slots.
- **Registry storage.** PseudoTransporter keeps its registry in global `ModData.getOrCreate("PseudoTransporter")`, with `{ x, y, z }` per entry, and clears stale entries. This cycle stores per character instead (decision below), but the table shape is the same.
- **No safeguards by design.** PseudoTransporter deliberately has no checks for vehicles, zombies, or mid-action states. Its design document lists those as candidates for later.
- **Game-version warning.** PseudoTransporter's first test crashed because the installed game's Lua differs from the 42.20.4 copy in this repo (argument order of the moveable functions). That does not affect this cycle's code, but it is a reminder that Lua checked only in the repo should be tested against the installed game.
- **The menu hook already exists.** `PseudoMagicMenu.lua` builds the ring's "Summon" submenu in `onFillInventoryObjectContextMenu`, using `context:addOption`, `ISContextMenu:getNew(context)` and `context:addSubMenu(option, sub)`. The Bind and Teleport submenus use the same calls. The ring menu appears when a ring is among the right-clicked items (`scan()` sets `hasRing`).
- **Flight interaction.** `PseudoMagicFlight.lua` holds the player's height in a Lua table (`held`) and re-applies it every tick. A teleport while flying would otherwise be overwritten the next tick. The flight code needs a way to release or reset the held height on teleport (for example a small exported function).

---

## Tasks

### Phase 1: Location Storage

**Status:** Work Complete

- [x] Create a new client or shared Lua module (for example `PseudoMagicTeleport.lua`) that owns the saved locations, with functions to get, set and clear a slot (1 to 7)
- [x] Store each slot as a small table of whole numbers (`x`, `y`, `z`), in `ModData` under a mod-specific key such as `PseudoMagicTeleport`
- [x] Store the data per character in `player:getModData()` (decision recorded in Open Questions)
- [x] Make sure the data survives saving and reloading (read it lazily and create the table when absent)
- [x] Reject invalid slot numbers

**Technical Notes:**
Keep this module free of menu code so it can be tested on its own. Values are stored as integers (`math.floor` of the player's X and Y; the floor number for Z) because `teleportTo` uses whole tiles. A slot that has never been bound is `nil`.

### Phase 2: Bind Location Menu

**Status:** Work Complete

- [x] In `PseudoMagicMenu.lua`, when a ring is present, add a "Bind Location" option with a submenu of seven entries: "Bind Location 1" to "Bind Location 7"
- [x] Choosing an entry stores the player's current tile and floor in that slot
- [x] Add text keys to `UI.json`: `UI_PseudoMagic_BindLocation` ("Bind Location") and `UI_PseudoMagic_BindLocation1` to `UI_PseudoMagic_BindLocation7` ("Bind Location 1" to "Bind Location 7")
- [x] Show feedback when a location is bound (for example the halo text above the player, "Location N bound")
- [x] Show an already-bound slot in the menu text (with its coordinates); rebinding does not ask for confirmation

**Technical Notes:**
The player position comes from `playerObj:getX()`, `getY()`, `getZ()` at the moment of the click. Use `math.floor` on all three, because the player may be at a fractional position (and a fractional height if flying). The submenu is built with the same pattern as the Summon submenu.

### Phase 3: Teleport Menu and Action

**Status:** Work Complete

- [x] Add a "Teleport" option with a submenu of seven entries: "Teleport to Location 1" to "Teleport to Location 7"
- [x] Add text keys to `UI.json`: `UI_PseudoMagic_Teleport` ("Teleport") and `UI_PseudoMagic_TeleportToLocation1` to `UI_PseudoMagic_TeleportToLocation7`
- [x] Choosing an entry moves the player with the approach proven in PseudoTransporter: `setX`, `setY`, `setZ` and then `setLastX`, `setLastY`, `setLastZ`, using the arrival square chosen by an `isFree` search of the destination tile and its eight neighbours (centre of the tile, `+ 0.5`), with the raw coordinates as the fallback when no square is loaded
- [x] Disable the entry (`option.notAvailable = true`) with a tooltip for slots with no bound location, using the PseudoTransporter pattern
- [x] Make the flight code release or reset its held height when a teleport happens, so the player is not pulled back to the old height
- [x] Exit a vehicle before moving the player (`playerObj:getVehicle()` then `exit`, or `ensureNotInVehicle()`), because the property writes do not do it; no other safeguards (as in PseudoTransporter)
- [x] Add feedback after teleporting (for example halo text, "Teleported to Location N")

**Technical Notes:**
`teleportTo` (`IsoGameCharacter.java:17388`) exits the vehicle and clamps Z, but it takes integers only and has not been tried in this project, so the PseudoTransporter method is used instead. The destination's chunk may not be loaded yet when the player teleports far away; check in testing that the player arrives safely, does not fall through the world, and that the map loads. Vanilla's debug teleport (`DebugUIs/ISTeleportDebugUI.lua`) is a model for what the game itself does around a teleport.

**Implementation (Phases 1 to 3):** New `lua/client/PseudoMagic/PseudoMagicTeleport.lua` (global `PseudoMagicTeleport`: `getSlot`, `clearSlot`, `bind`, `teleport`; slots stored per character in `player:getModData().PseudoMagicTeleport` as `slot1`..`slot7` tables of whole numbers `x`, `y`, `z`). `PseudoMagicMenu.lua` requires it and adds the "Bind Location" and "Teleport" submenus under the ring's menu (function `addTeleportMenus`, called after the Summon submenu); bound slots show `(x, y, floor z)` in the label, unbound Teleport entries are disabled with the tooltip "Nothing is bound to this location." `PseudoMagicFlight.lua` now exports `PseudoMagicFlight.groundAt`, `isFlying(player)` and `release(player)` for the teleport code: binding while flying stores the floor beneath, and teleporting releases the held height first. Teleport exits a vehicle (`ensureNotInVehicle`), picks the arrival square like PseudoTransporter, and shows halo text. Text keys are in `UI.json`. Not tested in game.

### Phase 4: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Confirm right-clicking a ring shows "Summon", "Bind Location" and "Teleport", and that the existing Summon items still work
- [ ] Bind location 1 at one place and location 2 at another, then teleport between them in both directions
- [ ] Bind all seven slots and confirm each teleports to the right place
- [ ] Confirm rebinding a slot replaces the old location
- [ ] Confirm teleporting works on upper floors and at ground level, indoors and outdoors
- [ ] Confirm bound locations survive saving and reloading (and, depending on the decision, death)
- [ ] Confirm a far teleport (several chunks away) arrives safely and the map loads
- [ ] Confirm teleporting while flying, while in a vehicle, and while standing in a doorway behaves sensibly
- [ ] Confirm the ring works from every finger variant
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

All answered by going with the recommendations (Ed's instruction, 2026-11-12). Decisions:

1. **Storage: per character.** Locations are kept in `player:getModData()` under a mod-specific key, so a new character starts with no bindings. (PseudoTransporter uses global `ModData`; this cycle deliberately differs.)
2. **Unbound slots:** all seven Teleport entries are always shown; unbound ones are disabled with a tooltip (`notAvailable` plus `toolTip`, as in PseudoTransporter).
3. **Coordinates in the menu:** bound slots show their coordinates (x, y, floor) in the menu text or tooltip so the player can tell the slots apart. No custom names this cycle.
4. **Rebinding:** no confirmation; the menu text shows that a slot is already bound.
5. **Cost or restriction:** none (no cooldown, cost, distance limit, or combat check), the same as PseudoTransporter.
6. **Effects:** halo text only ("Location N bound", "Teleported to Location N").
7. **Unsafe destination:** use the PseudoTransporter arrival-square search (nearest free square among the tile and its eight neighbours). No other safety check this cycle.
8. **Binding while flying:** bind the floor beneath the player (the ground height under the player's tile found as in `PseudoMagicFlight.lua`'s `groundAt`), not the hovering height.
9. **Ring must be worn?** No. As with Summon, the menu appears on any right-clicked Ring of the Mage.

---

## Notes and Risks

- Risk: multiplayer. A client-side teleport is something the server's anti-cheat may undo or flag. Out of scope; single-player only.
- Risk: teleporting while flying. The flight code re-applies its held height every tick, so the held height must be released or reset on teleport (Phase 3).
- Risk: teleporting to a chunk that is not loaded yet could place the player in the world before it exists. Check in testing.
- Risk: the bound position is a whole tile, so the player lands at the centre of the tile (or the nearest free neighbour) and not at the exact spot where they stood.
- Note: the menu appears on any right-clicked ring, as the Summon menu does today; the ring does not have to be worn.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 003 (the ring menu in `PseudoMagicMenu.lua`) and DevCycle 006 (flight; the held height). Technical reference: `mymods/PseudoTransporter/` (teleport, arrival square, disabled menu entries).

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
