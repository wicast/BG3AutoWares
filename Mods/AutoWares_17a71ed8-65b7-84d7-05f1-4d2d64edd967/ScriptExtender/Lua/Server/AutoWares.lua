-- Plugin's Object UUID
MagicWareChestTemplate_UUID = "DEC_Dungeon_Skeleton_Ribcage_A_Bloody_A_AW_MagicWares_01b9fb82-1739-4075-815b-f5d11d764e1c"
RefreshWeightDummy = "LOOT_GEN_Autopsy_Jar_Tadpoles_B_AW_RefreshWeightDummy_083f48a7-1727-4e57-88ea-e393c305eb0a"

-- Check If WareChest exist in party
Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", function(_Level) -- Don't use SavegameLoaded
    local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
    if MagicChest == nil then
        TimerLaunch("AW_GiveAMagicWareChest", 0)
    else 
        local MagicChestObj = Ext.Entity.Get(MagicChest)
        MagicChestObj.InventoryWeight.Weight = 1
        MagicChestObj.Data.Weight = 1
        Osi.IterateInventory(MagicChest, "AW_SetMagicChestWeight", "AW_SetMagicChestWeight_DONE")
    end
end)
-- Give a MagicChest
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_GiveAMagicWareChest" then
        TemplateAddTo(MagicWareChestTemplate_UUID, GetHostCharacter(),1)
    end
end)
-- Make the chest no weight
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight" then
        local Obj = Ext.Entity.Get(_Object)
        Obj.Data.Weight = 1
    end
end)
-- Refresh weight who carrying the chest
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight_DONE" then
        TemplateAddTo(RefreshWeightDummy, GetHostCharacter(), 1, 0)
        TimerLaunch("AW_RemoveMagicDummySoap", 0)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_RemoveMagicDummySoap" then
        local MagicSoap = GetItemByTemplateInPartyInventory(RefreshWeightDummy, GetHostCharacter())
        if MagicSoap == nil then
            _P("Warning! The bug is coming out!!!")
            return
        end
        RequestDelete(MagicSoap)
    end
end)

-- Auto Add To Wares
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(_ObjectTemplate, _Object, _InventoryHolder, _AddType)
    if IsItem(_Object) ~= 0 and IsPartyMember(_InventoryHolder, 0) ~= nil and IsPartyMember(_InventoryHolder, 0) ~=0 then
        local MagicWareChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, _InventoryHolder)
        if MagicWareChest == nil then
            return
        end
        if TemplateIsInInventory(_ObjectTemplate, MagicWareChest) ~= nil and TemplateIsInInventory(_ObjectTemplate, MagicWareChest) ~= 0 then
            _P("Add Obj".. _Object .. "To Wares")
            local Obj = Ext.Entity.Get(_Object)
            -- both are working
            Obj.ServerItem.DontAddToHotbar = true
            -- Obj.ServerItem.Flags = Obj.ServerItem.Flags | "DontAddToHotbar"

            Osi.IterateInventory(MagicWareChest, "AW_OnCleanWareInMagicWareChest", "AW_OnCleanWareInMagicWareChest_DONE")
        end
    end
end)
-- Clean The Object That Put In MagicWareChest
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_OnCleanWareInMagicWareChest" then
        local Obj = Ext.Entity.Get(_Object)
        Obj.ServerItem.DontAddToHotbar = false
    end
end)

--Make a copy when putting into the MagicChest and remove it when move out the MagicChest
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(_ObjectTemplate, _Object, _InventoryHolder, _AddType)
    local HolderTemplate = GetTemplate(_InventoryHolder)
    if MagicWareChestTemplate_UUID ~= HolderTemplate or IsItem(_Object) == 0 and _ObjectTemplate == HolderTemplate then
        return
    end

    local Holder = Ext.Entity.Get(_InventoryHolder)
    Holder.Data.Weight = 1
    local Obj = Ext.Entity.Get(_Object)
    Obj.ServerBaseData.Weight = 1
    Obj.Data.Weight = 1
    TemplateAddTo(_ObjectTemplate, _InventoryHolder, 1)
end)
Ext.Osiris.RegisterListener("RemovedFrom", 2, "after", function(_Object, _InventoryHolder)
    local HolderTemplate = GetTemplate(_InventoryHolder)
    if MagicWareChestTemplate_UUID == HolderTemplate and IsItem(_Object) ~= 0 then
        RequestDelete(_Object)
    end
end)

-- TODO Move The MagicChest When Character Is Leave