# DevCycle 003: Add planned saltwater well locations

**Status:** Work Complete
**Start Date:** 2026-06-28
**Target Completion:** 2026-06-28
**Focus:** Replace the temporary saltwater-location test coordinate with the real point and rectangle locations from `doc/ideas/well_locations.md`.

---

## Goal

`SaltwaterLocationDetector.lua` contained a temporary `saltwaterXCoordinates` rule where any tile with `X=8163` counted as a saltwater well location. That shortcut was useful for testing, but it was too broad for real gameplay.

This cycle removed that temporary X-coordinate rule and populated `SaltwaterLocationDetector.locations` with the real locations listed in `doc/ideas/well_locations.md`, while preserving support for both exact tile points and rectangular saltwater zones.

## Desired Outcome

The mod recognizes only the planned saltwater well locations from `well_locations.md` plus the two existing real locations already present in the detector. Digging at those coordinates creates a saltwater well; digging elsewhere creates a plain hole. The detector remains easy to extend with future point or rectangle entries.

---

## Tasks

### Phase 1: Normalize the well-location list

**Status:** Work Complete

- [x] Convert every exact coordinate in `doc/ideas/well_locations.md` into a `locations` entry with matching `x1/y1/x2/y2` values.
- [x] Convert each rectangle in `doc/ideas/well_locations.md` into a `locations` entry using its start and end coordinates.
- [x] Preserve place labels as comments where useful for future maintenance.
- [x] Check for typos, missing spaces, or ambiguous entries before editing code.
- [x] Keep the existing real locations `8165,12212` and `8175,12216` per Ed's note.

**Technical Notes:**
The detector supports both exact points and rectangles through this range check:

```lua
if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
    return true;
end
```

Exact points use the same structure by setting `x1 == x2` and `y1 == y2`.

### Phase 2: Update SaltwaterLocationDetector

**Status:** Work Complete

- [x] Remove `SaltwaterLocationDetector.saltwaterXCoordinates`.
- [x] Remove the loop that checks `saltwaterXCoordinates` in `isSaltwaterLocation`.
- [x] Replace the current test-only location data with the full list from `well_locations.md` plus the two existing real locations.
- [x] Keep `isSaltwaterLocation(x, y)` as the single public API used by digging and ghost-render logic.

**Technical Notes:**
Key file:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/SaltwaterLocationDetector.lua`

Current call sites:
- `ISLocationBasedHole:create(...)` decides whether to place `pseudoed_03_35` or `pseudoed_03_32`.
- `ISLocationBasedHole:render(...)` decides which ghost sprite to preview while dragging.

### Phase 3: Verification pass

**Status:** Work Complete

- [x] Code-review the updated detector to confirm no references to `saltwaterXCoordinates` remain.
- [x] Confirm every listed point and rectangle from `well_locations.md` appears in `SaltwaterLocationDetector.locations`.
- [x] Confirm representative detector behavior by static logic check:
  - `8165,12212` returns saltwater.
  - `10985,10248` returns saltwater.
  - `13910,7390` returns saltwater inside the Salt River rectangle.
  - `8163,1` no longer returns saltwater from the removed broad X rule.
  - `10986,10248` returns non-saltwater as a nearby negative case.
- [ ] In-game: test at least one exact point and one rectangle location to confirm saltwater wells are created.
- [ ] In-game: test a nearby non-listed coordinate to confirm it creates a plain hole.
- [ ] In-game: confirm no console errors when opening the dig menu or placing the hole/well.

**Technical Notes:**
Repo-side implementation and static verification are complete. In-game verification remains user-owned, so this phase and cycle stop at **Work Complete** rather than **Verified**.

---

## Implemented Location Inputs

Source: `mymods/PseudoSaltWell42_19/doc/ideas/well_locations.md`, plus the two existing real locations retained by user instruction.

Existing real points retained:

- `8165, 12212`
- `8175, 12216`

Exact points added from `well_locations.md`:

- `10985, 10248` - Muldraugh
- `10102, 8352` - McCoy Estate
- `10109, 8279` - McCoy Estate
- `13659, 7320` - Salt River
- `12921, 6908` - Bridge 2
- `12922, 6855` - Bridge 2
- `12880, 6910` - Bridge 2
- `12880, 6888` - Bridge 2
- `13177, 6858` - Bend
- `13881, 6701` - Camp
- `12798, 5872`
- `12788, 5786`
- `12989, 5274`
- `12874, 5006`
- `12303, 6711` - Bridge 1
- `12301, 6755` - Bridge 1
- `12239, 6751`
- `12474, 8955` - Campground
- `12746, 8776` - Lakehouse
- `10701, 9245` - Muldraugh
- `8490, 14447` - Resort
- `8757, 14237` - Resort
- `7825, 14600` - Resort
- `1983, 8609` - Private retreat
- `7378, 8335` - Fallas Lake
- `13225, 2601` - Louisville central park
- `14189, 2669` - Three mansions

Rectangles added from `well_locations.md`:

- `13901, 7387` to `13924, 7399` - Start of Salt River
- `13836, 7383` to `13857, 7386`

---

## Open Questions

1. ~~**Should the old test locations `8165,12212` and `8175,12216` remain?**~~
   Resolved by Ed: they are intentionally part of the real location list and were retained.

2. ~~**Should unnamed entries receive placeholder comments?**~~
   Resolved by Ed: keep coordinates without placeholder comments. Unnamed entries were left uncommented.

---

## Notes and Risks

- `saltwaterXCoordinates` was removed because `X=8163` made an entire vertical world line count as saltwater.
- The range-based `locations` structure is slightly verbose for exact points, but it supports both points and rectangles with one simple lookup path.
- Coordinate mistakes remain the main risk; in-game verification should include at least one exact point, one rectangle point, and one nearby negative case.

---

## Completion Summary

**Completion Date:** 2026-06-28
**Phases Completed:** All repo-side phases
**Work Deferred:** In-game verification of saltwater well placement and nearby plain-hole placement.

**Accomplishments:**
- Removed the temporary `saltwaterXCoordinates` detector path.
- Added 31 saltwater zones total: 29 exact points and 2 rectangles.
- Preserved the two existing real detector points by user instruction.
- Confirmed representative positive and negative detector behavior with a static logic check.

**Metrics:**
- Files modified: 2
- Saltwater detector entries: 31
- Broad X-coordinate rules removed: 1

**Lessons / Notes:**
The existing rectangle structure is a good fit for this data because it handles exact wells and river-zone ranges without a second lookup path.
