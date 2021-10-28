-- itemtooltip.lua

-- tooltip.xml???í??ë, ?´í ê´??ê°??ì²ì ?¤í?ë ë£¨ì ?¨ì. ?¬ê¸°???ì´?ì ì¢ë¥???°ë¼ ê°ê° ?¤ë¥¸ ?ì© ?´í ?¨ì?¤ì ?¸ì¶?ë¤. ì¢ë¥?ë ?¨ì ëªì? item?´ë?¤ì CT_ToolTipScpë¥??°ë¦

function ON_REFRESH_ITEM_TOOLTIP()
	local wholeitem = ui.GetTooltip("wholeitem")
	if wholeitem ~= nil then
		wholeitem:RefreshTooltip();
	end

    local wholeitem_link = ui.GetFrame("wholeitem_link")
	tolua.cast(wholeitem_link, "ui::CTooltipFrame");
	if wholeitem_link ~= nil then
		wholeitem_link:RefreshTooltip();
	end
end

function UPDATE_ITEM_TOOLTIP(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	
	local itemObj, isReadObj = nil
	
	if tooltipobj ~= nil then
		itemObj = tooltipobj;
		isReadObj = 0;
	else
		itemObj, isReadObj = GET_TOOLTIP_ITEM_OBJECT(strarg, numarg2, numarg1);	
	end
    
	if itemObj == nil then
		return;
	end

	if nil ~= itemObj and itemObj.GroupName == "Unused" then
		tooltipframe:Resize(1, 1);
        return;
	end
	
	-- ëª¨ì¡°?ì? ê°?ì ?ì´???ë³´ë¥?ë§ë¤?´ì ë³´ì¬ì£¼ê¸° ?ë¬¸??GUIDê° ?ì´??strargë¥??µí´ ?ë³´ ë³´ë´ì¤?forgery#ModifiedPropertyString)
	local isForgeryItem = false;	
	if string.find(strarg, 'forgery') ~= nil and itemObj ~= nil then
		isForgeryItem = true;
		local strList = StringSplit(strarg, '#');
		SetModifiedPropertiesString(itemObj, strList[2]);
	end	
	tooltipframe:SetUserValue('TOOLTIP_ITEM_GUID', numarg2);

	local recipeitemobj = nil

	local recipeid = IS_RECIPE_ITEM(itemObj)
	-- ?ì???ì´??ìª
		
	if recipeid ~= 0 then
		
		local recipeIES = CreateIESByID('Item', recipeid);
		
		if recipeIES ~= nil then

			recipeitemobj = recipeIES
			local refreshScp = recipeitemobj.RefreshScp;

			if refreshScp ~= "None" then
				refreshScp = _G[refreshScp];
				refreshScp(recipeitemobj);
			end	

		end
	end
	
	--Main Info
	tooltipframe:Resize(tooltipframe:GetOriginalWidth(), tooltipframe:GetOriginalHeight());
	tooltipframe:CheckSize()
	INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)

	if isReadObj == 0 then
		if 1 == IS_DRAG_RECIPE_ITEM(itemObj) then
			local tabTxt = "";
			tabTxt, numarg1 = GET_DRAG_RECIPE_INFO(itemObj);
			isReadObj = 1;
			
			local tabCtrl = GET_CHILD(tooltipframe, "tabText", "ui::CTabControl");
			tabCtrl:ChangeCaption(0, tabText);
			tabCtrl:ShowWindow(1);
		end
	end

	local recipeclass = recipeitemobj;

	-- ì½ë ?ì???´í???ì¸?ë ?ì?ë ?ì?ë§ ë³´ì¬ì¤?? 
	if recipeclass ~= nil and strarg ~= 'collection' then
		local ToolTipScp = _G[ 'ITEM_TOOLTIP_' .. recipeclass.ToolTipScp];
		ToolTipScp(tooltipframe, recipeclass, strarg, "usesubframe_recipe");
		DestroyIES(recipeitemobj);
	end

	
	if itemObj == nil then
		return;
	end
	
	local needAppraisal = TryGetProp(itemObj, "NeedAppraisal");
	local drawCompare = true;
	local showAppraisalPic = false;
	if needAppraisal ~= nil and needAppraisal == 1 then
		DRAW_APPRAISAL_PICTURE(tooltipframe);
		drawCompare = false;
		showAppraisalPic = true;
	end
	
	-- ë¹êµ?´í
	-- ?´í ë¹êµ??ë¬´ê¸°? ?¥ë¹?ë§ ?´ë¹?ë¤. (ë¯¸ê°???ì¸)

	if drawCompare == true and ( (itemObj.ToolTipScp == 'WEAPON' or itemObj.ToolTipScp == 'ARMOR') and  (strarg == 'inven' or strarg =='sell' or isForgeryItem == true) and (string.find(itemObj.GroupName, "Pet") == nil)) then

		local CompItemToolTipScp = _G[ 'ITEM_TOOLTIP_' .. itemObj.ToolTipScp];
		local ChangeValueToolTipScp = _G[ 'ITEM_TOOLTIP_' .. itemObj.ToolTipScp..'_CHANGEVALUE'];
		-- ?ì ë¬´ê¸° / ë°©í¨ ??ê²½ì°

		local isVisble = nil;
		
		if itemObj.EqpType == 'SH' then
		
			if itemObj.DefaultEqpSlot == 'RH' or itemObj.DefaultEqpSlot == 'RH LH' then
				
				local item = session.GetEquipItemBySpot( item.GetEquipSpotNum("RH") );
				if nil ~= item then
				local equipItem = GetIES(item:GetObject());
				
				local classtype = TryGetProp(equipItem, "ClassType"); -- ì½ì¤?¬ì? ?ë¨?ë¡

				if IS_NO_EQUIPITEM(equipItem) == 0 and classtype ~= "Outer" then
					CompItemToolTipScp(tooltipframe, equipItem, strarg, "usesubframe");
					isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg);
				end
				end
			elseif itemObj.DefaultEqpSlot == 'LH' then

				local item = session.GetEquipItemBySpot( item.GetEquipSpotNum("LH") );
				if nil ~= item then
				local equipItem = GetIES(item:GetObject());

				if IS_NO_EQUIPITEM(equipItem) == 0 then
					CompItemToolTipScp(tooltipframe, equipItem, strarg, "usesubframe");
					isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg);
				end
				end
			end
			
		-- ?ì ë¬´ê¸° ??ê²½ì°
		elseif itemObj.EqpType == 'DH' then
			
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum("RH"));
			if nil ~= item then
			local equipItem = GetIES(item:GetObject());

			if IS_NO_EQUIPITEM(equipItem) == 0 then
				CompItemToolTipScp(tooltipframe, equipItem, strarg, "usesubframe");
				isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg);
			end
			end
		else
			local equiptype = itemObj.EqpType

			if equiptype == 'RING' then

				if keyboard.IsPressed(KEY_ALT) == 1 then
					equiptype = 'RING2'
				else
					equiptype = 'RING1'
				end
			end

			local equitSpot = item.GetEquipSpotNum(equiptype);

			local item = session.GetEquipItemBySpot(equitSpot);

			if item ~= nil then
				local equipItem = GetIES(item:GetObject());

				if IS_NO_EQUIPITEM(equipItem) == 0 then
					CompItemToolTipScp(tooltipframe, equipItem, strarg, "usesubframe");
					isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg);
				end

			end
		end

	end

	-- ë©ì¸ ?ë ?? ì¦?ì£¼ë ?´í ?ì.
	if isReadObj == 1 then -- IESê° ?ë ?ì´?? ê°???ì?ì ?ì± ?ì´???ì ?
			
		local class = itemObj;
		if class ~= nil then
			local ToolTipScp = _G[ 'ITEM_TOOLTIP_' .. class.ToolTipScp];
			ToolTipScp(tooltipframe, class, strarg, "mainframe", isForgeryItem);
		end

		
	else
		local ToolTipScp = _G[ 'ITEM_TOOLTIP_' .. itemObj.ToolTipScp];
		if nil == noTradeCnt then
			noTradeCnt = 0
		end
		ToolTipScp(tooltipframe, itemObj, strarg, "mainframe",noTradeCnt);

	end
	

	if isReadObj == 1 then
		DestroyIES(itemObj);
	end

	ITEMTOOLTIPFRAME_ARRANGE_CHILDS(tooltipframe, showAppraisalPic);
	ITEMTOOLTIPFRAME_RESIZE(tooltipframe);

end

function ITEMTOOLTIPFRAME_ARRANGE_CHILDS(tooltipframe, showAppraisalPic)

	local cvalueGBox = GET_CHILD(tooltipframe, 'changevalue','ui::CGroupBox')
	if showAppraisalPic == true then
		cvalueGBox =  GET_CHILD(tooltipframe, 'appraisal','ui::CGroupBox');
	end
	local cvalueGBoxheight = cvalueGBox:GetHeight()
	local childCnt = tooltipframe:GetChildCount();
	local minY = option.GetClientHeight();
	local arrange = false;
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);
		if chld:GetName() ~= 'changevalue' then
			local targetY = chld:GetY() + cvalueGBoxheight;			
			local diff = targetY + chld:GetHeight() - option.GetClientHeight();
			if diff > 0 then
				arrange = true;
				targetY = targetY - diff;
			end

			chld:SetOffset(chld:GetX(), targetY);

			if minY > targetY then
				minY = targetY;
			end
		end
	end

	if arrange == true then
		-- ë¹êµ ?´í ?ì¹ ë§ì¶°ì£¼ê¸°
		local equip_main = tooltipframe:GetChild('equip_main');
		local equip_sub = tooltipframe:GetChild('equip_sub');
		local mainY = equip_main:GetY();
		local subY = equip_sub:GetY();
		if mainY > subY then
			equip_main:SetOffset(equip_main:GetX(), subY);
		elseif mainY < subY then
			equip_sub:SetOffset(equip_sub:GetX(), mainY);
		end

		-- ë¹êµ ë§í???ì¹ ì¡°ì 
		local changevalue = tooltipframe:GetChild('changevalue');
		local appraisalOffset = 0;
		if showAppraisalPic == true then
			changevalue = tooltipframe:GetChild('appraisal');
			local marginRect = changevalue:GetMargin();
			appraisalOffset = marginRect.top;
		end
		changevalue:SetOffset(changevalue:GetX(), minY - cvalueGBoxheight + appraisalOffset);
	end
end

function INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)

	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);

		chld:RemoveAllChild()
		chld:SetOffset(chld:GetOriginalX(),chld:GetOriginalY());

		if chld:GetName() ~= 'closebtn' then
			chld:Resize(chld:GetOriginalWidth(),0);
		end
	end
end

function ITEMTOOLTIPFRAME_RESIZE(tooltipframe)

	local min_x = 9999;
	local max_x = -9999;

	local min_y = 9999;
	local max_y = -9999;

	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);
		if chld:GetHeight() > 0 then
			local chldminx = chld:GetX()
			local chldmaxx = chld:GetX() + chld:GetWidth()
			local chldminy = chld:GetY()
			local chldmaxy = chld:GetY() + chld:GetHeight()

			if chldminx < min_x then
				min_x = chldminx
			end
			if chldmaxx > max_x then
				max_x = chldmaxx
			end
			if chldminy < min_y then
				min_y = chldminy
			end
			if chldmaxy > max_y then
				max_y = chldmaxy
			end

		end
	end

	local childCnt = tooltipframe:GetChildCount();
	for i = 0 , childCnt - 1 do
		local chld = tooltipframe:GetChildByIndex(i);
		    chld:SetOffset(chld:GetX() - min_x, chld:GetY() - min_y)
	end

	tooltipframe:Resize(max_x-min_x, max_y-min_y);

end

--?ì ?ì ê°ê²??ì
function DRAW_SELL_PRICE(tooltipframe, invitem, yPos, mainframename)
    
	local itemProp = geItemTable.GetPropByName(invitem.ClassName);
    if itemProp:IsEnableShopTrade() == false then
        return yPos
    end
    
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_sellinfo');
	
	local tooltip_sellinfo_CSet = gBox:CreateControlSet('tooltip_sellinfo', 'tooltip_sellinfo', 0, yPos);
	tolua.cast(tooltip_sellinfo_CSet, "ui::CControlSet");

	local sellprice_text = GET_CHILD(tooltip_sellinfo_CSet,'sellprice','ui::CRichText')
	sellprice_text:SetTextByKey("silver", geItemTable.GetSellPrice(itemProp) );

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- ë§??ë«ìª??¬ë°±
	tooltip_sellinfo_CSet:Resize(tooltip_sellinfo_CSet:GetWidth(),tooltip_sellinfo_CSet:GetHeight() + BOTTOM_MARGIN);

	local height = gBox:GetHeight() + tooltip_sellinfo_CSet:GetHeight();
	gBox:Resize(gBox:GetWidth(), height);
	return yPos + tooltip_sellinfo_CSet:GetHeight();
end

function DRAW_REMAIN_LIFE_TIME(tooltipframe, invitem, yPos, mainframename)
	
	local itemProp = geItemTable.GetPropByName(invitem.ClassName);
    if itemProp:IsEnableShopTrade() == false and itemProp.LifeTime == 0 then
        return yPos
    end
    
	local gBox = GET_CHILD(tooltipframe, mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_lifeTimeinfo');	

	local tooltip_lifeTimeinfo_CSet = gBox:CreateControlSet('tooltip_lifeTimeinfo', 'tooltip_lifeTimeinfo', 0, yPos);
	tolua.cast(tooltip_lifeTimeinfo_CSet, "ui::CControlSet");

	local lifeTime_text = GET_CHILD(tooltip_lifeTimeinfo_CSet,'lifeTime','ui::CRichText');
		
	if string.find(invitem.ItemLifeTime, "None") ~= nil then
		local timeTxt = GET_TIME_TXT(invitem.LifeTime);
		lifeTime_text:SetTextByKey("p_LifeTime", timeTxt );
	else
	local sysTime = geTime.GetServerSystemTime();
	local endTime = imcTime.GetSysTimeByStr(invitem.ItemLifeTime);
	local difSec = imcTime.GetDifSec(endTime, sysTime);
	lifeTime_text:SetUserValue("REMAINSEC", difSec);
	lifeTime_text:SetUserValue("STARTSEC", imcTime.GetAppTime());
	lifeTime_text:RunUpdateScript("SHOW_REMAIN_LIFE_TIME");
	end

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- ë§??ë«ìª??¬ë°±
	tooltip_lifeTimeinfo_CSet:Resize(tooltip_lifeTimeinfo_CSet:GetWidth(),tooltip_lifeTimeinfo_CSet:GetHeight() + BOTTOM_MARGIN);
	
	local height = gBox:GetHeight() + tooltip_lifeTimeinfo_CSet:GetHeight();
	gBox:Resize(gBox:GetWidth(), height);
	return height;
end;

function SHOW_REMAIN_LIFE_TIME(ctrl)
	local elapsedSec = imcTime.GetAppTime() - ctrl:GetUserIValue("STARTSEC");
	local startSec = ctrl:GetUserIValue("REMAINSEC");
	startSec = startSec - elapsedSec;
	if 0 > startSec then
		ctrl:SetText(ScpArgMsg("LessThanItemLifeTime"));
		ctrl:SetFontName("red_18");
		ctrl:StopUpdateScript("SHOW_REMAIN_LIFE_TIME");
		return 0;
	end 
	
	local timeTxt = GET_TIME_TXT(startSec);
	ctrl:SetTextByKey("p_LifeTime", timeTxt );
	return 1;
end

function GET_ITEM_TOOLTIP_DESC(obj)

	local invDesc = GET_ITEM_DESC_BY_TOOLTIP_VALUE(obj);
	local byDescColumn = obj.Desc;
	if byDescColumn == 'None' then
		byDescColumn = "";
	end

	if invDesc == "" then
		invDesc = invDesc .. byDescColumn;
	else
		invDesc = invDesc .. "{nl}" .. byDescColumn;
	end	

	return invDesc;
end

-- propNameListë§?ê°?¸ì¤???¨ì. ë§ì¼ ?´í?´ë ê¸°í? ?±ë±???ì´?ì ?µì???ì?????µìê°ë¤???ë???µí©??string ?íê° ?ë??ê·¸ë¥ ë¦¬ì¤?¸ë¡ ê°?¸ì¤ê³??¶ì ???ì©.
function GET_ITEM_PROP_NAME_LIST(obj) 

	local tooltipValue = TryGetProp(obj, "TooltipValue");
	if tooltipValue == nil or tooltipValue == "None" then
		return "";
	end

	local sList = StringSplit(tooltipValue, "/");
	local propNameList = {};
	for i = 1, #sList do
		local propName = sList[i];
		if string.sub(propName, 1, 1) == "#" then
			local func = _G[string.sub(propName, 2, string.len(propName) )];
			func(obj, propNameList);
		else
			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["PropName"] = propName;
			propNameList[#propNameList]["PropValue"] = obj[propName];
		end
	end
	
	return propNameList

end

function GET_ITEM_DESC_BY_TOOLTIP_VALUE(obj)

	local propNameList = GET_ITEM_PROP_NAME_LIST(obj)
	local ret = "";

	for i = 1, #propNameList do
		local propName = propNameList[i]["PropName"];
		local propValue = propNameList[i]["PropValue"];
		local useOperator = propNameList[i]["UseOperator"];
		local title = propNameList[i]["Title"];

		local resultMsg = "";
		if title ~= nil then
			resultMsg = title;
		else
			if propName == "CoolDown" then
				propValue = math.floor(propValue / 1000);
				 resultMsg = ScpArgMsg("CoolDown : {Sec} Sec",'Sec', propValue);
			else
				if useOperator ~= nil and propValue > 0 then
					resultMsg = ClMsg(propName) .. " : " .."{img green_up_arrow 16 16}".. propValue;
				else
					resultMsg = ClMsg(propName) .. " : " .."{img red_down_arrow 16 16}".. propValue;
				end
			end
		end	

		if ret ~= "" then
			ret = ret .. "{nl}";
		end

		ret = ret .. resultMsg;
	end
	
	return ret;
end

function GETCARDTOOLTIP(obj, propNameList)
	
	local lhandSkill = GET_ITEM_LHAND_SKILL(obj);
	if lhandSkill ~= nil then
		local values = CreateTooltipValues();
		GET_SKILL_TOOLTIP_VALUES(lhandSkill, obj.Level, values);

		local tooltipCount = GetTooltipVecCount(values);
		if tooltipCount > 0 then
			local langType = "SkillStats";
			propNameList[#propNameList + 1] = {};
			propNameList[#propNameList]["Title"] = "{#FFFF22}" .. ClMsg(langType) .. "{/}";

			for i = 0 , tooltipCount - 1 do
				local key, value = GetTooltipInfoByIndex(values, i);
				propNameList[#propNameList + 1] = {};
				propNameList[#propNameList]["PropName"] = key;
				propNameList[#propNameList]["PropValue"] = value;
			end	
		end	
	end
end


function CLOSE_ITEM_TOOLTIP()

end


-- ???ï¿½ì???ï¿½í¬ï¿??ï¿½ì´?ï¿½ë ?ï¿½ì?????ï¿½ì©?ï¿½ë??
function SET_ITEM_TOOLTIP_ALL_TYPE(icon, invitem, className, strType, ItemType, index)
	
	if className == 'Scroll_SkillItem' then
		local obj = GetIES(invitem:GetObject());
		SET_TOOLTIP_SKILLSCROLL(icon, obj, nil, strType);
	else
		icon:SetTooltipType('wholeitem');
		if nil ~= strType and nil ~= ItemType and nil ~= index then
			icon:SetTooltipArg(strType, ItemType, index);
		end
	end
end

function SET_ITEM_TOOLTIP_TYPE(prop, itemID, itemCls, tooltipType)	
	local customTooltipScp = TryGetProp(itemCls, "CustomToolTip");
	if customTooltipScp ~= nil and customTooltipScp ~= "None" then
		customTooltipScp = _G[customTooltipScp];
		customTooltipScp(prop, itemCls, nil, tooltipType);
	else
		prop:SetTooltipType('wholeitem');
	end	
	
end

function SET_TOOLTIP_SKILLSCROLL(icon, obj, itemCls, strType)

	if nil == obj or obj.SkillType == 0 then
		return 0;
	end 

	SET_SKILL_TOOLTIP_BY_TYPE_LEVEL(icon, obj.SkillType, obj.SkillLevel);
	if strType ~= nil then
		local slot = icon:GetParent();
		if slot ~= nil then
			slot:SetUserValue("SCROLL_ITEM_ID", GetIESID(obj));
			slot:SetUserValue("SCROLL_ITEM_INVTYPE", strType);
		end
		
		icon:SetUserValue("SCROLL_ITEM_ID", GetIESID(obj));
		icon:SetUserValue("SCROLL_ITEM_INVTYPE", strType);
	end

	return 1;
end

-- ë§ì¼?ï¿½ì??ë¬ì¬?ï¿½ì ?ï¿½í¬ï¿??ï¿½ì¤?ï¿½ë¡
function SET_ITEM_DESC(value, desc, item)
	if desc == "None" then
		desc = "";
	end

	local obj = GetIES(item:GetObject());

	if nil ~= obj and
	   obj.ClassName == 'Scroll_SkillItem' then		
		local sklCls = GetClassByType("Skill", obj.SkillType)
		value:SetTextByKey("value", obj.SkillLevel .. " Level/ "..  sklCls.Name);
	else
		value:SetTextByKey("value", desc);
	end
end

function ICON_SET_INVENTORY_TOOLTIP(icon, invitem, strarg, itemCls)

	if strarg == nil then
		strarg = 'inven';
	end

	SET_ITEM_TOOLTIP_ALL_TYPE(icon, invitem, itemCls.ClassName, strarg, 0, invitem:GetIESID());

	local itemobj = GetIES(invitem:GetObject());
	if itemobj.ItemType == "Equip" and itemobj.MaxDur ~= 0 and itemobj.Dur == 0 then
		icon:SetColorTone("FFFF0000");
	end

end

function ICON_SET_EQUIPITEM_TOOLTIP(icon, equipitem, topParentFrameName)
	SET_ITEM_TOOLTIP_TYPE(icon, equipitem.type);
	icon:SetTooltipArg('equip', equipitem.type, equipitem:GetIESID());
	if topParentFrameName ~= nil then
		icon:SetTooltipTopParentFrame(topParentFrameName);
	end
end