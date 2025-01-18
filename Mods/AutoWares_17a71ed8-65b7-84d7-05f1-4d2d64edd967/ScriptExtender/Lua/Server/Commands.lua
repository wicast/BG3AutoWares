local Samples = {}

local TemplateFile = "AutoWares/AutoWaresTemplate"

local AW_Slot = 0
local function SaveWareSample(cmd, slot)
    local MagicChest = AW_GetMagicChest()
    if slot == nil then
        slot = 0
    end
    AW_Slot = slot
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

local function Uninstall()
    local MagicChest = AW_GetMagicChest()
    RequestDelete(MagicChest)
end

local LoadQueue = {}
local TheChestOwner

local function LoadWareSample(cmd, slot, ...)
    if slot == nil then
        slot = 0
    end
    local FileStr = Ext.IO.LoadFile(TemplateFile..slot..".json")
    if FileStr ~= nil then
        LoadQueue = Ext.Json.Parse(FileStr)
        AW_bTrackingWaresChest = false
        TimerLaunch("AW_LoadWareSample_CleanUp", 0)
    end
end
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_CleanUp" then
        TheChestOwner = GetChestOwner()
        Uninstall()
        TimerLaunch("AW_LoadWareSample_GiveEmptyChest", 10)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_GiveEmptyChest" then
        TemplateAddTo(MagicWareChestTemplate_UUID, TheChestOwner, 1, 0)
        TimerLaunch("AW_LoadWareSample_LoadSampleIter", 50)
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_LoadSampleIter" then
        local Chest = AW_GetMagicChest()
        if Chest == nil then
            TimerLaunch("AW_LoadWareSample_LoadSampleIter", 10)
            return
        end
        
        local T = LoadQueue[1]
        if removeExistingValue(LoadQueue, T) then
            TemplateAddTo(T, Chest, 1, 0)    
            TimerLaunch("AW_LoadWareSample_LoadSampleIter", 10)
        else
            TimerLaunch("AW_LoadWareSample_Finish", 100)
        end
    end
end)
Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(_Event)
    if _Event == "AW_LoadWareSample_Finish" then
        AW_bTrackingWaresChest = true
        CleanChestWeight()
        _D("Done Loading")
    end
end)

Ext.RegisterConsoleCommand("AWSave", SaveWareSample)
Ext.RegisterConsoleCommand("AWLoad", LoadWareSample)
Ext.RegisterConsoleCommand("AWUninstall", Uninstall)