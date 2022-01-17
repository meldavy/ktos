-- monstercardslot.lua

local isSaved = true
local needApply = false
local curPreset = 0
local g_isChanged = false

function MONSTERCARDSLOT_ON_INIT(addon, frame)
	addon:RegisterMsg("DO_OPEN_MONSTERCARDSLOT_UI", "MONSTERCARDSLOT_FRAME_OPEN");
	addon:RegisterMsg("MSG_PLAY_LEGENDCARD_OPEN_EFFECT", "PLAY_LEGENDCARD_OPEN_EFFECT");
	addon:RegisterMsg("MSG_PLAY_GODDESSCARD_OPEN_EFFECT", "PLAY_GODDESSCARD_OPEN_EFFECT");

	addon:RegisterMsg("CHANGE_RESOLUTION", "CARD_OPTION_OPEN");
end

function MONSTERCARDSLOT_FRAME_OPEN()
	local frame = ui.GetFrame('monstercardslot')
	local etcObj = GetMyEtcObject()
	local selectedPreset = TryGetProp(etcObj, "SelectedPreset", 0)
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	droplist:SelectItemByKey(selectedPreset)
	MONSTERCARDSLOT_FRAME_INIT()
	RequestCardPreset(selectedPreset)
	g_isChanged = false
end

function MONSTERCARDSLOT_FRAME_INIT()
	local frame = ui.GetFrame('monstercardslot')
	ui.OpenFrame("monstercardslot")

	CARD_PRESET_CLEAR_SLOT(frame)
	CARD_SLOTS_CREATE(frame)

	local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
	local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
	optionGbox:ShowWindow(1)	

	CARD_OPTION_OPEN(frame)
	frame:SetUserValue("CARD_OPTION_OPENED", 0);

	local pcEtc = GetMyEtcObject()
	if pcEtc["IS_LEGEND_CARD_OPEN"] == 1 then
		local LEGlockGbox = GET_CHILD_RECURSIVELY(frame, "LEGslot_lock_box")
		LEGlockGbox:ShowWindow(0)
	end
	local aObj = GetMyAccountObj()
	if pcEtc["IS_LEGEND_CARD_OPEN"] == 1 and aObj["IS_GODDESS_CARD_OPEN"] == 1 then
		ui.OpenFrame("goddesscardslot")
	end

 	isSaved = true
end

function MONSTERCARDSLOT_CLOSE()
	ui.CloseFrame('monstercardslot')
	ui.CloseFrame('goddesscardslot')
end

function MONSTERCARDSLOT_FRAME_CLOSE()
	if g_isChanged == true then
		local msgBox = ui.MsgBox(ClMsg("NotChangeCardPreSetInfo"), "MONSTERCARDSLOT_CLOSE()", "None");
	else
		MONSTERCARDSLOT_CLOSE()
	end
end

-- 인벤토리의 카드 슬롯 생성 부분
function CARD_SLOTS_CREATE(frame)
	local monsterCardSlotFrame = frame;
	if monsterCardSlotFrame == nil then
		monsterCardSlotFrame = ui.GetFrame('monstercardslot')
	end

	CARD_SLOT_CREATE(monsterCardSlotFrame, 'ATK', 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	CARD_SLOT_CREATE(monsterCardSlotFrame, 'DEF', 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	CARD_SLOT_CREATE(monsterCardSlotFrame, 'UTIL', 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	CARD_SLOT_CREATE(monsterCardSlotFrame, 'STAT', 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	CARD_SLOT_CREATE(monsterCardSlotFrame, 'LEG', 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)

end;

function CARD_SLOT_CREATE(monsterCardSlotFrame, cardGroupName, slotIndex)
	local frame = monsterCardSlotFrame;
	if frame == nil then
		frame = ui.GetFrame('monstercardslot')
	end

	if cardGroupName == nil then
		return
	end

	local card_slotset = GET_CHILD_RECURSIVELY(frame, cardGroupName .. "card_slotset");
	local card_labelset = GET_CHILD_RECURSIVELY(frame, cardGroupName .. "card_labelset");

	if card_slotset ~= nil and card_labelset ~= nil then
		for i = 0, MONSTER_CARD_SLOT_COUNT_PER_TYPE - 1 do -- 슬롯은 왼쪽부터 순서대로 결정
			local slot_label = card_labelset:GetSlotByIndex(i);
			if slot_label == nil then
				return;
			end
			local icon_label = CreateIcon(slot_label)
			if cardGroupName == 'ATK' then
				icon_label : SetImage('red_cardslot1')
			elseif cardGroupName == 'DEF' then
				icon_label : SetImage('blue_cardslot1')
			elseif cardGroupName == 'UTIL' then
				icon_label : SetImage('purple_cardslot1')
			elseif cardGroupName == 'STAT' then
				icon_label : SetImage('green_cardslot1')
			elseif cardGroupName == 'LEG' then
				icon_label : SetImage('legendopen_cardslot')
			end
			local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex + i);			
			CARD_SLOT_SET(card_slotset, card_labelset, i, cardID, cardLv, cardExp);
			
		end;
	end;
end

function CARD_OPTION_OPEN(monsterCardSlotFrame)
	local frame = monsterCardSlotFrame;
	if frame == nil then
		frame = ui.GetFrame('monstercardslot')
	end

	local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");	
	if isOpen == nil then
		return;
	end
	
	local optionGbox = GET_CHILD_RECURSIVELY(frame, 'option_bg')
	local optionBtn = frame:GetChild('optionBtn');
	
	local bg = frame:GetChild('bg');
	local mainGbox = frame:GetChild('mainGbox');
	local pip = frame:GetChild('pip4');

	local option_H = optionGbox:GetHeight();
	local bg_X = bg:GetOriginalX();
	local bg_Y = bg:GetOriginalY();
	local bg_W = bg:GetWidth();
	local bg_H = bg:GetHeight();

	CARD_OPTION_CREATE(frame)
	bg:Resize(bg_X, bg_Y, bg_W, mainGbox:GetHeight() + pip:GetHeight() + option_H);
end

function CARD_OPTION_CLOSE(monsterCardSlotFrame)
	local frame = monsterCardSlotFrame;
	if frame == nil then
		frame = ui.GetFrame('monstercardslot')
	end

	local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
	if optionGbox ~= nil then
		optionGbox:RemoveAllChild();
	end

	local arrowText = frame:GetUserConfig("OPTION_BTN_TEXT_OPEN");
	local optionBtn = GET_CHILD_RECURSIVELY(frame, "optionBtn")
	optionBtn:SetText(arrowText)

	optionGbox : ShowWindow(0)
	frame:SetUserValue("CARD_OPTION_OPENED", 0);
end

function CARD_OPTION_CREATE(monsterCardSlotFrame)
	local frame = monsterCardSlotFrame;
	if frame == nil then
		frame = ui.GetFrame('monstercardslot')
	end

	local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
	if optionGbox ~= nil then
		optionGbox:RemoveAllChild();
	end
			
	local optionIndex = -1
	frame : SetUserValue("CARD_OPTION_INDEX", optionIndex);
	frame: SetUserValue("LABEL_HEIGHT", 0);
	local duplicateCount = 0;
	frame:SetUserValue("DUPLICATE_COUNT", 0)
	local currentHeight = 0;

	local clientMessage = ""
	
	local cardSlotCount_max = MAX_NORMAL_MONSTER_CARD_SLOT_COUNT
	local cardSlotCount_type = MONSTER_CARD_SLOT_COUNT_PER_TYPE
	local cardGroupCount = MAX_NORMAL_MONSTER_CARD_SLOT_COUNT / MONSTER_CARD_SLOT_COUNT_PER_TYPE

	local deleteLabelIndex = -1;

	local legendCardSlotset = GET_CHILD_RECURSIVELY
	--전설카드 껴있는지 확인하고 껴있으면 해당 옵션 여기다가 그려주자

	--숫자 12 빼줘야함
	local legendCardID, legendCardLv, legendCardExp = GETMYCARD_INFO(12)

	local prop = geItemTable.GetProp(legendCardID);
	if prop ~= nil then
		legendCardLv = prop:GetLevel(legendCardExp);
	end

	if legendCardID ~= nil and legendCardID ~= 0 then
		clientMessage = 'MonsterCardOptionGroupLEG'
		optionIndex = frame : GetUserIValue("CARD_OPTION_INDEX");
		CARD_OPTION_CREATE_BY_GROUP(frame, 12, clientMessage, legendCardID, legendCardLv, legendCardExp, optionIndex, labelIndex)

		optionIndex = frame : GetUserIValue("CARD_OPTION_INDEX");
		labelHeight = frame : GetUserIValue("LABEL_HEIGHT");
		currentHeight = frame : GetUserIValue("CURRENT_HEIGHT");
		local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_'..4, 0, 0);
		labelline: Move(0, currentHeight + labelHeight + labelline:GetHeight())
		frame : SetUserValue("LABEL_HEIGHT", labelHeight + labelline:GetHeight());
		frame : SetUserValue("CURRENT_HEIGHT", currentHeight);
		deleteLabelIndex = 4
	end

	for i = 0, 3 do
		frame:SetUserValue("DUPLICATE_COUNT", 0)
		if i == 0 then
			clientMessage = 'MonsterCardOptionGroupATK'
		elseif i == 1 then
			clientMessage = 'MonsterCardOptionGroupDEF'
		elseif i == 2 then
			clientMessage = 'MonsterCardOptionGroupUTIL'
		elseif i == 3 then
			clientMessage = 'MonsterCardOptionGroupSTAT'
		end
		
		local cardID, cardLv, cardExp = 0, 0, 0
		local isEquipThisTypeCard = -1

		frame:SetUserValue("IS_EQUIP_TYPE", isEquipThisTypeCard)
		frame:SetUserValue("DUPLICATE_OPTION_VALUE", 0)

		for j = 0, cardSlotCount_type - 1 do
			optionIndex = frame : GetUserIValue("CARD_OPTION_INDEX");
			labelHeight = frame : GetUserIValue("LABEL_HEIGHT");
			cardID, cardLv, cardExp = GETMYCARD_INFO(i * cardSlotCount_type + j)
			if cardID ~= 0 then
				CARD_OPTION_CREATE_BY_GROUP(frame, i * cardSlotCount_type + j, clientMessage, cardID, cardLv, cardExp, optionIndex, labelIndex)
			end
		end
		
		currentHeight = frame : GetUserIValue("CURRENT_HEIGHT");
		isEquipThisTypeCard = frame:GetUserIValue("IS_EQUIP_TYPE")
		if isEquipThisTypeCard ~= -1 then
			local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_'..i, 0, 0);
			labelline: Move(0, currentHeight + labelHeight + labelline:GetHeight())
			frame : SetUserValue("LABEL_HEIGHT", labelHeight + labelline:GetHeight());
			frame : SetUserValue("CURRENT_HEIGHT", currentHeight);
			deleteLabelIndex = i
		end
	end

	if deleteLabelIndex ~= -1 then
		local labelline = optionGbox:CreateOrGetControlSet('labelline', 'labelline_'..deleteLabelIndex, 0, 0);
		  labelline:ShowWindow(0)
	end

				
	local arrowText = frame : GetUserConfig("OPTION_BTN_TEXT_CLOSE");
	local optionBtn = GET_CHILD_RECURSIVELY(frame, "optionBtn")
	if optionBtn ~= nil then
		optionBtn:SetText(arrowText)
	end

	optionGbox : ShowWindow(1)
	frame : SetUserValue("CARD_OPTION_OPENED", 1);
end

function CARD_OPTION_CREATE_BY_GROUP(monsterCardSlotFrame, i, clientMessage, cardID, cardLv, cardExp, optionIndex, labelIndex)
	local frame = monsterCardSlotFrame;
	if frame == nil then
		frame = ui.GetFrame('monstercardslot')
	end
	
	local itemcls = GetClassByType("Item", cardID)
	if itemcls == nil then
		return
	end

	local strInfo = ""
	local optionValue = { }
	optionValue[1] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE1")
	optionValue[2] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE2")
	optionValue[3] = frame:GetUserIValue("DUPLICATE_OPTION_VALUE3")

	local optionValue_temp = { }
	optionValue_temp[1] = 0
	optionValue_temp[2] = 0
	optionValue_temp[3] = 0

	local itemClassName = itemcls.ClassName
	local cardcls = GetClass("EquipBossCard", itemClassName);
	if cardcls == nil then
		return;
	end

	local optionImage = string.format("%s", ClMsg(clientMessage));
	strInfo = strInfo .. optionImage

	local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
	local itemClsCtrl = nil
				
	local duplicateOptionIndex = -1
	local duplicateCount = frame:GetUserIValue("DUPLICATE_COUNT")
			
	local optionTextValue = cardcls.OptionTextValue
	local optionTextValueList = StringSplit(optionTextValue, "/")

	if optionTextValueList == nil then
		return
	end

	for j = 0, i - 1 do
		local cardID_temp, cardLv_temp = GETMYCARD_INFO(j)
		if cardID == cardID_temp then
			if duplicateOptionIndex == -1 then
				duplicateOptionIndex = j
				local preIndex = frame:GetUserIValue("PREINDEX")
				local cardID_flag = GETMYCARD_INFO(preIndex)
				if i - j == 2 and preIndex ~= j and cardID_flag ~= cardID_temp then
					duplicateCount = duplicateCount + 1
				end
			end

			for k = 1, #optionTextValueList do
				optionValue_temp[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv_temp
			end
		end
	end

	if optionGbox ~= nil then
		if duplicateOptionIndex == -1 then
			optionIndex = optionIndex + 1
			itemClsCtrl = optionGbox:CreateOrGetControlSet('eachoption_in_monstercard', 'OPTION_CSET_'..i, 0, 0);
			for k = 1, #optionTextValueList do
				optionValue_temp[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv
			end

			local optionText = cardcls.OptionText

			if CARD_PRESET_IS_EMPTY_CARD(i) == true and g_isChanged == false then
				optionText = "{#FF0000}"..optionText
			end

			optionText = string.format(optionText, optionValue_temp[1], optionValue_temp[2], optionValue_temp[3])

			strInfo = strInfo ..optionText
		else
			itemClsCtrl = optionGbox:CreateOrGetControlSet('eachoption_in_monstercard', 'OPTION_CSET_'..duplicateOptionIndex, 0, 0);

			for k = 1, #optionTextValueList do
				optionValue[k] = optionValue_temp[k] + optionTextValueList[k] * cardLv
			end

			local optionText = cardcls.OptionText

			if CARD_PRESET_IS_EMPTY_CARD(i) == true and g_isChanged == false then
				optionText = "{#FF0000}"..optionText
			end

			optionText = string.format(optionText, optionValue[1], optionValue[2], optionValue[3])

			strInfo = strInfo ..optionText
			frame : SetUserValue("DUPLICATE_OPTION_VALUE1", optionValue[1])
			frame : SetUserValue("DUPLICATE_OPTION_VALUE2", optionValue[2])
			frame : SetUserValue("DUPLICATE_OPTION_VALUE3", optionValue[3])
		end

		itemClsCtrl = AUTO_CAST(itemClsCtrl)
		local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
		local labelHeight = frame:GetUserIValue("LABEL_HEIGHT")
		itemClsCtrl : Move(0, (optionIndex - duplicateCount) * pos_y + labelHeight)
		local optionList = GET_CHILD_RECURSIVELY(itemClsCtrl, "option_name", "ui::CRichText");
		optionList:SetText(strInfo)
		frame : SetUserValue("CURRENT_HEIGHT", (optionIndex + 1) * pos_y);
	end				

	frame : SetUserValue("IS_EQUIP_TYPE", i)
	frame : SetUserValue("CARD_OPTION_INDEX", optionIndex);
	frame : SetUserValue("DUPLICATE_COUNT", duplicateCount)
	frame : SetUserValue("PREINDEX", i)
end

-- 카드를 카드 슬롯에 설정시키는 함수
function CARD_SLOT_SET(ctrlSet, slot_label_set, slotIndex, itemClsId, itemLv, itemExp)
	local cls = nil ;
	local cardID = tonumber(itemClsId);
	local cardLv = tonumber(itemLv);
	local cardExp = tonumber(itemExp);

	local cardCls = GetClassByType("Item", itemClsId)
	local cardGroupName = 'None';
	if cardCls == nil then
		return;
	end
	if cardCls.CardGroupName == nil or cardCls.CardGroupName == 'None' then
		return
	end
	cardGroupName = cardCls.CardGroupName

	local slot = ctrlSet:GetSlotByIndex(slotIndex);
	if slot == nil then
		return;
	end
			
	local slot_label = slot_label_set:GetSlotByIndex(slotIndex);
	if slot_label == nil then
		return;
	end

	if cardID > 0 then
		cls = GetClassByType("Item", cardID);
		if cls.GroupName ~= "Card" then		
			return;
		end;		
	else
		slot:ClearIcon();
		return;
	end;
	
	local icon = slot:GetIcon();	
	local icon_label = slot_label:GetIcon();
	if icon == nil or icon_label == nil then		
		-- icon이 없다는 건 아직 장착되지 않았다는 말.
		icon = CreateIcon(slot);
		icon_label = CreateIcon(slot_label)
	end;

	if CARD_PRESET_IS_EMPTY_CARD(CARD_SLOT_GET_SLOT_INDEX(cardGroupName, slotIndex) ) == true and g_isChanged == false then
		icon:SetColorTone('FFFF1010')
	else
		icon:SetColorTone('FFFFFFFF')
	end
	
	if cls ~= nil then		
		local imageName = cls.TooltipImage;
		if imageName ~= nil then			
			icon:SetImage(cls.TooltipImage);
			local icon_label = CreateIcon(slot_label)
			if cardGroupName == 'ATK' then
				icon_label : SetImage('red_cardslot')
			elseif cardGroupName == 'DEF' then
				icon_label : SetImage('blue_cardslot')
			elseif cardGroupName == 'UTIL' then
				icon_label : SetImage('purple_cardslot')
			elseif cardGroupName == 'STAT' then
				icon_label : SetImage('green_cardslot')
			elseif cardGroupName == 'LEG' then
				icon_label : SetImage('yellow_cardslot')
			end
			icon:Invalidate();
			icon_label:Invalidate();
		end;
	end;
	
	-- 카드 프리셋 임시 등록용 데이터
	icon:SetUserValue("CARD_TEMP_CLASSID", itemClsId)
	icon:SetUserValue("CARD_TEMP_LEVEL", itemLv)
	icon:SetUserValue("CARD_TEMP_EXP", itemExp)

	-- 툴팁 생성 (카드 아이템은 IES가 사라지기 때문에 똑같이 생긴 툴팁을 따로 만들어서 적용)
	slot:SetEventScript(ui.MOUSEMOVE, "EQUIP_CARDSLOT_INFO_TOOLTIP_OPEN");
	slot:SetEventScriptArgNumber(ui.MOUSEMOVE, slotIndex);
	slot:SetEventScript(ui.LOST_FOCUS, "EQUIP_CARDSLOT_INFO_TOOLTIP_CLOSE");
end;

-- 인벤토리의 카드 슬롯 오른쪽 클릭시 정보창오픈 과정시작 스크립트
function CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argStr, argNum)
	local icon = slot:GetIcon();		
	if icon == nil then		
		return;		
	end;

	local parentSlotSet = slot:GetParent()
	if parentSlotSet == nil then
		return
	end
		
	local groupName = string.gsub(parentSlotSet:GetName(), 'card_slotset', '');
	local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupName, slot:GetSlotIndex()) 

	if groupName == 'LEG' then
	EQUIP_CARDSLOT_INFO_OPEN(slotIndex);
	else
		CARD_PRESET_COLOR_INIT()
		g_isChanged = true
		_CARD_SLOT_REMOVE(slotIndex + 1, groupName)
	end
end

-- 카드 슬롯 정보창 열기
function EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
	local other_frame = ui.GetFrame('equip_cardslot_info_goddess')
	other_frame:ShowWindow(0)

	local frame = ui.GetFrame('equip_cardslot_info');
	
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0);	
	end
	
	local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex);	
	if cardID == 0 then
		return;
	end

	local prop = geItemTable.GetProp(cardID);
	if prop ~= nil then
		cardLv = prop:GetLevel(cardExp);
	end
	
	-- 카드 슬롯 제거하기 위함
	frame:SetUserValue("REMOVE_CARD_SLOTINDEX", slotIndex);

	local inven = ui.GetFrame("inventory");
	local cls = GetClassByType("Item", cardID);

	-- 안내메세지에 이름 적용
	local infoMsg = GET_CHILD(frame, "infoMsg");
	infoMsg:SetTextByKey("Name", cls.Name);

	-- 카드 이미지 적용
	local card_img = GET_CHILD(frame, "card_img");
	card_img:SetImage(TryGetProp(cls, "TooltipImage"));

	local multiValue = 64;	-- 꽉 찬 카드 이미지를 하고 싶다면 90 으로. (단, 카드레벨 하락 정보가 잘 안보일 수 있음.)
	local star_bg = GET_CHILD(frame, "star_bg");
	local cardStar_Before = GET_CHILD(star_bg, "cardStar_Before");
	local imgSize = frame:GetUserConfig('starSize');
	if cardLv <= 1 then	
		multiValue = 90;
		cardStar_Before:SetVisible(0);
	else
		cardStar_Before:SetTextByKey("value", GET_STAR_TXT(imgSize, cardLv, cls));
		cardStar_Before:SetVisible(1);
	end;

	-- 카드 크기 변환.
--	card_img:Resize(3 * multiValue, 4 * multiValue);

	-- 제거되는 효과 표시하는 곳. 
	local removedEffect =  string.format("%s{/}", cls.Desc);	
	if cls.Desc == "None" then
		removedEffect = "{/}";
	end

	local needSilverText = GET_CHILD_RECURSIVELY(frame, "button_3")
	local needSilver = tonumber(CALC_NEED_SILVER(cls, cardLv))
	needSilverText:SetTextByKey("needSilver", GET_COMMAED_STRING(needSilver))
	local bg = GET_CHILD(frame, "bg");
	local effect_info = GET_CHILD(bg, "effect_info");
	effect_info:SetTextByKey("RemovedEffect", removedEffect);
	
	-- 정보창 위치를 인벤 옆으로 붙힘.
	frame:SetOffset(inven:GetX() - frame:GetWidth(), frame:GetY());

	frame:ShowWindow(1);	
end

function CALC_NEED_SILVER(cls, cardLv)
	if cls == nil then
		return
	end

	if cardLv == nil or cardLv <= 0 then 
		return
	end

	local cardGroupName = cls.CardGroupName
	local consumeSilver = 0;
	if cardGroupName == 'LEG' then
		--1000000
		consumeSilver = cardLv * CONSUME_SILVER_WHEN_UNEQUIP_LEGEND_CARD
	else
		--20000
		consumeSilver = cardLv * CONSUME_SILVER_WHEN_UNEQUIP_MONSTER_CARD
	end

	return consumeSilver
end

-- 카드 슬롯 정보창 닫기
function EQUIP_CARDSLOT_BTN_CANCLE()
	local frame = ui.GetFrame('equip_cardslot_info');
	frame:ShowWindow(0);
end

-- 몬스터 카드를 인벤토리의 카드 슬롯에 드레그드롭으로 장착하려 할 경우.
function CARD_SLOT_DROP(frame, slot, argStr, argNum)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	local toFrame = frame:GetTopParentFrame();
	
	if toFrame:GetName() == 'monstercardslot' then
		local iconInfo = liftIcon:GetInfo();

		if iconInfo == nil then
			return
		end

		local item = session.GetInvItem(iconInfo.ext);		
		if nil == item then
			return;
		end
		local cardObj = GetClassByType("Item", item.type)
		if cardObj == nil then
			return
		end

		local parentSlotSet = slot:GetParent()
		if parentSlotSet == nil then
			return
		end
		
		if cardObj.CardGroupName == "REINFORCE_CARD" then
			ui.SysMsg(ClMsg("LegendReinforceCard_Not_Equip"));
			return
		end

		local cardGroupName_slotset = cardObj.CardGroupName .. 'card_slotset'
		if parentSlotSet:GetName() ~= cardGroupName_slotset then
			--같은 card group 에 착용해야합니다 메세지 띄워줘야해
			ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
			return
		end

		CARD_SLOT_EQUIP(slot, item, cardObj.CardGroupName);
	end
end;

-- 몬스터 카드를 인벤토리의 카드 슬롯에 장착 요청하기 전에 메세지 박스로 한번 더 확인
function CARD_SLOT_EQUIP(slot, item, groupNameStr)
	CARD_PRESET_COLOR_INIT()
	g_isChanged = true
	local obj = GetIES(item:GetObject());
	if obj.GroupName == "Card" then			
		local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupNameStr, slot:GetSlotIndex());
		local cardInfo = equipcard.GetCardInfo(slotIndex + 1);


		if groupNameStr == 'LEG' then
		if cardInfo ~= nil then
			ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
			return;
		end

			local pcEtc = GetMyEtcObject();
			if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
				ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
				return
			end	
			
		if item.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		local itemGuid = item:GetIESID();
		local invFrame = ui.GetFrame("inventory");	
		invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
		invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);	
		local textmsg = string.format("[ %s ]{nl}%s", obj.Name, ScpArgMsg("AreYouSureEquipCard"));	
		ui.MsgBox_NonNested(textmsg, invFrame:GetName(), "REQUEST_EQUIP_CARD_TX", "REQUEST_EQUIP_CARD_CANCLE");		
		return 1;
		end

		local cardClsID = TryGetProp(obj, "ClassID", 0)
		local cardLevel = TryGetProp(obj, "Level", 1)
		local cardExp = TryGetProp(obj, "ItemExp", 0)

		_CARD_SLOT_EQUIP(slotIndex + 1, cardClsID, cardLevel, cardExp)

	end;
	return 0;
end

-- 몬스터 카드 장착 요청
function REQUEST_EQUIP_CARD_TX()
	local invFrame = ui.GetFrame("inventory");	
	local itemGuid = invFrame:GetUserValue("EQUIP_CARD_GUID");
	local slotIndex = invFrame:GetUserIValue("EQUIP_CARD_SLOTINDEX");
	local argStr = string.format("%d#%s", slotIndex, itemGuid);
	pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);
	invFrame:SetUserValue("EQUIP_CARD_GUID", "");
	invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "");	
end

-- 몬스터 카드 장착 요청 사전취소
function REQUEST_EQUIP_CARD_CANCLE()
	local invFrame = ui.GetFrame("inventory");	
	invFrame:SetUserValue("EQUIP_CARD_GUID", "");
	invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "");	
end

function CARD_SLOT_GET_GROUP_SLOT_INDEX(groupNameStr, slotIndex)
	local groupSlotIndex = slotIndex
	if groupNameStr == 'ATK' then
		groupSlotIndex = groupSlotIndex - (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'DEF' then
		groupSlotIndex = groupSlotIndex - (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'UTIL' then
		groupSlotIndex = groupSlotIndex - (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'STAT' then
		groupSlotIndex = groupSlotIndex - (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'LEG' then
		groupSlotIndex = groupSlotIndex - (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	-- leg 카드는 slotindex = 12, 13번째 슬롯
	end
	return groupSlotIndex
end

function CARD_SLOT_GET_SLOT_INDEX(groupNameStr, groupSlotIndex)
	local slotIndex = groupSlotIndex;
	if groupNameStr == 'ATK' then
		slotIndex = slotIndex + (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'DEF' then
		slotIndex = slotIndex + (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'UTIL' then
		slotIndex = slotIndex + (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'STAT' then
		slotIndex = slotIndex + (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
	elseif groupNameStr == 'LEG' then
		slotIndex = 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
		-- leg 카드는 slotindex = 12, 13번째 슬롯
	end
	return slotIndex;
end

function CARD_SLOT_GET_GROUP_NAME(slotIndex)
	local groupNameStr = "None"

	if slotIndex < (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE) then
		groupNameStr = 'ATK'
	elseif slotIndex < (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE) then
		groupNameStr = 'DEF'
	elseif slotIndex < (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE) then
		groupNameStr = 'UTIL'
	elseif slotIndex < (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE) then
		groupNameStr = 'STAT'
	else
		groupNameStr = 'LEG'
	end
	return groupNameStr
end

-- 몬스터 카드를 인벤토리의 카드 슬롯에 장착 동작
function _CARD_SLOT_EQUIP(slotIndex, itemClsId, itemLv, itemExp)
	local moncardFrame = ui.GetFrame("monstercardslot");
	local invFrame    = ui.GetFrame("inventory");	
	
	if moncardFrame:IsVisible() == 0 then
		return;
	end;

	if invFrame:IsVisible() == 0 then
		return;
	end;

	local cardObj = GetClassByType("Item", itemClsId);
	if cardObj == nil then
		return;
	end

	local groupNameStr = cardObj.CardGroupName
	local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(groupNameStr, slotIndex)

	local moncardGbox = GET_CHILD_RECURSIVELY(moncardFrame, groupNameStr .. 'cardGbox');
	local card_slotset = GET_CHILD(moncardGbox, groupNameStr .. "card_slotset");

	local card_labelset = GET_CHILD(moncardGbox, groupNameStr .. "card_labelset");
	if card_slotset ~= nil and card_labelset then
		CARD_SLOT_SET(card_slotset, card_labelset, groupSlotIndex -1, itemClsId, itemLv, itemExp);
	end;
	invFrame:SetUserValue("EQUIP_CARD_GUID", "");
	invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", "");	
	
	CARD_OPTION_CREATE(moncardFrame)
end;

-- 카드 슬롯의 카드 제거 요청
-- function EQUIP_CARDSLOT_BTN_REMOVE(frame, ctrl)
-- 	-- local inven = ui.GetFrame("monstercardslot");
-- 	-- local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"));

-- 	-- argStr = argStr .. " 0" -- 0: 카드 레벨 떨어지면서 제거
-- 	-- pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);

-- 	local yesScp = string.format("_EQUIP_CARDSLOT_BTN_REMOVE");
-- 	local clmsg = ScpArgMsg("ReallyRemoveCardWithoutCost");

-- 	WARNINGMSGBOX_FRAME_OPEN_WITH_CHECK(clmsg, yesScp, "None");
-- end;

function _EQUIP_CARDSLOT_BTN_REMOVE()
	local frame = ui.GetFrame("equip_cardslot_info")
	local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"))

	argStr = argStr .. " 0"
	
	pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
end

-- 인벤토리의 카드 슬롯 제거 동작
function _CARD_SLOT_REMOVE(slotIndex, cardGroupName)
	local frame = ui.GetFrame('monstercardslot');
	local groupNameStr = cardGroupName
	local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(cardGroupName, slotIndex)

	local gBox = GET_CHILD_RECURSIVELY(frame, groupNameStr .. 'cardGbox');
	local card_slotset = GET_CHILD(gBox, groupNameStr .. "card_slotset");
	local card_labelset = GET_CHILD(gBox, groupNameStr .. "card_labelset");

	if card_slotset ~= nil and card_labelset ~= nil then
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex - 1);
		if slot ~= nil then
			slot:ClearIcon();
		end;

		local slot_label = card_labelset:GetSlotByIndex(groupSlotIndex - 1);
		if slot_label ~= nil then
			local icon_label = CreateIcon(slot_label)
			if cardGroupName == 'ATK' then
				icon_label : SetImage('red_cardslot1')
			elseif cardGroupName == 'DEF' then
				icon_label : SetImage('blue_cardslot1')
			elseif cardGroupName == 'UTIL' then
				icon_label : SetImage('purple_cardslot1')
			elseif cardGroupName == 'STAT' then
				icon_label : SetImage('green_cardslot1')
			elseif cardGroupName == 'LEG' then
				icon_label : SetImage('legendopen_cardslot')
			end
		end;
	end;

	local cardFrame = ui.GetFrame('equip_cardslot_info');
	cardFrame:ShowWindow(0);
	local goddess_cardFrame = ui.GetFrame('equip_cardslot_info_goddess');
	goddess_cardFrame:ShowWindow(0);

	CARD_OPTION_CREATE(frame)
end;

-- 카드 정보 얻는 함수
function GETMYCARD_INFO(slotIndex)
	local frame = ui.GetFrame("monstercardslot")
	local page = GET_CHILD_RECURSIVELY(frame,"preset_list"):GetSelItemKey()
	local selectedPreset = TryGetProp(GetMyEtcObject(), "SelectedPreset", 0)
	local info = equipcard.GetCardInfo(slotIndex + 1);

	if info ~= nil and g_isChanged == false then
		if page == "" or selectedPreset == tonumber(page) or slotIndex > 11 then
			return info:GetCardID(), info.cardLv, info.exp;
		end
	end
	
		local groupNameStr = CARD_SLOT_GET_GROUP_NAME(slotIndex)
		local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(groupNameStr, slotIndex)

		local moncardGbox = GET_CHILD_RECURSIVELY(frame, groupNameStr .. 'cardGbox');
		local card_slotset = GET_CHILD(moncardGbox, groupNameStr .. "card_slotset");
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex);
		if slot == nil then
			return 0, 0, 0;
		end
		
		local icon = slot:GetIcon();	
		if icon == nil then
		return 0, 0, 0;
	end

		local cardClsID = icon:GetUserValue("CARD_TEMP_CLASSID");
		local cardLv = icon:GetUserValue("CARD_TEMP_LEVEL");
		local cardExp = icon:GetUserValue("CARD_TEMP_EXP");

		if cardClsID == "None" then
			return 0, 0, 0;
		else
			local prop = geItemTable.GetProp(cardClsID);
			if prop ~= nil then
				cardLv = prop:GetLevel(cardExp);
			end
			return cardClsID, cardLv, cardExp;
		end
end

-- 단계 보호하고, 카드 슬롯의 카드 제거
function EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT(frame, ctrl)
	local inven = ui.GetFrame("monstercardslot");
	local argStr = string.format("%d", frame:GetUserIValue("REMOVE_CARD_SLOTINDEX"));

	argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
	pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr);
end;


function CARD_PRESET_CHANGE_NAME(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local preset_name = droplist:GetSelItemCaption()
    local newframe = ui.GetFrame('inputstring')
    newframe:SetUserValue('InputType', 'InputNameForChange')
	INPUT_STRING_BOX(ClMsg('ChangeAncientDefenseDeckTabName'), 'CARD_PRESET_CHANGE_NAME_EXEC', preset_name, 0, 16)
end

function CARD_PRESET_CHANGE_NAME_EXEC(input_frame, ctrl)
	if ctrl:GetName() == 'inputstr' then
        input_frame = ctrl
	end

    local new_name = GET_INPUT_STRING_TXT(input_frame)
	
	local frame = ui.GetFrame('monstercardslot')
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local preset_name = droplist:GetSelItemCaption()
	if new_name == preset_name then
		ui.SysMsg(ClMsg('AlreadyorImpossibleName'))
		return
	end

	local name_str = TRIM_STRING_WITH_SPACING(new_name)
	if name_str == '' then
		ui.SysMsg(ClMsg('InvalidStringOrUnderMinLen'))
		return
	end

	SetCardPreSetTitle(page, name_str)

	_DISABLE_CARD_PRESET_CHANGE_NAME_BTN()

	input_frame:ShowWindow(0)
end

function CARD_PRESET_GET_CARD_EXP_LIST(frame)
	local frame = frame:GetTopParentFrame()
	local cardList = {}
	local expList = {}
	for i = 0, 11 do
		local groupName = CARD_SLOT_GET_GROUP_NAME(i)
		local moncardGbox = GET_CHILD_RECURSIVELY(frame, groupName .. 'cardGbox');
		local card_slotset = GET_CHILD(moncardGbox, groupName .. "card_slotset");
		local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(groupName, i)
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex);
		local icon = slot:GetIcon();	
		if icon ~= nil then
			local cardClsID = icon:GetUserIValue("CARD_TEMP_CLASSID");
			local cardExp = icon:GetUserIValue("CARD_TEMP_EXP");
			table.insert(cardList, cardClsID);
			table.insert(expList, cardExp);
		else
			table.insert(cardList, 0);
			table.insert(expList, 0);
		end
	end

	return cardList, expList
end

function CARD_PRESET_COLOR_INIT()
	if g_isChanged == true then
		return
	end
	local frame = ui.GetFrame("monstercardslot")

	for i = 0, 11 do
		local groupName = CARD_SLOT_GET_GROUP_NAME(i)
		local moncardGbox = GET_CHILD_RECURSIVELY(frame, groupName .. 'cardGbox');
		local card_slotset = GET_CHILD(moncardGbox, groupName .. "card_slotset");
		local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(groupName, i)
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex);
		local icon = slot:GetIcon();	
		if icon ~= nil then
			icon:SetColorTone('FFFFFFFF');
		end
	end

end

function CARD_PRESET_LOAD(page, title, isEmpty)
	local frame = ui.GetFrame("monstercardslot")
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")

	if title == "" then
		title =  ScpArgMsg('CardPresetNumber{index}', 'index', page + 1)
	end
	
	local etcObj = GetMyEtcObject()
	local selectedPreset = TryGetProp(etcObj, "SelectedPreset", 0)
	if selectedPreset == page then
		title = "{#FFFF00}"..title
		droplist:SetUserValue("APPLIED_PRESET_KEY", page)
		droplist:SetUserValue("APPLIED_PRESET_NAME", title)
	droplist:SelectItemByKey(selectedPreset)
		if needApply == false then
			MONSTERCARDSLOT_FRAME_INIT()
			CARD_PRESET_RELOAD_AFTER_APPLY()
			if CARD_PRESET_CHECK_PRESET_CHANGED(frame, page) == true then
				local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(frame)
				SetCardPreset(page, cardList, expList)
				_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
			end
		end
	end

	local changed = droplist:SetItemTextByKey(page, title)
	if changed == false then
		droplist:AddItem(page, title)
	end
	
	if needApply == true then
		pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
	else
		_CHECK_CARD_PRESET_APPLY_SAVE_BTN()
	end
end 

function CARD_PRESET_APPLIED_PRESET_TEXT(frame)
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local prevKey = droplist:GetUserValue("APPLIED_PRESET_KEY")
	local prevText = droplist:GetUserValue("APPLIED_PRESET_NAME")
	local curKey = droplist:GetSelItemKey();
	local curText = "{#FFFF00}"..droplist:GetSelItemCaption();
	if prevKey ~= curKey then
		prevText = string.gsub(prevText, "{#FFFF00}", "");
		droplist:SetItemTextByKey(prevKey, prevText)
		droplist:SetItemTextByKey(curKey, curText)
		droplist:SetUserValue("APPLIED_PRESET_KEY", curKey)
		droplist:SetUserValue("APPLIED_PRESET_NAME", curText)
	end
end

function CARD_PRESET_APPLY_COMPLETE(page)
	local frame = ui.GetFrame("monstercardslot")
	needApply = false;
	CARD_PRESET_APPLIED_PRESET_TEXT(frame)
	_CHECK_CARD_PRESET_APPLY_SAVE_BTN()
	g_isChanged = false;
end

function CARD_PRESET_RELOAD_AFTER_APPLY()
	local frame = ui.GetFrame("monstercardslot")
	local etcObj = GetMyEtcObject()
	local page = TryGetProp(etcObj, "SelectedPreset", 0)
	CARD_PRESET_SHOW_PRESET(page)
end

function CARD_PRESET_SELECT_PRESET(parent, self)
	CARD_PRESET_CLEAR_SLOT(parent)
	local page = tonumber(self:GetSelItemKey())
	CARD_PRESET_SHOW_PRESET(page)
end

function CARD_PRESET_SHOW_PRESET(page)
	g_isChanged = false
	local cardList = equipcard.GetCardPresetInfo(page)
	if cardList == nil then
		return;
	end
	local count = cardList:Count()

	for i = 0, count - 1 do
		local info = cardList:Element(i)
		local class_id = info.class_id
		local page = info.page
		local slot = info.slot_idx
		local exp = info.exp
		_CARD_SLOT_EQUIP(slot, class_id, 1, exp)
	end
end

function CARD_PRESET_IS_EMPTY_CARD(slot_idx)
	local frame = ui.GetFrame("monstercardslot")
	local droplist = GET_CHILD_RECURSIVELY(frame,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local etcObj = GetMyEtcObject()
	local selectedPreset = TryGetProp(etcObj, "SelectedPreset", 0)

	if page == selectedPreset then 
		local info = equipcard.GetCardInfo(slot_idx + 1);
		local cardList = equipcard.GetCardPresetInfo(page)
		if cardList == nil then
			return false
		end
		
		local count = cardList:Count()
		for i = 0, count - 1 do
			local card = cardList:Element(i)
			local slot = card.slot_idx - 1
			local class_id = card.class_id

			if slot == slot_idx and info == nil then
				return true
			end
		end
	end
	return false;
end

function CARD_PRESET_INVALID_CARD(slotIndex)
	local frame = ui.GetFrame('monstercardslot');
	local groupNameStr = CARD_SLOT_GET_GROUP_NAME(slotIndex - 1)
	local groupSlotIndex = CARD_SLOT_GET_GROUP_SLOT_INDEX(cardGroupName, slotIndex)
	local gBox = GET_CHILD_RECURSIVELY(frame, groupNameStr .. 'cardGbox');
	local card_slotset = GET_CHILD(gBox, groupNameStr .. "card_slotset");

	if card_slotset ~= nil then
		local slot = card_slotset:GetSlotByIndex(groupSlotIndex - 1);
		if slot ~= nil then
			local icon = slot:GetIcon();	
			if icon ~= nil then		
				icon:SetColorTone('FFFF1010');
			end
		end
	end
end

function CARD_PRESET_CHECK_PRESET_CHANGED(frame, page)
	local presetList = equipcard.GetCardPresetInfo(page)
	if presetList == nil then
		return;
	end
	local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(frame)
	local count = presetList:Count()
	for i = 0, count - 1 do
		local info = presetList:Element(i)
		local cardClsID = cardList[info.slot_idx]
		local cardExp = expList[info.slot_idx]
		if cardClsID ~= info.class_id or cardExp ~= info.exp then
			return true
		end
	end

	local insertCnt = 0
	for i = 1, #cardList do
		if cardList[i] ~= 0 then
			insertCnt = insertCnt + 1
		end
	end

	if insertCnt ~= count then
		return true
	end

	return false
end

function CARD_PRESET_SAVE_PRESET(parent, self)
	local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
	local droplist = GET_CHILD_RECURSIVELY(parent,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())

	if g_isChanged == true then
		SetCardPreset(page, cardList, expList)
		_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	else
		ui.SysMsg(ClMsg("DuplicateCardPreSetInfo"));
	end
end

function CARD_PRESET_APPLY_PRESET(parent, self)
	local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
	local droplist = GET_CHILD_RECURSIVELY(parent,"preset_list")
	local page = tonumber(droplist:GetSelItemKey())
	local etcObj = GetMyEtcObject()
	local selectedPreset = TryGetProp(etcObj, "SelectedPreset", 0)

	if g_isChanged == true then
		needApply = true
		SetCardPreset(page, cardList, expList)
		_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	else
		pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
		_DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	end
end

function CARD_PRESET_CLEAR_SLOT(frame)
	local frame = frame:GetTopParentFrame()
	for i = 0, 11 do
		local groupName = CARD_SLOT_GET_GROUP_NAME(i)
		_CARD_SLOT_REMOVE(i+1, groupName)
	end
end

function _CHECK_CARD_PRESET_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('monstercardslot')
	local btn = GET_CHILD_RECURSIVELY(frame, 'nameBtn')
	btn:SetEnable(1)
end

function _DISABLE_CARD_PRESET_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('monstercardslot')
	local btn = GET_CHILD_RECURSIVELY(frame, 'nameBtn')
	if btn ~= nil then
		ReserveScript('_CHECK_CARD_PRESET_CHANGE_NAME_BTN()', 1)
    	btn:SetEnable(0)
	end
end

function _CHECK_CARD_PRESET_APPLY_SAVE_BTN()
	local frame = ui.GetFrame('monstercardslot')
	local btn = GET_CHILD_RECURSIVELY(frame, 'applyBtn')
	btn:SetEnable(1)
end

function _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
	local frame = ui.GetFrame('monstercardslot')
	local btn = GET_CHILD_RECURSIVELY(frame, 'applyBtn')
	btn:SetEnable(0)
end