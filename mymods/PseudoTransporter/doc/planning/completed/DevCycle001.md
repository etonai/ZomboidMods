# DevCycle 001: Minimal Working Transporter

**Status:** Verified (by Ed, 2026-11-06)
**Start Date:** 2026-11-05
**Target Completion:** TBD
**Focus:** Deliver a single-player, debug-spawned pair of linked objects (Transporter Control and Transporter Signal Booster) that teleport the player to each other.

**Source design:** `doc/ideas/PseudonymousEdTransporter_DesignDocument.md` (Ed's answers in §10 are the requirements for this cycle)
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

Build the smallest version of the PseudoTransporter mod that proves the core mechanic: two world objects, one pair, each with a "Transport" context-menu option that moves the player to the other object. The cycle also settles the technical unknowns listed in the design document (§9), because they decide how the later features (recipes, multiplayer, effects) will be built.

## Desired Outcome

In a single-player game, a tester spawns a Transporter Control and a Transporter Signal Booster with the debug tools, places them anywhere, and:

- right-clicking either one offers "Transport";
- choosing it (with the Control powered) puts the player next to the other object, along with the player's inventory;
- ordinary road cones and Ham Radio 2s never offer "Transport";
- the pair still works after saving and reloading.

## Scope (from Ed's answers)

| Topic | Decision for this cycle |
|---|---|
| Identifying our objects | New items that reuse the vanilla sprites (Option A) |
| Pairing | Exactly one Control and one Booster, one pair only |
| Direction | Symmetrical: the Control teleports to the Booster and the Booster teleports to the Control |
| Power | The Control needs power; the Booster does not |
| Limits and safeguards | None (no range, cooldown, zombie checks, vehicle checks, or push-back) |
| Acquisition | Debug spawn only (no recipes or loot) |
| Passengers | Player character and inventory only |
| Arrival | Next to the destination object (design document §4) |
| Missing or unloaded other end | Nothing happens |
| Multiplayer | Not supported |
| Sound and visuals | None |

**Out of scope:** recipes, world loot, translations beyond the minimum, multiplayer, effects, balance.

---

## Tasks

### Phase 1: Research the unknowns

**Status:** Verified

- [ ] Find out how a placed `HamRadio2` (a radio device object) and a placed `Mov_RoadCone` (a moveable) carry item data through placement and pick-up (design doc §9 items 3–4).
- [ ] Find out whether a new item can reuse `appliances_com_01_8` and `street_decoration_01_26` as its `WorldObjectSprite` without breaking the vanilla items that use them (§9 item 5).
- [ ] Find out how to tell that a placed Control "has power" from Lua (battery, generator or grid; the radio's own power state versus `square:haveElectricity()`).
- [ ] Decide how a placed world object can be identified as ours after save and load (item type, sprite plus marker, or modData).
- [ ] Find out how to read the other end's position when its chunk is not loaded (design doc §9 item 2) and how to handle "nothing happens".
- [ ] Record each finding in the Technical Notes below.

**Technical Notes:**
**Findings (v42.20.4, code-read only, not yet confirmed in game):**
- Placing a moveable copies the item's modData onto the placed object (`ISMoveableSpriteProps.lua:2273-2282`). Radios and cones both go through `placeMoveableInternal`.
- Pick-up does **not** return our item: `pickUpMoveableInternal` calls `instanceItem`, which builds `Moveables.<sprite>` (a vanilla item), and only copies `movableData`, container names and condition (`:206-234`, `:1274-1313`). So the item type is lost on pick-up.
- Consequence: identity is a **modData marker** (`PseudoTransporterRole`) on the placed object, set from the item type at placement and re-applied to the picked-up item by a wrapper around `instanceItem` during pick-up. This is Option A for acquisition (new items) plus Option B for identity.
- Sprite reuse: `WorldObjectSprite` on a new item does not alter vanilla items' own sprite mapping (only generators have a sprite->item map, `IsoGenerator.java:139`). Not confirmed in game.
- Power: `DeviceData.getIsTurnedOn()`; the engine turns a device off when it is battery-powered with no charge, or unpowered on a square without power (`DeviceData.java:476-498, 517-538`). "Powered" = switched on.
- Unloaded chunk: `getGridSquare` returns nil, so the registry coordinates are the source of truth. Stale entries are only cleared when the destination square is loaded and the marked object is gone.
- Known risk: `findInInventory` picks an item by sprite, so carrying a vanilla cone and a Booster could place the wrong one (the Booster item is then not marked).
*Reference points:* item scripts `media42_20_4/scripts/generated/items/radio.txt` (`HamRadio2`) and `moveable.txt` (`Mov_RoadCone`); `lua/shared/Moveables/ISMoveableSpriteProps.lua`; context-menu hooks such as `ISFeedingTroughMenu`.

### Phase 2: Items and debug spawn

**Status:** Verified

- [ ] Add item scripts for `TransporterControl` and `TransporterSignalBooster` that reuse the Ham Radio 2 and Road Cone sprites (per Phase 1 findings).
- [ ] Give both items display names and minimal tooltips.
- [ ] Confirm both can be spawned with the debug item list and placed in the world.
- [ ] Update `mod.info` (description, and poster if a placeholder is not acceptable) as needed.

**Technical Notes:** Items in `media/scripts/items/PseudoTransporter_Items.txt` (module `PseudoTransporter`). Control is a copy of `HamRadio2`; Booster a copy of `Mov_RoadCone`. Names/UI text in `Translate/EN`. Not yet confirmed that they appear in the debug item list.

### Phase 3: Pair registry

**Status:** Verified

- [ ] Create a registry stored in global ModData that holds the Control's and the Booster's location (x, y, z).
- [ ] Update the registry when either object is placed.
- [ ] Update the registry when either object is picked up or moved.
- [ ] Clear a stale entry when its object no longer exists.
- [ ] Confirm the registry survives save and load.

**Technical Notes:** `shared/PseudoTransporter/PseudoTransporter.lua`: global ModData `PseudoTransporter` = `{control={x,y,z}, booster={x,y,z}}`, updated by wrappers on `placeMoveableInternal` / `pickUpMoveableInternal`. Debug `print`s are on (`PT.DEBUG`). The registry coordinates are the source of truth for the other end's location (design doc §9 item 2).

### Phase 4: "Transport" menu option and teleport

**Status:** Verified

- [ ] Hook `Events.OnFillWorldObjectContextMenu` and add "Transport" only on the two transporter objects.
- [ ] Add a teleport action that moves the player next to the other object, using the `setX/Y/Z` plus `setLastX/Y/Z` pattern from `claude_RVLifeLessons.md` §3.3.
- [ ] Choose and implement the arrival square offset (a walkable square adjacent to the destination object).
- [ ] If the other end is missing, do nothing.
- [ ] Add the minimum text needed (menu label) in English.

**Technical Notes:** `client/PseudoTransporter/PseudoTransporterMenu.lua`. Immediate teleport (no timed action); arrival = destination square if free, else the first free neighbour, else raw coordinates. Per Ed, missing/unregistered other end does nothing. The design document's open risk is teleporting to a chunk that is not loaded (§9 item 1). Record what actually happens in testing.

### Phase 5: Power requirement on the Control

**Status:** Verified

- [x] Make "Transport" on the Control require power, based on the Phase 1 findings.
- [ ] Make "Transport" on the Booster work without power.
- [ ] Decide what the player sees when the Control is unpowered (see Open Question 1).

**Technical Notes:** Unpowered Control shows "Transport" greyed out with a tooltip (my recommendation for Open Question 1, pending Ed's confirmation). Booster never checks power.

### Phase 6: In-game testing

**Status:** Verified

- [ ] Place a pair, then use "Transport" from each end. Confirm arrival next to the other object, both ways.
- [ ] Confirm that inventory items go with the player.
- [ ] Confirm that vanilla road cones and Ham Radio 2s do **not** show "Transport".
- [ ] Pick up one end, place it elsewhere, and confirm "Transport" uses the new location.
- [ ] Save, quit, reload, and confirm the pair still works.
- [ ] Transport over a long distance to an unloaded area and record load time, falling, or stalls.
- [ ] Try an unpowered Control, and a pair with one end missing.
- [ ] Record the results in the Completion Summary.

**Technical Notes:**
*To be filled in during the phase.* Per `AGENTS.md` and `DevelopmentProcess.md`, work stops at **Work Complete**; only Ed can mark a phase or the cycle **Verified**.

---

## Open Questions

1. **What should the player see when the Control is unpowered?**
   Recommendation: show "Transport" greyed out with a tooltip stating that the Control needs power. The "nothing happens" answer in the design document covers the missing-end case, not the unpowered case, so this needs your confirmation.

2. **What counts as "powered" for the Control?**
   Recommendation: treat it the way the vanilla Ham Radio 2 does: it is on and has a working battery or a generator-powered or grid-powered square. Phase 1 will report what the code actually allows, and I will bring any difference back to you.

3. **Should the Control keep its normal radio functions (channel, sound, voice)?**
   Recommendation: keep them for this cycle, because removing them is extra work with no value to the core mechanic.

4. **If the Control or Booster is destroyed or picked up, should the other end keep its "Transport" option?**
   Recommendation: keep showing it, but do nothing when chosen (the same as the missing-end rule).

---

## Notes and Risks

- **Unloaded destination chunks** are the largest unknown (design doc §9 item 1). If a plain `setX/Y/Z` does not work for far-away destinations, the cycle may need a second approach, which could extend it.
- **Sprite reuse** (design doc §9 item 5): if reusing the vanilla sprites turns out to confuse the item lookup, Option B (a modData marker on vanilla items) is the fallback, and Phase 2 would change.
- **Single player only.** RV Life moves the player from client-side Lua. This cycle does not verify that approach on a dedicated server.
- **No safeguards** by design: the mod may teleport the player while in a vehicle or mid-action. This is a conscious decision by Ed, not an oversight.
- This document is a plan only. No implementation begins until Ed explicitly asks for it.

---

## Completion Summary

Ed tested the mod in game on 2026-11-06 and reported that it works; he asked for the cycle to be marked Verified. Per-item Phase 6 results (long-distance/unloaded-area behavior, save/reload, unpowered Control) were not recorded, so they are not claimed here.

Notes for later cycles:
- The first test run crashed in the `placeMoveableInternal` hook because the installed game's Lua differs from the 42.20.4 copy in the repo (argument order). The hooks now find the square, item and object by type. The installed build's `ISMoveableSpriteProps.lua` is not in the repo.
- Identity is a modData marker (`PseudoTransporterRole`) on the placed object, not the item type, because pick-up rebuilds a vanilla item.
- Debug `print`s (`PT.DEBUG = true` in `PseudoTransporter.lua`) are still on.
- Open Questions 1-4 were handled with the recommendations (greyed-out Transport with a tooltip when the Control is unpowered; radio functions kept).
