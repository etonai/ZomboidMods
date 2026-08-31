# DevCycle 002: Drying-Rack-Style Automatic Butter Churner

**Status:** Planning
**Start Date:** 2026-08-31
**Target Completion:** TBD
**Focus:** Fix the still-broken washing-machine → `AutoButterChurn` conversion carried over from DevCycle 1, and rebuild the churner's fill/production mechanic around the `Resources` + `DryingCraftLogic` pattern investigated in `doc/ideas/claude_dryingRackSimilarity.md`, with a fixed 20 L / 5-minute / 4-stick production cycle.

---

## Goal

DevCycle 1 closed with two unresolved problems, in this priority order:

1. **The washing-machine-to-`AutoButterChurn` conversion itself is still broken.** DC1 Phase 17 reported "did not work" with no captured diagnostic detail — it's unknown whether the conversion timed action fails, the entity fails to appear, or something else entirely. This needs to be root-caused and fixed before anything else in this cycle can be verified in-game, since every other task depends on being able to actually produce an `AutoButterChurn` entity to test against.
2. **The milk-fill and production mechanic needs to be rebuilt** around the pattern worked out in `doc/ideas/claude_dryingRackSimilarity.md`: the churner's menu/interaction should work like the vanilla drying racks — a `component Resources` fluid input slot filled through the entity's own crafting-style window (`ISEntityWindow`, drag a milk-holding item onto the slot), driven by `component DryingCraftLogic` with `StartMode = Automatic` — **not** the trough/rain-barrel "simple pour" interaction DC1 Phase 17 chased and failed to get working alongside automatic batching.

This cycle also fixes the production numbers to a specific, user-specified target: **the entire conversion of a full 20 L tank into 4 sticks of butter should take 5 minutes of game time.**

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can:

1. Right-click a placed, empty, powered-off Washing Machine and select "Convert to Automatic Butter Churner" (screwdriver kept, Electrical ≥ 5, as DC1 implemented) — **and this time the conversion is confirmed to actually complete and leave a working `AutoButterChurn` entity in the washing machine's place.**
2. Interact with the placed `AutoButterChurn` entity and get the same kind of crafting-style window a `Drying_Rack` opens (`ISEntityWindow`) — not a context-menu Turn On/Off toggle, not a trough-style pour prompt.
3. Drag a milk-holding item (Cow Milk and/or Sheep Milk) onto the entity's input slot, up to a 20 L capacity, same drag-to-fill interaction as loading a drying rack with crops.
4. Start it (`StartMode = Automatic` semantics — start once, it keeps going) and watch it consume milk in 5 L increments, producing 1 Butter per increment, automatically repeating with no further player interaction, until either the tank empties or the output slot is full.
5. Confirm the timing: **a full 20 L tank (4 batches of 5 L → 1 Butter each) completes in 5 minutes of game time at the 20°C baseline** — i.e. 75 seconds per 5 L batch (300 seconds ÷ 4 batches), understanding that `DryingCraftLogic`'s temperature/wetness pacing (per `claudeDocs/claude_dryingAnalysis.md` §4) means this is a baseline, not a hard duration — colder or rained-on (if left outside) will run slower.

---

## Tasks

### Phase 1: Root-Cause and Fix the Washing-Machine Conversion

**Status:** Planning

- [ ] Re-attempt the conversion in-game with diagnostic logging restored/added at each step of `ISConvertToAutoButterChurn.lua`'s `:complete()` (the DC1 diagnostic file `client/AutoButterChurnEntityDiagnostic.lua` is still present per DC1's file manifest — confirm it's still wired in, or reintroduce equivalent logging) to determine exactly which of these fails:
  - The context-menu option fails to appear or fails validity checks.
  - The timed action starts but `square:RemoveTileObject(...)` / entity removal fails.
  - `square:addWorkstationEntity(...)` fails to place the new entity at all.
  - The entity is placed but is invisible, mis-sprited, or otherwise not the problem (DC1 Phases 6–16 already solved a sprite-visibility issue once — confirm this isn't a regression of the same root cause: a "registered but blank" sprite slot).
  - The entity appears but interacting with it does not open the expected window (this may now be moot once Phase 2 replaces the entity's component makeup entirely — see below — but still worth isolating whether the *conversion* succeeded independent of what happens next).
- [ ] Fix whatever the diagnostic isolates. Keep the diagnostic logging in place until the fix is confirmed working in-game (per this project's standing practice — DC1 Phase 15's lesson, re-affirmed in DC1's Completion Summary).
- [ ] Once conversion is confirmed reliably producing a placed `AutoButterChurn` entity, this phase's remaining work is done — the entity's internal behavior (fill/production mechanic) is Phase 2/3's concern, not this phase's.

**Technical Notes:**
DC1 closed without knowing which part of Phase 17 failed. Do not assume the conversion flow itself (Phase 2 of DC1: context-menu gate, `ISConvertToAutoButterChurn.lua`, `addWorkstationEntity` call) is the broken part just because Phase 17's *entity redesign* landed in the same cycle — DC1 Phases 1–16 had already gotten a placed, visible, converted entity working before Phase 17 touched the entity's internals. It's equally possible the conversion mechanism itself still works fine and the failure is entirely inside Phase 17's new `component FluidContainer` design (which Phase 2 of this cycle replaces anyway). Isolate before fixing.

### Phase 2: Rebuild the Entity Around `Resources` + `DryingCraftLogic`

**Status:** Planning

- [ ] Rewrite `entity_AutoButterChurn.txt` to drop DC1 Phase 17's `component FluidContainer` + `component UiConfig{uiEnabled=false}` design entirely, replacing it with the pattern from `doc/ideas/claude_dryingRackSimilarity.md`:
  - `component UiConfig` with `uiEnabled = true` and a real `LuaWindowClass = ISEntityWindow` xuiSkin entry (DC1 Phase 17 identified the missing-xuiSkin bug that caused the wrong crafting window to appear — the fix going forward is to give this entity its *own* correct window, not to disable windows altogether).
  - `component Resources` with a `churn_inputs` group holding a `Fluid@Input@20` entry (20 L capacity, matching the 20 L target in this cycle's goal) and a `churn_outputs` group holding an `Item@Output@N@StackAny` entry (capacity to comfortably hold at least 4 Butter per full-tank cycle, matching the drying racks' output-slot sizing convention).
  - `component DryingCraftLogic` (not bare `component CraftLogic` — see `claude_dryingRackSimilarity.md`'s reasoning: `DryingCraftLogic` is proven by 12 shipped recipes, bare `CraftLogic` is used by none), with `StartMode = Automatic`, `inputGroup = churn_inputs`, `outputGroup = churn_outputs`.
  - `component SpriteOverlayConfig` with a `Churning`-style set of progress-tier sprites (0/50/100%), mirroring the drying racks' visual-feedback pattern — placeholder art acceptable this cycle (see Notes and Risks; DC1 already flagged custom art as outstanding).
- [ ] Add a named `fluidFilter` script object restricting the input to `CowMilk`/`SheepMilk` (the `ResourceFluid`/`ResourceBlueprint` filter mechanism confirmed in `claude_dryingRackSimilarity.md`), referenced from the `Fluid@Input@20` entry — reintroducing the DC1 Phase 1 approach that Phase 17 had abandoned, now on confirmed footing.
- [ ] Delete/retire whatever remains of DC1 Phase 17's `component FluidContainer` block and its associated `uiEnabled = false` xuiSkin entry once the replacement is in place.
- [ ] Confirm in-game that dragging a milk-holding item onto the entity's input slot in its `ISEntityWindow` actually drains it into the `Fluid@Input@20` resource (this exercises `ResourceFluid.canDrainFromItem()`/`drainFromItem()`, which per `claude_dryingRackSimilarity.md` is engine-confirmed but not exercised by any shipped entity in this build — first real-world test of this specific path).

**Technical Notes:**
Reference: `doc/ideas/claude_dryingRackSimilarity.md`, entire document — this phase is that document's proposed entity sketch, adjusted for the 20 L / 4-batch numbers below instead of the document's illustrative 5 L single-batch sketch.

### Phase 3: Recipe — 20 L Tank, 5-Minute Full Cycle, 4 Butter

**Status:** Planning

- [ ] Create the `AutoButterChurn` `craftRecipe` (replacing DC1's deleted `auto_churn_butter`): `Tags = AutoButterChurn`, `overlayStyle = Churning`, `inputs { fluid 5.0 [CowMilk;SheepMilk] mode:mixture, }`, `outputs { item 1 Base.Butter, }`.
- [ ] Set `time = 75`. Derivation: the user's target is a full 20 L tank (4 batches of 5 L, since the input slot is capped at 20 L and each batch fixed-consumes 5 L) completing in 5 minutes (300 seconds) of game time total, at the `DryingCraftLogic` 20°C baseline. 300 seconds ÷ 4 batches = 75 seconds per batch. Confirm this arithmetic against `StartMode = Automatic`'s actual re-trigger behavior in Phase 4 — back-to-back batches should not have any gap/delay beyond the 75 s craft time itself, otherwise the 5-minute total will run long.
- [ ] Note and accept the `DryingCraftLogic` temperature/wetness pacing consequence (per `claudeDocs/claude_dryingAnalysis.md` §4): `time = 75` is a 20°C baseline, not a hard duration — below 20°C the multiplier drops below 1.0x (quadratically, reaching 0x at ≤0°C) and a rained-on outdoor churner pauses entirely while wet. This is an accepted, documented tradeoff of reusing `DryingCraftLogic` rather than bare `CraftLogic` (see Phase 2) — flagged here so it isn't mistaken for a bug during Phase 4 verification if a cold or rainy test run measures longer than 5 minutes.
- [ ] Confirm the output slot capacity chosen in Phase 2 (`Item@Output@N@StackAny`) is large enough that a full 4-batch run never stalls on output-full pausing before the tank empties.

**Technical Notes:**
The "5 L increments" framing carries over unchanged from the ideas doc — this phase differs from that doc's illustrative sketch only in tank size (20 L vs. the doc's minimal 5 L example) and per-batch `time` (75 s, derived from the 5-minute/4-batch target, vs. the doc's undecided "few minutes" placeholder anchored on vanilla's 500 s `churn_butter`). `StartMode = Automatic` re-triggering on a partially-drained tank (per `claude_dryingRackSimilarity.md`'s "20 L tank → four batches" alternative) is what turns one 20 L fill into four consecutive 75 s batches rather than needing a variable-batch recipe.

### Phase 4: In-Game Verification

**Status:** Planning

- [ ] Confirm the mod loads with no script parse errors after Phases 1–3's changes.
- [ ] Confirm the washing-machine conversion (Phase 1's fix) reliably produces a working `AutoButterChurn` entity.
- [ ] Confirm interacting with the entity opens the drying-rack-style `ISEntityWindow`, not a bespoke context-menu toggle and not a trough-style pour prompt.
- [ ] Confirm dragging a milk item onto the input slot fills it, up to 20 L, and rejects non-milk fluids (via the Phase 2 `fluidFilter`).
- [ ] Confirm starting the entity with a full 20 L tank produces exactly 4 Butter over four automatic 5 L batches, with no player interaction between batches, and measure the actual elapsed game time against the 5-minute target (accounting for the temperature caveat in Phase 3).
- [ ] Confirm power loss (DC1 Phase 3's `AutoButterChurnCode.checkPower` hook — still needed, unchanged by this cycle's other changes) still correctly halts an in-progress batch.
- [ ] Confirm output-full pausing behavior (no custom Lua needed, per `CraftLogic`'s generic free-output-slot gating, as DC1 Phase 1 already found) still holds with the new `Resources` shape.

---

## Notes and Risks

- **This cycle depends on Phase 1 succeeding first.** Every later phase needs a real, converted `AutoButterChurn` entity in-game to test against — if the conversion root cause turns out to be something structural (not yet identified), later phases may need to be revisited.
- **Carried over from DC1, still unresolved, not in scope for this cycle:** Q6 (schematic/magazine recipe-learn requirement — currently skill-gate only), Q7/Phase 4 of DC1 (churn sound — entity is still silent), Q8 (power draw amount — only an on/off `haveElectricity()` check exists, no generator fuel consumption), and real custom sprite art (still using placeholder tile rows).
- **New risk this cycle:** `Fluid@Input` inside `component Resources` is, per `claude_dryingRackSimilarity.md`, confirmed in engine code (`ResourceType.Fluid`, `ResourceFluid`, `ResourceBlueprint`'s parser) but not exercised by any shipped vanilla entity — this cycle is the first real-world test of that specific path, same category of risk DC1 already took (successfully) on bare `component CraftLogic` before pivoting away from it.
- **DC1's Phase 17 entity design (`component FluidContainer`, `uiEnabled = false`) is being fully superseded, not patched.** Phase 2 above replaces it outright rather than debugging it further, per the reasoning in `claude_dryingRackSimilarity.md` (the pour-UX/automation conflict was structural, not a bug to fix within that design).
- Diagnostic logging should stay in place through Phase 4 and only be removed after the user confirms the full flow works end-to-end, consistent with `feedback_dont_remove_diagnostics_before_confirmed_fix` project guidance.
