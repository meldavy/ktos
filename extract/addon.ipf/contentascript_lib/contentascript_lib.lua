-- addon\contentascript_lib.lua


function GetUITutoProg(uituto)
	if session.shop.GetEventUserType() == 0 then return 100 end

	if uituto == nil then return end

	local aObj = GetMyAccountObj()
	if aObj == nil then return end

	return TryGetProp(aObj, uituto)
end