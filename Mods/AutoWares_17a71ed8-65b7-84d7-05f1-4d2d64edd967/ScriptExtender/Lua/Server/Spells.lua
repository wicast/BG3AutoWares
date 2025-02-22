Ext.Osiris.RegisterListener("CastSpell", 5, "after", function (_Caster, _Spell, _SpellType, _SpellElement, _StoryActionID)
    -- TODO replace with my spell
    -- if _Spell ~= "Target_Resistance" then
    if _Spell ~= "Shout_AW_Cache" then
        return
    end

    local HostChar = GetHostCharacter()
    if GetUUID(_Caster) == HostChar then
        -- _D("AW_CacheCurrent")
        AW_CacheCurrent()
    end

end)

Ext.Osiris.RegisterListener("CastSpell", 5, "after", function (_Caster, _Spell, _SpellType, _SpellElement, _StoryActionID)
    -- TODO replace with my spell
    -- if _Spell ~= "Target_Guidance" then
    if _Spell ~= "Shout_AW_Restore_Cache" then
        return
    end

    local HostChar = GetHostCharacter()
    if GetUUID(_Caster) == HostChar then
        -- _D("AW_CacheRestore")
        AW_CacheRestore()
    end

end)

Ext.Osiris.RegisterListener("CastSpell", 5, "after", function (_Caster, _Spell, _SpellType, _SpellElement, _StoryActionID)
    -- TODO replace with my spell
    -- if _Spell ~= "Target_Resistance" then
    if _Spell ~= "Shout_AW_Clean_Cache" then
        return
    end

    local HostChar = GetHostCharacter()
    if GetUUID(_Caster) == HostChar then
        -- _D("AW_CleanCache")
        AW_CleanCache()
    end

end)