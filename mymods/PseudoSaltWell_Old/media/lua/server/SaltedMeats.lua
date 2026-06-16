function SaltFishFillet_OnCreateOLD(items, result, player)
	print("PseudoEdPSW SaltFishFillet")
    --local anim = nil;
    --for i=0,items:size() - 1 do
     --   if instanceof(items:get(i), "Food") then
    --        anim = items:get(i);
     --       break;
    --    end
    --end
    --if anim then
	getPlayer():getInventory():AddItem("PseudoSaltWell.SaltedFishFillet");
    --end
end

function MakeSaltedMeatOLD(items, result, player)
	print("PseudoEdPSW MakeSaltedMeat")
    --local anim = nil;
    --for i=0,items:size() - 1 do
    --    if instanceof(items:get(i), "Food") then
    --        anim = items:get(i);
    --        break;
    --    end
    --end
    --if anim then
	--	getPlayer():getInventory():AddItem("PseudoSaltWell.SaltedMeat");
    --end

end

function GetSaltFromPot(items, result, player)
	player:getInventory():AddItem("Base.Salt");
end
