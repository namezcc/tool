local _cfg = CFG_DATA
local _func = LFUNC
local _IT = ITEM_TYPE
local _cm = CM
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _net_mgr = nil

local MAX_HUNHUAN_STRENGTH_LEVEL = 150

local HUNHUAN_STRENGTH_EXP = {
	[6010] = 100,
	[6011] = 500,
	[6012] = 1000
}

local hunhuan_module = {}

function hunhuan_module:init()
    _net_mgr = MOD.net_mgr_module
    _msg_func.bind_player_proto_func(_cm.CM_HUNHUAN_INFO, self.onHunhuanInfo, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_GET_NEW_HUNHUAN, self.onGetNewHunhuan, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_UPGRADE_HUNHUAN, self.onUpgradeHunhuan, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_UPGRADE_HUNHUAN_STRENGTH, self.onUpgradeHunhuanStrength, "UpgradeHunhuanStrength")
    _msg_func.bind_player_proto_func(_cm.CM_UNLOCK_HUNYIN, self.onUnlockHunyin, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_BREAK_HUANHUAN_STRENGTH, self.onBreakHunhuanStrength, "ProtoInt32")
    _msg_func.bind_player_server_proto(SERVER_MSG.IM_LOGIN_PLAYER_ADD_NEW_HUNHUAN, self.onGetNewHunhuan, "ProtoInt32")
    _msg_func.bind_player_proto_func(CM.CM_HUNYIN_COMPOSE,self.onHunyinCompose,"ProtoInt32Array")
end

function hunhuan_module:initDB(data)
	self._hunhuan = {}
    for i, v in ipairs(data.hunhuan) do
        self._hunhuan[v.hunhuan_id] = v
    end
end

function hunhuan_module:afterInit()
    self:initHunhuanAttrCash()
end

function hunhuan_module:initHunhuan()

end

function hunhuan_module:onHunhuanInfo(data)
    local hunhuanid = data.i32
    self:sendhunhuanInfo(hunhuanid)
    
end

function hunhuan_module:onUpgradeHunhuanStrength(data)
    local costcfg = {}

    for i, v in ipairs(data.hunhuancost) do
        costcfg[#costcfg+1] = _func.make_cfg_item_one(v.slot,_IT.IT_ITEM,v.num)
    end

    self:upgradeStrength(data.id, costcfg)
end

function hunhuan_module:onBreakHunhuanStrength(data)
    local id = data.i32
    local chrinfo = self._chr_info
    local curhunhuan = self._hunhuan[id]
    if curhunhuan == nil then
        return
    end

    local cfg = _cfg.hunhuan_break(chrinfo.job, curhunhuan.break_level + 1)
    if cfg == nil then
        return
    end

    if cfg.strength > curhunhuan.level then
        return
    end

    if self:delBagCheck(cfg.item) and self:getCurrency(CURRENCY_TYPE.CT_JINHUNBI) >= cfg.cost then
        self:addCurrency(CURRENCY_TYPE.CT_JINHUNBI, -cfg.cost, CHANGE_REASON.CR_HUNHUAN_BREAK_STRENGTH)
        self:delBag(cfg.item,CHANGE_REASON.CR_HUNHUAN_BREAK_STRENGTH)
        curhunhuan.break_level = curhunhuan.break_level + 1


        local curlevel = curhunhuan.level
        local curexp = curhunhuan.exp
        local strengthcfg = _cfg.hunhuan_strength(curlevel)
        while curexp >= strengthcfg.exp do
            if curlevel >= MAX_HUNHUAN_STRENGTH_LEVEL then
                break
            end

            local nextstrengthcfg = _cfg.hunhuan_strength(curlevel + 1)
            if nextstrengthcfg == nil then
                break
            end
            if nextstrengthcfg.grade > chrinfo.hunshi then
                break
            end
            if nextstrengthcfg.break_level > curhunhuan.break_level then
                break
            end

            curexp = curexp - strengthcfg.exp
            curlevel = curlevel + 1
            strengthcfg = _cfg.hunhuan_strength(curlevel)
        end
        local oldlevel = curhunhuan.level
        curhunhuan.exp = curexp
        curhunhuan.level = curlevel
        if oldlevel ~= curlevel then
            self:updateHunhuanAttr(id)
        end

        self:dbUpdateData(_table.TAB_mem_chr_hunhuan,curhunhuan)
        self:sendhunhuanInfo(id);
    end
end

function hunhuan_module:onGetNewHunhuan(data)
    local hunshi = data.i32
    local chr_info = self._chr_info
    if hunshi ~= chr_info.hunshi + 1 then
        return
    end
    self:getNewHunhuan()
end

function hunhuan_module:onUpgradeHunhuan(data)
    local id = data.i32
    local chr_info = self._chr_info
    if id > chr_info.hunshi then
        return
    end
    self:addHunhuan(id)
end

function hunhuan_module:onUnlockHunyin(data)
    local slot = data.i32

    if slot < 1 or slot > 27 then
        return
    end

    local hunyinid = math.floor((slot + 2)/3)
    local hunyinidx = (slot + 2) % 3
    local hunhuan = self._hunhuan[hunyinid]
    if hunhuan == nil then
        return
    end

    if hunyinidx == 0 then
        if hunhuan.hunyin_1 ~= 0 then
            return
        end
    elseif hunyinidx == 1 then
        if hunhuan.hunyin_2 ~= 0 then
            return
        end
    elseif hunyinidx == 2 then
        if hunhuan.hunyin_3 ~= 0 then
            return
        end
    end

    local cfg = CFG_DATA.hunyin_slot(hunyinid, hunyinidx)
    if cfg == nil then
        return
    end

    if hunhuan.attr_1 + hunhuan.attr_2 + hunhuan.attr_3 + hunhuan.attr_4 + hunhuan.attr_5 < cfg.attr_num then
        return
    end
    if self:delBagCheck(cfg.cost) then
        self:delBag(cfg.cost,CHANGE_REASON.CR_HUNYIN_UNLOCK)
        if hunyinidx == 0 then
            hunhuan.hunyin_1 = 1
        elseif hunyinidx == 1 then
            hunhuan.hunyin_2 = 1
        elseif hunyinidx == 2 then
            hunhuan.hunyin_3 = 1
        end

        self:dbUpdateData(_table.TAB_mem_chr_hunhuan,hunhuan)
        self:sendhunhuanInfo(hunyinid)
    end
end

function hunhuan_module:initHunhuanAttrCash()
    local chr_info = self._chr_info
    local hunhuan = self._hunhuan

    for i, v in pairs(hunhuan) do
        local attrdata = {}
        attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_1, 1, v.attr_1}
        attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_2, 1, v.attr_2}
        attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_3, 1, v.attr_3}
        attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_4, 1, v.attr_4}
        attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_5, 1, v.attr_5}

        local hunhuanstrengthcfg = _cfg.hunhuan_strength(hunhuan.level)
        if hunhuanstrengthcfg then
            for si, sv in ipairs(hunhuanstrengthcfg.basic_attr) do
                attrdata[#attrdata+1] = sv
            end
        end

        self._attr[PLAYER_ATTR_SOURCE.PAS_HUNHUAN_1 - 1 + v.hunhuan_id] = attrdata
    end
end

function hunhuan_module:getNewHunhuan()
    local chr_info = self._chr_info
    local curgrade = chr_info.hunshi
    local icfg = _cfg.hunhuan_init(curgrade)
    if icfg == nil then
        return
    end
    if chr_info.level < icfg.level then
        return
    end

    --增加新魂环属性
    local hunhuaninit = _cfg.hunhuan_init(curgrade + 1)
    if hunhuaninit == nil then
        return
    end
    self._chr_info.hunshi = curgrade + 1
    local hunhuanattr = hunhuaninit.basic_attr
    local hunhuaninfo = {cid = chr_info.cid, hunhuan_id = hunhuaninit.grade, hunshi = hunhuaninit.hunshi, level = 1, exp = 0, hunyin_1 = 0, hunyin_2 = 0, hunyin_3 = 0, break_level = 0}

    for i, v in ipairs(hunhuanattr) do
        if v[1] == ATTR_TYPE.ATTR_MAIN_1 then
            hunhuaninfo.attr_1 = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_2 then
            hunhuaninfo.attr_2 = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_3 then
            hunhuaninfo.attr_3 = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_4 then
            hunhuaninfo.attr_4 = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_5 then
            hunhuaninfo.attr_5 = v[3]
        end
    end

    self._hunhuan[hunhuaninit.grade] = hunhuaninfo
    self:updateHunhuanAttr(hunhuaninit.grade)
    self:addExp(icfg.give_exp, CHANGE_REASON.CR_HUNHUAN)

    self:updateHunhuanSkill()

    self:dbUpdateData(_table.TAB_mem_chr_hunhuan,hunhuaninfo)
    self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
    self:sendhunhuanInfo(hunhuaninit.grade)
    self:updateProgressByType(TASK_CONDITION_TYPE.TCT_GET_HUNHUAN, self._chr_info.hunshi, 1)
    self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNSHI_LV, 0, 1)
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_HUNHUAN, self._chr_info.hunshi, 1, 1)
end

function hunhuan_module:addHunhuan(id)--从当前grade到当前能到达的最大grade的最大属性之间的属性差值中随机数值来增加数值 hunshi记录当前对应grade
    local chr_info = self._chr_info
    local curgrade = chr_info.hunshi
    if curgrade < id then
        return
    end

    local curhunhuan = self._hunhuan[id]
    if curhunhuan == nil then
        return
    end

    local curhunshi = curhunhuan.hunshi
    
    local curattr = {}
    curattr[1] = curhunhuan.attr_1
    curattr[2] = curhunhuan.attr_2
    curattr[3] = curhunhuan.attr_3
    curattr[4] = curhunhuan.attr_4
    curattr[5] = curhunhuan.attr_5

    local curattrnum = curhunhuan.attr_1 + curhunhuan.attr_2 + curhunhuan.attr_3 + curhunhuan.attr_4 + curhunhuan.attr_5
    local hunhuancfg = _cfg.hunhuan(curgrade)
    if hunhuancfg == nil then
        return
    end
    local maxattrnum = 0
    local maxattr = {}

    for i, v in ipairs(hunhuancfg.max_attr) do
        maxattrnum = maxattrnum + v[3]
    end

    if curattrnum >= maxattrnum then
        return
    end

    local curmaxattrnum = 0
    local curmaxattr = {}
    local curhunhuancfg = _cfg.hunhuan(curhunshi)
    if curhunhuancfg == nil then
        return
    end

    for i, v in ipairs(curhunhuancfg.max_attr) do
        curmaxattrnum = curmaxattrnum + v[3]

        if v[1] == ATTR_TYPE.ATTR_MAIN_1 then
            curmaxattr[1] = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_2 then
            curmaxattr[2] = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_3 then
            curmaxattr[3] = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_4 then
            curmaxattr[4] = v[3]
        elseif v[1] == ATTR_TYPE.ATTR_MAIN_5 then
            curmaxattr[5] = v[3]
        end
    end

    if curattrnum >= curmaxattrnum then
        curhunhuancfg = _cfg.hunhuan(curhunshi + 1)
        for i, v in ipairs(curhunhuancfg.max_attr) do
    
            if v[1] == ATTR_TYPE.ATTR_MAIN_1 then
                curmaxattr[1] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MAIN_2 then
                curmaxattr[2] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MAIN_3 then
                curmaxattr[3] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MAIN_4 then
                curmaxattr[4] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MAIN_5 then
                curmaxattr[5] = v[3]
            end
        end
    end
    
    if self:delBagCheck(curhunhuancfg.cost_item) then
        self:delBag(curhunhuancfg.cost_item,CHANGE_REASON.CR_HUNHUAN)

        local nummin = curhunhuancfg.num * 4 - math.modf(curhunhuancfg.hunhuannum /2)
        local nummax = curhunhuancfg.num * 4 + math.modf(curhunhuancfg.hunhuannum /2)

        local attrdiff = {}
        for i = 1, 5, 1 do
            attrdiff[i] = curmaxattr[i] - curattr[i]
        end

        local attrdiffindex = {}

        for i = 1, 5, 1 do
            if attrdiff[i] > 0 then
                attrdiffindex[#attrdiffindex+1] = i
            end
        end

        local attradd = math.random(nummin, nummax)
        local attraddindex = math.random(1, #attrdiffindex)

        if attrdiff[attrdiffindex[attraddindex]] >= attradd then
            attrdiff[attrdiffindex[attraddindex]] = attrdiff[attrdiffindex[attraddindex]] - attradd
        else
            local leftadd = attradd - attrdiff[attrdiffindex[attraddindex]]
            attrdiff[attrdiffindex[attraddindex]] = 0
            local beginindex = attraddindex + 1
            if beginindex > #attrdiffindex then
                beginindex = 1
            end

            while leftadd > 0 do
                if beginindex == attraddindex then
                    break
                end
                if attrdiff[attrdiffindex[beginindex]] >= leftadd then
                    attrdiff[attrdiffindex[beginindex]] = attrdiff[attrdiffindex[beginindex]] - leftadd
                    leftadd = 0
                    break
                else
                    leftadd = leftadd - attrdiff[attrdiffindex[beginindex]]
                    attrdiff[attrdiffindex[beginindex]] = 0
                    beginindex = beginindex + 1
                    
                    if beginindex > #attrdiffindex then
                        beginindex = 1
                    end
                end
            end
        end

        self._hunhuan[id].attr_1 = curmaxattr[1] - attrdiff[1]
        self._hunhuan[id].attr_2 = curmaxattr[2] - attrdiff[2]
        self._hunhuan[id].attr_3 = curmaxattr[3] - attrdiff[3]
        self._hunhuan[id].attr_4 = curmaxattr[4] - attrdiff[4]
        self._hunhuan[id].attr_5 = curmaxattr[5] - attrdiff[5]

        local temcurattrnum = 0
        for i = 1, 5, 1 do
            temcurattrnum = temcurattrnum + curmaxattr[i] - attrdiff[i]
        end

        if temcurattrnum > curmaxattrnum then
            self._hunhuan[id].hunshi = curhunshi + 1
            self:updateProgressByType(TASK_CONDITION_TYPE.TCT_HUNHUAN, id, self._hunhuan[id].hunshi)
            self:updateProgressByType(TASK_CONDITION_TYPE.TCT_UPGRADE_HUNHUAN, id, 1)
            self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNHUANG_YEAR, 0, 1)
        end

        self:dbUpdateData(_table.TAB_mem_chr_hunhuan,self._hunhuan[id])
        self:updateHunhuanAttr(id)
        self:sendhunhuanInfo(id)
    end
end

function hunhuan_module:updateHunhuanAttr(module)
    local hunhuan = self._hunhuan[module]
    if hunhuan == nil then
        return
    end

    local attrdata = {}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_1, 1, hunhuan.attr_1}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_2, 1, hunhuan.attr_2}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_3, 1, hunhuan.attr_3}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_4, 1, hunhuan.attr_4}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MAIN_5, 1, hunhuan.attr_5}

    local hunhuanstrengthcfg = _cfg.hunhuan_strength(hunhuan.level)
    if hunhuanstrengthcfg then
        for si, sv in ipairs(hunhuanstrengthcfg.basic_attr) do
            attrdata[#attrdata+1] = sv
        end
    end

    self._attr[PLAYER_ATTR_SOURCE.PAS_HUNHUAN_1 + hunhuan.hunhuan_id - 1] = attrdata
    self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_HUNHUAN_1 + hunhuan.hunhuan_id - 1, self._attr[PLAYER_ATTR_SOURCE.PAS_HUNHUAN_1 + hunhuan.hunhuan_id - 1])
end

function hunhuan_module:sendhunhuanInfo(id)
    if id ~= 0 then
        local hunhuan = self._hunhuan[id]
        if hunhuan then
            local hunhuaninfo = {
                hunhuan_id = hunhuan.hunhuan_id,
                hunshi = hunhuan.hunshi,
                attr1 = hunhuan.attr_1,
                attr2 = hunhuan.attr_2,
                attr3 = hunhuan.attr_3,
                attr4 = hunhuan.attr_4,
                attr5 = hunhuan.attr_5,
                level = hunhuan.level,
                exp = hunhuan.exp,
                hunyin1 = hunhuan.hunyin_1,
                hunyin2 = hunhuan.hunyin_2,
                hunyin3 = hunhuan.hunyin_3,
                break_level = hunhuan.break_level,
            }
            self:sendMsg(_sm.SM_HUNHUAN_INFO, hunhuaninfo, "HunhuanInfo")
        end    
    else
        local pb = {}
        local hunhuaninfo = {}
        local hunhuannum = 0
        for i = 1, 9 do
            local hunhuan = self._hunhuan[i]
            if hunhuan then
                hunhuannum = hunhuannum + 1
                hunhuaninfo[#hunhuaninfo+1] = {
                    hunhuan_id = hunhuan.hunhuan_id,
                    hunshi = hunhuan.hunshi,
                    attr1 = hunhuan.attr_1,
                    attr2 = hunhuan.attr_2,
                    attr3 = hunhuan.attr_3,
                    attr4 = hunhuan.attr_4,
                    attr5 = hunhuan.attr_5,
                    level = hunhuan.level,
                    exp = hunhuan.exp,
                    hunyin1 = hunhuan.hunyin_1,
                    hunyin2 = hunhuan.hunyin_2,
                    hunyin3 = hunhuan.hunyin_3,
                    break_level = hunhuan.break_level,
                }
            end
        end
        pb.num = hunhuannum
        pb.hunhuaninfo = hunhuaninfo
        self:sendMsg(_sm.SM_HUNHUAN_INFO_LIST, pb, "HunhuanInfoList")
    end
end

function hunhuan_module:upgradeStrength(id, costcfg)
    local charinfo = self._chr_info
    local curhunhuan = self._hunhuan[id]
    if curhunhuan == nil then
        return
    end

    local curlevel = curhunhuan.level
    if curlevel >= MAX_HUNHUAN_STRENGTH_LEVEL then
        return
    end

    local curexp = curhunhuan.exp
    local strengthcfg = _cfg.hunhuan_strength(curlevel)
    if strengthcfg == nil then
        return
    end

    local addexp = 0
    if self:delBagCheck(costcfg) then 
        for i, v in ipairs(costcfg) do
			local itemid = v[1]
			local num = v[3]
            if HUNHUAN_STRENGTH_EXP[itemid] == nil then
                return
            end

            addexp = addexp + HUNHUAN_STRENGTH_EXP[itemid] * num
        end
        self:delBag(costcfg,CHANGE_REASON.CR_HUNHUAN_STRENGTH)

        curexp = curexp + addexp

        while curexp >= strengthcfg.exp do
            if curlevel >= MAX_HUNHUAN_STRENGTH_LEVEL then
                break
            end

            local nextstrengthcfg = _cfg.hunhuan_strength(curlevel + 1)
            if nextstrengthcfg == nil then
                break
            end
            if nextstrengthcfg.grade > charinfo.hunshi then
                break
            end
            if nextstrengthcfg.break_level > curhunhuan.break_level then
                break
            end

            curexp = curexp - strengthcfg.exp
            curlevel = curlevel + 1
            strengthcfg = _cfg.hunhuan_strength(curlevel)
        end
        local oldlevel = curhunhuan.level
        curhunhuan.exp = curexp
        curhunhuan.level = curlevel
        if oldlevel ~= curlevel then
            self:updateHunhuanAttr(id)
        end

        self:dbUpdateData(_table.TAB_mem_chr_hunhuan,curhunhuan)
        self:sendhunhuanInfo(id);
    end
end

function hunhuan_module:checkCanPutonHunyin(slot, id)
    local hunyinindex = math.floor((slot + 2)/3)
    local charinfo = self._chr_info
    
    if charinfo.hunshi < hunyinindex then
        return false
    end

    local hunyincfg = _cfg.hunyin(id)
    if hunyincfg == nil then
        return false
    end

    local hunhuan = self._hunhuan[hunyinindex]
    if hunhuan == nil then
        return false
    end

    local hunyinidx = (slot + 2) % 3
    if hunyinidx == 0 then
        if hunhuan.hunyin_1 ~= 1 then
            return false
        end
    elseif hunyinidx == 1 then
        if hunhuan.hunyin_2 ~= 1 then
            return false
        end
    elseif hunyinidx == 2 then
        if hunhuan.hunyin_3 ~= 1 then
            return false
        end
    end

    for i = hunyinindex * 3 - 2, hunyinindex * 3 do
        if i ~= slot then
            local cur = self._chr_hunyin[i]
            if cur then
                local curhunyincfg = _cfg.hunyin(cur.id)
                if curhunyincfg then
                    if curhunyincfg.type == hunyincfg.type then
                        return false
                    end
                end
            end
        end
    end

    local hunhuandcfg = _cfg.hunhuan_description(hunyinindex, charinfo.job)
    if hunhuandcfg == nil then
        return false
    end
    local skillcfg = _cfg.skill2(hunhuandcfg.id)
    local tagnum = 0

    for i, v in ipairs(skillcfg.tag) do
        for ni,nv in ipairs(hunyincfg.tag) do
            if v == nv then
                tagnum = tagnum + 1
            end
        end
    end

    if tagnum == #hunyincfg.tag then
        return true
    end

    return false
end

function hunhuan_module:updateHunyinInfo(slot)
    
    local charinfo = self._chr_info
    local hunyinindex = math.floor((slot + 2)/3)
    local hunhuandcfg = _cfg.hunhuan_description(hunyinindex, charinfo.job)
    if hunhuandcfg == nil then
        return
    end
    if charinfo.hunshi < hunyinindex then
        return
    end

    local hunhuan = self._hunhuan[hunyinindex]
    if hunhuan == nil then
        return
    end

    local pb = {}
    local hunyinid = {}
    for i = hunyinindex * 3 - 2, hunyinindex * 3 do
        local cur = self._chr_hunyin[i]
        if cur then
            hunyinid[#hunyinid+1] = cur.id
        end
    end

    for i, v in ipairs(hunhuandcfg.real_skill) do
      pb[#pb+1] =  { skill_id = v, level = self._real_skill[v].level, hunyin = hunyinid}
      self._real_skill[v].hunyin = hunyinid
    end

	self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_SKILL_LEVEL_INFO,  {skill_level_info = pb} , "ImSkillLevelInfo")

end

function hunhuan_module:updateHunhuanSkill()
    self._real_skill = {}
    local hunhuan = self._hunhuan
    local charinfo = self._chr_info

    local boneSkillAddon = self:getBoneSkillAddon()

    for hunyinindex = 1, 9 do
        local hunhuandcfg = _cfg.hunhuan_description(hunyinindex, charinfo.job)
        if hunhuandcfg == nil then
            break
        end
        if charinfo.hunshi < hunyinindex then
            break
        end
        local level = 0

        local curhunhuan = hunhuan[hunyinindex]
        if curhunhuan ~= nil then
            local bcfg = _cfg.hunhuan_break(self._chr_info.job, curhunhuan.break_level)
            if bcfg then
                level = bcfg.skill_level
            end
        end

        if boneSkillAddon and boneSkillAddon[hunyinindex] then
            level = level + boneSkillAddon[hunyinindex]
        end

        local hunyinid = {}
        for i = hunyinindex * 3 - 2, hunyinindex * 3 do
            local cur = self._chr_hunyin[i]
            if cur then
                hunyinid[#hunyinid+1] = cur.id
            end
        end
        for i, v in ipairs(hunhuandcfg.real_skill) do
            self._real_skill[v] = { skill_id = v, level = level, hunyin = hunyinid}
            self:updateProgressByType(TASK_CONDITION_TYPE.TCT_SKILL_LEVEL, v, level)
        end
    end

    local pb = {}
    for i, v in pairs(self._real_skill) do
        pb[#pb+1] =  v
    end
    _net_mgr:sendToGamePlayerMsg(self, SERVER_MSG.IM_GAME_PLAYER_SKILL_LEVEL_INFO,  {skill_level_info = pb} , "ImSkillLevelInfo")
end

function hunhuan_module:loadHunhuanSkill(pdata)
    self:updateHunhuanSkill()
    local pb = {}
    for i, v in pairs(self._real_skill) do
        pb[#pb+1] =  v
    end

    pdata.skill_level_info = pb
    --_net_mgr:sendToGamePlayerMsg(self, SERVER_MSG.IM_GAME_PLAYER_SKILL_LEVEL_INFO,  {skill_level_info = pb} , "ImSkillLevelInfo")
end

function hunhuan_module:onHunyinCompose(d)
	local id = d.i32[1]
	local num = d.i32[2]

	local cfg = _cfg.hunyin_level(id)
	if cfg == nil then
		return
	end

	local cost = table.clone(cfg.cost)
	local reward = table.clone(cfg.reward)
	for i, v in ipairs(cost) do
		v[3] = v[3]*num
	end
	for i, v in ipairs(reward) do
		v[3] = v[3]*num
	end

	if not self:delBagCheck(cost) then
		return
	end

	if not self:addBagCheck(reward) then
		return
	end

	self:delBag(cost,CHANGE_REASON.CR_HUNYIN_COMPOSE,true,false)
	self:addBag(reward,CHANGE_REASON.CR_HUNYIN_COMPOSE)
	self:replyMsg(CM.CM_HUNYIN_COMPOSE,ERROR_CODE.ERR_SUCCESS,{id})
end

return hunhuan_module