function GAUGE_BOSS_PATTERN_ON_INIT(addon, frame)
    addon:RegisterMsg('OPEN_GAUGE_BOSS_PATTERN', 'GAUGE_BOSS_PATTERN_OPEN')
    addon:RegisterMsg('CLOSE_GAUGE_BOSS_PATTERN', 'GAUGE_BOSS_PATTERN_CLOSE')
end

function UPDATE_GAUGE_BOSS_PATTERN(switch, currentValue, maxValue)
    if switch == 1 then
        if currentValue > maxValue then
            currentValue = maxValue
        end
        ui.OpenFrame('gauge_boss_pattern')
        local frame = ui.GetFrame('gauge_boss_pattern')
        local gauge = GET_CHILD_RECURSIVELY(frame, 'charge_gauge')
        gauge:SetPoint(currentValue, maxValue)
    elseif switch == 0 then
        local frame = ui.GetFrame('gauge_boss_pattern')
        if frame ~= nil and frame:IsVisible() == 1 then
            ui.CloseFrame('gauge_boss_pattern')
        end
    end
end

function GAUGE_BOSS_PATTERN_OPEN(frame)
    local gauge = GET_CHILD_RECURSIVELY(frame, 'charge_gauge')
    gauge:SetPoint(0, 100)
end

function GAUGE_BOSS_PATTERN_CLOSE(frame)

end