# DevCycle 006: User-led well location map update

**Status:** Planning
**Start Date:** 2026-07-03
**Target Completion:** TBD
**Focus:** Track Ed's user-led update to one planned well location and the addition of a Project Zomboid online-map link for building/checking locations.

---

## Goal

Ed has updated one of the planned PseudoSaltWell42_19 map locations and added a link intended to help build or verify well locations on the Project Zomboid online map. This DevCycle exists as a planning record for that user-led location-maintenance work.

There is no planned AI-agent implementation work in this cycle. Codex should not modify `SaltwaterLocationDetector.lua`, `well_locations.md`, map coordinates, assets, or release files unless Ed explicitly asks for a separate task.

## Desired Outcome

The location notes remain the source of truth for the updated well-location planning data, including the online-map reference. Any future code update should be based on Ed's finalized location list, not inferred by the AI agent.

---

## Tasks

### Phase 1: User-led map/location update

**Status:** Planning

- [ ] Ed updates the affected well location in the project notes or map-planning source.
- [ ] Ed maintains the Project Zomboid online-map link used for building/checking locations.
- [ ] Ed decides whether the changed location should later be propagated into `SaltwaterLocationDetector.lua`.

**Technical Notes:**
Primary planning file:
- `mymods/PseudoSaltWell42_19/doc/ideas/well_locations.md`

Current implementation file, if a future cycle updates code:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/SaltwaterLocationDetector.lua`

No Codex edits are planned for this phase.

### Phase 2: Future implementation decision

**Status:** Planning

- [ ] If Ed requests it later, create a separate implementation task or DevCycle to sync finalized location changes into `SaltwaterLocationDetector.lua`.
- [ ] If no code sync is needed, close this cycle as a user-led planning update.

**Technical Notes:**
This cycle intentionally avoids code changes. The prior location implementation work is recorded in `doc/planning/completed/DevCycle003.md`.

---

## Open Questions

1. **Should the changed map location be synced into code now or later?**
   Recommendation: no AI action during this cycle. Wait for Ed to explicitly request code sync after the location list is final.

---

## Notes and Risks

- This is a user-owned planning cycle, not an AI implementation cycle.
- The online-map link is useful context for future coordinate work, but Codex should not infer or rewrite coordinates from it without explicit instruction.
- Location mistakes are easy to introduce, so any future implementation cycle should compare notes, code, and in-game behavior carefully.

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
