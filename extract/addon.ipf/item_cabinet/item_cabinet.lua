-- item_cabinet.lua 
g_selectedItem = {}
g_materialItem = {}

function ITEM_CABINET_ON_INIT(addon, frame)
	addon:RegisterMsg('UPDATE_ITEM_CABINET_LIST', 'ITEM_CABINET_CREATE_LIST');
	addon:RegisterMsg('ITEM_CABINET_SUCCESS_ENCHANT', 'ITEM_CABINET_SUCCESS_GODDESS_ENCHANT');

end

function ITEM_CABINET_OPEN(frame)
	GET_CHILD_RECURSIVELY(frame, "cabinet_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "upgrade_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "equipment_tab"):SelectTab(0);
	ITEM_CABINET_CREATE_LIST(frame);
	help.RequestAddHelp('TUTO_SHARD_CABINET_1')
end

function ITEM_CABINET_CLOSE(frame)
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	edit:SetText("");
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function ITEM_CABINET_CHANGE_TAB(frame)
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	edit:SetText("");
	ITEM_CABINET_CREATE_LIST(frame);
end

function ITEM_CABINET_CREATE_LIST(frame)
	frame = frame:GetTopParentFrame();
	ITEM_CABINET_CLOSE_SUCCESS(frame)
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 0)
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	local category = ITEM_CABINET_GET_CATEGORY(frame);
	local itemgbox = GET_CHILD_RECURSIVELY(frame,"itemgbox");
	local itemList, itemListCnt = GetClassList("cabinet_"..string.lower(category));
	local group = "None";
	local equipTab = GET_CHILD_RECURSIVELY(frame, "equipment_tab");
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	local cap = edit:GetText();
	if category == "Weapon" or category == "Armor" then
		equipTab:ShowWindow(1);
		local equipTabIndex = equipTab:GetSelectItemIndex();
		local equipTxt = GET_CHILD_RECURSIVELY(frame, "equipmenttxt");
		if equipTabIndex == 0 then
			if category == "Weapon" then
				group = "VIBORA";
				equipTab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("Vibora"),false)
			elseif category == "Armor" then
				group = "GODDESS_EVIL";
				equipTab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("GoddessEvil"),false)
			end
		end
	else
		equipTab:ShowWindow(0);
	end
	
	local unavailabeList = {};
	local ctrlIndex = 0;
	local aObj = GetMyAccountObj();
	itemgbox:RemoveAllChild();
	for i = 0, itemListCnt - 1 do
		local listCls = GetClassByIndexFromList(itemList, i);
		local available = TryGetProp(aObj, listCls.AccountProperty, 0);				
		local itemGroup = TryGetProp(listCls,"TabGroup","None");		

		if group == itemGroup or (group == "None" and itemGroup == "None") then
			if ITEM_CABINET_MATCH_NAME(listCls, cap) then
				if available == 1 then
					local itemTabCtrl = itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex, 0, ctrlIndex * 90);					
					ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl);
					GET_CHILD(itemTabCtrl, 'shadow'):ShowWindow(0);
					ctrlIndex = ctrlIndex + 1;
				else
					table.insert(unavailabeList, listCls);
				end
			end
		end
	end
	for i = 1, #unavailabeList do		
		local listCls = unavailabeList[i];
		local itemTabCtrl = itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex, 0, ctrlIndex * 90);
		GET_CHILD(itemTabCtrl, 'shadow'):ShowWindow(1);
		ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl);
		ctrlIndex = ctrlIndex + 1;
	end
end

function ITEM_CABINET_SHOW_UPGRADE_UI(frame, isShow)
	local frame = frame:GetTopParentFrame();
	GET_CHILD_RECURSIVELY(frame,"upgrade_tab"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(isShow);
	
	if isShow == 1 then
		ITEM_CABINET_UPGRADE_TAB(frame);
	else
		frame:SetUserValue("SELECTED_TAB", "None");
		INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	end
end

function ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl)
	local itemSlot = GET_CHILD(itemTabCtrl, "itemIcon");
	local itemText = GET_CHILD(itemTabCtrl, "itemName");
	
	if TryGetProp(listCls, 'GetItemFunc', 'None') == 'None' then return; end
	
	local get_name_func = _G[TryGetProp(listCls, 'GetItemFunc', 'None')];
	if get_name_func == nil then return; end

	local itemClsName = get_name_func(listCls, GetMyAccountObj());
	if itemClsName == 'None' then return; end

	local itemCls = GetClass('Item', itemClsName);
	if itemCls == nil then return; end

	
	local add_str = ''	
	if TryGetProp(itemCls, 'AdditionalOption_1', 'None') ~= 'None' then		
		add_str = '(' ..  ClMsg('Unique1') .. ')'
	end

	SET_SLOT_BG_BY_ITEMGRADE(itemSlot, TryGetProp(itemCls, 'ItemGrade'));
	itemText:SetTextByKey('name', TryGetProp(itemCls, 'Name') .. add_str);
	
	local icon = CreateIcon(itemSlot);
	icon:SetImage(TryGetProp(itemCls, 'Icon'));
	icon:SetTooltipType('wholeitem');
	icon:SetTooltipNumArg(itemCls.ClassID);
	icon:SetTooltipStrArg('char_belonging')
	icon:GetInfo().type = itemCls.ClassID;
	
	GET_CHILD(itemTabCtrl, 'select'):ShowWindow(0);
	itemTabCtrl:SetUserValue("ITEM_TYPE", listCls.ClassID);
end

function SEARCH_ITEM_CABINET_KEY()
	local frame = ui.GetFrame('item_cabinet')
	frame:CancelReserveScript("SEARCH_ITEM_CABINET");
	frame:ReserveScript("SEARCH_ITEM_CABINET", 0.3, 1);
end

function SEARCH_ITEM_CABINET(a,b,c)
	ITEM_CABINET_CREATE_LIST(a);
end

function ITEM_CABINET_MATCH_NAME(listCls, cap)
	if cap == "" then
		return true
	end

	if TryGetProp(listCls, 'GetItemFunc', 'None') == 'None' then return; end
	
	local get_name_func = _G[TryGetProp(listCls, 'GetItemFunc', 'None')];
	if get_name_func == nil then return; end

	local itemClsName = get_name_func(listCls, GetMyAccountObj());
	if itemClsName == 'None' then return; end

	local itemCls = GetClass('Item', itemClsName);
	if itemCls == nil then return; end

	local itemName = TryGetProp(itemCls, 'Name');

	if string.find(itemName, cap) ~= nil then
		return true;
	end

	return false;
end

function ITEM_CABINET_EXCUTE_CREATE(parent, self)	
	local category = ITEM_CABINET_GET_CATEGORY(parent);
	local itemType = parent:GetUserIValue("ITEM_TYPE");
	local resultlist = session.GetItemIDList();

	if category == 'Accessory' then
		category = 1;
	elseif category == 'Ark' then
		category = 2;
	else
		return;
	end
	
	pc.ReqExecuteTx_Item('MAKE_CABINET_ITEM', category, itemType);
end

function ITEM_CABINET_SELECT_ITEM(parent, self)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "upgrade_tab");
	local index = tab:GetSelectItemIndex();
	local aObj = GetMyAccountObj();
	local category = ITEM_CABINET_GET_CATEGORY(parent);
	local itemType = parent:GetUserIValue("ITEM_TYPE");
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = itemCls.ClassName;
	local curLv = TryGetProp(aObj, itemCls.UpgradeAccountProperty, 0);

	frame:SetUserValue("CATEGORY", category);
	frame:SetUserValue("ITEM_TYPE", itemType);
	frame:SetUserValue("TARGET_LV", curLv + 1);


	ITEM_CABINET_CLOSE_SUCCESS(frame);
	ITEM_CABINET_SELECT_TAB(frame, parent);
	ITEM_CABINET_REGISTER_SECTION(frame, category, itemType, curLv);
	ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index);
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 1);
	ITEM_CABINET_ICOR_SECTION(frame, self, itemCls);
end

function ITEM_CABINET_ICOR_SECTION(frame, self, itemCls)
	local silverText = GET_CHILD_RECURSIVELY(frame,"pricetxt");
	local price = GET_COMMA_SEPARATED_STRING_FOR_HIGH_VALUE(itemCls.MakeCostSilver);
	silverText:SetTextByKey("price", price);

	local itemslot = GET_CHILD_RECURSIVELY(self:GetParent(), "itemIcon");
	local iconinfo = itemslot:GetIcon():GetInfo();
	local itemCls = GetClassByType('Item', iconinfo.type);

	itemslot = GET_CHILD_RECURSIVELY(frame,"slot2");
	local icon = CreateIcon(itemslot);
	icon:SetImage(TryGetProp(itemCls, 'Icon'));
	icon:SetTooltipType('wholeitem');
	icon:SetTooltipNumArg(itemCls.ClassID);
	icon:SetTooltipStrArg('char_belonging')

	local optionGbox = GET_CHILD_RECURSIVELY(frame, "optionGbox_1")
	optionGbox:RemoveChild('tooltip_equip_property_narrow')
	optionGbox:RemoveChild('item_tooltip_ark')
	optionGbox:RemoveChild('tooltip_ark_lv')

	ITEM_CABINET_OPTION_INFO(optionGbox, itemCls)
end

function ITEM_CABINET_SELECT_TAB(frame, tab)
	local prevTabName = frame:GetUserValue("SELECTED_TAB");
	if prevTabName ~= "None" then
		local prevTab = GET_CHILD_RECURSIVELY(frame, prevTabName);
		local select = GET_CHILD_RECURSIVELY(prevTab, "select");
		select:ShowWindow(0);
	end
	local select = GET_CHILD_RECURSIVELY(tab, "select");
	select:ShowWindow(1);
	frame:SetUserValue("SELECTED_TAB", tab:GetName());
end

function ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index)
	local enchantbtn = GET_CHILD_RECURSIVELY(frame,"enchantbtn");
	local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');

	if category == "Weapon" or category == "Armor" then
		enchantbtn:SetTextByKey("name", ClMsg("Enchant"));
		upgrade_tab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("IcorEnchant"),false)
		if index == 0 then
			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(1);
			enchantbtn:SetEventScript(ui.LBUTTONUP, "ITEM_CABINET_EXCUTE_ENCHANT");
		end
	else
		enchantbtn:SetTextByKey("name", ClMsg("Create"));
		upgrade_tab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("Create"),false)
		if index == 0 then
			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
			enchantbtn:SetEventScript(ui.LBUTTONUP, "ITEM_CABINET_EXCUTE_CREATE");
		end
	end
end

function ITEM_CABINET_GET_CATEGORY(frame)
	local frame = frame:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "cabinet_tab");
	local index = tab:GetSelectItemIndex();

	if index == 0 then
		category = "Weapon";
	elseif index == 1 then
		category = "Armor";
	elseif index == 2 then
		category = "Accessory";
	elseif index == 3 then
		category = "Ark";
	end

	return category;
end

function ITEM_CABINET_UPGRADE_TAB(parent)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "upgrade_tab");
	local index = tab:GetSelectItemIndex();
	if index == 1 then 
		GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(0);

		local max = GET_CHILD_RECURSIVELY(frame, 'registerbtn'):GetTextByKey("name");
		if max == "MAX" then
			INVENTORY_SET_CUSTOM_RBTNDOWN("None");
		else
			INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_CABINET_MATERIAL_INV_BTN");
		end
		if category == "Accessory" then
			GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(1);
		else
			GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(0);
		end

	elseif index == 0 then
		local category = frame:GetUserValue("CATEGORY");
		GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(1);
		ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index);

		if category == "Weapon" or category == "Armor" then
			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(1);		
			GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(0);			
			GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(0);
			INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_CABINET_INV_BTN");
			local inven = ui.GetFrame('inventory');
			if inven:IsVisible() == 0 then inven:ShowWindow(1); end
		else
			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
			GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(1);
			GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(1);
			INVENTORY_SET_CUSTOM_RBTNDOWN("None");
		end

		ITEM_CABINET_SELECTED_ITEM_CLEAR();
	end
	ITEM_CABINET_CLEAR_SLOT();
end

function ITEM_CABINET_REGISTER_SECTION(frame, category, itemType, curLv)
	local aObj = GetMyAccountObj();
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = itemCls.ClassName;
	local isRegister = TryGetProp(aObj, itemCls.AccountProperty, 0);
	local maxLv = itemCls.MaxUpgrade;
	local registerBtn = GET_CHILD_RECURSIVELY(frame, 'registerbtn');
	local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');
	registerBtn:SetTextByKey("name", "MAX");
	registerBtn:SetEnable(0);
	GET_CHILD_RECURSIVELY(frame, "upgradegbox"):RemoveAllChild();	
	if (category == "Weapon" or category == "Armor") and maxLv ~= 1 then
		if curLv == maxLv and isRegister == 1 then
			upgrade_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Upgrade"),false)
			return;
		end
	else
		if isRegister == 1 then
			upgrade_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Register"),false)
			return;
		end
	end
	registerBtn:SetEnable(1);
	if itemName == "EP12_NECK06_HIGH_003" then -- 칸트리베는 레시피가 두개임 
		curLv = frame:GetUserIValue("TARGET_LV");
		frame:SetUserValue("TARGET_LV", curLv + 1);
	end
	local materialTable = GET_REGISTER_MATERIAL(category, itemName, curLv+1);	
	ITEM_CABINET_DRAW_MATERIAL(frame, materialTable, curLv+1, maxLv);
end

function ITEM_CABINET_EXCUTE_REGISTER(parent, self)		
	session.ResetItemList();
	local selectIndex = 0
	for k,v in pairs(g_selectedItem) do
		session.AddItemID(k, v);
		selectIndex = selectIndex + 1;
	end
	local category = parent:GetUserValue("CATEGORY");
	local itemType = parent:GetUserIValue("ITEM_TYPE");
	local targetLv = parent:GetUserIValue("TARGET_LV");
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = itemCls.ClassName;
	
	local mat_count = 0
	for _, v in pairs(g_materialItem) do
		for k, v1 in pairs(v) do
			if k == 'name' then
				if v1 ~= 'Vis' and IS_ACCOUNT_COIN(v1) == false then
					mat_count = mat_count +1
				end
			end
		end
	end

	if selectIndex ~= mat_count then		
		ui.SysMsg(ClMsg('Auto_JaeLyoKa_BuJogHapNiDa.'))
		return;
	end

	local argStrList = NewStringList() ;   
    argStrList:Add(category);
	argStrList:Add(itemType);
	argStrList:Add(targetLv);
	local resultlist = session.GetItemIDList();		
	item.DialogTransaction("REGISTER_CABINET_ITEM", resultlist, '', argStrList);			
end

local function SORT_BY_NAME(a, b)
	return a.name < b.name;
end

function ITEM_CABINET_DRAW_MATERIAL(frame, materialTable, targetLV, maxLv)	
	local gbox = GET_CHILD_RECURSIVELY(frame, "upgradegbox");
	local registerBtn = GET_CHILD_RECURSIVELY(frame, "registerbtn");
	local registerTxt = GET_CHILD_RECURSIVELY(frame, "registertxt");
	local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');

	local pc = GetMyPCObject();
	local aObj = GetMyAccountObj();

	if targetLV > 1 and maxLv ~= 1 then
		registerBtn:SetTextByKey("name", ClMsg("Upgrade"));
		upgrade_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Upgrade"),false)

	else
		registerBtn:SetTextByKey("name", ClMsg("Register"));
		upgrade_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Register"),false)
	end

	g_materialItem = {}
	for k,v in pairs(materialTable) do
		local sortedMaterial = {}
		sortedMaterial.name = k;
		sortedMaterial.count = v;
		table.insert(g_materialItem, sortedMaterial);
	end
	table.sort(g_materialItem, SORT_BY_NAME)

	local index = 1;
	for i = 1, #g_materialItem do
		local ctrlSet = gbox:CreateOrGetControlSet("eachmaterial_in_item_cabinet", "ITEM_CABINET_MAT"..index, 0, (index - 1) * 40);
		if ctrlSet ~= nil then
			local icon = GET_CHILD_RECURSIVELY(ctrlSet, "material_icon", "ui::CPicture");
			local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, "material_questionmark", "ui::CPicture");
			local name = GET_CHILD_RECURSIVELY(ctrlSet, "material_name", "ui::CRichText");
			local count = GET_CHILD_RECURSIVELY(ctrlSet, "material_count", "ui::CRichText");
			local grade = GET_CHILD_RECURSIVELY(ctrlSet, "grade", "ui::CRichText");
			icon:ShowWindow(1);
			count:ShowWindow(1);
			questionmark:ShowWindow(0);

			local _name = g_materialItem[i].name
			local real_name = StringSplit(_name, '__')[1]
			if real_name ~= nil then
				_name = real_name
			end
			local materialCls = GetClass("Item", _name);
			if materialCls ~= nil and g_materialItem[i].count > 0 then
				count:SetTextByKey("color", "{#EE0000}");
				count:SetTextByKey("curCount", 0);
				count:SetTextByKey("needCount", g_materialItem[i].count);

				local add_str = ''
				if TryGetProp(materialCls, 'AdditionalOption_1', 'None') ~= 'None' then					
					add_str = '(' ..  ClMsg('Unique1') .. ')'
				end

				name:SetText(materialCls.Name .. add_str);
				icon:SetImage(materialCls.Icon);
			elseif materialCls == nil and g_materialItem[i].count > 0 then
				local curCoinCount = TryGetProp(aObj, _name, '0');
				if curCoinCount == "None" then
					curCoinCount = '0'
				end
				if math.is_larger_than(g_materialItem[i].count, curCoinCount) == 1 then
					count:SetTextByKey("color", "{#EE0000}");
				else
					count:SetTextByKey("color", nil);							
				end
				count:SetTextByKey("curCount", curCoinCount);
				count:SetTextByKey("needCount", g_materialItem[i].count);

				local coinCls = GetClass("accountprop_inventory_list", _name);
				name:SetText(ClMsg(_name));
				icon:SetImage(coinCls.Icon);
			end
			index = index + 1;
	 	end
	end
	local inven = ui.GetFrame('inventory');
	if inven:IsVisible() == 0 then inven:ShowWindow(1); end
end

function ITEM_CABINET_MATERIAL_INV_BTN(itemObj, slot)	
	if slot:IsSelected() == 1 then
		ITEM_CABINET_SET_SLOT_ITEM(slot, 0);
	else
		local frame = ui.GetFrame("item_cabinet");
		if frame == nil then
			return;
		end		
		ITEM_CABINET_REG_MATERIAL(frame, slot);
	end
end

local selected_slot = nil

function ITEM_CABINET_REG_MATERIAL(frame, slot)	
	selected_slot = nil
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local itemID = iconInfo:GetIESID();

	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemID);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', itemObj.ClassID);
	local aObj = GetMyPCObject();
	
	if GetMyPCObject() == nil then
		return;
	end

	-- 아이템 잠금 처리 확인
	local invframe = ui.GetFrame("inventory");
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local targetLv = frame:GetUserIValue("TARGET_LV");
	local targetItemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = targetItemCls.ClassName;

	for index = 1, #g_materialItem do
		local _name = g_materialItem[index].name
		local real_name = StringSplit(_name, '__')[1]
		if real_name ~= nil then
			_name = real_name
		end
		local materialCls = GetClass("Item", _name);
		local item_name = itemCls.ClassName
		if TryGetProp(itemObj, 'GroupName', 'None')	== 'Icor' then
			item_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
		end
		
		if TryGetProp(materialCls ,'ClassName', 'None') == item_name then 			
			if g_materialItem[index].count > 1 then				
				ITEM_CABINET_INPUT_MATERIAL_CNT_BOX(invItem, index, itemID, slot);
				return;
			else
				local materialCtrl = GET_CHILD_RECURSIVELY(ui.GetFrame("item_cabinet"), "ITEM_CABINET_MAT"..index);
				local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");
				local curCount = tonumber(materialCount:GetTextByKey("curCount"));
				if curCount == 0 then
					ITEM_CABINET_MATERIAL_CNT_UPDATE(index, 1, itemID);				
					ITEM_CABINET_SET_SLOT_ITEM(slot, 1, index);				
					return
				end
			end			
		end
		index = index + 1
	end
end

function ITEM_CABINET_INPUT_MATERIAL_CNT_BOX(invItem, index, guid, slot)
    local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", invItem.count);
    local inputstringframe = ui.GetFrame("inputstring");
	inputstringframe:SetUserValue("CTRL_INDEX", index);
	inputstringframe:SetUserValue("GUID", guid);
	selected_slot = slot
	INPUT_NUMBER_BOX(inputstringframe, titleText, "ITEM_CABINET_INPUT_MATERIAL_CONFIRM", 1, 1, invItem.count, 1);	
end

function ITEM_CABINET_INPUT_MATERIAL_CONFIRM(parent, count)
	local index = parent:GetUserValue("CTRL_INDEX");
	local guid = parent:GetUserValue("GUID"); 
	ITEM_CABINET_MATERIAL_CNT_UPDATE(index, count, guid);
	if selected_slot ~= nil then
		ITEM_CABINET_SET_SLOT_ITEM(selected_slot, 1, index);		
	end
end

function ITEM_CABINET_MATERIAL_CNT_UPDATE(index, count, guid)
	local frame = ui.GetFrame("item_cabinet")
	local materialCtrl = GET_CHILD_RECURSIVELY(frame, "ITEM_CABINET_MAT"..index);
	local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");

	local curCount = tonumber(materialCount:GetTextByKey("curCount"));
	local needCount = tonumber(materialCount:GetTextByKey("needCount"));
	count = tonumber(count);

	if curCount + count < needCount then
		curCount = curCount + count
		materialCount:SetTextByKey("color", "{#EE0000}");
	else
		curCount = needCount
		materialCount:SetTextByKey("color", nil);
		g_selectedItem[guid] = curCount;
	end
	materialCount:SetTextByKey("curCount",curCount);
end

function ITEM_CABINET_CLEAR_SLOT()
	if ui.CheckHoldedUI() == true then
		return;
	end
	local frame = ui.GetFrame("item_cabinet");
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	slot:ClearIcon();
end

function ITEM_CABINET_INV_BTN(itemObj, slot)
	local frame = ui.GetFrame("item_cabinet");
	if frame == nil then
		return;
	end
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	ITEM_CABINET_REG_ADD_ITEM(frame, iconInfo:GetIESID());
end


function ITEM_CABINET_ADD_ITEM_DROP(parent, self, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		ITEM_CABINET_REG_ADD_ITEM(parent, iconInfo:GetIESID(), self:GetName());
	end
end

function ITEM_CABINET_SET_SLOT_ITEM(slot, isSelect, index)	
	slot = AUTO_CAST(slot);
	if isSelect == 1 then
		slot:SetSelectedImage('socket_slot_check');
		slot:Select(1);
		slot:SetUserValue("INDEX", index);
	else
		local icon = slot:GetIcon();
		local iconInfo = icon:GetInfo();
		local itemID = iconInfo:GetIESID();

		slot:Select(0);
		index = slot:GetUserValue("INDEX");
		if index == "None" then
			return;
		end
		local frame = ui.GetFrame("item_cabinet");
		local materialCtrl = GET_CHILD_RECURSIVELY(frame, "ITEM_CABINET_MAT"..index);
		local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");
		materialCount:SetTextByKey("color", "{#EE0000}");
		materialCount:SetTextByKey("curCount", 0);	
		CANCEL_CABINET_SET_SLOT_ITEM(itemID)		
	end
end

function table.removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function CANCEL_CABINET_SET_SLOT_ITEM(itemID)
	table.removeKey(g_selectedItem, itemID)
	SELECT_INV_SLOT_BY_GUID(itemID, 0);
end

function ITEM_CABINET_SELECTED_ITEM_CLEAR()
	for k,v in pairs(g_selectedItem) do
		SELECT_INV_SLOT_BY_GUID(k, 0);
	end
	g_selectedItem = {}
end

function ITEM_CABINET_REG_ADD_ITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemID);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', itemObj.ClassID);
	local aObj = GetMyAccountObj();
	
	if GetMyPCObject() == nil then
		return;
	end

	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local ret, clmsg, msg = CHECK_ENCHANT_VALIDATION(itemObj, category, itemType, aObj);
	if ret == false then
		if msg ~= nil then
			ui.SysMsg(msg);
		else
			ui.SysMsg(ClMsg(clmsg));
		end
		return;
	end

	-- 아이템 잠금 처리 확인
	local invframe = ui.GetFrame("inventory");
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon ~= nil then
		icon:SetColorTone("FFFFFFFF");
	end
	SET_SLOT_ITEM(slot, invItem);
	session.ResetItemList();
	session.AddItemID(itemID, 1); 
end


function ITEM_CABINET_EXCUTE_ENCHANT(parent, self)
	local frame = parent:GetTopParentFrame();
    local argStrList = NewStringList();
	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");

    argStrList:Add(category);
	argStrList:Add(itemType);
	
    local resultlist = session.GetItemIDList(); 
    item.DialogTransaction("ENCHANT_GODDESS_ITEM", resultlist, '', argStrList);	 
end


function ITEM_CABINET_SUCCESS_GODDESS_ENCHANT(frame, msg, argStr, argNum)
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 0);
	ITEM_CABINET_CREATE_LIST(frame);
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	session.ResetItemList();
	imcSound.ReleaseSoundEvent("sys_transcend_success");
	imcSound.PlaySoundEvent("sys_transcend_success");
	GET_CHILD_RECURSIVELY(frame,"successBgBox"):ShowWindow(1);
end

function ITEM_CABINET_CLOSE_SUCCESS(frame)
	local frame = frame:GetTopParentFrame();
	GET_CHILD_RECURSIVELY(frame, "successBgBox"):ShowWindow(0);
end

local function ITEM_CABINET_CREATE_ARK_LV(gBox, ypos, step, class_name, curlv)
	local margin = 5;

	class_name = replace(class_name, 'PVP_', '')

	local func_str = string.format('get_tooltip_%s_arg%d', class_name, step)
    local tooltip_func = _G[func_str]  -- get_tooltip_Ark_str_arg1 시리즈
	if tooltip_func ~= nil then
		local tooltip_type, status, interval, add_value, summon_atk, client_msg, unit = tooltip_func();		
		local option_active_lv = nil
		local option_active_func_str = string.format('get_%s_option_active_lv', class_name)
		local option_active_func = _G[option_active_func_str]
		if option_active_func ~= nil then
			option_active_lv = option_active_func();			
		end

		local option = status        
		local grade_count = math.floor(curlv / interval);
		if tooltip_type == 3 then
			add_value = add_value * grade_count
		else
			add_value = math.floor(add_value * grade_count);		
		end
		
		if add_value <= 0 and (option_active_lv == nil or curlv < option_active_lv)then			
			return ypos;
		end
		
		local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(option), add_value)
		
		if tooltip_type == 2 then
			local add_msg =  string.format(", %s "..ScpArgMsg("PropUp").."%.1f", ScpArgMsg('SUMMON_ATK'), math.abs(add_value / 200)) .. '%'
			strInfo = strInfo .. ' ' .. add_msg
		elseif tooltip_type == 3 then
			if unit == nil then				
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. '%'								
			else
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. unit				
			end
		elseif tooltip_type == 4 then
			if unit == nil then
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. '%'
			else
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. unit				
			end
		end		
		
		local infoText = gBox:CreateControl('richtext', 'infoText'..step, 15, ypos, gBox:GetWidth(), 30);
		infoText:SetText(strInfo);		
		infoText:SetFontName("brown_16");
		gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + infoText:GetHeight())

		ypos = ypos + infoText:GetHeight() + margin;
	end

	return ypos;
end

-- 옵션 text 추가 
local function ITEM_CABINET_CREATE_ARK_OPTION(gBox, ypos, step, class_name)
	local margin = 5;

	class_name = replace(class_name, 'PVP_', '')

	local func_str = string.format('get_tooltip_%s_arg%d', class_name, step)
    local tooltip_func = _G[func_str]  -- get_tooltip_Ark_str_arg1 시리즈
	if tooltip_func ~= nil then
		local tooltip_type, status, interval, add_value, summon_atk, client_msg, unit = tooltip_func();
		local option = status
		local infoText = gBox:CreateControl('richtext', 'optionText'..step, 15, ypos, gBox:GetWidth(), 30);
		local text = ''
		if tooltip_type == 1 then
			text = ScpArgMsg("ArkOptionText{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)
		elseif tooltip_type == 2 then
			text = ScpArgMsg("ArkOptionText{Option}{interval}{addvalue}{option2}{addvalue2}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value, 'option2', ClMsg(summon_atk), 'addvalue2', string.format('%.1f', add_value / 200))
		elseif tooltip_type == 3 then			
			if client_msg == nil then
				text = ScpArgMsg("ArkOptionText3{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)				
			else
				text = ScpArgMsg(client_msg, "Option", ClMsg(option), "interval", interval, "addvalue", add_value)				
			end
		elseif tooltip_type == 4 then			
			text = ScpArgMsg("ArkOptionText4{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)
		end
		
		infoText:SetText(text);
		infoText:SetFontName("brown_16_b");
		gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + infoText:GetHeight())
		ypos = ypos + infoText:GetHeight() + margin;
	end

	return ypos;
end

function ITEM_CABINET_OPTION_INFO(gBox, targetItem)
	local yPos = 0
	local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(targetItem)
    local list = {}
    local basicTooltipPropList = StringSplit(targetItem.BasicTooltipProp, ';')
    for i = 1, #basicTooltipPropList do
        local basicTooltipProp = basicTooltipPropList[i]
        list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list)
    end

	local cnt = 0
	for i = 1 , #list do
		local propName = list[i]
		local propValue = TryGetProp(targetItem, propName, 0)
		
		if propValue ~= 0 then
            local checkPropName = propName
            if propName == 'MINATK' or propName == 'MAXATK' then
                checkPropName = 'ATK'
            end
            if EXIST_ITEM(basicTooltipPropList, checkPropName) == false then
                cnt = cnt + 1
            end
		end
	end

	for i = 1 , 3 do
		local propName = "HatPropName_"..i
		local propValue = "HatPropValue_"..i
		if targetItem[propValue] ~= 0 and targetItem[propName] ~= "None" then
			cnt = cnt + 1
		end
	end

	local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow', 'tooltip_equip_property_narrow', 0, yPos)
	tooltip_equip_property_CSet:Resize(gBox:GetWidth(),tooltip_equip_property_CSet:GetHeight())
	
	local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "labelline")
	labelline:ShowWindow(0)
	local property_gbox = GET_CHILD(tooltip_equip_property_CSet,'property_gbox','ui::CGroupBox')
	property_gbox:Resize(tooltip_equip_property_CSet:GetWidth(),property_gbox:GetHeight())

	local class = GetClassByType("Item", targetItem.ClassID)

	local inner_yPos = 0
	
	for i = 1 , #list do
		local propName = list[i]
		local propValue = TryGetProp(targetItem, propName, 0)
		local needToShow = true
		for j = 1, #basicTooltipPropList do
			if basicTooltipPropList[j] == propName then
				needToShow = false
			end
		end

		if needToShow == true and propValue ~= 0 then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
			if  targetItem.GroupName == 'Weapon' then
				if propName ~= "MINATK" and propName ~= 'MAXATK' then
					local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
					inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
				end
			elseif  targetItem.GroupName == 'Armor' then
				if targetItem.ClassType == 'Gloves' then
					if propName ~= "HR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				elseif targetItem.ClassType == 'Boots' then
					if propName ~= "DR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				else
					if propName ~= "DEF" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				end
			else
				local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
				inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
			end
		end
	end
	if targetItem.ClassType == 'Ark' then
		inner_yPos = 10
		for i = 1, max_ark_option_count do 	-- 옵션이 최대 10개 있다고 가정함		
			inner_yPos = ITEM_CABINET_CREATE_ARK_LV(tooltip_equip_property_CSet, inner_yPos, i, targetItem.ClassName, 1);
		end

		for i = 1, max_ark_option_count do 	-- 옵션이 최대 10개 있다고 가정함		
			inner_yPos = ITEM_CABINET_CREATE_ARK_OPTION(tooltip_equip_property_CSet, inner_yPos, i, targetItem.ClassName);
		end

		local desc = EQUIP_ARK_DESC(targetItem.ClassName);
		if desc ~= "" then
			inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(tooltip_equip_property_CSet, desc, 0, inner_yPos)
		end
	end

	for i = 1 , 3 do
		local propName = "HatPropName_"..i
		local propValue = "HatPropValue_"..i
		if targetItem[propValue] ~= 0 and targetItem[propName] ~= "None" then
			local opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(targetItem[propName]))
			local strInfo = ABILITY_DESC_PLUS(opName, targetItem[propValue])
			inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
		end
	end

	if targetItem.OptDesc ~= nil and targetItem.OptDesc ~= 'None' then
		inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, targetItem.OptDesc, 0, inner_yPos)
	end

	if targetItem.OptDesc ~= nil and (targetItem.OptDesc == 'None' or targetItem.OptDesc == '') and TryGetProp(targetItem, 'StringArg', 'None') == 'Vibora' then
		local opt_desc = targetItem.OptDesc
		if opt_desc == 'None' then
			opt_desc = ''
		end
		
		for idx = 1, MAX_VIBORA_OPTION_COUNT do			
			local additional_option = TryGetProp(targetItem, 'AdditionalOption_' .. tostring(idx), 'None')			
			if additional_option ~= 'None' then
				local tooltip_str = 'tooltip_' .. additional_option					
				local cls_message = GetClass('ClientMessage', tooltip_str)
				if cls_message ~= nil then
					opt_desc = opt_desc .. ClMsg(tooltip_str)
				end
			end
		end
		inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, opt_desc, 0, inner_yPos);
	end

	tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY() + 40)
	gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight()+10)
end
