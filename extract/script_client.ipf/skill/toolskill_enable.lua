-- toolskill_enable.lua

function SKL_CHECK_ISJUMPING_C(actor, skl)
    if 1 == actor:IsOnGround() then
        return 0;
    end

    return 1;
end

function SKL_CHK_OOBE_C(actor, skl)

    local oobeActor = geMCC.GetOOBEActor();
    if oobeActor == nil then
        return 0;
    end
    
    return 1;
end

function SKL_CHECK_FORMATION_STATE_C(actor, skl, checkValue)
    
    if actor:GetUserSValue("FORMATION_NAME") == "None" then
        if checkValue == 1 then
            return 0;
        end

        return 1;
    end

    if checkValue == 1 then
        return 1;
    end

    return 0;
end

function SKL_CHECK_BUFF_STATE_C(actor, skl, buffName)
    local myHandle = session.GetMyHandle();
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        return 1;
    end

    return 0;
end

function SKL_CHECK_BUFF_NO_STATE_C(actor, skl, buffName)
    local myHandle = session.GetMyHandle();
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        return 0;
    end
    
    return 1;
end

function SKL_CHECK_BRING_COMPANION_C(self, skl, jobID)
    local hawk = session.pet.GetSummonedPet(jobID);
    if hawk == nil then
        return 0;
    end

    return 1;
end

function SKL_CHECK_MOVEING_C(actor, skl)
    return control.IsMoving(false); -- checkSkillState = false
end

function SKL_CHECK_RIDING_COMPANION_C(actor, skl)

    local myActor = GetMyActor();
    if myActor:GetVehicleState() == true then
        return 1;
    end

    return 0;

end

function SKL_CHECK_FORMATION_NAME_C(actor, skl, checkName)
    
    local name = actor:GetUserSValue("FORMATION_NAME");
    if name == "None" or name == "" or checkName == name then
        return 0;
    end

    return 1;
end

function SKL_CHECK_EXPROP_OBJ_RANGE_C(actor, skl, propName, propValue, range)
    
    local obj = world.GetMonsterByUserValue(propName, propValue, range);
    if obj == nil then
        return 0;
    end

    return 1;

end


function SKL_CHECK_BOSS_CARD_C(self, skl)
    local etc = GetMyEtcObject();
    if etc == nil then
        return 0;
    end

    local bosscardCount = 0;
    for i = 1, 4 do
        local cardGUID = etc["Necro_bosscardGUID" .. i];
        local invItem = nil;

        if cardGUID ~= 'None' and cardGUID ~= "" then
             invItem = session.GetInvItemByGuid(cardGUID);
        end

        if invItem ~= nil then
            bosscardCount = bosscardCount + 1;
        end
    end

    if bosscardCount < 1 then
        return 0;
    end

    local mymapname = session.GetMapName();
    local map = GetClass("Map", mymapname);
    if nil == map then
        return 0;
    end
    
    if 'City' == map.MapType then
        return 0;
    end

    return 1;
end

function SKL_CHECK_DPARTS_COUNT_C(self, skl, count)
    if skl.ClassName == "Necromancer_RaiseSkullarcher" or skl.ClassName == "Necromancer_RaiseDead" or skl.ClassName == "Necromancer_RaiseSkullwizard" then
        local mymapname = session.GetMapName();
        local map = GetClass("Map", mymapname);
        if nil == map then
            return 0;
        end
        
        if 'City' == map.MapType then
            return 0;
        end
    end

    local etc = GetMyEtcObject();
    if etc == nil then
        return 0;
    end

    local haveParts = 0;
    haveParts = etc["Necro_DeadPartsCnt"];

    if haveParts < count then
        return 0;
    end

    return 1;

end

function CHECK_IS_VILLAGE_C(actor, skl)
    local mymapname = session.GetMapName();
    local map = GetClass("Map", mymapname);
    if nil == map then
        return 0;
    end
    
    if map.isVillage == "YES" then
        return 0;
    end
    
    return 1;

end

function CHECK_IS_PVP_C(actor, skl)
    if IsPVPField(self) ~= 1 then
        return 0;
    end
    
    return 1;
end

function CHECK_IS_PVE_C(actor, skl)
    if IsPVPField(self) ~= 0 then
        return 0;
    end
    
    return 1;
end

function CHECK_IS_GUIILDCOLONY_MAP_C(actor, skl)
    local mymapname = session.GetMapName();
    local map = GetClass("Map", mymapname);
    if nil == map then
        return 0;
    end
    
    if map.Group == "GuildColony" then
        return 0;
    end
    
    return 1;

end


function SKL_CHECK_CHECK_BUFF_C(actor, skl, buffName)

    if actor:GetBuff():GetBuff(buffName) == nil then
        return 0;
    end
    
    if buffName == 'IronHook' then
        local abil = session.GetAbilityByName('Corsair7')
        if nil == abil then
            return 1;
        end
        local obj = GetIES(abil:GetObject());
        if 1 == obj.ActiveState then
            return 0;
        end
    end

    return 1;
end

function SKL_CHECK_CHECK_NOBUFF_C(actor, skl, buffName)

    if actor:GetBuff():GetBuff(buffName) == nil then
        return 1;
    end
    
    return 0;
end

function SKL_CHECK_NEAR_PAD_C(actor, skl, padName, isExist, range, padStyle)
    local pos = actor:GetPos();
    local padCount = SelectPadCount_C(actor, padName, pos.x, pos.y, pos.z, range, padStyle);

    if isExist == 0 then
        if padCount == 0 then
            return 1;
        end

        return 0;
    else
        if padCount > 0 then
            return 1;
        end

        return 0;
    end

    return 0;
end

function SKL_CHECK_EXARGOBJECT_C(self, skl, objName)
    if 0 == geClientSkill.GetExArgObject(objName) then
        return 0;
    end

    return 1;
end


function SKL_CHECK_ITEM_C(self, skill, item, spend)

    local invItem = session.GetInvItemByName(item);
    local itemCnt = 0
    if invItem ~= nil then
        itemCnt = invItem.count;
    end

    if itemCnt  < spend then
        --SysMsg(self, "Item", ScpArgMsg("Auto__aiTemi_PilyoLyange_MoJaLapNiDa"));
        return 0;
    end
        
    return 1;
end


function SKL_CHECK_VIS_C(self, skill, spend)
    local MyMoneyCount = 0;
    local invItem = session.GetInvItemByName('Vis');
    if invItem ~= nil then
        MyMoneyCount = invItem.count;
    end

    if MyMoneyCount < spend then
        --SysMsg(self, "Item", ScpArgMsg("NOT ENOUGH MONEY"));
        return 0;
    end
    
    --RunScript('SKL_SPEND_MONEY', self, spend)
    
    return 1;

end


function SKL_CHK_CLAYMORE(self, skill)

    local d = geClientSkill.GetCondSkillIndex(30302);
    
    if d > 0 then
        return 1;
    end

    local invItem = session.GetInvItemByName("misc_trapkit");
    if nil == invItem then
        return 0;
    end

    if true == invItem.isLockState then
        return 0;
    end

    local itemCnt = 0
    if invItem ~= nil then
        itemCnt = invItem.count;
    end

    if itemCnt  < 1 then
        --SysMsg(self, "Item", ScpArgMsg("Auto__aiTemi_PilyoLyange_MoJaLapNiDa"));
        return 0;
    end
        
    return 1;
end


function SKL_CHECK_BY_SCRIPT_C(self, skill, funcName)
    local func = _G[funcName];
    return func(self, skill);

end



function HAWK_SKILL_PRE_CHECK_C(self, skill)
    
    local job_id = 3014;
    local hawk = session.pet.GetSummonedPet(job_id);
    
    if hawk == nil then
        return 0;
    end
--
--    local hawk = control.GetMyCompanionActor();
--    
--    if nil == hawk then
--        return 0
--    end

--  local hawk = GetSummonedPet(self, PET_HAWK_JOBID);
--  if hawk == nil then
--      return 0;
--  end

--  local flyingAway = GetExProp(hawk, "FLYING_AWAY");
--  if flyingAway == 1 then
--      return 0;
--  end
--  
--  local _hide = IsHide(hawk);
--  if _hide == 1 then
--      return 0;
--  end

    return 1;
end

function PET_SKILL_PRE_CHECK_C(self, skill)
    local job_id = 0;
    local pet = session.pet.GetSummonedPet(job_id);
    
    if pet == nil then
        return 0;
    end
    
	local companionClass = GetClass('Companion', pet.ClassName);
	if companionClass ~= nil then
		if TryGetProp(companionClass, 'RidingOnly') == 'YES' then
	        SendSysMsg(self, 'ThisCompanionIs NotPossible');
	        return 0;
		end
	end
    
--    local job_id = 0;
--    
--    local petList = GetSummonedPetList(self);
--    if petList ~= nil and #petList >= 1 then
--        local classList = GetClassList("Companion");
--        for i = 1, #petList do
--            local class = GetClassByNameFromList(classList, petList[i].ClassName)
--            if class ~= nil then
--                if class.JobID == job_id then
--                    return 1;
--                end
--            end
--        end
--    end
--    
--    SendSysMsg(self, 'SummonedPetDoesNotExist');
--    return 0;
end

function SKL_CHECK_ACTIVE_ABILITY_C(self, skill, abilName)
    local abil = session.GetAbilityByName(abilName);
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if TryGetProp(abilObj, "ActiveState") == 1 then
            return 0;
        end
    end

    return 1;
end

function SKL_CHECK_USE_TEMPLER_SKILL_C(actor, skl, abilName)
    if actor:GetBuff():GetBuff("RidingCompanion") == nil then
        local obj = nil
        local abil = session.GetAbilityByName(abilName);
        if abil ~= nil then
            obj = GetIES(abil:GetObject());
        end
        
        if abil == nil or TryGetProp(obj, "ActiveState", 0) == 0 then
            return 0;
        else
            return 1;
        end
    end
    
    return 1;
end

function SCR_CRUSADER_CHECK_CHECK_BUFF_C(actor, skl, buffName)
    if actor:GetBuff():GetBuff("GoddessProtection_Buff") == nil and actor:GetBuff():GetBuff("GoddessPunishment_Buff") == nil and actor:GetBuff():GetBuff("GoddessBlessing_Buff") == nil then
        return 0;
    end

    return 1;
end

function SCR_BOKOR_CHECK_BUFF_C(actor, skl, buffName)
    local getBuff = actor:GetBuff():GetBuff("PowerOfDarkness_Buff")
    if getBuff ~= nil then
        local over = getBuff.over
        if over >= 10 then
            return 1;
        end
    end
    
    return 0;
end

function SCR_BOKOR_CHECK_BUFF_C_Mackangdal(actor, skl, buffName)
    local getBuff = actor:GetBuff():GetBuff("PowerOfDarkness_Buff")
    if getBuff ~= nil then
        local over = getBuff.over
        if over >= 1 then
            return 1;
        end
    end
    
    return 0;
end

function SKL_CHECK_USE_RAMPAGE_SKILL_C(actor, skl, abilName)
    if actor:GetBuff():GetBuff("RidingCompanion") ~= nil then
        local obj = nil
        local abil = session.GetAbilityByName(abilName);
        if abil ~= nil then
            obj = GetIES(abil:GetObject());
        end
        
        if abil == nil or TryGetProp(obj, "ActiveState", 0) == 0 then
            return 1;
        else
            return 0;
        end
    end
    
    return 1;
end

function SCR_BULLETMARKER_CHECK_BUFFOVER_C(actor, skl, buffName)
    local getbuff = actor:GetBuff():GetBuff("Overheating_Buff")
    if getbuff ~= nil then
        local over = getbuff.over
        if over >= 4 then
            return 1;
        end
    end
    return 0;
end

function SCR_CHECK_JOUST_ABIL_C()
    local abil = session.GetAbilityByName('Lancer28')
    if abil ~= nil then
        obj = GetIES(abil:GetObject())
    end
    
    if abil ~= nil and TryGetProp(obj, "ActiveState", 0) == 1 then
        return 1
    else
        return 0
    end
end

function SCR_CHECK_SPIRALARROW_ABIL_C()
    local abil = session.GetAbilityByName('Ranger44')
    if abil ~= nil then
        obj = GetIES(abil:GetObject())
    end
    
    if abil ~= nil and TryGetProp(obj, "ActiveState", 0) == 1 then
        return 1
    else
        return 0
    end
end

function SKL_CHECK_RELIC_SPEND_RP_C(actor, skl, value)
	local mapname = session.GetMapName()
	local mapcls = GetClass("Map", mapname)
    if TryGetProp(mapcls, "MapType", "None") == "City" then
        return 0
    end	

    local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
    if equip_item == nil then
        return 0
    end

	local item_obj = GetIES(equip_item:GetObject())
	if item_obj == nil or IS_NO_EQUIPITEM(item_obj) == 1 or TryGetProp(item_obj, 'ClassType', 'None') ~= 'Relic' then
		return 0
    end

    local pc = GetMyPCObject()
	if IsBuffApplied(pc, "Relic_Release_Buff") == "YES" then
		return 1	
	end

    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    if cur_rp < value then
        return 0
    end

	local spend_rp_cyan = GetExProp(pc, "Spend_RP_By_Cyan")
	local spend_rp_magenta = GetExProp(pc, "Spend_RP_By_Magenta")
   	if spend_rp_cyan == 0 or spend_rp_magenta == 0 then
		return 0
    end
    
    if IsPVPField() == 1 then
        spend_rp_cyan = spend_rp_cyan * 1.5
        spend_rp_magenta = spend_rp_magenta * 1.5
    end
    
	local cur_rp, max_rp = shared_item_relic.get_rp(pc)
	if cur_rp < spend_rp_cyan or cur_rp < spend_rp_magenta then
		return 0	
	end

    return 1
end

function SCR_PRAKRITI_CHECK_BUFF_C(actor, skl, buffName)
    local getBuff = actor:GetBuff():GetBuff("Sadhu_Soul_Buff")
    if getBuff ~= nil then
        local over = getBuff.over
        if over >= 2 then
            return 1;
        end
    end

    return 0;
end

function SCR_RINGOFLIGHT_CHECK_ABIL_WEAPON_C(actor, skl)
    local abil = session.GetAbilityByName('Crusader22')
    if abil ~= nil then
        abil_obj = GetIES(abil:GetObject())
    end
    
    if abil_obj ~= nil and TryGetProp(abil_obj, "ActiveState", 0) == 1 then
        local rh = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
        if rh ~= nil then
            local rh_obj = GetIES(rh:GetObject())
            if rh_obj ~= nil and IS_NO_EQUIPITEM(rh_obj) == 0 then
                local class_type = TryGetProp(rh_obj, 'ClassType', 'None')	
                if class_type == 'Mace' or class_type == 'THMace' then
                    return 1
                end
            end
        end
        return 0
    else
        return 1
    end
end

function CHECK_IS_EQUIP_PREFIX_C(actor, skl, prefix)
	local cls = GetClass('LegendSetItem', prefix)
	local MaxCnt = TryGetProp(cls, 'MaxOptionCount')
	local Cnt = 0
	local slot = {'RH', 'LH', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'}

	local TrinketSlot = session.GetEquipItemBySpot(item.GetEquipSpotNum('TRINKET'))
	local TrinketObj = GetIES(TrinketSlot:GetObject())
	if TryGetProp(TrinketObj, "ClassType", "None") == 'Trinket' then
		slot[2] = 'TRINKET'
	end

	for i = 1, 6 do
		local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot[i]))
	    if equip_item == nil then
	        return 0
	    end

		local item_obj = GetIES(equip_item:GetObject())
		if item_obj == nil or IS_NO_EQUIPITEM(item_obj) == 1 then
			return 0
	    end

		if TryGetProp(item_obj, 'LegendPrefix', 'None') == prefix then
			Cnt = Cnt + 1
		end
	end

    if Cnt < MaxCnt then
        return 0
    end
    
    return 1
end