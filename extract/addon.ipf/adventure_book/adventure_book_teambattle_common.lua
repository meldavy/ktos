function ADVENTURE_BOOK_TEAM_BATTLE_COMMON_INIT(adventureBookFrame, teamBattleRankingPage)
    local ret = worldPVP.RequestPVPInfo();
	if ret == false then -- 이미 데이타가 있음
		ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(adventureBookFrame);
	end

    -- ranking
    local rankingBox = teamBattleRankingPage:GetChild('teamBattleRankingBox');
    ADVENTURE_BOOK_TEAM_BATTLE_RANK(teamBattleRankingPage, rankingBox);
	
	local join = GET_CHILD_RECURSIVELY(teamBattleRankingPage, 'teamBattleMatchingBtn');
	join:SetEnable(IS_TEAM_BATTLE_ENABLE());

	local reward = GET_CHILD_RECURSIVELY(teamBattleRankingPage, 'teamBattleRewardBtn');
	local cid = session.GetMySession():GetCID();
	local myRank = session.worldPVP.GetPrevRankInfoByCID(cid);
	if myRank ~= nil and myRank.ranking < 3 then
		reward:SetEnable(1)
	else
		reward:SetEnable(0)
	end
end

function IS_TEAM_BATTLE_ENABLE()
    if session.colonywar.GetIsColonyWarMap() == false then
		local cnt = session.worldPVP.GetPlayTypeCount();
		if cnt > 0 then
			local isGuildBattle = 0;
			for i = 1, cnt do
				local type = session.worldPVP.GetPlayTypeByIndex(i);
				if type == 210 then
					isGuildBattle = 1;
					break;
				end
			end

			if isGuildBattle == 0 then
				return 1
			end
		end
	end
	return 0
end

function GET_TEAM_BATTLE_CLASS()
    local pvpCls = GetClass("WorldPVPType", 'Three');
	return pvpCls;
end

function ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(adventureBookFrame, msg, argStr, argNum)
    local pvpCls = GET_TEAM_BATTLE_CLASS();
	if pvpCls == nil then
		return;
	end
	local pvpObj = GET_PVP_OBJECT_FOR_TYPE(pvpCls);        
	if nil == pvpObj then
		return;
	end
    local winValue = pvpObj:GetPropValue(pvpCls.ClassName..'_WIN');
    local loseValue = pvpObj:GetPropValue(pvpCls.ClassName..'_LOSE');
    local totalValue = winValue + loseValue;
    local battleHistoryValueText = GET_CHILD_RECURSIVELY(adventureBookFrame, 'battleHistoryValueText');    
    battleHistoryValueText:SetTextByKey('total', totalValue);
    battleHistoryValueText:SetTextByKey('win', winValue);
    battleHistoryValueText:SetTextByKey('lose', loseValue);
        
    local mySession = session.GetMySession();
	local cid = mySession:GetCID();
    local pointInfo = session.worldPVP.GetRankInfoByCID(cid);
    local pointValue = pvpObj:GetPropValue(pvpCls.ClassName..'_RP', 1000);
    if pointInfo ~= nil then
        pointValue = pointInfo.point;
    end

    local battlePointValueText = GET_CHILD_RECURSIVELY(adventureBookFrame, 'battlePointValueText');
    battlePointValueText:SetTextByKey('point', pointValue);
end

function ADVENTURE_BOOK_TEAM_BATTLE_RANK(parent, teamBattleRankingBox)
	ADVENTURE_BOOK_RANKING_PAGE_SELECT(parent, teamBattleRankingBox, 'TeamBattle', 1);

	local topFrame = parent:GetTopParentFrame();
	local teamBattleRankSet = GET_CHILD_RECURSIVELY(topFrame, 'teamBattleRankSet');
	local pageCtrl = GET_CHILD(teamBattleRankSet, 'control');
	local prevBtn = GET_CHILD_RECURSIVELY(pageCtrl, 'prev');
	local nextBtn = GET_CHILD_RECURSIVELY(pageCtrl, 'next');
	prevBtn:SetEventScript(ui.LBUTTONUP, 'ADVENTURE_BOOK_RANKING_PAGE_SELECT_PREV');
	nextBtn:SetEventScript(ui.LBUTTONUP, 'ADVENTURE_BOOK_RANKING_PAGE_SELECT_NEXT');
end

function ADVENTURE_BOOK_TEAM_BATTLE_RANK_UPDATE(frame, msg, argStr, argNum)
    local rank_type = session.worldPVP.GetRankProp("Type");    
	if rank_type == 210 then
        return;
	end
	local teamBattleRankSet = GET_CHILD_RECURSIVELY(frame, 'teamBattleRankSet');
	local EACH_RANK_SET_HEIGHT_FOR_TB = tonumber(teamBattleRankSet:GetUserConfig('EACH_RANK_SET_HEIGHT_FOR_TB'));
    local rankingBox = GET_CHILD(teamBattleRankSet, 'rankingBox');
	rankingBox:RemoveAllChild();
    local pvpCls = GET_TEAM_BATTLE_CLASS();
	local pvpType = pvpCls.ClassID;
	local type = session.worldPVP.GetRankProp("Type");
	local league = session.worldPVP.GetRankProp("League");
	local page = session.worldPVP.GetRankProp("Page");
	local totalCount = session.worldPVP.GetRankProp("TotalCount");
	
	local cnt = session.worldPVP.GetRankInfoCount();
	for i = 0 , cnt - 1 do
		local info = session.worldPVP.GetRankInfoByIndex(i);
		local ctrlSet = rankingBox:CreateControlSet("pvp_rank_ctrl", "CTRLSET_" .. i,  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
		UPDATE_PVP_RANK_CTRLSET(ctrlSet, info);
        ctrlSet:Resize(rankingBox:GetWidth(), EACH_RANK_SET_HEIGHT_FOR_TB);
	end
	GBOX_AUTO_ALIGN(rankingBox, 0, 0, 0, true, false);

	local totalPage = math.floor((totalCount + WORLDPVP_RANK_PER_PAGE)/ WORLDPVP_RANK_PER_PAGE) ;
	local control = GET_CHILD(teamBattleRankSet, 'control', 'ui::CPageController')
	control:SetMaxPage(totalPage);
	control:SetCurPage(page - 1);

	local reward = GET_CHILD_RECURSIVELY(frame, 'teamBattleRewardBtn');
	local cid = session.GetMySession():GetCID();
	local myRank = session.worldPVP.GetPrevRankInfoByCID(cid);
	if myRank ~= nil and myRank.ranking < 3 then
		reward:SetEnable(1)
	else
		reward:SetEnable(0)
	end
end

function ADVENTURE_BOOK_JOIN_WORLDPVP(parent, ctrl)
    if IS_IN_EVENT_MAP() == true then
        ui.SysMsg(ClMSg('ImpossibleInCurrentMap'));
        return;
    end 

	local accObj = GetMyAccountObj();
	if IsBuffApplied(GetMyPCObject(), "TeamBattleLeague_Penalty_Lv1") == "YES" or IsBuffApplied(GetMyPCObject(), "TeamBattleLeague_Penalty_Lv2") == "YES" then
		ui.SysMsg(ClMsg("HasTeamBattleLeaguePenalty"));
		return;
	end
	
	local cls = GET_TEAM_BATTLE_CLASS();
	if nil == cls then
		ui.SysMsg(ScpArgMsg("DonotOpenPVP"))
		return;
	end	

    local pvpType = cls.ClassID;
	if IsBuffApplied(GetMyPCObject(), "UNKNOWN_SANTUARY_PC") == "YES" then 
	local state = session.worldPVP.GetState();
	if state == PVP_STATE_NONE then
			local top_frame_name = parent:GetTopParentFrame():GetName();
			local parent_name = parent:GetName();
			local yes_scp = string.format("ADVENTURE_BOOK_JOIN_WORLDPVP_UNKNOWN_SANTUARTY_PC_BUFF_YES_SCP(\"%s\",\"%s\",\"%d\")", top_frame_name, parent_name, pvpType);
			ui.MsgBox(ClMsg("WorldPVP_JoinCheck_UnknownSantuaryPCBuff"), yes_scp, "None");
				 return;
			end
			end
	JOIN_WORLDPVP_BY_TYPE(parent, pvpType);
				return;
			end
		
function ADVENTURE_BOOK_JOIN_WORLDPVP_UNKNOWN_SANTUARTY_PC_BUFF_YES_SCP(frame_name, parent_name, pvp_type)
	local frame = ui.GetFrame(frame_name);
	local parent = GET_CHILD_RECURSIVELY(frame, parent_name);
	if parent ~= nil then
		JOIN_WORLDPVP_BY_TYPE(parent, pvp_type);
		end
end

function ADVENTURE_BOOK_TEAM_BATTLE_STATE_CHANGE(frame, msg, argStr, argNum)
	local state = session.worldPVP.GetState();
	local stateText = GetPVPStateText(state);
	local viewText = ClMsg( "PVP_State_".. stateText );
	local join = GET_CHILD_RECURSIVELY(frame, 'teamBattleMatchingBtn');
	join:SetTextByKey("text", viewText);

	if state == PVP_STATE_FINDING then
        ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(frame);
	elseif state == PVP_STATE_READY then
		local cls = GET_TEAM_BATTLE_CLASS();
		if cls.MatchType ~= "Guild" then
			return;
		end
		local isLeader = AM_I_LEADER(PARTY_GUILD);
		if 1 ~= isLeader then
			return;
		end
		ui.Chat("/sendMasterEnter");
	end
	if 1 == ui.IsFrameVisible("worldpvp_ready") then
		WORLDPVP_READY_STATE_CHANGE(state, pvpType);
	end
end

function ADVENTURE_BOOK_TEAM_BATTLE_HISTORY_UPDATE(frame, msg, argStr, argNum)
end

function ADVENTURE_BOOK_TEAM_BATTLE_SEARCH(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local teamBattleRankSet = GET_CHILD_RECURSIVELY(topFrame, 'teamBattleRankSet');
    local control = GET_CHILD(teamBattleRankSet, 'control');
    local page = control:GetCurPage();
    local adventureBookRankSearchEdit = GET_CHILD_RECURSIVELY(teamBattleRankSet, 'adventureBookRankSearchEdit');
    local teamBattleCls = GET_TEAM_BATTLE_CLASS();
	local searchText = adventureBookRankSearchEdit:GetText();
    if searchText == nil or searchText == '' then
		worldPVP.RequestPVPRanking(teamBattleCls.ClassID, 0, -1, 1, 0, '');
	else		
		worldPVP.RequestPVPRanking(teamBattleCls.ClassID, 0, -1, page, 0, adventureBookRankSearchEdit:GetText());
	end
	ui.DisableForTime(control, 0.5);
end

function WORLDPVP_PUBLIC_GAME_LIST(frame, msg, argStr, argNum)
	local is_guild_pvp = 0;
	if frame:IsVisible() == 0 then is_guild_pvp = 1; end

	local bg_observer = GET_CHILD_RECURSIVELY(frame, "bg_observer");
	local CTRLSET_OFFSET = bg_observer:GetUserConfig('CTRLSET_OFFSET');

	local gbox = bg_observer:GetChild("gbox");
	gbox:RemoveAllChild();

	local world_pvp_frame = ui.GetFrame("worldpvp");
	local game_index_list = WORLDPVP_PUBLIC_GAME_LIST_BY_TYPE(is_guild_pvp);

	local ctrl_set_y = 0;
	local max_count = 3;
	local cnt = math.min(#game_index_list, max_count);
	for i = 1, cnt do
		local index = game_index_list[i];
		if index ~= nil then
			local info = session.worldPVP.GetPublicGameByIndex(index);
			local ctrl_set = gbox:CreateControlSet("pvp_observe_ctrlset", "CTRLSET_"..i, 0, ctrl_set_y);
			if ctrl_set ~= nil then
				ctrl_set:SetUserValue("GAME_ID", info.guid);
				local gbox_pc = ctrl_set:GetChild("gbox_pc");
				local gbox_ctrl_set = ctrl_set:GetChild("gbox");
				local gbox_whole = ctrl_set:GetChild("gbox_whole");

				local gbox_1 = ctrl_set:GetChild("gbox_1");
				local teamVec1 = info:CreateTeamInfo(1);
				WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_1, teamVec1, 1);
				SET_VS_NAMES(world_pvp_frame, ctrl_set, 1, WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_1, teamVec1, 1));

				local gbox_2 = ctrl_set:GetChild("gbox_2");
				local teamVec2 = info:CreateTeamInfo(2);
				SET_VS_NAMES(world_pvp_frame, ctrl_set, 2, WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_2, teamVec2, 2));		

				local height_add_value = 7;
				local height = math.max(gbox_1:GetHeight(), gbox_2:GetHeight()) + height_add_value;
				gbox_ctrl_set:Resize(gbox_ctrl_set:GetWidth(), height);
				
				local btn = ctrl_set:GetChild("btn");
				ctrl_set:Resize(ctrl_set:GetWidth(), height + btn:GetHeight() + height_add_value + 45);
				gbox_whole:Resize(ctrl_set:GetWidth(), height + btn:GetHeight() + height_add_value +50);

				ctrl_set_y = ctrl_set_y + ctrl_set:GetHeight() + CTRLSET_OFFSET;
			end
		end
	end
end