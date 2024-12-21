-- Debug Utils
function GetInvenStore()
    if next(Inven) == nil then
        _P("GetInvenStore Empty")
    else 
        for k,v in pairs(Inven) do
            _P(k)
        end
    end
end

function IterInvent()
    Inven = {}
    Osi.IterateInventory(Osi.GetHostCharacter(), "AW_ITER_Inv", "AW_ITER_Inv_COMP")
end
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_ITER_Inv" then
        local Obj = Ext.Entity.Get(_Object)
        Inven[_Object] = 1
    end
end)

function AW_GetTemplate()
   _P(GetTemplate("LOOT_GEN_Backpack_C_Posed_A_000_dd6f63d4-7092-80ba-3f40-83849eb6655e"))
end

function AW_DoAny()
    local eee =GetItemByTemplateInPartyInventory(MagicWareChestTemplate_UUID, GetHostCharacter())
    local obj = Ext.Entity.Get(eee)
    obj.InventoryWeight.Weight = 1

    -- local obj = Ext.Entity.Get("CONT_Barrel_Brine_A_626cbf89-51d0-4d9f-99bd-c9e26ca6abed")
    -- _D(obj:GetAllComponents())
    -- obj.ServerBaseData.Weight = 1
    -- obj.Data.Weight = 1
    -- _D(obj.ServerBaseData.Weight)
    -- _D(obj.Data.Weight)
    
    -- _D(obj.InventoryWeight.Weight)
    Osi.IterateInventory(eee, "AW_ITER_InvDoAny", "AW_ITER_InvDoAny_DONE")
end
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
    if _Event == "AW_ITER_InvDoAny" then
        local Obj = Ext.Entity.Get(_Object)
        Obj.ServerBaseData.Weight = 1
        Obj.Data.Weight = 1
    end
end)

Ext.RegisterConsoleCommand("StoreInv", IterInvent)
Ext.RegisterConsoleCommand("GetInv", GetInvenStore)
Ext.RegisterConsoleCommand("GetTemplateDbg", AW_GetTemplate)
Ext.RegisterConsoleCommand("Doit", AW_DoAny)