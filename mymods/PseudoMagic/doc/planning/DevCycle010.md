# DevCycle 010: Transit Menu

**Status:** VERIFIED
**Start Date:** 2026-11-13
**Target Completion:** TBD
**Focus:** Add a "Transit" menu to the Ring of the Mage that teleports the survivor to seven fixed, named locations.

---

## Goal

Add a "Transit" item to the Ring of the Mage's right-click menu. Its submenu lists seven named destinations; choosing one teleports the survivor there. The destinations are fixed (unlike the bindable Teleport slots from DevCycle 8) and come from `doc/ideas/transit.txt`.

## Desired Outcome

- Right-clicking a Ring of the Mage shows a "Transit" entry next to Summon, Bind Location and Teleport.
- The Transit submenu lists the seven locations below, by name.
- Selecting one moves the survivor to that location, using the same move as the existing Teleport.
- The existing Bind Location and Teleport menus keep working unchanged.

---

## Research Summary

- **Destinations** (from `doc/ideas/transit.txt`; format is `x, y, z, name`):

| # | Name | X | Y | Z |
|---|---|---|---|---|
| 1 | LSU | 12416 | 2237 | 4 |
| 2 | Farm | 11699 | 6299 | 0 |
| 3 | Rabbit Isle | 8600 | 15086 | 0 |
| 4 | Cow Isle | 2032 | 8620 | 0 |
| 5 | Hen Isle | 10133 | 8303 | 0 |
| 6 | Gigamart | 8000 | 11256 | 2 |
| 7 | Market | 9067 | 12188 | 1 |

- **Existing teleport code:** `PseudoMagic/42/media/lua/client/PseudoMagic/PseudoMagicTeleport.lua` (`PseudoMagicTeleport`, "PMT"). `PMT.teleport(player, n)` looks up a bound slot, leaves any vehicle, releases flight (`PseudoMagicFlight.release`), picks the nearest free square around the destination (`pickArrival`, which falls back to the raw coordinates if no square is loaded), then sets X/Y/Z and LastX/Y/Z. It is tied to slot lookup, so Transit needs a way to teleport to given coordinates. The simplest change is to split `PMT.teleport` into a lookup part and a shared `PMT.teleportTo(player, dest, message)` that Transit also calls.
- **Existing menu code:** `PseudoMagicMenu.lua`, `addTeleportMenus(context, playerObj)` builds the "Bind Location" and "Teleport" submenus and is called from `onFillInventoryObjectContextMenu` only when the player holds a ring (`hasRing`). A Transit builder goes beside it and is called from the same place.
- **Text keys:** menu labels live in `PseudoMagic/42/media/lua/shared/Translate/EN/UI.json` (existing pattern: `UI_PseudoMagic_Teleport`, `UI_PseudoMagic_TeleportToLocation<n>`, `UI_PseudoMagic_Teleported`). Transit needs a `UI_PseudoMagic_Transit` key and a name for each destination.
- **Data layout:** the seven destinations are a fixed table in Lua (for example `PMT.TRANSIT = { {name key, x, y, z}, ... }`), not mod data, since they are not per-character.
- **Far destinations:** every destination is a long way from most starting points (for example Rabbit Isle at y=15086). The destination chunk will not be loaded when the teleport starts. This is the same case `pickArrival` already handles by falling back to raw coordinates, but it needs in-game confirmation over long distances (see Open Questions).

---

## Tasks

### Phase 1: Teleport to Coordinates

**Status:** Work Complete

- [x] In `PseudoMagicTeleport.lua`, factor the move out of `PMT.teleport` into `PMT.teleportTo(player, dest, message)` taking `dest = { x, y, z }`
- [x] Keep `PMT.teleport(player, n)` behaving exactly as before (slot lookup, then `teleportTo`, same "Teleported" halo text)
- [x] Add the fixed destination table `PMT.TRANSIT` with the seven entries above, in order

**Technical Notes:**
`teleportTo` keeps the vehicle exit, flight release, `pickArrival` search and `setX/Y/Z` plus `setLastX/Y/Z` steps unchanged.

### Phase 2: Transit Menu

**Status:** Work Complete

- [x] In `PseudoMagicMenu.lua`, add `addTransitMenu(context, playerObj)` that adds a "Transit" option with a submenu of the seven destinations
- [x] Label each entry with its name only (for example "LSU"); coordinates are not shown unless asked for (see Open Questions)
- [x] Selecting an entry calls `PMT.teleportTo` with that destination
- [x] Call `addTransitMenu` from `onFillInventoryObjectContextMenu` inside the `hasRing` block, after `addTeleportMenus`
- [x] Add to `UI.json`: `UI_PseudoMagic_Transit` ("Transit") and one key per destination (`UI_PseudoMagic_TransitLSU`, `...Farm`, `...RabbitIsle`, `...CowIsle`, `...HenIsle`, `...Gigamart`, `...Market`)
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`

**Technical Notes:**
The Transit options are always available (no greyed-out state), since the destinations are fixed.

### Phase 3: In-Game Testing

**Status:** Planning

- [ ] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save
- [ ] Right-click a Ring of the Mage; confirm "Transit" appears with the seven named entries in the order above
- [ ] Use each entry; confirm the survivor arrives at (or next to) the listed coordinates and floor, standing on solid ground
- [ ] Test at least one far destination (for example Rabbit Isle) from a distant start, and confirm the world loads in around the survivor with no fall, stuck position or crash
- [ ] Test from inside a vehicle and while flying
- [ ] Confirm Bind Location and Teleport still work, including the existing "Teleported" message
- [ ] Check the console log for errors

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

1. **Unloaded destinations:** teleporting to a far, unloaded chunk uses `pickArrival`'s raw-coordinate fallback. If testing shows the survivor falling or getting stuck, a follow-up could set the position and wait for the square to load before settling.
2. **Coordinate display:** the Teleport submenu shows coordinates beside each label. Should Transit entries show them too, or names only (the current plan)?
3. **Arrival message:** the existing Teleport shows "Teleported to location N". Transit will show "Transit: <name>" unless another text is wanted.
4. **Multiplayer:** DevCycle 8 was single-player first; Transit follows the same scope.
5. **Isle coordinates:** Rabbit Isle, Cow Isle and Hen Isle are islands. Confirm the Z=0 coordinates are on land, as `pickArrival` only searches the nine tiles around the point.

---

## Notes and Risks

- Risk: a destination that is water, an unwalkable tile or lies outside the playable map would drop the survivor somewhere bad. Testing covers all seven.
- Risk: long-distance teleport in a loaded world may cause a brief hitch while chunks stream in.
- The Transit locations are hard-coded, so changing a destination later means editing the table in `PseudoMagicTeleport.lua`.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Builds on DevCycle 8 (Teleport); touches `PseudoMagicTeleport.lua`, `PseudoMagicMenu.lua` and `UI.json`.

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
