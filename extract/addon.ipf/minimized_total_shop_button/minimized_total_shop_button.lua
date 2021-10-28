function MINIMIZED_TOTAL_SHOP_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_TOTAL_SHOP_BUTTON_OPEN_CHECK');
end

function MINIMIZED_TOTAL_SHOP_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);	
    if session.world.IsIntegrateServer() == true then
        frame:ShowWindow(0);
    else
    	frame:ShowWindow(1);

		local mapprop = session.GetCurrentMapProp();
		local mapCls = GetClassByType("Map", mapprop.type);
	
		local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
		if housingPlaceClass ~= nil then
			local margin = frame:GetMargin()
			frame:SetMargin(margin.left, 163, margin.right, margin.bottom)
		end
	end
end

local function SHOW_MINIMIZED_BUTTON(frame)
	local pvp_button = ui.GetFrame('minimized_pvpmine_shop_button')
	local ceritificate_button = ui.GetFrame('minimized_certificate_shop_button')

	if frame ~= nil and frame:IsVisible() == 1 then
		frame:ShowWindow(0)	
		pvp_button:ShowWindow(0)
		ceritificate_button:ShowWindow(0)
	else
		frame:ShowWindow(1)
		frame:GetMargin()
		frame:SetMargin(0, 71, 355, 0)

		pvp_button:ShowWindow(1)
		ceritificate_button:ShowWindow(1)

		local mapprop = session.GetCurrentMapProp()
		local mapCls = GetClassByType("Map", mapprop.type)
	
		local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName)
		if housingPlaceClass ~= nil then
			frame:SetMargin(0, 177, 355, 0)
			pvp_button:SetMargin(0, 183, 413, 0)
			ceritificate_button:SetMargin(0, 183, 458, 0)
		end
	end

end

function MINIMIZED_TOTAL_SHOP_BUTTON_CLICK(parent, ctrl)
	local frame = ui.GetFrame('minimized_folding_button')
	SHOW_MINIMIZED_BUTTON(frame)
end
