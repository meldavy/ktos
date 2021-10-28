function SCR_BURNING_EVENT_LIST_LOAD(inputType, isServer)

    local sysTime
    
    if isServer == true then
        sysTime = GetDBTime() --imcTime.GetSysTimeByStr(curSysTimeStr)t
    else
        sysTime = geTime.GetServerSystemTime();
    end

    local year = sysTime.wYear
    local month = sysTime.wMonth
    local day = sysTime.wDay

    if month < 10 then
        month = tostring("0"..month)
    end
    if day < 10 then
        day = tostring("0"..day)
    end

    local today = tostring(year..month..day)

    local dateList = {}

    local xmlList, xmlCount = GetClassList("weekendevent_schedule")
    if xmlCount ~= nil and xmlCount ~= 0 then
        local i
        for i = 1, xmlCount do
            dateList[i] = GetClassByIndexFromList(xmlList, i-1)
        end
    end
    
    for j = 1, #dateList do
        local datePiece = StringSplit(dateList[j]["Date"], "-")
        local eventDate = tostring(datePiece[1]..datePiece[2]..datePiece[3])
        if tonumber(eventDate) == tonumber(today) then
            return dateList[j]["EventList"]
        end
    end
    return "None"
end


function SCR_BURNING_EVENT_BUFF_CHECK(self, isServer)
    if IsServerSection() == 1 then
        -- load event list
        local eventList = {}
        local xmlList, xmlCount = GetClassList("weekendevent_list")
        if xmlCount ~= 0 and xmlCount ~= nil then

            local i
            for i = 1, xmlCount do
                eventList[i] = GetClassByIndexFromList(xmlList, i-1)
            end

        end
        if #eventList ~= 0 and #eventList ~= nil then

            --cheat check
            local sessionObject = GetSessionObject(self, "ssn_klapeda")
            local buffNum = TryGetProp(sessionObject, "TEST_BURNING_EVENT")
            if TryGetProp(sessionObject, "TEST_BURNING_EVENT") ~= nil and TryGetProp(sessionObject, "TEST_BURNING_EVENT") ~= 0 then
                AddBuff(self, self, tostring(eventList[buffNum].BuffName))
                return
            end

            local eventCheck = SCR_BURNING_EVENT_LIST_LOAD(inputType, isServer)
            -- if today is active burning event day then
            if eventCheck ~= "None" then
                local buffTable = StringSplit(eventCheck, "/")
                if #buffTable ~= 0 and #buffTable ~= nil then
                    for j = 1, #buffTable do
                        for k = 1, #eventList do
                            -- remove previous day buff
                            if tostring(buffTable[j]) ~= tostring(eventList[k].ClassName) then
                                if IsBuffApplied(self, tostring(eventList[k].ClassName)) == "YES" then
                                    RemoveBuff(self, tostring(eventList[k].BuffName))
                                end
                            end

                            -- add today buff
                            if tostring(buffTable[j]) == tostring(eventList[k].ClassName) then
                                if IsBuffApplied(self, tostring(eventList[k].ClassName)) == "NO" then
                                    AddBuff(self, self, tostring(eventList[k].BuffName))
                                end
                            end
                        end
                    end
                    
                end
                return

            -- if today isn;t active burning event day then
            elseif eventCheck == "None" then

                for l = 1, #eventList do
                    if IsBuffApplied(self, tostring(eventList[l].ClassName)) == "YES" then
                        RemoveBuff(self, tostring(eventList[l].BuffName))
                    end
                end
                return
                
            end
        end
    end
end


function SCR_RAID_BURNING_EVENT_CHECK(pc, isServer)
    if 1 == 1 then
        return false;
    end

    if IsBuffApplied(pc, "") == "YES" then
        return "YES"
    else
        return "NO"
    end
end