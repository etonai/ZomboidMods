# DevCycle 004: Add B42 depth metadata for custom ground tiles

**Status:** Verified
**Start Date:** 2026-06-29
**Target Completion:** 2026-06-29
**Focus:** Add valid B42 tile-depth metadata for the active `pseudoed_03` ground sprites so the custom saltwater well and plain-hole tiles load without depthmap parser errors.

---

## Goal

After switching the mod to the cleaned `pseudoed_salt_03` tile pack, in-game testing showed that the custom ground tiles still lacked B42 depth metadata. The active sprites, `pseudoed_03_32` for the plain hole and `pseudoed_03_35` for the saltwater well, are ground-level tiles rather than upright furniture, so they do not need custom 3D object depthmaps.

This cycle adds the minimum valid metadata needed for B42's tile-depth system to recognize the mod and assign both custom sprites to the vanilla flat floor depth preset.

## Desired Outcome

`PseudoSaltWell` loads its active custom ground sprites without `TileGeometryFile` or `TileDepthTextureAssignments` parser errors. Both active sprites use vanilla's floor depth texture behavior, matching their ground-level placement.

---

## Tasks

### Phase 1: Identify the missing depth metadata path

**Status:** Verified

- [x] Inspect the active `PseudoSaltWell42_19/PseudoSaltWell/common/media` folder.
- [x] Confirm `tileGeometry.txt` and `tileDepthTextureAssignments.txt` existed but were empty placeholders.
- [x] Compare against `notmymods/Erikas Tiles` as a reference for B42 custom tile assets and depthmap folders.
- [x] Confirm Erika's rug tiles do not use custom rug depthmaps, supporting the idea that flat ground tiles can use floor-style depth handling.

**Technical Notes:**
The active mod already had the two B42 metadata filenames in place:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/common/media/tileGeometry.txt`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/common/media/tileDepthTextureAssignments.txt`

Both files were zero bytes before this cycle, which made them invalid once the engine attempted to parse them.

### Phase 2: Trace B42 depth loader behavior

**Status:** Verified

- [x] Review `zombie42_19/tileDepth/TileDepthTextureManager.java`.
- [x] Review `zombie42_19/tileDepth/TileDepthTextureAssignmentManager.java`.
- [x] Review `zombie42_19/tileDepth/TileDepthTextureAssignments.java`.
- [x] Review `zombie42_19/tileDepth/TileGeometryFile.java`.
- [x] Confirm `tileGeometry.txt` presence causes the mod to participate in depth texture loading.
- [x] Confirm `tileDepthTextureAssignments.txt` maps one tile name to another tile's depth texture.
- [x] Identify vanilla preset `preset_depthmaps_01_0` as the floor depth preset through `TileDepthMapManager.TileDepthPreset.Floor`.

**Technical Notes:**
Key loader facts from the 42.19 Java code:

- `TileDepthTextureManager.init()` checks for `common/media/tileGeometry.txt` before initializing mod depth data.
- `TileDepthTextureAssignmentManager.init()` checks for `common/media/tileDepthTextureAssignments.txt`.
- Assignment files are parsed as `tileDepthTextureAssignments` script blocks with `VERSION = 1,`.
- Geometry files are parsed as `tileGeometry` script blocks with `VERSION = 2,`.
- Vanilla's floor depth preset is `preset_depthmaps_01_0`.

### Phase 3: Add minimal metadata files

**Status:** Verified

- [x] Populate `tileGeometry.txt` with a valid empty `tileGeometry` block.
- [x] Populate `tileDepthTextureAssignments.txt` with a valid assignment block.
- [x] Map `pseudoed_03_32` to `preset_depthmaps_01_0`.
- [x] Map `pseudoed_03_35` to `preset_depthmaps_01_0`.
- [x] Avoid adding a custom `DEPTH_pseudoed_03.png`, since the active sprites are flat ground tiles.

**Technical Notes:**
Final `tileGeometry.txt`:

```txt
tileGeometry
{
    VERSION = 2,
}
```

Final `tileDepthTextureAssignments.txt`:

```txt
tileDepthTextureAssignments
{
    VERSION = 1,
    pseudoed_03_32 = preset_depthmaps_01_0,
    pseudoed_03_35 = preset_depthmaps_01_0,
}
```

### Phase 4: Fix parser syntax and redeploy

**Status:** Verified

- [x] Read `docs/console.txt` after the first in-game test reported new errors.
- [x] Identify `TileGeometryFile.read` and `TileDepthTextureAssignments.read` errors reporting `missing VERSION`.
- [x] Confirm the deployed files were no longer empty, so the problem was not stale zero-byte metadata.
- [x] Compare against the vanilla files in the local Project Zomboid install.
- [x] Discover that vanilla script-parser files use trailing commas after values.
- [x] Add trailing commas to the metadata files.
- [x] Redeploy `PseudoSaltWell42_19` to `C:\Users\edwar\Zomboid\mods\PseudoSaltWell42_19`.
- [x] Verify the deployed `PseudoSaltWell42_19/PseudoSaltWell/common/media` copies contain the comma-correct syntax.

**Technical Notes:**
The first attempt used:

```txt
VERSION = 2
```

Vanilla uses:

```txt
VERSION = 2,
```

The missing comma caused the parser to fail in a way that surfaced as `missing VERSION in tileGeometry.txt`, even though the `VERSION` line was visibly present.

---

## Open Questions

1. ~~**Does the comma-correct metadata remove the depth parser errors in-game?**~~
   Resolved by Ed on 2026-06-29: DC 4 is confirmed complete.

2. ~~**Do the flat floor depth assignments produce correct visual behavior for the hole and well sprites?**~~
   Resolved by Ed on 2026-06-29: DC 4 is confirmed complete.

---

## Notes and Risks

- The active mod id is `PseudoSaltWell`, even when loaded from the `PseudoSaltWell42_19/PseudoSaltWell` folder, so console logs label the mod as `PseudoSaltWell`.
- A separate deployed folder named `C:\Users\edwar\Zomboid\mods\PseudoSaltWell` also exists, but Ed confirmed it is not the loaded test target for this cycle.
- The metadata files are intentionally minimal. They do not define custom geometry because the active sprites are ground-level tiles.
- If the floor preset assignment is visually insufficient, the next fallback is generating a custom `common/media/depthmaps/DEPTH_pseudoed_03.png` sheet with non-empty floor-depth pixels only for the active tile slots.

---

## Completion Summary

**Completion Date:** 2026-06-29
**Phases Completed:** All repo-side phases
**Work Deferred:** None.

**Accomplishments:**
- Added B42 depth metadata files for the active `pseudoed_03` ground sprites.
- Mapped both active hole/well sprites to vanilla's floor depth preset.
- Diagnosed the misleading `missing VERSION` parser error as missing trailing commas.
- Redeployed the corrected `PseudoSaltWell42_19` copy and verified the deployed files contain the corrected syntax.

**Metrics:**
- Files added: 2
- Active custom sprites assigned to floor depth: 2
- Console error class addressed: `TileGeometryFile.read` / `TileDepthTextureAssignments.read` parser failures

**Lessons / Notes:**
The B42 script parser format is comma-sensitive. For these generated metadata-style files, matching vanilla formatting exactly is safer than relying on minimal-looking key/value syntax.


