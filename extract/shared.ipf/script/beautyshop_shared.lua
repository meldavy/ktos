function IS_COUPON_ITEM(item, type)
	if item.StringArg == type..'_Discount' then
		return true;
	end
	return false;
end

function GET_BEAUTYSHOP_STAMP_EXCHANGE_LIST()
	local list = {
		{
			stampCount = 5,
			rewardItemName = 'Beauty_Hair_Dye_30_CouponBox',
		},
		{
			stampCount = 10,
			rewardItemName = 'Beauty_Hair_Dye_50_CouponBox',
		},
		{
			stampCount = 15,
			rewardItemName = 'Beauty_Hair_Dye_100_CouponBox',
		},
	};

	return list;
end

function GET_STAMP_EXHCANGE_INFO(stampCnt)
	local list = GET_BEAUTYSHOP_STAMP_EXCHANGE_LIST();
	for i = 1, #list do
		local info = list[i];
		if info.stampCount == stampCnt then
			return info;
		end
	end
	return nil;
end

-- dateString Format "YYYY-MM-DD HH:mm:ss"
function CONVERT_DATESTR_TO_TIME_STAMP(dateString)
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = dateString:match(pattern)
	local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})

	return convertedTimestamp, runyear, runmonth, runday, runhour, runminute, runseconds;
end

function GET_CURRENT_SYSTEMTIME(isClient)
	if isClient == true then
		return geTime.GetServerSystemTime();
	end
	return GetDBTime();
end

function GET_CURRENT_DB_TIME_STAMP(isClient)
	local curTime = GET_CURRENT_SYSTEMTIME(isClient);
	local curSysTimeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d", curTime.wYear, curTime.wMonth, curTime.wDay, curTime.wHour, curTime.wMinute, curTime.wSecond)
	return CONVERT_DATESTR_TO_TIME_STAMP(curSysTimeStr)
end

function IS_BEAUTYSHOP_MAP(mapCls)
	if mapCls == nil then
		return false;
	end
	local mapName = mapCls.ClassName;	
	if mapName == 'c_fedimian' or mapName == 'c_Klaipe' or mapName == 'c_orsha' or mapName == 'c_barber_dress' then
		return true;
	end
	return false;
end

function GET_TOTAL_TP(accountObj)
	if accountObj == nil then
		return 0;
	end
	return accountObj.Medal + accountObj.GiftMedal + accountObj.PremiumMedal;
end

-- 아이템의 금액 반환(할인된 가격까지 계산함.)
function GET_BEAUTYSHOP_ITEM_PRICE(pc, info, hairCouponItem, dyeCouponItem)    
	if info.IDSpace == "Beauty_Shop_Hair" then
		return GET_BEAUTYSHOP_HAIR_PRICE(pc, info, hairCouponItem, dyeCouponItem);
	else
		return GET_BEAUTYSHOP_NORMAL_ITEM_PRICE(info);
	end
end

-- 헤어 아이템의 금액
function GET_BEAUTYSHOP_HAIR_PRICE(pc, info, hairCouponItem, dyeCouponItem)	
	local isSameCurrentHair = IS_SAME_CURRENT_HAIR(pc, info); -- 색은 비교하지 않는다.	
	local isSameCurrentHairColor = IS_SAME_CURRENT_HAIR_COLOR(pc, info);
	if isSameCurrentHair == true and isSameCurrentHairColor == true then
		-- 현재 자신의 헤어/염색이 같으면 뭔가 이상한거다.
		return -1
	end

	-- 헤어 가격 계산
	local hairPrice = 0
    local hairDiscountValue = 0;
    local dyeDiscountValue = 0;
	if isSameCurrentHair == false then	-- 구매하고자 하는 헤어가 현재 헤어와 같지 않을 때 금액 계산
		local cacheHairList = BEAUTYSHOP_MAKE_ITEM_CACHELIST(info.IDSpace);
			
		if cacheHairList[info.ClassName] ~= nil then
			local cls = GetClass(info.IDSpace, cacheHairList[info.ClassName])
			local price = TryGetProp(cls, "Price")
			local priceRatio = TryGetProp(cls, "PriceRatio")
			if price == nil then
				-- 정상이 아님.
				return -1
			end

			-- 기본 금액 설정
			hairPrice = price			

			-- 할인 적용 : nil 이면 적용안함.
			local priceRatioPer = 0
			if priceRatio ~= nil then
				priceRatioPer = priceRatio / 100
			end

			-- 쿠폰 적용 : 쿠폰은 헤어와 염색에만 적용된다는것을 명심해야 한다.
			local couponDiscountPer = GET_COUPON_DISCOUNT_PERCENT(info, hairCouponItem);
			-- 1차 기본 할인율 적용
            local priceRatioAppliedValue = (price * priceRatioPer);
			hairPrice = hairPrice - priceRatioAppliedValue;

			-- 2차 쿠폰 할인율 적용
            local beforeSecondDiscountValue = hairPrice;
            hairDiscountValue = (hairPrice * couponDiscountPer);
			hairPrice = hairPrice - hairDiscountValue;
			-- 모두 계산하고나서 floor
			hairPrice = math.floor(hairPrice)

            hairDiscountValue = math.floor(beforeSecondDiscountValue - hairPrice);
		end
	end

	-- 염색 가격 계산
	local colorDyePrice = 0
	local cacheColorList = BEAUTYSHOP_MAKE_HAIR_COLOR_CACHELIST(info.ClassName)
	if cacheColorList ~= nil then		
		local cls = GetClass("Hair_Dye_List", cacheColorList[info.ColorEngName])		
		if cls ~= nil then
			local price = TryGetProp(cls, "Price")
			local priceRatio = TryGetProp(cls, "PriceRatio")
			local defaultDye = TryGetProp(cls, "DefaultDye")
			if price == nil then
				-- 정상이 아님.
				return -1
			end

			colorDyePrice = price
			local isFreeDefault = false
			if defaultDye ~= nil then
				if defaultDye == "YES" and isSameCurrentHair == false then	 -- 다른머리에서 헤어 변경하면서 디폴트를 골랐을 경우.
					colorDyePrice = 0	
					isFreeDefault = true
				end
			end

			-- 무료가 아닐 때.
			if isFreeDefault == false then
				-- 할인 적용 : nil 이면 적용안함.
				local priceRatioPer =0
				if priceRatio ~= nil then
					priceRatioPer = priceRatio / 100
				end

				-- 쿠폰 적용 : 쿠폰은 헤어와 염색에만 적용된다는것을 명심해야 한다.
				local couponDiscountPer = GET_COUPON_DISCOUNT_PERCENT(info, dyeCouponItem) 

				-- 1차 기본 할인율 적용
                local priceRatioAppliedValue = (price * priceRatioPer);
				colorDyePrice = colorDyePrice - priceRatioAppliedValue;

				-- 2차 쿠폰 할인율 적용
                local beforeSecondDiscountValue = colorDyePrice;
                dyeDiscountValue = (colorDyePrice * couponDiscountPer);
				colorDyePrice = colorDyePrice - dyeDiscountValue;
				-- 모두 계산하고나서 floor
				colorDyePrice = math.floor(colorDyePrice);

                -- for log: 할인을 두 단계로 적용해두고 마지막에만 floor 처리를 하니까.. 정밀도 문제가 발생해요.. 끔찍해요..
                dyeDiscountValue = math.floor(beforeSecondDiscountValue - colorDyePrice);
			end
		end
	end
	return hairPrice + colorDyePrice, hairPrice, colorDyePrice, hairDiscountValue, dyeDiscountValue;
end

function IS_SAME_CURRENT_HAIR(pc, info)	
	local itemobj = GetClass("Item", info.ClassName)
	if itemobj == nil then
		IMC_LOG("INFO_NORMAL", "IS_SAME_CURRENT_HAIR: itemobj is nil- ClassName["..info.ClassName..']');
		return false;
	end
	
	return IS_SAME_PC_ETC_PROPERTY(pc, "StartHairName", itemobj.StringArg)
end

function IS_SAME_PC_ETC_PROPERTY(pc, etcPropName, compareName)
	local pcetc = nil;
	if IsServerObj(pc) == 1 then
		pcetc = GetETCObject(pc);
	else
		pcetc = GetMyEtcObject();
	end
	if pcetc == nil then
		IMC_LOG("INFO_NORMAL", "IS_SAME_PC_ETC_PROPERTY: etcObject is nil");
		return false
	end

	local propValue = TryGetProp(pcetc, etcPropName);
	if propValue == nil then
		IMC_LOG("INFO_NORMAL", "IS_SAME_PC_ETC_PROPERTY: etcobject propValue is nil- propName["..etcPropName..']');
		return false
	end

	if compareName == propValue then
		return true
	end

	return false
end

function BEAUTYSHOP_MAKE_ITEM_CACHELIST(IDSpace)	
	local cacheList ={}
	local clsList, cnt = GetClassList(IDSpace);
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if cls ~= nil then
			if cacheList[cls.ItemClassName] == nil then
				cacheList[cls.ItemClassName] = cls.ClassName
			end
		end
	end

	return cacheList
end

function GET_BEAUTYSHOP_NORMAL_ITEM_PRICE(info)
	local cacheList =  BEAUTYSHOP_MAKE_ITEM_CACHELIST(info.IDSpace);
	local totalPrice = 0;
	if cacheList[info.ClassName] ~= nil then
		local cls = GetClass(info.IDSpace, cacheList[info.ClassName]);
		if cls ~= nil then
			local price = TryGetProp(cls, "Price")
			local priceRatio = TryGetProp(cls, "PriceRatio")
			if price == nil then
				-- 정상이 아님.
				return -1
			end

			-- 기본 금액 설정
			totalPrice = price

			-- 할인 적용 : nil 이면 적용안함.
			if priceRatio ~= nil then
				local per = priceRatio / 100
				totalPrice = totalPrice - math.floor((price * per) + 0.5) 
			end
		end
	end
	return totalPrice;
end

function IS_SAME_CURRENT_HAIR_COLOR(pc, info)
	return IS_SAME_PC_ETC_PROPERTY(pc, "StartHairColorName", info.ColorEngName);
end

function GET_COUPON_DISCOUNT_PERCENT(info, couponItem) 
	if couponItem == nil then
		return 0;
	end
	return couponItem.NumberArg1 / 100;
end

function BEAUTYSHOP_MAKE_HAIR_COLOR_CACHELIST(ItemClassName)
	local cacheList ={}

	local clsList, cnt = GetClassList("Hair_Dye_List");
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if cls ~= nil then
			local group = TryGetProp(cls, "Group")
			local dyeName = TryGetProp(cls, "DyeName")
			if group ~= nil and dyeName ~= nil then
				if group == ItemClassName then
					cacheList[dyeName] = cls.ClassName
				end
			end
		end
	end

	return cacheList
end

function IS_CURREUNT_IN_PERIOD(startDateString, endDateString, isClient)
	local startTimeStamp = CONVERT_DATESTR_TO_TIME_STAMP(startDateString);
	local endTimeStamp = CONVERT_DATESTR_TO_TIME_STAMP(endDateString);
	local currentTimeStamp = GET_CURRENT_DB_TIME_STAMP(isClient);
	if startTimeStamp > currentTimeStamp or currentTimeStamp > endTimeStamp then
		return false;
	end
	return true;
end