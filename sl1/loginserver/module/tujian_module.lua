local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _attr_mod = PLAYER_ATTR_SOURCE

local MAX_AFFI_LV = 15

local TuJianGroup = {
    TJG_NPC = 1,
    TJG_MONSTER = 2,
    TJG_BAIBAO = 3,
    TJG_MAP = 4,
    TJG_STORY = 5,
}


local tujian_module = {}

function tujian_module:init()
    MSG_FUNC.bind_player_proto_func(CM.CM_UNLOCK_TUJIAN,self.onUnlockTujian,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_AFFINITY_UP,self.onAffinityUp,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_UNLOCK_AFFI_MENU,self.onAffiUnlockMenu,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_ACTIVATE_JIBAN,self.onActivateJiban,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_GIVE_GIFT,self.onGiveGift,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_COGNI_UP,self.onCognitionUp,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_GET_SCORE_REWARD,self.onGetScoreReward,"ProtoInt32Array")
end

function tujian_module:initDB(data)
	local tujian = {}
    for i = 1, 5 do
        tujian[i] = {}
    end
    
	if data.tujian then
		for _, value in ipairs(data.tujian) do
            if tujian[value.group] == nil then
                tujian[value.group] = {}
            end
			tujian[value.group][value.id] = table.cloneSimple(value)
		end
	end

    local tujian_total = {}
    if _func.checkPlayerData(data.tujian_total) then
        tujian_total = data.tujian_total
    else
        tujian_total = {
            cid = self.cid,
            score_npc = 0,
            score_monster = 0,
            score_baibao = 0,
            score_map = 0,
            score_story = 0,
            level = 0,
        }
    end

	self._tujian = tujian
    self._tujian_total = tujian_total
	self:sendTujianInfo()
    self:sendTujianTotalInfo()

end

function tujian_module:afterInit()
    self:updateModuleAttr(_attr_mod.PAS_TUJIAN,true)
end


function tujian_module:unlockTujian(group,id)
    local card = {
        cid = self.cid,
        group = group,
        id = id,
        affinity = 0,
        affi_lv = 1,
        affi_unlock = 0,
        jb_lv = 0,
        jb_activate =0,
        cognition = 0,
        cogni_lv = 1,
        unlock = 1,
    }
    if self._tujian[group] == nil then
        self._tujian[group] = {}
    end
    if self._tujian[group][id] ~= nil then
        return
    end
    self._tujian[group][id] = card
end

function tujian_module:onUnlockTujian(data)
    if #data.i32 < 2 then
        return
    end
    local group = data.i32[1];
    local id = data.i32[2];
    self:unlockTujian(group,id)
    --self:updataTujianGroupScore(group,id)

    local tujian = self._tujian[group][id]
    --local tujian_total = self._tujian_total

    self:sendTujianInfo(tujian)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
    --self:sendTujianTotalInfo()
    --self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian_total,tujian_total)
    self:updateModuleAttr(_attr_mod.PAS_TUJIAN)
end

function tujian_module:sendTujianInfo(info)
	local pb = {}
	if info then
		pb[#pb+1] = info
	else
		for _, v in pairs(self._tujian) do
            for _, n in pairs(v) do
                pb[#pb+1] = n
            end
		end
	end

	self:sendMsg(_sm.SM_TUJIAN_INFO,{data=pb},"SmTujianInfo")
end

function tujian_module:sendTujianTotalInfo()
    self:sendMsg(_sm.SM_TUJIAN_TOTAL_INFO,self._tujian_total,"SmTujianTotalInfo")
end


function tujian_module:updataTujianGroupScore(group,id,get_level)
    local tujian_total = self._tujian_total
    local tujian = self._tujian[group][id]
    if group == TuJianGroup.TJG_NPC then
        local cfg = _cfg.tujian_npc(id)
	    if cfg == nil then
	    	return
	    end
        local quality = cfg.quality
        if get_level < tujian.affi_lv then
            return
        end
        local cfg2 = _cfg.tujian_score(group,1,quality,get_level)
        if cfg2 ~= nil then
            tujian_total.score_npc = tujian_total.score_npc + cfg2.score
        end
        --奖励
        if not self:addBagCheck(cfg2.reward) then
		    return
	    end
        self:addBag(cfg2.reward,CHANGE_REASON.CR_TUJIAN_SCORE_REWARD)
    elseif group == TuJianGroup.TJG_MONSTER then
        local cfg = _cfg.tujian_monster(id)
	    if cfg == nil then
	    	return
	    end
        if get_level < tujian.cogni_lv then
            return
        end
        local quality = cfg.quality
        local cfg2 = nil
        if cfg.type == 1 then
            cfg2 = _cfg.tujian_score(group,1,quality,get_level)
        else
            cfg2 = _cfg.tujian_score(group,2,quality,get_level)
        end
        if cfg2 ~= nil then
            tujian_total.score_monster = tujian_total.score_monster + cfg2.score
        end
        --奖励
        if not self:addBagCheck(cfg2.reward) then
		    return
	    end
        self:addBag(cfg2.reward,CHANGE_REASON.CR_TUJIAN_SCORE_REWARD)
    elseif group == TuJianGroup.TJG_BAIBAO then
        local cfg = _cfg.tujian_baibao(id)
	    if cfg == nil then
	    	return
	    end
        local score = 0
        if cfg.type == 1 then--道具
            score = cfg.score
        else
            local quality = cfg.quality
            local level = 0
            local cfg2 = nil
            if cfg.type == 2 and self._grass[cfg.itemid] and self._grass[cfg.itemid].star then --仙草
                level = self._grass[cfg.itemid].star
                if get_level < level then
                    return
                end
                cfg2 = _cfg.tujian_score(group,2,quality,level)
            elseif cfg.type == 3 and self._anqi[cfg.itemid] and self._anqi[cfg.itemid].star_lv then--暗器
                level = self._anqi[cfg.itemid].star_lv + 1
                if get_level < level then
                    return
                end
                cfg2 = _cfg.tujian_score(group,3,quality,level)
            end
            if cfg2 ~= nil then
                score = cfg2.score
            end
        end
        tujian_total.score_baibao = tujian_total.score_baibao + score
        --奖励
        if not self:addBagCheck(cfg2.reward) then
		    return
	    end
        self:addBag(cfg2.reward,CHANGE_REASON.CR_TUJIAN_SCORE_REWARD)
    elseif group == TuJianGroup.TJG_MAP then
        local cfg = _cfg.tujian_map(id)
	    if cfg == nil then
	    	return
	    end
        tujian_total.score_map = tujian_total.score_map + cfg.score
    elseif group == TuJianGroup.TJG_STORY then
        local cfg = _cfg.tujian_story(id)
	    if cfg == nil then
	    	return
	    end
        tujian_total.score_story = tujian_total.score_story + cfg.score
    end

    local total_score = tujian_total.score_npc+tujian_total.score_monster+tujian_total.score_baibao+tujian_total.score_map+tujian_total.score_story
    local cfg = _cfg.tujian(tujian_total.level+1)
    if cfg == nil then
        return
    end
    while total_score>=cfg.score do
        tujian_total.level = tujian_total.level + 1
        cfg = _cfg.tujian(tujian_total.level+1)
        if cfg == nil then
	    	break
	    end
    end
end


function tujian_module:calcTujianAttr()
    local attr = {}
	local tujian_total = self._tujian_total
	local cfg_total = _cfg.tujian(tujian_total.level)
	if cfg_total  then
		_func.combindAttr(attr,cfg_total.attr)
	end


    local t_group = self._tujian[TuJianGroup.TJG_NPC]
    for _, v in ipairs(t_group) do
        for level = 1, v.jb_lv do
            local jb_activate = v.jb_activate
            if _func.is_bit_on(jb_activate,level) then
                local cfg_jb = _cfg.tujian_jiban(v.id,level)
	            if cfg_jb  then
		            _func.combindAttr(attr,cfg_jb.attr)
	            end
            end   
        end      
    end
    

    t_group = self._tujian[TuJianGroup.TJG_MONSTER]
    for _, v in ipairs(t_group) do
        for level=1,v.cogni_lv do
            local cfg_co = _cfg.tujian_cognition(v.id,level)
	        if cfg_co  then
		        _func.combindAttr(attr,cfg_co.attr)
	        end
        end     
    end

	return attr
end


function tujian_module:onAffinityUp(data)
    if #data.i32 < 2 then
        return
    end
    local group = data.i32[1];
    local id = data.i32[2];
    local tujian = self._tujian[group][id]
    local level = tujian.affi_lv + 1
    local cfg = _cfg.tujian_affinity(id,level)
	if cfg == nil then
		return
	end

    --亲密度值判断
    if tujian.affinity < cfg.affi_val then
        return
    end

    --奖励
    if not self:addBagCheck(cfg.reward) then
		return
	end
    self:addBag(cfg.reward,CHANGE_REASON.CR_AFFINITY_UP)
    tujian.affi_lv = level

    self:sendTujianInfo(tujian)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
end

function tujian_module:onAffiUnlockMenu(data)
    if #data.i32<3 then
        return
    end
    local group = data.i32[1]
    local id = data.i32[2]
    local level = data.i32[3]
    local tujian = self._tujian[group][id]
    if tujian == nil then
        return
    end
    if level > tujian.affi_lv then
        return
    end

    local affi_unlock = tujian.affi_unlock
    if _func.is_bit_on(affi_unlock,level) then
        return
    end

    affi_unlock = _func.set_bit_on(affi_unlock,level)
    tujian.affi_unlock = affi_unlock

    self:sendTujianInfo(tujian)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
end

function tujian_module:onActivateJiban(data)
    if #data.i32<3 then
        return
    end

    local group = data.i32[1]
    local id = data.i32[2]
    local level = data.i32[3]
    local tujian = self._tujian[group][id]

    local cfg = _cfg.tujian_jiban(id,level)
	if cfg == nil then
		return
	end
    
    --是否已领取
    if not _func.is_bit_on(tujian.affi_unlock,cfg.affi_lv) then
        return
    end

    --是否已激活
    local jb_activate = tujian.jb_activate
    if _func.is_bit_on(jb_activate,level) then
        return
    end

    --是否满足亲密度条件
    if  tujian.affi_lv < cfg.affi_lv then
        return
    end

    if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_ACTIVATE_JIBAN)
    jb_activate=_func.set_bit_on(jb_activate,level)
    tujian.jb_activate = jb_activate

    if tujian.jb_lv < cfg.jb_lv then
        tujian.jb_lv = cfg.jb_lv
    end  

    self:sendTujianInfo(tujian)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
    self:updateModuleAttr(_attr_mod.PAS_TUJIAN)
end

local function getGiftGroupOrItem(cfgVec,flag)
    local fl = flag or 0
    local proVec = {}
        for _, v in ipairs(cfgVec) do
            proVec[#proVec+1] = v.probability
        end
        table.sort(proVec)

        local r = math.random(1,1000)
        local index = nil
        for _, v in ipairs(proVec) do
            if r<=v then
                index = v
                break
            end
        end

        if index==nil then
            return
        end

        local groups = {}
        for _, v in ipairs(cfgVec) do
            if index==v.probability then
                if fl then
                    groups[#groups+1] = v.index
                else
                    groups[#groups+1] = v.group
                end
                
            end
        end

        if #groups==0 then
            return
        end
        local gIndex = math.random(1,#groups)
        local fgroup = groups[gIndex]

        return fgroup
end

function tujian_module:onGiveGift(data)
    local group = data.i32[1]
    local id = data.i32[2]
    local gift_type = data.i32[3] --0常驻1每日刷新
    local tujian = self._tujian[group][id]
    if tujian == nil then
        return
    end
    local cfg=nil

    --赠送给图鉴 消耗5个道具 亲密度给自己
    if gift_type==0 then
        local index = data.i32[4]
        cfg = _cfg.tujian_gift(id,index)
        if cfg==nil then
            return
        end
    else
        local count = self:getRecord(RECORD_TYPE.RT_DAILY_AFFI_GIFT_REFRESH)
        if count>=1 then
            return
        end 
        local cfgVec = _cfg.tujian_gift_group(id)
        if cfgVec==nil then
            return
        end

        --选组
        local group = getGiftGroupOrItem(cfgVec)

        --选道具
        local vec = _cfg.tujian_gift_group_item(group)
        if vec==nil then
            return
        end

        local index = getGiftGroupOrItem(vec,1)
        for _, v in ipairs(vec) do
            if index==v.index then
                cfg = v
                break
            end
        end
    end

    --
    if not self:delBagCheck(cfg.item) then
        return
    end

    self:delBag(cfg.item,CHANGE_REASON.CR_GIVE_GIFT)
    tujian.affinity = tujian.affinity + cfg.affinity

    if gift_type==1 then
        self:updateRecord(RECORD_TYPE.RT_DAILY_AFFI_GIFT_REFRESH,1)
    end

    --自动升级亲密度
    local level = tujian.affi_lv + 1
    if level<=MAX_AFFI_LV then
        local cfg_aff = _cfg.tujian_affinity(id,level)
	    if cfg_aff == nil then
		    return
	    end

        --亲密度值判断
        if tujian.affinity >= cfg_aff.affi_val then
            --奖励
            -- if not self:addBagCheck(cfg_aff.reward) then
		    --     return
	        -- end
            -- self:addBag(cfg_aff.reward,CHANGE_REASON.CR_AFFINITY_UP)
            tujian.affi_lv = level
        end
    end
    ---

    ---------------------------------------
    -- local level = 0
    -- repeat
    --     level = tujian.affi_lv + 1
    --     local cfg_aff = _cfg.tujian_affinity(id,level)
	--     if cfg_aff == nil then
	-- 	    return
	--     end
    --     tujian.affi_lv = level
    -- until(tujian.affinity < cfg_aff.affi_val and level>MAX_AFFI_LV)
    ---------------------------------------

    self:sendTujianInfo(tujian)
    self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
end

function tujian_module:onCognitionUp(data)
    if #data.i32 < 2 then
        return
    end
    local group = data.i32[1]
    local id = data.i32[2]
    local tujian = self._tujian[group][id]
    local level = tujian.cogni_lv + 1
    local cfg = _cfg.tujian_cognition(id,level)
	if cfg == nil then
		return
	end

    --认知度值判断
    if tujian.cognition < cfg.cogni_val then
        return
    end

	self:sendTujianInfo(tujian)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian,tujian)
    self:updateModuleAttr(_attr_mod.PAS_TUJIAN)  
end

function tujian_module:haveNpcTujian(id)
	return self._tujian[TuJianGroup.TJG_NPC][id] ~= nil
end

function tujian_module:onGetScoreReward(data)
    if #data.i32 < 3 then
        return
    end
    local group = data.i32[1]
    local id = data.i32[2]
    local level = data.i32[3]
    self:updataTujianGroupScore(group,id,level)

    local tujian_total = self._tujian_total
    self:sendTujianTotalInfo()
    self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_tujian_total,tujian_total)
end

return tujian_module