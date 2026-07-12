# DevCycle 008: Saltwater Cook Time and Container Substitutes

**Status:** Complete
**Start Date:** 2026-07-11
**Target Completion:** 2026-07-12
**Completion Date:** 2026-07-12
**Focus:** Tune saltwater cooking times and add forged pot, copper kettle, and bucket variants for salt production.

---

## Goal

This cycle updates PseudoSaltWell42_19's saltwater container flow so small vessels share one balance profile and bucket-sized vessels use a larger, slower profile. Saltwater pots, kettles, and copper kettles should share the same cooking duration and salt yield; forged pots should work as a substitute for normal pots; and bucket-sized containers should support longer saltwater boiling with a larger salt yield.

The intended balance captured from the request is:

1. Saltwater pot cooks in 2 hours and yields 2 salts.
2. Saltwater kettle and saltwater copper kettle have the same cooking time and yield as the saltwater pot.
3. Forged pot can substitute for the normal saltwater pot with the same cooking time and yield.
4. Bucket and forged bucket can substitute for a saltwater pot, cook in 6 hours, and yield 7 salts.

## Desired Outcome

Players can use the existing saltwater workflow with normal pots, kettles, copper kettles, forged pots, buckets, and forged buckets. Each supported container returns the correct empty container after boiling/extracting salt, uses the intended cook time, and produces the intended salt yield.

---

## Tasks

### Phase 1: Adjust Small-Vessel Cook Times and Yield

**Status:** Work Complete

- [x] Update `SaltwaterPot` cooking duration to 2 hours.
- [x] Update `SaltwaterKettle` cooking duration to 2 hours.
- [x] Confirm pot and kettle salt extraction recipes both continue to yield `2x Base.Salt`.
- [x] Verify the implementation changes the cooking time on the saltwater item, not the later "Get Salt From..." extraction recipe time, unless testing shows the extraction recipe is the actual user-facing delay.

**Technical Notes:**
Current saltwater items live in `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt`.

- `SaltwaterPot` now has `MinutesToCook = 120` and `ReplaceOnCooked = PseudoSaltWellB42.SaltPot`.
- `SaltwaterKettle` now has `MinutesToCook = 120` and `ReplaceOnCooked = PseudoSaltWellB42.SaltKettle`.
- `MinutesToBurn` was raised for small vessels so they do not burn immediately after the longer cook time.

The prior DC7 recipe-time change affected `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/recipes/PseudoSaltWellRecipes.txt`, where `Get Salt From Pot` and `Get Salt From Kettle` remain `time = 60`. This cycle distinguishes oven/campfire cooking time from post-cook extraction recipe time.

### Phase 2: Add Forged Pot and Copper Kettle Support

**Status:** Verified

**Root Cause Update (2026-07-12):** The copper kettle (and forged pot, and bucket-family) menu detection was never actually broken in code. Ed had been deploying the mod to the local mods folder instead of the local Steam Workshop folder, so in-game testing was running stale/wrong code regardless of what was fixed in this repo. Once deployed to the correct location, copper kettle, forged pot, and bucket/forged bucket all work as implemented. Phases 4 and 5's static/runtime investigation work is retained for historical record, but the underlying `WellFillMenu.lua` logic they were investigating was correct all along.

- [x] Identify vanilla item ids for forged pot and any cooked/full forged-pot equivalents needed by B42.19.
- [x] Use `Base.Kettle_Copper` as the vanilla copper kettle id unless implementation review finds a different 42.19 item id.
- [x] Add a saltwater forged pot item or mapper path that can be produced from a forged pot.
- [x] Add saltwater copper kettle support that matches normal kettle behavior.
- [x] Ensure cooked saltwater forged pot converts to a salt-containing forged pot state.
- [x] Ensure cooked saltwater copper kettle converts to a salt-containing copper kettle state.
- [x] Add a salt extraction recipe for the forged pot output that yields the same amount as normal pot and returns `Base.PotForged`.
- [x] Add a salt extraction recipe for the copper kettle output that yields the same amount as normal kettle and returns `Base.Kettle_Copper`.
- [x] Update fill/empty context-menu or timed-action logic if it currently only recognizes `Base.Pot` or `Base.Kettle`.

**Technical Notes:**
Vanilla references found in generated scripts include `Base.PotForged`, `Base.Kettle_Copper`, and the reused model ids `CookingPotForged_Fluid`, `CookingPotForgedGround_Fluid`, `CookingPotForged`, `CookingPotForgedGround`, and `Kettle_Copper`.

Existing fill actions reviewed and updated:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/client/WellFillMenu.lua`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillPotFromWell.lua`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillKettleFromWell.lua`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/client/EmptySaltwaterMenu.lua`

### Phase 3: Add Bucket and Forged Bucket Support

**Status:** Verified

- [x] Identify vanilla item ids for bucket and forged bucket variants in B42.19.
- [x] Add saltwater bucket and saltwater forged bucket items, or an equivalent mapper-based implementation, with 6-hour cooking time.
- [x] Add cooked salt bucket states for bucket and forged bucket outputs.
- [x] Add salt extraction recipes for bucket outputs that yield `7x Base.Salt`.
- [x] Ensure bucket extraction returns the appropriate bucket or forged bucket.
- [x] Add fill/empty context-menu or timed-action code paths for bucket support.
- [x] Verify bucket capacity/yield balance and in-game menu behavior. Root cause of prior failed verification was a deployment mistake (local mods folder instead of Steam Workshop folder), not the code — see Phase 2 root cause note.

**Technical Notes:**
The implementation uses a parallel saltwater container family because bucket output yield and returned container differ from pot/kettle behavior.

Vanilla B42.19 ids confirmed in `media/scripts/generated/items/normal.txt`:

- `Base.Bucket`
- `Base.BucketForged`

Bucket saltwater items use `MinutesToCook = 360`, `MinutesToBurn = 480`, and extraction recipes yield `7x Base.Salt`.

### Phase 4: Fix Copper Kettle Fill Menu Detection

**Status:** Failed (see root cause below — kept for historical record)

**Important Correction:** The previous copper kettle work in this DevCycle was incomplete. Although Phase 2 added `SaltwaterKettleCopper`, `SaltKettleCopper`, recipes, and menu mappings, in-game testing shows that a player with a copper kettle still does not receive the `Fill Kettle with Saltwater` menu option. This phase is dedicated specifically to making copper kettle detection and menu enablement work before returning to forged pot or bucket behavior.

- [x] Continue static/code review of the copper kettle path before adding runtime logging or debug prints.
- [x] Compare the copper kettle code path against the working regular kettle path, including menu mapping, item definitions, and produced saltwater item ids.
- [x] Adjust `WellFillMenu.lua` so a valid empty copper kettle is added to `containers.kettle`.
- [ ] Verify in-game that the `Fill Kettle with Saltwater` menu appears when the player carries an empty copper kettle and right-clicks a saltwater well.
- [ ] Verify in-game that selecting the copper kettle queues `ISFillKettleFromWell` with the intended copper-kettle saltwater result.
- [ ] Keep this phase focused on copper kettle only; forged pot and bucket fixes should wait until copper kettle behavior is understood. Phase 3 is not complete and likely suffers from the same detection problem, but the current investigation is intentionally narrowed.

**Technical Notes:**
Static analysis in `mymods/PseudoSaltWell42_19/doc/ideas/codex_vanillaKettleFillMenuAnalysis.md` found that vanilla `Base.Kettle_Copper` should be kettle-like: it has `PourType = Kettle` and a `FluidContainer` in `media/scripts/generated/items/normal.txt`. Phase 4 avoided runtime logging and replaced the broad generalized inventory predicate with direct `getAllTypeRecurse(...)` lookups for each supported type, including both `Base.Kettle_Copper` and `Kettle_Copper`. This mirrors the known-working regular kettle path more closely and avoids calling behavior getters across every carried item.

**Outcome: Failed.** A second independent static review (`mymods/PseudoSaltWell42_19/doc/ideas/claude_vanillaKettleFillMenuAnalysis.md`) traced `getAllTypeRecurse`/`compareType` into the decompiled `zombie42_19/inventory/ItemContainer.java` and confirmed the current `fillableTypes` matching logic is structurally correct against vanilla `Base.Kettle_Copper`. Two static-only passes (Codex's and Claude's) have both failed to explain why the copper kettle still doesn't appear in-game. The bug was not found by code review; it requires a runtime data point. Phase 4 is closed as failed rather than left open, since further static analysis without runtime logging is not expected to be productive. Follow-up is tracked in Phase 5.

**Actual Root Cause (found 2026-07-12, outside this phase's process):** The static analysis was correct — the code was never broken. Ed had been deploying the mod build to the local Zomboid mods folder instead of the local Steam Workshop folder, so every in-game test in Phases 2-5 was exercising stale code, not the current `WellFillMenu.lua`. Once deployed to the correct workshop location, copper kettle, forged pot, and bucket/forged bucket fill-menu detection all work correctly with no code changes beyond what Phase 2/3 already implemented. This is a useful lesson: when static analysis strongly disagrees with an observed in-game symptom, verify the deployment path before spending further engineering effort on the code itself.

---

### Phase 5: Claude Attempt at Copper Kettle Fill Menu Detection

**Status:** Superseded — root cause was deployment, not code (see Phase 4 root cause note)

Phase 4 (Codex) closed as failed after two independent static-only reviews could not explain the symptom from code alone. This phase authorized Claude to add temporary runtime diagnostics (not permitted in Phase 4) to find the actual root cause. The diagnostic print was added and then removed at Ed's request (2026-07-12) before an in-game test collected any data. Before Phase 5's runtime testing resumed, Ed identified the actual root cause independently: the mod was being deployed to the local mods folder instead of the local Steam Workshop folder, so no version of the code under investigation in Phases 2-5 had actually been running in-game. With correct deployment, copper kettle, forged pot, and bucket/forged bucket detection all work with the code as it stood at the end of Phase 3. No further runtime diagnostic work is needed; remaining Phase 5 checklist items are not applicable and are left unchecked for the historical record rather than retroactively marked done.

**Technical Notes:**
See `mymods/PseudoSaltWell42_19/doc/ideas/claude_vanillaKettleFillMenuAnalysis.md` for the full static analysis. The `PourType`-based group classification suggested there as a durability improvement was not needed to fix this bug (deployment was the cause), but remains a reasonable future hardening idea independent of this DevCycle.

---

### Phase 6: Post-Verification Balance Adjustments

**Status:** Work Complete

Now that all six saltwater container variants are confirmed working in-game (Phases 2 and 3 verified after the deployment fix), this phase makes two balance adjustments Ed requested:

1. **`MinutesToBurn` standardized to 480 across all saltwater (cookable) items.** Previously pot/kettle/copper kettle/forged pot used `MinutesToBurn = 240` (set in Phase 1/2 alongside the 120-minute cook time) while bucket/forged bucket already used 480. All six are now 480, regardless of cook time.
2. **Bucket-family `MinutesToCook` reduced from 360 to 240.** Applies to `SaltwaterBucket` and `SaltwaterBucketForged`.

- [x] Set `MinutesToBurn = 480` on `SaltwaterPot`.
- [x] Set `MinutesToBurn = 480` on `SaltwaterPotForged`.
- [x] Set `MinutesToBurn = 480` on `SaltwaterKettle`.
- [x] Set `MinutesToBurn = 480` on `SaltwaterKettleCopper`.
- [x] Confirm `SaltwaterBucket` `MinutesToBurn` is already 480 (no change needed).
- [x] Confirm `SaltwaterBucketForged` `MinutesToBurn` is already 480 (no change needed).
- [x] Reduce `SaltwaterBucket` `MinutesToCook` from 360 to 240.
- [x] Reduce `SaltwaterBucketForged` `MinutesToCook` from 360 to 240.

**Technical Notes:**
All changes are in `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt`. Post-change cook/burn pairs:

| Item | MinutesToCook | MinutesToBurn |
|---|---|---|
| `SaltwaterPot` | 120 | 480 |
| `SaltwaterPotForged` | 120 | 480 |
| `SaltwaterKettle` | 120 | 480 |
| `SaltwaterKettleCopper` | 120 | 480 |
| `SaltwaterBucket` | 240 (was 360) | 480 |
| `SaltwaterBucketForged` | 240 (was 360) | 480 |

`MinutesToBurn` is now a flat 480 across every saltwater item regardless of group, per Ed's explicit request, rather than scaled relative to each group's cook time as it was previously. No recipe-time (`PseudoSaltWellRecipes.txt`) or yield changes were made in this phase.

---

## Decisions

1. **"2 hours / 6 hours" was implemented as `MinutesToCook = 120 / 360`.**
   This keeps the requested delay on the cookable saltwater item that turns into a salt-containing container on heat.

2. **Extraction recipe time stays at `time = 60`.**
   The requested change was to the time it takes to cook the saltwater containers, so post-cook salt extraction remains unchanged.

3. **Bucket support does not create a separate `SaltBucketEmpty` path.**
   `Base.BucketEmpty` is accepted as a plain bucket input and produces the normal bucket saltwater/salt states. `Get Salt From Empty Bucket` was intentionally removed because it does not read correctly as a player-facing recipe.

4. **`MinutesToBurn` was increased alongside the longer cook times.**
   This prevents the new 2-hour and 6-hour cook targets from being undermined by burn timing that was balanced around the prior 20-minute cook time.

---

## Notes and Risks

- `DevCycle007.md` is still open for minor recipe tuning and model work. This cycle intentionally scopes the larger container-expansion work separately.
- Model/icon support for new saltwater bucket states reuses existing vanilla bucket visuals. Custom assets can be added in a later cycle if desired.
- Copper kettle, forged pot, and bucket/forged bucket fill-menu detection are all confirmed working in-game as of the deployment fix noted in Phase 4/5. The prior "menu availability incomplete" risk entries are resolved and removed.

---

## Completion Summary

**Completion Date:** 2026-07-12
**Phases Completed:** All (Phase 1 through Phase 6). Phase 4 is closed as Failed and Phase 5 as Superseded for historical accuracy, but the functionality both were chasing is confirmed working — see root cause note below.
**Work Deferred:** None.

**Accomplishments:**

- Retuned pot and kettle saltwater cooking to 2 hours with 2-salt extraction yield.
- Added forged pot and copper kettle saltwater/cooked-salt states, emptying support, and extraction recipes.
- Added bucket and forged bucket saltwater/cooked-salt states with 7-salt extraction yield. `Base.BucketEmpty` maps into the normal bucket path rather than a separate recipe.
- Generalized fill timed actions to accept the produced saltwater item type and remove the source container from its actual inventory container.
- Expanded world context menus and inventory-emptying support to cover every new saltwater and cooked-salt state, including copper kettle and both bucket variants.
- Confirmed in-game (Phases 2/3 Verified) that copper kettle, forged pot, bucket, and forged bucket all correctly show their fill-menu options and produce the right saltwater/salt/return-container items.
- Standardized `MinutesToBurn` to 480 across all six saltwater items and reduced bucket-family `MinutesToCook` from 360 to 240 (Phase 6).

**Root Cause Note (Phase 4/5 investigation):** Extensive static analysis (Codex and Claude, independently) and a runtime-diagnostic attempt found no bug in `WellFillMenu.lua` because there wasn't one — the mod was being deployed to the local mods folder instead of the local Steam Workshop folder, so in-game testing throughout Phases 2-5 never actually ran the code under review. Once deployed correctly, all container variants worked with the code as it stood at the end of Phase 3. Lesson retained for future cycles: verify deployment path before extended code-level debugging when static analysis strongly disagrees with an observed symptom.

**Metrics:**
- Files modified: 9 (adds `PseudoSaltWellItems.txt` changes from Phase 6 to the Phase 1-5 total).

**Validation:**

- `python -m json.tool` passed for `ContextMenu.json`.
- Confirmed B42.19 vanilla item ids with `rg` in `media/scripts/generated/items/normal.txt`.
- Confirmed reused vanilla model ids with `rg` in `media/scripts/generated/models_items.txt`.
- Confirmed expected mod ids, cook times, and `item 7 Base.Salt` outputs for bucket and forged bucket recipes with `rg` across the mod media folder.
- In-game verification: pot, forged pot, kettle, copper kettle, bucket, and forged bucket all confirmed fillable from the saltwater well and correctly convert/extract salt.
- Lua bytecode validation was not run because `lua`/`luac` are not available in this environment.

**Lessons / Notes:**

- The fill actions were narrow but easy to generalize by passing the target saltwater item type from the menu mapping.
- Bucket behavior needed separate item states and recipes instead of sharing pot behavior because the cook time, yield, and return containers differ.
- When in-game behavior contradicts a thorough static review, check the deployment path (mods folder vs. Steam Workshop folder) before continuing to debug the code.
