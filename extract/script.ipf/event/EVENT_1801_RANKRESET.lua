function SCR_EVENT_1801_RANKRESET_NPC_DIALOG(self, pc)    
    local now_time = os.date('*t')
    local year = now_time['year']
    local month = now_time['month']
    local day = now_time['day']
    local nowDate = year..'/'..month..'/'..day
    
    local sObj = GetSessionObject(pc, 'ssn_klapeda')
    
    if sObj == nil then
        return
    end
    
    local select = ShowSelDlg(pc, 0, 'BALANCE_7_GIVE_ITEM_DLG1', ScpArgMsg('EVENT_1801_RANKRESET_MSG1'), ScpArgMsg('EVENT_1801_RANKRESET_MSG2'), ScpArgMsg('Auto_DaeHwa_JongLyo'))
    
    if select == 1 then
        local jobCircle = GetJobGradeByName(pc, 'Char1_13')
        if jobCircle == nil or jobCircle < 1 then
            ShowOkDlg(pc, 'BALANCE_7_GIVE_ITEM_DLG3', 1)
            return
        end
        if sObj.EVENT_1801_SHINOBI_DATE ~= 'None' then
            ShowOkDlg(pc, 'BALANCE_7_GIVE_ITEM_DLG2', 1)
            return
        end
        local tx = TxBegin(pc)
        TxSetIESProp(tx, sObj, 'EVENT_1801_SHINOBI_DATE', nowDate)
        TxGiveItem(tx, 'Premium_StatReset14', 2, 'EVENT_1801_RANKRESE')
        TxGiveItem(tx, 'Premium_SkillReset_14d', 2, 'EVENT_1801_RANKRESE')
        TxGiveItem(tx, 'Premium_RankReset_14d', 2, 'EVENT_1801_RANKRESE')
        local ret = TxCommit(tx)
    elseif select == 2 then
        local jobCircle = GetJobGradeByName(pc, 'Char2_1')
        if jobCircle == nil or jobCircle < 1 then
            ShowOkDlg(pc, 'BALANCE_7_GIVE_ITEM_DLG3', 1)
            return
        end
        if sObj.EVENT_1801_WIZARD_DATE == nowDate then
            ShowOkDlg(pc, 'BALANCE_7_GIVE_ITEM_DLG6', 1)
            return
        end
        
        local tx = TxBegin(pc)
        TxSetIESProp(tx, sObj, 'EVENT_1801_WIZARD_DATE', nowDate)
        TxGiveItem(tx, 'Premium_StatReset_1d', 1, 'EVENT_1801_RANKRESE')
        TxGiveItem(tx, 'Premium_SkillReset_1d', 1, 'EVENT_1801_RANKRESE')
        TxGiveItem(tx, 'Premium_RankReset_1d', 1, 'EVENT_1801_RANKRESE')
        local ret = TxCommit(tx)
    end
end
