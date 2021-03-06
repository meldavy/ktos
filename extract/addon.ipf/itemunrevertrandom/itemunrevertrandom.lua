-- 신비한 돋보기
function ITEMUNREVERTRANDOM_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_SUCCESS_UNREVERT_RANDOM_OPTION", "SUCCESS_UNREVERT_RANDOM_OPTION");
	addon:RegisterMsg("ON_UI_TUTORIAL_NEXT_STEP", "UNREVERT_RANDOM_TUTO_CHECK");
end

function OPEN_UNREVERT_RANDOM(invItem)
	for i = 1, #revertrandomitemlist do
		local frame = ui.GetFrame(revertrandomitemlist[i]);
		if frame ~= nil and frame:IsVisible() == 1 and revertrandomitemlist[i] ~= "itemunrevertrandom" then
			return;
		end
	end

	local item = GetIES(invItem:GetObject());
	local frame = ui.GetFrame('itemunrevertrandom');
	frame:SetUserValue('REVERTITEM_GUID', invItem:GetIESID());
	frame:SetUserValue("CLASS_ID", item.ClassID);

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, "richtext_1");
	richtext_1:SetTextByKey("value", item.Name);	

	local text_needmaterial = GET_CHILD_RECURSIVELY(frame, "text_needmaterial");
	text_needmaterial:SetTextByKey("name", item.Name);	

	frame:ShowWindow(1);
end

function ITEM_UNREVERT_RANDOM_OPEN(frame)
	CLEAR_ITEM_UNREVERT_RANDOM_UI()
	ui.OpenFrame("inventory")

	local tab = GET_CHILD_RECURSIVELY(ui.GetFrame("inventory"), "inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	tab:SelectTab(0);

	INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_UNREVERT_RANDOM_INV_RBTN")

	UNREVERT_RANDOM_TUTO_CHECK(frame)
end

function ITEM_UNREVERT_RANDOM_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	frame:ShowWindow(0);
	control.DialogOk();
	TUTORIAL_TEXT_CLOSE(frame);
end

function UNREVERT_RANDOM_TUTO_CHECK(frame, msg, arg_str, arg_num)
	if frame == nil or frame:IsVisible() == 0 then return end

	if session.shop.GetEventUserType() == 0 then return end

	if arg_num == 100 then
		TUTORIAL_TEXT_CLOSE(frame)
		return
	end

	local open_flag = false
	if msg == nil then
		open_flag = true
	end

	local prop_name = "UITUTO_GLASS1"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function UNREVERT_RANDOM_UPDATE(isSuccess)
	local frame = ui.GetFrame("itemunrevertrandom");
	UPDATE_UNREVERT_RANDOM_ITEM(frame);
	UPDATE_UNREVERT_RANDOM_RESULT(frame, isSuccess);
end

function CLEAR_ITEM_UNREVERT_RANDOM_UI()
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("itemunrevertrandom");

	local slot = GET_CHILD_RECURSIVELY(frame, "slot", "ui::CSlot");
	slot:ClearIcon();

	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(0)

	local do_unrevertrandom = GET_CHILD_RECURSIVELY(frame, "do_unrevertrandom")
	do_unrevertrandom:ShowWindow(1)

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(1)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(1)
		
	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText("")

	local bodyGbox1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1');
	bodyGbox1:ShowWindow(1)
	local bodyGbox1_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1_1');
	bodyGbox1_1:RemoveAllChild();

	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(0)
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:RemoveAllChild();

	UPDATE_REMAIN_MYSTIC_GLASS_COUNT(frame)
end

function SENDOK_ITEM_UNREVERT_RANDOM_UI()
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("itemunrevertrandom");

	local slot = GET_CHILD_RECURSIVELY(frame, "slot", "ui::CSlot");
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	slot:ClearIcon();
	
	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(0)

	local do_unrevertrandom = GET_CHILD_RECURSIVELY(frame, "do_unrevertrandom")
	do_unrevertrandom:ShowWindow(1)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(1)

	local bodyGbox1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1');
	bodyGbox1:ShowWindow(1)
	local bodyGbox1_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1_1');
	bodyGbox1_1:RemoveAllChild();

	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(0)
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:RemoveAllChild();

	local reset_flag = frame:GetUserValue('RESET_FLAG')
	if reset_flag == 'YES' then
		CLEAR_ITEM_UNREVERT_RANDOM_UI()
	else
		ITEM_UNREVERT_RANDOM_REG_TARGETITEM(frame, iconInfo:GetIESID())
	end

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GLASS1' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 2 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function ITEM_UNREVERT_RANDOM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local liftIcon 				= ui.GetLiftIcon();
	local FromFrame 			= liftIcon:GetTopParentFrame();
	local toFrame				= frame:GetTopParentFrame();
	CLEAR_ITEM_UNREVERT_RANDOM_UI()
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		ITEM_UNREVERT_RANDOM_REG_TARGETITEM(frame, iconInfo:GetIESID());
	end;
end;

function ITEM_UNREVERT_RANDOM_REG_TARGETITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then
		return;
	end

	local obj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', obj.ClassID)

	if TryGetProp(itemCls, "NeedRandomOption") == nil or itemCls.NeedRandomOption ~= 1 then
		ui.SysMsg(ClMsg("NotAllowedRandomReset"));
		return;
	end

	if IS_NEED_APPRAISED_ITEM(obj) == true or IS_NEED_RANDOM_OPTION_ITEM(obj) == true then 
		ui.SysMsg(ClMsg("NeedAppraisd"));
		return;
	end
		
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(0)

	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText(obj.Name);

	local gBox = GET_CHILD_RECURSIVELY(frame:GetTopParentFrame(), "bodyGbox1_1");
	local ypos = 0;
	for i = 1 , MAX_RANDOM_OPTION_COUNT do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if obj[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif obj[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif obj[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(obj[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, obj[propValue], 0);
			local itemClsCtrl = gBox:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..i, ui.TOP,ui.LEFT, 0, 0, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
			itemClsCtrl:Move(0, i * pos_y);			
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
			ypos = i * pos_y + propertyList:GetHeight() + 5;
		end
	end

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	SET_SLOT_ITEM(slot, invItem);

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GLASS1' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 0 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function ITEM_UNREVERT_RANDOM_EXEC(frame)
	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);

	if invItem == nil then
		return
	end

	local text_havematerial = GET_CHILD_RECURSIVELY(frame, "text_havematerial")
	local materialCnt = text_havematerial:GetTextByKey("count")
	if materialCnt == '0' then
		ui.SysMsg(ClMsg("LackOfUnrevertRandomMaterial"));
		return
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_msgbox')
	if check_no_msgbox:IsChecked() == 1 then
		_ITEM_UNREVERT_RANDOM_EXEC()
	else
		local clmsg = ScpArgMsg("DoUnrevertRandomReset")
		ui.MsgBox_NonNested(clmsg, frame:GetName(), "_ITEM_UNREVERT_RANDOM_EXEC", "None");
	end
end

function _ITEM_UNREVERT_RANDOM_EXEC()
	local frame = ui.GetFrame("itemunrevertrandom");
	if frame:IsVisible() == 0 then
		return;
	end
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', itemObj.ClassID)

	if itemCls.NeedRandomOption ~= 1 then
		ui.SysMsg(ClMsg("NotAllowedRandomReset"));
		return;
	end

	if ui.GetFrame("apps") ~= nil then
		ui.CloseFrame("apps")
	end

	local revertItemGUID = frame:GetUserValue('REVERTITEM_GUID');
	local revertItem = session.GetInvItemByGuid(revertItemGUID);
	if revertItem == nil then
		revertItemGUID = GET_NEXT_ITEM_GUID_BY_CLASSID(frame:GetUserValue("CLASS_ID"));
	end

	session.ResetItemList();
	session.AddItemID(revertItemGUID);
	session.AddItemID(invItem:GetIESID());
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("REVERT_ITEM_OPTION", resultlist);
end

function SUCCESS_UNREVERT_RANDOM_OPTION(frame, msg, argStr, argNum)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end

	frame:SetUserValue('RESET_FLAG', argStr)
	
	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');

	local do_unrevertrandom = GET_CHILD_RECURSIVELY(frame, "do_unrevertrandom")
	do_unrevertrandom:ShowWindow(0)

	ui.SetHoldUI(true);

	ReserveScript("_SUCCESS_UNREVERT_RANDOM_OPTION()", EFFECT_DURATION)
end

function _SUCCESS_UNREVERT_RANDOM_OPTION()
	ui.SetHoldUI(false);
	local frame = ui.GetFrame("itemunrevertrandom");
	if frame:IsVisible() == 0 then
		return;
	end

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		return;
	end

	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));

	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end
	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5);

	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(1)

	local invItemGUID = invItem:GetIESID()
	local resetInvItem = session.GetInvItemByGuid(invItemGUID)
	if resetInvItem == nil then
		resetInvItem = session.GetEquipItemByGuid(invItemGUID)
	end
	local obj = GetIES(resetInvItem:GetObject());

	local refreshScp = obj.RefreshScp
	if refreshScp ~= "None" then
		refreshScp = _G[refreshScp];
		refreshScp(obj);
	end
    
	local gBox = GET_CHILD_RECURSIVELY(frame, "bodyGbox2_1");
    local ypos = 0;
	for i = 1 , MAX_RANDOM_OPTION_COUNT do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if obj[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif obj[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif obj[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'			
		elseif obj[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(obj[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, obj[propValue], 0);
			local itemClsCtrl = gBox:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..i,ui.TOP,ui.LEFT, 0, 0, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
			itemClsCtrl:Move(0, i * pos_y)
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
            ypos = i * pos_y + propertyList:GetHeight() + 5;
		end
	end

	local bodyGbox1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1');
	bodyGbox1:ShowWindow(0)
	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(1)

	UPDATE_REMAIN_MYSTIC_GLASS_COUNT(frame)

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GLASS1' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 1 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function UPDATE_REMAIN_MYSTIC_GLASS_COUNT(frame)
	local classID = frame:GetUserValue("CLASS_ID");
	local itemHaveCount = GET_INV_ITEM_COUNT_BY_CLASSID(classID);
	
	local text_havematerial = GET_CHILD_RECURSIVELY(frame, "text_havematerial")
	text_havematerial:SetTextByKey("count", itemHaveCount)
end

function REMOVE_UNREVERT_RANDOM_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	slot:ClearIcon();
	CLEAR_ITEM_UNREVERT_RANDOM_UI()
end

function ITEM_UNREVERT_RANDOM_INV_RBTN(itemObj, slot)
	local frame = ui.GetFrame("itemunrevertrandom");
	if frame == nil then
		return
	end

	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
	local obj = GetIES(invItem:GetObject());
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local slotInvItem = GET_SLOT_ITEM(slot);
	
	CLEAR_ITEM_UNREVERT_RANDOM_UI()

	ITEM_UNREVERT_RANDOM_REG_TARGETITEM(frame, iconInfo:GetIESID()); 
end
