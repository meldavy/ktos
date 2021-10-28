function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_INIT");
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_INIT(frame)
	local btn1_gb = GET_CHILD(frame, "btn1_gb");
	btn1_gb:ShowWindow(0);
	local btn2_gb = GET_CHILD(frame, "btn2_gb");
	btn2_gb:ShowWindow(0);

	MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON1(frame, btn1_gb);
	MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON2(frame, btn2_gb);
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON1(frame, gb)
	local btn = GET_CHILD(gb, "openBtn");
	local title = GET_CHILD(gb, "title");
	-- SEASON_SERVER
	-- if IS_SEASON_SERVER() == "YES" then
	-- 	btn:SetImage("god_roulette_coin_entrance");
	-- 	btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- 	btn:SetEventScriptArgNumber(ui.LBUTTONUP, 2);
		
	-- 	title:SetTextByKey("value", ClMsg("GODDESS_ROULETTE"));
	-- 	gb:ShowWindow(1);
	-- 	return;
	-- end

	-- FLEX_BOX
	-- if IS_SEASON_SERVER() == "NO"  then
	-- 	btn:SetImage("flex_box_btn");
	-- 	btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- 	btn:SetEventScriptArgNumber(ui.LBUTTONUP, 3);
		
	-- 	title:SetTextByKey("value", ClMsg("FLEX!"));
	-- 	gb:ShowWindow(1);
	-- 	return;
	-- end
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON2(frame, gb)
	local btn = GET_CHILD(gb, "openBtn2");
	local title = GET_CHILD(gb, "title2");
	
	-- YOUR_MASTER
	-- btn:SetImage("your_master_activity_btn");
	-- btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- btn:SetEventScriptArgNumber(ui.LBUTTONUP, 4);
	-- title:SetTextByKey("value", ClMsg("EVENT_YOUR_MASTER_TITLE"));
    -- gb:ShowWindow(1);

    -- -- EVENT_2009_FULLMOON
    -- btn:SetImage("2009Chursok_btn")
    -- btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- btn:SetEventScriptArgNumber(ui.LBUTTONUP, 5);
	-- title:SetTextByKey("value", ClMsg("EVENT_2009_FULLMOON_TITLE"));
    -- gb:ShowWindow(1);
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK(parent, ctrl, argStr, type)	
	local frame = ui.GetFrame("event_progress_check");
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0);
		return;
	end

	EVENT_PROGRESS_CHECK_OPEN_COMMAND("", "", "", type);
end