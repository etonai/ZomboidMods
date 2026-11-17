# Ring of the Mage: Automatic Cleaning, Code Analysis

**Created:** 2026-11-16
**Game build analysed:** v42.20.4 (`media42_20_4/lua/` and `zombie42_20_4/`)
**Purpose:** record how the game cleans the character, worn and carried clothing, weapons and containers, as the basis for giving the Ring of the Mage an automatic-cleaning power.
**Status:** analysis only. Nothing here has been run in game; every statement below comes from reading the source files named next to it.

---

## 1. Summary

- Cleaning in vanilla is done by two Lua timed actions, both started from the water-source context menu: `ISWashYourself` (the character's own body) and `ISWashClothing` (one item: clothing, container, weapon, or a dirty bandage/rag). Both need a water source (a sink or other fluid source) and use water; soap is optional.
- There is no Java "clean everything" call used by the game. The actions set stored blood/dirt values to 0 directly, then send the result to the server and other players.
- The data lives in three places, which is why cleaning needs several steps:
  1. the character's **body visual** (`HumanVisual`): blood and dirt per body part;
  2. each **clothing or container item's visual** (`ItemVisual`): blood and dirt per covered body part, plus two summary fields on `Clothing` (`dirtyness`, `bloodLevel`);
  3. each **weapon's** single `bloodLevel` (0 to 1).
- A ring power can do the same writes without water, soap or a timed action. The details that matter for doing it safely (which functions to call, what must be synced, single-player versus multiplayer) are in sections 6 and 7.

---

## 2. Where blood and dirt are stored

### 2.1 Body parts

Blood and dirt are tracked per `BloodBodyPartType` (the body-part list, `BloodBodyPartType.MAX` entries). Every visual stores one byte per part, so a value is a multiple of 1/255 in the range 0 to 1.

### 2.2 The character's body: `HumanVisual`

`zombie42_20_4/core/skinnedmodel/visual/HumanVisual.java`

| Method | Line | What it does |
|---|---|---|
| `setBlood(part, amount)` / `getBlood(part)` | 278 / 283 | clamps to 0..1, stores as a byte |
| `setDirt(part, amount)` / `getDirt(part)` | 287 / 292 | same, for dirt |
| `removeBlood()` | 304 | `Arrays.fill(blood, 0)`: clears every part at once |
| `removeDirt()` | 308 | `Arrays.fill(dirt, 0)`: clears every part at once |
| `getTotalBlood()` | 324 | sum over parts |

The character is reached from Lua with `playerObj:getHumanVisual()`. The game's own debug menu already clears blood this way (`client/DebugUIs/DebugMenu/General/ISDebugBlood.lua:79`: `playerObj:getHumanVisual():removeBlood()`).

### 2.3 Clothing and containers: `ItemVisual` plus summary fields

`zombie42_20_4/core/skinnedmodel/visual/ItemVisual.java`: `setBlood` (583), `setDirt` (600), `removeBlood()` (697) and `removeDirt()` (703) (also `Arrays.fill`).

`InventoryItem.getBlood/setBlood/getDirt/setDirt(part, amount)` (`InventoryItem.java:4156-4177`) just forward to the item's visual.

Which parts an item can hold blood or dirt on is defined by `BloodClothingType.getCoveredParts(item:getBloodClothingType())` (`characterTextures/BloodClothingType.java:80`), so washing code loops over the item's covered parts, not over all parts.

`Clothing` also keeps two **summary** fields, separate from the per-part visuals:

- `dirtyness` (`Clothing.java:66`), set with `setDirtiness` (771, clamped 0..100), shown in the tooltip as "Dirty" when 1.0 or more (191-197);
- `bloodLevel`, set with `setBloodLevel` (776, clamped 0..100), shown as "Bloody" (185-189).

Washing code clears both the per-part visuals and these summary fields (see 4.2).

`InventoryContainer` (bags) has no `dirtyness` field of its own. `getBloodLevel()` sums the per-part blood of its covered parts (`InventoryContainer.java:238-248`) and `setBloodLevel(delta)` writes the same value to every covered part (`:230-236`).

### 2.4 Weapons

`HandWeapon.bloodLevel` is a single float clamped to 0..1 (`HandWeapon.java:2284-2286`). Weapons have no per-part blood and no dirt.

### 2.5 Helpers on `InventoryItem`

- `hasBlood()` (`InventoryItem.java:4249`): for `Clothing`, true if any covered part has blood above 0 (and false if the item has no blood clothing type); other item types are handled further down the same method.
- `hasDirt()` (`:4278`): the same for `Clothing` and `InventoryContainer`.
- `isBloody()` (`:5236`): `getBloodLevel() > 0.25`.

---

## 3. How a character gets dirty and bloody

### 3.1 Dirt

`IsoGameCharacter.updateDirt()` (`IsoGameCharacter.java:9936-9998`), run for local players on the client side (`:9939`):

- running adds a random chance of 1 dirt (1 in about 3500 per frame-adjusted tick), sprinting adds 1-2 (1 in about 2500);
- body temperature above 37 C and above 38 C each add a chance of 1 dirt (about 1 in 5000 and 1 in 3000);
- only while moving: standing in puddles (`getPuddlesInGround() > 0.09`) or on muddy natural ground (outside, natural floor, wet-ground value above 0.5) adds dirt (about 1 in 1500 and 1 in 3000); being in trees adds a further chance.
- The first batch is applied with `addDirt(null, n, true)` (all clothing layers), the second with `addDirt(null, n, false)` (outer layer only). After adding dirt the player is synced with `player:syncVisuals()` (`:9992-9994`).

`addDirt(part, nbr, allLayers)` (`:13757`) picks a random body part for each unit and calls `BloodClothingType.addDirt` (`BloodClothingType.java:124`). The intensity added per unit depends on the sandbox option `clothingDegradation`: option value 2 gives 0.001-0.01, 3 gives 0.05-0.1, 4 gives 0.01-0.05, and any other value gives 0 (`BloodClothingType.java:125-130`). Dirt is only added to a part where the item has no hole (`getHole(part) == 0`).

### 3.2 Blood

`addBlood(part, scratched, bitten, allLayers)` (`IsoGameCharacter.java:13816`), called when the character is hit, bitten, scratched, or hits something. The number of splashes comes from the equipped weapon's `SplatNumber` (or 20 for a bite, 5 for a scratch, plus 8 for a zombie). While a hand weapon is equipped, **each random-part splash adds 0.02 to that weapon's blood level**, up to 1.0 (`:13849-13853`). Blood intensity per unit uses the same sandbox switch as dirt (`BloodClothingType.java:115-121`).

Other sources: vehicle impacts (`addBloodFromVehicleImpact`, `:15244`).

### 3.3 Wetness

Washing clothing also soaks it: `ISWashClothing.complete()` sets `item:setWetness(100)` for `Clothing` (`ISWashClothing.lua:140-143`). This is a side effect of washing, not part of "clean".

---

## 4. How the game cleans

### 4.1 Cleaning yourself: `ISWashYourself`

`media42_20_4/lua/shared/TimedActions/ISWashYourself.lua`

- **Needs:** a sink (`self.sink`): an `IsoObject` with fluid, or an `IsoWorldInventoryObject`. Water is drawn from it with `useFluid`. Soap is optional.
- **Water and soap cost:** `GetRequiredWater` (`:95`) = 1 unit per body part that has any blood or dirt. `GetRequiredSoap` (`:69`) = 1 unit per body part that has **blood**. Soap is only used for blood, not for dirt (`:37, :74`).
- **What it clears** (`washPart`, `:31-49`): for each part, `visual:setBlood(part, 0)` and `visual:setDirt(part, 0)` on the character's `HumanVisual`. If the part has blood, one use of the first drainable soap in the list is consumed (`soap:UseAndSync()`). If soap was used, `UNHAPPINESS` is reduced by 2 per part (`:122-124`).
- **Also:** `removeAllMakeup()` (`:51-67`) removes worn makeup items (full face, eyes, eye shadow, lips) from the character and deletes them from the inventory.
- **Sync:** `complete()` ends with `sendHumanVisual(self.character)` (`:133`).
- **Time:** `getDuration()` (`:153`): 126 ticks per water unit without soap, 70 with soap; 1 if the character has "timed action instant" (cheat/debug) set.
- **Only the body is cleaned here.** Worn clothing is not touched by this action; clothing is washed separately.

### 4.2 Cleaning an item: `ISWashClothing`

`media42_20_4/lua/shared/TimedActions/ISWashClothing.lua`

One action washes one item. The menu queues one action per item for the "wash all" entries.

- **Water cost** (`GetRequiredWater`, `:76-92`): `ceil(4 + blood*3 + dirt)`, where blood and dirt are summed over the item's covered parts for clothing and containers, and `blood = getBloodLevel()` for everything else (weapons, rags).
- **Soap cost** (`GetRequiredSoap`, `:56-74`): 1 unit per covered part with blood for clothing; 1 unit if `getBloodLevel() > 0` for other items.
- **Soap sources** (`GetSoapRemaining`, `:40-54`; `ItemContainer.getSoapList`, `ItemContainer.java:3794`): a `Soap2` drainable, or any fluid container holding at least 50% cleaning liquid (`Fluid.CleaningLiquid`). The search also looks inside equipped bags (`:3812-3818`). `useSoap` (`:94-123`) spends cleaning fluid (`ZomboidGlobals.CleanStainCleaningFluidAmount`) or one soap use. Without soap, washing still works but takes five times longer (`getDuration`, `:193-216`: time = (blood + dirt) * 15, capped to 500, multiplied by 5 with no soap, capped to 800, at least 100).
- **What it clears** (`complete()`, `:125-175`):
  - **Clothing and containers** (`:129-143`): for each covered part, `item:setBlood(part, 0)` and `item:setDirt(part, 0)`. For `Clothing` only, also `item:setWetness(100)` and `item:setDirtiness(0)`.
  - **Anything else with `getItemAfterCleaning()`** (dirty bandages, rags, strips): the item is removed from the inventory and replaced by the clean version (`:144-151`); the favourite flag is copied over.
  - **Everything else** (weapons): only `useSoap(item, nil)`.
  - **All paths then call `item:setBloodLevel(0)`** (`:156`). For a weapon this is the whole clean. For `Clothing` it clears the summary field; for a container it writes 0 to every covered part.
- **Sync** (`:158-170`): `syncItemFields(self.character, item)` (unless the item was removed), `syncVisuals(self.character)`, `self.character:updateHandEquips()`, and re-setting the item in the primary/secondary hand if it is held. `perform()` calls `self.character:resetModel()` and fires the `OnClothingUpdated` event (`:186-187`).
- **Validity** (`isValid`, `:5-14`): there must be enough water in the sink, and the item must be in the character's own inventory.

### 4.3 The menu: which items can be washed

`zombie42_20_4/iso/ISWorldObjectContextMenuLogic.java`, `doWashClothingMenu` (`:4595`):

- Only offered when the water source is in the same building as the player (`:4596`).
- **Clothing:** items in the player's main inventory of category `Clothing` that are not hidden, have blood or dirt, and do not have the tag `BREAK_WHEN_WET` (`:4603-4615`).
- **Other washable items:** items with the tag `CAN_BE_WASHED` (dirty bandages and rags) that are not currently mid-job (`:4618-4630`).
- **Weapons:** items of category `Weapon` that have blood (`:4633-4645`).
- **Containers:** items of category `Container` that are not hidden and have blood or dirt (`:4648-4657`).
- The lookups use `getItemsFromCategory` (non-recursive, `ItemContainer.java:3103`, `:1692`), so **only items directly in the main inventory are listed**. That includes worn clothing and worn bags (they stay in the main inventory) but not items inside a bag. There is a separate recursive lookup, `getAllCategoryRecurse` (`ItemContainer.java:1699`).
- Entries: "Wash yourself" if `ISWashYourself.GetRequiredWater > 0`; "all clothing", "all containers", "all weapons", "all bandages" groups, and one entry per item (`:4669-4900`).
- Washing machines are a separate path: `ClothingWasherLogic.java` removes blood and dirt from clothing in the machine over time (blood and dirt each reduced by `elapsedMinutes * 2 / 100` per part at `:143-165`, weapons/containers by the same rate at `:128`). It does not clean the character and is not relevant to a ring power.

### 4.4 Other cleaning that is not about the character

- `ISCleanBlood` (`shared/TimedActions/ISCleanBlood.lua:106`): removes blood splats from the floor square (`square:removeBlood(false, false)`), and `ISWashVehicle` cleans vehicles. Neither affects the character.
- Bandages: `ISCleanBandage` (referenced from the world menu) turns a dirty bandage into a clean one; this is separate from wound handling.

---

## 5. Cleaning by hand in code: what each target needs

This table lists the writes the vanilla actions perform, for use as a checklist.

| Target | Read | Clear | Extra |
|---|---|---|---|
| Character body | `humanVisual:getBlood(part)`, `getDirt(part)` over `BloodBodyPartType` | `humanVisual:removeBlood()` and `removeDirt()` (all parts at once), or `setBlood/setDirt(part, 0)` per part | sync the human visual |
| Worn or carried clothing | `item:hasBlood()`, `item:hasDirt()` | per covered part `item:setBlood(part, 0)`, `item:setDirt(part, 0)`, then `item:setDirtiness(0)` and `item:setBloodLevel(0)` | sync the item fields and the player's visuals; clothing model refresh |
| Containers (bags) | `item:hasBlood()`, `item:hasDirt()` | per covered part `setBlood/setDirt(part, 0)`, then `item:setBloodLevel(0)` | sync item fields |
| Weapons | `item:getBloodLevel()` or `hasBlood()` | `item:setBloodLevel(0)` | sync item fields; refresh equipped model if held |
| Dirty rags / bandages | `item:getItemAfterCleaning()` | replace by the clean item type | inventory remove/add sync |

`ItemVisual.removeBlood()` and `removeDirt()` (`ItemVisual.java:697-707`) clear every part of an item's visual in one call, but the vanilla actions do not use them; they loop over the covered parts. They are not checked for side effects here (see section 8).

---

## 6. Synchronisation and where the code runs

This matters for a ring power that runs automatically.

- **Timed actions run on the server in multiplayer.** `ISWashYourself:complete()` and `ISWashClothing:complete()` are the "complete" side of the action, which the server executes; `isValid` is also checked on the server (`ISWashClothing.lua:10`).
- **The Lua globals differ by side.** In `LuaManager.java`, the global `syncVisuals(player)` (`:3881-3886`) and `sendHumanVisual(player)` (`:7689-7694`) only act when running on the **server** (`if (GameServer.server)`); on a client they do nothing. From client code the equivalent is the `IsoPlayer` method `player:syncVisuals()` (`IsoPlayer.java:9052-9061`): on a client it sends the clothing, visuals and human-visual packets for the local player; on the server it calls `GameServer.syncVisuals` and `syncHumanVisual`.
- **Dirt accumulation is done on the client** for the local player, then synced with `player:syncVisuals()` (`IsoGameCharacter.java:9939, 9992-9994`). So the owning client is authoritative for its own player's visuals and can both add and remove blood and dirt, and then push the result.
- **Item fields:** `InventoryItem.syncItemFields()` (`InventoryItem.java:4699`) sends a `SyncItemFields` packet if the item is in a player's inventory (client sends to server, server sends to that player). The global `syncItemFields(player, item)` (`LuaManager.java:10266`) is what `ISWashClothing` calls. `SyncVisualsPacket` carries per-part item visual values plus `dirtiness` and `bloodLevel` for clothing and `bloodLevel` for weapons (`SyncVisualsPacket.java:95-121`).
- **Model refresh:** after a clean the vanilla action calls `resetModel()` / `resetModelNextFrame()` and triggers `OnClothingUpdated` so the on-screen model updates. `addDirt` and `addBlood` use `updateModelTextures = true` and trigger `OnClothingUpdated` for local players (`IsoGameCharacter.java:13779-13782`).

---

## 7. Where the mod can hook in, and relevant existing mod code

The mod already has several Ring of the Mage powers, which give working patterns:

- **Detecting the ring.** Two patterns are in use:
  - worn ring: `PseudoMagicFlight.lua:55-63` loops over `player:getWornItems()` and matches the four ring full types;
  - ring anywhere in the inventory: `PseudoMagicFreshness.lua:142-150` and `PseudoMagicMenu.lua:67-83` (the ring items carry the `START_FIRE` tag, found with `getAllTagRecurse`).
  The ring full types are `PseudoMagic.RingOfTheMage{Right,Left}{MiddleFinger,RingFinger}`.
- **Periodic work.** `PseudoMagicFreshness.lua:115, 135` runs a pass every ten in-game minutes with `Events.EveryTenMinutes`; `PseudoMagicEverfulRefill.lua:40-48` does the same; `PseudoMagicLightBallServer.lua:54-86` uses `Events.EveryOneMinute` (server and single-player only). `PseudoMagicFlight.lua:234` uses `Events.OnPlayerUpdate` (every frame).
- **Client or server.** The existing player-power scripts that act on the local player (flight, everful refill) are client-side scripts.

Natural places for a cleaning power:

1. **A timer event.** `EveryOneMinute` or `EveryTenMinutes` (cheap, lets dirt build up between passes, so the cleaning is visible as "gets cleaned shortly after"), or `OnPlayerUpdate` throttled by a counter (continuous, never visibly dirty, but runs every frame).
2. **A reaction to dirt being added.** The game fires `OnClothingUpdated` for local players when dirt or blood is added (`IsoGameCharacter.java:13781, 13810, 13861`). A handler on that event could clean immediately, but it also fires for many other reasons (equip, wash, damage), so it needs a guard against doing needless work or re-entering itself. This hook is not tested.
3. **A menu action instead of automatic.** A "Cleanse" entry in the Ring menu (next to Summon, Bind Location, Teleport) calling the same cleaning function. This is not what was asked, but the cleaning function would be the same, and it is useful for testing before wiring a timer.

---

## 8. Design points and open questions for the ring power

These are points the analysis raises. None are decided.

1. **What counts as "the character"?** The request is to clean the character automatically. The minimum is the body (`ISWashYourself` equivalent). The vanilla game treats clothes, containers and weapons as separate wash actions with separate costs. Decide whether the ring cleans only the body, or the body plus worn clothing, plus carried items.
   - Worn clothing cleans its blood and dirt per covered part (section 5). Note that **the body visual and the worn clothing visuals are different data**: clearing only the body leaves a bloody shirt still showing blood.
   - Containers: only worn bags matter visually; bags in the inventory have blood values but are not drawn on the character.
   - Weapons: only the weapon in hand shows blood; any carried weapon can hold a blood level.
ALL
2. **Scope of items.** Items directly in the main inventory only (as the vanilla menu does), or also items inside bags (`getAllCategoryRecurse`)? Recursing visits every item in every bag on each pass, which costs more on a character carrying a lot; this has not been measured.
3. **Wetness.** Vanilla washing sets clothing wetness to 100 (`ISWashClothing.lua:141`). A magic clean most likely should not make clothes wet; simply not calling `setWetness` avoids it. Confirm that is the intent.
CONFIRMED
4. **Makeup.** `ISWashYourself` removes worn makeup (`removeAllMakeup`, `:51-67`). A cleaning ring would remove the player's makeup if it copied that; decide whether it should. The simplest option is to leave makeup alone.
LEAVE MAKEUP ALONE
5. **Dirty bandages and rags.** Vanilla turns them into clean ones via `getItemAfterCleaning()`. The ring probably should not touch bandages already on wounds; applying it to carried rags is optional and needs inventory add/remove sync.
6. **Wounds and infection are out of scope.** Cleaning blood does not touch wounds, bleeding or infection; those are body-damage state, not visuals. Confirm the power should not affect them.
7. **Costs and balance.** Vanilla uses water, soap and time. A ring power is free by default. Options: free; free but only while the ring is worn; limited by a delay; limited by a cost (for example a small amount of the ring's own charge, if rings have one).
8. **Timing.** Instantly (immediately after dirt is added) or periodically? Instant cleaning means the character is never visibly dirty or bloody, which may remove blood-based gameplay (for example the sight of blood on clothes, `isBloody()` is true above 0.25 blood). A periodic pass is gentler.
9. **Sandbox options.** `clothingDegradation` controls how much dirt and blood is added (section 3.1) and can be 0 in a game, in which case nothing accumulates. The power should not assume there is always something to clean.
10. **Multiplayer.** Because the owning client is authoritative for its own visuals, a client-side script that clears values and then calls `player:syncVisuals()` plus item syncs follows the same path as the game's own dirt accumulation. Whether this behaves correctly on a dedicated server has not been tested. The existing light ball code shows the mod already has a server-and-client split if one is needed.
11. **Untested calls.** `HumanVisual.removeBlood()/removeDirt()` and `ItemVisual.removeBlood()/removeDirt()` are simple array clears, but this analysis has not checked whether they miss any side effect that `setBlood(part, 0)` per part would not (for example a texture refresh flag). The vanilla actions use the per-part calls, so those are the safer reference pattern.

---

## 9. Source files read

Lua (`media42_20_4/lua/`):

- `shared/TimedActions/ISWashYourself.lua`
- `shared/TimedActions/ISWashClothing.lua`
- `shared/TimedActions/ISCleanBlood.lua` (floor, not the character; referenced only)
- `client/DebugUIs/DebugMenu/General/ISDebugBlood.lua` (referenced)
- `client/ISUI/ISWorldObjectContextMenu.lua` (`calculateSoapAndWaterRequired`, `onWashClothing`, `onWashYourself`, lines 1782-1840)

Java (`zombie42_20_4/`):

- `core/skinnedmodel/visual/HumanVisual.java`, `ItemVisual.java`
- `inventory/InventoryItem.java`, `ItemContainer.java`
- `inventory/types/Clothing.java`, `InventoryContainer.java`, `HandWeapon.java`
- `characterTextures/BloodClothingType.java`
- `characters/IsoGameCharacter.java` (`updateDirt`, `addDirt`, `addBlood`), `characters/IsoPlayer.java` (`syncVisuals`)
- `iso/ISWorldObjectContextMenuLogic.java` (`doWashClothingMenu`)
- `iso/objects/ClothingWasherLogic.java`
- `network/packets/SyncVisualsPacket.java`
- `Lua/LuaManager.java` (`syncVisuals`, `sendHumanVisual`, `syncItemFields` Lua globals)

Mod files (`PseudoMagic/42/media/lua/client/PseudoMagic/`): `PseudoMagicFlight.lua`, `PseudoMagicFreshness.lua`, `PseudoMagicEverfulRefill.lua`, `PseudoMagicMenu.lua`; `lua/server/PseudoMagicLightBallServer.lua`.
