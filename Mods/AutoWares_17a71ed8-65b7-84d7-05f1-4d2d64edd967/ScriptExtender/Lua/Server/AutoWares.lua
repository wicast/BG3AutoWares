-- Plugin's Object UUID
MagicWareChestTemplate_UUID = "DEC_Dungeon_Skeleton_Ribcage_A_Bloody_A_AW_MagicWares_01b9fb82-1739-4075-815b-f5d11d764e1c"
RefreshWeightDummy = "LOOT_GEN_Autopsy_Jar_Tadpoles_B_AW_RefreshWeightDummy_083f48a7-1727-4e57-88ea-e393c305eb0a"

ObjTemplateBlackList = {
                        "LOOT_Gold_A_1c3c9c74-34a1-4685-989e-410dc080be6f",
                        "DLC_DD_Clothing_Chest_8a1f5dc0-3f13-47ed-b238-50fdcaa2f680"
                    }

local function IsBlackList(_Object)
    local Obj = Ext.Entity.Get(_Object)
    if Obj ~= nil and (Obj.ServerItem.Flags & "StoryItem") ~= {} then
        _D(_Object.." is StoryItem")
        return true
    end

    local ObjTemplate = GetTemplate(_Object)
    for k,v in pairs(ObjTemplateBlackList) do
        if ObjTemplate == v then
            return true
        end
    end

    return false
end

local function MarkObjectWareSample(_Object)
    if IsBlackList(_Object) then
        return
    end
    -- _D("MarkObjectWareSample:".._Object)
    local Obj = Ext.Entity.Get(_Object)
    Obj.Data.Weight = 0
    Obj.Value.Value = 0
    if Obj.Use ~= nil then
        Obj.Use.ItemUseBlocked = 1
    end
end

-- Check If WareChest exist in party
Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", function(_Level) -- Don't use SavegameLoaded
    local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
    if MagicChest == nil then
        TimerLaunch("AW_GiveAMagicWareChest", 0)
    else 
        local MagicChestObj = Ext.Entity.Get(MagicChest)
        MagicChestObj.InventoryWeight.Weight = 0
        MagicChestObj.Data.Weight = 0
        MagicChestObj.Value.Value = 0

        Osi.IterateInventory(MagicChest, "AW_SetMagicChestWeight", "AW_SetMagicChestWeight_DONE")
    end
end)
-- Give a MagicChest
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_GiveAMagicWareChest" then
        TemplateAddTo(MagicWareChestTemplate_UUID, GetHostCharacter(), 1)
    end
end)
-- Make the chest no weight
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight" then
        MarkObjectWareSample(_Object)
    end
end)
-- Refresh weight who carrying the chest
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight_DONE" then
        local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
        local Owner = GetOwner(MagicChest)
        TemplateAddTo(RefreshWeightDummy, Owner, 1, 0)
        TimerLaunch("AW_RemoveMagicDummySoap", 0)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_RemoveMagicDummySoap" then
        local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
        local Owner = GetOwner(MagicChest)
        local MagicSoap = GetItemByTemplateInPartyInventory(RefreshWeightDummy, Owner)
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
        if MagicWareChest == nil or IsBlackList(_Object) then
            return
        end
        if TemplateIsInInventory(_ObjectTemplate, MagicWareChest) ~= nil 
            and TemplateIsInInventory(_ObjectTemplate, MagicWareChest) ~= 0
            and IsInInventoryOf(_Object, MagicWareChest) == 0 then
            -- _P("Add Obj:".. _Object .. " To Wares, AddType:".._AddType)
            local Obj = Ext.Entity.Get(_Object)
            -- both are working
            Obj.ServerItem.DontAddToHotbar = true
            -- Obj.ServerItem.Flags = Obj.ServerItem.Flags | "DontAddToHotbar"
        end
    end
end)

--Make a copy when putting into the MagicChest and remove it when move out the MagicChest
Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(_ObjectTemplate, _Object, _InventoryHolder, _AddType)
    local HolderTemplate = GetTemplate(_InventoryHolder)
    -- _D("TemplateAddedTo Holder".._InventoryHolder .. " Item:".._Object)
    if MagicWareChestTemplate_UUID ~= HolderTemplate then
        return
    end
    if IsBlackList(_Object) or IsItem(_Object) == 0 then
        local amount = GetStackAmount(_Object)
        ToInventory(_Object, GetHostCharacter(), amount, 0, 1)
        _D("BlackListObj: " .. _Object .." Entering!")
        return
    end
    -- _D("Copy:".. _Object.." Template:".._ObjectTemplate)
    MarkObjectWareSample(_Object)
    TemplateAddTo(_ObjectTemplate, GetHostCharacter(), 1)
end)
Ext.Osiris.RegisterListener("RemovedFrom", 2, "after", function(_Object, _InventoryHolder)
    local HolderTemplate = GetTemplate(_InventoryHolder)
    if MagicWareChestTemplate_UUID == HolderTemplate and IsItem(_Object) ~= 0 then
        if IsBlackList(_Object) then
            return
        end

        -- _D("Delete:".._Object)
        RequestDelete(_Object)
    end
end)

-- Prevent MagicChest from removing
Ext.Osiris.RegisterListener("RemovedFrom", 2, "after", function(_Object, _InventoryHolder)
    local ObjTemplate = GetTemplate(_Object)
    if MagicWareChestTemplate_UUID == ObjTemplate 
        and GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter()) == nil then
            ToInventory(_Object, GetHostCharacter(), 1, 0, 1)
    end
end)
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "before", function(_Character)
    local MagicChest = GetItemByTemplateInInventory(MagicWareChestTemplate_UUID, _Character)
    ToInventory(MagicChest, GetHostCharacter(), 1, 0, 1)
end)