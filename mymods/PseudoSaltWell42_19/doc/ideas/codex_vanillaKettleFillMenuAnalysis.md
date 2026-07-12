# Vanilla Kettle Fill Menu Analysis

**Created:** 2026-07-12  
**Author:** Codex  
**Mod:** PseudoSaltWell42_19  
**Focus:** How the mod decides whether to show `Fill Kettle with Saltwater`, with special attention to vanilla kettle inventory detection and empty-state detection.

---

## Short Answer

The `Fill Kettle with Saltwater` option is created entirely by the mod's Lua context-menu code in:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/client/WellFillMenu.lua`

The game does not automatically infer this saltwater action from the vanilla kettle item. Instead, the mod does this:

1. Checks that the clicked world object list contains an object named `SaltwaterWell`.
2. Scans the player's inventory recursively.
3. For each inventory item, calls `getContainerData(item)`.
4. If an item is recognized as a kettle and is empty, it is added to the `containers.kettle` list.
5. If `containers.kettle` has at least one entry, the mod adds the `Fill Kettle with Saltwater` submenu.
6. Each submenu entry queues `ISFillKettleFromWell` and replaces the selected kettle with a saltwater kettle item.

The normal kettle works because `Base.Kettle` is explicitly mapped to `kettleData` in `WellFillMenu.ContainerTypes`.

---

## Vanilla Kettle Definitions

The relevant vanilla definitions are in:

- `media/scripts/generated/items/normal.txt`

### Normal Kettle

At `media/scripts/generated/items/normal.txt:4105`, vanilla defines:

```txt
item Kettle
{
    DisplayCategory = Cooking,
    ItemType = base:normal,
    PourType = Kettle,
    Icon = Kettle,
    IsCookable = true,
    Tags = base:cookable;base:hasmetal;base:smeltableironsmall,
    component FluidContainer
    {
        ContainerName = Kettle,
        Capacity = 1.5,
        TransferRate = 2.0,
    }
}
```

Important properties for this mod:

- The full runtime id should be `Base.Kettle`.
- `getType()` should be `Kettle`.
- `getPourType()` should be `Kettle`.
- It has a `FluidContainer` component.
- Empty-state can be checked through `item:getFluidContainer():isEmpty()`.

### Copper Kettle

At `media/scripts/generated/items/normal.txt:4130`, vanilla defines:

```txt
item Kettle_Copper
{
    DisplayCategory = Cooking,
    ItemType = base:normal,
    PourType = Kettle,
    Icon = CopperKettle,
    StaticModel = Kettle_Copper,
    WorldStaticModel = Kettle_Copper,
    IsCookable = true,
    Tags = base:cookable;base:hasmetal;base:scraplargecopper,
    component FluidContainer
    {
        ContainerName = Kettle_Copper,
        Capacity = 1.5,
        TransferRate = 2.0,
    }
}
```

Important comparison:

- Copper kettle is also a kettle-like fluid container.
- It also has `PourType = Kettle`.
- Its expected full id is `Base.Kettle_Copper`.
- Its expected bare type is `Kettle_Copper`.
- Its fluid container name differs: `ContainerName = Kettle_Copper` instead of `ContainerName = Kettle`.

Based on the vanilla item script alone, copper kettle should be detectable as a kettle-like item.

---

## Mod Kettle Recognition

The recognition table is in `WellFillMenu.lua`.

The normal kettle path is:

```lua
local kettleData = {
    group = "kettle",
    saltwaterType = "PseudoSaltWellB42.SaltwaterKettle",
    action = ISFillKettleFromWell,
};

WellFillMenu.ContainerTypes = {
    ["Base.Kettle"] = kettleData,
    ["Kettle"] = kettleData,
}
```

The copper kettle path is currently separate:

```lua
local copperKettleData = {
    group = "kettle",
    saltwaterType = "PseudoSaltWellB42.SaltwaterKettleCopper",
    action = ISFillKettleFromWell,
};

WellFillMenu.ContainerTypes = {
    ["Base.Kettle_Copper"] = copperKettleData,
    ["Kettle_Copper"] = copperKettleData,
}
```

So both normal kettle and copper kettle should end up in the same `group = "kettle"`, but they produce different saltwater items.

---

## How the Mod Knows There Is a Kettle in Inventory

The inventory scan happens in `collectFillableContainers(playerObj)`:

```lua
local allItems = playerObj:getInventory():getAllEvalRecurse(function(item)
    return getContainerData(item) ~= nil;
end);
```

This means:

- The mod asks the player's inventory for every item that passes the predicate.
- `getAllEvalRecurse` is recursive, so items in nested inventory containers should also be considered.
- The predicate does not directly ask for `Base.Kettle`; it asks whether `getContainerData(item)` recognizes the item.

After that, the matching items are grouped:

```lua
local containerData = getContainerData(item);
if containerData then
    table.insert(containers[containerData.group], { item = item, data = containerData });
end
```

For a normal kettle, `containerData.group` is `"kettle"`, so the item lands in `containers.kettle`.

---

## How the Mod Knows the Kettle Is Empty

The empty check is currently in `getContainerData(item)`:

```lua
if item:getFluidContainer() and not item:getFluidContainer():isEmpty() then
    return nil;
end
```

This means:

- If the item has a fluid container and it is not empty, the item is rejected.
- If the item has a fluid container and it is empty, matching continues.
- If the item does not have a fluid container, the check does not reject it. That is useful for legacy or odd script items, but it also means exact type matches can still pass without a fluid container.

For vanilla `Base.Kettle`, the expected path is:

1. `item:getFluidContainer()` returns the kettle's fluid container.
2. `isEmpty()` returns true for an empty kettle.
3. The item is not rejected.
4. `item:getFullType()` returns `Base.Kettle`, or `item:getType()` returns `Kettle`.
5. `WellFillMenu.ContainerTypes[...]` returns `kettleData`.

For a filled kettle, step 2 returns false, so the item is rejected and the menu option should not appear for that kettle.

---

## How the Menu Item Appears

The world-object context-menu hook is registered at the bottom of `WellFillMenu.lua`:

```lua
Events.OnFillWorldObjectContextMenu.Add(WellFillMenu.createMenu);
```

`WellFillMenu.createMenu(...)` does the gatekeeping:

```lua
if not findSaltwaterWell(worldobjects) then return end

local containers = collectFillableContainers(playerObj);

if #containers.pot > 0 or #containers.kettle > 0 or #containers.bucket > 0 then
    if test then return ISWorldObjectContextMenu.setTest() end
end

WellFillMenu.addFillSubMenu(context, worldobjects, player, getText("ContextMenu_FillKettleWithSaltwater"), containers.kettle);
```

So `Fill Kettle with Saltwater` is available only when:

- The clicked world object list includes the saltwater well object.
- `collectFillableContainers()` finds at least one recognized empty kettle item.
- `containers.kettle` has at least one entry.

The actual submenu label comes from:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/Translate/EN/ContextMenu.json`

```json
"ContextMenu_FillKettleWithSaltwater": "Fill Kettle with Saltwater"
```

---

## What Happens After Selecting a Kettle

The submenu item calls:

```lua
WellFillMenu.onFillContainer(worldobjects, container, player, containerData)
```

For a normal kettle, `containerData` is `kettleData`, so the queued action is:

```lua
ISFillKettleFromWell:new(playerObj, well, container, 100, "PseudoSaltWellB42.SaltwaterKettle")
```

The timed action is in:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillKettleFromWell.lua`

Its validity check is:

```lua
return self.well ~= nil and self.kettle ~= nil and self.kettle:getContainer() ~= nil and self.saltwaterType ~= nil;
```

Its `perform()` removes the original kettle from its current inventory container and adds the saltwater item to the player's main inventory:

```lua
self.kettle:getContainer():Remove(self.kettle);
local saltwaterKettle = self.character:getInventory():AddItem(self.saltwaterType);
```

For normal kettle, the added item is:

- `PseudoSaltWellB42.SaltwaterKettle`

For copper kettle, the intended added item is:

- `PseudoSaltWellB42.SaltwaterKettleCopper`

---

## Mod Saltwater Kettle Items

The normal saltwater kettle item is in:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt:99`

It uses:

```txt
item SaltwaterKettle
{
    ReplaceOnUse = Kettle,
    ReplaceOnCooked = PseudoSaltWellB42.SaltKettle,
    Icon = Kettle,
    StaticModel = Kettle,
    WorldStaticModel = KettleGround,
}
```

The copper saltwater kettle item is in:

- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt:147`

It uses:

```txt
item SaltwaterKettleCopper
{
    ReplaceOnUse = Base.Kettle_Copper,
    ReplaceOnCooked = PseudoSaltWellB42.SaltKettleCopper,
    Icon = CopperKettle,
    StaticModel = Kettle_Copper,
    WorldStaticModel = Kettle_Copper,
}
```

The difference matters: the normal kettle path creates a custom item that already existed and is known to work, while copper kettle creates a newer custom item. If the menu recognizes the copper kettle but the target item is invalid or unavailable, the action may fail later. However, menu visibility itself should depend on recognition, not on successfully creating the target item.

---

## Current Copper Kettle Hypothesis

From the code and vanilla definitions, a vanilla `Base.Kettle_Copper` should satisfy the same broad conditions as `Base.Kettle`:

- It has `PourType = Kettle`.
- It has a fluid container.
- It is cookable.
- It has a valid item id.

If `Base.Kettle` appears but `Base.Kettle_Copper` does not, the most useful next diagnostic is to log what the runtime inventory item reports during `collectFillableContainers()`:

```lua
print("PseudoSaltWell item", tostring(item:getFullType()), tostring(item:getType()), tostring(item:getPourType()), tostring(item:getEatType()), tostring(item:getFluidContainer()), item:getFluidContainer() and tostring(item:getFluidContainer():isEmpty()))
```

That would answer whether the copper kettle is:

- absent from the scanned inventory list,
- reporting a different full type/type than expected,
- reporting a non-empty fluid container,
- throwing an error when a getter is called,
- or being recognized but not displayed for another reason.

Without runtime logging, the static code says the copper kettle should be recognized by at least one of these checks:

```lua
WellFillMenu.ContainerTypes["Base.Kettle_Copper"]
WellFillMenu.ContainerTypes["Kettle_Copper"]
pourType == "Kettle"
```

---

## Key Takeaways

- The normal kettle works because the mod explicitly recognizes `Base.Kettle` / `Kettle` and maps it to `kettleData`.
- The game knows a kettle is in inventory because the mod calls `playerObj:getInventory():getAllEvalRecurse(...)` and filters each item through `getContainerData(item)`.
- The mod knows a kettle is empty by checking `item:getFluidContainer():isEmpty()`.
- The menu appears when `containers.kettle` contains at least one recognized empty kettle and the clicked world object is the saltwater well.
- Vanilla `Kettle_Copper` is also kettle-like in the item scripts, so static analysis does not explain why it fails while `Kettle` works.
- The next best diagnostic is runtime logging of copper kettle item properties inside `collectFillableContainers()`.