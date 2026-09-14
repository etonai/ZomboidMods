# DevCycle 004: Liquid Container

**Status:** Work Complete — closed by explicit direction from Ed (2026-09-13) with known gaps intentionally deferred (see Completion Summary); not `Verified`
**Start Date:** 2026-09-12
**Target Completion:** 2026-09-13
**Focus:** Turn the placeholder Churning Machine into a fluid container with a 20 liter capacity, granting the same "Add Liquid from Item", "Container Info", "Transfer Liquid", "Fill", and "Empty" interactions the Amphora gets from `component FluidContainer`.

---

## Process Note (2026-09-12)

I closed this DevCycle and moved it to `doc/planning/completed/` without Ed's permission. I should not have done that.

**When:** 2026-09-12, while writing up Phase 5 (documenting the deferral of the texture-pack fix). The bundling error and the premature closure both happened in that same pass of writing Phase 5's Status/Technical Notes and the Completion Summary — not a separate later mistake.

**Why it happened:** Ed decided to postpone the mod-owned texture-pack work (needed to fix the wrong displayed name and the unwanted Wash Menu) until after Step 11. I bundled all three Phase 3 failures — the wrong name, the Wash Menu, and the missing "Add Liquid from Item" — into a single "Phase 5" item and treated Ed's one deferral decision as covering all of it. That was wrong on two counts: I had only ever called "Add Liquid from Item" *"most likely"* related to the same root cause, and had explicitly not traced it — I never confirmed it, and Ed never deferred it. Once I told myself "Phase 5 is deferred," I treated the cycle's whole punch list as accounted for, which is what let me apply this project's DevCycle-closure rule and close it at all.

Ed ordered me to reopen the DevCycle, because we are not done — there are items that were never deferred. Specifically, "Add Liquid from Item" not appearing at all is a separate, still-open problem, with its own cause not yet identified, and it needs to stay tracked as open work in this document rather than being folded into the deferred texture-pack fix.

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

**Status:** Work Complete

- [x] Re-read `claude_amphoraAnalysis.md`'s `component FluidContainer` block (`Capacity`, `RainFactor`, `InitialPercentMin`/`Max`) and confirm which fields are actually needed for a 20L container with no rain-collection (the Churning Machine is presumably used indoors/isn't meant to catch rain, unlike the Amphora — confirm this assumption against the idea doc before implementing).
- [x] Confirm the exact `whitelist` syntax for restricting a `FluidContainer` to a single fluid type, `CowMilk`.
- [x] Confirm how the built-object's display name ("Churning Machine") should be sourced/verified in the specific context that matters here (the fluid-container menu), not assumed from the xuiSkin field alone.

**Technical Notes:**

**`FluidContainer` fields needed.** `entity_well.txt` (`media42_20_4/scripts/generated/entities/appliances/workstations/entity_well.txt`) gave the clearest real example of a restricted, non-rain-collecting container:
```
component FluidContainer
{
    ContainerName = ChurningMachine,
    Capacity = 20.0,
    InitialPercentMin = 0.0,
    InitialPercentMax = 0.0,
    whitelist
    {
        fluid = CowMilk,
    }
}
```
- `Capacity = 20.0` — the required 20L cap.
- `InitialPercentMin`/`Max = 0.0` — matches the Amphora's own explicit `0.0`/`0.0` (starts empty). Needed explicitly since some vanilla containers (e.g. `Well`, `InitialPercentMin = 0.2`) default to starting partially full — don't rely on an implicit default.
- `RainFactor` — **omitted entirely.** The idea doc never describes the Churning Machine catching rain (unlike the Amphora, which is explicitly outdoor pottery), and nothing in `PseudoChurningMachinePlan.md` calls for it. Confirmed `RainFactor` isn't a required field (`Well` doesn't set it either — it uses `FillsWithCleanWater = true` instead, a different vanilla-specific mechanic not applicable here). Leaving it unset means no passive rain collection, which matches the plan.
- `ContainerName` — see the naming finding below; this is the field that actually needs to be `ChurningMachine`, distinct from the xuiSkin `DisplayName`.

**Whitelist syntax, confirmed against a real example and the enforcement code, not just a plausible guess.** `entity_well.txt` uses exactly:
```
whitelist
{
    fluid = CowMilk,
}
```
(a block, not an inline single-line `whitelist { fluid = X, fluid = Y }` as `PseudoButterChurner`'s DevCycle 2 Phase 8 used for a *different* field shape — confirmed here against the real vanilla `Well` entity instead of relying on that other mod's own possibly-different usage). Traced the enforcement itself in `zombie42_20_4/entity/components/fluids/FluidContainer.java`:
- `canAddFluid(Fluid)` (line 912): `return (this.whitelist == null || this.whitelist.allows(fluid)) && ...` — a fluid must pass the whitelist to be added at all.
- `FluidContainer.CanTransfer(source, target)` (line 1145-1170), used by `canTransferFluidFrom`/`canTransferFluidTo` (which gate the "Add Liquid from Item" submenu's item list, per `ISWorldObjectContextMenuLogic.addFluidFromItem()`, line 4302): iterates every fluid in the *source* item and returns `false` if `!target.canAddFluid(fluid)` for any of them.
- **Conclusion: a `whitelist { fluid = CowMilk }` block will make the "Add Liquid from Item" submenu itself omit any inventory item holding only Sheep's Milk (or any other non-`CowMilk` fluid)** — the restriction isn't just "the pour silently fails," the incompatible item never appears as an option in the first place. This directly satisfies the Phase 3 verification task ("attempting to pour Sheep's Milk is rejected/not offered").

**Display name — corrected finding, more precise than originally assumed.** The xuiSkin `DisplayName` field (`entity_ChurningMachine_xuiSkin.txt`, set in DevCycle 003) governs the BUILD-menu label and (if `uiEnabled` were true) the crafting-window title — **it is not what's shown by the fluid-container interactions this cycle adds.** Traced `ISWorldObjectContextMenuLogic.doFluidContainerMenu()` (line 4210-4213): the clickable top-level menu label that opens the whole fluid submenu is `getMoveableDisplayName(object)` (reads a `CustomName` sprite-tile property — not applicable here, since we reuse vanilla's own `appliances_laundry_01_0` tile unmodified, and it has no `CustomName` set), falling back to `object.getFluidUiName()` → `FluidContainer.getUiName()` → `getTranslatedContainerName()` → `Translator.getFluidText("Fluid_Container_" + containerName)`. This is exactly the same mechanism the Amphora uses: its `FluidContainer` sets `ContainerName = Amphora`, and `media42_20_4/lua/shared/Translate/EN/Fluids.json:63` defines `"Fluid_Container_Amphora": "Amphora"`. **So for this cycle, the object's name in every fluid-related menu/panel (the top-level submenu label, "Container Info", "Fill", "Empty", etc., which all format around `getUiName()`) is set via `ContainerName = ChurningMachine` plus a new translation entry `"Fluid_Container_ChurningMachine": "Churning Machine"` in this mod's own `Fluids.json` — not the xuiSkin `DisplayName`, and not a Lua `setName()` call.** No change needed to the xuiSkin file itself.


### Phase 2: Add the `FluidContainer` component

**Status:** Work Complete — implemented, in-game verification pending (Phase 3)

- [x] Add `component FluidContainer` to `entity_ChurningMachine.txt` with `Capacity = 20.0` (matching the Amphora's `Capacity = 300.0` pattern, just a smaller number). This one component is what grants all five interactions listed in Desired Outcome ("Add Liquid from Item", "Container Info", "Transfer Liquid", "Fill", "Empty") — none of them need custom Lua or a menu-item declaration of their own.
- [x] Restrict the `FluidContainer` to `CowMilk` only, via a `whitelist { fluid = CowMilk, }` block, per Phase 1's confirmed syntax. Sheep's Milk and every other fluid must be rejected.
- [x] Set `ContainerName = ChurningMachine` on the `FluidContainer` component, and add `"Fluid_Container_ChurningMachine": "Churning Machine"` to this mod's `Translate/EN/Fluids.json` (new file) — per Phase 1's finding, this is what actually governs the name shown in the fluid-container menus/panels, not the xuiSkin `DisplayName`.
- [x] Confirm no other functionality (`CraftBench`, `Resources`, `DryingCraftLogic`, custom menu items) is introduced this cycle.

**Technical Notes:**

`entity_ChurningMachine.txt` now declares, ahead of `SpriteConfig`:
```
component FluidContainer
{
    ContainerName = ChurningMachine,
    Capacity = 20.0,
    InitialPercentMin = 0.0,
    InitialPercentMax = 0.0,
    whitelist
    {
        fluid = CowMilk,
    }
}
```
exactly per Phase 1's research (`entity_well.txt`'s real syntax, `FluidContainer.java`'s confirmed enforcement). New file `PseudoChurningMachine/42/media/lua/shared/Translate/EN/Fluids.json` adds `"Fluid_Container_ChurningMachine": "Churning Machine"`. No other component was added — `UiConfig` (`uiEnabled = false`), `SpriteConfig`, and `CraftRecipe` are unchanged from DevCycle 003.


### Phase 3: In-game verification

**Status:** Work Complete — verification run, three issues found; see Phase 5

- [X] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing (per `PseudoChurningMachinePlan.md`'s standing instruction).
- [ ] Confirm **"Add Liquid from Item"**: right-clicking with a milk-holding item in inventory offers a submenu to pour it into the Churning Machine, and doing so transfers the fluid. **FAILED — option is not present at all.**
- [X] Confirm **"Container Info"**: opens a panel showing the current contents/amount.
- [X] Confirm **"Transfer Liquid"**: opens the fluid-transfer UI and can move fluid in/out via it.
- [X] Confirm **"Fill"**: a held empty/partial container can be filled from the Churning Machine's contents.
- [X] Confirm **"Empty"**: dumps the Churning Machine's entire contents onto the ground in one action.
- [X] Confirm the container caps at 20 liters (pouring in more than the remaining capacity doesn't overfill it).
- [X] Confirm **only Cow's Milk can be poured in** — attempting to pour Sheep's Milk (or any other fluid) is rejected/not offered.
- [ ] Confirm the object's displayed name reads "Churning Machine". **FAILED — displays as "Blue Combo Washer/Dryer" or "Clothing Washer" depending on context.**
- [ ] Confirm no unintended menu items or interactions (e.g. drink/wash-clothing options) were introduced. **FAILED — a Wash Menu (the real vanilla washer/dryer's "Turn On" cycle menu) is present.**

**Technical Notes:**

Reported by Ed after testing (2026-09-12): three of the nine checks failed (above), and one unplanned, useful discovery was made — **the built object also has its own item-inventory capacity of 20 encumbrance.** This wasn't declared anywhere in `entity_ChurningMachine.txt` (no `component ItemContainer`/`Resources` was added this cycle) — see Phase 5 for why this is suspected to be connected to the three failures, not a separate, unrelated bonus. This capacity is valuable independent of its cause: Phase 4 uses it to replace the fullness/percentage mechanic originally planned for Steps 7-9.

### Phase 4: Remove the fullness mechanic from `PseudoChurningMachinePlan.md`

**Status:** Work Complete

- [x] Replace the fullness/percentage design in `PseudoChurningMachinePlan.md`'s Core Mechanics section with an inventory-based design: instead of tracking an abstract 0-100% "fullness" value and cashing it out via a "Get Butter (X% full)" menu (composter-style), butter sticks are placed directly into the Churning Machine's own item inventory as they're produced, and the player retrieves them the normal way (opening/looting the object's inventory).
- [x] Revise Steps 7-10 of the Incremental Steps list accordingly: Step 7 becomes "produce butter directly into the object's inventory at cycle end" (merging what were separately Steps 7/8/9 — fullness menu item, butter generation, wiring fullness to the cycle — since there's no intermediate fullness value to add, generate from, or wire up anymore); Step 8 and Step 9 are marked merged/removed rather than renumbering everything, to keep DevCycle 003's "Step 3" references and similar stable; Step 10 (clean up, cycle time to 15 minutes) is kept, minus the now-nonexistent debug fullness menu items.
- [x] Note the dependency this creates on Phase 5: the "20 encumbrance inventory" this plan revision relies on was discovered alongside the Phase 3 failures now tracked as Phase 5 Part A, under an unconfirmed hypothesis that it belongs to a real vanilla object the tile gets reclassified into (see Phase 5 Part A). If that hypothesis is later confirmed and fixed, the inventory capacity may turn out to be a symptom of the same issue rather than an intentional/stable feature of the entity, and this plan revision would need to be revisited.

**Technical Notes:**

Applied directly to `PseudoChurningMachinePlan.md` (Core Mechanics and Incremental Steps sections) — see that document for the current wording. This is a plan-document change only; no mod script files were touched in this phase.

### Phase 5: Fix the problems found in Phase 3

**Status:** Split — Part A (wrong name + Wash Menu) Deferred to after Step 11 (2026-09-12); Part B ("Add Liquid from Item") separately Deferred to DC 11 (2026-09-13), workaround: use "Transfer Liquid"

**This phase covers two separate problems that were deferred separately, on separate dates, for different reasons — record them as two distinct decisions, not one bundled "Phase 5 deferred."** Part A: the fix needs asset work Ed doesn't want to do right now. Part B: three candidate causes were investigated and ruled out without finding the real one, and Ed decided to accept the "Transfer Liquid" workaround rather than keep chasing it now. Both happen to land around the same milestone (post-Step-11 / DC 11), but that's their independent conclusion, not a reason to treat them as one item going forward.

#### Part A — Wrong displayed name and Wash Menu (DEFERRED until after Step 11)

- [ ] **Displayed name is "Blue Combo Washer/Dryer" or "Clothing Washer" (varies by context), not "Churning Machine".** This is a different failure than Phase 1 anticipated — Phase 1 only considered *our own* `ContainerName`/xuiSkin fields being wrong, not the object showing a name that isn't ours at all.
- [ ] **A Wash Menu is present** — the real vanilla washer/dryer's own "Turn On" cycle option, which nothing in this cycle's entity script requests.

**Root cause — the mechanism is confirmed in code; whether this specific tile actually triggers it is a strong inference, not directly verified.** Ed confirmed the Churning Machine was built nowhere near any real washer/dryer, ruling out a same-square/nearby-object collision. Traced a plausible mechanism instead: `zombie42_20_4/iso/CellLoader.java`, `DoTileObjectCreation()` (the tile-based world-object factory, used whenever a tile-backed object is created on a square — not just at map/chunk load) contains, among many other hardcoded sprite-property checks (lines ~127-180):

```java
} else if ("IsoCombinationWasherDryer".equals(spr.getProperties().get(IsoPropertyType.ISO_TYPE))) {
    obj = new IsoCombinationWasherDryer(cell, sq, spr);
    AddObject(sq, obj);
} else if (spr.getProperties().has(IsoFlagType.container) && spr.getProperties().get(IsoPropertyType.CONTAINER).equals("clothingdryer")) {
    obj = new IsoClothingDryer(cell, sq, spr);
    AddObject(sq, obj);
} else if (spr.getProperties().has(IsoFlagType.container) && spr.getProperties().get(IsoPropertyType.CONTAINER).equals("clothingwasher")) {
    obj = new IsoClothingWasher(cell, sq, spr);
    AddObject(sq, obj);
}
```

**Important correction (2026-09-13):** `CONTAINER` here is a *generic* tile property, not washer-specific — the same `CellLoader.java` block uses it for `barbecue`, `barbecuepropane`, `fireplace`, `campfire`, `woodstove`, and `microwave` too, each as a different string *value* of the same property key (confirmed by grepping every `get(IsoPropertyType.CONTAINER).equals(...)` check in the file). It's the specific value (`"clothingwasher"`, `"clothingdryer"`) that would trigger this reclassification, not the mere presence of a `CONTAINER` property.

This is consistent with what `claude_washingMachineAnalysis.md` already established from a different angle: the Blue Combo Washer/Dryer is not a scripted `entity` at all, it's a hardcoded `IsoObject` subclass whose identity is determined by **tile properties baked into the tileset graphic itself**, not by any script — *if* the `appliances_laundry_01_0` tile's own baked property value is actually `ISO_TYPE = "IsoCombinationWasherDryer"` or `CONTAINER = "clothingwasher"`/`"clothingdryer"`. **That specific fact has not been directly verified** — the tile's own property data lives in the game's compiled tileset/`.pack` files, which are not present as readable text anywhere in this repo's decompiled Java or media scripts; searching for `appliances_laundry_01_0` and for any tile-property-definition file (`.tiles`, `tiledef*`) in the sources available here turned up nothing. What's actually being claimed is an inference: *if* this tile carries one of those specific property values, this mechanism would fully explain the observed symptoms as one cause, not four coincidences:
- **Wash Menu** — `toggleClothingWasher()`/`toggleComboWasherDryer()` would fire because the object genuinely is (or is treated as) that hardcoded class.
- **Wrong displayed name** — would be the real appliance's own name resolution, because it's genuinely that object.
- **20-encumbrance inventory** — would be the real appliance's own hardcoded `"clothingwasher"`/`"clothingdryer"` `ItemContainer`, not anything our entity declared.

This is a strong, symptom-consistent hypothesis backed by a real code mechanism — not a guess pulled from nowhere — but it should be treated as **unconfirmed** until either the tile's actual property data is found and read, or an in-game test rules it in/out directly (e.g. checking whether the placed object is literally reported as an `IsoClothingWasher`/`IsoCombinationWasherDryer` instance via a debug/admin tool, if one is available).

**This hypothesis does NOT explain "Add Liquid from Item" — see Part B.** An earlier draft of this document claimed the missing menu item was "most likely" caused by the same reclassification. That claim was traced and disproven: `ISWorldObjectContextMenuLogic.java:919-934` calls `doFluidContainerMenu()` (confirmed working — it's what gives us "Container Info"/"Transfer Liquid"/"Fill"/"Empty") and `addFluidFromItem()` unconditionally, back to back, in the same loop, for the same object. Since the first three are confirmed working on our object, `addFluidFromItem()` ran for it too — there is no washer-specific exclusion between them. The missing menu item is not part of Part A's hypothesis.

**Deferred by direct decision (2026-09-12):** the *investigation and fix* for the wrong name/Wash Menu (which would require authoring a new mod-owned texture pack/tile definition if the hypothesis above is confirmed) is more effort than Ed wants to spend right now. **Postponed until after Step 11** (the same point where the placeholder build recipe/materials are revisited). Tracked in `PseudoChurningMachinePlan.md`'s Deferred/Out of Scope section too. Since this is deferred, the hypothesis above is not being confirmed or acted on now either — it's recorded as the leading theory for whoever picks this up after Step 11 to verify first.

**If confirmed, the fix would be: stop reusing the literal vanilla `appliances_laundry_01_0` tile.** A tile carrying the suspected properties is not just "the same picture" — it would be baked with tile properties that trigger hardcoded reclassification unconditionally, in `DoTileObjectCreation()`, independent of our entity script. The durable fix would be a mod-owned copy of the graphic: a new texture pack + tile definition with the *same visual appearance* but none of the `ISO_TYPE`/`CONTAINER` tile properties — the same pattern `PseudoSaltWell42_19` already uses for its own custom-graphic object (`common/media/pseudoed_salt_01.tiles` + `texturepacks/pseudoed_salt_01.pack`), rather than pointing `SpriteConfig.row` at a shared vanilla index. This would be a different, more fundamental problem than `PseudoButterChurner` DevCycle 2's "duplicate declared sprite row" issue — that was a load-time naming collision; this would be a runtime object-*identity* takeover, which no `SpriteConfig` field could opt out of once the tile itself carries the property.

- [ ] **First, confirm the hypothesis itself** — find and read `appliances_laundry_01_0`'s actual baked tile properties (may require a tool this project hasn't used yet, since the property data isn't in any decompiled Java or media script source found so far), or confirm/refute in-game via a debug/admin means of checking the placed object's actual Java class.
- [ ] If confirmed: extract/copy the Blue Combo Washer/Dryer's `appliances_laundry_01_0` graphic into a new mod-owned tile definition (own `.tiles`/texture pack entry, own tile index) with the same visual appearance but no `ISO_TYPE`/`CONTAINER` properties.
- [ ] Point `entity_ChurningMachine.txt`'s `SpriteConfig.row` at the new mod-owned tile instead of `appliances_laundry_01_0`.
- [ ] Re-copy and re-test: confirm the Wash Menu and wrong name are gone, and determine whether the 20-encumbrance inventory Phase 4 now depends on disappears (since it was the *real* appliance's container, not ours) — if it disappears, Phase 4's plan revision needs to be revisited (see Notes and Risks) and an explicit `component ItemContainer`/equivalent will need to be added to the entity deliberately instead.
- [ ] If NOT confirmed: the wrong name/Wash Menu need a different investigation entirely — this hypothesis would be ruled out, not just postponed.

#### Part B — "Add Liquid from Item" missing (DEFERRED to DC 11 — direct decision, 2026-09-13)

**Deferred by direct decision (2026-09-13):** after all three candidate causes below were investigated and ruled out without finding the real one, Ed decided to defer this specific functionality to DC 11, using **"Transfer Liquid"** as a workaround in the meantime — it can pour milk into the Churning Machine in place of "Add Liquid from Item", just with a clunkier interaction (opens the fluid-transfer UI instead of a direct one-click submenu pick). Explicitly **not ideal**, accepted as a temporary substitute, not a fix. This deferral is separate from, and was decided independently of, Part A's deferral — the two are not being bundled (see the Process Note at the top of this document for why that distinction matters).

- [ ] **"Add Liquid from Item" does not appear at all**, even though the object is confirmed to be in the same `fluidcontainer` list that produces the working "Container Info"/"Transfer Liquid"/"Fill"/"Empty" options, and `addFluidFromItem()` is called unconditionally right alongside `doFluidContainerMenu()` for every object in that list (`ISWorldObjectContextMenuLogic.java:919-934`). This has its own cause, separate from Part A, not yet identified. **Deferred to DC 11 — workaround: use "Transfer Liquid" instead.**
- [x] Investigate `addFluidFromItem()`'s own gating conditions (`ISWorldObjectContextMenuLogic.java:4287-4357`, `FluidContainer.java`) as candidate causes:
  - **Ruled out: `isFluidInputLocked()`.** Traced `IsoObject.isFluidInputLocked()` → `FluidContainer.isInputLocked()` → the field defaults to `false` (`FluidContainerScript.java:57`) and is only ever set `true` if the entity script explicitly declares `InputLocked = true` — `entity_ChurningMachine.txt` never does. Not the cause.
  - **Not ruled out: the container-full gate.** `addFluidFromItem()` only builds the submenu at all when `pourFluidInto.getFluidAmount() < pourFluidInto.getFluidCapacity()` — if the Churning Machine's 20L container was already full at the moment "Add Liquid from Item" was checked (e.g. from an earlier Phase 3 test, such as Fill/Transfer), the option would correctly not appear, and this wouldn't be a bug at all.
  - **Not ruled out: no compatible item in inventory at test time.** `FluidContainer.CanTransfer()` requires every fluid in the held item to pass `canAddFluid()` — i.e. be `CowMilk`, per our whitelist. If the specific item tested for this check didn't actually contain `CowMilk` (e.g. it was the Sheep's Milk item used for the separate restriction test, or an empty/water-only container), the option correctly wouldn't show for *that* item — also not a bug, just the restriction working as designed.
  - **Answered by Ed (2026-09-13): yes to both** — the container was below 20L, and the item held actual Cow's Milk. Both the container-full and wrong-item-type explanations are ruled out.
  - **Followed up by checking vanilla milk items directly** (`media42_20_4/scripts/generated/items/normal.txt:6039-6059`, item `Milk`): a standard milk carton is a proper `component FluidContainer` (`Capacity = 1.0`, `Fluids { fluid = CowMilk:1.0 }`), not an old-style Drainable item — so `canStoreWater()` (`hasComponent(ComponentType.FluidContainer)`) is `true` for it, ruling out a hypothesis that milk items aren't real `FluidContainer` items. No `InputLocked`/`CanEmpty` override is set on it either, so both default to the same permissive values already traced.
  - **All three original candidate causes are now ruled out.** The actual cause is still unidentified. `addFluidFromItem()` is added as a nested option *inside* the object's own named submenu (the same submenu that holds "Container Info"/"Transfer Liquid"/"Fill"/"Empty" — it is not a separate top-level right-click entry). **Needs confirming with Ed:** was "Add Liquid from Item" checked for by opening into that same named submenu (where Container Info etc. were found working), or expected as a separate top-level menu option? If it was checked in the right place and is still genuinely absent, this cannot be resolved from static code reading alone anymore and needs a live diagnostic (a temporary Lua print hooked to `Events.OnFillWorldObjectContextMenu`, tracing exactly what `fetch.fluidcontainer` contains and what `addFluidFromItem` actually decides, the same pattern `PseudoButterChurner` DevCycle 2 used repeatedly once static reading stopped predicting real behavior).
- [ ] Re-verify Phase 3's "Add Liquid from Item" check once a cause is found and addressed — independent of Part A's timeline.

**Technical Notes:**

---

## Notes and Risks

- No "Turn On" action, no cycle logic, and no fullness/butter mechanic belong in this cycle — those are Steps 5-9, each getting their own DevCycle.
- The `CowMilk`-only restriction is deliberate and settled, not a placeholder — Sheep's Milk support is explicitly Step 11+ work, per `PseudoChurningMachineIdea.txt` and `PseudoChurningMachinePlan.md`. When Sheep's Milk is added later, this restriction will need to be widened (e.g. to a two-fluid whitelist) rather than removed outright.
- **Phase 4's plan revision (inventory instead of fullness) is provisional until Phase 5 Part A is actually investigated.** The 20-encumbrance inventory it depends on is *suspected* (per Phase 5 Part A's unconfirmed hypothesis) to belong to the *real* vanilla appliance object the tile may be getting reclassified into, not to anything `Pseudonymous.ChurningMachine` itself declares. Since Part A's investigation is deferred until after Step 11, this mod will likely keep working (and looking, mostly) like a real washer/dryer, inventory included, until then — which is exactly why the inventory-based design still works for now. **If Part A's hypothesis is later confirmed and fixed (a mod-owned tile with none of the vanilla properties), that inventory will very likely disappear along with the Wash Menu and wrong name**, and Steps 7+ (which by then may already be built assuming this free inventory) will need an explicit `component ItemContainer`/equivalent added deliberately to keep working. Any DevCycle for Steps 5-10 built before Part A's investigation should treat this as a known, called-out risk, not a surprise later.
- Phase 5 Part A's proposed fix (a mod-owned copy of the washer/dryer graphic) — if its hypothesis is confirmed — is asset work, not a script change: a new texture pack entry/tile definition, unlike every other fix so far in this mod. Investigation and fix both deferred until after Step 11 by direct decision (2026-09-12); tracked in `PseudoChurningMachinePlan.md`'s Deferred/Out of Scope section.
- **Phase 5 Part B ("Add Liquid from Item" missing) is now also deferred, to DC 11, by a separate direct decision (2026-09-13)** made after three candidate causes were investigated and ruled out. The workaround is "Transfer Liquid," which works but is a clunkier interaction — explicitly accepted as not ideal, not as a fix.

---

## Completion Summary

**Completion Date:** 2026-09-13
**Closed by explicit direction from Ed**, after both remaining gaps were each separately, explicitly deferred by him (not decided unilaterally — see the Process Note at the top of this document for why that distinction matters this time).
**Phases Completed:** 1-4 fully done. Phase 5 splits into two parts, both deferred rather than fixed:
- **Part A** (wrong displayed name, unwanted Wash Menu) — deferred until after Step 11 (2026-09-12); requires asset work (a mod-owned texture pack/tile) Ed doesn't want to do right now. Root cause is a strong, code-backed hypothesis, not directly confirmed.
- **Part B** ("Add Liquid from Item" missing) — deferred to DC 11 (2026-09-13), a separate decision made after three candidate causes were investigated and individually ruled out without finding the real one. Workaround: use "Transfer Liquid" instead — functional, but clunkier than a direct one-click pour would have been.

This cycle's own Desired Outcome (all five fluid interactions working, correct displayed name, no unintended menu items) is **not fully met** — 3 of 9 Phase 3 checks failed and remain failing. The cycle is closing anyway because Ed explicitly chose to accept that gap now, not because the gap was resolved.

**Accomplishments:**
- The `ChurningMachine` entity has a working 20L `FluidContainer`, restricted to `CowMilk` only (verified: whitelist correctly omits non-`CowMilk` items, and the container caps at 20L).
- Four of the five target vanilla interactions confirmed working in-game: "Container Info", "Transfer Liquid", "Fill", "Empty".
- Developed a leading, code-backed hypothesis for the wrong displayed name and unwanted Wash Menu (plus the bonus 20-encumbrance inventory) sharing one mechanism — confirmed to exist in code, not yet confirmed to apply to this specific tile.
- Ruled out three candidate causes for "Add Liquid from Item" missing (input lock, container-full, wrong item type) without finding the real one.
- `PseudoChurningMachinePlan.md` revised to replace the originally-planned fullness/percentage mechanic (Steps 7-9) with direct-to-inventory butter placement, using the (currently vanilla-appliance-owned, not yet our own) 20-encumbrance container — flagged in that document and here as provisional pending Part A.

**Metrics:**
- Files changed: `entity_ChurningMachine.txt` (added `FluidContainer`), new `Fluids.json` translation file.
- 9 Phase 3 verification checks: 6 passed, 3 failed — all 3 now have their fixes deferred (2 to after Step 11, 1 to DC 11), not resolved.

**Lessons / Notes:**
- Reusing a literal vanilla sprite/tile for a custom entity is riskier than the sprite-*declaration* collision `PseudoButterChurner` hit in its own DevCycle 2 — that was a load-time naming collision fixable by picking a different index; this is a runtime object-*identity* takeover baked into the tile's own properties, which no `SpriteConfig` field can opt out of. Worth remembering for any future entity that's tempted to reuse a real vanilla appliance/fixture graphic directly: check whether that tile is tied to a hardcoded `IsoObjectType`/`ISO_TYPE`/`CONTAINER` property in `CellLoader.java` before assuming "same picture" is purely cosmetic.
- The plan's inventory-based butter design (Phase 4) is currently riding on borrowed, not owned, functionality — it works today only because the object is secretly a real washer/dryer. This is explicitly flagged so Steps 5-10 aren't built assuming a free inventory that will need to be replaced with a real one once Phase 5 Part A's deferred fix eventually lands.
- Don't bundle multiple failures into one "phase" just because one of them has a confirmed shared cause — Phase 5 originally lumped all three Phase 3 failures together, which led directly to treating Ed's deferral of *one* of them as covering all three. See the Process Note at the top of this document.
- Don't close a DevCycle unilaterally, and don't infer a broad deferral from one specific decision — this cycle was mistakenly closed once already on exactly that error, reopened, and is only closing now because Ed explicitly reviewed both remaining gaps separately and said to close it.
- `CONTAINER`/`ISO_TYPE` tile properties are generic keys with many possible values (`barbecue`, `fireplace`, `campfire`, `woodstove`, `microwave`, `clothingwasher`, `clothingdryer`, etc.) — don't describe a property key itself as "the washer marker" when it's really the specific value assigned to it that would matter, and don't claim a specific tile carries a specific value without having actually read that tile's data.
