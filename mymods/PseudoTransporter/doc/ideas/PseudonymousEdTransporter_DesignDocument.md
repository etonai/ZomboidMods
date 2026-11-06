# Limited Transporter – Design Document

**Created:** 2026-11-05
**Source idea:** `PseudonymousEdTransporter.txt` (same folder)
**Status:** Draft design. Not a DevCycle. DevCycles are created separately under `doc/planning/`.
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)
**Mod scaffold:** `PseudoTransporter/42/mod.info` (id `PseudonymousEdTransporter`, name "PseudonymousEd's Transporter")
**Related reading:** `claudeDocs/claude_RVLifeLessons.md` (teleport technique, §3)

---

## 1. Purpose

A limited site-to-site transporter. The player builds or places two linked objects in the world. Using either one from its context menu ("Transport") teleports the player to the other one.

---

## 2. The two objects

| Object | Looks like | Vanilla item | Sprite | Notes |
|---|---|---|---|---|
| **Transporter Control** | Ham Radio 2 | `Base.HamRadio2` (`ItemType = base:radio`, `radio.txt:229`) | `appliances_com_01_8` | A vanilla radio device. It has its own radio behavior, battery use, and context menu. |
| **Transporter Signal Booster** | Road Cone | `Base.Mov_RoadCone` (`ItemType = base:moveable`, `moveable.txt:957-964`) | `street_decoration_01_26` (id 173026) | A plain moveable. Weight 0.5. It can be picked up and re-placed with the vanilla moveable tools. |

**Design consequence:** both looks are common vanilla objects that already exist in the world (every road cone and every Ham Radio 2). The mod therefore needs a way to tell *our* objects from the vanilla ones (see §5 and Question 1). Otherwise every road cone in Muldraugh would offer "Transport".

---

## 3. Player-facing behavior

1. The player obtains/places a Transporter Control and a Transporter Signal Booster.
2. The two objects are linked as a pair (§5).
3. Right-clicking either object shows a **Transport** entry (and only on our objects).
4. Choosing it teleports the player to the paired object's location.
5. From the other end, "Transport" takes the player back.

Out of scope for the idea document (see §10 Questions): power or battery cost, cooldowns, range limits, carrying items or companions, crafting recipe.

---

## 4. Teleport mechanism

Based on RV Life (`claude_RVLifeLessons.md` §3.3–3.4):

```lua
player:setX(destX); player:setY(destY); player:setZ(destZ)
player:setLastX(destX); player:setLastY(destY); player:setLastZ(destZ)
```

- Setting the `Last*` values as well prevents the engine from treating the move as a huge step.
- RV Life also pushed nearby zombies away for two seconds on arrival. The same safeguard may be wanted here (Question 7).
- RV Life refused to start while a zombie was within 10 tiles and while the player was in a vehicle. The same pre-checks are candidates here.
- **Destination square:** teleport to a walkable square next to the destination object, not onto the object's own square (a radio or cone square may be blocked or not walkable). The exact offset needs choosing and testing.

**Difference from RV Life:** RV Life's destination is a reserved interior block. The Transporter's destination is an arbitrary place anywhere in the world, so the destination chunk may not be loaded when the player is moved. This is the largest technical unknown in the mod (see §9).

---

## 5. Pairing and identity

### 5.1 Identifying "our" objects
The vanilla sprites are shared with vanilla world objects, so the mod must mark its own objects. Options:

| Option | Idea | Pros | Cons |
|---|---|---|---|
| **A. New items** | New item scripts (`TransporterControl`, `TransporterSignalBooster`) that reuse the vanilla sprites as their `WorldObjectSprite`. | Clear identity; an item name and tooltip are free. | Reusing a sprite already mapped by a vanilla item may confuse sprite→item lookups. Needs testing. |
| **B. modData flag** | Keep the vanilla items. Tag the placed world object (`getModData().PseudoTransporter = ...`) when the player places it. | No new item scripts. | The flag has to be applied at placement and may not survive pick-up and re-place unless carried on the item. |

### 5.2 Pairing
Each Control is linked to one Signal Booster. Data kept per object:

```text
transporterId   -- unique id for the pair
role            -- "control" or "booster"
```

and a global registry in ModData (name e.g. `PseudoTransporter`):

```text
registry[transporterId] = {
    control = { x, y, z } or nil,
    booster = { x, y, z } or nil,
}
```

The registry is updated when an object is placed, moved, or removed. "Transport" looks up the other end from the registry.

How the link is created is undecided (Question 2).

---

## 6. UI

- Hook `Events.OnFillWorldObjectContextMenu` (the same event vanilla menus use, e.g. `ISFeedingTroughMenu`, `AdminContextMenu`, `ISInventoryBuildMenu`).
- From the clicked `worldobjects`, find objects whose sprite is one of the two transporter sprites **and** that carry the mod's marker.
- Add a single option "Transport" (translated text).
- Hide or grey out the option if the pair is incomplete, the other end is missing, or a pre-check fails. A tooltip on the disabled option explains why.
- Use a timed action for the teleport (a short, interruptible action) rather than an instant jump. This leaves room for a progress bar and cancellation.

---

## 7. Components (planned)

```
PseudoTransporter/                              (mod folder, id PseudonymousEdTransporter)
└── 42/
    ├── mod.info
    └── media/
        ├── scripts/                            item definitions (if Option A), recipes
        └── lua/
            ├── shared/                         constants, helpers (isTransporterObject, registry access)
            ├── client/                         context menu, timed action
            └── server/                         registry persistence, validation of the teleport
```

| Component | Responsibility |
|---|---|
| Item scripts | Define the two objects (Option A) with the radio and cone sprites. |
| Registry (ModData) | Store pair locations; survive save and load. |
| Placement hooks | Record location and marker when an object is placed; clear it when removed or picked up. |
| Context menu | Show "Transport" on our objects. |
| Teleport action | Run the pre-checks, move the player, apply arrival safeguards. |
| Translations | Item names, menu text, error messages. |

---

## 8. Edge cases to handle

- One end of the pair is missing, destroyed, or picked up.
- The other end's chunk is not loaded.
- The player is in a vehicle, is carrying a heavy item, is mid-action, or is injured in a way that blocks movement.
- Zombies near the origin or the destination.
- The destination square is blocked, or the destination object sits inside a building and the origin outside.
- Different Z levels.
- The player picks up an object that is part of a pair, then places it somewhere else (the registry must follow it).
- Two players use the same transporter at once (multiplayer).
- Vanilla road cones and Ham Radio 2s must never show "Transport".

---

## 9. Technical risks and unknowns

These are things I have **not** verified in the code. They need research or an in-game test.

1. **Unloaded destination chunks.** A plain `setX/Y/Z` to a far-away location puts the player on a square whose chunk may not be loaded yet. RV Life avoids the problem because its interior block sits in a fixed place. Whether the engine loads the chunk fast enough, or the player falls or stalls, needs testing.
2. **Reading the other end's position.** If the other object is in an unloaded chunk, its square cannot be fetched with `getGridSquare`. The registry coordinates are therefore the source of truth, not the live object.
3. **Marking a placed radio.** A Ham Radio 2 placed in the world is a radio device object, not a generic moveable. How its modData persists through pick-up and placement needs checking. I did not verify this.
4. **Marking a placed cone.** The cone is a plain moveable. How moveable pick-up and placement carry modData was not verified.
5. **Sprite reuse.** Reusing `appliances_com_01_8` or `street_decoration_01_26` as an item's `WorldObjectSprite` may conflict with the vanilla items that already use them.
6. **Multiplayer authority.** RV Life moves the player from client-side Lua. Whether that is accepted by a dedicated server in B42, or needs a server command, is unverified.
7. **Radio behavior on the Control.** A real radio device has power, channel and sound behavior. Whether those should be disabled, kept, or reused for the Transporter's power cost is a design choice (Question 4).

---

## 10. Questions for Ed

1. **How should the mod tell a Transporter object from an ordinary road cone or Ham Radio 2?** New items that reuse the vanilla sprites (A), or a modData marker on vanilla items (B)? I lean toward A. Is that acceptable?
Reuse the vanilla sprites
2. **How should a Control and a Signal Booster be paired?** For example: the booster is placed within a set distance of a control and links automatically; the player uses a "Link" menu option on each; or each crafted pair is born linked? Can a Control have more than one booster?
There is only one booster and only one control. The booster teleports to the control. The control teleports to the booster.
3. **Do both objects always come as exactly one pair, or can a player own several pairs?** If several, how does the player know which booster belongs to which control?
One pair
4. **Should the Control need power?** The vanilla Ham Radio 2 uses batteries or a generator. Should "Transport" require power, and if so how much (per use, or only that it is on)? Should the Signal Booster need power too?
The control needs power. The booster does nto need power.
5. **Is there a distance limit between the two ends?** "Limited" in the idea text could mean range, uses, cooldown, power, or something else. Which of these do you mean?
No limits
6. **How do players get the objects?** Craft recipes (and if so, from which ingredients and skill), world loot, or debug/admin spawn only for the first version?
debug spawn
7. **Which safeguards do you want on use?** For example: blocked while a zombie is nearby, blocked in a vehicle, a short channel time, a cooldown, and a push-back of nearby zombies on arrival, as RV Life does.
No safeguards
8. **Should the player be able to take items, companions or vehicles through?** Or only the player character?
Just the player character and inventory
9. **Where exactly should the player arrive?** Next to the destination object, on a fixed side, or on the nearest free square?
in the same loation as the destination object
10. **What should happen if the other end is missing, destroyed or in an unloaded area?** Refuse with a message, or try anyway?
Nothing happens
11. **Is the Signal Booster also allowed to initiate a transport,** or only the Control? The idea text says each object has a "Transport" item. Do you want it to be symmetrical?
Yes, the booster is allowed to initiate a transport
12. **Does the first version need multiplayer support,** or is singleplayer enough for the first DevCycle?
No multiplayer support
13. **Should the mod adjust sounds or visuals** (a transport sound, a screen effect, or an animation) or is a silent teleport fine for the first version?
No sounds or visuals

---

## 11. Test plan (in-game, v42.20.4)

1. Place a Control and a Booster, link them, and use "Transport" from each. Confirm arrival next to the other object, both ways.
2. Confirm vanilla road cones and Ham Radio 2s do **not** show "Transport".
3. Pick up one end and re-place it elsewhere. Confirm the registry follows and "Transport" lands at the new location.
4. Save, quit, reload. Confirm the pair still works.
5. Transport over a long distance to an area that is not loaded. Note load time, falling, or stalls.
6. Try each pre-check (vehicle, zombies nearby, missing end).
7. Multiplayer pass on a dedicated server, if multiplayer is in scope.

---

## 12. Suggested first DevCycle scope (for later)

Two objects (Option A, subject to Question 1), a registry, a "Transport" option with the plain teleport, and test plan items 1–4. Recipes, power, safeguards, effects, and translations can follow in later cycles. I will create the actual DevCycle only when you ask.
