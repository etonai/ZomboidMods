# Idea: Ring of the Mage Storage ("Store" and "Recall")

**Created:** 2026-11-12
**Game build checked against:** v42.20.4 (`zombie42_20_4/` Java, `media42_20_4/` Lua)
**Status:** Idea / feasibility study only. Nothing here is implemented.

## The Question

How feasible is it for the Ring of the Mage to make items disappear from the inventory, then bring them back through a menu? For example: the character finds a gold necklace, uses the ring to "store" it, the necklace is gone from the inventory, and later a ring menu item "Recall Gold Necklace" brings it back. Requirements:

1. The ring can store many items.
2. If an item has a status (condition, for example), the exact same status is restored when it is recalled.

## Short Answer

**Feasible, and not hard, if we store the real item object instead of copying its fields.** The game already saves any item sitting inside a container with all of its state, so an item moved into a hidden container and moved back out comes back exactly as it left. The tempting alternative, writing the item's fields into mod data and rebuilding the item later, is feasible for condition alone but becomes a long, error-prone list for full fidelity.

| Approach | Exact state restored | Effort | Main risk |
|----------|----------------------|--------|-----------|
| A. Hidden container holding the real items | Yes, automatic | Low to medium | Hiding it from the UI, multiplayer sync, items still count as "carried" |
| B. Copy each item's fields into mod data and rebuild | Only for the fields we write code for | High | Missing fields, per-item-type special cases, other mods' data |
| C. Binary save of the item to a string | Would be exact | Not possible from Lua | The save methods are not available to Lua |

Recommendation: **Approach A.**

---

## What I Verified in the Game Code

### Items cannot be serialized from Lua (rules out approach C)

`InventoryItem.save(ByteBuffer, boolean)` and `InventoryItem.loadItem(ByteBuffer, ...)` exist (`InventoryItem.java:1663, 1875`), and the save writes uses, condition, visual (holes, patches, dirt, blood), colour, and more. But `ByteBuffer` is not exposed to Lua: there is no Lua use of it in `media42_20_4/lua`, and `LuaManager.java` only references the network writer. So a mod cannot turn an item into a saved string. (A Java-level mod is not an option for a normal Workshop mod.)

### Vanilla copies items field by field, and shows how long that list is (approach B)

When the player swaps a ring to a different finger, vanilla replaces the item with a new one and copies state by hand (`ISClothingExtraAction.lua`, `createItemNew`): tint, base texture, texture choice, decal, colour, dirt, blood, holes, patches, wetness, fluids, condition, favourite flag, alarm clock settings, mod data, and container contents (`takeItemsFrom`). Even this vanilla list is only for clothing and a few special types. It does not cover food age and cooked state, weapon sharpness and head condition, drainable uses, keys, maps, radios, and so on. A general "store anything and get it back identical" feature built this way would need a handler for every item class, and would silently lose anything we forgot or any state a different mod adds.

### Containers keep the real items and save them (approach A)

`InventoryContainer` (the class behind bags) holds an `ItemContainer` and saves and loads it with the item (`InventoryContainer.java:55-75`). Items placed inside are the same Java objects: same condition, same ID, same mod data, same everything. When the item is moved back to the main inventory, nothing has to be reconstructed.

### A carried but unworn container shows no inventory tab

`ISInventoryPage.lua:1572` adds a container button only if the item's category is `Container` **and it is equipped**, or it is a key ring. So a container item sitting in the main inventory but not worn does not appear as a bag tab, and its contents are not listed in the inventory window. That is what makes "the item is gone from my inventory" possible.

### Weight can be hidden

`ItemContainer.setWeightReduction` clamps to 0 to 100 (`ItemContainer.java:2944`). A reduction of 100 would make the contents weigh nothing to the player. PseudoMagic already uses 95 on its satchel and pouch.

### The ring's variants already carry mod data and contents across finger swaps

In `ISClothingExtraAction.lua`, swapping the finger copies the item's mod data (`copyModData`) and, for container items, moves the contents (`takeItemsFrom`). This matters for where the storage lives (see below).

---

## Design Options for Approach A

### A1: A separate hidden "vault" container item (recommended first try)

- Add an item, for example `PseudoMagic.RingVault`: `ItemType = base:container`, large capacity, `WeightReduction = 100`, tiny or zero weight, no body location, never worn.
- First "Store" creates the vault in the player's main inventory if there is none.
- "Store" moves the chosen item into the vault. "Recall" moves it back to the main inventory.
- Because the vault is separate from the ring, **all four finger variants share one vault**, switching fingers cannot lose anything, and wearing two rings does not create two stores.

Drawbacks: the vault is a real item that can be dropped, put in another container, or looted from the body. It would need protection (hide it from the inventory list, and recreate or re-find it) or a clear rule that the vault goes where the player goes.

### A2: The ring itself is the container

- Make the four ring variants `base:container` items with finger body locations (the pouch already uses a container item with a body location, so the idea has a precedent, though not on a finger).
- Vanilla's finger swap already moves a container's contents to the new item (`takeItemsFrom`), so the contents would follow the ring across fingers.
- Problem: a worn container does get an inventory tab (`isEquipped` is true), so we would need to remove that tab. The `OnRefreshInventoryWindowContainers` event (triggered at `ISInventoryPage.lua:1560, 1794, 1801, 1902`) is the hook for changing the button list, but I have not checked how reliable removing a button there is.
- Two worn rings would be two separate stores.

I recommend trying A1 first because it avoids the tab problem and the finger-swap problem. A2 is a more elegant "the ring holds it" design if the tab can be hidden.

### Alternative B in brief

Store only a table (`fullType`, `condition`, and so on) in the ring's mod data or in global mod data, and delete the real item. Recall creates a new item (`instanceItem`) and copies fields back. This gives true "stasis" (food can be frozen exactly) and avoids a hidden container, but see the verified limits above. It could still be a reasonable fallback restricted to a whitelist of simple item types, such as jewelry with only a condition.

---

## The Menu

Both approaches use the existing pattern in `PseudoMagicMenu.lua` (`OnFillInventoryObjectContextMenu`):

- **Store:** when the player has a ring and right-clicks one or more eligible items, add "Store in Ring of the Mage". Eligible items should exclude: equipped items, worn clothing (take it off first), the ring itself, and the vault.
- **Recall:** under the ring's existing menu, add a "Recall" submenu listing the stored items, for example "Recall Gold Necklace". With many items, group identical names and show a count, and consider grouping by category. The item's condition can go in a tooltip so the player can tell two necklaces apart.
- Storing a bag or any container keeps its contents, because the contents travel with the item object. (Nesting a bag inside the vault should be tested, including the capacity limit.)

---

## Open Questions and Risks (not yet checked)

1. **Multiplayer.** The existing summon code adds items on the client and calls `sendAddItemToContainer`. In multiplayer, vanilla moves items with server-side timed actions (`ISInventoryTransferAction`), so a real multiplayer version would likely need a timed action or server command so the server performs the move. Single-player is straightforward.
2. **Does the vault count as "carried"?** Java helpers such as `getAllTypeRecurse` look inside containers, so recipes, crafting, or other mods may still find stored items. Whether an unequipped, tab-less container is searched by crafting needs testing. If stored items must be unavailable, that matters.
3. **Aging.** Food and other time-based items keep updating inside a container, so stored food would keep rotting. Approach B could freeze it. Decide whether the ring should preserve food, and whether that matters.
4. **Death and dropping.** With approach A the vault dies with the player and drops with the corpse, like any bag. With approach B, global mod data survives. Decide which is wanted.
5. **Capacity.** `InventoryContainer` has a `MAX_CAPACITY_BAG = 50` constant (`InventoryContainer.java:30`). The satchel uses capacity 50 already. Whether a script capacity above 50 is clamped, and whether a direct `AddItem` call from Lua checks capacity at all, needs testing. "Store many items" depends on this.
6. **Container tab hiding (A2 only).** Unverified; see above.
7. **Which items may be stored?** Anything? Only valuables? Limits per ring? This is a design decision, not a technical one.
8. **Duplicate item IDs.** `AddItem` rejects an item whose ID is already in the container (`ItemContainer.java:472`). Moving the real object should be fine, but approach B creates new IDs on recall, which other mods might notice.

---

## Suggested Path if We Pursue It

1. **Prototype (single-player):** add the `RingVault` item, a "Store in Ring" option for one selected item, and a "Recall" submenu. Move the real item with `Remove` and `AddItem` (plus the existing `sendRemoveItemFromContainer` and `sendAddItemToContainer` calls). Test that a damaged item returns with the identical condition.
2. **Test the questions above:** many items, a stored bag with contents, food aging, crafting visibility, dropping the vault, saving and reloading.
3. **Decide A1 vs A2, and the rules** (what can be stored, what happens on death).
4. **Multiplayer pass** if needed.

## Verdict

**Feasible.** Storing and recalling many items with their exact condition and other state is achievable in single-player with moderate effort by keeping the real item objects in a hidden container. The risks are about presentation (hiding the container, how stored items behave in crafting and food aging) and multiplayer, not about restoring item state. Copying state field by field is the harder path and is not recommended.
