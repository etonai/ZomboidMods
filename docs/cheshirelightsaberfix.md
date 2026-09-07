# Cheshire's Lightsaber fix

At some point in build 42, Mexiox's light saber mod stopped working. Cheshire claims a fix.

in mymods, TestLightSabers is a modified version of Mexios's mod.

Source:
https://pastebin.com/wreUM4eM

## Cheshire's fix
Hey all! I was able to edit this mod to work on the current stable branch (42.13.1). However, I don't know how to create, package, and publish mods, so I'm sharing the steps here so you can edit your own mod. Mexiox, if you want to take these and integrate them into an update of the mod, please go right ahead! And thank you for making a great mod, I really appreciate all your work.

WARNING: It is *highly* recommended that you start a brand new save after making these updates. When I tried integrating them into an existing run, I got a crap ton of script errors that vanished with a new run. YOU HAVE BEEN WARNED.

Note 1: I have only tested these for SP. No idea if they'll work for MP. Sorry.
Note 2: I'm only writing the steps for the full version (Lightsabers), but if you want only the Machetes or without Machetes, the steps should be similar.

These changes will do the following:
* Get the hilts and sabers working in game again
* Get the saber glow working again
* Specify the "on" saber as a two handed weapon
* Fix the script for turning the lightsaber on and off (default bound to Z) to auto equip the saber to 2 hands when on, and 1 hand when off.
* Fix the clothing so it can be worn (side effect: fixes the crash bug when killing a jedi zombie)

1) Get the hilts and sabers working again, get the glow working again, make the on saber a two handed weapon
* Go to [C:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2927454765\mods\Mexiox's - Light Sabers\42\media\scripts] (or wherever you have your steam install. The above is the default arrangement)
* Open [Mexiox_ls_armas.txt] in notepad or notepad++ (any text editor will probably work)
* The general format for the scripts are "item <name>_<on/off>" e.g. "item anakin_off" or "item anakin_on" followed by an {. I will be calling each of these bracketed sections an instance
* Add the following lines to *every* instance. As long as the code goes between the { and the }, it should work for that instance:
  ItemType = base:weapon,
* Add the following lines to every *on* instance:
  TwoHandWeapon = true,
  LightDistance	=	3,
  LightStrength	=	0.8,
* Save and close.

What did we just do? Setting everything to "ItemType = base:weapon," seems to fix the issue of the equipped item not actually equipping or working. My guess is that the devs for Project Zomboid changed the code format requirements. Adding "TwoHandWeapon = true," Makes the game recognize the turned on sabers as two handed weapons, so you can equip in both hands, and there's a damage penalty for equipping one handed. And the last two lines about "light" added the correct glow back in.

2) Fix the "on/off" script
* Go to [C:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2927454765\mods\Mexiox's - Light Sabers\42\media\lua\client]
* Open [Mexiox_ls_LightSaber.lua]. Again, notepad or notepad++ works fine, as should any text editor.
* Scroll down to find the "local function LightSaberUpdate(key)" section.
* Like the previous step, you'll see a lot of instances of "if item:getType() == "<name>_<on/off>" then". E.G. if "item:getType() == "anakin_off" then"
* Don't mess with *any* of the "on" instances.
* For each "off" instance, add this one line "player:setSecondaryHandItem(newitem)" directly under the line that says "player:setPrimaryHandItem(newitem)"
* So each "off" instance should look basically like this, just with different character names:
  player:playSound("AnakinIgnition")
  local inventory = player:getInventory()
  newitem = inventory:AddItem("Mexiox_ls.anakin_on")
  condicionActual = item:getCondition()
  newitem:setCondition(condicionActual)
  player:setPrimaryHandItem(newitem)
  player:setSecondaryHandItem(newitem)
  inventory:Remove(item)
  LScheckHotbar(item,newitem)
* Save and close.

What did we just do? By adding the "SecondaryHandItem" line under the "PrimaryHandItem" line, the game assumes that the turned on saber needs to be equipped in both hands, thus saving you the hassle of needing to right click and "equip in both hands" every time. And when you turn the saber off, the hilt goes back to being a one handed item automatically.

One side note, if you have the saber equipped to your belt slot, and you stow the saber while it's on, you'll have an active lightsaber hanging by your side. Doesn't do anything negative, just looks wrong from a lore perspective. But I don't know how to code the game to automatically turn the saber off when stowing it.

3) Fix the clothing and also fix the crash when killing a Jedi zombie.
* Go to [C:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2927454765\mods\Mexiox's - Light Sabers\42\media\scripts\clothing]
* There are 5 text files in this folder:
  [Mexiox_ls_clothing_jacket.txt]
  [Mexiox_ls_clothing_others.txt]
  [Mexiox_ls_clothing_pants.txt]
  [Mexiox_ls_clothing_shoes.txt]
  [Mexiox_ls_clothing_suits.txt]
* Open all 5 files with your favorite text editor
* For *every* instance in *every* file, between the { and }, add a single line:
  ItemType = base:Clothing,
* Optional: If you want to be thorough, you can replace the line "Type = Clothing," with the above, but it's not necessary, the game doesn't know what to do with this line, so it ignores it.
* Save and close the files.

What did we just do? By adding the line "ItemType = base:Clothing,", the game now knows what the items are. My best guess is that the crash on killing a Jedi zombie was caused because the game didn't know what to do with the clothing (and the lightsabers) when the zombie died and their worn clothing turned to loot.

That should be it. I tested these in my own game on a new save, and everything worked correctly. Ran across Jedi Zombies, killed them without crashes, looted their lightsabers and clothes, and wore and used them myself. If you have any questions, let me know and I'll do my best to answer.

Happy hunting and may the force be with you!