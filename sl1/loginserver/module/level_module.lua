local _ST = STORAGE_TYPE
local _IT = ITEM_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _table = TABLE_INDEX
local _net_mgr = nil

local level_module = {}

function level_module:init()
    _net_mgr = MOD.net_mgr_module
    MSG_FUNC.bind_player_proto_func(CM.CM_SET_LAVEL_ATTR, self.onSetLevelAttr, "ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_GET_LEVEL_GIFT, self.onGetLevelGift, "ProtoInt32")
    MSG_FUNC.bind_player_proto_func(CM.CM_LEVEL_GIFT_INFO, self.onLevelGiftInfo, "ProtoInt32Array")

end

function level_module:initDB(data)

end

function level_module:afterInit()
    self:initLevelAttrCash()
    self:sendLevelInfo()
end

function level_module:initLevelAttrCash()
    local chr_info = self._chr_info
    local icfg = _cfg.job(chr_info.job)
    if icfg == nil then
        return
    end
    local levelcfg = _cfg.level(chr_info.level)
    if levelcfg == nil then
        return
    end
    self._attr[PLAYER_ATTR_SOURCE.PAS_JOB] = icfg.basic_attr

    local attrdata = {}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_TIZHI, 1, chr_info.attr_point_1}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_LILIANG, 1, chr_info.attr_point_2}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MINJIE, 1, chr_info.attr_point_3}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_ZHIHUI, 1, chr_info.attr_point_4}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_JINGSHEN, 1, chr_info.attr_point_5}
    self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL] = attrdata
    self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS] = levelcfg.attr

    -- self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_JOB, self._attr[PLAYER_ATTR_SOURCE.PAS_JOB])
    -- self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_LEVEL, self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL])
    -- self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS, self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS])
end

function level_module:setLevel(level, reason)
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_LEVEL, level, 1)
    self._chr_info.level = level
    self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
    self:sendLevelInfo()
	self:checkSystemOpen(SYSTEM_OPEN_CONDITION.SOC_LEVEL,level)
end

function level_module:setHunshi(hunshi, reason)
    self._chr_info.hunshi = hunshi
    self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
    self:sendLevelInfo()
    self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNSHI_LV, 0, hunshi, 1)
end

function level_module:addExp(exp, reason)
    local chr_info = self._chr_info
    local curexp = chr_info.exp
    curexp = curexp + exp
    chr_info.exp = curexp
    local curlevel = chr_info.level
    local hunshi = chr_info.hunshi
    local hunhuancfg = _cfg.hunhuan(hunshi)
    if hunhuancfg == nil then
        return
    end

    if hunhuancfg.level <= curlevel then
        self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
        self:sendExpInfo()
        return
    end
    local attr_level = chr_info.attr_level
    local xuantian1 = chr_info.xuantian1
    local xuantian2 = chr_info.xuantian2
    local xuantian3 = chr_info.xuantian3
    local levelchange = 0

    local levelcfg = _cfg.level(curlevel)
    if levelcfg == nil then
        return
    end

    while (levelcfg.exp <= curexp)
    do
        curexp = curexp - levelcfg.exp
        curlevel = curlevel + 1
        levelchange = levelchange + 1

        local nextLevelCfg = _cfg.level(curlevel)
        if nextLevelCfg == nil then
            break
        end

        attr_level = attr_level + nextLevelCfg.talentNum
        xuantian1 = xuantian1 + nextLevelCfg.xuantian1
        xuantian2 = xuantian2 + nextLevelCfg.xuantian2
        xuantian3 = xuantian3 + nextLevelCfg.xuantian3
        chr_info.level = curlevel
        chr_info.exp = curexp
        chr_info.xuantian1 = xuantian1
        chr_info.xuantian2 = xuantian2
        chr_info.xuantian3 = xuantian3
        chr_info.attr_level = attr_level
        levelcfg = _cfg.level(curlevel)
        if levelcfg == nil then
            break
        end
        if hunhuancfg.level <= curlevel then
            break
        end
    end
    self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
    if levelchange > 0 then
        self:taskProgressPlayerLevel(curlevel)
        self:sendLevelInfo()
        self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_LEVEL, curlevel, 1)

        levelcfg = _cfg.level(self._chr_info.level)
        self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS] = levelcfg.attr
        self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS, self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL_SYS])

		self:checkSystemOpen(SYSTEM_OPEN_CONDITION.SOC_LEVEL,curlevel)
    end
    self:sendExpInfo()
end

function level_module:onSetLevelAttr(d)
    local attr_points = {}

    attr_points[#attr_points+1] = d.i32[1]
    attr_points[#attr_points+1] = d.i32[2]
    attr_points[#attr_points+1] = d.i32[3]
    attr_points[#attr_points+1] = d.i32[4]
    attr_points[#attr_points+1] = d.i32[5]
    self:setLevelAttr(attr_points)
end

function level_module:setLevelAttr(attr_points)
    local chr_info = self._chr_info
    local levelcfg = _cfg.level(chr_info.level)
    if levelcfg == nil then
        return
    end

    local totalattr = attr_points[1] + attr_points[2]+ attr_points[3]+ attr_points[4]+ attr_points[5]

    if levelcfg.total < totalattr  then
        return
    end

    if attr_points[1] > levelcfg.total * 0.6  then
        return
    end

    if attr_points[2] > levelcfg.total * 0.6  then
        return
    end

    if attr_points[3] > levelcfg.total * 0.6  then
        return
    end

    if attr_points[4] > levelcfg.total * 0.6  then
        return
    end

    if attr_points[5] > levelcfg.total * 0.6  then
        return
    end

    chr_info.attr_point_1 = attr_points[1]
    chr_info.attr_point_2 = attr_points[2]
    chr_info.attr_point_3 = attr_points[3]
    chr_info.attr_point_4 = attr_points[4]
    chr_info.attr_point_5 = attr_points[5]
    chr_info.attr_level = levelcfg.total - totalattr

    local attrdata = {}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_TIZHI, 1, chr_info.attr_point_1}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_LILIANG, 1, chr_info.attr_point_2}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_MINJIE, 1, chr_info.attr_point_3}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_ZHIHUI, 1, chr_info.attr_point_4}
    attrdata[#attrdata+1] = {ATTR_TYPE.ATTR_JINGSHEN, 1, chr_info.attr_point_5}
    self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL] = attrdata
    self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_LEVEL, self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL])
    self:sendLevelInfo()
    self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
end

function level_module:onGetLevelGift(d)
    local level = d.i32
    local giftdone = self._level_gift[level]
    local chr_info = self._chr_info
    if giftdone == nil then
        if chr_info.level >= level then
            
            local icfg = _cfg.hunshiroad(level)
            if icfg == nil then
                return
            end

            if icfg.reward then
                if self:addBagCheck(icfg.reward) then
                    self:addBag(icfg.reward, CHANGE_REASON.CR_LEVEL_GIFT)
                    self._level_gift[level] = 1
                    self:sendLevelGiftInfo(level, level);

                    local dbupdate = {
                        cid = self.cid,
                        level = level,
                        done = 1,
                    }
                    self:dbUpdateData(_table.TAB_mem_chr_level_gift,dbupdate)

                else
                    return
                end
            end


        end
    end
end

function level_module:onLevelGiftInfo(d)
    local levelbegin = d.i32[1]
    local levelend = d.i32[2]
    if levelbegin < 8 then
        return
    end
    if levelend > 100 then
        return
    end

    if levelbegin > levelend then
        return
    end

    self:sendLevelGiftInfo(levelbegin, levelend);
end

function level_module:sendLevelGiftInfo(levelbegin, levelend)
    local pb = {}
    local levelgift = self._level_gift

    for i = levelbegin, levelend do
        local giftdone = levelgift[i]
        if giftdone ~= nil then
            pb[#pb+1] = {level = i, done = giftdone} 
        end
    end

	self:sendMsg(_sm.SM_LEVEL_GIFT_INFO,{list=pb},"SmLevelGiftInfo")
end

return level_module