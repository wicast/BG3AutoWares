Ext.Events.NetMessage:Subscribe(function(data)
    local channel = "AW_NET_SW_Action"
    if data.Channel == channel then
        --Parse the string back into a table if it was stringified
        local message = Ext.Json.Parse(data.Payload)
        if message == nil then
            return
        end
        --Do whatever you want with the data in the client context

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
    end
end)

