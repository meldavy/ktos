-- rankreset


function RANKRESET_ON_INIT(addon, frame)
	addon:RegisterOpenOnlyMsg('EQUIP_ITEM_LIST_GET', 'RANKRESET_PC_EQUIP_STATE');
	addon:RegisterOpenOnlyMsg('RESET_ABILITY_UP', 'RANKRESET_PC_ABILITY_STATE');
	addon:RegisterOpenOnlyMsg('AUTOSELLER_UPDATE', 'RANKRESET_PC_AUTOSELLER_STATE'); 
end

function RANKRESET_ITEM_USE(invItem)
	if invItem.isLockState then 
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if true == IS_TEMP_LOCK(invframe, invItem) then
		return false;
	end

	local obj = GetIES(invItem:GetObject());
	if obj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return;
	end

	local frame = ui.GetFrame("rankreset");
	frame:ShowWindow(1)
	frame:SetUserValue("itemIES", invItem:GetIESID());

	RANKRESET_CHECK_PLAYER_STATE(frame);
end

function RANKRESET_CHECK_PLAYER_STATE(frame)

	RANKRESET_PC_EQUIP_STATE(frame);
	RANKRESET_PC_ABILITY_STATE(frame);
	RANKRESET_PC_WITH_COMMPANION(frame);
	RANKRESET_PC_LOCATE(frame);
	RANKRESET_PC_AUTOSELLER_STATE(frame);
	RANKRESET_PC_TIMEACTION_STATE(frame);
	RANKRESET_PC_GUILDMASTER_STATE(frame);
end

function RANKRESET_PC_TIMEACTION_STATE(frame)
	local timeActionFrame = ui.GetFrame("timeaction");
	local actor = GetMyActor();	
	local nonstate = true;
	if 1 == actor:HasCmd("TIME_ACTION_ANIM_CMD") or timeActionFrame:IsVisible() == 1 then
		nonstate = false;
	end

	local invframe = ui.GetFrame("inventory");
	if invframe:GetUserValue('ITEM_GUID_IN_MORU') ~= 'None'
		or 'None' ~= invframe:GetUserValue("ITEM_GUID_IN_AWAKEN") then
		nonstate = false;
	end

	local timeaction = GET_CHILD(frame, 'timeaction_check', "ui::CCheckBox");
	if nonstate == true then
		timeaction:SetCheck(1);
	else
		timeaction:SetCheck(0);
	end
end

function RANKRESET_PC_GUILDMASTER_STATE(frame)
	local isLeader = AM_I_LEADER(PARTY_GUILD);
	if isLeader == 1 then
		local templer = session.GetJobGrade(1016);
		templer = tonumber(templer);
		if templer == 0 then
			isLeader = 0;
		else
			isLeader = 1;
		end
	end
	local master_check = GET_CHILD(frame, 'master_check', "ui::CCheckBox");
	if 0 == isLeader then
		master_check:SetCheck(1);
	else
		master_check:SetCheck(0);
	end
end

function RANKRESET_PC_AUTOSELLER_STATE(frame)
	local nonstate = true;
	for i = 0, AUTO_SELL_COUNT-1 do
	-- ���ϳ��� true��
		if session.autoSeller.GetMyAutoSellerShopState(i) == true then
			nonstate = false;
			break;
		end
	end

	local shop_check = GET_CHILD(frame, 'shop_check', "ui::CCheckBox");
	if nonstate == true then
		shop_check:SetCheck(1);
	else
		shop_check:SetCheck(0);
	end
end

function RANKRESET_PC_LOCATE(frame)
	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);
	local home_check = GET_CHILD(frame, 'home_check', "ui::CCheckBox");
    if mapCls == nil or mapCls.MapType ~= "City" then
        home_check:SetCheck(0);
	else
		home_check:SetCheck(1);
    end
        
end

function RANKRESET_PC_WITH_COMMPANION(frame)
	local summonedPet = GET_SUMMONED_PET();
	local com_check = GET_CHILD(frame, 'com_check', "ui::CCheckBox");
	if summonedPet == nil then
		com_check:SetCheck(1);
	else
		com_check:SetCheck(0);
	end
end

function RANKRESET_PC_EQUIP_STATE(frame)
	local equipList = session.GetEquipItemList();
	local unEquip = false;
	for i = 0, equipList:Count() - 1 do
		local equipItem = equipList:Element(i);
		local spotName = item.GetEquipSpotName(equipItem.equipSpot);	
		if  equipItem.type  ~=  item.GetNoneItem(equipItem.equipSpot)  then
			unEquip = true;
			break;
		end
	end

	local armor_check = GET_CHILD(frame, 'armor_check', "ui::CCheckBox");
	if false == unEquip then
		armor_check:SetCheck(1);
	else
		armor_check:SetCheck(0);
	end
end

function RANKRESET_PC_ABILITY_STATE(frame)
	local pc = GetMyPCObject();
	local runAbil = false;
	for i = 0, RUN_ABIL_MAX_COUNT do
		local prop = "None";
		if 0 == i then
			prop = "LearnAbilityID";
		else
			prop = "LearnAbilityID_" ..i;
		end
		if pc[prop] ~= nil and pc[prop] > 0 then
			runAbil = true;
			break;
		end
	end

	local ability_check = GET_CHILD(frame, 'ability_check', "ui::CCheckBox");
	if false == runAbil then
		ability_check:SetCheck(1);
	else
		ability_check:SetCheck(0);
	end
end

function RANKRESET_ITEM_USE_BUTTON_CLICK(frame, ctrl)

	local gradeRank = session.GetPcTotalJobGrade();
	if gradeRank <= 1 then
		ui.SysMsg(ScpArgMsg("CantUseRankRest1Rank"));
	    return;
	end
	
    local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);
    if mapCls == nil or mapCls.MapType ~= "City" then
        ui.SysMsg(ClMsg("AllowedInTown"));
        return;
    end

	local itemIES = frame:GetUserValue("itemIES");
	packet.RankResetItemUse(itemIES);
end

function RANKRESET_CANCEL_BUTTON_CLICK(frame, ctrl)
	frame = frame:GetTopParentFrame();
	frame:SetUserValue("itemIES", 'None');
	frame:ShowWindow(0);
end