# PseudoChurningMachine — DC11+ Idea Analysis

**Created:** 2026-09-13
**Source:** `mymods/PseudoChurningMachine/doc/ideas/DC11Ideas.txt`
**Purpose:** A numbered, analyzed breakdown of every idea in `DC11Ideas.txt`, for future DevCycles to implement out of order, referenced by number (`#1`, `#2`, etc.). Numbers are stable once assigned — don't renumber this list as items are completed or dropped; mark them done/dropped in place instead, the same convention `PseudoChurningMachinePlan.md` uses for its Incremental Steps.

This is an analysis document, not a DevCycle plan — it doesn't commit to an implementation order or bundle items into cycles. Each numbered item below should get its own DevCycle (or be folded into one, if a future planning pass decides two items are cheaper to do together) when work on it actually begins, per `DevelopmentProcess.md`.

---

## 1. "Turn On" running sound still doesn't play

**Status:** RESOLVED (DevCycle 014, 2026-09-14).

DevCycle 005 matched the Lua code exactly to the vanilla `ClothingWasherLogic.updateSound()` pattern — `IsoWorld.instance:getFreeEmitter(x, y, z)`, `IsoWorld.instance:setEmitterOwner(emitter, entity)`, `emitter:playSoundLoopedImpl("ClothingWasherRunning")` — and it stayed silent through DevCycle 011 (17 phases), DevCycle 012's research, and DevCycle 013's abandoned attempt to route around the problem entirely by converting a real washer/dryer (see #8's updated status below — that path was tried and abandoned, and turned out not to be needed).

**Actual root cause and fix, found in DevCycle 014 by comparing four other vanilla sound-emitting objects (generator, stove/microwave, digital watch — see `claudeDocs/claude_generatorAudioAnalysis.md`, `claude_microwaveAudioAnalysis.md`, `claude_digitalWatchAudioAnalysis.md`) instead of continuing to vary code anchored to the washer's own pattern:** `IsoWorld.instance:setEmitterOwner(emitter, entity)` leaves the emitter in `IsoWorld`'s automatically-ticked pool — which works for a real `IsoObject` owner, but was not sufficient for our `GameEntity`-backed scripted entity. A left-behind digital watch's alarm (confirmed, everyday vanilla behavior) uses a different mechanism instead: `IsoWorld.instance:takeOwnershipOfEmitter(emitter)` (removing it from the automatic pool) plus an explicit, manually-called `emitter:tick()` every frame (mirroring `ItemSoundManager.update()`, the manager that drives that watch's own sound). Applying that exact recipe to the Churning Machine — replacing `setEmitterOwner` with `takeOwnershipOfEmitter`, and adding a manual `emitter:tick()` call inside the existing `Events.OnTick`-driven `checkRunningMachines` — made the running sound audible. DevCycle 014 also added handle-based sound stopping and proper `returnOwnershipOfEmitter` cleanup on stop, matching the generator's/watch's own patterns.

**No longer cross-referenced to #8** — #1 was fixed independently, on the scripted `GameEntity` entity, without needing to convert to a real washer/dryer object at all.

## 2. Wash Menu, wrong displayed name, and the reclassification hypothesis

**Status:** Open, hypothesis unconfirmed (carried over from DevCycle 004 Phase 5 Part A).

The leading, code-backed theory (`zombie42_20_4/iso/CellLoader.java`, `DoTileObjectCreation()`) is that a vanilla `appliances_laundry_01_*` tile our `SpriteConfig` reuses is baked with an `ISO_TYPE`/`CONTAINER` property value that makes the game reclassify the placed object as a real `IsoClothingWasher`/`IsoCombinationWasherDryer` — which would explain the Wash Menu, the wrong name, *and* the free 20-encumbrance item inventory DevCycle 007 successfully used, as one shared cause rather than three coincidences. Still unconfirmed because the tile's actual baked property data isn't present in any decompiled source available to this project. **Note (2026-09-14): the specific tile changed since this was written** — DevCycle 015 moved our own entity's sprite from `appliances_laundry_01_0` (Blue Combo Washer/Dryer) to `appliances_laundry_01_4..7` (White Washing Machine, one row per facing, per DevCycle 016 Phase 6) — the reclassification hypothesis, if true, would now apply to whichever of those four tiles is in use, not `_0` specifically.

**Cross-reference — update (2026-09-14): #8 is now implemented (DevCycle 016), replacement-based, on the scripted entity — separate from this hypothesis, not a resolution of it.** #2 remains open and can be treated as a real bug to eventually fix per the plan on record (`PseudoChurningMachinePlan.md`: a mod-owned tile/texture pack replacing the borrowed vanilla graphic) whenever picked up.

## 3. "Add Liquid from Item" still missing

**Status:** Open, root cause not found; three candidate causes already ruled out (DevCycle 004 Phase 5 Part B): input lock, container-full, and wrong fluid type in the test item. Workaround in use: "Transfer Liquid."

**Update (DevCycle 013, 2026-09-14):** re-encountered on a *real* converted washer/dryer object during DC13's audio-fix attempt (which used #8's conversion mechanism as a means to try fixing #1, not as a pursuit of #8 itself) — same symptom (no "Add Liquid from Item," but "Transfer Liquid" works), confirming this is a genuine, long-standing gap rather than something specific to the scripted entity's own fluid-container setup. This remains open exactly as before, on the current (scripted-entity) Churning Machine — including on machines obtained via DevCycle 016's conversion feature, since those are the same scripted entity, not the real washer/dryer object DC13 was investigating.

Traced the actual gating logic one level deeper than DevCycle 004 did, in `ISWorldObjectContextMenuLogic.addFluidFromItem()` (`zombie42_20_4/iso/ISWorldObjectContextMenuLogic.java:4287-4307`). An inventory item is offered in the "Add Liquid from Item" submenu only if **all three** of these are true for it:
```java
item.canStoreWater() && pourFluidInto.canTransferFluidFrom(item.getFluidContainer()) && item.getFluidContainer().canPlayerEmpty()
```
- `item.canStoreWater()` — an item-level script flag (`CanStoreWater = true`, `zombie42_20_4/scripting/objects/Item.java:104/2458`), not something our entity controls. Should already be true for any normal milk container item (bucket, jug, etc.) — not investigated directly, but not expected to be the cause.
- `pourFluidInto.canTransferFluidFrom(item.getFluidContainer())` — resolves to `FluidContainer.CanTransfer(itemFC, ourFC)`, which DevCycle 005's research already traced and confirmed requires every fluid in the source item to pass our whitelist (`CowMilk` only). DevCycle 004 confirmed the test item held real Cow's Milk, so this should pass.
- **`item.getFluidContainer().canPlayerEmpty()` — not explicitly tested by DevCycle 004's three ruled-out causes.** This is a genuinely new candidate this analysis surfaced: if the specific milk-holding item used for testing can't be "player-emptied" for some reason (e.g. a script flag on that particular item type), it would silently fail this exact gate and produce precisely the observed symptom (option not present, no error). Recommend this be the first thing re-tested in a future DevCycle, ideally with a couple of different milk-container item types (not just one) to rule out an item-specific flag versus a container-specific one.

## 4. Final build recipe/materials

**NOTE from Ed: don't worry about this — keep the placeholder (1 plank + 1 nail) for testing purposes until the end.** No analysis performed, per instruction.

## 5. Sheep's milk mixing and its contribution to butter output

**Status:** Open, no design yet.

Directly related to #11 and #12 below — see those for the mechanism (whitelist changes, `getSpecificFluidAmount`, and the vanilla Butter Churn's own `mode:mixture` precedent). The `churn_butter` recipe (`media42_20_4/scripts/generated/entities/animals/craftRecipes/recipes_butter_churn.txt`) already treats `CowMilk` and `SheepMilk` as interchangeable inputs for butter (`-fluid 5.0 [CowMilk;SheepMilk] mode:mixture`) — the vanilla Butter Churn doesn't distinguish them at all for output purposes. The simplest design consistent with that precedent: widen the Churning Machine's `FluidContainer` whitelist from `CowMilk` only to `CowMilk;SheepMilk`, and change the cycle-end logic to remove/convert *combined* cow+sheep milk in 5L increments rather than treating them separately. This doesn't need a new mechanic — it needs the whitelist widened and the removal math changed from "amount of CowMilk" to "amount of CowMilk + SheepMilk combined," which `FluidContainer.getSpecificFluidAmount(Fluid)` (see #11) makes straightforward.

## 6. Front-loading capacity: 20L -> 25L

**Status:** Trivial, low-risk, ready to implement whenever picked up.

A single-value change: `entity_ChurningMachine.txt`'s `component FluidContainer { Capacity = 20.0, ... }` becomes `Capacity = 25.0`. Every downstream mechanic (5L-increment removal, butter-per-5L generation) is already written in terms of `fluidContainer:getAmount()` and doesn't hardcode `20.0` anywhere in `ChurningMachineCode.lua` — confirmed by re-reading the file in full. 25L / 5L = exactly 5 butter sticks on a full cycle, no remainder-math changes needed. No known risk beyond the ordinary re-test of the existing DevCycle 006/007 test matrix at the new capacity.

## 7. A top-loading variant, 50L+ capacity

**Status:** Open, needs its own entity + asset, but the *logic* code is already reusable as-is.

Good news found in this analysis: `ChurningMachineCode.lua`'s functions (`turnOnOffMenu`, `onToggleOption`, `startMachine`, `stopMachine`, `checkRunningMachines`) all take `entity` as a parameter and key their per-machine state (`ChurningMachineCode.active`, `ChurningMachineCode.emitters`) off `machineKey(entity)` (the entity's own square coordinates) — nothing in the code assumes there's only one Churning Machine entity type or hardcodes a single entity name. A second entity (e.g. `ChurningMachineTopLoader`) with its own `entity_ChurningMachineTopLoader.txt` can point its `ContextMenuConfig.customSubmenu` at the exact same `ChurningMachineCode.turnOnOffMenu`, with no Lua code changes required — only a new entity script (own `Capacity = 50.0`+, own `ContainerName`, own recipe) and a new `SpriteConfig.row` pointing at a top-loading washer tile.

**What's not yet known:** whether a suitable top-loading washer tile/graphic already exists in the vanilla tileset the way `appliances_laundry_01_0` did for the front-loader. Grepping the decompiled sources found no top-loader-specific tile name (tileset sprite row names are baked into compiled `.pack` tileset data, not present as readable text anywhere in this repo, the same limitation DevCycle 004 hit trying to verify `appliances_laundry_01_0`'s own baked properties). Finding a usable vanilla tile (or deciding this needs mod-owned art) would need in-game tile browsing, not more source reading.

## 8. Convert a real washer/dryer into a Churning Machine (Electrician-gated)

**Status:** IMPLEMENTED (DevCycle 016, 2026-09-14) — replacement-based, see `doc/planning/completed/DevCycle016.md`.

DC13 (2026-09-14) had earlier borrowed this idea's mechanism as a *means to fix #1's audio problem* — not an attempt at this feature for its own sake — using the **flag-based** approach, and abandoned it after finding a real converted washer/dryer's fluid container was unreliable across different object instances (see below). #1 was then fixed independently, a different way, in DevCycle 014.

DevCycle 016 subsequently implemented this idea for real, on its own merits, using the **replacement-based** approach instead (idea #8's other option, described below): the real washer is removed and this mod's own scripted `Pseudonymous.ChurningMachine` entity is placed in its square. Requirement: a screwdriver (checked, not consumed) and Electricity skill level 6. This sidesteps DC13's fluid-container-reliability blocker entirely, since replacement never touches or depends on the real object's own container — confirming idea #8's own original assessment (below) that replacement-based, while "simpler to reason about," would reintroduce #1/#2/#3 as open problems on the scripted entity... except by DC16's time, #1 (audio) and #3-adjacent concerns were already resolved on the scripted entity independently (DC014), so replacement-based no longer had that downside either. Scope: plain washer only (`IsoClothingWasher`, "White Washing Machine"), not the combo unit or a standalone dryer — a natural follow-on, not implemented here.

**DC13's flag-based finding, still relevant if flag-based is ever revisited for the combo/dryer case:** the conversion mechanism itself worked correctly end-to-end (Electrician-perk gate, `ModData` flag, vanilla Wash-menu suppression via `Events.OnFillWorldObjectContextMenu`, all confirmed in-game), but a real converted washer/dryer's fluid container was unreliable across different object instances — one converted unit had a working fluid submenu, a second had none at all, apparently because it was still in vanilla's piped/infinite-water mode (`IsoObject.usesExternalWaterSource`/`isUnmovedPipedWaterSource()`) and had never been given a real local `FluidContainer` component. This is exactly why DC16 used replacement-based instead — it doesn't depend on that container at all.

*Original analysis, kept for reference:*

Technically feasible with an existing, generic vanilla mechanism: `Events.OnFillWorldObjectContextMenu` (confirmed real and already used by many vanilla systems, e.g. `media42_20_4/lua/client/Vehicles/ISUI/ISVehicleMenu.lua:1741`, `media42_20_4/lua/client/ISUI/ISBBQMenu.lua`) lets Lua add custom menu options onto *any* world object's right-click menu, including a real vanilla `IsoClothingWasher`/`IsoCombinationWasherDryer` — no `ContextMenuConfig` component is needed, since that mechanism is for scripted entities and a real washer/dryer isn't one. A handler could check `instanceof(object, "IsoClothingWasher")` (or the combo variant), check the player's skill via `playerObj:getPerkLevel(Perks.Electricity)` (the skill's real internal name is **`Electricity`** — "Electrician" is the profession/trait display name, confirmed via `media42_20_4/lua/shared/Translate/EN/UI.json:916` and the moveable tool-definition at `media42_20_4/lua/shared/Moveables/ISMoveableDefinitions.lua:313`, which references `Perks.Electricity` directly), and if both pass, add a "Convert to Churning Machine" option requiring whatever ingredients get decided.

**The harder open question is what "convert" actually changes.** A real `IsoClothingWasher` object can't have its underlying Java class swapped at runtime from Lua. Two realistic approaches:
1. **Flag-based:** set a `ModData` flag (`isChurningMachine = true`) on the real washer/dryer object, and have `ChurningMachineCode.lua`'s menu/cycle logic hook in via `OnFillWorldObjectContextMenu` (checking that flag) instead of `ContextMenuConfig`, running the churning cycle *alongside* whatever the real object already does. This directly resolves #1 (real audio, for free) and likely #3 (real object, so "Add Liquid from Item" would use the same code path every other real fluid-holding object uses) — but doesn't resolve the Wash Menu (#2) unless it's deliberately hidden/relabeled once converted, which is itself doable via the same event hook (suppressing or renaming the vanilla wash option when the flag is set).
2. **Replacement-based:** remove the real object and place our own scripted `ChurningMachine` entity in its square instead, "converting" only in the sense of a crafted transformation, not a runtime reclassification. Simpler to reason about, but throws away the real object's audio/inventory "for free" wins that made #8 attractive in the first place, and re-introduces #1/#2/#3 as still-open problems on the newly-placed scripted entity.

This decision should happen before deep work on #1/#2/#3, since it changes whether those are still bugs to fix on the scripted entity, or become moot/reframed under a real washer/dryer object.

## 9. Build UI shows the old manual Butter Churner, not the Churning Machine

**NOTE from Ed: don't worry about this — keep it for testing until the end.** No analysis performed, per instruction.

## 10. An extraneous Churning Machine menu item, possibly from the old fullness system

**Status:** Open — could not be located or confirmed by static code reading; needs an in-game description/screenshot from Ed.

Re-read `entity_ChurningMachine.txt` in full: it declares exactly one `ContextMenuConfig.contextEntry` (`menu = ChurningMachine, customSubmenu = ChurningMachineCode.turnOnOffMenu`). Grepped every file the mod ships (Lua and translation JSON) for `fullness`, `GetButter`, and `Debug` (case-insensitive) — **zero matches anywhere in the current mod source.** The fullness/percentage mechanic was fully removed from the plan in DevCycle 004 Phase 4, before any of it was actually implemented in code (it was replaced with the inventory-based design before Steps 7-9 were built), so there shouldn't be leftover fullness-related menu code to find — and none was found.

This most likely means either: (a) the extra menu item Ed is seeing is actually the vanilla Wash Menu (#2) being misattributed to "the old fullness system" rather than a second, genuinely leftover item of ours, or (b) it's something real that isn't visible from static source reading (e.g. generated at runtime some other way not yet traced). **Recommend getting an exact in-game menu screenshot or the precise item text before investigating further** — there's nothing more to find by re-reading source without knowing specifically what extra label is showing up.

## 11. Allow any liquid in; only 100% milk converts to butter

**Status:** Open, no design yet, but the vanilla Butter Churn's own recipe gives a directly-applicable precedent.

Two separate changes are implied: (a) removing or widening the `FluidContainer` whitelist (currently `CowMilk` only) so any liquid can be poured in, and (b) changing the cycle-end conversion math so it only ever consumes/converts the milk portion, not the container's total `getAmount()`.

**(b) is the important part, and it's already solved by a real method this analysis found:** `FluidContainer.getSpecificFluidAmount(Fluid fluid)` (`zombie42_20_4/entity/components/fluids/FluidContainer.java:738`) returns the amount of one specific fluid type present, independent of what else is mixed into the same container. DevCycle 006/007's current code uses the container's *total* `getAmount()` for both the 5L-removal math and the butter-count math — widening the whitelist without also switching this call to `getSpecificFluidAmount(Fluid.CowMilk)` (and, per #5, `SheepMilk`) would incorrectly consume/convert non-milk liquids too. This is a real, concrete implementation requirement for #11, not just a design preference.

This exactly mirrors the vanilla Butter Churn's own approach: `churn_butter`'s recipe (`media42_20_4/scripts/generated/entities/animals/craftRecipes/recipes_butter_churn.txt`) declares `-fluid 5.0 [CowMilk;SheepMilk] mode:mixture` as its input — it draws only from those two fluid types out of whatever the container item actually holds, ignoring anything else present. `claude_butterChurn.md` doesn't go further into how the underlying multi-fluid consumption is implemented at the `FluidContainer` level (its scope was the crafting-bench timing mechanism, not the fluid math), but the recipe-input declaration alone confirms vanilla already treats "consume only the milk out of a mixed container" as a normal, supported pattern — `getSpecificFluidAmount` is very likely the same mechanism the recipe-input system uses under the hood to check availability before consuming.

## 12. Advanced: what happens with a milk/water mixture

**Status:** Open, but largely answered by #11's research above — recorded separately since Ed flagged it as a distinct, harder question.

Given `getSpecificFluidAmount(Fluid)` returns the amount of one fluid type regardless of what else is mixed in, a container holding (say) 8L milk + 4L water at cycle end would report `getSpecificFluidAmount(CowMilk) = 8.0`, and the existing 5L-increment logic would correctly remove/convert 5L of *that* (leaving 3L milk + 4L water untouched), the same way DevCycle 006's current whole-container math already handles a non-multiple-of-5 remainder — just scoped to the milk amount instead of the total. No new mixture-specific mechanic appears to be needed beyond what #11 already requires; the "advanced" difficulty Ed anticipated seems to mostly have been in *not knowing* whether per-fluid-type querying was possible at all, which this analysis now confirms it is. The one part not yet verified: whether `removeFluid(amount)` (used since DevCycle 006) removes fluid proportionally across all types in the container or specifically from one type — if it's the former, converting only the milk portion would need a different, more targeted removal call than the one DevCycle 006 currently uses, and that method should be identified before implementing #11/#12.

## 13. Require power to run, like the real washer/dryer

**Status:** Open, no design yet, but a clean, low-risk implementation path was found — likely the easiest item in this whole list to implement correctly.

Traced the real washer/dryer's own power-gating mechanism in full, not just its existence. `ClothingWasherLogic.update()` (`zombie42_20_4/iso/objects/ClothingWasherLogic.java:58-62`) force-deactivates itself every tick if unpowered:
```java
if (!this.getContainer().isPowered()) {
    this.setActivated(false);
}
```
`ItemContainer.isPowered()` (`zombie42_20_4/inventory/ItemContainer.java:2316-2318`) delegates to `this.parent.checkObjectPowered()` (`IsoObject.java:6999-7010`), which resolves to `ItemContainer.isObjectPowered(this, true)` (`ItemContainer.java:2320-2368`) — the same generic power check used by fridges, freezers, stoves, and TVs: true if the object's square has grid power (in-room, or in an adjacent room if outdoors, via a private helper `isSquarePowered`, `ItemContainer.java:2289-2314`) or, if `includeGenerators` is true, a nearby running generator (`square.haveElectricity()`).

**Confirmed Lua-callable, and already used exactly this way by the real washer/dryer's own toggle UI** — not a Java-only mechanism. `media42_20_4/lua/client/ISUI/LootWindow/Handlers/ClothingWasherToggle.lua:10` (and the matching dryer/combo handlers in the same folder) call `self.container:isPowered()` directly to decide whether the Turn On/Off toggle is even enabled. `media42_20_4/lua/client/ISUI/ISWorldObjectContextMenu.lua:1178/1183` do the same for the general appliance context menu.

**Directly usable by the Churning Machine, no new mechanism needed — confirmed by cross-checking against DevCycle 007.** `IsoObject.getContainer()` (`IsoObject.java:1940-1942`) and `IsoObject.getItemContainer()` (`IsoObject.java:2499-2501`) are both plain getters for the *exact same field* (`this.container`) — meaning `entity:getContainer():isPowered()` calls the identical object DevCycle 007 already confirmed works reliably for `AddItem("Base.Butter")`. This means power-gating doesn't require any new component, any new tile property, or resolving the still-unconfirmed reclassification hypothesis (#2) — it rides on the same borrowed container #7's butter placement already depends on, with the same defensive nil-check DevCycle 007 already established (`if itemContainer then ... end`) applying equally here.

**Suggested implementation, minimal and consistent with the existing code:** in `ChurningMachineCode.onToggleOption` (`ChurningMachineCode.lua:60-69`), before allowing `startMachine`, add a check like `local container = entity:getContainer(); if container and container:isPowered() then startMachine(entity, playerObj) end` — and mirror the same check in `turnOnOffMenu` (`ChurningMachineCode.lua:71-92`) to grey out/label "Turn On" as unavailable when unpowered, the same way the milk-gate (`hasMilk`) already does, rather than only silently failing when clicked. A currently-running machine should also plausibly stop early if power is lost mid-cycle, mirroring `ClothingWasherLogic.update()`'s own per-tick check — `checkRunningMachines` (`ChurningMachineCode.lua:94-107`), which already runs on `Events.OnTick`, is the natural place to add that, alongside its existing time-based stop condition.

**Open design question, not resolved here:** whether losing power mid-cycle should count as "completed" (removing milk / producing butter, per DevCycle 006/007) or as an interrupted cycle like manual "Turn Off" (no removal, no butter) — this needs a decision before Phase 2 implementation, not just a code change. The real washer/dryer's own behavior (simply pausing/stopping, not consuming a load) suggests treating it like manual "Turn Off," not like natural completion.

**Also worth deciding:** whether "power" here means grid electricity specifically (matching the real washer/dryer, and requiring the player to have restored/maintained electricity — a real, meaningful survival constraint) or whether a portable generator should count too (`includeGenerators = true` in the vanilla check already allows this) — `isObjectPowered`'s `includeGenerators` parameter is already `true` in the real washer/dryer's own call chain, so generator support comes for free if the same method/pattern is reused, without needing a separate decision to add it.

---

## Summary Table

| # | Idea | Status | Key dependency / cross-reference |
|---|---|---|---|
| 1 | Turn On sound still silent | **RESOLVED (DC014)** | Fixed independently of #8 — see #1 |
| 2 | Wash Menu / wrong name / reclassification hypothesis | Open, unconfirmed | Tile changed since DC015/DC016 (now `_4..7`, not `_0`) — hypothesis, if true, applies to those instead |
| 3 | "Add Liquid from Item" missing | Open, new candidate found (`canPlayerEmpty()`) | Re-confirmed present on a real washer too (DC013) — not tied to #8's fate |
| 4 | Final build recipe | Deferred by Ed | Keep placeholder until the end |
| 5 | Sheep's milk mixing | Open, no design | Same mechanism as #11/#12 |
| 6 | Front-loader capacity 20L->25L | **Superseded (DC016)** — went straight to 50L instead | See #7/#8 |
| 7 | Top-loading variant, 50L+ | Capacity goal met directly (DC016, 50L on the existing entity) — a separate top-loading entity/tile is still open if wanted | No new art needed for the capacity itself |
| 8 | Convert real washer/dryer via Electrician gate | **IMPLEMENTED (DC016)** — replacement-based | DC13's flag-based attempt (abandoned) informed the choice of replacement-based instead |
| 9 | Build UI shows old Butter Churner | Deferred by Ed | Keep for testing until the end |
| 10 | Extraneous menu item | Open, not found in source | Needs exact in-game detail from Ed |
| 11 | Any liquid in, only milk converts | Open, mechanism found (`getSpecificFluidAmount`) | Same mechanism as #5/#12 |
| 12 | Milk/water mixture handling | Open, mostly answered by #11 | Verify `removeFluid`'s per-type behavior before implementing |
| 13 | Require power to run | Open, clean implementation path found | Reuses #7/#8's borrowed container (`getContainer():isPowered()`); one open design question (mid-cycle power loss = "Turn Off" or completion?) |
