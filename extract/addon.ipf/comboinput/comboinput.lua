function COMBOINPUT_ON_INIT(addon, frame)
	addon:RegisterMsg('COMBOINPUT_START', 'ON_COMBOINPUT_START')
	addon:RegisterMsg('COMBOINPUT_SUCCESS', 'ON_COMBOINPUT_SUCCESS')
	addon:RegisterMsg('COMBOINPUT_FAILED', 'ON_COMBOINPUT_FAILED')
	addon:RegisterMsg('COMBOINPUT_END', 'ON_COMBOINPUT_END')
end

function COMBOINPUT_OPEN(frame)
	COMBOINPUT_CANCEL_SETTING(frame)
end

function COMBOINPUT_CLOSE(frame)
	local combo_timer = GET_CHILD_RECURSIVELY(frame, 'combo_timer')
	combo_timer:StopUpdateScript('COMBOINPUT_TIME_UPDATE')
end

function COMBOINPUT_CANCEL_SETTING(frame)
    -- cancel key
    local cancel_text = GET_CHILD_RECURSIVELY(frame, 'cancel_text')
    config.InitHotKeyByCurrentUIMode('Battle')

    local jumpKeyIdx = config.GetHotKeyElementIndex('ID', 'Jump')
    local jumpKey = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, 'Key')
    if IsJoyStickMode() == 1 then
        jumpKey = 'X'
    end
    
    if string.find(jumpKey, 'NUMPAD') ~= nil then
        local find_start, find_end = string.find(jumpKey, 'NUMPAD')
        jumpKey = string.sub(jumpKey, find_end + 1, string.len(jumpKey))
    end

    local useShift = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, 'UseShift')
    local useAlt = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, 'UseAlt')
    local useCtrl = config.GetHotKeyElementAttributeForConfig(jumpKeyIdx, 'UseCtrl')

    local KEY_IMG_SIZE = tonumber(frame:GetUserConfig('KEY_IMG_SIZE'))
    local imgName = 'key_' .. jumpKey
    local originImgWidth = ui.GetImageWidth(imgName)
    local originImgHeight = ui.GetImageHeight(imgName)
    local sizeAmendCoeff = KEY_IMG_SIZE / originImgWidth

    local jumpKeyImg = string.format('{img %s %d %d}', imgName, KEY_IMG_SIZE, originImgHeight * sizeAmendCoeff)

    if useShift == 'YES' then
        jumpKeyImg = string.format('{img SHIFT %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE) .. jumpKeyImg
    end

    if useAlt == 'YES' then
        jumpKeyImg = string.format('{img alt %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE) .. jumpKeyImg
    end

    if useCtrl == 'YES' then
        jumpKeyImg = string.format('{img ctrl %d %d}', KEY_IMG_SIZE, KEY_IMG_SIZE) .. jumpKeyImg
    end

    if IsJoyStickMode() == 0 then
        cancel_text:SetTextByKey('img', jumpKeyImg)
    end

    if IsJoyStickMode() == 1 then
        jumpKeyImg = string.format('{img %s %d %d}', 'a_button', KEY_IMG_SIZE, originImgHeight * sizeAmendCoeff)
        cancel_text:SetTextByKey('img', jumpKeyImg)
    end
end

function ON_COMBOINPUT_START(frame, msg, arg_str, arg_num)
	if arg_str == nil then return end

	local key_list = SCR_STRING_CUT(arg_str, ';')
	if #key_list <= 0 then return end

	frame:SetUserValue('COMBO_SIZE', #key_list)

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	bg:RemoveAllChild()
	for i = 1, #key_list do
		local ctrl = bg:CreateOrGetControlSet('comboinput_key', 'KEY_' .. i, (i - 1) * 80, 0)
		if ctrl ~= nil then
			local keycap = GET_CHILD_RECURSIVELY(ctrl, 'keycap')
			keycap:SetImage(key_list[i])
		end
	end

	bg:Resize(#key_list * 64 + (#key_list - 1) * 16, 64)

	local combo_timer = GET_CHILD_RECURSIVELY(frame, 'combo_timer')
	combo_timer:StopUpdateScript('COMBOINPUT_TIME_UPDATE')
	combo_timer:RunUpdateScript('COMBOINPUT_TIME_UPDATE')
	combo_timer:SetUserValue('COMBO_START_TIME', tostring(imcTime.GetAppTimeMS()))
	combo_timer:SetUserValue('COMBO_LIMIT_TIME', tostring(arg_num))

	ui.OpenFrame('comboinput')
end

function ON_COMBOINPUT_SUCCESS(frame, msg, arg_str, arg_num)
	local ctrl = GET_CHILD_RECURSIVELY(frame, 'KEY_' .. arg_num)
	if ctrl == nil then return end

	local combo_size = frame:GetUserIValue('COMBO_SIZE')
	if combo_size <= 0 then return end

	local keycap = GET_CHILD_RECURSIVELY(ctrl, 'keycap')
	if keycap ~= nil then
		if arg_num < combo_size then
			local input_sound = frame:GetUserConfig('KEY_INPUT_SOUNT')
			imcSound.PlaySoundEvent(input_sound)
		end
		keycap:SetAlpha(30)
	end
end

function ON_COMBOINPUT_FAILED(frame, msg, arg_str, arg_num)
	local combo_size = frame:GetUserIValue('COMBO_SIZE')
	for i = 1, combo_size do
		local ctrl = GET_CHILD_RECURSIVELY(frame, 'KEY_' .. i)
		if ctrl ~= nil then
			local keycap = GET_CHILD_RECURSIVELY(ctrl, 'keycap')
			if keycap ~= nil then
				local input_sound = frame:GetUserConfig('KEY_INPUT_SOUNT')
				imcSound.PlaySoundEvent(input_sound)
				keycap:SetAlpha(100)
			end
		end
	end
end

function ON_COMBOINPUT_END(frame, msg, arg_str, arg_num)
	if arg_num == 1 then
		local input_sound = frame:GetUserConfig('LAST_KEY_INPUT_SOUNT')
		imcSound.PlaySoundEvent(input_sound)
	end
	ui.CloseFrame('comboinput')
end

function COMBOINPUT_TIME_UPDATE(time_text)
	local frame = time_text:GetTopParentFrame()
	if frame == nil then return end

	local start_time = time_text:GetUserValue('COMBO_START_TIME')
	if start_time == nil or start_time == 'None' then
		return 0
	end

	local limit_time = time_text:GetUserValue('COMBO_LIMIT_TIME')
	if limit_time == nil or limit_time == 'None' then
		return 0
	end

	
	limit_time = math.floor(tonumber(limit_time) / 100)
	
	local cur_time = imcTime.GetAppTimeMS()
	local time_diff = math.floor((cur_time - tonumber(start_time)) / 100)
	local remain_time = limit_time - time_diff
	if remain_time < 0 then
		time_text:SetTextByKey('time', '0.0')
		return 0
	end
	
	local timer_gauge = GET_CHILD_RECURSIVELY(frame, 'combo_timer_gauge')
	local half_time = limit_time / 2
	local quarter_time = limit_time / 4
	if remain_time <= quarter_time then
		timer_gauge:SetSkinName('challenge_gauge_lv3')
	elseif remain_time <= half_time then
		timer_gauge:SetSkinName('challenge_gauge_lv2')
	else
		timer_gauge:SetSkinName('challenge_gauge_lv1')
	end	
	timer_gauge:SetPoint(remain_time, limit_time)

	local sec = math.floor(remain_time / 10)
	local r = remain_time % 10
	local time_str = string.format('%d.%d', sec, r)
	time_text:SetTextByKey('time', time_str)

	return 1
end