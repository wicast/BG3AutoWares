local channel = "AW_NET_Action"
Ext.Events.NetMessage:Subscribe(function(data)
    if data.Channel == channel then
        --Parse the string back into a table if it was stringified
        local message = Ext.Json.Parse(data.Payload)
        if message == nil then
            return
        end
        --Do whatever you want with the data in the client context

        if message.uninstall ~= nil then
            AW_Uninstall()
            return
        end

        local preset = message.preset
        local clean = 1
        if preset ~= nil then
            message.slot = -909
            clean = 0
            if preset == "Rotten" then
                AW_SourceList = AW_Rotten_Template
                AW_MergeWareSample(nil, message.slot, clean)
            end
            return
        end

        local action = message.action
        if action == "Merge" then
            AW_MergeWareSample(nil, message.slot, clean)
        elseif action == "Save" and preset == nil then
            AW_SaveWareSample(nil, message.slot)
        elseif action == "Load" then
            AW_LoadWareSample(nil, message.slot)
        end
        -- _D("AW_NET_SW_Action done")

        local cache = message.cache_wares
        if cache ~= nil then
            AW_CacheCurrent()
        end

        local restore_cache = message.restore_cache
        if restore_cache ~= nil then
            AW_CacheRestore()
        end

        local clean_cache = message.clean_cache
        if clean_cache ~= nil then
            AW_CleanCache()
        end

    end
end)

Ext.ModEvents.BG3MCM["MCM_Setting_Saved"]:Subscribe(function(payload)
    if not payload or payload.modUUID ~= ModuleUUID or not payload.settingId then
        return
    end

    if payload.settingId == "AW_enable" then
        -- _D("Setting enable to " .. payload.value)
        AW_Enable(nil, payload.value)
    end

    if payload.settingId == "AW_show_notification" then
        AW_ShowGiveBackNotify = payload.value and 1 or 0
    end
end)
