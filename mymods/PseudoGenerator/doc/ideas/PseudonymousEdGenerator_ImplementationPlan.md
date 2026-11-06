# Naquadah Generator – General Implementation Plan

**Created:** 2026-11-05
**Source idea:** `PseudonymousEdGenerator.txt` (same folder)
**Status:** Idea-stage plan. This is not a DevCycle. DevCycles are created separately under `doc/planning/`.
**Engine checks against:** v42.20.4 (`zombie42_20_4/`, `media42_20_4/`)
**Mod scaffold:** `PseudoGenerator/42/mod.info` (id `PseudonymousEdGenerator`), empty `42/media/lua` and `common/media/lua`

---

## 1. Goal

A craftable and/or placeable generator, the "Naquadah Generator", that looks like the Blue Generator (`Generator_Blue`) and behaves like a normal generator, except that **every 10 in-game minutes the mod sets it back to full fuel and full condition and makes sure it is activated**. It is the visible version of the hidden generator that RV Life uses (see `claudeDocs/claude_RVLifeLessons.md` §4.1).

---

## 2. What the engine gives us (verified in v42.20.4)

| Fact | Source |
|---|---|
| A generator "type" is **derived from the object's sprite**. `IsoGenerator.getGeneratorItemType()` looks the sprite name up in a map built from every item script tagged `base:generator`, keyed by that item's `WorldObjectSprite`. If there is no match it falls back to `Base.Generator`. | `IsoGenerator.java:134-156` |
| Picking a generator up (`ISTakeGenerator:complete`) creates `instanceItem(generator:getGeneratorItemType())`, copies condition, and stores fuel in the item's modData `fuel`. | `shared/TimedActions/ISTakeGenerator.lua` |
| Placing a generator from a moveable sprite is **hard-coded by sprite name** in `ISMoveableSpriteProps`. `appliances_misc_01_12`–`15` create `Base.Generator_Blue`. | `shared/Moveables/ISMoveableSpriteProps.lua:2044-2046` |
| The `IsoGenerator` constructor copies `generatorFullType` (the item's full type) into the object's modData. | `IsoGenerator.java:131` |
| Fuel is clamped to 0–10 (`setFuel`), so "full fuel" is 10, not 100. | `IsoGenerator.java:512` |
| Fuel and condition drop based on **elapsed in-game hours since `lastHour`**, applied when the generator updates. If fuel or condition hit 0, the generator turns itself off. | `IsoGenerator.java:195-225` |
| Generator power reaches squares within `generatorTileRange` (horizontal) and `generatorVerticalPowerRange` (vertical) sandbox settings. | `IsoGenerator.java:111-123, 714-720` |
| The list of all live generators (`AllGenerators`) is **private and not exposed to Lua**. | `IsoGenerator.java:83` |
| Item scripts for the vanilla generators are in `scripts/generated/items/normal.txt`. `Generator_Blue` is weight 30, icon `Generator3`, sprite `appliances_misc_01_12`, `ConditionLowerChanceOneIn = 24`, sound radius 23. | `normal.txt:4827-4842` |

---

## 3. Key design decisions

### 3.1 How to make it a distinct thing (the main open question)

The mod needs to tell a Naquadah Generator apart from an ordinary Blue Generator. Because the type comes from the sprite (§2), the options are:

| Option | Idea | Pros | Cons |
|---|---|---|---|
| **A. New item, new sprite** | Define `Naquadah Generator` as a new item tagged `base:generator` with its own `WorldObjectSprite` (a new tile from a custom tile pack). | Cleanest. Pickup and placement round-trip correctly. | Needs a tilesheet and tile definitions (art work, extra files). Placement for a new sprite is not hard-coded in `ISMoveableSpriteProps`, so it needs checking and probably a small patch. |
| **B. New item, borrowed vanilla sprite** | Use an existing frame such as `appliances_misc_01_13`, `14` or `15` (Blue's other facings) as the new item's `WorldObjectSprite`. | No art. Looks like the Blue Generator. | Another frame of the same generator, so it may face the wrong way. Sprites `12`–`15` already map to Blue in `ISMoveableSpriteProps` and `MOGenerator`, so map-placed or moved generators would become Blue. The first-wins or last-wins behavior of the sprite→type map needs testing. |
| **C. Same item, modData flag** | Use the vanilla `Generator_Blue` and tag the placed `IsoGenerator` with modData such as `PseudoNaquadah = true`. | Smallest change. | Pickup returns a plain `Generator_Blue` (the flag is lost), so the flag would have to be carried by the item's modData and re-applied on placement. That needs hooks into both `ISTakeGenerator` and placement. |

**Working assumption for the first cut:** start with **Option B** to get the rest of the mod working with no art, and revisit once the sprite→type behavior is confirmed in game (see Question 1). The "looks like the Blue Generator" requirement in the idea document fits B and C. Nothing in the rest of the plan depends on which option wins, as long as the mod has a single function `isNaquadah(generator)`.

### 3.2 Finding the generators to refill

Because `AllGenerators` is private, the mod has to track generators itself. Approaches, in order of preference:

1. **Registry in global ModData** (e.g. `PseudoGenerator.registry`, a table of `x,y,z` keys). Add a square when a Naquadah Generator is placed. Remove it on pickup or destruction. Every 10 minutes, iterate the registry, fetch each square with `getCell():getGridSquare(x,y,z)`, call `square:getGenerator()`, and refill if present. Squares that are not loaded return nil and are skipped.
2. **Hook object creation and loading** (`Events.OnObjectAdded` or `LoadGridsquare`) to catch generators that appear by other routes (loaded from a save, moved, placed by another mod). This is more expensive per call, so it must filter cheaply.
3. **Full scan of loaded squares** every 10 minutes. It needs no bookkeeping but costs the most. This is a fallback only.

### 3.3 What the refill does

For each Naquadah Generator found, on the server (or in singleplayer):

```text
generator:setCondition(100)
generator:setFuel(10)        -- engine max; 100 would be clamped anyway
generator:setActivated(true)
```

Notes:
- `setActivated(true)` also starts the generator sound and, indoors, flags the building as toxic (`IsoGenerator.java:526-531`). This is vanilla behavior for a running generator, so a Naquadah Generator indoors would poison the air (see Question 4).
- The generator must also be **connected** (plugged in). The plan keeps the player-facing plug step, since the idea only says "activates it". RV Life also calls `setConnected(true)` (see Question 5).

### 3.4 Where the refill runs

- Register on `Events.EveryTenMinutes`, as the idea specifies.
- Run on the **server** (or singleplayer). Generators are server-authoritative in multiplayer, and the vanilla fuel and condition setters sync themselves when called on the server. RV Life's client-side creation is a pattern we should not copy.
- **Gap to cover:** fuel and condition are charged for *elapsed hours since the last update*, applied when the generator ticks. If a chunk was unloaded for many in-game hours and then loads, the generator could drain to zero (and shut itself off) before the next 10-minute event fires. Mitigation: also refill when a registered square loads, or when the registry sees the chunk come in (`LoadGridsquare` / `OnLoadMapZones`-style hook). Needs a test.

---

## 4. Planned components

```
PseudoGenerator/                              (mod folder)
├── 42/
│   ├── mod.info                              (already present; update description/poster later)
│   └── media/
│       ├── scripts/                          NaquadahGenerator item definition (+ recipe, see 4.2)
│       └── lua/
│           ├── shared/                       constants, isNaquadah(), registry helpers
│           └── server/                       10-minute refill, registry load/save
└── common/media/lua/...                      (only if we want non-B42 builds, probably unneeded)
```

### 4.1 Item script
A copy of the `Generator_Blue` definition (`normal.txt:4827-4842`) with:
- a new item id (e.g. `NaquadahGenerator`) and a display name;
- the same tag set, including `base:generator` so the sprite→type map picks it up;
- `WorldObjectSprite` per the §3.1 decision;
- `Icon`, weight, and sound values initially copied from Blue.

### 4.2 Acquiring it
The first cut will be debug/admin spawn only, so the mechanic can be tested before any acquisition design. A craft recipe (e.g. from a Blue Generator plus rare parts) or world loot is future work (see Question 3).

### 4.3 Refill logic (server)
- `NaquadahGenerator.isNaquadah(gen)`: compare `gen:getGeneratorItemType()` to the new item's full type (and/or check the modData flag if Option C).
- `NaquadahGenerator.refillAll()`: iterate the registry, apply §3.3, drop entries whose generator no longer exists.
- Persist the registry in ModData; sync to clients only if the UI ever needs it.

### 4.4 Placement and pickup
- Confirm the placement path for the new item (sprite lookup in `ISMoveableSpriteProps`, §2). If the new sprite does not create an `IsoGenerator`, patch that function or wrap it.
- Confirm that `ISTakeGenerator` returns the new item type (it should, via `getGeneratorItemType()`).
- Register and unregister coordinates at placement and pickup.

### 4.5 Translations and polish (later)
Item name, tooltip text, poster, README description.

---

## 5. Test plan (in-game, v42.20.4)

1. Spawn the item, place it, plug it in, and start it. Confirm it behaves like a Blue Generator (sound, power radius, fuel and condition UI).
2. Let fuel and condition drop (or reduce them with debug), then wait for the next 10-minute tick. Confirm fuel is 10, condition is 100, and the generator is on.
3. Turn it off by hand and confirm the next tick turns it back on. Decide whether that is desired.
4. Pick it up and place it again. Confirm it is still a Naquadah Generator and stays in the registry.
5. Save, quit, reload. Confirm the registry persists and refills continue.
6. Leave the area for many in-game hours, return, and check the §3.4 gap.
7. Place a vanilla Blue Generator next to it and confirm the vanilla one is **not** refilled.
8. Multiplayer (dedicated server) pass: confirm refill runs once, on the server, and that clients see the new values.

---

## 6. Risks

These are known technical risks, not decisions for you. Decisions are in §7.

- **Sprite→type collision** (Options B and C): whether a borrowed vanilla sprite resolves to the new item or to Blue is unverified.
- **Placement hard-coding** in `ISMoveableSpriteProps` may block a new sprite from becoming an `IsoGenerator`.
- **No Lua access to `AllGenerators`**, so tracking has to be our own (§3.2).
- **Drain between loads** (§3.4): a generator in an area that was unloaded for many in-game hours can drain before its first refill.
- **Indoor toxicity** of a permanently running generator (§3.3).
- **Balance:** an unlimited-fuel generator removes the fuel economy entirely. Sandbox options such as `generatorFuelConsumption` are untouched by the mod.

---

## 7. Questions for Ed

1. **Which approach should I use to make the Naquadah Generator distinct from a Blue Generator?** A: new item with a new custom sprite (needs art and a tilesheet), B: new item borrowing another Blue sprite frame (no art, but the sprite may resolve to Blue), or C: a normal Blue Generator tagged with modData (the tag would be lost on pickup unless I hook pickup and placement)? I lean toward B for the first cut. Is that acceptable?
B
2. **Is it OK to spell the name "Naquadah" in item names and text?** Your idea file spells it "Naquidah". Which spelling do you want?
Naquadah
3. **How should players obtain it in the first version?** Debug/admin spawn only, a craft recipe (and if so, from what ingredients?), or world loot?
Debug spawn
4. **Should it be allowed to run indoors?** A running vanilla generator indoors makes the building toxic. Do you want to keep that, or should the Naquadah Generator avoid it (which would mean special handling or restricting it to outdoor placement)?
No
5. **Should the refill also plug the generator in (`setConnected(true)`), or only refuel, repair, and activate it?** Your idea says "activates it", so I assumed the player still plugs it in themselves.
Only refuel repair and activate
6. **If a player turns it off by hand, should the next 10-minute tick turn it back on?** The idea says the mod activates it every 10 minutes. Should a manual shutdown be respected or overridden?
Manual shutdown is respected
7. **Should the mod also refill when a generator's area loads, not only every 10 minutes?** This closes the long-absence drain gap in §3.4, but goes beyond the idea as written.
Yes, refill when the area loads
8. **Should the generator be balanced in any way?** For example, a higher craft cost, lower power output, or noise, or do you want it to be a plain unlimited generator?
No
9. **Does the mod need to support multiplayer from the start,** or is singleplayer enough for the first DevCycle?
No multiplayer

---

## 8. Suggested first DevCycle scope (for later)

Spawn-only Naquadah item (Option B, subject to Question 1), server-side registry plus 10-minute refill, and test plan items 1–5. Recipe, art, translations, and balance come in later cycles. I will create the actual DevCycle only when you ask.
