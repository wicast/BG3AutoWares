Ext.Osiris.RegisterListener("AddedTo", 3, "after" ,function(_Object, _InventoryHolder, _AddType) 
    local Obj = Ext.Entity.Get(_Object)
    -- both are working
    Obj.ServerItem.DontAddToHotbar = true
    Obj.ServerItem.Flags = Obj.ServerItem.Flags | "DontAddToHotbar"
end)

-- function IT_Inven()
--     Osi.IterateInventory(Osi.GetHostCharacter(), "AAA_ITER_Inv", "AAA_ITER_Inv_COMP")
-- end

-- Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function(_Object, _Event) 
--     if _Event == "AAA_ITER_Inv" then
--         local Obj = Ext.Entity.Get(_Object)
--         Obj.ServerItem.DontAddToHotbar = true
--         Obj.ServerItem.Flags = Obj.ServerItem.Flags | "DontAddToHotbar"
--     end
-- end)