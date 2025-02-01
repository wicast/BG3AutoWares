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

if Mods.BG3MCM ~= nil then
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
        local Tooltip = RottenPreset:Tooltip()
        Tooltip:AddText("Merge Rotten Preset to your chest")
    end)
    
    Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Misc", function(tabHeader)
        local Uninstall = tabHeader:AddButton("Uninstall")
        Uninstall.OnClick = function()
            if Ext.Net.IsHost() == false then
                return
            end
            local message = {uninstall = true}
            SendMsg(message)
        end
    
        local Tooltip = Uninstall:Tooltip()
        Tooltip:AddText("Uninstall will remove the cheese chest from the game, then save and reload your game will make the game back to origin")
    end)
end
