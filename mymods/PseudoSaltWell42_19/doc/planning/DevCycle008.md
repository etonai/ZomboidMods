# DevCycle 008: Saltwater Cook Time and Container Substitutes

**Status:** In Progress
**Start Date:** 2026-07-11
**Target Completion:** 2026-07-12
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

**Status:** In Progress

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

**Status:** In Progress

- [x] Identify vanilla item ids for bucket and forged bucket variants in B42.19.
- [x] Add saltwater bucket and saltwater forged bucket items, or an equivalent mapper-based implementation, with 6-hour cooking time.
- [x] Add cooked salt bucket states for bucket and forged bucket outputs.
- [x] Add salt extraction recipes for bucket outputs that yield `7x Base.Salt`.
- [x] Ensure bucket extraction returns the appropriate bucket or forged bucket.
- [x] Add fill/empty context-menu or timed-action code paths for bucket support. In-game menu detection is not yet verified and appears to suffer from the same problem as Phase 2.
- [ ] Verify bucket capacity/yield balance and in-game menu behavior after the copper kettle issue is understood.

**Technical Notes:**
The implementation uses a parallel saltwater container family because bucket output yield and returned container differ from pot/kettle behavior.

Vanilla B42.19 ids confirmed in `media/scripts/generated/items/normal.txt`:

- `Base.Bucket`
- `Base.BucketForged`

Bucket saltwater items use `MinutesToCook = 360`, `MinutesToBurn = 480`, and extraction recipes yield `7x Base.Salt`.

### Phase 4: Fix Copper Kettle Fill Menu Detection

**Status:** Work Complete

**Important Correction:** The previous copper kettle work in this DevCycle was incomplete. Although Phase 2 added `SaltwaterKettleCopper`, `SaltKettleCopper`, recipes, and menu mappings, in-game testing shows that a player with a copper kettle still does not receive the `Fill Kettle with Saltwater` menu option. This phase is dedicated specifically to making copper kettle detection and menu enablement work before returning to forged pot or bucket behavior.

- [x] Continue static/code review of the copper kettle path before adding runtime logging or debug prints.
- [x] Compare the copper kettle code path against the working regular kettle path, including menu mapping, item definitions, and produced saltwater item ids.
- [x] Adjust `WellFillMenu.lua` so a valid empty copper kettle is added to `containers.kettle`.
- [ ] Verify in-game that the `Fill Kettle with Saltwater` menu appears when the player carries an empty copper kettle and right-clicks a saltwater well.
- [ ] Verify in-game that selecting the copper kettle queues `ISFillKettleFromWell` with the intended copper-kettle saltwater result.
- [ ] Keep this phase focused on copper kettle only; forged pot and bucket fixes should wait until copper kettle behavior is understood. Phase 3 is not complete and likely suffers from the same detection problem, but the current investigation is intentionally narrowed.

**Technical Notes:**
Static analysis in `mymods/PseudoSaltWell42_19/doc/ideas/codex_vanillaKettleFillMenuAnalysis.md` found that vanilla `Base.Kettle_Copper` should be kettle-like: it has `PourType = Kettle` and a `FluidContainer` in `media/scripts/generated/items/normal.txt`. Phase 4 avoided runtime logging and replaced the broad generalized inventory predicate with direct `getAllTypeRecurse(...)` lookups for each supported type, including both `Base.Kettle_Copper` and `Kettle_Copper`. This mirrors the known-working regular kettle path more closely and avoids calling behavior getters across every carried item.

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
- This work has not been marked `Verified`; in-game confirmation is still required.
- Copper kettle menu availability is known incomplete despite earlier DC8 implementation work.
- Bucket and forged bucket menu availability are also not complete; they likely suffer from the same detection issue as copper kettle, but investigation is intentionally narrowed to copper kettle first.
- Do not add runtime logging/debug prints for Phase 4 yet. Ed wants a static/code-review attempt first and may inspect the small mod directly if the issue is not found.

---

## Completion Summary

**Completion Date:** 2026-07-12
**Phases Completed:** Phase 1 and Phase 4 implementation. Phase 2 and Phase 3 remain partially complete until copper kettle and bucket-family menu behavior are verified in-game.
**Work Deferred:** In-game verification of copper kettle menu detection/action result, plus later investigation of bucket and forged bucket menu detection.

**Accomplishments:**

- Retuned pot and kettle saltwater cooking to 2 hours with 2-salt extraction yield.
- Added forged pot and copper kettle saltwater/cooked-salt states, emptying support, and extraction recipes. Copper kettle fill-menu support was attempted but is incomplete in-game and is now tracked in Phase 4.
- Added bucket and forged bucket saltwater/cooked-salt states with 6-hour cooking and 7-salt extraction yield. `Base.BucketEmpty` maps into the normal bucket path rather than a separate recipe. Bucket-family fill-menu behavior is not complete and remains pending after the copper kettle investigation.
- Generalized fill timed actions to accept the produced saltwater item type and remove the source container from its actual inventory container.
- Expanded world context menus for pot, kettle, and bucket filling groups. Phase 4 changed inventory detection to direct recursive type lookups for each supported container id, including `Base.Kettle_Copper` and `Kettle_Copper`.
- Expanded inventory emptying support for every new saltwater and cooked-salt state.

**Metrics:**
- Files modified: 8

**Validation:**

- `python -m json.tool` passed for `ContextMenu.json`.
- Confirmed B42.19 vanilla item ids with `rg` in `media/scripts/generated/items/normal.txt`.
- Confirmed reused vanilla model ids with `rg` in `media/scripts/generated/models_items.txt`.
- Confirmed expected mod ids, cook times, and `item 7 Base.Salt` outputs for bucket and forged bucket recipes with `rg` across the mod media folder.
- Lua bytecode validation was not run because `lua`/`luac` are not available in this environment.

**Lessons / Notes:**

- The fill actions were narrow but easy to generalize by passing the target saltwater item type from the menu mapping. The Phase 4 menu lookup no longer depends on broad behavior inference; it directly requests each supported item type from inventory, which should make copper kettle handling closer to the known-working regular kettle path.
- Bucket behavior needed separate item states and recipes instead of sharing pot behavior because the cook time, yield, and return containers differ. Phase 3 is not complete until bucket-family menu detection is resolved and verified.
- The DevCycle is reopened as In Progress until Phase 4 resolves copper kettle menu detection and Ed verifies the behavior in-game.
