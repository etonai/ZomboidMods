# DevCycle 002: Switch PseudoSaltWell to cleaned pseudoed_salt_03 tiles

**Status:** Work Complete
**Start Date:** 2026-06-27
**Target Completion:** 2026-06-28
**Focus:** Move the mod away from the risky `pseudoed_salt_01` tile/texturepack path and onto the cleaned `pseudoed_salt_03` assets with a lower tiledef number.

---

## Goal

DevCycle 001 narrowed the remaining campfire build-cheat error to the mod's custom tile/texturepack registration path. The original working hypothesis was that `tiledef=pseudoed_salt_01 8724` might be outside the practical custom tile-ID range documented in `doc/ideas/tile_notes.md`.

During this cycle, the experiment evolved from simply renumbering `pseudoed_salt_01` to using the newly exported `pseudoed_salt_03` asset pair. The new `.tiles` file is small, parseable, and limited to the mod's own `pseudoed_03` tileset rather than carrying the broad copied vanilla tile-property data seen in `pseudoed_salt_01.tiles`.

## Desired Outcome

`PseudoSaltWell` loads the `pseudoed_salt_03` pack/tiledef pair, uses a lower custom tiledef number, and points digging code at the intended `pseudoed_03` sprites for both saltwater wells and plain holes.

---

## Tasks

### Phase 1: Apply tiledef and asset-path change

**Status:** Work Complete

- [x] Change `PseudoSaltWell/42/mod.info` from `pack=pseudoed_salt_01` / `tiledef=pseudoed_salt_01 8724` to `pack=pseudoed_salt_03` / `tiledef=pseudoed_salt_03 1000`.
- [x] Confirm `common/media/pseudoed_salt_03.tiles` exists.
- [x] Confirm `common/media/texturepacks/pseudoed_salt_03.pack` exists and is non-empty.
- [x] Confirm the old `pseudoed_salt_01` pack path is no longer the active path in `mod.info`.

**Technical Notes:**
`tiledef=pseudoed_salt_03 1000` keeps the mod in the documented custom range while also avoiding the old `8724` value. This cycle no longer uses the originally proposed `2110` number because the active test path became the cleaned `03` export rather than another `01` offset.

Key file:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/mod.info`

### Phase 2: Wire digging sprites to the pseudoed_03 pack

**Status:** Work Complete

- [x] Set the saltwater well sprite to `pseudoed_03_35`.
- [x] Set the plain hole sprite to `pseudoed_03_32`.
- [x] Set the initial digging cursor sprite to `pseudoed_03_32`.
- [x] Set the ghost preview render logic to switch between `pseudoed_03_35` and `pseudoed_03_32`.

**Technical Notes:**
The live code now uses the intended two custom sprites from the active pack:

- Saltwater well: `pseudoed_03_35`
- Plain hole: `pseudoed_03_32`

Key files:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/client/LocationBasedHoleMenu.lua`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/server/BuildingObjects/ISLocationBasedHole.lua`

### Phase 3: Inspect pseudoed_salt_03 tile properties

**Status:** Work Complete

- [x] Parse `pseudoed_salt_03.tiles` enough to identify its tileset, image, grid size, and tile count.
- [x] Confirm the file describes `pseudoed_03` / `pseudoed_03.png` with a `16 x 20` grid and `320` tile slots.
- [x] Confirm `pseudoed_03_32` and `pseudoed_03_35` both have `attachedFloor` and `exterior` properties.
- [x] Confirm the cleaned `03` tiles file does not contain the risky `container`, `campfire`, `water`, or `solid` property strings seen in the old `01` investigation.

**Technical Notes:**
The parsed properties for the two active digging sprites are:

- `pseudoed_03_32`: `attachedFloor`, `exterior`
- `pseudoed_03_35`: `attachedFloor`, `exterior`

This supports the idea that the `03` export is safer than the old `01` export, which included broad copied vanilla tile-property data.

---

## Open Questions

1. **Does the `pseudoed_salt_03` path fully resolve the in-game campfire build-cheat error?**
   Recommendation: test in-game with the full mod enabled. Do not mark this cycle `Verified` until the user confirms the result.

2. **Should the old `pseudoed_salt_01` files remain in the mod folder?**
   Recommendation: leave them for now while testing, since they are inactive when `mod.info` points to `pseudoed_salt_03`. Remove or archive them in a later cleanup cycle once the `03` path is confirmed.

---

## Notes and Risks

- The active asset path is now `pseudoed_salt_03`, not `pseudoed_salt_01`.
- The active tiledef number is now `1000`, not `8724` or the initially proposed `2110`.
- The cleaned `pseudoed_salt_03.tiles` file is much smaller and cleaner than `pseudoed_salt_01.tiles`.
- `Work Complete` here means the repo-side changes and documentation are complete. Per the planning process, only the user can approve `Verified` after in-game testing.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** All
**Work Deferred:** In-game verification and any cleanup/removal of inactive old `pseudoed_salt_01` assets.

**Accomplishments:**
- Switched `mod.info` to `pack=pseudoed_salt_03` and `tiledef=pseudoed_salt_03 1000`.
- Wired saltwater well digging to `pseudoed_03_35` and plain-hole digging to `pseudoed_03_32`.
- Confirmed both active sprites are present in the `03` pack and have clean tile properties in `pseudoed_salt_03.tiles`.

**Metrics:**
- Files modified: 3 live mod files plus this DevCycle document.
- Active tiledef lowered from `8724` to `1000`.

**Lessons / Notes:**
The likely fix is not just changing one number on the old `01` export. The safer path is using the cleaned `03` tile/texturepack export, because it avoids the broad vanilla tile-property data that made `pseudoed_salt_01.tiles` suspicious.