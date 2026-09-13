# DevCycle 004: Liquid Container

**Status:** Planning
**Start Date:** 2026-09-12
**Target Completion:** TBD
**Focus:** Turn the placeholder Churning Machine into a fluid container with a 20 liter capacity, granting the same "Add Liquid from Item", "Container Info", "Transfer Liquid", "Fill", and "Empty" interactions the Amphora gets from `component FluidContainer`.

---

## Goal

Implement Step 4 of `PseudoChurningMachinePlan.md`: give the `ChurningMachine` entity (built in DevCycle 003) a 20-liter fluid container, so the player gets the same basic set of fluid interactions the Amphora has. No other functionality is in scope: no "Turn On" action, no cycle, no fullness/butter mechanic. As part of this cycle, also change the object's in-game name to "Churning Machine" (with proper spacing), rather than any bare/internal identifier.

## Desired Outcome

The Churning Machine has a `FluidContainer` with a 20 liter capacity, which grants these specific vanilla interactions automatically — traced directly from `ISWorldObjectContextMenuLogic.doFluidContainerMenu()`/`addFluidFromItem()` (`zombie42_20_4/iso/ISWorldObjectContextMenuLogic.java:4203-4357`), with the exact player-facing menu text confirmed against the actual translation strings (`media42_20_4/lua/shared/Translate/EN/ContextMenu.json`, `Fluids.json`) rather than paraphrased — this is the same generic mechanism the Amphora relies on (per `claude_amphoraAnalysis.md`, which never needed any custom Lua for basic fluid storage):

1. **"Add Liquid from Item"** (translation key `ContextMenu_AddFluidFromItem`, `ContextMenu.json:72`) — right-click submenu listing every fluid-holding item in the player's inventory that can pour into the object; selecting one drains that held item's fluid into the Churning Machine, up to its remaining capacity. This is the interaction that lets the player fill it with milk from a bucket/jug/etc.
2. **"Container Info"** (`Fluid_Show_Info`, `Fluids.json:18`) — opens a read-only panel showing the container's current fluid contents and amount.
3. **"Transfer Liquid"** (`Fluid_Transfer_Fluids`, `Fluids.json:2`) — opens the generic `ISFluidTransferUI`, letting the player move fluid between the Churning Machine and another container via drag/pour controls (gated on `canPlayerEmpty()`).
4. **"Fill"** (`ContextMenu_Fill`, `ContextMenu.json:7`, via `doFillFluidMenu`) — lets the player fill a held empty/partial container *from* the Churning Machine's contents (the reverse direction of #1).
5. **"Empty"** (`Fluid_Empty`, `Fluids.json:20`) — dumps the entire contents of the Churning Machine onto the ground in one action (only offered when capacity is under the engine's "unlimited" threshold, which a 20L cap is well within).

Not applicable here and expected to not appear: "drink water"/"wash clothing" submenus, which are gated on the container actually holding Water specifically — milk doesn't trigger either.

- **Only Cow's Milk (`CowMilk`) can be poured in.** Per `PseudoChurningMachineIdea.txt` ("We'll start this simply, using only cow's milk. Sheep's milk will happen after step 11") and `PseudoChurningMachinePlan.md`'s Core Mechanics/Deferred sections, Sheep's Milk is explicitly out of scope until after Step 11. Pouring any other fluid (including Sheep's Milk) must not be accepted.
- The object's displayed name in-game reads "Churning Machine".
- No cycle, no "Turn On" action, no fullness/butter behavior yet — those are Steps 5-9, each their own DevCycle.

---

## Tasks

### Phase 1: Research the Amphora's `FluidContainer` component

**Status:** Planning

- [ ] Re-read `claude_amphoraAnalysis.md`'s `component FluidContainer` block (`Capacity`, `RainFactor`, `InitialPercentMin`/`Max`) and confirm which fields are actually needed for a 20L container with no rain-collection (the Churning Machine is presumably used indoors/isn't meant to catch rain, unlike the Amphora — confirm this assumption against the idea doc before implementing).
- [ ] Confirm the exact `whitelist` syntax for restricting a `FluidContainer` to a single fluid type, `CowMilk` — reference the inline `whitelist { fluid = CowMilk, fluid = SheepMilk }` syntax `PseudoButterChurner`'s DevCycle 2 Phase 8 used (adapted here to `CowMilk` only, since Sheep's Milk is out of scope until after Step 11 — this is not an open decision, it's already settled by the idea doc and plan).
- [ ] Confirm how the built-object's display name ("Churning Machine") should be sourced/verified — check whether the xuiSkin `DisplayName` field already used in DevCycle 003 is what's shown when the player hovers/interacts with the placed object, or whether a separate mechanism (e.g. `setName()`) is what actually needs changing.

**Technical Notes:**


### Phase 2: Add the `FluidContainer` component

**Status:** Planning

- [ ] Add `component FluidContainer` to `entity_ChurningMachine.txt` with `Capacity = 20.0` (matching the Amphora's `Capacity = 300.0` pattern, just a smaller number). This one component is what grants all five interactions listed in Desired Outcome ("Add Liquid from Item", "Container Info", "Transfer Liquid", "Fill", "Empty") — none of them need custom Lua or a menu-item declaration of their own.
- [ ] Restrict the `FluidContainer` to `CowMilk` only, via a `whitelist` block, per Phase 1's syntax research. Sheep's Milk and every other fluid must be rejected.
- [ ] Confirm the object's in-game display name reads "Churning Machine" (the task called out explicitly by Ed for this cycle) — fix if Phase 1's research found a gap.
- [ ] Confirm no other functionality (`CraftBench`, `Resources`, `DryingCraftLogic`, custom menu items) is introduced this cycle.

**Technical Notes:**


### Phase 3: In-game verification

**Status:** Planning

- [ ] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing (per `PseudoChurningMachinePlan.md`'s standing instruction).
- [ ] Confirm **"Add Liquid from Item"**: right-clicking with a milk-holding item in inventory offers a submenu to pour it into the Churning Machine, and doing so transfers the fluid.
- [ ] Confirm **"Container Info"**: opens a panel showing the current contents/amount.
- [ ] Confirm **"Transfer Liquid"**: opens the fluid-transfer UI and can move fluid in/out via it.
- [ ] Confirm **"Fill"**: a held empty/partial container can be filled from the Churning Machine's contents.
- [ ] Confirm **"Empty"**: dumps the Churning Machine's entire contents onto the ground in one action.
- [ ] Confirm the container caps at 20 liters (pouring in more than the remaining capacity doesn't overfill it).
- [ ] Confirm **only Cow's Milk can be poured in** — attempting to pour Sheep's Milk (or any other fluid) is rejected/not offered.
- [ ] Confirm the object's displayed name reads "Churning Machine".
- [ ] Confirm no unintended menu items or interactions (e.g. drink/wash-clothing options) were introduced.

**Technical Notes:**

---

## Notes and Risks

- No "Turn On" action, no cycle logic, and no fullness/butter mechanic belong in this cycle — those are Steps 5-9, each getting their own DevCycle.
- The `CowMilk`-only restriction is deliberate and settled, not a placeholder — Sheep's Milk support is explicitly Step 11+ work, per `PseudoChurningMachineIdea.txt` and `PseudoChurningMachinePlan.md`. When Sheep's Milk is added later, this restriction will need to be widened (e.g. to a two-fluid whitelist) rather than removed outright.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
