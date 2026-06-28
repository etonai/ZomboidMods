# DevCycle 003: Add planned saltwater well locations

**Status:** Planning
**Start Date:** 2026-06-28
**Target Completion:** TBD
**Focus:** Replace the temporary saltwater-location test coordinate with the real point and rectangle locations from `doc/ideas/well_locations.md`.

---

## Goal

`SaltwaterLocationDetector.lua` currently contains a temporary `saltwaterXCoordinates` rule where any tile with `X=8163` counts as a saltwater well location. That shortcut was useful for testing, but it is too broad for real gameplay.

This cycle will remove that temporary X-coordinate rule and populate `SaltwaterLocationDetector.locations` with the real locations listed in `doc/ideas/well_locations.md`, preserving support for both exact tile points and rectangular saltwater zones.

## Desired Outcome

The mod recognizes only the planned saltwater well locations from `well_locations.md`. Digging at those coordinates creates a saltwater well; digging elsewhere creates a plain hole. The detector remains easy to extend with future point or rectangle entries.

---

## Tasks

### Phase 1: Normalize the well-location list

**Status:** Planning

- [ ] Convert every exact coordinate in `doc/ideas/well_locations.md` into a `locations` entry with matching `x1/y1/x2/y2` values.
- [ ] Convert each rectangle in `doc/ideas/well_locations.md` into a `locations` entry using its start and end coordinates.
- [ ] Preserve place labels as comments where useful for future maintenance.
- [ ] Check for typos, missing spaces, or ambiguous entries before editing code.

**Technical Notes:**
The current detector already supports both exact points and rectangles through this range check:

```lua
if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
    return true;
end
```

Exact points can use the same structure by setting `x1 == x2` and `y1 == y2`.

### Phase 2: Update SaltwaterLocationDetector

**Status:** Planning

- [ ] Remove `SaltwaterLocationDetector.saltwaterXCoordinates`.
- [ ] Remove the loop that checks `saltwaterXCoordinates` in `isSaltwaterLocation`.
- [ ] Replace the current test entries in `SaltwaterLocationDetector.locations` with the full list from `well_locations.md`.
- [ ] Keep `isSaltwaterLocation(x, y)` as the single public API used by digging and ghost-render logic.

**Technical Notes:**
Key file:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/SaltwaterLocationDetector.lua`

Current call sites:
- `ISLocationBasedHole:create(...)` decides whether to place `pseudoed_03_35` or `pseudoed_03_32`.
- `ISLocationBasedHole:render(...)` decides which ghost sprite to preview while dragging.

### Phase 3: Verification pass

**Status:** Planning

- [ ] Code-review the updated detector to confirm no references to `saltwaterXCoordinates` remain.
- [ ] Confirm every listed point and rectangle from `well_locations.md` appears in `SaltwaterLocationDetector.locations`.
- [ ] In-game: test at least one exact point and one rectangle location to confirm saltwater wells are created.
- [ ] In-game: test a nearby non-listed coordinate to confirm it creates a plain hole.
- [ ] In-game: confirm no console errors when opening the dig menu or placing the hole/well.

**Technical Notes:**
In-game verification remains user-owned. This phase should stop at **Work Complete** unless the user explicitly approves **Verified**.

---

## Proposed Location Inputs

Source: `mymods/PseudoSaltWell42_19/doc/ideas/well_locations.md`

Exact point candidates:

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

Rectangle candidates:

- `13901, 7387` to `13924, 7399` - Start of Salt River
- `13836, 7383` to `13857, 7386`

---

## Open Questions

1. **Should the old test locations `8165,12212` and `8175,12216` remain?**
   Recommendation: remove them unless they are intentionally part of the real location list, because this cycle is specifically replacing test data with `well_locations.md`.
ED: They are INTENTIONALLY PART OF THE REAL LOCATION LIST. DO NOT REMOVE.

2. **Should unnamed entries receive placeholder comments?**
   Recommendation: keep the coordinates even if unnamed and use concise comments such as `-- unnamed river point` only if needed. Avoid inventing place names not present in the source notes.
Ed: keep coordinates without placeholder comments
---

## Notes and Risks

- Removing `saltwaterXCoordinates` is important because `X=8163` makes an entire vertical world line count as saltwater.
- The range-based `locations` structure is slightly verbose for exact points, but it supports both points and rectangles with one simple lookup path.
- Coordinate mistakes are the main risk; verification should include at least one exact point, one rectangle point, and one nearby negative case.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**
- Files modified:

**Lessons / Notes:**