local function GetCurrentMessage()
    local action = MCM.Get("AW_sw_action")
    local slot = MCM.Get("AW_sw_slot")
    local message = {action = action, slot = slot}
    return message
end

local channel = "AW_NET_Action"
local function SendMsg(msg)
    Ext.ClientNet.PostMessageToServer(channel, Ext.Json.Stringify(msg))
end

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Save&Load", function(tabHeader)
    local DoAction = tabHeader:AddButton("Do Action")
    DoAction.OnClick = function()
        if Ext.Net.IsHost() == false then
            return
        end

        local message = GetCurrentMessage()
        SendMsg(message)
        -- _D("AW_NET_SW_Action sent!")
    end

end)

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Presets", function(tabHeader)
    local RottenPreset = tabHeader:AddButton("Load Rotten Food Preset")
    RottenPreset.OnClick = function()
        if Ext.Net.IsHost() == false then
            return
        end
        local message = GetCurrentMessage()
        message.preset = "Rotten"
        SendMsg(message)
    end
end)

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Misc", function(tabHeader)
    local RottenPreset = tabHeader:AddButton("Uninstall")
    RottenPreset.OnClick = function()
        if Ext.Net.IsHost() == false then
            return
        end
        local message = {uninstall = true}
        SendMsg(message)
    end
end)