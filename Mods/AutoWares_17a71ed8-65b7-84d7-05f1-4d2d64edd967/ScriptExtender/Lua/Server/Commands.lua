local Samples = {}

local TemplateFile = "AutoWares/AutoWaresTemplate"

local AW_Slot = 0
function AW_SaveWareSample(cmd, slot)
    local MagicChest = AW_GetMagicChest()
    if slot == nil then
        slot = 0
    end
    AW_Slot = slot
    AW_LoadQueue = {}
    Osi.IterateInventory(MagicChest, "AW_SaveWareSample", "AW_SaveWareSample_DONE")
end
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SaveWareSample" then
        addUniqueValue(Samples, GetTemplate(_Object))
    end
end)
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_SaveWareSample_DONE" then
        Ext.IO.SaveFile(TemplateFile..AW_Slot..".json", Ext.DumpExport(Samples))
        _D("AutoWaresTemplate.json saved")
    end
end)

local function AW_Uninstall()
    local MagicChest = AW_GetMagicChest()
    RequestDelete(MagicChest)
end

local AW_LoadQueue = {}
local TheChestOwner

function AW_LoadWareSample(cmd, slot, ...)
    if slot == nil then
        slot = 0
    end
    local FileStr = Ext.IO.LoadFile(TemplateFile..slot..".json")
    if FileStr ~= nil then
        AW_LoadQueue = Ext.Json.Parse(FileStr)
        AW_bTrackingWaresChest = false
        TimerLaunch("AW_LoadWareSample_CleanUp", 0)
    end
end
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_CleanUp" then
        TheChestOwner = GetChestOwner()
        AW_Uninstall()
        TimerLaunch("AW_LoadWareSample_GiveEmptyChest", 100)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_GiveEmptyChest" then
        TemplateAddTo(MagicWareChestTemplate_UUID, TheChestOwner, 1, 0)
        TimerLaunch("AW_LoadWareSample_LoadSampleIter", 300)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_LoadSampleIter" then
        local Chest = AW_GetMagicChest()
        if Chest == nil then
            TimerLaunch("AW_LoadWareSample_LoadSampleIter", 10)
            return
        end
        
        local T = AW_LoadQueue[1]
        for k,v in pairs(AW_LoadQueue) do
            TemplateAddTo(v, Chest, 1, 0)
        end
        TimerLaunch("AW_LoadWareSample_Finish", 100)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_Finish" then
        CleanChestWeight()
        AW_LoadQueue = {}
        _D("Done Loading")
    end
end)

local MergeSource
function AW_MergeWareSample(cmd, source, clean, ...)
    local Chest = AW_GetMagicChest()

    if source == nil then
        MergeSource = 0
    else
        MergeSource = source
    end
    if clean == nil then
        clean = 1
    end

    if clean ~= 0 then
        AW_LoadQueue = {}
    end
    AW_bTrackingWaresChest = false
    Osi.IterateInventory(Chest, "AW_CollectToMerge", "AW_CollectToMerge_DONE")
end
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event ~= "AW_CollectToMerge" then
        return
    end

    local _ObjectTemplate = GetTemplate(_Object)
    
    addUniqueValue(AW_LoadQueue, _ObjectTemplate)
end)
AW_SourceList = {}
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event ~= "AW_CollectToMerge_DONE" then
        return
    end

    -- deal preset
    if MergeSource ~= -909 then
        local SourceFileStr = Ext.IO.LoadFile(TemplateFile..MergeSource..".json")
        if SourceFileStr == nil then
            return
        end
    
        AW_SourceList = Ext.Json.Parse(SourceFileStr)
    end

    -- _D(AW_SourceList)
    
    for k,v in pairs(AW_SourceList) do
        addUniqueValue(AW_LoadQueue, v)
    end
    
    TimerLaunch("AW_LoadWareSample_CleanUp", 0)
    
end)


Ext.RegisterConsoleCommand("AWSave", AW_SaveWareSample)
Ext.RegisterConsoleCommand("AWLoad", AW_LoadWareSample)
Ext.RegisterConsoleCommand("AWMerge", AW_MergeWareSample)
Ext.RegisterConsoleCommand("AWUninstall", AW_Uninstall)