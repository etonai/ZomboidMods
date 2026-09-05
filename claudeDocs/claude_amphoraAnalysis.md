# Amphora Analysis

**Created:** 2026-08-30
**Updated:** 2026-08-30 — re-verified against Project Zomboid 42.20.4
**Game Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media/`). Originally analyzed against 42.19; no functional differences were found for anything documented here — only source directory references were updated.

## Summary

The Amphora is a player-built, clay/pottery, large-capacity **fluid storage container**
(300 units). Unlike the [Butter Churn](claude_butterChurn.md), it hosts no passive
crafting-bench recipe at all — it does not ferment, age, or convert any liquid over time.
Its only "mechanic" beyond being a fluid container is a lid that can be opened/closed,
which swaps it between two entity variants (`Amphora` / `AmphoraClosed`) and changes how
fast it collects rainwater.

## Code Locations

| Purpose | File |
|---|---|
| Entity definitions (`Amphora`, `AmphoraClosed`) — build recipe, fluid container, sprites | `media/scripts/generated/entities/outdoors/entity_amphora.txt` |
| xuiSkin (icon / display name binding, hand-authored source) | `media/scripts/entities/outdoors/entity_amphora_xuiSkin.txt` |
| Lid toggle context-menu entry point | `media/lua/client/ContextMenuCode.lua` (`OpenCloseAmphoraLid`, line 129) |
| Lid toggle timed action (duration, entity swap, fluid transfer) | `media/lua/shared/TimedActions/ISOpenCloseLid.lua` |
| Tile material metadata (for scrapping/interaction) | `media/lua/shared/Util/CustomTileProps.lua` (line 160-ish) |
| UI strings (display name, tooltip) | `media/lua/shared/Translate/EN/Recipes.json` (lines 1178, 1182), `media/lua/shared/Translate/EN/Tooltip.json` (line 70), `media/lua/shared/Translate/EN/Fluids.json` (line 63) |
| `time` field → skill-scaled build duration | `zombie42_20_4/scripting/entity/components/crafting/CraftRecipe.java` (`getTime()` / `getTime(character)`) |
| Build recipe → player timed-action wiring | `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua` (line 914: `o.maxTime = o.craftRecipe:getTime()`) |
| `RainFactor` → rain-collection rate field | `zombie42_20_4/scripting/entity/components/fluids/FluidContainerScript.java` (line 169-170, stored as `rainCatcher`) |

## Entity Definitions

`media/scripts/generated/entities/outdoors/entity_amphora.txt` defines **two** entities that
represent the same physical object in its two lid states:

```
entity Amphora            // lid open
{
    component ContextMenuConfig { contextEntry { menu = CloseLid, ... } }
    component FluidContainer
    {
        ContainerName = Amphora,
        Capacity = 300.0,
        RainFactor = 0.4,
        InitialPercentMin = 0.0,
        InitialPercentMax = 0.0,
    }
    component CraftRecipe       // <-- BUILD recipe for the amphora itself
    {
        timedAction = BuildLowNoTool,
        time = 50,
        category = Pottery,
        Tooltip = Tooltip_craft_amphoraDesc,
        inputs
        {
            item 1 tags[base:masonstrowel] mode:keep flags[Prop1;MayDegradeLight],
            item 10 [Base.Clay] flags[DontRecordInput],
        }
    }
}

entity AmphoraClosed      // lid closed
{
    component ContextMenuConfig { contextEntry { menu = OpenLid, ... } }
    component FluidContainer
    {
        ContainerName = Amphora,
        Capacity = 300.0,
        RainFactor = 0.0,
        InitialPercentMin = 0.0,
        InitialPercentMax = 0.0,
    }
    // no CraftRecipe block — you cannot build it directly with a lid already on;
    // it only exists as the result of closing an open Amphora
}
```

Note there is **no `CraftBench`/`Recipes = ...` tag** on either entity, unlike `ChurnBucket`
(`Recipes = ChurnBucket`). That absence is the key structural fact: nothing in the recipe
scripts (`media/scripts/generated/...`) references an `Amphora` tag as a recipe target, so
no bench-hosted, passive, over-time crafting process (like `churn_butter`) is ever attached
to this entity. It is pure storage.

## Building the Amphora

Like the Churn Bucket, the Amphora is built via the entity's own `component CraftRecipe`
block — a normal player **timed-action** craft, not the passive bench system:

- Tool: a masonry trowel (`tags[base:masonstrowel]`, kept, may degrade lightly)
- Materials: 10x `Base.Clay` (consumed, `DontRecordInput` so it's not shown as a
  "known ingredient" hint)
- Category: `Pottery`
- `timedAction = BuildLowNoTool` (see `media/scripts/generated/timedactions.txt:746` —
  `metabolics = HeavyWork`, animation `Tying_Low`, sound `BuildingGeneric`); this
  timed-action type itself defines no fixed `time`, so the actual duration comes from the
  recipe's own `time = 50`.
- `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua:914` wires this up:
  `o.maxTime = o.craftRecipe:getTime()` — the same skill-scalable `time` field used by
  every other player-built entity (including the Churn Bucket's own `time = 50` build
  recipe). This is the ordinary character build-action duration system (scaled by the
  player's relevant skill via `CraftRecipe.getTime(IsoGameCharacter)`,
  `zombie42_20_4/scripting/entity/components/crafting/CraftRecipe.java:199-207`), and is a
  different unit/system from the "game-seconds" bench-tick timing used by passive recipes
  like `churn_butter` — see the Butter Churn analysis for that mechanism.

## Storage Behavior (Capacity 300)

`FluidContainer` capacity is 300 units either way (open or closed) — this doesn't change
with lid state. What does change is `RainFactor`, parsed into the `rainCatcher` field in
`zombie42_20_4/scripting/entity/components/fluids/FluidContainerScript.java:169-170`:

- Open (`Amphora`): `RainFactor = 0.4` — the amphora passively collects rainwater while its
  lid is off.
- Closed (`AmphoraClosed`): `RainFactor = 0.0` — sealed, no rain intake (and presumably no
  evaporation/contamination either, though that wasn't traced further in this pass).

## Opening/Closing the Lid

The lid toggle is a context-menu action (`ContextMenuCode.OpenCloseAmphoraLid`,
`media/lua/client/ContextMenuCode.lua:129`) that queues `ISOpenCloseLid`
(`media/lua/shared/TimedActions/ISOpenCloseLid.lua`):

- **Duration:** `getDuration()` returns `15` (or `1` if the character has "instant timed
  actions" on) — this is a normal `ISBaseTimedAction` tick count, the same short-duration
  category as other simple "Loot"-animation interactions (comparable to opening a container
  lid elsewhere in the game); it is not meaningfully comparable to the Butter Churn's
  in-game-seconds bench timer.
- **What happens on completion** (`ISOpenCloseLid:complete()`): the sprite is swapped
  (`crafted_04_32` ↔ `crafted_04_33` for the south face, `crafted_04_34` ↔ `crafted_04_35`
  for the east face — matching the two `SpriteConfig` rows in the entity definitions above),
  the old entity (`Amphora` or `AmphoraClosed`) is removed from the square and replaced with
  the other one via `addWorkstationEntity`, and its fluid contents are explicitly copied
  across (`newbarrel:getFluidContainer():copyFluidsFrom(tempCont)`) so liquid isn't lost when
  toggling the lid. Health/max-health are also carried over.

## Comparison to the Butter Churn

| | Butter Churn (`ChurnBucket`) | Amphora |
|---|---|---|
| Built via | Player timed action (`time=50`, Woodwork) | Player timed action (`time=50`, Pottery) |
| Hosts a `CraftBench` recipe? | Yes — `Recipes = ChurnBucket` tag, matched by `churn_butter` recipe | No |
| Passive over-time process? | Yes — `churn_butter` (milk → butter, `time=500` in-game seconds via `CraftLogicSystem`) | None |
| Fluid container? | No (it's a bench, not a `FluidContainer`) | Yes — 300 capacity |
| Notable secondary mechanic | N/A | Openable lid (state-swap entity, rain-catching only while open) |

## Caveats / Uncertainties

- Whether the Amphora is used as an input/output *container* by some other recipe
  elsewhere (e.g., a fermentation or aging recipe that targets fluid stored in an Amphora
  specifically, rather than tagging the Amphora entity itself as a bench) was not
  exhaustively ruled out — only recipes referencing the entity/tag `Amphora` directly were
  searched for, and none were found in `media/scripts/generated`. A liquid-based recipe that
  simply accepts "any fluid container" as an input could still use an Amphora as its
  vessel without ever naming it.
- Rain-collection rate (`RainFactor = 0.4`) was confirmed to be parsed into a `rainCatcher`
  field, but the actual formula converting that factor plus precipitation intensity into
  fluid gained per tick was not traced in this pass (see `DryingCraftLogic.java` for a
  similar, already-traced rain-intensity formula used elsewhere, as a likely analogous
  pattern).

## Verified Against `media42_20_4/`

**Checked:** 2026-09-05

All three code paths this analysis depends on were diffed byte-for-byte between `media/`
(v42.19) and `media42_20_4/` (v42.20.4) and found **identical**, so every finding above
applies unchanged to the 42.20.4 build:

- `media{,42_20_4}/scripts/generated/entities/outdoors/entity_amphora.txt`
- `media{,42_20_4}/lua/shared/TimedActions/ISOpenCloseLid.lua`
- `media{,42_20_4}/lua/client/ContextMenuCode.lua`

No functional or structural changes to the Amphora, its lid mechanic, or its storage
behavior between these two builds.

## The Lid Mechanic as a Reusable Modding Pattern

The Amphora's "container that can be sealed/unsealed" behavior is not bespoke code — it's
a small, fully generic pattern built from three pieces that any modded entity can reuse:

### 1. Two entities, one identity, name-convention-linked

`Amphora` and `AmphoraClosed` are two independent `entity` blocks with their own
`FluidContainer`, `SpriteConfig`, and `ContextMenuConfig`, but they're never explicitly
cross-referenced by ID anywhere in script data. The link is a **pure string convention**,
resolved entirely at runtime in `ISOpenCloseLid:complete()`
(`media42_20_4/lua/shared/TimedActions/ISOpenCloseLid.lua:33-41`):

```lua
local name = self.barrel:getEntityScript():getName();
local newName;
if luautils.stringEnds(name, "Closed") then
    newName = string.gsub(name, "Closed", "");
else
    newName = name .. "Closed";
end
```

This means the toggle logic is entirely generic: **any** entity pair named `Foo` /
`FooClosed` gets working open/close behavior for free, with no Lua changes — only two
`entity` blocks in script data and one `ContextMenuConfig.contextEntry` per state. Nothing
about this function is Amphora-specific.

### 2. The swap is a full entity replacement, not a state flag

`ISOpenCloseLid:complete()` (lines 33-61) doesn't flip a boolean on the existing entity —
it removes the old one from the square (`RemoveTileObject`) and creates the other one fresh
(`self.square:addWorkstationEntity(newName, self.sprite)`), then manually carries over the
two pieces of state that would otherwise be lost:

- **Fluid contents**: `copy()` the old `FluidContainer` before removal, `copyFluidsFrom()`
  into the new entity's `FluidContainer` after creation (only if the entity actually has one
  — `hasComponent(ComponentType.FluidContainer)` guards both sides, so this same action
  works unmodified on non-fluid entities too).
- **Health**: `getHealth()`/`getMaxHealth()` read before removal, `setHealth()`/
  `setMaxHealth()` applied to the new entity after creation.

Any other per-instance state (mod data, custom component values, item contents of a
non-fluid `ItemContainer`, etc.) is **not** carried over automatically — a mod reusing this
pattern for a container type with its own extra state would need to extend `complete()`
(or fork it) to copy that state across the swap the same way health and fluids are copied.

### 3. Two call sites: entity-specific vs. fully generic

`ContextMenuCode.lua` actually ships **two** functions for this, and the Amphora
deliberately uses the more specific one:

- `ContextMenuCode.OpenCloseLid(context, entity, character, sprite)` (line 146) — fully
  generic: just walks to the entity and queues `ISOpenCloseLid` with whatever `sprite`
  string it's given. This is the one to call directly from a new entity's
  `ContextMenuConfig.contextEntry.customFunction` for a from-scratch mod, since it requires
  no per-entity Lua at all — the sprite name is passed straight through from script data.
- `ContextMenuCode.OpenCloseAmphoraLid(context, entity, character, param)` (line 129) — an
  Amphora-specific wrapper that hardcodes the four known Amphora sprite row names
  (`crafted_04_32/33/34/35`) and picks the correct target sprite based on the entity's
  *current* sprite before delegating to the same `ISOpenCloseLid` action. This extra layer
  exists only because the Amphora's `SpriteConfig` uses face-specific rows (`S` vs `E`) that
  differ between the open/closed sprite pairs, so a plain "toggle sprite by name suffix"
  can't infer the right row — the wrapper's `if/elseif` chain is standing in for that
  missing convention.

**Takeaway for modding:** a new sealable container (e.g., a lidded crock, a corked jug, a
capped fuel drum) can get this whole mechanic by: (1) defining two entities named `Foo`/
`FooClosed` each with matching `FluidContainer`/`ItemContainer` blocks and a
`ContextMenuConfig.contextEntry` pointing at `menu = CloseLid`/`OpenLid` respectively, and
(2) wiring `customFunction` to the generic `ContextMenuCode.OpenCloseLid` (passing the
target sprite name as `param`) if the sprite swap is a simple 1:1 row substitution, or to a
small Amphora-style wrapper only if face-dependent sprite rows make the swap ambiguous. No
new timed-action code is needed in either case — `ISOpenCloseLid` already handles the
entity replacement, fluid-content preservation, and health preservation generically.
