# DevCycle 002: Experiment with PseudoSaltWell tiledef range

**Status:** Planning
**Start Date:** 2026-06-27
**Target Completion:** TBD
**Focus:** Test whether moving `PseudoSaltWell`'s custom tile definition range from `8724` to `2110` resolves the campfire build-cheat error seen with the mod's `common/media/` assets enabled.

---

## Goal

DevCycle 001 narrowed the remaining campfire build-cheat error to the mod's custom tile/texturepack registration path: `mod.info` declares `pack=pseudoed_salt_01` and `tiledef=pseudoed_salt_01 8724`, and the error disappears when the `common/media/` assets are removed. The current working hypothesis is that `8724` may be outside or too close to the documented practical custom tile-ID range.

This cycle will change the tiledef number to `2110`, as proposed in `doc/ideas/tile_notes.md`, then run a tight in-game verification pass to see whether the lower range avoids the error.

## Desired Outcome

`PseudoSaltWell42_19/PseudoSaltWell/42/mod.info` uses `tiledef=pseudoed_salt_01 2110`, the mod still loads its custom well tile, and the campfire build-cheat test no longer logs the `ItemContainer.new(...)` overload-resolution error. If the error persists, the cycle should leave a clear record that tiledef renumbering alone did not resolve the issue and identify the next narrowing step.

---

## Tasks

### Phase 1: Apply tiledef renumbering

**Status:** Planning

- [ ] Update `PseudoSaltWell/42/mod.info` from `tiledef=pseudoed_salt_01 8724` to `tiledef=pseudoed_salt_01 2110`.
- [ ] Confirm no other live mod file in this repo still declares `tiledef=pseudoed_salt_01 8724`.
- [ ] Record the change in this DevCycle's technical notes.

**Technical Notes:**
The change comes from `doc/ideas/tile_notes.md`, which cites custom tile definition numbers as valid from `100` up to about `8000`, with values under `100` reserved by the game. The original mod uses `8724`, which is above that documented upper neighborhood; `2110` is the proposed replacement value.

Key file:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/mod.info`

### Phase 2: Minimal tile/texturepack test

**Status:** Planning

- [ ] Restore or keep the minimal failing configuration from DevCycle 001: `mod.info`, `poster.png`, and `common/media/` assets present, with `42/media/lua/` and `42/media/scripts/` disabled or removed for the test.
- [ ] Enable only vanilla plus this minimal `PseudoSaltWell` setup where possible.
- [ ] Build a campfire with the build cheat and check whether the `ItemContainer.new("campfire", square, isoObject, 1, 1)` error still appears.
- [ ] Record the result here with the exact enabled-mod set and whether the well tile/texturepack loaded.

**Technical Notes:**
This test isolates the tiledef/texturepack path from all mod-authored Lua, scripts, recipes, translations, and item definitions. It answers whether changing the global tile-ID start from `8724` to `2110` is enough to fix the issue in the smallest previously failing setup.

### Phase 3: Full mod regression pass

**Status:** Planning

- [ ] Restore the full mod contents after the minimal test.
- [ ] Load `PseudoSaltWell` with the new `tiledef` value.
- [ ] Confirm no console errors on load.
- [ ] Re-run the core smoke path: dig a saltwater well at a known saltwater coordinate, dig a plain hole elsewhere, fill pot/kettle, empty container, cook saltwater, and extract salt.
- [ ] Re-run the campfire build-cheat test with the full mod enabled.

**Technical Notes:**
This phase checks that the lower tiledef number fixes the suspected collision without breaking the actual custom well sprite or any of the gameplay work completed in DevCycle 001. Per the planning process, these checks should remain **Work Complete** until the user explicitly approves **Verified**.

---

## Open Questions

1. **Is `2110` unused by all other enabled mods in the user's actual test profile?**
   Recommendation: use `2110` for this experiment because it is within the documented custom range and was explicitly selected in `doc/ideas/tile_notes.md`. If another enabled mod also claims that range, choose a different documented-range value in a follow-up cycle.

2. **Does changing `tiledef` require rebuilding `pseudoed_salt_01.tiles` or `pseudoed_salt_01.pack`?**
   Recommendation: first test the `mod.info` declaration change alone. If the custom well sprite fails to load or the campfire error persists, then investigate whether the binary `.tiles` export itself embeds assumptions that need to be regenerated.

---

## Notes and Risks

- The tile notes source says custom `NUMBER` values can be from `100` up to about `8000`, and the game reserves values under `100`.
- `8724` is above the documented upper neighborhood, so it is a credible suspect even if it worked in the earlier 42.11 setup.
- The `.tiles` file is binary and was previously confirmed byte-identical to the 42.11 mod copy, so this cycle intentionally starts with the smallest reversible change: the `tiledef` number in `mod.info`.
- A clean minimal test with `2110` would strongly support the tile-ID range hypothesis. A failing minimal test would point next at the `.tiles`/`.pack` assets themselves or at a different tile-registration issue.

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
