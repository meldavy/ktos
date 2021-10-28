function SELECT_MGAME_BUFF_SOLO_ON_INIT(addon, frame)
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO", "ON_SELECT_MGAME_BUFF_SOLO_OPEN");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_END", "ON_SELECT_MGAME_BUFF_SOLO_END");
end


function SELECT_MGAME_BUFF_SOLO_OPEN(frame)
end

function SELECT_MGAME_BUFF_SOLO_CLOSE(frame)
end

function ON_SELECT_MGAME_BUFF_SOLO_OPEN(frame,msg,argStr,argNum)
	local buffList = StringSplit(argStr,'/')
	INIT_SELECT_MGAME_BUFF(frame,buffList,argNum)
	frame:ShowWindow(1)
end

function ON_SELECT_MGAME_BUFF_SOLO_END(frame,msg,argStr,argNum)
	frame:ShowWindow(0)
end

function ON_SELECT_MGAME_BUFF_ICON_CLICK(parent,ctrl,argStr,argNum)
	local frame = parent:GetTopParentFrame()
	for i = 1,5 do
		local ctrlSet = GET_CHILD_RECURSIVELY(frame,"BUFF_CTRL_"..i)
		local click_pic = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_on")
		click_pic:EnableHitTest(0)
		click_pic:SetVisible(0)
	end
	if argNum == nil or argNum <= 0 then
		return
	end
	do
		local click_pic = GET_CHILD(parent,"buff_select_on")
		click_pic:EnableHitTest(1)
		click_pic:SetVisible(1)
		frame:SetUserValue("SELECT_MGAME_BUFF",argNum)
	end
end

function ON_SELECT_MGAME_BUFF_SOLO_SELECT_BTN(parent,ctrl)
	local frame = parent:GetTopParentFrame()
	local buffType = frame:GetUserIValue("SELECT_MGAME_BUFF")
	SelectSoloBuff(buffType)
	frame:SetEnable(0)
	frame:ReserveScript("ENABLE_FRAME", 0.5,1);
end