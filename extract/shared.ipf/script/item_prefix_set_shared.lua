function IS_VALID_ITEM_FOR_GIVING_PREFIX(item)
    if TryGetProp(item, 'LegendGroup', 'None') == 'None' then
        return false;        
    end

    return true;
end

function GET_LEGEND_PREFIX_MATERIAL_ITEM_NAME()
    return 'Legend_ExpPotion';
end

function GET_LEGEND_PREFIX_NEED_MATERIAL_COUNT(item)
    if item == nil then
        return 0;
    end

    if item.GroupName == 'Armor' then
        return 1;
    end
    return 4;
end

function GET_LEGEND_PREFIX_ITEM_NAME(item)
	local nameText = item.Name;
	if TryGetProp(item, 'LegendPrefix', 'None') ~= 'None' then
		local prefixCls = GetClass('LegendSetItem', item.LegendPrefix);
        if prefixCls ~= nil then
		  nameText = prefixCls.Name..' '..nameText;
        end
	end
	return nameText;
end

function GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemObj)
    return TryGetProp(itemObj, "StringArg");
end

function GET_LEGENDEXPPOTION_ICON_IMAGE(itemObj)
    local curExp, maxExp = itemObj.ItemExp, itemObj.NumberArg1;
    if GetExpOrbGuidStr() == GetIESID(itemObj) then
		curExp = GetExpOrbFillingExp();
    end
	if curExp >= maxExp then
		return GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemObj);
	end
    local emptyImage = TryGetProp(itemObj, "TooltipImage");
	return emptyImage;
end
