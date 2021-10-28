function INDUNINFO_CLASS_SELECTOR_UI_OPEN(frame)
	local induninfo = ui.GetFrame('induninfo')
	local x = induninfo:GetX() - frame:GetWidth()
	local y = induninfo:GetY() + (induninfo:GetHeight() - frame:GetHeight())
	frame:SetOffset(x,y)
	local class_selector_btn = GET_CHILD_RECURSIVELY(induninfo,"class_selector_btn")
	class_selector_btn:SetImage("details_classes_rank_btn02")
end

function INDUNINFO_CLASS_SELECTOR_UI_CLOSE(frame)
	frame:ShowWindow(0)
	local induninfo = ui.GetFrame('induninfo')
	local class_selector_btn = GET_CHILD_RECURSIVELY(induninfo,"class_selector_btn")
	class_selector_btn:SetImage("details_classes_rank_btn")
end

function INDUNINFO_CLASS_SELECTOR_SELECT_JOB(parent, ctrl)
end

function INDUNINFO_CLASS_SELECTOR_FILL_CLASS(jobID)
	local frame = ui.GetFrame('induninfo_class_selector');
	local classList = GET_CHILD_RECURSIVELY(frame,"classList");
	classList:RemoveAllChild()
	local baseJobID = math.floor(jobID/1000)*1000+1
	local job_list = GET_JOB_LIST(baseJobID)

	for i=1,#job_list do
		local jobClsID = job_list[i].ClassID

		local width = 80
		local height = 80

		local x = (i-1)%3*width
		local y = math.floor((i-1)/3)*height - 20
		local ctrlSet = classList:CreateOrGetControlSet("induninfo_class_selector_job_btn", "list_job_" .. i, ui.LEFT, ui.TOP, x, y, 0, 0);
		local icon = GET_CHILD(ctrlSet, "icon_pic");
		icon:SetImage(job_list[i].Icon);
		icon:SetColorTone("FF444444");
		if jobID == jobClsID then
			icon:SetColorTone("FFFFFFFF");
		end
		local select_btn = GET_CHILD(ctrlSet,"select_btn")
		select_btn:SetTooltipType('adventure_book_job_info');
		select_btn:SetTooltipArg(jobClsID, 0, 0);
		select_btn:SetEventScriptArgNumber(ui.LBUTTONUP, jobClsID);
	end
end

function GET_JOB_LIST(baseJobID)
	local retTable = {}

	local list, cnt = GetClassList("Job");
	local baseCls = GetClassByTypeFromList(list,baseJobID);
	if baseCls == nil then
		return retTable
	end
	local ctrlType = TryGetProp(baseCls, "CtrlType")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list,i);
		if TryGetProp(cls, "CtrlType") == ctrlType and TryGetProp(cls, "Rank") <= 2 then
			table.insert(retTable,cls)
		end
	end
	return retTable;
end

function INDUNINFO_CLASS_SELECT(parent,ctrl,argStr,jobID)
	local frame = parent:GetTopParentFrame()
	local classList = GET_CHILD_RECURSIVELY(frame,"classList");
	local i = 1
	while true do
		local ctrlSet = classList:GetControlSet("induninfo_class_selector_job_btn", "list_job_" .. i);
		if ctrlSet == nil then
			break
		end
		local icon = GET_CHILD(ctrlSet, "icon_pic");
		icon:SetColorTone("FF444444")
		i = i + 1
	end
	local icon = GET_CHILD(parent,"icon_pic")
	icon:SetColorTone("FFFFFFFF")

	local week_num =  WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
	weekly_boss.RequestWeeklyBossRankingInfoList(week_num, jobID);
	frame:SetEnable(0)
	ReserveScript("INDUNINFO_CLASS_SELECTOR_UNFREEZE()", 1);
end

function INDUNINFO_CLASS_SELECTOR_UNFREEZE()
	local frame = ui.GetFrame("induninfo_class_selector")
	frame:SetEnable(1)
end