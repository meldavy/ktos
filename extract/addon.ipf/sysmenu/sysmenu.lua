function SYSMENU_ON_INIT(addon, frame)
	addon:RegisterMsg('NOTICE_Dm_levelup_base', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('PC_PROPERTY_UPDATE', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('GAME_START', 'SYSMENU_ON_MSG');
	addon:RegisterOpenOnlyMsg('RESET_SKL_UP', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('JOB_CHANGE', 'SYSMENU_ON_JOB_CHANGE');
	addon:RegisterMsg('JOB_SKILL_POINT_UPDATE', 'SYSMENU_ON_MSG');
	addon:RegisterMsg("NPC_AUCTION_MYINFO", "ON_SYSMENU_AUCTIONINFO")
	addon:RegisterMsg("UPDATE_FRIEND_LIST", "SYSMENU_ON_MSG")
	addon:RegisterMsg("REMOVE_FRIEND", "SYSMENU_ON_MSG");
	addon:RegisterMsg("ADD_FRIEND", "SYSMENU_ON_MSG");
	addon:RegisterMsg("GUILD_ENTER", "SYSMENU_MYPC_GUILD_JOIN");

	addon:RegisterMsg('SERV_UI_EMPHASIZE', 'ON_UI_EMPHASIZE');
	addon:RegisterMsg("UPDATE_READ_COLLECTION_COUNT", "SYSMENU_ON_MSG");

	local statusBtn = frame:GetChild('status');
	HIDE_CHILD(statusBtn, 'notice');
	HIDE_CHILD(statusBtn, 'noticetext');
	frame:EnableHideProcess(1);

end

function SYSMENU_ON_JOB_CHANGE(frame)
	SYSMENU_CHECK_HIDE_VAR_ICONS(frame);
	
	--"SYSMENU_CHANGED" �޽��� ������ ���.
	SYSMENU_JOYSTICK_ON_MSG();
end

function SYSMENU_MYPC_GUILD_JOIN(frame)
	SYSMENU_CHECK_HIDE_VAR_ICONS(frame);	
	
	--"SYSMENU_CHANGED" �޽��� ������ ���.
	SYSMENU_JOYSTICK_ON_MSG();
end

function SYSMENU_ON_MSG(frame, msg, argStr, argNum)
	if msg == "GAME_START" then
		frame:RunUpdateScript("JANSORI", 0.01, 0.0, 0, 1);
		SYSMENU_CHECK_HIDE_VAR_ICONS(frame);
	end

	if msg == 'PC_PROPERTY_UPDATE' or msg == 'RESET_SKL_UP' or msg =='GAME_START' or msg=='UPDATE_READ_COLLECTION_COUNT' then
		SYSMENU_PC_STATUS_NOTICE(frame);
		SYSMENU_PC_SKILL_NOTICE(frame);
		SYSMENU_CHECK_OPENCONDITION(frame);
		SYSMENU_PC_NEWFRIEND_NOTICE(frame)
		frame:Invalidate();
	end

	if msg == 'JOB_SKILL_POINT_UPDATE' then
		SYSMENU_PC_SKILL_NOTICE(frame);
		imcSound.PlaySoundEvent('sys_alarm_skl_status_point_count');
	end

	if msg == 'UPDATE_FRIEND_LIST' or msg == 'REMOVE_FRIEND' or msg == 'ADD_FRIEND' then
		SYSMENU_PC_NEWFRIEND_NOTICE(frame)
		frame:Invalidate();
	end
end

function CHECK_SYSMENU_OPENCOND()
	local frame = ui.GetFrame("sysmenu");
	SYSMENU_CHECK_OPENCONDITION(frame)
end

function SYSMENU_CHECK_OPENCONDITION(frame)

	CHECK_CTRL_OPENCONDITION(frame, "status", "status");
	CHECK_CTRL_OPENCONDITION(frame, "inven", "inventory");
	CHECK_CTRL_OPENCONDITION(frame, "skilltree", "skilltree");
	CHECK_CTRL_OPENCONDITION(frame, "quest", "quest");
	CHECK_CTRL_OPENCONDITION(frame, "sys_collection", "sys_collection");
	CHECK_CTRL_OPENCONDITION(frame, "helplist", "helplist");
	--CHECK_CTRL_OPENCON_SCP(frame, "inte_warp", CHECK_WARP_VISIBLE);


end

function SYSMENU_CHECK_HIDE_VAR_ICONS(frame)

	if false == VARICON_VISIBLE_STATE_CHANTED(frame, "necronomicon", "necronomicon")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "grimoire", "grimoire")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "guild", "guild")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "poisonpot", "poisonpot")
	then
		return;
	end

	DESTROY_CHILD_BY_USERVALUE(frame, "IS_VAR_ICON", "YES");

	local status = frame:GetChild("status");
	local inven = frame:GetChild("inven");
	local offsetX = inven:GetX() - status:GetX();
	local startX = status:GetMargin().left - offsetX;

	startX = SYSMENU_CREATE_VARICON(frame, status, "guild", "guild", "sysmenu_guild", startX, offsetX, "Guild");
	startX = SYSMENU_CREATE_VARICON(frame, status, "necronomicon", "necronomicon", "sysmenu_card", startX, offsetX);
	startX = SYSMENU_CREATE_VARICON(frame, status, "grimoire", "grimoire", "sysmenu_neacro", startX, offsetX);
	startX = SYSMENU_CREATE_VARICON(frame, status, "poisonpot", "poisonpot", "sysmenu_wugushi", startX, offsetX);
	

	
	-- frame:CreateControl("")
	-- print(status:GetWidth());

	-- 		<button name="grimoire" rect="0 0 44 44" margin="520 0 0 10" layout_gravity="center bottom" LBtnUpScp="ui.ToggleFrame(&apos;grimoire&apos;)" MouseOffAnim="btn_mouseoff_2" MouseOnAnim="btn_mouseover_2" clickrgn="0 0 44 44" clicksound="button_click_2" image="sysmenu_card" oversound="button_over" skin="textbutton" textalign="center center" texttooltip="{@st59}�׸����{/}"/>
	-- CHECK_CTRL_OPENCONDITION(frame, "necronomicon", "necronomicon");	
	-- CHECK_CTRL_OPENCONDITION(frame, "grimoire", "grimoire");

end

function SYSMENU_CREATE_VARICON(frame, status, ctrlName, frameName, imageName, startX, offsetX, hotkeyName)

	local invenOpen = ui.CanOpenFrame(frameName);
	if invenOpen == 0 then
		return startX;
	end

	local margin = status:GetMargin();
	local btn = frame:CreateControl("button", ctrlName, status:GetWidth(), status:GetHeight(), ui.CENTER_HORZ, ui.BOTTOM, startX, margin.top, margin.right, margin.bottom);
	if btn == nil then
		return startX;
	end

	btn:CloneFrom(status);

	startX = startX - offsetX;
	AUTO_CAST(btn);
	btn:SetImage(imageName);
	btn:SetUserValue("IS_VAR_ICON", "YES");
	local tooltipString = ScpArgMsg(frameName);
	if hotkeyName ~= nil then
		local hotKey = hotKeyTable.GetHotKeyString(hotkeyName, 2, 1);	
		tooltipString = tooltipString .. string.format(" (%s)", hotKey);
	end

	btn:SetTextTooltip("{@st59}" .. tooltipString);
	btn:SetEventScript(ui.LBUTTONUP, string.format("ui.ToggleFrame('%s')", frameName));
	return startX;
	----- 		<button name="grimoire" rect="0 0 44 44" margin="520 0 0 10" layout_gravity="center bottom" LBtnUpScp="ui.ToggleFrame(&apos;grimoire&apos;)" MouseOffAnim="btn_mouseoff_2" MouseOnAnim="btn_mouseover_2" clickrgn="0 0 44 44" clicksound="button_click_2" image="sysmenu_card" oversound="button_over" skin="textbutton" textalign="center center" texttooltip="{@st59}�׸����{/}"/>

end

function VARICON_VISIBLE_STATE_CHANTED(frame, ctrlName, frameName)
	local invenOpen = ui.CanOpenFrame(frameName);
	
	local currentVisible = 0;
	local inven = GET_CHILD(frame, ctrlName);
	if inven ~= nil then
		currentVisible = 1;
	end

	return currentVisible ~= beforeVisible;
end

function CHECK_WARP_VISIBLE()
	if 1 == 1 then
		return 0;
	end

	local result = GET_INTE_WARP_LIST();
	if result ~= nil and #result > 0 then
		return 1;
	end

	return 0;
end

function SYSMENU_FORCE_ALARM(childName, abilName)
	local frame = ui.GetFrame("sysmenu");

	local inven = GET_CHILD(frame, childName, "ui::CButton");

	if inven == nil then
		return;
	end

	local msg = ScpArgMsg("{The}AbilityIsActivated", "The", ClMsg(abilName));
	local fx, fy = NOTICE_CUSTOM(msg, inven:GetImageName());

	imcSound.PlaySoundEvent("statsup");
	local tx, ty = GET_UI_FORCE_POS(inven);
	UI_FORCE("sysmenu_alarm", fx, fy, tx, ty, 2, inven:GetImageName());
end

function CHECK_COLLECTION_VISIBLE()

	local colls = session.GetMySession():GetCollection();
	if colls:Count() > 0 then
		return 1;
	else
		return 0;
	end

end

function CHECK_HELPLIST_VISIBLE()

	local helpCount = session.GetHelpVecCount();

	if helpCount > 0 then
		return 1;
	else
		return 0;
	end

end

function CHECK_CTRL_OPENCON_SCP(frame, ctrlName, func, abilName)

	local inven = GET_CHILD(frame, ctrlName, "ui::CButton");
	local beforeVisible = inven:IsVisible();
	local visible = func();
	if beforeVisible == visible then
		return;
	end

	inven:ShowWindow(visible);
	frame:Invalidate();

	if beforeVisible == 0 and session.IsGameStarted() == 1 then
		inven:Emphasize("focus_ui", 10, 1.0, "AAFFFFFF");
		UI_PLAYFORCE(inven, "emphasize_1", 0, 0);
		--imcSound.PlaySoundEvent("statsup");
	end

end

function CHECK_CTRL_OPENCONDITION(frame, ctrlName, frameName)

	local inven = GET_CHILD(frame, ctrlName, "ui::CButton");
	
	if inven == nil then
		return
	end

	local invenOpen = ui.CanOpenFrame(frameName);
	local beforeVisible = inven:IsVisible();
	if beforeVisible == invenOpen then
		return;
	end

	inven:ShowWindow(invenOpen);
	frame:Invalidate();

	if beforeVisible == 0 and session.IsGameStarted() == 1 then
		inven:Emphasize("focus_ui", 0, 1.0, "AAFFFFFF");
		ui.CheckStopEmphaSize(frameName, frame:GetName(), ctrlName);
	end
end

function ON_UI_EMPHASIZE(frame, msg, argStr, argNum)

	local cnt, imageName, frameName, childName, targetName = Tokenize(argStr);
	RUN_UI_EMPHASIZE(imageName, frameName, childName, targetName, argNum);

end

function RUN_UI_EMPHASIZE(imageName, frameName, uiName, openFrameName, time)

	local frame = ui.GetFrame(frameName);
	local ctrl = frame:GetChild(uiName);
	ctrl:Emphasize(imageName, 0, 1.0, "AAFFFFFF");
	ui.CheckStopEmphaSize(openFrameName, frameName, uiName, time);
end

function SYSMENU_PC_STATUS_NOTICE(frame)
	local pc = GetMyPCObject();
	local bonusstat = GET_STAT_POINT(pc);
	local parentCtrl = frame:GetChild('status');
	NOTICE_CTRL_SET(parentCtrl, "status", bonusstat);
end

function SYSMENU_PC_NEWFRIEND_NOTICE(frame)

	local cnt = session.friends.GetFriendCount(FRIEND_LIST_REQUESTED);
	local parentCtrl = frame:GetChild('friend');
	NOTICE_CTRL_SET(parentCtrl, "friend", cnt);

end

function SYSMENU_PC_SKILL_NOTICE(frame)

	local parentCtrl = frame:GetChild("skilltree");
	local point = session.GetSkillPoint();
	NOTICE_CTRL_SET(parentCtrl, "skilltree", point);
end

function SYSMENU_COLLECTION_NOTICE(frame)

	local parentCtrl = frame:GetChild("sys_collection");

	local pc = session.GetMySession();
	local etcObj = GetMyEtcObject();
	local colls = pc:GetCollection();
	local cnt = colls:Count();
	local point = 0
	for i = 0 , cnt - 1 do
		local coll = colls:GetByIndex(i);
		local isread = etcObj['CollectionRead_' .. coll.type]
		if isread == 0 then
			point = point + 1
		end
	end
	
	NOTICE_CTRL_SET(parentCtrl, "sys_collection", point);
end

function NOTICE_CTRL_SET(parentCtrl, noticeName, point)

	if parentCtrl == nil then
		return
	end

	local notice = parentCtrl:GetChild(noticeName.."notice");
	local noticeText = parentCtrl:GetChild(noticeName.."noticetext");

	if point > 0 then
		notice:ShowWindow(1);
		noticeText:ShowWindow(1);
		noticeText:SetText('{ol}{b}{s14}'..tostring(point));
		if point >= 10 and point < 100 then
			notice:Resize(0, 0, 30, 22);
			noticeText:SetOffset(6, 2);
		elseif point >= 100 and point < 1000 then
			notice:Resize(0, 0, 40, 22);
			noticeText:SetOffset(6, 2);
		else
			notice:Resize(0, 0, 22, 22);
			noticeText:SetOffset(6, 2);
		end
	elseif point == 0 then
		notice:ShowWindow(0);
		noticeText:ShowWindow(0);
	end
end

function SYSMENU_BTN_MOUSE_MOVE(frame, btnCtrl, argStr, argNum)
	ui.OpenFrame("apps");
end

function SYSMENU_BTN_LCLICK(frame, btnCtrl, argStr, argNum)
	ui.OpenFrame("apps");
end


function SYSMENU_BTN_LOST_FOCUS(frame, btnCtrl, argStr, argNum)

	local focusFrame = ui.GetFocusFrame();
	if focusFrame ~= nil then
		local focusFrameName = focusFrame:GetName();
		if focusFrameName == "apps" then
			return;
		end

		if focusFrameName == "sysmenu" then
			local object = ui.GetFocusObject();
			if ui.GetFocusObject() == btnCtrl then
				return;
			end
		end
	end

	ui.CloseFrame("apps");
end

function SYSMENU_LOSTFOCUS_SCP(frame, ctrl, argStr, argNum)

	--[[
	�޴� ��� Ȱ��ȭ �Ǿ��ֵ��� �ؼ� �ּ�ó��

	local focusFrame = ui.GetFocusFrame();
	if focusFrame ~= nil then
		local focusFrameName = focusFrame:GetName();
		if focusFrameName == "apps" or focusFrameName == "sysmenu" then
			return;
		end
	end

	if 1 == ctrl:GetUserIValue("DISABLE_L_FOCUS") then
		return;
	end

	
	]]
end

function SYSMENU_SHOW_FOR_SEC(sec)
	--[[
	local frame = ui.GetFrame("sysmenu");
	SYSMENU_ENABLE_LOST_FOCUS(frame, 0);
	frame:RunUpdateScript("SYSMENU_AUTO_LOST_FOCUS", sec);
	]]
end

function SYSMENU_AUTO_LOST_FOCUS(frame)
	--SYSMENU_ENABLE_LOST_FOCUS(frame, 1)
	return 0;
end

function SYSMENU_ENABLE_LOST_FOCUS(frame, isEnable)
	--[[
	if isEnable == 1 then
		frame:SetUserValue("DISABLE_L_FOCUS", 0);
		frame:SetEffect("sysmenu_LostFocus", ui.UI_LOSTFOCUS);
		frame:SetEffect("sysmenu_LostFocus", ui.UI_TEMP0);
		frame:StartEffect(ui.UI_TEMP0);
	else
		frame:SetUserValue("DISABLE_L_FOCUS", 1);
		frame:SetEffect("None", ui.UI_LOSTFOCUS);
		frame:SetEffect("sysmenu_MouseMove", ui.UI_TEMP0);
		frame:StartEffect(ui.UI_TEMP0);
	end
	]]
end

function SYSMENU_UPDATE_QUEUE(frame, queue)
	queue:UpdateData();
	if queue:GetChildCount() == 0 then
		queue:ShowWindow(0);
	else
		queue:ShowWindow(1);
	end
	queue:Invalidate();
	frame:Invalidate();
end

function SYSMENU_DELETE_QUEUE_BTN(frame, ctrlName)
	local queue = frame:GetChild("alarmqueue");
	queue:RemoveChild(ctrlName);
	SYSMENU_UPDATE_QUEUE(frame, queue);
end


function SYSMENU_CREATE_QUEUE_BTN(frame, ctrlName, image, updateQueue)
	local queue = frame:GetChild("alarmqueue");
	local pic = queue:CreateOrGetControl("picture", ctrlName, 44, 44, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
	pic = tolua.cast(pic, "ui::CPicture");
	pic:SetEnableStretch(1);
	pic:SetImage(image);
	pic:ShowWindow(1);

	if updateQueue == 1 then
		SYSMENU_UPDATE_QUEUE(frame, queue);
	end

	return pic;
end

function ON_SYSMENU_AUCTIONINFO(frame)

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local vec = geNPCAuction.GetAuctionVec();

	local queue = frame:GetChild("alarmqueue");
	local aucItem = nil;
	for i = 0 , vec:size() - 1 do
		local auc = vec:at(i);
		aucItem = auc:GetRelatedItem(cid);
		if aucItem ~= nil then
			break;
		end
	end

	if aucItem == nil then
		queue:RemoveChild("AUCTION");
	else
		local pic = SYSMENU_CREATE_QUEUE_BTN(frame, "AUCTION", "skillpower_icon");
		pic:SetTooltipType("auction_sysmenu");
		pic:SetTooltipArg("", 0, aucItem:GetGuid());

		if aucItem:GetCID() == cid then
			pic:SetColorTone("FFFFFFFF");
		else
			pic:SetColorTone("FFFF0000");
		end
	end

	SYSMENU_UPDATE_QUEUE(frame, queue);

end

function UPDATE_AUCTION_SYSMENU_TOOLTIP(frame, strArg, num, guid)

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();

	local item = geNPCAuction.GetByGuid(guid);

	local itemCls = GetClassByType("Item", item.itemType);
	local pic = GET_CHILD(frame, "pic", "ui::CPicture");
	pic:SetImage(itemCls.Icon);

	local itemtext = GET_CHILD(frame, "itemtext", "ui::CRichText");
	local text;
	local font;
	if cid == item:GetCID() then
		text = ScpArgMsg("NowYouAreTopBidderOf{Auto_1}", "Auto_1", itemCls.Name);
		font = "{@st55_c}";
	else
		font = "{@st42_red}";
		local tname = item:GetName();
		if tname == "" then
			tname = ClMsg("OtherPC");
		end

		text = ScpArgMsg("{Bidder}IsTopBidderOf{ItemName}", "Bidder", tname, "ItemName", itemCls.Name);
	end

	itemtext:SetText(font .. text);
	itemtext:Resize(220, 50);
	itemtext:SetTextFixWidth(1);
	itemtext:EnableResizeByText(1);

	local money =  GET_CHILD(frame, "money", "ui::CRichText");
	local text = "{@sti9}" .. GET_MONEY_IMG(24) .. " " .. GetCommaedText(item.curPrice);
	money:SetText(text);

	frame:SetUserValue("GUID", guid);
	frame:RunUpdateScript("UPDATE_AUCTION_TOOLTIP_TIME", 0, 0, 0, 1);
	AUCTION_TOOLTIP_SET_REMAINTIME(frame, item);

	frame:Invalidate();
end

function UPDATE_AUCTION_TOOLTIP_TIME(frame)
	local guid = frame:GetUserValue("GUID");
	local aucItem = geNPCAuction.GetByGuid(guid);
	AUCTION_TOOLTIP_SET_REMAINTIME(frame, aucItem);
	return 1;
end

function AUCTION_TOOLTIP_SET_REMAINTIME(frame, aucItem)

	local endTime = aucItem:GetEndSysTime();
	local curTime = geTime.GetServerSystemTime();
	local difSec = imcTime.GetIntDifSec(endTime, curTime);
	local timeString = GET_DHMS_STRING(difSec);
	local text = ScpArgMsg("RemainTime:{Auto_1}","Auto_1", timeString);
	frame:GetChild("remaintime"):SetText("{@55_c}" .. text);

end

function TOGGLE_CARD_REINFORCE(frame)
	local rframe = ui.GetFrame("reinforce_by_mix");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("CardReinforce"));
		rframe:ShowWindow(1);
	end
end

function TOGGLE_GEM_REINFORCE(frame)
	local rframe = ui.GetFrame("reinforce_by_mix");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("GemReinforce"));
		rframe:ShowWindow(1);
	end
end
