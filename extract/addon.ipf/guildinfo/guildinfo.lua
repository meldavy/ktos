﻿function GUILDINFO_ON_INIT(addon, frame)
	addon:RegisterMsg("GUILD_NEUTRALITY_UPDATE", 'ON_GUILD_NEUTRALITY_UPDATE');
    addon:RegisterMsg('GUILD_UPDATE_PROFILE', 'ON_GUILD_UPDATE_PROFILE');
	addon:RegisterMsg("UPDATE_GUILD_ONE_SAY", "GUILDINFO_COMMUNITY_INIT_ONELINE");
    addon:RegisterMsg('UPDATE_GUILD_ASSET', 'ON_UPDATE_GUILD_ASSET');
    addon:RegisterMsg('GUILD_NEUTRALITY_ALARM_FAIL', 'GUILDINFO_WAR_INIT_CHECKBOX_ALARM');
	addon:RegisterMsg("GAME_START_3SEC", "GUILD_GAME_START_3SEC");
    addon:RegisterMsg("GUILD_WAREHOUSE_ITEM_ADD", "GUILDINFO_INVEN_UPDATE_INVENTORY");
    addon:RegisterMsg('GUILD_WAREHOUSE_ITEM_LIST', 'GUILDINFO_INVEN_UPDATE_INVENTORY');
    addon:RegisterMsg('GUILD_ASSET_LOG_UPDATE', 'ON_GUILD_ASSET_LOG');
    addon:RegisterMsg('GUILD_INFO_UPDATE', 'GUILDINFO_UPDATE_INFO');
	addon:RegisterMsg("GUILD_ENTER", "GUILDINFO_UPDATE_INFO");
	addon:RegisterMsg("GUILD_OUT", "ON_GUILD_OUT");
    addon:RegisterMsg('MYPC_GUILD_JOIN', 'GUILDINFO_OPEN_UI');
    addon:RegisterMsg('GUILD_PROPERTY_UPDATE', 'GUILDINFO_UPDATE_PROPERTY');    
    addon:RegisterMsg("GUILD_EMBLEM_UPDATE", 'ON_UPDATE_GUILD_EMBLEM');
    addon:RegisterMsg('COLONY_ENTER_CONFIG_FAIL', 'GUILDINFO_COLONY_INIT_RADIO');
    addon:RegisterMsg('COLONY_OCCUPATION_INFO_UPDATE', 'GUILDINFO_COLONY_UPDATE_OCCUPY_INFO');
    addon:RegisterMsg("GUILD_MASTER_REQUEST", "ON_GUILD_MASTER_REQUEST");

    g_ENABLE_GUILD_MEMBER_SHOW = false;
end

function UI_CHECK_GUILD_UI_OPEN(propname, propvalue)    
	local pcparty = session.party.GetPartyInfo(PARTY_GUILD);
	if pcparty == nil then
		return 0;
	end
	return 1;
end

function GUILDINFO_OPEN_UI(frame)
    GUILDINFO_INIT_TAB(frame);
   GUILDINFO_INIT_PROFILE(frame); 
    GetGuildNotice("GET_GUILD_NOTICE");
    GetGuildProfile("GET_GUILD_PROFILE");

    local guild = GET_MY_GUILD_INFO();
	local leaderAID = guild.info:GetLeaderAID();
    local myAID = session.loginInfo.GetAID()
    if leaderAID ~= myAID then
        local mainTab = GET_CHILD_RECURSIVELY(frame, "mainTab");
        mainTab:SetTabVisible(6, false)
        local tabText = GET_CHILD_RECURSIVELY(frame, "optionTabItemText")
        tabText:SetVisible(0)
    else
        GUILD_APPLICANT_INIT()
    end
end


function GET_GUILD_APPLICATION_LIST(code, ret_json)

    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "GET_GUILD_APPLICATION_LIST")
    end
    
    local frame = ui.GetFrame("guild_prototype");
    local applicantList = GET_CHILD_RECURSIVELY(frame, "applicantPanel", "ui::CScrollPanel");
    local comment = GET_CHILD_RECURSIVELY(frame, "comment", "ui::CEdit");
    local list = json.decode(ret_json)
    for k, v in pairs(list) do
        for x, y in pairs(v) do
            local label = applicantList:CreateControl("richtext", '{@st42}' ..y["account_team_name"], 0, 0, 50, 50);
            label:SetText(y["account_team_name"]);
            label:SetEventScript(ui.LBUTTONUP, "ON_APPLICANT_CLICK")
            label:SetUserValue("msg", y["msg_text"]) 
            label:SetUserValue("idx", y["account_idx"])
          
        end
    end
end

function GET_GUILD_PROFILE(code, ret_json)
    local frame = ui.GetFrame("guildinfo")
    local introduceText = GET_CHILD_RECURSIVELY(frame, 'introduceText');
    local introduceEdit = GET_CHILD_RECURSIVELY(frame, 'introduceEdit');
    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "GET_GUILD_NOTICE")
        local guild = GET_MY_GUILD_INFO();
        if guild ~= nil then
            introduceText:SetText(guild.info:GetProfile());
            introduceEdit:SetText(guild.info:GetProfile());
        end
        
        return
    end
    introduceText:SetText(ret_json);
    introduceEdit:SetText(ret_json);
end

function GET_GUILD_NOTICE(code, ret_json)
    local frame = ui.GetFrame("guildinfo");
    local notifyText = GET_CHILD_RECURSIVELY(frame, 'notifyText');
    local noticeEdit = GET_CHILD_RECURSIVELY(frame, 'noticeEdit');
    if code ~= 200 then        
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "GET_GUILD_NOTICE")
        local guild = GET_MY_GUILD_INFO();
        if guild ~= nil then
            notifyText:SetText(guild.info:GetNotice());
            noticeEdit:SetText(guild.info:GetNotice());
        end

        return
    end
    notifyText:SetText(ret_json);
    noticeEdit:SetText(ret_json);
end

function GUILDINFO_INIT_PROFILE(frame)
    local guild = session.party.GetPartyInfo(PARTY_GUILD);
     if guild == nil then
        GUILDINFO_FORCE_CLOSE_UI()
        return
    end

    local guildObj = GET_MY_GUILD_OBJECT();
    local profileBox = GET_CHILD_RECURSIVELY(frame, 'profileBox');

    -- level and name
    local nameText = GET_CHILD_RECURSIVELY(profileBox, 'nameText');    
    nameText:SetTextByKey('level', guildObj.Level);
    nameText:SetTextByKey('name', guild.info.name);

    -- leader name
    local masterText = GET_CHILD_RECURSIVELY(profileBox, 'masterText');
    local leaderAID = guild.info:GetLeaderAID();
	local list = session.party.GetPartyMemberList(PARTY_GUILD);
	local count = list:Count();
	for i = 0 , count - 1 do
		local partyMemberInfo = list:Element(i);
		if leaderAID == partyMemberInfo:GetAID() then
			leaderName = partyMemberInfo:GetName();
            masterText:SetTextByKey('name', leaderName);
            break;
		end
	end

    -- opening date
    local openText = GET_CHILD_RECURSIVELY(profileBox, 'openText');
    local openDate = imcTime.ImcTimeToSysTime(guild.info.createTime);
    local openDateStr = string.format('%04d.%02d.%02d', openDate.wYear, openDate.wMonth, openDate.wDay); -- yyyy.mm.dd
    print(openDateStr)
    openText:SetTextByKey('date', openDateStr);

    -- member
    local memberText = GET_CHILD_RECURSIVELY(profileBox, 'memberText');
    memberText:SetTextByKey('current', count);
    memberText:SetTextByKey('max',  guild:GetMaxGuildMemberCount());

    -- asset
   GUILDINFO_PROFILE_INIT_ASSET(frame);


   GUILDINFO_PROFILE_INIT_EMBLEM(frame);
end

function GUILDINFO_PROFILE_INIT_ASSET(frame)
    local profileBox = GET_CHILD_RECURSIVELY(frame, 'profileBox');
    local moneyText = GET_CHILD_RECURSIVELY(profileBox, 'moneyText');
    local guildObj = GET_MY_GUILD_OBJECT();
    local guildAsset = guildObj.GuildAsset;    
    if guildAsset == nil or guildAsset == 'None' then
        guildAsset = 0;
    end
    moneyText:SetTextByKey('money', GET_COMMAED_STRING(guildAsset));
end

function GUILDINFO_INIT_TAB(frame)
    local mainTab = GET_CHILD(frame, 'mainTab');
    mainTab:SelectTab(0);
end

function GET_MY_GUILD_INFO()
    return session.party.GetPartyInfo(PARTY_GUILD);
end

function GET_MY_GUILD_OBJECT()
    local guild = GET_MY_GUILD_INFO();
    if guild == nil then
        GUILDINFO_FORCE_CLOSE_UI()
        return
    end

    local guildObj = GetIES(guild:GetObject());
    if guildObj == nil then
        return nil;
    end
    return guildObj;
end

function ON_GUILD_UPDATE_PROFILE(frame, msg, argStr, argNum)
    GUILDINFO_INIT_PROFILE(frame);
end

function ON_UPDATE_GUILD_ASSET(frame, msg, argStr, argNum)
    GUILDINFO_INIT_PROFILE(frame);
end

function GUILDINFO_UPDATE_INFO(frame, msg, argStr, argNum)
    GUILDINFO_INIT_PROFILE(frame);
    _GUILDINFO_INIT_MEMBER_TAB(frame);
end

function GUILDINFO_FORCE_CLOSE_UI()
    local frame = ui.GetFrame("guildinfo");
    if frame ~= nil then
        if frame:IsVisible() == 1 then
        
        GUILDINFO_CLOSE_UI(frame)
        end
    end
end

function ON_GUILD_OUT(frame)
	frame:ShowWindow(0);
    ui.CloseFrame('guildinfo');

	local sysMenuFrame = ui.GetFrame("sysmenu");
	SYSMENU_CHECK_HIDE_VAR_ICONS(sysMenuFrame);
end

function GUILDINFO_CLOSE_UI(frame)    
    ui.CloseFrame('guildinven_send');
    ui.CloseFrame('guild_authority_popup');
    ui.CloseFrame('guildemblem_change');
    ui.CloseFrame("loadimage")
    ui.CloseFrame("guild_applicant_list")
    frame:ShowWindow(0);
end

function GUILDINFO_MOVE_START(frame)
    ui.CloseFrame('guild_authority_popup');
end

function GUILDINFO_UPDATE_PROPERTY(frame, msg, argStr, argNum)
    if argStr == 'EnableEnterColonyWar' then
        GUILDINFO_COLONY_INIT_RADIO(frame);
        return;
    elseif argStr == 'GuildOnlyAgit' then
        GUILDINFO_OPTION_INIT(frame, frame);
        return;
    elseif argStr == 'GuildAsset' then
        ON_UPDATE_GUILD_ASSET(frame, msg, argStr, argNum);
    end
end

function GUILDINFO_PROFILE_INIT_EMBLEM(frame)
    local guildInfo = GET_MY_GUILD_INFO();    
    local worldID = session.party.GetMyWorldIDStr();    
    local emblemImgName = guild.GetEmblemImageName(guildInfo.info:GetPartyID(),worldID);  
    local isRegisteredEmblem = session.party.IsRegisteredEmblem();
    DRAW_GUILD_EMBLEM(frame,false,  isRegisteredEmblem, emblemImgName)
    GUILDINFO_OPTION_UPDATE_EMBLEM(frame)
end 

function DRAW_GUILD_EMBLEM(frame, isPreView, isRegisteredEmblem, emblemName)
    local isOpenGuildInfoUI = false;
    local frame_guildInfo = ui.GetFrame("guildinfo");
    if frame_guildInfo ~= nil then
        if frame_guildInfo:IsVisible() == 1 then
            isOpenGuildInfoUI = true;
        end
    end
    
    if isOpenGuildInfoUI == true then
        --길드 엠블렘 변경중. 창을 닫으면 자동으로 기존엠블렘으로 업데이트됨.
        local frame_emblemChange = ui.GetFrame("guildemblem_change");
        if frame_emblemChange ~= nil and frame_emblemChange:IsVisible() == 1 and isPreView == false then
            return
        end
        local emblemFront = GET_CHILD_RECURSIVELY(frame_guildInfo, 'emblemPic_upload');
        local emblemBack = GET_CHILD_RECURSIVELY(frame_guildInfo, 'emblemPic');
        emblemFront:ShowWindow(0)
        emblemBack:ShowWindow(0);

        if isPreView == true then
            emblemFront:SetImage(""); -- clear clone image
            emblemFront:SetFileName(emblemName);
            emblemFront:ShowWindow(1); 
        else
            if isRegisteredEmblem == true and emblemName ~= 'None' then
                emblemBack:SetImage("")
                emblemBack:SetFileName(emblemName); 
            else
                local default_emblem = frame_guildInfo:GetUserConfig("DEFAULT_EMBLEM_IMAGE");
                emblemBack:SetImage(default_emblem);
            end
            emblemBack:ShowWindow(1);
        end
        frame_guildInfo:Invalidate();
    end
end

function ON_UPDATE_GUILD_EMBLEM(frame,  msg, argStr, argNum)
   GUILDINFO_PROFILE_INIT_EMBLEM(frame)
end

function REGISTER_GUILD_EMBLEM(frame)
   GUILDEMBLEM_CHANGE_INIT(frame);
end

function UI_TOGGLE_GUILD()
    if app.IsBarrackMode() == true then
		return;
	end

    local myActor = GetMyActor();
    if myActor == nil or myActor:IsGuildExist() == false then
        return;
    end
    g_ENABLE_GUILD_MEMBER_SHOW = true;
	ui.ToggleFrame('guildinfo');
end

function ON_GUILD_MASTER_REQUEST(frame, msg, argStr)
	local pcparty = session.party.GetPartyInfo(PARTY_GUILD);
	if nil ==pcparty then
		return;
	end
	local leaderAID = pcparty.info:GetLeaderAID();
	local list = session.party.GetPartyMemberList(PARTY_GUILD);
	local count = list:Count();
	local leaderName = 'None'
	for i = 0 , count - 1 do
		local partyMemberInfo = list:Element(i);
		if leaderAID == partyMemberInfo:GetAID() then
			leaderName = partyMemberInfo:GetName();
		end
	end

	local yesScp = string.format("ui.Chat('/agreeGuildMasterByWeb')");
	local noScp = string.format("ui.Chat('/disagreeGuildMaster')");
	ui.MsgBox(ScpArgMsg("DoYouWantGuildLeadr{N1}{N2}",'N1',leaderName,'N2', pcparty.info.name), yesScp, noScp);
end
