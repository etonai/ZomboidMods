# DevCycle 017: Power Requirement, Sheep's Milk, Purity Gate, and Extraneous Menu Investigation

**Status:** Verified
**Start Date:** 2026-09-15
**Target Completion:** 2026-09-15

---

## Goal

Work through several items from `doc/ideas/PseudoChurningMachineDC11Plus.md` in priority order:

1. **#13 (primary):** Require grid power to run, matching the real washer/dryer's own gating.
2. **#5 (secondary):** Sheep's milk mixing and its contribution to butter output.
3. **#11 + #12 (combined, new design):** Only a container that is 100% milk (cow, sheep, or a mix of the two — see open question below) converts to butter; anything else in the container (water, or any other non-milk liquid) means **nothing happens** on cycle completion — no partial extraction. This supersedes `PseudoChurningMachineDC11Plus.md`'s original `getSpecificFluidAmount`-based partial-extraction design for #11/#12, per Ed's explicit direction (2026-09-15): #11 and #12 are "essentially the same thing" under this new framing.
4. **#10:** Investigate the extraneous Churning Machine menu item. Ed will provide more detail (in-game description/screenshot) before this phase is actionable.

**Dropped/resolved from the idea list, per Ed's direction (2026-09-15):**
- **#6** (front-loader capacity 20L→25L) — marked **Abandoned**. Superseded by DevCycle 016's jump straight to 50L capacity; the 25L increment is no longer relevant.
- **#7** (top-loading variant, 50L+) — marked **Already Implemented**. DevCycle 016 met the capacity goal directly on the existing entity (50L). Per `PseudoChurningMachineDC11Plus.md`'s own summary table, a *separate* top-loading entity/tile (distinct art/model) is technically still open, but Ed has directed we treat #7 as done — a new top-loader entity is not planned work.

## Desired Outcome

- The Churning Machine will not start (or, if already running, stops) when its square loses grid power, mirroring `ClothingWasherLogic.update()`'s per-tick check. Open design questions below must be resolved before implementation.
- The `FluidContainer` whitelist is removed entirely — any liquid can be poured in, per idea #11's own title — with purity enforced in code instead of at the container's input gate.
- The machine can only be turned on, and only produces butter on cycle completion, if the container holds nothing but milk (cow, sheep, or a mix of both — confirmed pure per Open Design Question 3). Any other liquid present (including plain water) blocks "Turn On" outright, or — if already running when it would otherwise complete — produces no butter and leaves the container untouched, rather than DC11Plus's original partial-conversion design.
- `PseudoChurningMachineDC11Plus.md` updated to reflect #6 (Abandoned), #7 (Already Implemented), and #5/#11/#12's new combined status pointing at this DevCycle.
- #10 remains open pending Ed's in-game detail; no implementation attempted until that's available.

---

## Open Design Questions

These need Ed's confirmation before the corresponding phase's implementation work begins — none are assumed answered by this document.

1. **(Phase 1, #13) Mid-cycle power loss — completed or interrupted cycle?** Does losing power mid-cycle count as a completed cycle (butter produced, milk consumed) or an interrupted one, like manual "Turn Off" (no production, no consumption)? `PseudoChurningMachineDC11Plus.md` #13 suggests treating it like manual "Turn Off," matching the real washer/dryer's own behavior — that's the working assumption, not yet confirmed.\
    - It is not a completed cycle, like a manual Turn Off
2. **(Phase 1, #13) Grid power only, or does a generator count too?** `isObjectPowered`'s `includeGenerators` parameter is already `true` in the real washer/dryer's own call chain, so generator support comes for free if that exact pattern is reused as-is — confirm this is actually desired, not just inherited by default.
   - Generator counts
3. **(Phase 2, #5/#11/#12) Does a cow+sheep milk mix count as "pure"?** Is a container of, say, 5L CowMilk + 5L SheepMilk (no water, no other liquid) "100% milk" and eligible for conversion, or does purity mean single-fluid-type only (pure cow, or pure sheep, but not a mix of the two)? `PseudoChurningMachineDC11Plus.md` #5 treats cow+sheep as interchangeable/combinable (matching vanilla's own `churn_butter` recipe, `-fluid 5.0 [CowMilk;SheepMilk] mode:mixture`) — the working assumption for this DevCycle is that a cow+sheep mix still counts as pure milk, but this needs confirmation.
- Yes cow+sheep milk is pure
---

## Tasks

### Phase 1: Require power to run (#13)

**Status:** Verified (Ed, 2026-09-15)

- [x] Resolve Open Design Question 1 (mid-cycle power loss: completed vs. interrupted cycle) with Ed. **Answer: interrupted, like manual Turn Off — no butter, no milk consumed.**
- [x] Resolve Open Design Question 2 (grid-only vs. generator) with Ed. **Answer: a nearby generator counts.**
- [x] Add `entity:getContainer():isPowered()` check (with the existing nil-guard pattern) to `ChurningMachineCode.onToggleOption` before `startMachine`, per the implementation path `PseudoChurningMachineDC11Plus.md` #13 already traced.
- [x] Mirror the same check in `turnOnOffMenu` so "Turn On" is greyed out / labeled unavailable when unpowered, rather than only silently failing when clicked — matching the existing `hasMilk` gate's UX pattern.
- [x] Add a per-tick power check to `checkRunningMachines` (already `Events.OnTick`-driven) so a running machine stops early if power is lost mid-cycle, treated as an interrupted cycle per Open Design Question 1's answer.
- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` to copy the mod into place before testing.
- [x] In-game verification: machine won't start unpowered, greys out correctly, and stops appropriately if power is cut mid-cycle.

**Technical Notes:**

- Added a shared `isPowered(entity)` helper in `ChurningMachineCode.lua`, wrapping `entity:getContainer():isPowered()` (nil-guarded) — `getContainer()` and `getItemContainer()` are the same underlying field per `PseudoChurningMachineDC11Plus.md` #13's tracing, so this reuses the exact container DC007's butter placement already depends on. `isPowered()` itself is the generic `ItemContainer.isPowered()`/`isObjectPowered` check, which already includes nearby-generator support (`includeGenerators = true`), matching Open Design Question 2's answer with no extra code needed.
- `onToggleOption`: `startMachine` now also requires `isPowered(entity)`, alongside the existing milk check.
- `turnOnOffMenu`: added a `hasPower` check; "Turn On" is greyed out (`notAvailable`) when either milk or power is missing. When both are missing, the no-milk tooltip (`Tooltip_ChurningMachine_NoMilk`) takes precedence, matching the option's pre-DC017 behavior; a new `Tooltip_ChurningMachine_NoPower` ("Requires electricity to run.") covers the power-only case. Added to `Tooltip.json`.
- `checkRunningMachines`: running machines are now split into `toInterrupt` (unpowered — stopped via `stopMachine(entity, false)`, i.e. no butter/milk consumption) and `toStop` (normal time-based completion, unchanged) each tick, checked before the existing elapsed-time logic so an unpowered machine stops regardless of how far through the cycle it is.
- Mod copied to the local test install via `CopyModToZomboid.bat`; in-game verification (start blocked while unpowered, menu greys out, mid-cycle power loss stops the machine without producing butter) is still outstanding — first item for Ed to confirm.

### Phase 2: Sheep's milk mixing + purity gate (#5, #11, #12 combined)

**Status:** Verified (Ed, 2026-09-15)

- [x] Resolve Open Design Question 3 (does a cow+sheep mix count as pure milk) with Ed. **Answer: yes, cow+sheep milk is pure.**
- [x] **Design correction found mid-implementation, confirmed with Ed (2026-09-15):** widening the whitelist to `CowMilk;SheepMilk` (as originally planned above) would have kept the container from ever accepting a non-milk liquid at all — making the "impure mixture" scenario this phase's own Desired Outcome describes physically impossible. Ed confirmed the whitelist should instead be **removed entirely**, matching idea #11's own title ("allow any liquid in"), with purity enforced in code instead.
- [x] Removed the `FluidContainer` `whitelist` block entirely from `entity_ChurningMachine.txt` (was `CowMilk` only) — `FluidContainer.canAddFluid` allows any fluid when `whitelist == null` (confirmed by reading `FluidContainer.java`), so any liquid can now be poured in.
- [x] Changed the milk-gate check (`hasMilk`, used by both the toggle menu and the cycle-completion logic) to a purity check (`isPureMilk`): the container converts — and can even be turned on — only if **every** fluid present is cow and/or sheep milk; any other fluid type present at all (including water) blocks "Turn On" and, if already running when the cycle would complete, produces no butter and leaves the container untouched (not partially consumed).
- [x] Cycle-completion math unchanged (still 5L-increment removal/butter count from `fluidContainer:getAmount()`) — now simply gated by `isPureMilk` first, so it only ever runs on a container that's already 100% milk.
- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` to copy the mod into place before testing.
- [x] In-game verification: pure cow milk still works as before; pure sheep milk converts; a cow+sheep mix converts; a milk+water (or milk+other-liquid) mixture can now actually be poured in, blocks "Turn On" (or, if already running, produces no butter and leaves the container untouched at completion). **Note: this phase's "Turn On" purity gate was subsequently reverted in Phase 4 — see that phase for the final, current behavior.**

**Technical Notes:**

- `entity_ChurningMachine.txt`: `component FluidContainer`'s `whitelist { fluid = CowMilk }` block removed entirely (not widened) — see the design-correction note above.
- `ChurningMachineCode.lua`: added `MILK_FLUID_TYPES = {"CowMilk", "SheepMilk"}`, `getMilkAmount(fluidContainer)` (sums `getSpecificFluidAmount` for both types via `Fluid.Get`), and `isPureMilk(fluidContainer)` (combined milk volume ≥ total amount, within a small epsilon). `isPureMilk` covers cow-only, sheep-only, and cow+sheep-mix containers alike, per Open Design Question 3's answer.
- `onToggleOption` and `turnOnOffMenu`'s `hasMilk` check now call `isPureMilk` instead of a plain "amount > 0" check — an impure mixture now blocks "Turn On" outright (menu greys out with the existing `Tooltip_ChurningMachine_NoMilk` tooltip), rather than starting a cycle that would silently produce nothing 10 minutes later.
- `stopMachine`'s `completedCycle` branch now checks `isPureMilk(fluidContainer)` before removing anything — confirmed via `FluidContainer.removeFluid`'s Java source that removal is already proportional across every fluid type present, so removing from a pure cow+sheep mix correctly reduces both in proportion; this path is only ever reached when the container is already 100% milk.
- Mod copied to the local test install via `CopyModToZomboid.bat`; in-game verification is the outstanding item.

### Phase 3: Extraneous menu item investigation (#10)

**Status:** Verified (Ed, 2026-09-15)

`PseudoChurningMachineDC11Plus.md` #10 could not be located via static source reading (no `fullness`/`GetButter`/`Debug` matches anywhere in the mod).

**Detail from Ed (2026-09-15):** the extra item is labeled **"Churning Machine"**, and appears in the right-click menu **between "Add Fluid" and "Turn On."**

- [x] Get exact in-game menu item text/screenshot from Ed.
- [x] Investigate based on that detail — **root cause confirmed, not just hypothesized.**
- [x] Fix applied and mod copied to the local test install (`CopyModToZomboid.bat`).
- [x] In-game verification: only one entry ("Churning Machine") should now appear between "Add Fluid" and the rest of the menu, opening a submenu that contains "Turn On"/"Turn Off" — not two separate sibling entries.

**Technical Notes:**

- **Root cause, confirmed by reading the Java engine's own dispatch code** (`ISWorldObjectContextMenuLogic.java:5278-5304`, the method that processes every `ContextMenuConfig.contextEntry` with a `customSubmenu`): for each entry, the engine calls `context.addOption(textRef, null, null)` to create the top-level "Churning Machine" entry (`textRef` resolved from `menu = ChurningMachine` via `ContextMenu_ChurningMachine`), then invokes the Lua `customSubmenu` callback (`ChurningMachineCode.turnOnOffMenu`) and hands it that same `option` object via `param.option`. The engine's `addOption(textRef, null, null)` creates an **inert** entry — no click target, no submenu — entirely expecting the callback to wire it up.
- **Confirmed via a real, already-working vanilla example using the exact same mechanism:** `entity_waterdispenser.txt`'s `Add_Bottle` entry (`customSubmenu = ContextMenuCode.AddDispenserBottle`) and its Lua implementation (`media42_20_4/lua/client/ContextMenuCode.lua:10-29`) does: `local subMenu = ISContextMenu:getNew(context); context:addSubMenu(option, subMenu)`, then adds its actual options (`subMenu:addGetUpOption(...)`) onto `subMenu`, not onto `context` directly.
- **Our code never did this.** `ChurningMachineCode.turnOnOffMenu` captured `param.option` into a local variable but never used it, and added "Turn On"/"Turn Off" directly via `context:addGetUpOption(...)` — making it a separate top-level sibling entry next to the inert, un-wired "Churning Machine" entry, instead of nesting it inside a proper submenu. This is exactly the extraneous menu item Ed reported, and a real, confirmed bug — not a misreading of correct menu structure (Phase 3's other hypothesis, now ruled out).
- **Fix applied:** `turnOnOffMenu` now creates `local subMenu = ISContextMenu:getNew(context)`, calls `context:addSubMenu(option, subMenu)`, and adds "Turn On"/"Turn Off" onto `subMenu` instead of `context` — matching the vanilla `AddDispenserBottle` pattern exactly. "Churning Machine" now becomes a real submenu header containing "Turn On"/"Turn Off," rather than two separate entries.
- **UX note:** this does mean reaching "Turn On"/"Turn Off" now takes one extra hover step (through the "Churning Machine" submenu) versus the previous (buggy) flat layout — this is how every other `customSubmenu`-based vanilla entity behaves, so it's consistent with the engine's intended design, not a new tradeoff introduced here.

### Phase 4: "Turn On" should never be content-gated — only output should be

**Status:** Verified (Ed, 2026-09-15)

**Design change from Ed (2026-09-15):** Phase 2 made "Turn On" require pure milk (`isPureMilk`), greying the option out for an empty or impure container. Ed wants this reverted — the machine should **always** be able to turn on regardless of what's in it (or whether it's empty), gated only by power (Phase 1's `isPowered` check, unchanged). Purity should only ever affect **output**: no butter (and no consumption) at cycle completion unless the container is 100% milk, exactly as Phase 2 already built for the completion path.

- [x] Remove the `isPureMilk`/`hasMilk` check from `ChurningMachineCode.onToggleOption` — starting the machine now only requires `isPowered(entity)`, not any particular container contents.
- [x] Remove the `hasMilk` check from `ChurningMachineCode.turnOnOffMenu` — "Turn On" now only greys out for the power gate (`Tooltip_ChurningMachine_NoPower`). Decided to remove `Tooltip_ChurningMachine_NoMilk` entirely rather than leave it unused, since nothing referenced it anymore — deleted from `Tooltip.json`.
- [x] Left `stopMachine`'s `completedCycle` branch untouched — its `isPureMilk` gate (no butter/consumption on an impure or empty container) is exactly the behavior Ed wants to keep.
- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` to copy the mod into place before testing.
- [x] In-game verification: machine turns on with an empty container, with water only, with a milk/water mix, and with pure milk — in every case it runs (sound, power draw) but only the pure-milk case produces butter at completion.

**Technical Notes:**

- `onToggleOption`: dropped the `fluidContainer`/`isPureMilk` check entirely — `startMachine` now only requires `isPowered(entity)`.
- `turnOnOffMenu`: dropped the `hasMilk` local and its tooltip-precedence branch — `subOption.notAvailable` now depends only on `not hasPower`, always showing `Tooltip_ChurningMachine_NoPower` when greyed out.
- `Tooltip.json`: removed the now-unreferenced `Tooltip_ChurningMachine_NoMilk` entry.
- `stopMachine`'s `completedCycle` branch, `isPureMilk`, and `getMilkAmount` (added in Phase 2) are unchanged — output is still gated on purity exactly as before.
- Mod copied to the local test install via `CopyModToZomboid.bat`; in-game verification is the outstanding item.

---

## Notes and Risks

- Phase 2's purity-gate design is a deliberate departure from `PseudoChurningMachineDC11Plus.md`'s original #11/#12 analysis (which proposed `getSpecificFluidAmount` for partial milk extraction from a mixed container). Ed's direction (2026-09-15) replaces that with an all-or-nothing purity check — simpler, and the design DevCycle 017 will actually implement.
- See **Open Design Questions** above — none of these three should be assumed before writing code.
- Phase 3 is explicitly blocked on information only Ed can provide; do not spend further time on static source investigation for #10 until that arrives.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

**Completion Date:** 2026-09-15

**Phases Completed:** All 4 phases (power requirement, sheep's milk + purity gate, extraneous menu item fix, "Turn On" content-gate reversal) completed and verified in a single session.

**Work Deferred:** None — this DevCycle's own Desired Outcome was fully met, including the mid-session design corrections below. `PseudoChurningMachineDC11Plus.md` #2 ("Wash Menu"/reclassification), #3 ("Add Liquid from Item"), #4, and #9 remain open/deferred as before — untouched by this DevCycle, not new gaps introduced by it.

**Accomplishments:**
- **#13 (power requirement):** the Churning Machine now requires grid power (or a nearby generator) to turn on, and stops as an interrupted cycle (no butter, no milk consumed) if power is lost mid-run — matching the real washer/dryer's own behavior.
- **#5, #11, #12 (sheep's milk + purity gate, combined):** the `FluidContainer` whitelist was removed entirely (any liquid can now be poured in, per idea #11's own title), and a new `isPureMilk` check (cow and/or sheep milk, combined) gates output — a container produces butter, and consumes anything, only if it's 100% milk at cycle completion; otherwise nothing happens and the container is left untouched.
- **#10 (extraneous menu item):** found and fixed a real, confirmed bug — the Java engine's `customSubmenu` mechanism hands the Lua callback an inert `option` object expecting it to be wired into a real submenu (matching vanilla's own `ContextMenuCode.AddDispenserBottle` pattern), which this mod's code never did. "Churning Machine" was appearing as an inert sibling entry next to "Turn On" instead of containing it. Fixed by building a proper submenu (`ISContextMenu:getNew` + `context:addSubMenu`), so "Churning Machine" now correctly nests "Turn On"/"Turn Off."
- **Phase 4 (design correction, requested mid-cycle):** Phase 2 had also made "Turn On" itself require pure milk. Ed asked for this reverted — the machine should always be able to turn on regardless of contents (gated only by power); purity should only ever affect output. Reverted in Phase 4, with the now-unused `Tooltip_ChurningMachine_NoMilk` tooltip removed as dead code.
- Two real mid-implementation design corrections were caught and fixed before/during coding rather than after: Phase 2's whitelist plan (widening to `CowMilk;SheepMilk`, which would have made "impure mixture" physically impossible) was corrected to a full whitelist removal per Ed's confirmation; and #10 turned out to be a genuine bug rather than a misreading of normal menu structure, as the phase's own leading hypothesis had left open.
- Items #6 and #7 were resolved by direction rather than implementation: #6 (25L capacity) marked Abandoned (superseded by DC016's 50L), #7 (top-loading variant) marked Already Implemented (DC016 met the capacity goal on the existing entity).

**Metrics:** 4 phases, 1 real bug found and fixed (#10's un-wired submenu), 1 mid-implementation design correction confirmed with Ed (Phase 2's whitelist scope) and 1 mid-cycle design reversal requested and applied (Phase 4), 3 code files modified (`ChurningMachineCode.lua`, `entity_ChurningMachine.txt`, `Tooltip.json`).

**Lessons / Notes:**
- Writing out a DevCycle's task list in detail before implementing paid off twice: it's what surfaced the Phase 2 whitelist inconsistency (the written Desired Outcome required impure mixtures to be reachable; the literal task list as first drafted would have made them impossible) before any code was written, rather than after — the correction was cheap because it was caught at the planning-vs-implementation comparison step, not after building the wrong thing.
- #10 is a good example of the mod's own research convention working as intended: rather than accepting the "leading hypothesis" (that "Churning Machine" was just an expected submenu header) at face value, re-reading the actual Java engine dispatch code turned up a real, confirmed root cause and a working vanilla precedent (`ContextMenuCode.AddDispenserBottle`) to fix it against — the hypothesis was wrong, and static analysis alone was enough to prove it, no in-game trial-and-error needed.
- Design requirements changed twice mid-cycle (Phase 2's purity-gate scope, then Phase 4's reversal of "Turn On" content-gating) — both were incorporated cleanly because output (butter production) and access (can the machine be turned on) were kept as separately gated concerns in the code from Phase 2 onward, so Phase 4 only had to touch the access gate.
