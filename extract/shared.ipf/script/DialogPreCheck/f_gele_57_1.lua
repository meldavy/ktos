function SCR_GELE571_RP_1_OBJ_PRE_DIALOG(pc, dialog)
    local result = SCR_QUEST_CHECK(pc, 'GELE571_RP_1')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end

