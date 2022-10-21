local _table = TABLE_INDEX
local _cm = CM
local _sm = SM
local _cfg = CFG_DATA
local _msg_func = MSG_FUNC
local _func = LFUNC
local _str_util = STRING_UTIL
local _time = TIME_UTIL

local vitality_module = {}

local VIT_TASK_CONDITION = {
    LEVEL = 1,
    WEEK = 2,
    TIME = 3,
}

local function newVitality(vit,state,total,count,time,task)
    return {
        vit = vit,
        state = state,
        total = total,
        count = count,
        time = time,
        task = task,
    }
end

local function newVitalityTask(tid,state,progress)
    return {
        tid = tid,
        state = state,
        progress = progress,
    }
end

function vitality_module:init()
	_msg_func.bind_player_proto_func(_cm.CM_VITALITY_ACT, self.onVitalityAct, "ProtoInt32Array")
end

function vitality_module:initDB(data)
    self._vitality = newVitality(0, 0, 0, 0, 0, {})
    if data.vit_gift ~= nil then
        self._vitality.vit = data.vit_gift.vit
        self._vitality.state = data.vit_gift.state
        self._vitality.total = data.vit_gift.total
        self._vitality.count = data.vit_gift.count
        self._vitality.time = data.vit_gift.time
    end
    if data.vit_task ~= nil then
        for _, value in pairs(data.vit_task) do
            self._vitality.task[value.tid] = table.cloneSimple(value)
        end
    end
end

function vitality_module:afterInit()
    self:checkResetVit()
    self:sendVitInfo()
end

function vitality_module:onVitalityAct(data)
    local type = data.i32[1] --1:vit_task,2:vit_gift

    if type == 1 then
        local taskId = data.i32[2]
        self:submitVitTask(taskId)
    elseif type == 2 then
        local id = data.i32[2]
        self:getVitGift(id)
    end
end

function vitality_module:submitVitTask(tid)
    local task = self._vitality.task[tid]
    if task == nil then
        return
    end
    if task.tid ~= tid then
        return
    end
    if task.state ~= TASK_STATE.TSTATE_CAN_SUBMIT then
        return
    end

    local iCfg = _cfg.vit_task(tid)
    if iCfg == nil then
        return
    end
    if iCfg.progress > task.progress then
        return
    end
    if not self:addBagCheck(iCfg.gift) then
        return
    end

    self:addBag(iCfg.gift, CHANGE_REASON.CR_VIT_TASK)
    self._vitality.vit = self._vitality.vit + iCfg.vit
    self._vitality.total = self._vitality.total + iCfg.vit
    self._vitality.task[tid].state = TASK_STATE.TSTATE_DONE
    self:syncVitTaskInfo({tid})
    self:syncVitGiftInfo()
    self:sendVitInfo()
end

function vitality_module:getVitGift(id)
    if id < 0 then
        return
    end

    if id == 0 then
        local iCfg = {}
        local count = self._vitality.count + 1
        for i = 1, 99 do
            iCfg = _cfg.vit_total_gift(i)
            if iCfg and iCfg.min <= count and iCfg.max >= count then
                break
            end
        end
        if #iCfg < 1 then
            return
        end
        if iCfg.vit > self._vitality.total then
            return
        end
        if count > 1 then
            if not self:addBagCheck(iCfg.gift) then
                return
            end
            self:addBag(iCfg.gift, CHANGE_REASON.CR_VIT_GIFT)
        end
        self._vitality.total = 0
        self._vitality.count = count
    else
        local iCfg = _cfg.vit_gift(id)
        if iCfg == nil then
            return
        end
        if iCfg.vit > self._vitality.vit then
            return
        end
        if _func.is_bit_on(self._vitality.state, id) then
            return
        end
        if not self:addBagCheck(iCfg.gift) then
            return
        end
        self:addBag(iCfg.gift, CHANGE_REASON.CR_VIT_GIFT)
        self._vitality.state = _func.set_bit_on(self._vitality.state, id)
    end
    self:syncVitGiftInfo()
    self:sendVitInfo()
end

function vitality_module:updateVitTaskProgress(type,progress)
    local add = {}
    local del = {}
    for tid, task in pairs(self._vitality.task) do
        if task.state == TASK_STATE.TSTATE_DOING then
            local iCfg = _cfg.vit_task(tid)
            if iCfg and iCfg.type == type then
                if not self:checkVitTaskCondition(iCfg) then
                    self._vitality.task[tid] = nil
                    del[#del+1] = tid
                else
                    self._vitality.task[tid].progress = self._vitality.task[tid].progress + progress
                    if self._vitality.task[tid].progress >= iCfg.progress then
                        self._vitality.task[tid].state = TASK_STATE.TSTATE_CAN_SUBMIT
                    end
                    add[#add+1] = tid
                end
            end
        end
    end
    for tid = 1, 99, 1 do
        if not self._vitality.task[tid] then
            local iCfg = _cfg.vit_task(tid)
            if iCfg and iCfg.type == type then
                if self:checkVitTaskCondition(iCfg) then
                    local state = TASK_STATE.TSTATE_DOING
                    if progress >= iCfg.progress then
                        state = TASK_STATE.TSTATE_CAN_SUBMIT
                    end
                    self._vitality.task[tid] = newVitalityTask(tid, state, progress)
                    add[#add+1] = tid
                end
            end
        end
    end
    self:syncVitTaskInfo(add,del)
    self:sendVitInfo()
end

function vitality_module:checkResetVit()
    local now = _func.getNowSecond()
    local time = self._vitality.time or 0
    if time == 0 then
        self._vitality.time = now
    else
        local tm = os.date("*t", now) -- 新的一天且 hour >= 5
        if tm.hour < 5 then
            return
        end
        if _time.week_diff(time, now) then
            self._vitality.time = now
            self:resetVit(2)
        elseif _time.day_diff(time, now) ~= 0 then
            self._vitality.time = now
            self:resetVit(1)
        end
    end
end

function vitality_module:resetVit(flag) --flag:1-new_day,2-new_week
    self._vitality.vit = 0
    self._vitality.state = 0

    local del = {}
    local add = {}
    if self._vitality.task then
        for _, v in pairs(self._vitality.task) do
            local iCfg = _cfg.vit_task(v.tid)
            if iCfg == nil then
                self._vitality.task[v.tid] = nil
                del[#del+1] = v.tid
                goto continue
            end
            if not self:checkVitTaskCondition(iCfg) then
                self._vitality.task[v.tid] = nil
                del[#del+1] = v.tid
                goto continue
            end
            if flag == 1 and iCfg.group == 3 then
                goto continue
            end

            self._vitality.task[v.tid].progress = 0
            self._vitality.task[v.tid].state = TASK_STATE.TSTATE_DOING
            add[#add+1] = v.tid

            ::continue::
        end
    end
    self:syncVitGiftInfo()
    self:syncVitTaskInfo(add, del)
    self:sendVitInfo()
end

function vitality_module:checkVitTaskCondition(cfg)
    if cfg == nil then
        return false
    end
    if cfg.condition == nil then
        return true
    end
    local check = true
    for _, v in pairs(cfg.condition) do
        if v[1] == VIT_TASK_CONDITION.LEVEL then -- 等级
            check = self._chr_info.level >= v[2]
        elseif v[1] == VIT_TASK_CONDITION.WEEK then -- 星期
            local tm = os.date("*t", os.time())
            local wday = tm.wday - 1
            if wday == 0 then
                wday = 7
            end
            check = _func.is_bit_on(v[2], wday)
        elseif v[1] == VIT_TASK_CONDITION.TIME then -- 时间段内
            local tm = os.date("*t", os.time())
            check = tm.hour >= v[2] and tm.min >= v[3] and tm.hour <= v[4] and tm.min <= v[5]
        end
        if check == false then
            break
        end
    end
    return check
end

function vitality_module:addVit(vit)
    if vit <= 0 then
        return
    end
    self._vitality.vit = self._vitality.vit + vit
    self._vitality.total = self._vitality.total + vit
    self:syncVitGiftInfo()
    self:sendVitInfo()
end

function vitality_module:sendVitInfo()
    local vitality = self._vitality
    if vitality == nil then
        return
    end

    local taskPb = {}
    if vitality.task then
        for _, v in pairs(vitality.task) do
            taskPb[#taskPb+1] = v
        end
    end
    local pb = {
        vit = vitality.vit or 0,
        state = vitality.state or 0,
        total = vitality.total or 0,
        count = vitality.count or 0,
        task = taskPb
    }
    self:sendMsg(_sm.SM_VITALITY_INFO,pb,"SmVitalityInfo")
end

function vitality_module:syncVitGiftInfo()
    local dbupdate = {
        cid = self.cid,
        vit = self._vitality.vit,
        state = self._vitality.state,
        total = self._vitality.total,
        count = self._vitality.count,
        time = self._vitality.time,
    }
    self:dbUpdateData(_table.TAB_mem_chr_vit_gift,dbupdate)
end

function vitality_module:syncVitTaskInfo(add,del)
    local dbupdate = {}
    if add then
        for _, v in pairs(add) do
            local task = self._vitality.task[v]
            if task ~= nil then
                dbupdate[#dbupdate +1] = {
                    cid = self.cid,
                    tid = task.tid,
                    state = task.state,
                    progress = task.progress
                }
            end
        end
    end

    local dbdelete = {}
    if del then
        for _, v in pairs(del) do
            local task = self._vitality.task[v]
            if task == nil then
                dbdelete[#dbdelete +1] = {
                    cid = self.cid,
                    tid = v
                }
            end
        end
    end

    if #dbupdate > 0 then
        self:dbUpdateDataVector(_table.TAB_mem_chr_vit_task,dbupdate)
    end

    if #dbdelete > 0 then
        self:dbDeleteDataVector(_table.TAB_mem_chr_vit_task,dbdelete)
    end
end

return vitality_module