-- 아이템 아크 shared_item_ark.lua

shared_item_ark = {}
max_ark_option_count = 10 -- 옵션이 최대 10개 있다고 가정함
item_ark_grow_ratio = 0.2  -- 아이템 렙업을 위한 재료 요구량 증가 계수
item_ark_grow_ratio_exp_up = 0.1 -- 뉴클 증가 계수

----------------------------------  재료들 --------------------------------------------

shared_item_ark.get_exp_material = function()
    return 'misc_ore22' -- 뉴클 가루
end

-- 축석, 신비한서, 시에라 스톤의 class_name
shared_item_ark.get_require_item_list_for_lv = function()
    return 'Premium_item_transcendence_Stone', 'HiddenAbility_Piece', 'misc_ore23_stone'
end
----------------------------------  재료들 끝 --------------------------------------------



shared_item_ark.get_low_lv_adventage = function(goal_lv, max_lv)
    if max_lv == nil or max_lv == 0 then
        max_lv = 100
    end

    local low_lv_adventage = 1
    local diff = (max_lv - goal_lv) / max_lv
    diff = tonumber(string.format("%.2f", diff))
    low_lv_adventage = 1 - diff
    low_lv_adventage = tonumber(string.format("%.2f", low_lv_adventage))
    return low_lv_adventage
end

-- 축석 개수, 신비한 서 낱장, 시에라 스톤 순으로 반환
shared_item_ark.get_require_count_for_next_lv = function(goal_lv, max_lv)    
    if max_lv == nil or max_lv == 0 then
        max_lv = 5
    else
        max_lv = 5
    end

    local multiple = tonumber(string.format('%.2f',math.floor(goal_lv * (goal_lv * item_ark_grow_ratio))))    
    local base_transcend_count = 20  -- 축석 수
    local base_arcane_count = 7     -- 신비한 서 낱장
    local base_siera_count = 2      -- 시에라 스톤

    local low_lv_adventage = shared_item_ark.get_low_lv_adventage(goal_lv, max_lv)
    if goal_lv > max_lv then
        low_lv_adventage = math.min(low_lv_adventage, 0.8)
    else
        low_lv_adventage = math.min(low_lv_adventage, 1)
    end
    
    base_transcend_count = math.max(math.floor(base_transcend_count * multiple * low_lv_adventage), 1)
    base_arcane_count = math.max(math.floor(base_arcane_count * multiple * low_lv_adventage), 1)
    base_siera_count = math.max(math.floor(base_siera_count * multiple * low_lv_adventage), 1)

    base_transcend_count = math.min(base_transcend_count, 200)
    base_arcane_count = math.min(base_arcane_count, 100)
    base_siera_count = math.min(base_siera_count, 100)

    return base_transcend_count, base_arcane_count, base_siera_count
end

-- 렙업에 필요한 뉴클 가루 수
shared_item_ark.get_require_count_for_exp_up = function(goal_lv, max_lv)    
    if max_lv == nil or max_lv == 0 then
        max_lv = 5
    else
        max_lv = 5
    end

    local low_lv_adventage = shared_item_ark.get_low_lv_adventage(goal_lv, max_lv)
    if goal_lv > max_lv then
        low_lv_adventage = math.min(low_lv_adventage, 0.8)
    else
        low_lv_adventage = math.min(low_lv_adventage, 1)
    end

    local multiple = goal_lv * (goal_lv * item_ark_grow_ratio_exp_up)
    multiple = tonumber(string.format('%.2f', multiple))
    local base = 100 -- float 연산 오류때문에 분리함 200 * 1000    
    base = math.floor(base * multiple * low_lv_adventage)  
    base = base * 1000
    if base < 10000 then
        base = 10000
    end
    
    return tostring(base)
end

shared_item_ark.is_valid_condition_for_copy = function(item_dest, item_src)
    local src_lv = TryGetProp(item_src, 'ArkLevel', 1)
    local dest_lv = TryGetProp(item_dest, 'ArkLevel', 1) 

    if dest_lv > src_lv then
        return false
    end

    if dest_lv == src_lv then
        local src_exp = TryGetProp(item_src, 'ArkExp', 0)
        local dest_exp = TryGetProp(item_dest, 'ArkExp', 0)

        if dest_exp >= src_exp then
            return false
        end
    end

    return true
end

-- 최대렙 확인
shared_item_ark.is_max_lv = function(item)
    if item == nil then
        return "YES"
    end

    local max = TryGetProp(item, 'MaxArkLv', 10)    
    local lv = TryGetProp(item, 'ArkLevel', 1)

    if lv >= max then
        return "YES"
    else
        return "NO"
    end
end

-- 다음 레벨에 필요한 경험치
shared_item_ark.get_next_lv_exp = function(item)    
    local is_max_lv = shared_item_ark.is_max_lv(item)
    if is_max_lv == "YES" then        
        return false, nil
    end

    local max_lv = TryGetProp(item, 'MaxArkLv', 10)    
    local current_lv = TryGetProp(item, 'ArkLevel', 1)
    local next_exp = shared_item_ark.get_require_count_for_exp_up(current_lv + 1, max_lv)    
    next_exp = tonumber(next_exp)
    if next_exp <= 0 then
        return false, nil
    end
    
    return true, next_exp
end


shared_item_ark.get_current_lv_exp = function(item)    
    local max_lv = TryGetProp(item, 'MaxArkLv', 10)
    local current_lv = TryGetProp(item, 'ArkLevel', 1)    
    local next_exp = shared_item_ark.get_require_count_for_exp_up(current_lv, max_lv)    
    next_exp = tonumber(next_exp)
    if next_exp <= 0 then
        return false, nil
    end
    
    return true, next_exp
end

------------------------------------ 아크 툴팁 관련 ----
-- 반환값 : tooptip_type, option, level, value

-------------- 아크 - 힘 ----------------
-- 첫번째 옵션 힘은 1레벨당 16씩 오른다.
function get_tooltip_Ark_str_arg1()    
    return 1, 'STR_BM', 1, 16
end

-- 두번째 옵션 물방은 3레벨당 500씩 오른다.
function get_tooltip_Ark_str_arg2()
    return 1, 'DEF_BM', 3, 500
end

-- 세번째 옵션 민/맥 물공은 5레벨당 500씩 오른다.
function get_tooltip_Ark_str_arg3()
    return 1, 'PATK_BM', 5, 700
end

-------------- 아크 - 지능 ----------------
-- 첫번째 옵션 지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_int_arg1()
    return 1, 'INT_BM', 1, 16
end

-- 두번째 옵션 마방은 3레벨당 x씩 오른다.
function get_tooltip_Ark_int_arg2()
    return 1, 'MDEF_BM', 3, 500
end

-- 세번째 옵션 민/맥 마공은 5레벨당 x씩 오른다.
function get_tooltip_Ark_int_arg3()
    return 1, 'MATK_BM', 5, 700
end

-------------- 아크 - 민첩 ----------------
-- 첫번째 옵션 민은 1레벨당 16씩 오른다.
function get_tooltip_Ark_dex_arg1()
    return 1, 'DEX_BM', 1, 16
end

-- 두번째 옵션 회피는 3레벨당 x씩 오른다.
function get_tooltip_Ark_dex_arg2()
    return 1, 'DR_BM', 3, 300
end

-- 세번째 옵션 물리 치공은 5레벨당 x씩 오른다.
function get_tooltip_Ark_dex_arg3()
    return 1, 'CRTATK_BM', 5, 1400
end

-------------- 아크 - 정신 ----------------
-- 첫번째 옵션 정신은 1레벨당 16씩 오른다.
function get_tooltip_Ark_mna_arg1()
    return 1, 'MNA_BM', 1, 16
end

-- 두번째 옵션 치유력은 3레벨당 x씩 오른다.
function get_tooltip_Ark_mna_arg2()
    return 2, 'HEAL_PWR_BM', 3, 420, 'SUMMON_ATK'
end

-- 세번째 옵션 마치공 5레벨당 x씩 오른다.
function get_tooltip_Ark_mna_arg3()
    return 1, 'CRTMATK_BM', 5, 1400
end

-------------- 아크 - 질풍 ----------------
-- 첫번째 옵션 힘/민/지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_wind_arg1()
    return 1, 'STR_DEX_INT_BM', 1, 20
end

-- 두번째 옵션 기본 공격 3레벨당 x씩 오른다. 총 16회, 100 + (20 * 16) = 420%
function get_tooltip_Ark_wind_arg2()
    return 3, 'ARK_BASIC_ATTACK', 3, 20, 100
end

-- 세번째 옵션 질풍은 5레벨당 x씩 확률적으로 발생한다. (정수로 해야 함). 총 10회, 10 + (2 * 10) = 30%
function get_tooltip_Ark_wind_arg3()
    return 3, 'ARK_UNLEASH_WIND', 5, 5, 10
end

-------------- 아크 - 낙뢰 ----------------
-- 첫번째 옵션 힘/지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_thunderbolt_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션 낙뢰 발동은 3레벨당 x씩 확률적으로 발생한다. (정수로 해야 함), 총 16회, 15 + (2 * 16) = 47%
function get_tooltip_Ark_thunderbolt_arg2()
    return 3, 'ARK_THUNDERBOLT_RATIO', 3, 2, 15
end

-- 세번째 옵션 낙뢰 계수는 5레벨당 x씩 오른다. 총 10회, 3500 + (10 * 700) = 10500%
function get_tooltip_Ark_thunderbolt_arg3()
    return 3, 'ARK_THUNDERBOLT_ATTACK', 5, 700, 3500
end


-------------- 아크 - 폭풍 ----------------
-- 첫번째 옵션 힘/지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_storm_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션 폭풍 발동은 3레벨당 x씩 확률적으로 발생한다. (정수로 해야 함), 총 16회, 15 + (2 * 16) = 47%
function get_tooltip_Ark_storm_arg2()
    return 3, 'ARK_STORM_RATIO', 3, 2, 15
end

-- 세번째 옵션 폭풍 계수는 5레벨당 x씩 오른다. 총 16회, 1200 + (10 * 250) = 3700%
function get_tooltip_Ark_storm_arg3()
    return 3, 'ARK_STORM_ATTACK', 5, 250, 1200
end
