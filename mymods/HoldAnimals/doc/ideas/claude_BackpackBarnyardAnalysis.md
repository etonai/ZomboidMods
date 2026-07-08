# Backpack Barnyard: Mechanics Analysis for HoldAnimals

**Created:** 2026-07-07
**Source mod:** `notmymods/Backpack Barnyard` (author: YumiNekoGirl, modversion=6.0, versionMin=42.16)
**Purpose:** Understand how Backpack Barnyard lets players carry multiple animals, so HoldAnimals can reuse the same core trick (multiple `Base.Animal` inventory items) while dropping the weight-nullification behavior.

This is an analysis-only document. No implementation has started; HoldAnimals currently contains only a skeleton `mod.info` and poster.

---

## 1. The core trick: `Base.Animal` inventory items

Project Zomboid already ships an item type, `Base.Animal`, backed by the Java class `AnimalInventoryItem`, which can hold a reference to a live `IsoAnimal` via `item:setAnimal(animal)` / `item:getAnimal()`. Vanilla only ever puts one of these in a hand slot at a time (the "carry animal" action). Backpack Barnyard's entire mod is built around instantiating this item type and dropping it into a normal inventory container instead of a hand slot:

```lua
local inventoryItem = instanceItem("Base.Animal")
inventoryItem:setAnimal(self.animal)
AnimalWeightUtils.applyWeight(inventoryItem)
self.character:getInventory():AddItem(inventoryItem)
```

(`42/media/lua/client/TimedActions/ISPickupAnimal.lua:60-65`)

Because `Base.Animal` is a real inventory item, PZ's normal container rules apply to it once it's created — it can sit in the main inventory, in a worn bag, in hands, etc. There is nothing else "special" required to hold more than one: vanilla doesn't stop you from having multiple `Base.Animal` items in inventory simultaneously — it just never gives the player a way to create more than one at a time because the pickup action forces the item into both hands and vanilla weight makes a second one unbearable. Backpack Barnyard removes the hand-forcing and the weight, and that's sufficient to get "hold N animals."

**Implication for HoldAnimals:** The multi-animal-carrying capability is not something HoldAnimals needs to build — it already exists in vanilla `Base.Animal`/`AnimalInventoryItem`. The mod's job is narrower: (a) create a `Base.Animal` item into inventory instead of forcing hands, and (b) decide what to do about weight (Backpack Barnyard zeroes it; HoldAnimals will not).

## 2. Where animals get picked up (three entry points)

Backpack Barnyard hooks three separate pickup paths, all converging on the same "make a `Base.Animal` item, put it in inventory" pattern:

1. **World right-click pickup** — `AnimalContextMenu_Extended.lua` adds a "Pick Up Animal" option to `OnFillWorldObjectContextMenu`, and also wraps `AnimalContextMenu.doMenu` (the vanilla animal-specific context menu) to inject the same option. Both funnel into `ISPickupAnimal:new(playerObj, animal)` queued via `ISTimedActionQueue`.
2. **Single-player batch pickup** — `BB_SPBatchPickupAnimals.lua` scans a radius (clamped 1-12 tiles, default 4) around the player for `IsoAnimal` instances on grid squares (`square:getAnimals()` and `square:getMovingObjects()`), and adds a "Pick Up Nearby Animals (N)" menu option that instant-creates inventory items for all of them in one call (`BBSP.pickupNearby`), bypassing the timed action entirely. Explicitly gated to single-player only (`isMPClient()`/`isClient()` checks) — the author didn't attempt to make batch pickup MP-safe.
3. **Vehicle/trailer removal** — `ISRemoveAnimalFromTrailer.lua` (a copy of the vanilla timed action) is modified so that when `self.grab` is true, the animal removed from a vehicle's animal trailer becomes an inventory item instead of being placed in both hands. It also handles the `IsoDeadBody` case (dead animal corpses) by grabbing the existing corpse item directly.

**Implication for HoldAnimals:** Since the stated goal is narrower ("easily move chicks around"), HoldAnimals likely only needs entry point #1 (single/world pickup), possibly with a simplified version of #2 if picking up multiple chicks at once is desired. The trailer-grab path (#3) is probably out of scope unless chick-moving specifically involves vehicles.

## 3. The weight-zeroing system (the part HoldAnimals will NOT copy)

`AnimalWeightUtils.lua` is the shared utility all pickup paths call through. Its job is to detect "is this item an animal" and then flatten every weight-related field to near zero:

```lua
AnimalWeightUtils.TARGET_WEIGHT = 0.01
...
function AnimalWeightUtils.applyWeight(item)
    if not AnimalWeightUtils.isAnimalItem(item) then return item end
    local w = AnimalWeightUtils.TARGET_WEIGHT
    callSetter(item, "setActualWeight", w)
    callSetter(item, "setWeight", w)
    callSetter(item, "setCustomWeight", true)
    callSetter(item, "setUnequippedWeight", w)
    callSetter(item, "setEquippedWeight", w)
    callSetter(item, "setContentsWeight", 0)
    callSetter(item, "setKeyWeight", w)
    callSetter(item, "setCanBeEquipped", "")
    callSetter(item, "setTwoHandWeapon", false)
    callSetter(item, "setRequiresEquippedBothHands", false)
    return item
end
```

(`42/media/lua/shared/PutAnimalsInBags/AnimalWeightUtils.lua:66-81`)

Every animal item is forced to `0.01` weight (`TARGET_WEIGHT`) on all weight fields PZ exposes, and `setCanBeEquipped("")`/`setTwoHandWeapon(false)`/`setRequiresEquippedBothHands(false)` strip the two-handed equip requirement so it doesn't even try to occupy both hand slots. This is applied:
- immediately after creating the item (pickup),
- recursively down the player's entire inventory tree (`applyWeightDeep`, walking nested containers) on every player-created / game-start event,
- again after any inventory move (`move_animals.lua`'s "Move Animal To" submenu),
- again after batch pickup.

The recursive re-application on `OnCreatePlayer`/`OnGameStart` suggests the author found that PZ doesn't always persist custom weight overrides reliably across save/load, hence re-stamping every animal item in the player's inventory tree at game start as a defensive measure.

`isAnimalItem` uses a layered detection strategy — `instanceof(item, "AnimalInventoryItem")`, fulltype/type/category checks, `getAnimal() ~= nil`, mod-data flags, and finally a substring match against a hardcoded list of animal-related words in the item name (`cow`, `chicken`, `piglet`, etc.) as a last-resort fallback. This heavy-handed detection exists because the item can arrive from several different code paths (fresh pickup, trailer removal, batch pickup, MP sync) and the author wanted `applyWeight` to be safely callable on anything without knowing its provenance.

**Implication for HoldAnimals:** Since HoldAnimals will *not* reduce weight, this entire utility (and its four call sites) is the one piece of Backpack Barnyard's design to explicitly not port over. Full-grown livestock (cows, pigs) will therefore remain effectively uncarryable in numbers under real weight — which is fine, since the stated use case is chicks, which are light to begin with. This means HoldAnimals's design goal is naturally self-limiting: only lightweight animals are practical to carry multiples of, without any code needing to enforce that — vanilla weight/encumbrance does it for free.

## 4. Secondary systems (context menu polish, trailer capacity, MP awareness)

These are supporting conveniences layered on top of the core trick; likely not needed for a narrow "move chicks around" mod but worth being aware of:

- **`move_animals.lua`** — Adds a "Move Animal To" submenu (`OnFillInventoryObjectContextMenu`) letting the player relocate an already-held animal item between the main inventory and any worn/held container, re-stamping weight and refreshing inventory UI panels after each move.
- **`BB_LivestockTrailer_10M.lua`** — Unrelated to inventory carrying; patches `ISVehicleMenu`/`ISVehicleAnimalUI` to raise vehicle animal-trailer capacity from vanilla ~500 to 50,000,000 and exposes inventory-held animals as trailer-loadable options. Out of scope for HoldAnimals.
- **MP awareness** — Batch pickup is explicitly single-player-only (checked via `isMPClient()`/`isClient()`). The core pickup/weight utilities appear MP-agnostic (they operate on `self.character`/`playerObj` passed in, not global state), but the author never built server-authoritative batch pickup, implying batch pickup over multiplayer needs sync work the author didn't attempt. If HoldAnimals is single-player-only (per `AGENTS.md`/project scope), this isn't a concern.
- **mod-data flags** (`BBMP_ServerBatchPickup`, `BB_SPBatchPickup`, etc.) — vestiges of an abandoned/partial multiplayer batch-pickup feature, used only by `isAnimalItem`'s detection fallback. Not needed if HoldAnimals doesn't attempt MP batch pickup.

## 5. Minimal shape for HoldAnimals

Based on the above, a minimal HoldAnimals implementation that satisfies "carry more than one animal, without messing with weight, mainly for moving chicks" needs only:

1. A timed action (or direct `instanceItem("Base.Animal")` + `setAnimal()` + `AddItem()`, if a chick is light enough to skip the timed-action ceremony) that creates a `Base.Animal` inventory item from a world `IsoAnimal` and adds it to the player's inventory instead of forcing both hands — essentially `ISPickupAnimal.lua` minus every `AnimalWeightUtils` call.
2. A context menu hook (`OnFillWorldObjectContextMenu`, and optionally wrapping `AnimalContextMenu.doMenu`) so "Pick Up Animal" appears and queues that action.
3. No weight utility at all — vanilla `Base.Animal` weight (which vanilla presumably already sets per animal type/age) is left untouched, so carrying capacity is naturally gated by encumbrance. This is the intentional divergence from Backpack Barnyard.
4. (Optional, only if useful for chick-herding) A "put an already-held animal back down" / release action, and possibly a small-radius batch pickup for grabbing a whole clutch of chicks at once — Backpack Barnyard's `BB_SPBatchPickupAnimals.lua` is a reasonable reference if this is wanted, minus its `AnimalWeightUtils.applyWeight` calls.

Not needed: trailer capacity changes, the "Move Animal To" submenu (nice-to-have, not core), MP batch-pickup mod-data flags, or the animal-name-substring fallback detection (only necessary because Backpack Barnyard's weight utility must be safely callable from many contexts — HoldAnimals doing less work has less need for that).
