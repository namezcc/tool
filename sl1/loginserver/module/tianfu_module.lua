local _table = TABLE_INDEX
local _cm = CM
local _sm = SM
local _cfg = CFG_DATA
local _msg_func = MSG_FUNC
local _func = LFUNC
local _str_util = STRING_UTIL
local _attr_mod = PLAYER_ATTR_SOURCE

local TIANFU_MAX = {
    BRANCH = 3,
    PAGE = 15,
}

local tianfu_module = {}

local function newTianfu(cid,branch,page,point,active)
    return {
        cid = cid,
        branch = branch,
        page = page,
        point = point,
        active = active,
    }
end

function tianfu_module:init()
	_msg_func.bind_player_proto_func(_cm.CM_TIANFU_ACTIVE, self.onTianfuActive, "ProtoInt32Array")
	_msg_func.bind_player_proto_func(_cm.CM_TIANFU_RESET, self.onTianfuReset, "ProtoInt32Array")
end

function tianfu_module:initDB(data)
    self._tianfu = {}
    if data.tianfu then
        for _, v in pairs(data.tianfu) do
            if not self._tianfu[v.branch] then
                self._tianfu[v.branch] = {}
            end
            self._tianfu[v.branch][v.page] = table.cloneSimple(v)
            self._tianfu[v.branch][v.page].active = _str_util.splite_int_vec(v.active)
        end
    end
    self:checkUnlockTianfu()
end

function tianfu_module:afterInit()
    self:sendTianfuInfo()
    self:updateModuleAttr(_attr_mod.PAS_TIANFU,true)
end

function tianfu_module:calcTianfuAttr()
    local attr = {}
    for _, vv in pairs(self._tianfu) do
        for _, v in pairs(vv) do
            if v.active then
                for _, index in pairs(v.active) do
                    if index > 0 then
                        local iCfg = _cfg.tianfu_point(v.branch, v.page, index)
                        if iCfg and not table.empty(iCfg.attr) then
                            _func.combindJobAttr(attr, iCfg.attr, self._chr_info.job)
                        end
                    end
                end
            end
        end
    end
    return attr
end

function tianfu_module:onTianfuActive(data)--激活天赋点
    local branch = data.i32[1]
    local page = data.i32[2]
    local index = data.i32[3]

    if branch < 1 or branch > TIANFU_MAX.BRANCH then
        return
    end
    if page < 1 or page > TIANFU_MAX.PAGE then
        return
    end
    if index < 1 then
        return
    end

    local chrInfo = self._chr_info
    if chrInfo == nil then
        return
    end
    local point = chrInfo.xuantian1
    if branch == 2 then
        point = chrInfo.xuantian2
    elseif branch == 3 then
        point = chrInfo.xuantian3
    end

    if point == 0 then
        return
    end

    local tianfu = self._tianfu[branch][page]
    if tianfu == nil then
        return
    end
    if tianfu.active ~= nil then
        for _, value in pairs(tianfu.active) do
            if value == index then
                return
            end
        end
    end

    local iCfg = _cfg.tianfu_point(branch, page, index)
    if iCfg == nil then
        return
    end
    if iCfg.branch ~= branch or iCfg.page ~= page or iCfg.index ~= index then
        return
    end

    if point < iCfg.cost  then
        return
    end

    if index > 1 then
        local bCheck = false
        if iCfg.next then
            for _, vc in ipairs(iCfg.next) do
                if not tianfu.active or bCheck then
                    break
                end
                for _, va in pairs(tianfu.active) do
                    if vc == va then
                        bCheck = true
                        break
                    end
                end
            end
        end
        if not bCheck then
            return
        end
    end

    if iCfg.type == 5 and iCfg.skill > 0 then
		self:updateSkill(iCfg.skill,1) --激活技能
    end

    if branch == 1 then
        self._chr_info.xuantian1 = self._chr_info.xuantian1 - iCfg.cost
    elseif branch == 2 then
        self._chr_info.xuantian2 = self._chr_info.xuantian2 - iCfg.cost
    else
        self._chr_info.xuantian3 = self._chr_info.xuantian3 - iCfg.cost
    end
    self._tianfu[branch][page].point = tianfu.point + iCfg.cost
    local act = self._tianfu[branch][page].active
    act[#act+1] = index
    self._tianfu[branch][page].active = act
    self:checkUnlockTianfu(branch)

    self:updateModuleAttr(_attr_mod.PAS_TIANFU)
    self:sendLevelInfo()
    self:sendTianfuInfo(branch,page)
    self:syncTianfuChange()
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_TIANFU, branch, self:getTianfuPoint(branch), 1)
end

function tianfu_module:onTianfuReset(data)--重置天赋点
    local branch = data.i32[1]
    local page = data.i32[2]

    if branch < 1 or branch > TIANFU_MAX.BRANCH then
        return
    end
    if page < 1 or page > TIANFU_MAX.PAGE then
        return
    end

    local tianfu = self._tianfu[branch][page]
    if tianfu == nil or #tianfu.active == 0 then
        return
    end

    local iCfg = _cfg.tianfu(branch, page)
    if iCfg == nil then
        return
    end
    if iCfg.branch ~= branch or iCfg.page ~= page then
        return
    end

    if not self:delBagCheck(iCfg.reset) then
        return
    end

    if #tianfu.active > 0 then
        local pb = {}
        for _, value in pairs(tianfu.active) do
            if value > 0 then
                local pCfg = _cfg.tianfu_point(branch, page, value)
                if pCfg ~= nil and pCfg.branch == branch and pCfg.page == page and pCfg.index == value then
                    if pCfg.type == 5 and pCfg.skill > 0 then
                        pb[#pb+1] = {pCfg.skill, 0} --重置技能
                    end
                end
            end
        end
        if #pb > 0 then
            self:updateSkillList(pb)
        end
    end

    self:delBag(iCfg.reset,CHANGE_REASON.CR_TIANFU_RESET)
    if branch == 1 then
        self._chr_info.xuantian1 = self._chr_info.xuantian1 + tianfu.point
    elseif branch == 2 then
        self._chr_info.xuantian2 = self._chr_info.xuantian2 + tianfu.point
    else
        self._chr_info.xuantian3 = self._chr_info.xuantian3 + tianfu.point
    end
    self._tianfu[branch][page].point = 0
    self._tianfu[branch][page].active = {}

    self:updateModuleAttr(_attr_mod.PAS_TIANFU)
    self:sendLevelInfo()
    self:sendTianfuInfo(branch,page)
    self:syncTianfuChange()
end

function tianfu_module:loadTianfuSkill(pdata)
    local pb = pdata.skill_level_info
    local tianfu = self._tianfu
    for _, vv in pairs(tianfu) do
        for _, v in pairs(vv) do
            for _, index in pairs(v.active) do
                if index > 0 then
                    local iCfg = _cfg.tianfu_point(v.branch,v.page,index)
                    if iCfg ~= nil and iCfg.type == 5 and iCfg.skill > 0 then
                        pb[#pb+1] = {skill_id = iCfg.skill, level = 1, hunyin = {}}
                    end
                end
            end
        end
    end
    pdata.skill_level_info = pb
end

function tianfu_module:checkUnlockTianfu(branch)
    if not branch then
        for i = 1, TIANFU_MAX.BRANCH, 1 do --默认解锁3分支第1页
            if not self._tianfu[i] then
                self._tianfu[i] = {}
            end
            if not self._tianfu[i][1] then
                self._tianfu[i][1] = newTianfu(self.cid,i,1,0,{})
            end
        end
    else
        if branch < 1 or branch > TIANFU_MAX.BRANCH  then
            return
        end
        local point = 0
        for page = 1, TIANFU_MAX.PAGE, 1 do
            if self._tianfu[branch] and self._tianfu[branch][page] then
                point = point + self._tianfu[branch][page].point
            end
        end
        for page = 2, TIANFU_MAX.PAGE, 1 do
            if not self._tianfu[branch] then
                self._tianfu[branch] = {}
            end
            if not self._tianfu[branch][page] then
                local preCfg = _cfg.tianfu(branch, page-1)
                if preCfg and preCfg.unlock <= point then
                    self._tianfu[branch][page] = newTianfu(self.cid,branch,page,0,{})
                end
            end
        end
    end
end

function tianfu_module:getTianfuPoint(branch)
    local point = 0
    if not branch then
        for b = 1, TIANFU_MAX.BRANCH, 1 do
            for p = 1, TIANFU_MAX.PAGE, 1 do
                if self._tianfu[b] and self._tianfu[b][p] then
                    point = point + self._tianfu[b][p].point
                end
            end
        end
    else
        if branch >= 1 and branch <= TIANFU_MAX.BRANCH  then
            for page = 1, TIANFU_MAX.PAGE, 1 do
                if self._tianfu[branch] and self._tianfu[branch][page] then
                    point = point + self._tianfu[branch][page].point
                end
            end
        end
    end
    return point
end

function tianfu_module:addTianfuPoint(num1,num2,num3)
    if num1 and num1 > 0 then
        self._chr_info.xuantian1 = self._chr_info.xuantian1 + num1
    end
    if num2 and num2 > 0 then
        self._chr_info.xuantian2 = self._chr_info.xuantian2 + num2
    end
    if num3 and num3 > 0 then
        self._chr_info.xuantian3 = self._chr_info.xuantian3 + num3
    end
    self:sendLevelInfo()
end

function tianfu_module:sendTianfuInfo(branch,page)
    local pb = {}
    if branch and page then
        if branch < 1 or branch > TIANFU_MAX.BRANCH then
            return
        end
        if page < 1 or page > TIANFU_MAX.PAGE then
            return
        end
        if not self._tianfu[branch] then
            return
        end
        local tianfu = self._tianfu[branch][page]
        if tianfu then
            pb[#pb+1] = {
                branch = tianfu.branch,
                page = tianfu.page,
                point = tianfu.point,
                active = table.concat(tianfu.active,":"),
            }
        end
    else
        for _, vv in pairs(self._tianfu) do
            for _, v in pairs(vv) do
                pb[#pb+1] = {
                    branch = v.branch,
                    page = v.page,
                    point = v.point,
                    active = table.concat(v.active,":"),
                }
            end
        end
    end

    if #pb > 0 then
        self:sendMsg(_sm.SM_TIANFU_INFO,{tianfu = pb},"SmTianfuInfo")
    end
end

function tianfu_module:syncTianfuChange()
    local tianfu = self._tianfu
    if tianfu == nil then
        return
    end
    local dbupdate = {}
    for _, vv in pairs(tianfu) do
        for _, v in pairs(vv) do
            dbupdate[#dbupdate+1] = {
                cid = v.cid,
                branch = v.branch,
                page = v.page,
                point = v.point,
                active = table.concat(v.active,":"),
            }
        end
    end
    if #dbupdate > 0 then
        self:dbUpdateDataVector(_table.TAB_mem_chr_tianfu,dbupdate)
    end
end

return tianfu_module