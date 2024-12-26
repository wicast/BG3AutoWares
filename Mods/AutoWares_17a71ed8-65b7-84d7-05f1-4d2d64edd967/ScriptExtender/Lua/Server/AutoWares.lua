-- Plugin's Object UUID
MagicWareChestTemplate_UUID = "DEC_Dungeon_Skeleton_Ribcage_A_Bloody_A_AW_MagicWares_01b9fb82-1739-4075-815b-f5d11d764e1c"
RefreshWeightDummy = "LOOT_GEN_Autopsy_Jar_Tadpoles_B_AW_RefreshWeightDummy_083f48a7-1727-4e57-88ea-e393c305eb0a"

ObjTemplateBlackList = {
                        "LOOT_Gold_A_1c3c9c74-34a1-4685-989e-410dc080be6f",
                        "DLC_DD_Clothing_Chest_8a1f5dc0-3f13-47ed-b238-50fdcaa2f680"
                    }

CleanStackQueue = {}
bAddFromStackRemains = false

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

function AW_GetMagicChest()
    return GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
end

function GetChestOwner()
    local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
    local Owner = GetOwner(MagicChest)
    return Owner
end

local function Find(_Table, _Target)
    if _Table == nil then
        return nil
    end
    for k,v in pairs(_Table) do
        if v == _Target then
            return k
        end
    end
    return nil
end

-- This function takes a table and a value as input and checks if the value already exists in the table.
-- If the value does not exist, it adds the value to the table.
-- If the value already exists, it does not add the value to the table.
-- @param tbl: The table to check and add the value to.
-- @param value: The value to check and add to the table.
-- @return: Returns true if the value was added to the table, false if the value already exists in the table.
function addUniqueValue(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return false
        end
    end
    table.insert(tbl, value)
    return true
end
    
-- This function takes a table and a value as input and removes the value from the table if it exists.
-- @param tbl: The table to remove the value from.
-- @param value: The value to remove from the table.
-- @return: Returns true if the value was removed from the table, false if the value does not exist in the table.
function removeExistingValue(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            table.remove(tbl, i)
            return true
        end
    end
    return false
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
        -- This is necessary for leaving prologue
        TimerLaunch("AW_CheckMagicChestCount", 10)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_CheckMagicChestCount" then
        if TemplateIsInInventory(MagicWareChestTemplate_UUID, GetHostCharacter()) < 1 then
            TemplateAddTo(MagicWareChestTemplate_UUID, GetHostCharacter(), 1)
        end
    end
end)
-- Make the chest no weight
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight" then
        MarkObjectWareSample(_Object)
        local _ObjectTemplate = GetTemplate(_Object)
        local exists = TemplateIsInInventory(_ObjectTemplate, AW_GetMagicChest())
        _D("CleanObj:".._ObjectTemplate.."exists:"..exists)
        if exists > 1 then
            addUniqueValue(CleanStackQueue, _ObjectTemplate)
            TimerLaunch("AW_CleanMagicChestStack", 10)
        end
    end
end)
-- Refresh weight who carrying the chest
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SetMagicChestWeight_DONE" then
        -- local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
        local Owner = GetChestOwner()
        TemplateAddTo(RefreshWeightDummy, Owner, 1, 0)
        TimerLaunch("AW_RemoveMagicDummySoap", 0)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_RemoveMagicDummySoap" then
        -- local MagicChest = GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
        local Owner = GetChestOwner()
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
            and IsInInventoryOf(_Object, MagicWareChest) == 0 
        then
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

    if bAddFromStackRemains then
        bAddFromStackRemains = false
        return
    end

    local exists = TemplateIsInInventory(_ObjectTemplate, _InventoryHolder)
    local amount = GetStackAmount(_Object)
    local Owner = GetChestOwner()
    if IsBlackList(_Object) or IsItem(_Object) == 0 then
        ToInventory(_Object, Owner, amount, 0, 1)
        _D("BlackListObj: " .. _Object .." Entering!")
        return
    end
    -- _D("Copy:".. _Object.." Template:".._ObjectTemplate)
    MarkObjectWareSample(_Object)
    TemplateAddTo(_ObjectTemplate, Owner, amount)

    if exists > 1 then
        -- _D("TODO remove stack "..amount)
        addUniqueValue(CleanStackQueue, _ObjectTemplate)
        TimerLaunch("AW_CleanMagicChestStack", 0)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function (_Event)
    if _Event ~= "AW_CleanMagicChestStack" then
        return
    end
    
    local _ObjectTemplate = CleanStackQueue[1]
    if _ObjectTemplate == nil then
        return
    end
    local MagicChest = AW_GetMagicChest()
   
    local exists = TemplateIsInInventory(_ObjectTemplate, MagicChest)
    if exists ~= nil and exists ~= 1 then
        local Item = GetItemByTemplateInInventory(_ObjectTemplate, MagicChest)
        local amount = -1
        if Item ~= nil then
            amount = GetStackAmount(Item)
            RequestDelete(Item)
        end
        if exists == amount then
            bAddFromStackRemains = true
            -- _D("Object:"..Item.."Fullstack")
            TemplateAddTo(_ObjectTemplate, MagicChest, 1, 0)
        end
        -- _D("Cleaning:".._ObjectTemplate.." Obj ".. Item.. " in ".. MagicChest)
        TimerLaunch("AW_CleanMagicChestStack", 0)
    else
        -- _D("Done CLeanup:".._ObjectTemplate.." exist:"..exists)
        removeExistingValue(CleanStackQueue, _ObjectTemplate)
        -- _D(CleanStackQueue)
        if CleanStackQueue ~= {} then
            TimerLaunch("AW_CleanMagicChestStack", 0)
        end
    end
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
            ToInventory(_Object, _InventoryHolder, 1, 0, 1)
    end
end)
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "before", function(_Character)
    local MagicChest = GetItemByTemplateInInventory(MagicWareChestTemplate_UUID, _Character)
    if MagicChest ~= nil then
        ToInventory(MagicChest, GetHostCharacter(), 1, 0, 1)
    end
end)