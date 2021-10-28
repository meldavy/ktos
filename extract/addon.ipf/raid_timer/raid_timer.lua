function RAID_TIMER_ON_INIT(addon, frame)
    addon:RegisterMsg('RAID_TIMER_START', 'RAID_TIMER_UI_OPEN');
    addon:RegisterMsg('RAID_TIMER_END', 'RAID_TIMER_END');
end

function RAID_TIMER_UI_OPEN(frame,msg,strArg,numArg)
    frame:ShowWindow(1)
    RAID_TIMER_INIT(frame,strArg,numArg)
end

function RAID_TIMER_INIT(frame,strArg,appTime)
    frame:SetUserValue("NOW_TIME",appTime)
    frame:SetUserValue("END_TIME",appTime + strArg)
    frame:SetUserValue("SET_TIME", strArg)
--    RAID_TIMER_UPDATE(frame)
--    frame:RunUpdateScript("RUN_RAID_TIMER_UPDATE", 0.1);
end

function RUN_RAID_TIMER_UPDATE(frame,totalTime,elapsedTime)
    local now_time = frame:GetUserValue("NOW_TIME")
    frame:SetUserValue("NOW_TIME",now_time + elapsedTime)
    RAID_TIMER_UPDATE(frame)
    return 1;
end

function RAID_TIMER_UPDATE(set_time, remain_time)
    local frame = ui.GetFrame("raid_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
    
    if remain_time < 0 then
        RAID_TIMER_END(frame)
        return;
    end

    local remaintimeValue = GET_CHILD_RECURSIVELY(frame,"remaintimeValue")
    local remaintimeGauge = GET_CHILD_RECURSIVELY(frame,"remaintimeGauge")
    
    remaintimeValue:SetTextByKey("min",math.floor(remain_time/60))
    remaintimeValue:SetTextByKey("sec",remain_time%60)
    remaintimeGauge:SetPoint(remain_time,set_time)
end

function RAID_TIMER_UPDATE_BY_SERVER(frame,msg,strArg,numArg)
    frame:SetUserValue('NOW_TIME',numArg)
end

function RAID_TIMER_END(frame,msg,argStr,argNum)
    frame:StopUpdateScript("RAID_TIMER_DPS");
    frame:ShowWindow(0)
end

function RAID_TIMER_UPDATE_SERVER()
    local frame = ui.Getframe("raid_timer")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
end

