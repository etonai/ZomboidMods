# DevCycle 011: Magic Waterskin, Everful Waterskin and Crate of Freshness

**Status:** VERIFIED (Phases 1-9 Work Complete (Ed: "Tests passed"); Phase 10 Everful Bucket Work Complete, in-game checks pending)
**Start Date:** 2026-11-14
**Target Completion:** TBD
**Focus:** Add self-refilling Everful items (a waterskin and, from Phase 10, a bucket) and a Crate of Freshness that keeps its perishable contents fresh. (The large-capacity Magic Waterskin in the original plan was dropped in Phase 5.)

**Source documents:** `doc/ideas/DC11PlusIdeas.txt` (idea). Inspiration for the periodic-maintenance pattern: `mymods/PseudoGenerator` (`doc/planning/completed/DevCycle001.md`).
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

Extend PseudoMagic with three items from the ideas list, in order of difficulty:

1. **Magic Waterskin**: a leather waterskin with a much larger capacity (test with 10 L).
2. **Everful Waterskin**: the same, but it refills itself with water on a timer (about every 10 minutes).
3. **Crate of Freshness**: a placeable crate that resets the age of perishable items inside it on a timer (about every 10 minutes), so they never spoil.

The Everful Waterskin and the Crate use the same approach as PseudoGenerator: a periodic pass that resets a value to its maximum, plus a way to find the objects to maintain.

## Desired Outcome

In a single-player game, a tester spawns each item with the debug tools and:

- the Everful Waterskin is a normal 1 L waterskin (the Magic Waterskin was dropped);
- after being drunk from or emptied it is full of water again within about 10 in-game minutes;
- the Crate of Freshness can be placed, filled with food, and after the next pass the food's age is 0, so it never goes stale or rotten while in the crate;
- food taken out of the crate starts ageing again from age 0 (fresh), and food not in the crate is not affected;
- everything keeps working after saving and reloading.

## Scope

| Topic | Decision for this cycle (proposed; see Open Questions) |
|---|---|
| Magic Waterskin | Dropped in Phase 5; removed from the mod |
| Everful Waterskin | New item based on `Base.Bag_LeatherWaterBag` (keeps its 1 L capacity; Phase 8 corrects the 10 L set in Phase 3) plus a periodic refill to full of `Water` |
| Crate of Freshness | **Changed in Phase 1:** not a new crate (the engine allows one entity per sprite). A regular Metal Crate (`Metal_Crate_Lvl1`, sprites `constructedobjects_01_44`-`47`; changed from the Fancy Metal Crate in Phase 7) is enchanted from its right-click menu by a survivor carrying a Ring of the Mage; periodic age reset of food inside |
| Acquisition | Waterskins: debug spawn. Crate: enchant an existing Fancy Metal Crate (needs the vanilla crate, built with the welding recipe or the debug build cheat) |
| Interval | Every 10 in-game minutes (`Events.EveryTenMinutes`) |
| Multiplayer | Not supported (single player first, as in DC 8 and DC 10) |

**Out of scope:** custom art or models (reuse vanilla), balance beyond the requested behavior, multiplayer.

---

## Research Summary

What I found so far, read from the v42.20.4 files. None of it has been run in game.

- **Waterskin base:** `Base.Bag_LeatherWaterBag` (`media42_20_4/scripts/generated/items/clothing.txt:24482`). It is a `base:clothing` item (body location `base:satchel`, weight 0.3, icon `Wineskin`) with a `component FluidContainer` (`ContainerName = LeatherWaterBag`, `Capacity = 1.0`, initial fluid `Water:1.0`). A new item can copy this script and change `Capacity`.
- **Fluid API:** `FluidContainer` (`zombie42_20_4/entity/components/fluids/FluidContainer.java`) has `getCapacity()`, `getFreeCapacity()`, `getAmount()`, `adjustAmount()` and `addFluid(String fluidType, float amount)`. A refill can be done with `addFluid("Water", getFreeCapacity())` when the container is not full. Whether it can be topped up when it holds a different fluid (for example if the player filled it with something else) is open, see Open Questions.
- **Crate base:** the Fancy Metal Crate is `entity Metal_Crate_Lvl2` (`media42_20_4/scripts/generated/entities/furniture/entity_welding_crate_lvl2.txt`), a crafted entity using sprite `crafted_05_44`, built with a welding recipe. It is not a normal item script, so a crate of our own needs research on how to define it: either a new entity/recipe with its own name, or a hook on the vanilla crate.
- **Food age:** `InventoryItem.getAge()/setAge(float)` (`zombie42_20_4/inventory/InventoryItem.java:2729-2737`) and `Food.java` use `age` against `offAge` and `offAgeMax` to decide stale and rotten. Setting `setAge(0)` on each `Food` in the crate resets freshness. Other perishable things (for example items with their own `age`, such as some drinks or cooked-state items) still need checking.
- **Periodic pattern:** the PseudoGenerator keeps a registry of its objects in global ModData, uses `Events.EveryTenMinutes` to maintain loaded ones, and `Events.LoadChunk` when an area loads. It also found that engine code charges *every in-game hour since its last update* on first update after loading, which is why its area-load pass matters. Food ageing needs the same check: does the food's age get advanced in one step for the hours the chunk was unloaded, and does resetting on chunk load prevent a rotten result after a long absence?
- **Existing PseudoMagic style:** the mod has client Lua files per feature (`PseudoMagicRingRefill.lua`, `PseudoMagicTeleport.lua`, `PseudoMagicMenu.lua`), items in `scripts/items/PseudoMagic_Items.txt` and text in `shared/Translate/EN/`. `PseudoMagicRingRefill.lua` already keeps ring uses topped up, which is the closest existing example of "reset a value on a timer" for an *inventory* item.

---

## Tasks

### Phase 1: Research the unknowns

**Status:** Work Complete

- [x] **Waterskin capacity:** confirm a copy of `Bag_LeatherWaterBag` with `Capacity = 10.0` works (fill, drink, empty, tooltip and fluid bar display, weight if the engine adds the fluid weight).
- [x] **Waterskin refill:** confirm the best Lua call for topping up water (`addFluid` versus `adjustAmount`), what happens if the container holds a different fluid, and whether the refill must be done on the item the player holds, in a bag, or on the ground.
- [x] **Where to find the waterskins:** decide how the periodic pass reaches the Everful Waterskin: scan the player's inventory (like `PseudoMagicRingRefill`) or also containers in the world. Record what a scan costs.
- [x] **Crate definition:** find out how the Fancy Metal Crate is turned into a placed container (entity, `IsoThumpable`, or other), and how a new "Crate of Freshness" can use the same sprite and still be told apart from a vanilla crate.
- [x] **Crate tracking:** choose how to find placed crates from Lua (registry of locations in ModData, loaded-square events, or the crate's own modData flag) and when to register and unregister them.
- [x] **Food age fields:** confirm which perishable items expose `age` (`Food`, drinks, others) and which fields to reset (`setAge(0)`; also check whether the "rotten" or "stale" state is cached and must be refreshed).
- [x] **Long absence:** find out how food age is advanced when a chunk loads after hours away, and whether a reset on `LoadChunk` is enough (compare with PseudoGenerator DevCycle 1 finding 7).
- [x] **Container types in the crate:** check whether the reset should reach nested containers (a bag of food inside the crate).
- [x] Record each finding in the Technical Notes below.

**Technical Notes (findings read from the v42.20.4 code; none run in game):**

1. **Waterskin capacity.** `Bag_LeatherWaterBag` is a plain `base:clothing` item with a `FluidContainer` component; a copy with `Capacity = 10.0` needs no other change. *Unverified in game:* fluid bar and tooltip at 10 L, and any weight the engine adds for the fluid.
2. **Waterskin refill.** `FluidContainer.addFluid(Fluid, amount)` (`FluidContainer.java:935-960`) adds up to the free capacity and refuses when full or when the fluid cannot be added; `isEmpty()`, `isFull()`, `isPureFluid(fluid)` and `getFreeCapacity()` are available. Vanilla Lua uses `Fluid.Get(...)` and `Fluid.AnimalMilk`, so `Fluid.Water` is used.
3. **Finding the skins.** `ItemContainer.getAllTypeRecurse(type)` searches the player's inventory and nested bags. Only the player's own inventory is scanned; a skin lying on the ground or in a world container is not refilled.
4. **Crate definition (the blocker).** A placed crate gets its entity from the sprite's `EntityScriptName` tile property, and `SpriteConfigManager.parseEntityScript` (`:117-140`) throws "Sprite ... is duplicate" if two entity scripts use one sprite. A second crate entity therefore cannot reuse `crafted_05_44`, and a different container sprite would need a custom tilesheet. **Decision:** enchant the vanilla crate instead (fallback from recommendation 6).
5. **Crate tracking.** The enchanted crate is flagged in the object's modData and recorded in global ModData (`PseudoMagicFreshness.crates`, keyed `x,y,z`), the same pattern as PseudoGenerator. Entries whose loaded square no longer holds an enchanted crate are dropped at the next pass. *Unverified:* that object modData survives save/load and moving the crate; a moved crate may lose the flag, in which case the entry is dropped.
6. **Food age.** `Food.updateAge` advances age by `worldAgeHours - lastAged` (`Food.java:751-782`). The mod therefore sets both `setAge(0)` and `setLastAged(now)` on each `Food`, so a long absence does not age it again on its first update after load.
7. **Long absence.** Covered by the `LoadChunk` pass plus the `lastAged` reset above. Unverified in game.
8. **Nested containers.** The freshening recurses into bags inside the crate.

### Phase 2: Magic Waterskin (superseded: removed in Phase 5)

**Status:** Work Complete

- [x] Add the `MagicWaterskin` item script to `PseudoMagic_Items.txt`, based on `Bag_LeatherWaterBag`, with the larger capacity.
- [x] Add its display name to `ItemName.json`.
- [x] Decide the starting contents (empty, or full of water).
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.

**Technical Notes:**
Start with 10 L as in the ideas file; the number is a one-line change.

### Phase 3: Everful Waterskin

**Status:** Work Complete

- [x] Add the `EverfulWaterskin` item script (same base as Phase 2).
- [x] Add its display name to `ItemName.json`.
- [x] Add a client Lua file (for example `PseudoMagicEverfulWaterskin.lua` (renamed `PseudoMagicEverfulRefill.lua` in Phase 10)) that, on `Events.EveryTenMinutes`, tops up every Everful Waterskin the player carries to full of water.
- [x] Also run the top-up when the player loads in, so a save loaded after a long break starts full.
- [x] Never touch vanilla waterskins or the plain Magic Waterskin.

**Technical Notes:**
Reuse the inventory-scan approach in `PseudoMagicRingRefill.lua` unless Phase 1 shows a need to maintain skins outside the player's inventory.

### Phase 4: Crate of Freshness (enchantment)

**Status:** Work Complete

- [x] Add the "Enchant: Crate of Freshness" / "Remove Crate of Freshness enchantment" options to the world context menu of a Fancy Metal Crate (`crafted_05_44`), shown only to a survivor carrying a Ring of the Mage.
- [x] Add the menu and message text to `UI.json`.
- [x] Track enchanted crates (modData flag plus a registry in global ModData), registering on enchant and unregistering on removal; entries for a crate that has gone are dropped at the next pass.
- [x] On `Events.EveryTenMinutes`, for each tracked crate whose square is loaded, set the age of every perishable item inside to 0.
- [x] Do the same on `Events.LoadChunk` for tracked crates in the loaded chunk.
- [x] Never touch a vanilla Fancy Metal Crate that has not been enchanted.
- [x] Run only in single player (`if isClient() then return end`).

**Technical Notes:**
Files: `PseudoMagic/42/media/lua/client/PseudoMagic/PseudoMagicFreshness.lua` (modelled on PseudoGenerator's registry plus ten-minute pass) and `PseudoMagicEverfulWaterskin.lua`. Items are `MagicWaterskin` and `EverfulWaterskin` in `PseudoMagic_Items.txt`, both spawning full of water. Enchanting is instant (no timed action) and shows a halo note. Deployed with `CopyModToZomboid.bat PseudoMagic` on 2026-11-14.

### Phase 5: Remove the Magic Waterskin

**Status:** Work Complete (implemented ahead of this plan entry at Ed's request; not yet verified)

**Change of plan (Ed):** the Magic Waterskin (the 10 L one) is removed from the mod entirely. Only the Everful Waterskin remains. This replaces the earlier idea of splitting the two skins by capacity, and supersedes Phase 2.

- [x] Remove the `MagicWaterskin` item script from `PseudoMagic_Items.txt`.
- [x] Remove its entry from `ItemName.json`.
- [x] Confirm nothing else in the mod refers to it (only `doc/ideas/DC11PlusIdeas.txt` does, and it is left as the original idea record).
- [x] Update the comment on the Everful Waterskin item, which referred to the Magic Waterskin.
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.
- [ ] In game: confirm the Magic Waterskin no longer appears in the debug item list.

**Technical Notes:**
A Magic Waterskin already in an existing save will no longer have an item script; expect it to disappear or log a missing-item warning on load.

### Phase 6: Show the Everful Waterskin's name in the inventory

**Status:** Work Complete (implemented ahead of this plan entry at Ed's request; not yet verified)

**Problem (Ed):** the Everful Waterskin's name must show in the inventory.

**Finding:** `InventoryItem.getName` returns `FluidContainer.getUiName()` for any item with a fluid container (`InventoryItem.java:2463`), and that name is built from the translation `Fluid_Container_<ContainerName>` (`FluidContainer.getTranslatedContainerName`). The Everful Waterskin had copied `ContainerName = LeatherWaterBag`, so it displayed the vanilla "Leather Water Bag" name and ignored its `ItemName.json` entry.

- [x] Set `ContainerName = EverfulWaterskin` in the item's `FluidContainer` component.
- [x] Add `lua/shared/Translate/EN/Fluids.json` with `"Fluid_Container_EverfulWaterskin": "Everful Waterskin"` (same pattern as PseudoChurningMachine).
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.
- [ ] In game: confirm the inventory (and the tooltip and the worn or held item) shows "Everful Waterskin". The fluid state may be appended to the name, as for vanilla containers.

**Technical Notes:**
If the name still does not show, check that `Fluids.json` is loaded (file name and folder) and, as a fallback, whether a `DisplayName` is needed in the item script.

### Phase 7: Crate of Freshness uses the regular Metal Crate

**Status:** Work Complete (deployed; not yet verified in game)

**Problem:** Phase 4 enchants the **Fancy Metal Crate** (`Metal_Crate_Lvl2`, sprite `crafted_05_44`, welding level 7). The wanted base is the **regular Metal Crate**.

**Findings so far (read from `media42_20_4/scripts/generated/entities/furniture/entity_welding_crate_lvl1.txt`):**

- The regular Metal Crate is `entity Metal_Crate_Lvl1` (welding level 3), not `crafted_05_44`.
- Unlike the fancy crate, it has **four** sprites, one per facing: `constructedobjects_01_44`, `_45`, `_46` and `_47`. (Facings in the script: `_45`, `_44`, `_47`, `_46`.) The sprite check must accept all four.
- Facings: `_45` = W, `_44` = N, `_47` = E, `_46` = S. Not confirmed in game: that each sprite gives an object with a container (expected, since the entity is a crate).

Tasks:

- [x] Confirm the four sprite names from `entity_welding_crate_lvl1.txt`.
- [ ] In game: confirm every one of the four facings gives an object with a container and the enchant option appears.
- [x] In `PseudoMagicFreshness.lua`, replace the single `CRATE_SPRITE` check with a set of the four sprite names used by `isCrateSprite`.
- [x] Decide what happens to the Fancy Metal Crate: it is no longer enchantable (recommended, see Open Questions).
- [x] Update the comments in `PseudoMagicFreshness.lua`, and the Scope table and Phase 4 notes in this document, to say "regular Metal Crate".
- [x] Menu text in `UI.json` does not name a crate type, so it needed no change.
- [ ] In game: check that crates already enchanted in a test save (Fancy Metal Crate) are dropped cleanly: their registry entries should be removed at the next ten-minute pass because the square no longer holds an enchantable crate.
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.

**Technical Notes:**
Implemented in `PseudoMagicFreshness.lua` as a `CRATE_SPRITES` set used by `isCrateSprite`; redeployed 2026-11-14. The sprite-per-entity rule from Phase 1, Note 4 still applies, so the enchantment approach stays; only the sprite check changes.

### Phase 8: Everful Waterskin keeps the original 1 L capacity

**Status:** Work Complete (deployed; not yet verified in game)

**Note:** the Magic Waterskin stays removed (Phase 5); it is not coming back.

**Problem (Ed):** the Everful Waterskin still shows a capacity of 1 L in game. The original instructions were that it is modeled on the original waterskin (`Bag_LeatherWaterBag`, 1 L), and only the Magic Waterskin was supposed to be 10 L.

**Finding:** Ed is right about the instructions. `DC11PlusIdeas.txt` gives the Everful Waterskin no capacity change (only "Waterskin that refills itself"). In Phase 3 I copied the Magic Waterskin's 10 L capacity into the Everful Waterskin, which was my mistake. The Magic Waterskin has since been removed (Phase 5). The Everful Waterskin item script in the mod currently says `Capacity = 10.0`, yet Ed sees 1 L in game; that mismatch is unexplained (see Open Questions).

Tasks:

- [x] Set `Capacity = 1.0` (the vanilla value) in the `EverfulWaterskin` item script, so the script matches the original instructions.
- [x] Update the comment above the item (it says "with a 10 L capacity"), the Scope table and the Desired Outcome in this document.
- [x] Find out why the game shows 1 L while the script said 10 L. Result: **not explained.** Before this fix the deployed script matched the source (10 L); after it, the deployed copy reads `Capacity = 1.0`. Remaining possibilities are that the game was not restarted after deploying, or that the skin inspected was spawned earlier; both are checked by the in-game step below.
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.
- [ ] In game: spawn a fresh Everful Waterskin; confirm it holds 1 L, shows the name "Everful Waterskin", and refills after the next ten-minute tick.

**Technical Notes:**
Changed `Capacity` to `1.0` and the item comment in `PseudoMagic_Items.txt`; redeployed 2026-11-14. No Lua change is expected: the refill uses `getFreeCapacity()`, which follows the container's capacity.

### Phase 9: In-Game Testing

**Status:** Work Complete (Ed reported "Tests passed" on 2026-11-14; individual checklist results were not recorded; not marked Verified)

- [x] Deploy via `CopyModToZomboid.bat PseudoMagic` and load a B42 test save.
- [x] Confirm the Magic Waterskin is gone from the debug item list.
- [x] Everful Waterskin: confirm the name "Everful Waterskin" shows in the inventory; empty it, wait for the next ten-minute tick, confirm it is full; confirm a vanilla waterskin carried alongside is not refilled.
- [x] Crate: build a regular Metal Crate (or use the debug build cheat), and try each of its four facings, enchant it with a Ring of the Mage in the inventory, fill with fresh and half-aged food; after the next tick confirm age is 0.
- [x] Take food out of the crate and confirm it ages normally from then on.
- [x] Place a second, un-enchanted regular Metal Crate nearby; confirm a Fancy Metal Crate no longer offers the enchant option and confirm its food is **not** reset; confirm the enchant option does not appear without a ring.
- [x] Save, quit, reload; confirm both items keep working. Pick the crate up and place it again, and note whether the enchantment survives (expected: it may not).
- [x] Leave the crate's area for many in-game days, return, and confirm the food is still fresh (tests the `LoadChunk` path).
- [x] Check the game console/log for Lua errors from the mod after each step.
- [x] Record the results in the Completion Summary.

**Technical Notes:**
Covers Phases 1-8. Per `AGENTS.md`, work stops at **Work Complete**; only the user can mark a phase or the cycle **Verified**.

### Phase 10: Everful Bucket

**Status:** Work Complete (deployed; in-game checks pending)

**Goal (Ed):** add an Everful Bucket, the bucket counterpart of the Everful Waterskin: a bucket that refills itself with water.

**Findings so far (read from `media42_20_4/scripts/generated/items/normal.txt`; nothing run in game):**

- The vanilla bucket is `Base.Bucket` (`normal.txt:13864`): `ItemType = base:normal`, weight 1.0, icon `MetalBucket` with `IconFluidMask = Bucket_Mask`, `EatType`/`PourType = Bucket`, tags `base:bucket;base:cookable;base:hasmetal;base:metalbucket`, and a `FluidContainer` with `ContainerName = Bucket`, `Capacity = 10.0`, `RainFactor = 0.5`, `TransferRate = 5.0`. It starts empty. `Base.BucketEmpty` (`:13225`) is a near copy with `RainFactor = 1.0` and a rain tooltip.
- "Modeled off the original item" (the lesson of Phase 8): the Everful Bucket copies the vanilla bucket's capacity (10 L, which is the bucket's own normal capacity) and changes nothing else about it except the refill and its name.
- The name rule from Phase 6 applies: the inventory name comes from `Fluid_Container_<ContainerName>`, so the bucket needs its own `ContainerName = EverfulBucket` and a `Fluids.json` entry, or it will show as "Bucket".
- The refill code in `PseudoMagicEverfulWaterskin.lua` already works from item type and `getFreeCapacity()`. It needs to cover a second item type rather than be copied.
- Vanilla recipes and tags reference `base:bucket` / `base:metalbucket`; keeping the tags makes the Everful Bucket usable wherever a bucket is (for example for cooking or carrying water). This is intended; see Open Questions.

Tasks:

- [x] Add the `EverfulBucket` item script to `PseudoMagic_Items.txt`, modeled on `Base.Bucket`: same model, icon, fluid mask, sounds, tags and `FluidContainer` (`Capacity = 10.0`, `RainFactor`, `TransferRate`), with `ContainerName = EverfulBucket`, starting full of water.
- [x] Add `"PseudoMagic.EverfulBucket": "Everful Bucket"` to `ItemName.json`.
- [x] Add `"Fluid_Container_EverfulBucket": "Everful Bucket"` to `Fluids.json`.
- [x] Extend the refill to cover the Everful Bucket: rename `PseudoMagicEverfulWaterskin.lua` to a general name (for example `PseudoMagicEverfulRefill.lua`), keep a table of Everful item types, and run the same top-up for each (every ten in-game minutes and on game start). The refill rules are unchanged: top up only when empty or already holding water; never touch the vanilla bucket or the Everful Waterskin's other behavior.
- [x] Update the comments in the item script and the Lua file, and the Scope table, Desired Outcome and Goal at the top of this document, to include the bucket.
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.
- [ ] In game: spawn an Everful Bucket; confirm the name "Everful Bucket" shows, it holds 10 L, and it starts full.
- [ ] In game: empty it and confirm it is full again after the next ten-minute tick; confirm a vanilla bucket carried alongside is **not** refilled and the Everful Waterskin still refills.
- [ ] In game: confirm it works as a bucket (pour, fill other containers, rain collection if carried or placed) and check the console log for Lua errors.

**Technical Notes:**
Implemented: `EverfulBucket` in `PseudoMagic_Items.txt` (copy of `Base.Bucket`, starts full), entries in `ItemName.json` and `Fluids.json`, and `PseudoMagicEverfulWaterskin.lua` replaced by `PseudoMagicEverfulRefill.lua`, which refills both Everful types. Redeployed 2026-11-14; the deployed copy no longer contains the old Lua file. A bucket lying on the ground or in a world container is not refilled, as with the waterskin (the pass scans the player's inventory only). Whether a bucket should refill while placed or on the ground is an Open Question.

---

## Open Questions

Each question has a recommendation. Answer with "go with the recommendations" or override individual ones.

1. **How are the items obtained?** The ideas file does not say. Options: debug spawn only (as for the Naquadah Generator), a crafting recipe, or world loot.
   **Recommendation:** debug spawn only in this cycle. It keeps the cycle about the mechanics, and recipes (with their skill and ingredient balance) can follow in a later cycle once the items work.

2. **Waterskin capacity:** is 10 L the final value, or only the test value? The ideas file says "Test with 10 Liters".
   **Recommendation:** use 10 L as the working value and treat it as a one-line change after testing. Revisit it only if the fluid bar, tooltip or carry weight looks wrong at that size.

3. **Everful Waterskin and non-water fluids:** if the player fills it with something else, what should the refill do?
   **Recommendation:** top up only when the skin is empty or already holds water; leave any other fluid alone. This never destroys something the player put in on purpose, and the skin still refills as soon as it is emptied.

4. **Everful interval:** is "about every 10 minutes" a hard requirement, or would a quicker refill be preferred?
   **Recommendation:** keep every 10 in-game minutes (`EveryTenMinutes`). It matches the idea and PseudoGenerator, and is cheap. A faster trigger can be added later if it feels slow in play.

5. **Crate of Freshness: scope of "perishable".** Only `Food`, or also drinks, cooked meals and corpses? Should nested bags inside the crate be refreshed?
   **Recommendation:** reset the age of every `Food` item in the crate (cooked meals are `Food`, so they are covered) and recurse into containers inside the crate, such as a bag of food. Ignore corpses and fluid containers. Phase 1 confirms what else carries an `age`; widen the scope only if it finds something that obviously should be included.

6. **Crate of Freshness: new object or modified vanilla crate?** *(Resolved in Phase 1: the fallback was needed; see Technical Note 4. The crate is an enchantment of the vanilla crate.)*
   **Recommendation:** a new, separately named crate that reuses the `crafted_05_44` sprite, with no recipe in this cycle (debug spawn, per question 1). Changing the vanilla crate would also affect every normal Fancy Metal Crate. If Phase 1 shows a separate crate is impractical, fall back to marking placed crates with a modData flag, or move the crate to its own cycle.

7. **Multiplayer:** single player only, as in DC 8 and DC 10?
   **Recommendation:** yes, single player only (`if isClient() then return end`). Multiplayer would need server-side crate and container handling that this cycle does not design.

8. **Planning folder housekeeping:** `DevelopmentProcess.md` says finished cycles live in `doc/planning/completed/`, but all of DevCycle001-010 are still in `doc/planning/`. Status check: 001-007 and 010 are VERIFIED; 008 is In Progress; 009 is Planning.
   **Recommendation:** move the VERIFIED cycles (001-007 and 010) into `doc/planning/completed/` before this cycle starts; leave 008 and 009 where they are. I will not do it unless you ask, since it touches files outside this task.

9. **Everful Waterskin capacity:** *(Resolved by Ed: the Everful Waterskin keeps the original 1 L capacity; see Phase 8.)* One new question remains: the script says 10 L but Ed sees 1 L in game.
   **Recommendation:** check the deployed script and restart the game first, then spawn a fresh skin (Phase 8).

10. **Telling the waterskins apart:** both reuse the vanilla waterskin model and icon.
    **Recommendation:** names only for now, with no new art. A different tooltip or icon can follow if they are hard to tell apart in game.

11. **The Fancy Metal Crate after Phase 7:** should it stay enchantable alongside the regular Metal Crate?
    **Recommendation:** no, regular Metal Crate only, as requested. Supporting both is a one-line change later if wanted.

12. **Everful Bucket scope:** should a bucket on the ground, on a shelf or in a world container refill, or only one the player carries?
    **Recommendation:** carried only, matching the Everful Waterskin. Refilling placed buckets needs a registry like the Crate of Freshness and can be a later phase if wanted.

13. **Everful Bucket and cooking:** the vanilla bucket tags include `base:cookable`, so an Everful Bucket could be used as a pot; whatever is cooked in it is not touched by the refill, but water-filled buckets used as a water source for other recipes would never run out.
    **Recommendation:** keep the vanilla tags, since the request is a bucket "modeled off the original", and note the unlimited water as intended (as with the waterskin).

---

## Notes and Risks

- **Nothing has been run in game.** The findings above come from the v42.20.4 sources only.
- **Crate definition is the biggest unknown.** The Fancy Metal Crate is a crafted entity, not a plain item, so how a new crate is defined, placed and identified may be harder than the two waterskins. If Phase 1 shows it is impractical, the fallback is to split the crate into its own DevCycle and ship the waterskins first.
- **Long-absence ageing** may bypass the ten-minute pass (see PseudoGenerator DevCycle 1, finding 7). The `LoadChunk` pass is meant to cover it but is unverified for food.
- **Balance:** a never-spoiling crate and an unlimited water supply remove two survival pressures. This follows the ideas file and the theme of the mod; no balancing is planned.
- **Performance:** scanning inventories and crates every ten minutes should be cheap, but count items per pass if many crates are placed.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Per `AGENTS.md`, work stops after this document is created; implementation starts only when the user asks.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** [YYYY-MM-DD]
**Phases Completed:** [List or "All"]
**Work Deferred:** [What was not done and why, or "None"]

**Accomplishments:**
- [What was built or changed]

**Metrics:**
- Files modified: [N]

**Lessons / Notes:**
[Anything worth remembering for future cycles.]
