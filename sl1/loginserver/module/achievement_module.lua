local _table = TABLE_INDEX
local _cm = CM
local _sm = SM
local _cfg = CFG_DATA
local _msg_func = MSG_FUNC
local _func = LFUNC
local _attr_mod = PLAYER_ATTR_SOURCE

local achievement_module = {}

local function newAchievementTask(tid,state,progress,time)
    return {
        tid = tid,
        state = state,
        progress = progress,
        time = time,
    }
end

function achievement_module:init()
    _msg_func.bind_player_proto_func(_cm.CM_ACHIEVEMENT_ACT, self.onAchievementAct, "ProtoInt32")
    --_msg_func.bind_player_proto_func(_cm.CM_ACHIEVEMENT_UPDATE, self.onAchievementUpdate, "ProtoInt32Array")
end

function achievement_module:initDB(data)
    self._achievement = {level = 0, point = 0, task = {}}
    if data.achievement ~= nil then
        self._achievement.level = data.achievement.level
        self._achievement.point = data.achievement.point
    end
    if data.achievement_task ~= nil then
        for _, value in pairs(data.achievement_task) do
            self._achievement.task[value.tid] = table.cloneSimple(value)
        end
    end
end

function achievement_module:afterInit()
    self:sendAchievementInfo()
    self:updateModuleAttr(_attr_mod.PAS_ACHIEVEMENT,true)
end

function achievement_module:onAchievementAct(data)
    local tid = data.i32
    local task = self._achievement.task[tid]
    if task == nil or task.tid ~= tid then
        return
    end
    if task.state ~= TASK_STATE.TSTATE_CAN_SUBMIT then
        return
    end
    local iCfg = _cfg.achievement_task(tid)
    if iCfg == nil then
        return
    end
    if iCfg.progress > task.progress then
        return
    end
    if not self:addBagCheck(iCfg.gift) then
        return
    end

    self:addBag(iCfg.gift, CHANGE_REASON.CR_ACHIEVEMENT)
    self:addAchievementPoint(iCfg.point)
    self._achievement.task[tid].state = TASK_STATE.TSTATE_DONE
    self:syncAchievement()
    self:syncAchievementTask({tid})
    self:sendAchievementInfo({tid})
end

function achievement_module:onAchievementUpdate(data)
    -- 需要客户端更新的成就类型
    local type = data.i32[1]
    local param = data.i32[2]
    local progress = data.i32[3]
    local tp = data.i32[4]
    if type == ACHIEVEMENT_TYPE.ACH_ANQI_WSXJ or
        type == ACHIEVEMENT_TYPE.ACH_ANQI_FTSZ_1 or
        type == ACHIEVEMENT_TYPE.ACH_ANQI_FTSZ_2 or
        type == ACHIEVEMENT_TYPE.ACH_FLY or
        type == ACHIEVEMENT_TYPE.ACH_FLY_SPEED or
        type == ACHIEVEMENT_TYPE.ACH_DIVING then
        --服务端验证
        self:updateAchievementProgress(type,param,progress,tp)
    end
end

function achievement_module:addAchievementPoint(point)
    self._achievement.point = self._achievement.point + point
    local level = self._achievement.level
    for lv = self._achievement.level+1, 999, 1 do
        local iCfg = _cfg.achievement(lv)
        if iCfg == nil or iCfg.point > self._achievement.point then
            break
        end
        level = iCfg.level
    end
    if level ~= self._achievement.level then
        self._achievement.level = level
        self:updateModuleAttr(_attr_mod.PAS_ACHIEVEMENT)
    end
end

function achievement_module:updateAchievementProgress(type,param,progress,tp)
    local upper = false
    if type == ACHIEVEMENT_TYPE.ACH_LEVEL or type == ACHIEVEMENT_TYPE.ACH_WUHUN_JUEXING or
        type == ACHIEVEMENT_TYPE.ACH_WUHUN_JINHUA or type == ACHIEVEMENT_TYPE.ACH_WING_TUPO or
        type == ACHIEVEMENT_TYPE.ACH_POSITION or type == ACHIEVEMENT_TYPE.ACH_GRASS or
        type == ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_HUNQI or type == ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_BONE or
        type == ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_EQUIP or type == ACHIEVEMENT_TYPE.ACH_MEILI or
        type == ACHIEVEMENT_TYPE.ACH_HUNYIN or type == ACHIEVEMENT_TYPE.ACH_NEIGONG_GRADE or
        type == ACHIEVEMENT_TYPE.ACH_SHOOT then
        upper = true
    end

    local add = {}
    for tid, task in pairs(self._achievement.task) do
        if task.state == TASK_STATE.TSTATE_DOING then
            local iCfg = _cfg.achievement_task(tid)
            if iCfg and iCfg.type == type then
                if param == iCfg.param or (param > iCfg.param and upper) then
                    local change = -1
                    if tp then
                        if progress > task.progress then
                            change = progress
                        end
                    else
                        change = task.progress + progress
                    end
                    if change > 0 then
                        self._achievement.task[tid].progress = change
                        if self._achievement.task[tid].progress >= iCfg.progress then
                            self._achievement.task[tid].state = TASK_STATE.TSTATE_CAN_SUBMIT
                            self._achievement.task[tid].time = _func.getNowSecond()
                        end
                        add[#add+1] = tid
                    end
                end
            end
        end
    end

    for tid = 1, 999, 1 do
        if not self._achievement.task[tid] then
            local iCfg = _cfg.achievement_task(tid)
            if iCfg and iCfg.type == type then
                if param == iCfg.param or (param > iCfg.param and upper) then
                    local state = TASK_STATE.TSTATE_DOING
                    local time = 0
                    if progress >= iCfg.progress then
                        state = TASK_STATE.TSTATE_CAN_SUBMIT
                        time = _func.getNowSecond()
                    end
                    self._achievement.task[tid] = newAchievementTask(tid, state, progress, time)
                    add[#add+1] = tid
                end
            end
        end
    end
    self:syncAchievementTask(add)
    self:sendAchievementInfo(add)
end

function achievement_module:calcAchievementAttr()
    local attr = {}
    local iCfg = _cfg.achievement(self._achievement.level)
    if iCfg and iCfg.attr then
        _func.combindAttr(attr,iCfg.attr)
    end
    return attr
end

function achievement_module:sendAchievementInfo(update)
    local ach = self._achievement
    if ach == nil then
        return
    end
    local taskPb = {}
    if ach.task ~= nil then
        if update then
            for _, v in pairs(update) do
                local task = ach.task[v]
                if task then
                    taskPb[#taskPb+1] = task
                end
            end
        else
            for _, v in pairs(ach.task) do
                taskPb[#taskPb+1] = v
            end
        end
    end
    local pb = {
        level = ach.level,
        point = ach.point,
        task = taskPb,
    }
    self:sendMsg(_sm.SM_ACHIEVEMENT_INFO,pb,"SmAchievementInfo")
end

function achievement_module:syncAchievement()
    if self._achievement == nil then
        return
    end
    local dbupdate = {
        cid = self.cid,
        level = self._achievement.level,
        point = self._achievement.point,
    }
    self:dbUpdateData(_table.TAB_mem_chr_achievement,dbupdate)
end

function achievement_module:syncAchievementTask(update)
    local dbupdate = {}
    if update then
        for _, v in pairs(update) do
            if self._achievement.task then
                local task = self._achievement.task[v]
                if task then
                    dbupdate[#dbupdate+1] = {
                        cid = self.cid,
                        tid = task.tid,
                        progress = task.progress,
                        state = task.state,
                        time = task.time,
                    }
                end
            end
        end
    end

    if #dbupdate > 0 then
        self:dbUpdateDataVector(_table.TAB_mem_chr_achievement_task,dbupdate)
    end
end

return achievement_module