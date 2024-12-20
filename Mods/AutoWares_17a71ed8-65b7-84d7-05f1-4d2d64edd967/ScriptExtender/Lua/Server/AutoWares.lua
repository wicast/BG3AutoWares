Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(_ObjectTemplate, _Object, _InventoryHolder, _AddType)
    -- if Ext.Entity.Get(_InventoryHolder) == _C() then
    if IsPartyMember(_InventoryHolder, 1) ~= 0 then
        MagicWaresChest = GetItemByTemplateInPartyInventory("DEC_Dungeon_Skeleton_Ribcage_A_Bloody_A_254096e8-fb58-46e4-9d85-29a8f92f78e6", _InventoryHolder)
        if TemplateIsInInventory(_ObjectTemplate, MagicWaresChest) ~= 0 then
            _P("Add Obj".. _Object .. "To Wares")
            local Obj = Ext.Entity.Get(_Object)
            -- both are working
            Obj.ServerItem.DontAddToHotbar = true
            -- Obj.ServerItem.Flags = Obj.ServerItem.Flags | "DontAddToHotbar"
            Osi.IterateInventory(MagicWaresChest, "AW_OnCleanWareInMagicWareChest", "AW_OnCleanWareInMagicWareChest_Comp")
        end
    end
end)
-- Clean The Object That Put In MagicWaresChest
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_OnCleanWareInMagicWareChest" then
        local Obj = Ext.Entity.Get(_Object)
        Obj.ServerItem.DontAddToHotbar = false
    end
end)

function GetInvenStore()
    if next(Inven) == nil then
        _P("GetInvenStore Empty")
    else 
        for k,v in pairs(Inven) do
            _P(k)
        end
    end
end

function IterInvent()
    Inven = {}
    Osi.IterateInventory(Osi.GetHostCharacter(), "AW_ITER_Inv", "AW_ITER_Inv_COMP")
end
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_ITER_Inv" then
        local Obj = Ext.Entity.Get(_Object)
        Inven[_Object] = 1
    end
end)

function AW_GetTemplate()
   _P(GetTemplate("LOOT_GEN_Backpack_C_Posed_A_000_dd6f63d4-7092-80ba-3f40-83849eb6655e"))
end

Ext.RegisterConsoleCommand("StoreInv", IterInvent)
Ext.RegisterConsoleCommand("GetInv", GetInvenStore)
Ext.RegisterConsoleCommand("GetTemplateDbg", AW_GetTemplate)