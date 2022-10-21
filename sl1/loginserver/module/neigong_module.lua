local _table = TABLE_INDEX
local _cm = CM
local _sm = SM
local _cfg = CFG_DATA
local _msg_func = MSG_FUNC
local _func = LFUNC
local _string_util = STRING_UTIL
local _attr_mod = PLAYER_ATTR_SOURCE

local NEIGONG_NUM = {
    TYPE_MIN = 1,
    TYPE_MAX = 8,
}

local neigong_module = {}

local function newNeigong(grade,level,ratio,neili,time)
    return {
        grade = grade,
        level = level,
        ratio = ratio,
        neili = neili,
        time = time,
    }
end

local function getNeigong(neigong)
    return {
        grade = neigong.grade,
        level = _string_util.splite_int_vec(neigong.level),
        ratio = _string_util.splite_int_vec(neigong.ratio),
        neili = neigong.neili,
        time = neigong.time,
    }
end

function neigong_module:init()
	_msg_func.bind_player_proto_func(_cm.CM_NEIGONG_UPGRADE, self.onNeigongUpgrade, "ProtoInt32")
	_msg_func.bind_player_proto_func(_cm.CM_NEIGONG_NEILI, self.onNeigongNeiliGet, "ProtoInt32")
end

function neigong_module:initDB(data)
    self._neigong = newNeigong(1,{8,8,8,8,8,8,8,8},{0,0,0,0,0,0,0,0},0,_func.getNowSecond())--默认开启1级玄天功,8级经脉
    if _func.checkPlayerData(data.neigong) then
        self._neigong = getNeigong(data.neigong)
    else
        self:syncNeigongChange()
    end
end

function neigong_module:afterInit()
    self:sendNeigongInfo()
    self:updateModuleAttr(_attr_mod.PAS_NEIGONG,true)
end

function neigong_module:calcNeigongAttr()
    local attr = {}
    local neigong = self._neigong
    if neigong then
        local gradeCfg = _cfg.neigong_grade(neigong.grade)
        if gradeCfg ~= nil and gradeCfg.attr ~= nil then
            _func.combindJobAttr(attr, gradeCfg.attr, self._chr_info.job)
        end
        for k, v in pairs(neigong.level) do
            local levelCfg = _cfg.neigong_level(k, v)
            if levelCfg ~= nil and levelCfg.attr ~= nil then
                _func.combindJobAttr(attr, levelCfg.attr, self._chr_info.job)
            end
        end
    end
    return attr
end

function neigong_module:onNeigongUpgrade(data)--升级玄天功/玄天功经脉
    local type = tonumber(data.i32)
    if type < 0 or type > 8 then--0:grade,1-8:level
        return
    end

    local neigong = self._neigong
    if type == 0 then
        local nCfg = _cfg.neigong_grade(neigong.grade + 1)
        if nCfg == nil then
            return
        end
        for i=NEIGONG_NUM.TYPE_MIN,NEIGONG_NUM.TYPE_MAX do
            local level = neigong.level[i]
            if level ~= neigong.level[NEIGONG_NUM.TYPE_MIN] or level % 10 ~= 0 then
                return
            end
        end
        local iCfg = _cfg.neigong_grade(neigong.grade)
        if iCfg == nil then
            return
        end
        if iCfg.param > self._chr_info.hunshi then
            return
        end

        self._neigong.grade = neigong.grade + 1
        self._chr_info.xuantian1 = self._chr_info.xuantian1 + iCfg.point
        self:sendLevelInfo()
        self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_NEIGONG_GRADE, 0, 1)
        self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_NEIGONG_GRADE, self._neigong.grade, 1, 1)
    else
        local level = neigong.level[type] or 0
        local iCfg = _cfg.neigong_level(type, level + 1)
        if iCfg == nil then
            return
        end
        if iCfg.cost > neigong.neili then
            return
        end
        if iCfg.grade > neigong.grade then
            return
        end

        local ratio = iCfg.rate + neigong.ratio[type]
        if math.random(1,100) > ratio then -- fail,+5%
            self._neigong.ratio[type] = self._neigong.ratio[type] + 5
        else
            self._neigong.ratio[type] = 0
            self._neigong.level[type] = level + 1
        end
        self._neigong.neili = neigong.neili - iCfg.cost
    end
    self:updateModuleAttr(_attr_mod.PAS_NEIGONG)
    self:sendNeigongInfo()
    self:syncNeigongChange()
end

function neigong_module:onNeigongNeiliGet(data)
    local gold = data.i32
    local neigong = self._neigong
    if gold <= 0 then
        local addon = self:calcNeili() --领取内力池中的内力
        if addon <= 0 then
            return
        end
        self._neigong.time = _func.getNowSecond()
        self._neigong.neili = neigong.neili + addon
        self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_NEILI_GET, 1)
    else
        local count = self:getRecord(RECORD_TYPE.RT_DAILY_NEILI_BUY_COUNT)
        local add = 0
        for id = 1, 100, 1 do
            local iCfg = _cfg.index_number(id)
            if iCfg ~= nil and iCfg.min <= count and count <= iCfg.max then
                if iCfg.del ~= gold then
                    return
                end
                add = iCfg.add
            end
        end
        if add == 0 then
            return
        end
        if self:getCurrency(CURRENCY_TYPE.CT_JINHUNBI) < gold then --使用金魂币兑换内力
            return
        end
        self:updateRecord(RECORD_TYPE.RT_DAILY_NEILI_BUY_COUNT,count+1)
        self:addCurrency(CURRENCY_TYPE.CT_JINHUNBI,-gold,CHANGE_REASON.CR_NEIGONG)
        self._neigong.neili = neigong.neili + add
    end
    self:sendNeigongInfo()
    self:syncNeigongChange()
end

function neigong_module:calcNeili()
    local neigong = self._neigong
    if neigong == nil or neigong.time <= 0 then
        return 0
    end
    local lCfg = _cfg.level(self._chr_info.level)
    if not lCfg then
        return 0
    end
    local gCfg = _cfg.neigong_grade(neigong.grade)
    if not gCfg then
        return 0
    end
    local time = _func.getNowSecond() - neigong.time
    if time < 60 then
        return 0
    end
    local addon = math.ceil(time / 60 * lCfg.addon)
    if addon > gCfg.pool then
        addon = gCfg.pool
    end
    return addon
end

function neigong_module:addNeili(num, flv)
    if flv then
        local lCfg = _cfg.level(self._chr_info.level)
        if lCfg and lCfg.flv_neili and lCfg.flv_neili > 0 then
            num = num * lCfg.flv_neili
        end
    end
    self._neigong.neili = self._neigong.neili + num
    if self._neigong.neili < 0 then
        self._neigong.neili = 0
    end
    self:sendNeigongInfo()
    self:syncNeigongChange()
end

function neigong_module:sendNeigongInfo()
    local neigong = self._neigong
    local pb = {
        grade = neigong.grade,
        level = neigong.level,
        ratio = neigong.ratio,
        neili = neigong.neili,
        time = neigong.time,
        buy_count = self:getRecord(RECORD_TYPE.RT_DAILY_NEILI_BUY_COUNT)
	}
	self:sendMsg(_sm.SM_NEIGONG_INFO,pb,"SmNeigongInfo")
end

function neigong_module:syncNeigongChange()
    local neigong = self._neigong
    if neigong == nil then
        return
    end
    local dbupdate = {
        cid = self.cid,
        grade = neigong.grade,
        level = table.concat(neigong.level,":"),
        ratio = table.concat(neigong.ratio,":"),
        neili = neigong.neili,
        time = neigong.time,
    }
    self:dbUpdateData(_table.TAB_mem_chr_neigong,dbupdate)
end

return neigong_module