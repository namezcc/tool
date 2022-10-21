local _ST = STORAGE_TYPE
local _IT = ITEM_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _cm = CM
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _net_mgr = nil
local _strutil = STRING_UTIL
local _func = LFUNC
local _time = TIME_UTIL
local task_module = {}

local CSPECIAL_ALL = 0
local CSPECIAL_ONE = 1
local CSPECIAL_CERTAIN = 2

function task_module:init()
    _net_mgr = MOD.net_mgr_module
    _msg_func.bind_player_proto_func(_cm.CM_TASK_INFO, self.onTaskInfo, "ProtoInt32Array")
    _msg_func.bind_player_proto_func(_cm.CM_RECEIVE_TASK, self.onReceiveTask, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_SUBMIT_TASK, self.onSubmitTask, "ProtoInt32")
    _msg_func.bind_async_player_proto(_cm.CM_CHECK_TASK_PROGRESS,self.onCheckTaskProgress,"ProtoInt32Array")
    _msg_func.bind_player_proto_func(_cm.CM_CHECK_TASK_PROGRESS_N,self.onCheckTaskProgressN,"ProtoInt32")
    _msg_func.bind_player_server_proto(SERVER_MSG.IM_LOGIN_PLAYER_UPDATE_TASK_PROGRESS,self.onUpdateTaskProgress,"ImUpdateTaskProgress")
    _msg_func.bind_player_server_proto(SERVER_MSG.IM_LOGIN_PLAYER_RECEIVE_TASK, self.onReceiveTask, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_GET_TASK_GIFT, self.onGetTaskGift, "ProtoInt32Array")
end

function task_module:initDB(data)
	self._task_trunk = {}
    if data.task_trunk then
        for i, v in ipairs(data.task_trunk) do
            self._task_trunk[v.tid] = v
        end
    end

    self._task_xy = {}
    self._task_tddg = {}
    self._task_xldg = {}
    --self._task_whd = {}
    if data.task_random then
        for _, v in pairs(data.task_random) do
            if v.ttype == TASK_TYPE.TTYPE_DAILY_XY then
                self._task_xy[v.tid] = v
                self._task_xy[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
            elseif v.ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
                self._task_tddg[v.tid] = v
                self._task_tddg[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
            elseif v.ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
                self._task_xldg[v.tid] = v
                self._task_xldg[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
            --elseif v.ttype == TASK_TYPE.TTYPE_WEEK_WHD then
            --    self._task_whd[v.tid] = v
            --    self._task_whd[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
            end
        end
    end

    self._task_baoxiang = {}
    if data.baoxiang_task then
        for _, v in ipairs(data.baoxiang_task) do
            self._task_baoxiang[v.tid] = v
            self._task_baoxiang[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
        end
    end

    self._task_branch = {}
    if data.task_branch then
        for _, v in ipairs(data.task_branch) do
            self._task_branch[v.tid] = v
            self._task_branch[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
        end
    end

    self._task_zj = {}
    if data.task_zhuanji then
        for _, v in ipairs(data.task_zhuanji) do
            self._task_zj[v.tid] = v
            self._task_zj[v.tid].progress = _strutil.splite_int_vec(v.progress,",")
        end
    end

    self._task_round = {}
    if data.task_round then
        for _, v in pairs(data.task_round) do
            self._task_round[v.tid] = v
        end
    end

    self._task_war_token = {}
    if data.task_war_token then
        for _, v in pairs(data.task_war_token) do
            self._task_war_token[v.tid] = v
        end
    end
end

function task_module:onTaskInfo(data)--任务信息
    local type = data.i32[1]
    local done = data.i32[2] -- 1:done task,2:doing | can_submit task
    if type == TASK_TYPE.TTYPE_TRUNK then
        self:sendTaskInfo(type, self._trunk_task_id, self._trunk_task_state, self._trunk_task_progress,self._task_trunk[self._trunk_task_id].time)
    elseif type == TASK_TYPE.TTYPE_DAILY_XY then
        self:sendTaskData()
        self:sendTypeTaskInfo(type)
    elseif type == TASK_TYPE.TTYPE_WEEK_TDDG or type == TASK_TYPE.TTYPE_WEEK_XLDG then
        self:sendTypeTaskInfo(type)
    elseif type == TASK_TYPE.TTYPE_ZHUANJI or type == TASK_TYPE.TTYPE_BRANCH or type == TASK_TYPE.TTYPE_BAOXIANG then
        self:sendTypeTaskInfo(type, done)
    end
end

function task_module:onReceiveTask(data)
    local tid = data.i32
    self:receive(tid)
end

function task_module:onSubmitTask(data)
    local tid = data.i32
    self:submit(tid)
end

function task_module:submitTaskRound(tid)
    local task = self._task_round[tid]
    if not task then
        return
    end
    local iCfg = _cfg.zz_task(tid)
    if not iCfg then
        return
    end
    if iCfg.progress > task.progress then
        return
    end
    if task.state == TASK_STATE.TSTATE_DONE then
        return
    end
    if task.round > 1 then
        local preCancel = true
        for _, v in pairs(self._task_round) do
            if task.round - 1 == v.round and v.state ~= TASK_STATE.TSTATE_DONE then
                preCancel = false
                break
            end
        end
        if not preCancel then
            return
        end
    end
    if not self:addBagCheck(iCfg.reward) then
        return
    end
    self:addBag(iCfg.reward, CHANGE_REASON.CR_TASK_SUBMIT)
    self._task_round[tid].state = TASK_STATE.TSTATE_DONE
    self:sendTaskInfo(TASK_TYPE.TTYPE_ROUND, tid, TASK_STATE.TSTATE_DONE, {task.progress}, 0)
    self:updateTaskRoundDB({tid})
end

function task_module:submitTaskWarToken(tid)
    local task = self._task_war_token[tid]
    if not task then
        return
    end
    local iCfg = _cfg.task_war_token(tid)
    if not iCfg then
        return
    end
    if iCfg.progress > task.progress then
        return
    end
    if task.state == TASK_STATE.TSTATE_DONE then
        return
    end

    self:addWarTokenExp(iCfg.exp)
    self._task_war_token[tid].state = TASK_STATE.TSTATE_DONE
    self:sendTaskInfo(TASK_TYPE.TTYPE_WAR_TOKEN, tid, TASK_STATE.TSTATE_DONE, {task.progress}, 0)
    self:updateTaskWarTokenDB({tid})
end

function task_module:onCheckTaskProgressN(data)
    local tid = data.i32
    if tid == self._trunk_task_id and self._trunk_task_state == TASK_STATE.TSTATE_DOING then
        local icfg = _cfg.task(self._trunk_task_id)
        if icfg then
            if icfg.condition == TASK_CONDITION_TYPE.TCT_GET_ITEM then
            
            end
        end
    end
end

function task_module:onCheckTaskProgress(data, coro)
    local ttp = data.i32[1]
    local tid = data.i32[2]
    local index = data.i32[3]

    local icfg = nil
    if ttp == TASK_TYPE.TTYPE_TRUNK then
        if tid == self._trunk_task_id and self._trunk_task_state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task(self._trunk_task_id)
        end
    elseif ttp == TASK_TYPE.TTYPE_BAOXIANG then
        if self._task_baoxiang[tid] and self._task_baoxiang[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_baoxiang(tid)
        end
    elseif ttp == TASK_TYPE.TTYPE_DAILY_XY then
        if self._task_xy[tid] and self._task_xy[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_group(tid)
        end
    elseif ttp == TASK_TYPE.TTYPE_WEEK_TDDG then
        if self._task_tddg[tid] and self._task_tddg[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_group(tid)
        end
    elseif ttp == TASK_TYPE.TTYPE_WEEK_XLDG then
        if self._task_xldg[tid] and self._task_xldg[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_group(tid)
        end
    elseif ttp == TASK_TYPE.TTYPE_ZHUANJI then
        if self._task_zj[tid] and self._task_zj[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_zhuanji(tid)
        end
    elseif ttp == TASK_TYPE.TTYPE_BRANCH then
        if self._task_branch[tid] and self._task_branch[tid].state == TASK_STATE.TSTATE_DOING then
            icfg = _cfg.task_branch(tid)
        end
    end

    if not icfg then
        return
    end

    local value = icfg.condition_list[index][1]
    if value == TASK_CONDITION_TYPE.TCT_CLOSE_UI_WINDOW then
        local v = self._task_progress[tid]
        if v then
            v.finish[index] = true
            v.process[index] = 1
            v.update = true
        end
        self:updateTaskProgress()
    else
        local checkTaskProgress = {}
        if value == TASK_CONDITION_TYPE.TCT_REACH_PLACE or value == TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER then
            checkTaskProgress = {
                condition = TASK_CONDITION_TYPE.TCT_REACH_PLACE,
                placeid = icfg.condition_list[index][2],
            }
        elseif value == TASK_CONDITION_TYPE.TCT_TALK then
            checkTaskProgress = {
                condition = TASK_CONDITION_TYPE.TCT_TALK,
            }
        end

        local repb = _net_mgr:requestGamePlayerMsg(self,SERVER_MSG.IM_GAME_PLAYER_REQUEST_CHECK_TASK_PROGRESS,checkTaskProgress,"ImCheckTaskProgress",coro,"ProtoInt32")
        if repb == nil then
            --print("request out time")
        elseif repb.i32 == 1 then
            local v = self._task_progress[tid]
            if v then
                if v.condition[index] == TASK_CONDITION_TYPE.TCT_REACH_PLACE or
                 v.condition[index] == TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER or
                 v.condition[index] == TASK_CONDITION_TYPE.TCT_TALK then
                    v.finish[index] = true
                    v.process[index] = 1
                    v.update = true
                end
            end
            self:updateTaskProgress()
        end
    end
end

function task_module:cmdUpdateTaskProgress(ttype,tid)
    local task = {}
    if ttype == TASK_TYPE.TTYPE_TRUNK then
        if not tid or tid <= 1 then
            tid = self._trunk_task_id
        end
        task = self._task_trunk[tid]
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        task = self._task_branch[tid]
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        task = self._task_zj[tid]
    elseif ttype == TASK_TYPE.TTYPE_DAILY_XY then
        task = self._task_xy[tid]
    elseif  ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        task = self._task_tddg[tid]
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        task = self._task_xldg[tid]
    else
        return
    end

    if table.empty(task) then
        return
    end

    if table.empty(self._task_progress[tid]) then
        return
    end

    for k, v in pairs(self._task_progress[tid].condition) do
        local request = self._task_progress[tid].request[k]
        if #request > 0 then
            self._task_progress[tid].process[k] = request[#request]
        else
            self._task_progress[tid].process[k] = 1
        end
        self._task_progress[tid].finish[k] = true
    end

    task.state = TASK_STATE.TSTATE_CAN_SUBMIT
    task.progress = self._task_progress[tid].process
    if ttype == TASK_TYPE.TTYPE_TRUNK then
        self._trunk_task_state = task.state
        self._trunk_task_progress = task.progress
    end
    self:updateTaskDB(ttype, task)
    self:sendTaskInfo(ttype, tid, task.state, task.progress, task.time)
end

function task_module:cmdReceiveTask(ttype,tid)
    local iCfg = {}
    if ttype == TASK_TYPE.TTYPE_TRUNK then
        iCfg = _cfg.task(tid)
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        iCfg = _cfg.task_branch(tid)
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        iCfg = _cfg.task_zhuanji(tid)
    elseif ttype == TASK_TYPE.TTYPE_DAILY_XY or ttype == TASK_TYPE.TTYPE_WEEK_TDDG or ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        iCfg = _cfg.task_group(tid)
    else
        return
    end

    if table.empty(iCfg) then
        return
    end

    local condition = {}
    local process = {}
    local request = {}
    local finish = {}

    for _, v in ipairs(iCfg.condition_list) do
        condition[#condition+1] = v[1]
        process[#process+1] = 0
        local tempreq = {}
        for ti,tv in ipairs(v) do
            if ti > 1 then
                tempreq[#tempreq+1] = tv
            end
        end
        finish[#finish+1] = false
        request[#request+1] = tempreq
    end

    local task = {}
    if ttype == TASK_TYPE.TTYPE_TRUNK then
        self._trunk_task_id = tid
        self._trunk_task_state = TASK_STATE.TSTATE_DOING
        self._trunk_task_progress = process
        task = self._task_trunk
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        task = self._task_branch
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        task = self._task_zj
    elseif ttype == TASK_TYPE.TTYPE_DAILY_XY then
        task = self._task_xy
    elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        task = self._task_tddg
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        task = self._task_xldg
    end

    task[tid] = {cid = self.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
    self._task_progress[tid] = {id = tid, condition_special = iCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
    self:refreshTaskProgress(tid, true)
    self:updateTaskDB(ttype, task[tid])
    self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, task[tid].time)
    self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_RECEIVED,{i32={tid}},"ProtoInt32Array")
end

function task_module:updateProgressByType(processtype, param1, param2, param3)
    if processtype == TASK_CONDITION_TYPE.TCT_TALK then
        self:taskProgressTalk(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_REQ_ITEM then
        self:taskProgressReqItem(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_USE_ITEM then
        self:taskProgressUseItem(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_GROUP then
        self:taskProgressKillMonsterGroup(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_LEVEL then
        self:taskProgressKillMonsterLevel(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL then
        self:taskProgressPlayerLevel(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_CAIJI then
        self:taskProgressCollect(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_DIG then
        self:taskProgressDig(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_BUILD_ITEM then
        self:taskProgressBuildItem(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_COOK then
        self:taskProgressCook(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_USE_DRUG then
        self:taskProgressUseDrug(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_PASS_DUNGEON then
        self:taskProgressPassDungeon(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_EQUIP then
        self:taskProgressEquip(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_KILL_PLAYER then
        self:taskProgressKillPlayer(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_STRENGTH_EQUIP then
        self:taskProgressStrengthEquip(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_HUNHUAN then
        self:taskProgressHunhuan(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_SKILL_LEVEL then
        self:taskProgressSkillLevel(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_FRIENDLINES then
        self:taskProgressFriendlines(param1, param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_REACH_PLACE then
        self:taskProgressReachPlace(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_READ then
        self:taskProgressRead(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_UNLOCK_MAP then
        self:taskProgressUnlockMap(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_NUM then
        self:taskProgressKillMonsterNum(param1,param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_GET_ITEM then
        self:taskProgressGetItem(param1,param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_UPGRADE_HUNHUAN then
        self:taskProgressUpgradeHunhuan(param1,param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_CLOSE_UI_WINDOW then
        self:taskProgressCloseUiWindow(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_DAZUO then
        self:taskProgressDazuo(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER then
        self:taskProgressReachPlaceTimer(param1,param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_FOLLOW_NPC then
        self:taskProgressFollowNpc(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_SELL_GOODS then
        self:taskProgressSellGoods(param1,param2)
    elseif processtype == TASK_CONDITION_TYPE.TCT_NPC_ITEM then
        self:taskProgressNpcItem(param1,param2,param3)
    elseif processtype == TASK_CONDITION_TYPE.TCT_MONSTER_MIN_HP then
        self:taskProgressMonsterMinHP(param1)
    elseif processtype == TASK_CONDITION_TYPE.TCT_GET_HUNHUAN then
        self:taskProgressGetHunhuan(param1)
    end

    if self._need_update_progress then
        self:updateTaskProgress()
    end
end


function task_module:onUpdateTaskProgress(data)
    self:updateProgressByType(data.condition, data.param1, data.param2)
end

function task_module:afterInit()
    local chr_info = self._chr_info
    local tasks = self._task_trunk
    local trunk_task_id = 0
    local trunk_task_state = TASK_STATE.TSTATE_UNKNOWN
    local trunk_task_progress = {}
    for i, v in pairs(tasks) do
        if v.tid > trunk_task_id then
            trunk_task_id = v.tid
        end
    end

    if trunk_task_id == 0 then
        -- 自动接取第一个主线任务,去除
        --[[trunk_task_id = TASK_DATA_DEF.TDD_FIRST_TRUNK_TASK
        trunk_task_state = TASK_STATE.TSTATE_UNKNOWN
        trunk_task_progress = {}
        local icfg = _cfg.task(trunk_task_id)
        if icfg then
            for i, v in ipairs(icfg.condition_list) do
                trunk_task_progress[#trunk_task_progress+1] = 0
            end
        end--]]
    else
        trunk_task_state = tasks[trunk_task_id].state
        trunk_task_progress = _strutil.splite_int_vec(tasks[trunk_task_id].progress,",")
    end

    --if trunk_task_state == TASK_STATE.TSTATE_DONE then
    --    for i, v in pairs(_cfg.task) do
    --        if v.pretask == trunk_task_id and v.job == self.job then
    --           trunk_task_id = v.id
    --           trunk_task_state = TASK_STATE.TSTATE_UNKNOWN
    --           trunk_task_progress = 0
    --           trunk_task_index = 0
    --        end
    --    end
    --end

    self._task_trunk[trunk_task_id] = {cid = chr_info.cid, tid = trunk_task_id, state = trunk_task_state, progress = trunk_task_progress}
    self._trunk_task_id = trunk_task_id
    self._trunk_task_state = trunk_task_state
    self._trunk_task_progress = trunk_task_progress
    self._need_update_progress = false
    self:initTaskProgress()
    self:updateTaskDB(TASK_TYPE.TTYPE_TRUNK, self._task_trunk[trunk_task_id])
    self:sendTaskInfo(TASK_TYPE.TTYPE_TRUNK, self._trunk_task_id, self._trunk_task_state, self._trunk_task_progress, self._task_trunk[trunk_task_id].time)
    self:sendTypeTaskInfo(TASK_TYPE.TTYPE_DAILY_XY)
    self:sendTypeTaskInfo(TASK_TYPE.TTYPE_WEEK_TDDG)
    self:sendTypeTaskInfo(TASK_TYPE.TTYPE_WEEK_XLDG)
    self:sendTypeTaskInfo(TASK_TYPE.TTYPE_ZHUANJI)
    self:sendTypeTaskInfo(TASK_TYPE.TTYPE_BRANCH)
    self:sendTaskData()
    self:initTaskRound()
    self:sendTaskRoundInfo()
    self:initTaskWarToken()
    self:sendTaskWarTokenInfo()
end

function task_module:initTask()

end

function task_module:initTaskProgress()
    self._progress_all = {}

    self._progress_all[TASK_CONDITION_TYPE.TCT_TALK] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_REQ_ITEM] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_USE_ITEM] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_GROUP] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_LEVEL] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_CAIJI] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_DIG] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_BUILD_ITEM] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_COOK] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_USE_DRUG] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_PASS_DUNGEON] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_EQUIP] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_PLAYER] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_STRENGTH_EQUIP] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_HUNHUAN] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_SKILL_LEVEL] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_FRIENDLINES] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_REACH_PLACE] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_READ] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_UNLOCK_MAP] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_NUM] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_GET_ITEM] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_UPGRADE_HUNHUAN] = {}
	self._progress_all[TASK_CONDITION_TYPE.TCT_CLOSE_UI_WINDOW] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_DAZUO] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_FOLLOW_NPC] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_SELL_GOODS] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_NPC_ITEM] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_MONSTER_MIN_HP] = {}
    self._progress_all[TASK_CONDITION_TYPE.TCT_GET_HUNHUAN] = {}

    self._task_progress = {}
    local icfg = _cfg.task(self._trunk_task_id)
    if icfg and self._trunk_task_state ~= TASK_STATE.TSTATE_DONE and  self._trunk_task_state ~= TASK_STATE.TSTATE_UNKNOWN then
        local condition = {}
        --local process = {}
        local request = {}
        local finish = {}
        for i, v in ipairs(icfg.condition_list) do
            condition[#condition+1] = v[1]
            --process[#process+1] = 0
            local tempreq = {}
            for ti,tv in ipairs(v) do
                if ti > 1 then
                    tempreq[#tempreq+1] = tv
                end
            end

            request[#request+1] = tempreq
            finish[#finish+1] = false
        end

        local taskprocess = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = self._trunk_task_progress}
        self._task_progress[icfg.id] = taskprocess
        self:refreshTaskProgress(self._trunk_task_id, true)
    end

    for i = 1, 6, 1 do
        local task = {}
        if i == 1 then
            task = self._task_xy
        elseif i == 2 then
            task = self._task_tddg
        elseif i == 3 then
            task = self._task_xldg
        --elseif i == 4 then
        --    task = self._task_whd
        elseif i == 4 then
            task = self._task_zj
        elseif i == 5 then
            task = self._task_branch
        elseif i == 6 then
            task = self._task_baoxiang
        end
        for tid, v in pairs(task) do
            if v.state ~= TASK_STATE.TSTATE_DONE and v.state ~= TASK_STATE.TSTATE_UNKNOWN then
                local tCfg = {}
                if i == 1 or i == 2 or i == 3 then
                    tCfg = _cfg.task_group(tid)
                elseif i == 4 then
                    tCfg = _cfg.task_zhuanji(tid)
                elseif i == 5 then
                    tCfg = _cfg.task_branch(tid)
                elseif i == 6 then
                    tCfg = _cfg.task_baoxiang(tid)
                end
                if not table.empty(tCfg) then
                    local condition = {}
                    --local process = {}
                    local request = {}
                    local finish = {}
                    for _, cv in ipairs(tCfg.condition_list) do
                        condition[#condition+1] = cv[1]
                        --process[#process+1] = 0
                        local tempreq = {}
                        for ti,tv in ipairs(cv) do
                            if ti > 1 then
                                tempreq[#tempreq+1] = tv
                            end
                        end

                        request[#request+1] = tempreq
                        finish[#finish+1] = false
                    end

                    local taskprocess = {id = tCfg.id, condition_special = tCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = v.progress}
                    self._task_progress[tCfg.id] = taskprocess
                    self:refreshTaskProgress(tid, true)
                end
            end
        end
    end
end

function task_module:initTaskRound()
    if table.empty(self._task_round) then -- 自动接取所有宗族任务
        local id = 10001
        while id <= 50099 do
            local iCfg = _cfg.zz_task(id)
            if iCfg and iCfg.job == self._chr_info.job then
                self._task_round[iCfg.id] = {
                    round = iCfg.round,
                    tid = iCfg.id,
                    state = TASK_STATE.TSTATE_DOING,
                    progress = 0
                }
            end

            if id % 100 == 99 then
                id = id + 10000 - 98
            else
                id = id + 1
            end
        end
        self:updateTaskRoundDB()
    end
end

function task_module:initTaskWarToken()
    if table.empty(self._task_war_token) then
        for id = 1, 100, 1 do
            local iCfg = _cfg.task_war_token(id)
            if iCfg then
                self._task_war_token[iCfg.id] = {
                    tid = iCfg.id,
                    state = TASK_STATE.TSTATE_DOING,
                    progress = 0,
                }
            end
        end
        self:updateTaskWarTokenDB()
    end
end

function task_module:receive(tid)
    local chr_info = self._chr_info
    local ttype = 0
    local icfg = _cfg.task(tid)
    if not table.empty(icfg) then
        ttype = TASK_TYPE.TTYPE_TRUNK
    else
        icfg = _cfg.task_branch(tid)
        if not table.empty(icfg) then
            ttype = TASK_TYPE.TTYPE_BRANCH
        else
            icfg = _cfg.task_zhuanji(tid)
            if not table.empty(icfg) then
                ttype = TASK_TYPE.TTYPE_ZHUANJI
            else
                icfg = _cfg.task_baoxiang(tid)
                if not table.empty(icfg) then
                    ttype = TASK_TYPE.TTYPE_BAOXIANG
                else
                    icfg = _cfg.task_group(tid)
                    if not table.empty(icfg) then
                        if self._task_tddg[tid] then
                            ttype = TASK_TYPE.TTYPE_WEEK_TDDG
                        elseif self._task_xldg[tid] then
                            ttype = TASK_TYPE.TTYPE_WEEK_XLDG
                        end
                    end
                end
            end
        end
    end

    if ttype == 0 or table.empty(icfg) then
        return
    end

    if self:receivePreCheck(tid) == false then
        return
    end

    if icfg.items_receive then
        if self:addBagCheck(icfg.items_receive) then
            self:addBag(icfg.items_receive, CHANGE_REASON.CR_TASK_RECEIVE)
        else
            return
        end
    end

    if icfg.cost then
        if self:delBagCheck(icfg.cost) then
            self:delBag(icfg.cost, CHANGE_REASON.CR_TASK_RECEIVE)
        else
            return
        end
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK or ttype == TASK_TYPE.TTYPE_BRANCH then
        local preCfg = nil
        if ttype == TASK_TYPE.TTYPE_TRUNK then
            local preTid = 0
            for k, _ in pairs(self._task_trunk) do
                if k > preTid then
                    preTid = k
                end
            end
            if preTid > tid then
                preCfg = _cfg.task(preTid)
            end
        elseif ttype == TASK_TYPE.TTYPE_BRANCH then
            local preTid = 0
            for k, _ in pairs(self._task_trunk) do
                if k > preTid then
                    preTid = k
                end
            end
            if preTid > tid then
                preCfg = _cfg.task_zhuanji(preTid)
            end
        end

        if preCfg and not table.empty(preCfg.del_items) then
            if self:delBagCheck(preCfg.del_items) then
                self:delBag(preCfg.del_items,CHANGE_REASON.CR_TASK_BACKSPACE)
            else
                return
            end
        end
    end

    local condition = {}
    local process = {}
    local request = {}
    local finish = {}

    for i, v in ipairs(icfg.condition_list) do
        condition[#condition+1] = v[1]
        process[#process+1] = 0
        local tempreq = {}
        for ti,tv in ipairs(v) do
            if ti > 1 then
                tempreq[#tempreq+1] = tv
            end
        end
        finish[#finish+1] = false
        request[#request+1] = tempreq
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK then
        self._trunk_task_id = tid
        self._trunk_task_progress = process
        self._trunk_task_state = TASK_STATE.TSTATE_DOING
        self._task_trunk[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[icfg.id] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(self._trunk_task_id, true)
        self:updateTaskDB(ttype, self._task_trunk[tid])
        self:sendTaskInfo(ttype, self._trunk_task_id, self._trunk_task_state, self._trunk_task_progress, self._task_trunk[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_BAOXIANG then
        self._task_baoxiang[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[icfg.id] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(icfg.id, true)
        self:updateTaskDB(ttype, self._task_baoxiang[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_baoxiang[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        self._task_zj[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[tid] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_zj[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_zj[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        self._task_branch[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[tid] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_branch[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_branch[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        self._task_tddg[tid].state = TASK_STATE.TSTATE_DOING
        self._task_tddg[tid].time = _func.getNowSecond()
        self._task_progress[tid] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_tddg[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_tddg[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        self._task_xldg[tid].state = TASK_STATE.TSTATE_DOING
        self._task_xldg[tid].time = _func.getNowSecond()
        self._task_progress[tid] = {id = icfg.id, condition_special = icfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_xldg[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_xldg[tid].time)
    end
    self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_RECEIVED,{i32={tid}},"ProtoInt32Array")
end

function task_module:submit(tid)
    local ttype = 0
    local icfg = {}
    if self._task_round[tid] then
        self:submitTaskRound(tid)
        return
    elseif self._task_war_token[tid] then
        self:submitTaskWarToken(tid)
        return
    elseif self._task_trunk[tid] then
        ttype = TASK_TYPE.TTYPE_TRUNK
        icfg = _cfg.task(tid)
    elseif self._task_baoxiang[tid] then
        ttype = TASK_TYPE.TTYPE_BAOXIANG
        icfg = _cfg.task_baoxiang(tid)
    elseif self._task_xy[tid] then
        ttype = TASK_TYPE.TTYPE_DAILY_XY
        icfg = _cfg.task_group(tid)
    elseif self._task_tddg[tid] then
        ttype = TASK_TYPE.TTYPE_WEEK_TDDG
        icfg = _cfg.task_group(tid)
    elseif self._task_xldg[tid] then
        ttype = TASK_TYPE.TTYPE_WEEK_XLDG
        icfg = _cfg.task_group(tid)
    elseif self._task_branch[tid] then
        ttype = TASK_TYPE.TTYPE_BRANCH
        icfg = _cfg.task_branch(tid)
    elseif self._task_zj[tid] then
        ttype = TASK_TYPE.TTYPE_ZHUANJI
        icfg = _cfg.task_zhuanji(tid)
    end

    if ttype == 0 or table.empty(icfg) then
        return
    end

    if self:submitPreCheck(tid) == false then
        return
    end

    if icfg.reward_items then
        if self:addBagCheck(icfg.reward_items) then
            self:addBag(icfg.reward_items, CHANGE_REASON.CR_TASK_SUBMIT)
        else
            return
        end
    end

    if icfg.exp and icfg.exp ~= 0 then
        self:addExp(icfg.exp, CHANGE_REASON.CR_TASK_SUBMIT)
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK then
        self:refreshTaskProgress(self._trunk_task_id, false)
        self._trunk_task_state = TASK_STATE.TSTATE_DONE
        self._task_progress[self._trunk_task_id] = nil
        self._task_trunk[self._trunk_task_id].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_trunk[self._trunk_task_id])
        self:sendTaskInfo(ttype, self._trunk_task_id, self._trunk_task_state, self._trunk_task_progress, self._task_trunk[self._trunk_task_id].time)
		-- 任务完成处理
		self:checkSystemOpen(SYSTEM_OPEN_CONDITION.SOC_TASK,tid)
        self:checkChangeModel(tid)
    elseif ttype == TASK_TYPE.TTYPE_BAOXIANG then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_baoxiang[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_baoxiang[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_baoxiang[tid].progress, self._task_baoxiang[tid].time)

        --设置宝箱可开启
        if icfg.baoxiang then
            local baoxiangcfg = _cfg.baoxiang(icfg.baoxiang)
            if baoxiangcfg then
                if baoxiangcfg.request and baoxiangcfg.request[1] == 1 and baoxiangcfg.request[2] == tid then
                    local baoxiangdata = self._baoxiang[icfg.baoxiang]
                    if baoxiangdata == nil then
                        baoxiangdata = {}
                        baoxiangdata.state = BAOXIANG_STATE.CAN_OPEN
                        baoxiangdata.map = baoxiangcfg.mapid
                        baoxiangdata.x = baoxiangcfg.x
                        baoxiangdata.y = baoxiangcfg.y
                        baoxiangdata.z = baoxiangcfg.z
                        baoxiangdata.groupid = baoxiangcfg.groupid
                        baoxiangdata.cid = self.cid
                        baoxiangdata.bid = baoxiangcfg.id
                        baoxiangdata.time = 0
                        baoxiangdata.type = 1
                        baoxiangdata.opennum = 0
                        self._baoxiang[icfg.baoxiang] = baoxiangdata
                        self:updateBaoxiangDB(self._baoxiang[icfg.baoxiang])
                        self:sendBaoxiangInfo({self._baoxiang[icfg.baoxiang]}, 2)
                    else
                        baoxiangdata.state = BAOXIANG_STATE.CAN_OPEN
                        self:updateBaoxiangDB(self._baoxiang[icfg.baoxiang])
                        self:sendBaoxiangInfo({self._baoxiang[icfg.baoxiang]}, 2)
                    end
                end
            end
        end
    elseif ttype == TASK_TYPE.TTYPE_DAILY_XY then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_xy[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_xy[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_xy[tid].progress, self._task_xy[tid].time)
        self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_TASK_XY,0,1)
        self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_TASK_XY, 1)
    elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_tddg[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_tddg[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_tddg[tid].progress, self._task_tddg[tid].time)
        self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_TASK_XS,0,1)
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_xldg[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_xldg[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_xldg[tid].progress, self._task_xldg[tid].time)
        self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_TASK_XS,0,1)
    --elseif ttype == TASK_TYPE.TTYPE_WEEK_WHD then
    --    self:refreshTaskProgress(tid, false)
    --    self._task_progress[tid] = nil
    --    self._task_whd[tid].state = TASK_STATE.TSTATE_DONE
    --    self:updateTaskDB(ttype, self._task_whd[tid])
    --    self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_whd[tid].progress)
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_zj[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_zj[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_zj[tid].progress, self._task_zj[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        self:refreshTaskProgress(tid, false)
        self._task_progress[tid] = nil
        self._task_branch[tid].state = TASK_STATE.TSTATE_DONE
        self:updateTaskDB(ttype, self._task_branch[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DONE, self._task_branch[tid].progress, self._task_branch[tid].time)
    end

	-- 任务完成
	self:taskItemComposeUnlock(tid)

    self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_COMPLETED,{i32={tid}},"ProtoInt32Array")
end

--回退到任务tid
function task_module:backspaceTask(tid)
    local ttype = 0
    local iCfg = {}
    if self._task_trunk[tid] then
        if tid >= self._trunk_task_id then
            return
        end
        iCfg = _cfg.task(tid)
        if table.empty(iCfg) then
            return
        end
        local preCfg = _cfg.task(self._trunk_task_id)
        if table.empty(preCfg) then
            return
        end
        if not table.empty(preCfg.del_items) then
            if self:delBagCheck(preCfg.del_items) == false then
                return
            end
            self:delBag(preCfg.del_items,CHANGE_REASON.CR_TASK_BACKSPACE)
        end
        ttype = TASK_TYPE.TTYPE_TRUNK
    elseif self._task_branch[tid] then
        local preTid = 0
        for k, _ in pairs(self._task_branch) do
            if preTid < k then
                preTid = k
            end
        end
        if tid >= preTid then
            return
        end
        iCfg = _cfg.task_branch(tid)
        if table.empty(iCfg) then
            return
        end
        local preCfg = _cfg.task_branch(preTid)
        if table.empty(preCfg) then
            return
        end
        if not table.empty(preCfg.del_items) then
            if self:delBagCheck(preCfg.del_items) == false then
                return
            end
            self:delBag(preCfg.del_items,CHANGE_REASON.CR_TASK_BACKSPACE)
        end
        ttype = TASK_TYPE.TTYPE_BRANCH
    elseif self._task_zj[tid] then
        local preTid = 0
        for k, _ in pairs(self._task_zj) do
            if preTid < k then
                preTid = k
            end
        end
        if tid >= preTid then
            return
        end
        iCfg = _cfg.task_zhuanji(tid)
        if table.empty(iCfg) then
            return
        end
        local preCfg = _cfg.task_zhuanji(preTid)
        if table.empty(preCfg) then
            return
        end
        if not table.empty(preCfg.del_items) then
            if self:delBagCheck(preCfg.del_items) == false then
                return
            end
            self:delBag(preCfg.del_items,CHANGE_REASON.CR_TASK_BACKSPACE)
        end
        ttype = TASK_TYPE.TTYPE_ZHUANJI
    else
        return
    end

    local condition = {}
    local process = {}
    local request = {}
    local finish = {}
    for _, v in ipairs(iCfg.condition_list) do
        condition[#condition+1] = v[1]
        process[#process+1] = 0
        local tempreq = {}
        for ti,tv in ipairs(v) do
            if ti > 1 then
                tempreq[#tempreq+1] = tv
            end
        end
        finish[#finish+1] = false
        request[#request+1] = tempreq
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK then
        self._trunk_task_id = tid
        self._trunk_task_progress = process
        self._trunk_task_state = TASK_STATE.TSTATE_DOING
        self._task_trunk[tid] = {cid = self._chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[tid] = {id = iCfg.id, condition_special = iCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(self._trunk_task_id, true)
        self:updateTaskDB(ttype, self._task_trunk[tid])
        self:sendTaskInfo(ttype, self._trunk_task_id, self._trunk_task_state, self._trunk_task_progress, self._task_trunk[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        self._task_branch[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[tid] = {id = iCfg.id, condition_special = iCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_branch[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_branch[tid].time)
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        self._task_zj[tid] = {cid = chr_info.cid, tid = tid, state = TASK_STATE.TSTATE_DOING, progress = process, time = _func.getNowSecond()}
        self._task_progress[tid] = {id = iCfg.id, condition_special = iCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
        self:refreshTaskProgress(tid, true)
        self:updateTaskDB(ttype, self._task_zj[tid])
        self:sendTaskInfo(ttype, tid, TASK_STATE.TSTATE_DOING, process, self._task_zj[tid].time)
    end
    self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_RECEIVED,{i32={tid}},"ProtoInt32Array")
end

function task_module:isTaskComplete(tid)
    if self._task_trunk[tid] then
        if self._task_trunk[tid].state == TASK_STATE.TSTATE_DONE then
            return true
        end
    end
    return false
end

function task_module:refreshTaskProgress(tid, isadd)
    local taskprogress = self._task_progress[tid]
    if taskprogress ~= nil then
        local curprogress = {}
        for i, v in ipairs(taskprogress.condition) do
            if v == TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL or v == TASK_CONDITION_TYPE.TCT_KILL_PLAYER then
                curprogress = table.getOrNewTable(self._progress_all[v], 1)
            else
                curprogress = table.getOrNewTable(self._progress_all[v], taskprogress.request[i][1])
            end
            if isadd then
                local isfind = false
                for _, value in ipairs(curprogress) do
                    if value == tid then
                        isfind = true
                        break
                    end
                end
                if isfind == false then
                    curprogress[#curprogress + 1] = tid
                end
                if v == TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL then
                    self:updateProgressByType(TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL, self._chr_info.level, 0)
                elseif v == TASK_CONDITION_TYPE.TCT_REQ_ITEM then
                    local item_id = taskprogress.request[i][1]
                    self:updateProgressByType(TASK_CONDITION_TYPE.TCT_REQ_ITEM, item_id, self:getItemTotalNum(item_id))
                end
            else
                for index, value in ipairs(curprogress) do
                    if value == tid then
                        table.remove(curprogress, index)
                        break
                    end
                end
            end
        end
    end
end

function task_module:receivePreCheck(tid)
    local ttype = 0
    local icfg = _cfg.task(tid)
    if not table.empty(icfg) then
        ttype = TASK_TYPE.TTYPE_TRUNK
    else
        icfg = _cfg.task_branch(tid)
        if not table.empty(icfg) then
            ttype = TASK_TYPE.TTYPE_BRANCH
        else
            icfg = _cfg.task_baoxiang(tid)
            if not table.empty(icfg) then
                ttype = TASK_TYPE.TTYPE_BAOXIANG
            else
                icfg = _cfg.task_zhuanji(tid)
                if not table.empty(icfg) then
                    ttype = TASK_TYPE.TTYPE_ZHUANJI
                else
                    icfg = _cfg.task_group(tid)
                    if not table.empty(icfg) then
                        if self._task_tddg[tid] and self._task_tddg[tid].state == TASK_STATE.TSTATE_UNKNOWN then
                            return true
                        elseif self._task_xldg[tid] and self._task_xldg[tid].state == TASK_STATE.TSTATE_UNKNOWN then
                            return true
                        end
                    end
                end
            end
        end
    end
    
    if ttype == 0 or table.empty(icfg) then
        return false
    end

    if ttype == TASK_TYPE.TTYPE_BAOXIANG then
        if not icfg.baoxiang or icfg.baoxiang == 0 then
            return false
        end
        local baoxiangdata = self._baoxiang[icfg.baoxiang]
        if baoxiangdata ~= nil and baoxiangdata.state ~= BAOXIANG_STATE.LOCK then
            return false
        end
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        if icfg.unlock_task and icfg.unlock_task > 0 then -- 主线任务完成可解锁支线任务
            if not self._task_trunk[icfg.unlock_task] or self._task_trunk[icfg.unlock_task].state ~= TASK_STATE.TSTATE_DONE then
                return
            end
        end
        if icfg.clear_task and icfg.clear_task > 0 then -- 主线任务完成需清除支线任务
            if self._task_trunk[icfg.clear_task] and self._task_trunk[icfg.clear_task].state == TASK_STATE.TSTATE_DONE then
                return
            end
        end
    end

    local chr_info = self._chr_info
    if icfg.level and chr_info.level < icfg.level then
        return false
    end

    if icfg.job and chr_info.job ~= icfg.job and icfg.job ~= 0 then
        return false
    end

    if icfg.start_npc and icfg.start_npc ~= 0 then
        --todo判断npc位置
    end

    if not table.empty(icfg.konw) then
        if 1 == icfg.konw[1] then -- 1:npc,2:map_region
            -- 判断NPC位置
        elseif 2 == icfg.konw[1] then
            -- 判断地图区域
        end
    end

    --todo 判断宝箱位置
    if ttype == TASK_TYPE.TTYPE_BAOXIANG then
        if icfg.baoxiang and icfg.baoxiang < 1  then
            return false
        end
        local bCfg = _cfg.baoxiang(icfg.baoxiang)
        if not bCfg then
            return false
        end
        -- 判断当前是否在宝箱附近
    end

    if not table.empty(icfg.pretask) and icfg.pretask[1] > 0 then
        local tasks = nil
        if ttype == TASK_TYPE.TTYPE_TRUNK then
            tasks = self._task_trunk
        elseif ttype == TASK_TYPE.TTYPE_BRANCH then
            tasks = self._task_branch
        elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
            tasks = self._task_zj
        end
        local firsttask = false
        if tasks and tasks[tid] and tasks[tid].state == TASK_STATE.TSTATE_UNKNOWN then
            firsttask = true
        end
        if firsttask then
            _log.error("receivePreCheck error, %d %d pretask error",ttype,tid)
        else
            local predone = false
            for _, ptid in pairs(icfg.pretask) do
                if tasks[ptid] and tasks[ptid].state == TASK_STATE.TSTATE_DONE then
                    predone = true
                    break
                end
            end
            if predone == false then
                return false
            end
        end
    end
    return true
end

function task_module:submitPreCheck(tid)
    local ttype = 0
    local icfg = {}
    local time = 0
    if self._task_trunk[tid] then
        ttype = TASK_TYPE.TTYPE_TRUNK
        icfg = _cfg.task(tid)
        time = self._task_trunk[tid].time
    elseif self._task_baoxiang[tid] then
        ttype = TASK_TYPE.TTYPE_BAOXIANG
        icfg = _cfg.task_baoxiang(tid)
        time = self._task_baoxiang[tid].time
    elseif self._task_xy[tid] then
        ttype = TASK_TYPE.TTYPE_DAILY_XY
        icfg = _cfg.task_group(tid)
        time = self._task_xy[tid].time
    elseif self._task_tddg[tid] then
        ttype = TASK_TYPE.TTYPE_WEEK_TDDG
        icfg = _cfg.task_group(tid)
        time = self._task_tddg[tid].time
    elseif self._task_xldg[tid] then
        ttype = TASK_TYPE.TTYPE_WEEK_XLDG
        icfg = _cfg.task_group(tid)
        time = self._task_xldg[tid].time
    elseif self._task_branch[tid] then
        ttype = TASK_TYPE.TTYPE_BRANCH
        icfg = _cfg.task_branch(tid)
        time = self._task_branch[tid].time
    elseif self._task_zj[tid] then
        ttype = TASK_TYPE.TTYPE_ZHUANJI
        icfg = _cfg.task_zhuanji(tid)
        time = self._task_zj[tid].time
    end

    if ttype == 0 or table.empty(icfg) then
        return false
    end

    if icfg.end_npc then
        --todo判断npc位置
    end

    if icfg.limit_time and icfg.limit_time[1] > 0 then -- 限时
        if time and time + icfg.limit_time[1] < _func.getNowSecond() then
            return false
        end
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK and self._trunk_task_id ~= tid then
        return false
    end
    local needupdate = false
    local taskprogress = self._task_progress[tid]
    if taskprogress then
        for i, v in ipairs(taskprogress.condition) do
            if v == TASK_CONDITION_TYPE.TCT_REQ_ITEM then
                local oldf = taskprogress.finish[i]
                if self:getItemTotalNum(taskprogress.request[i][1]) >= taskprogress.request[i][3] then
                    taskprogress.finish[i] = true
                else
                    taskprogress.finish[i] = false
                end
                if oldf ~= taskprogress.finish[i] then
                    taskprogress.update = true
                    needupdate = true
                end
            end
        end
    end

    if needupdate then
        self:updateTaskProgress()
    end

    if ttype == TASK_TYPE.TTYPE_TRUNK and self._trunk_task_state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_BAOXIANG and self._task_baoxiang[tid] ~= nil and self._task_baoxiang[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_DAILY_XY and self._task_xy[tid] and self._task_xy[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_WEEK_TDDG and self._task_tddg[tid] and self._task_tddg[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_WEEK_XLDG and self._task_xldg[tid] and self._task_xldg[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_ZHUANJI and self._task_zj[tid] and self._task_zj[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    if ttype == TASK_TYPE.TTYPE_BRANCH and self._task_branch[tid] and self._task_branch[tid].state == TASK_STATE.TSTATE_CAN_SUBMIT then
        return true
    end

    return false
end

function task_module:onGetTaskGift(data)
    local tp = data.i32[1]
    local id = data.i32[2]
    if tp == TASK_TYPE.TTYPE_DAILY_XY then
        local iCfg = _cfg.task_random(id)
        if not iCfg then
            return
        end
        if not self._task_xy then
            return
        end
        if self:getRecord(RECORD_TYPE.RT_XY_TASK_GIFT) == 1 then
            return
        end
        local canGet = true
        for _, v in pairs(self._task_xy) do
            if v.state ~= TASK_STATE.TSTATE_DONE then
                canGet = false
                break
            end
        end
        if not canGet then
            return
        end
        if not self:addBagCheck(iCfg.gift) then
            return
        end

        self:addBag(iCfg.gift, CHANGE_REASON.CR_XY_TASK_GIFT)
        self:updateRecord(RECORD_TYPE.RT_XY_TASK_GIFT, 1)
        self:sendTaskData()
    elseif tp == TASK_TYPE.TTYPE_ROUND then
        local iCfg = _cfg.zz_task_round_reward(id)
        if not iCfg then
            return
        end
        if iCfg.job ~= self._chr_info.job then
            return
        end
        local rwd = self:getRecord(RECORD_TYPE.RT_ZZ_TASK_GIFT)
        if _func.is_bit_on(rwd, iCfg.round) then
            return
        end
        for _, v in pairs(self._task_round) do
            if iCfg.round == v.round and v.state ~= TASK_STATE.TSTATE_DONE then
                return
            end
        end
        if not self:addBagCheck(iCfg.reward) then
            return
        end

        self:addBag(iCfg.reward, CHANGE_REASON.CR_ZZ_TASK_ROUND_GIFT)
        rwd = _func.set_bit_on(rwd, iCfg.round)
        self:updateRecord(RECORD_TYPE.RT_ZZ_TASK_GIFT, rwd)
        self:sendTaskData()
    end
end

function task_module:checkAutoReciveTask()
    local now = _func.getNowSecond()
    local tm = os.date("*t", now)
    if tm.hour >= 5 then
        -- 学院任务:每日5:00
        local xy_time = self:getRecord(RECORD_TYPE.RT_XY_TASK_TIME)
        if _time.day_diff(xy_time, now) ~= 0 then
            self:updateRecord(RECORD_TYPE.RT_XY_TASK_TIME,now)
            self:resetAndNewTask(TASK_TYPE.TTYPE_DAILY_XY)
        end

        -- 天斗帝国周一5:00
        local td_time = self:getRecord(RECORD_TYPE.RT_TDDG_TASK_TIME)
        if _time.week_diff(td_time, now) and tm.wday >= 2 then
            self:updateRecord(RECORD_TYPE.RT_TDDG_TASK_TIME,now)
            self:resetAndNewTask(TASK_TYPE.TTYPE_WEEK_TDDG)
        end

        -- 星罗帝国周四5:00
        local xl_time = self:getRecord(RECORD_TYPE.RT_XLDG_TASK_TIME)
        if _time.week_diff(xl_time, now) and tm.wday >= 5 then
            self:updateRecord(RECORD_TYPE.RT_XLDG_TASK_TIME,now)
            self:resetAndNewTask(TASK_TYPE.TTYPE_WEEK_XLDG)
        end

        -- 武魂殿每周六5:00
        --[[local whd_time = self:getRecord(RECORD_TYPE.rt_whd_task_time)
        if _time.week_diff(whd_time, now) and (tm.wday == 7 or tm.wday == 1) then
            self:updateRecord(RECORD_TYPE.rt_whd_task_time,now)
            self:resetAndNewTask(TASK_TYPE.TTYPE_WEEK_WHD)
        end--]]
    end
end

function task_module:resetAndNewTask(ttype)
    local chr_info = self._chr_info
    if not chr_info then
        return
    end

    local task = {}
    local taskNum = 0
    local state = TASK_STATE.TSTATE_UNKNOWN
    if ttype == TASK_TYPE.TTYPE_DAILY_XY then
        self:updateRecord(RECORD_TYPE.RT_XY_TASK_GIFT, 0)
        task = self._task_xy
        taskNum = 4
        state = TASK_STATE.TSTATE_DOING
    elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        task = self._task_tddg
        taskNum = 7
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        task = self._task_xldg
        taskNum = 7
    end
    local db = {}
    local taskTemp = table.clone(task)
    for tid, v in pairs(task) do
        db[#db+1] = {cid = self.cid, tid = v.tid}
        table.remove(self._task_progress, tid)
    end
    task = {}
    if #db > 0 then
        self:dbDeleteDataVector(TABLE_INDEX.TAB_mem_chr_task_random, db)
    end

    -- 生成新任务
    local iCfg = {}
    for id = 1, 999, 1 do
        iCfg = _cfg.task_random(id)
        if iCfg and iCfg.type == ttype then
            if chr_info.level >= iCfg.level[1] and chr_info.level <= iCfg.level[2] then
                break
            end
        end
    end
    if table.empty(iCfg) then
        return
    end

    local pb = {}
    for tid, _ in pairs(taskTemp) do
        -- 若有系列任务，则必定接取下一环
        local tCfg = _cfg.task_group(tid)
        if tCfg and tCfg.nexttask and tCfg.nexttask[1] > 0 then
            local idx = math.random(1, #tCfg.nexttask)
            local ntid = tCfg.nexttask[idx]
            
            local condition = {}
            local process = {}
            local request = {}
            local finish = {}
            for _, cv in ipairs(tCfg.condition_list) do
                condition[#condition+1] = cv[1]
                process[#process+1] = 0
                local tempreq = {}
                for ti,tv in ipairs(cv) do
                    if ti > 1 then
                        tempreq[#tempreq+1] = tv
                    end
                end
                request[#request+1] = tempreq
                finish[#finish+1] = false
            end

            local time = _func.getNowSecond()
            task[ntid] = {cid = self.cid, tid = ntid, state = state, progress = process, time = time}
            pb[#pb+1] = {cid = self.cid, ttype = ttype, tid = ntid, state = state, progress = process, time = time}
            if ttype == TASK_TYPE.TTYPE_DAILY_XY then
                local taskprocess = {id = ntid, condition_special = tCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = process}
                self._task_progress[ntid] = taskprocess
                self:refreshTaskProgress(tid, true)
                self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_RECEIVED,{i32={ntid}},"ProtoInt32Array")
            end
        end
    end

    local curNum = #pb
    for i = 1, taskNum * 10, 1 do
        if #pb >= taskNum then
            break
        end
        local index = #pb + 1
        if index > curNum + 3 then
            index = math.random(1,3)
        end
        local minId,maxId = iCfg.talk[1],iCfg.talk[2]
        if index == 2 then
            minId,maxId = iCfg.gather[1],iCfg.gather[2]
        elseif index == 3 then
            minId,maxId = iCfg.monster[1],iCfg.monster[2]
        end

        local tCfg = {}
        for i = minId, maxId+100, 1 do
            if not table.empty(tCfg) then
                break
            end
            
            local randId = math.random(minId,maxId)
            tCfg = _cfg.task_group(randId)
            if not table.empty(tCfg) then
                local bCheck = true
                if bCheck then
                    for k, _ in pairs(self._task_xy) do
                        if k == randId then
                            bCheck = false
                            break
                        end
                    end
                end
                if bCheck then
                    for k, _ in pairs(self._task_tddg) do
                        if k == randId then
                            bCheck = false
                            break
                        end
                    end
                end
                if bCheck then
                    for k, _ in pairs(self._task_xldg) do
                        if k == randId then
                            bCheck = false
                            break
                        end
                    end
                end
                if bCheck then
                    if tCfg.pretask and tCfg.pretask[1] > 0 then --带前置任务的前面已自动生成后续任务
                        bCheck = false
                    end
                    if bCheck and tCfg.unlock then
                        for k, v in pairs(tCfg.unlock) do
                            -- 检查解锁条件是否符合
                        end
                    end
                end
                if bCheck == false then
                    tCfg = {}
                end
            end
        end

        if not table.empty(tCfg) then
            local condition = {}
            local process = {}
            local request = {}
            local finish = {}
            for _, cv in ipairs(tCfg.condition_list) do
                condition[#condition+1] = cv[1]
                process[#process+1] = 0
                local tempreq = {}
                for ti,tv in ipairs(cv) do
                    if ti > 1 then
                        tempreq[#tempreq+1] = tv
                    end
                end
                request[#request+1] = tempreq
                finish[#finish+1] = false
            end

            local time = _func.getNowSecond()
            task[tCfg.id] = {cid = self.cid, tid = tCfg.id, state = state, progress = process, time = time}
            pb[#pb+1] = {cid = self.cid, ttype = ttype, tid = tCfg.id, state = state, progress = process, time = time}
            if ttype == TASK_TYPE.TTYPE_DAILY_XY then
                local taskprocess = {id = tCfg.id, condition_special = tCfg.condition_special, condition = condition, request = request, finish = finish, update = true, process = v.progress}
                self._task_progress[tCfg.id] = taskprocess
                self:refreshTaskProgress(tCfg.id, true)
                self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_TASK_RECEIVED,{i32={tCfg.id}},"ProtoInt32Array")
            end
        end
    end

    if #pb < taskNum then --循环多次后仍未生成足够任务
        _log.error("task_module:resetAndNewTask() error: task count = %d < %d",#pb,taskNum)
    end

    self:updateTaskDB(ttype)
    self:sendTaskData()
    self:sendTypeTaskInfo(ttype)
end

function task_module:checkTaskProgress()
    for i, v in  pairs(self._task_progress) do
        if v.update == true then
            if self._trunk_task_id == v.id then
                self._trunk_task_progress = v.process
                local isfinish = true
                if v.condition_special[1] == CSPECIAL_ALL then
                    for index, value in ipairs(v.finish) do
                        if value == false then
                            isfinish = false
                            break
                        end
                    end
                elseif v.condition_special[1] == CSPECIAL_ONE then
                    isfinish = false
                    for index, value in ipairs(v.finish) do
                        if value == true then
                            isfinish = true
                            break
                        end
                    end
                elseif v.condition_special[1] == CSPECIAL_CERTAIN then
                    for index, value in ipairs(v.condition_special) do
                        if index ~= 1 then
                            if v.finish[value] == false then
                                isfinish = false
                                break
                            end
                        end
                    end
                else
                    isfinish = false
                end

                if isfinish then
                    self._trunk_task_state = TASK_STATE.TSTATE_CAN_SUBMIT
                end

                self._task_trunk[self._trunk_task_id].state = self._trunk_task_state
                self._task_trunk[self._trunk_task_id].progress = self._trunk_task_progress
                self:updateTaskDB(TASK_TYPE.TTYPE_TRUNK, self._task_trunk[self._trunk_task_id])
                v.update = false
                self:sendTaskInfo(TASK_TYPE.TTYPE_TRUNK, self._trunk_task_id,self._trunk_task_state, self._trunk_task_progress, self._task_trunk[self._trunk_task_id].time)
            end
        end
    end
end

function task_module:updateTaskProgress()
    local taskprocess = self._task_progress
    for i, v in  pairs(taskprocess) do
        if v.update == true then
            if self._trunk_task_id == v.id then
                self._trunk_task_progress = v.process
            elseif self._task_baoxiang[v.id] then
                self._task_baoxiang[v.id].progress = v.process
            elseif self._task_xy[v.id] then
                self._task_xy[v.id].progress = v.process
            elseif self._task_tddg[v.id] then
                self._task_tddg[v.id].progress = v.process
            elseif self._task_xldg[v.id] then
                self._task_xldg[v.id].progress = v.process
            --elseif self._task_whd[v.id] then
            --    self._task_whd[v.id].progress = v.process
            elseif self._task_zj[v.id] then
                self._task_zj[v.id].progress = v.process
            elseif self._task_branch[v.id] then
                self._task_branch[v.id].progress = v.process
            end

            local isfinish = true
            if v.condition_special[1] == CSPECIAL_ALL then
                for index, value in ipairs(v.finish) do
                    if value == false then
                        isfinish = false
                        break
                    end
                end
            elseif v.condition_special[1] == CSPECIAL_ONE then
                isfinish = false
                for index, value in ipairs(v.finish) do
                    if value == true then
                        isfinish = true
                        break
                    end
                end
            elseif v.condition_special[1] == CSPECIAL_CERTAIN then
                for index, value in ipairs(v.condition_special) do
                    if index ~= 1 then
                        if v.finish[value] == false then
                            isfinish = false
                            break
                        end
                    end
                end
            else
                isfinish = false
            end
            
            if self._trunk_task_id == v.id then
                if isfinish then
                    self._trunk_task_state = TASK_STATE.TSTATE_CAN_SUBMIT
                elseif self._trunk_task_state == TASK_STATE.TSTATE_CAN_SUBMIT then
                    self._trunk_task_state = TASK_STATE.TSTATE_DOING
                end
                self._task_trunk[self._trunk_task_id].state = self._trunk_task_state
                self._task_trunk[self._trunk_task_id].progress = self._trunk_task_progress
                self:updateTaskDB(TASK_TYPE.TTYPE_TRUNK, self._task_trunk[self._trunk_task_id])
                v.update = false
                self:sendTaskInfo(TASK_TYPE.TTYPE_TRUNK, self._trunk_task_id,self._trunk_task_state, self._trunk_task_progress,self._task_trunk[self._trunk_task_id].time)
            elseif self._task_baoxiang[v.id] then
                if isfinish then
                    self._task_baoxiang[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                --宝箱任务应该不能从可提交状态到正在进行状态
                self:updateTaskDB(TASK_TYPE.TTYPE_BAOXIANG, self._task_baoxiang[v.id])
                v.update = false
                self:sendTaskInfo(TASK_TYPE.TTYPE_BAOXIANG, v.id, self._task_baoxiang[v.id].state, self._task_baoxiang[v.id].progress, self._task_baoxiang[v.id].time)
            elseif self._task_xy[v.id] then
                if isfinish then
                    self._task_xy[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                v.update = false
                self:updateTaskDB(TASK_TYPE.TTYPE_DAILY_XY, self._task_xy[v.id])
                self:sendTaskInfo(TASK_TYPE.TTYPE_DAILY_XY, v.id, self._task_xy[v.id].state, self._task_xy[v.id].progress, self._task_xy[v.id].time)
            elseif self._task_tddg[v.id] then
                if isfinish then
                    self._task_tddg[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                v.update = false
                self:updateTaskDB(TASK_TYPE.TTYPE_WEEK_TDDG, self._task_tddg[v.id])
                self:sendTaskInfo(TASK_TYPE.TTYPE_WEEK_TDDG, v.id, self._task_tddg[v.id].state, self._task_tddg[v.id].progress, self._task_tddg[v.id].time)
            elseif self._task_xldg[v.id] then
                if isfinish then
                    self._task_xldg[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                v.update = false
                self:updateTaskDB(TASK_TYPE.TTYPE_WEEK_XLDG, self._task_xldg[v.id])
                self:sendTaskInfo(TASK_TYPE.TTYPE_WEEK_XLDG, v.id, self._task_xldg[v.id].state, self._task_xldg[v.id].progress, self._task_xldg[v.id].time)
            --elseif self._task_whd[v.id] then
            --    if isfinish then
            --        self._task_whd[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
            --    end
            --    v.update = false
            --    self:updateTaskDB(TASK_TYPE.TTYPE_WEEK_WHD, self._task_whd[v.id])
            --    self:sendTaskInfo(TASK_TYPE.TTYPE_WEEK_WHD, v.id, self._task_whd[v.id].state, self._task_whd[v.id].progress)
            elseif self._task_zj[v.id] then
                if isfinish then
                    self._task_zj[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                v.update = false
                self:updateTaskDB(TASK_TYPE.TTYPE_ZHUANJI, self._task_zj[v.id])
                self:sendTaskInfo(TASK_TYPE.TTYPE_ZHUANJI, v.id, self._task_zj[v.id].state, self._task_zj[v.id].progress, self._task_zj[v.id].time)
            elseif self._task_branch[v.id] then
                if isfinish then
                    self._task_branch[v.id].state = TASK_STATE.TSTATE_CAN_SUBMIT
                end
                v.update = false
                self:updateTaskDB(TASK_TYPE.TTYPE_BRANCH, self._task_branch[v.id])
                self:sendTaskInfo(TASK_TYPE.TTYPE_BRANCH, v.id, self._task_branch[v.id].state, self._task_branch[v.id].progress, self._task_branch[v.id].time)
            end
        end
    end
end

function task_module:updateTaskRoundProgress(type,param,progress,addTp)
    local tids = {}
    for tid, v in pairs(self._task_round) do
        if v.state == TASK_STATE.TSTATE_DOING then
            local iCfg = _cfg.zz_task(tid)
            if iCfg and iCfg.type == type then
                if iCfg.param == param or
                    (iCfg.type == TASK_ROUND_TYPE.TRT_MAKE_EQUIP_X and param >= iCfg.param) or
                    (iCfg.type == TASK_ROUND_TYPE.TRT_POSITION and param >= iCfg.param) then
                    if addTp then
                        self._task_round[tid].progress = progress
                    else
                        self._task_round[tid].progress = self._task_round[tid].progress + progress
                    end
                    if self._task_round[tid].progress >= iCfg.progress then
                        self._task_round[tid].state = TASK_STATE.TSTATE_CAN_SUBMIT
                    end
                    local prg = {}
                    prg[#prg+1] = self._task_round[tid].progress
                    self:sendTaskInfo(TASK_TYPE.TTYPE_ROUND, tid, self._task_round[tid].state, prg, 0)
                    tids[#tids+1] = tid
                end
            end
        end
    end
    if #tids > 0 then
        self:updateTaskRoundDB(tids)
    end
end

function task_module:updateTaskWarTokenProgress(type,param,progress,addTp)
    local tids = {}
    for tid, v in pairs(self._task_war_token) do
        if v.state == TASK_STATE.TSTATE_DOING then
            local iCfg = _cfg.task_war_token(tid)
            if iCfg and iCfg.type == type then
                if iCfg.param == param then
                    if addTp then
                        self._task_war_token[tid].progress = progress
                    else
                        self._task_war_token[tid].progress = self._task_war_token[tid].progress + progress
                    end
                    if self._task_war_token[tid].progress >= iCfg.progress then
                        self._task_war_token[tid].state = TASK_STATE.TSTATE_CAN_SUBMIT
                    end
                    local prg = {}
                    prg[#prg+1] = self._task_war_token[tid].progress
                    self:sendTaskInfo(TASK_TYPE.TTYPE_WAR_TOKEN, tid, self._task_war_token[tid].state, prg, 0)
                    tids[#tids+1] = tid
                end
            end
        end
    end
    if #tids > 0 then
        self:updateTaskWarTokenDB(tids)
    end
end

function task_module:resetTaskWarToken(type)
    local tp = type or 1 -- 1:day,2:week,3:season
    if table.empty(self._task_war_token) then
        return
    end

    local tids = {}
    for tid, v in pairs(self._task_war_token) do
        local icfg = _cfg.task_war_token(tid)
        if icfg and icfg.cycle <= tp then
            self._task_war_token[tid].state = TASK_STATE.TSTATE_DOING
            self._task_war_token[tid].progress = 0
            tids[#tids+1] = tid
        end
    end
    self:updateTaskWarTokenDB(tids)
    self:sendTaskWarTokenInfo()
end

function task_module:taskProgressTalk(talkid)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_TALK]
    if taskprogress[talkid] then
        for i, v in pairs(taskprogress[talkid]) do
            self:updateTaskProgressByTalk(v, talkid)
        end
    end
end

function task_module:updateTaskProgressByTalk(tid, talkid)
    local taskprocess = self._task_progress[tid]
    if taskprocess then
        for i, v in ipairs(taskprocess.condition) do
            if v == TASK_CONDITION_TYPE.TCT_TALK then
                if taskprocess.finish[i] == false then
                    taskprocess.process[i] = 1
                    taskprocess.finish[i] = true
                    taskprocess.update = true
                    self._need_update_progress = true 
                end
            end
        end
    end
end

function task_module:taskProgressReqItem(itemid, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_REQ_ITEM]
    if taskprogress[itemid] then
        for i, v in pairs(taskprogress[itemid]) do
            self:updateTaskProgressByReqItem(v, itemid, num)
       end
    end
end

function task_module:updateTaskProgressByReqItem(tid, itemid, num)
    local taskprocess = self._task_progress[tid]
    if taskprocess then
        for i, v in ipairs(taskprocess.condition) do
            if v == TASK_CONDITION_TYPE.TCT_REQ_ITEM then
                if taskprocess.request[i][1] == itemid then
                    if taskprocess.process[i] ~= num then
                        taskprocess.process[i] = num
                        if taskprocess.process[i] >= taskprocess.request[i][3] then
                            taskprocess.finish[i] = true
                        else
                            taskprocess.finish[i] = false
                        end
                        taskprocess.update = true
                        self._need_update_progress = true
                    end
                end
            end
        end
    end
end

function task_module:taskProgressUseItem(itemid, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_USE_ITEM]
    if taskprogress[itemid] then
        for i, v in pairs(taskprogress[itemid]) do
            self:updateTaskProgressByUseItem(v, itemid, num)
       end
    end
end

function task_module:updateTaskProgressByUseItem(tid, itemid, num)
    local taskprocess = self._task_progress[tid]
    if taskprocess then
        for i, v in ipairs(taskprocess.condition) do
            if v == TASK_CONDITION_TYPE.TCT_USE_ITEM then
                if taskprocess.request[i][1] == itemid and taskprocess.finish[i] == false then
                    taskprocess.process[i] = taskprocess.process[i] + num
                    if taskprocess.process[i] >= taskprocess.request[i][2] then
                        taskprocess.finish[i] = true
                    end
                    taskprocess.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressKillMonsterGroup(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_GROUP]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByKillMonsterGroup(v, id, num)
        end
    end
end

function task_module:updateTaskProgressByKillMonsterGroup(tid, id, num)
    local taskprocess = self._task_progress[tid]
    if taskprocess then
        for i, v in ipairs(taskprocess.condition) do
            if v == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_GROUP then
                if taskprocess.request[i][1] == id and taskprocess.finish[i] == false then
                    taskprocess.process[i] = taskprocess.process[i] + num
                    if taskprocess.process[i] >= taskprocess.request[i][2] then
                        taskprocess.finish[i] = true
                    end
                    taskprocess.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressKillMonsterLevel(level, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_LEVEL]
    if taskprogress[level] then
        for i, v in pairs(taskprogress[level]) do
            self:updateTaskProgressByKillMonsterLevel(v, level, num)
        end
    end
end

function task_module:updateTaskProgressByKillMonsterLevel(tid, level, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_LEVEL then
                if v.request[index][1] == level and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressPlayerLevel(level)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL]
    if taskprogress[1] then
        for i, v in pairs(taskprogress[1]) do
            self:updateTaskProgressByPlayerLevel(v, level)
       end
    end
end

function task_module:updateTaskProgressByPlayerLevel(tid, level)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_PLAYER_LEVEL then
                if v.process[index] ~= level and v.finish[index] == false then
                    v.process[index] = level
                    if v.process[index] >= v.request[index][1] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressCollect(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_CAIJI]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByCollect(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByCollect(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_CAIJI then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressDig(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_DIG]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByDig(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByDig(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_DIG then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressBuildItem(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_BUILD_ITEM]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByBuildItem(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByBuildItem(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_BUILD_ITEM then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressCook(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_COOK]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByCook(v, id, num)
        end
    end
end

function task_module:updateTaskProgressByCook(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_COOK then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressUseDrug(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_USE_DRUG]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByUseDrug(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByUseDrug(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_USE_DRUG then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressPassDungeon(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_PASS_DUNGEON]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByPassDungeon(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByPassDungeon(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_PASS_DUNGEON then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressEquip(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_EQUIP]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByEquip(v, id)
       end
    end
end

function task_module:updateTaskProgressByEquip(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_EQUIP then
            if v.request[index][1] == id and v.finish[index] == false then
                v.process[index] = 1
                v.finish[index] = true
                v.update = true
                self._need_update_progress = true
            end
            end
        end
    end
end

function task_module:taskProgressKillPlayer(num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_PLAYER]
    if taskprogress[1] then
        for i, v in pairs(taskprogress[1]) do
            self:updateTaskProgressByKillPlayer(v, num)
       end
    end
end

function task_module:updateTaskProgressByKillPlayer(tid, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_KILL_PLAYER then
                if v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][1] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressStrengthEquip(id, level)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_STRENGTH_EQUIP]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByStrengthEquip(v, id, level)
       end
    end
end

function task_module:updateTaskProgressByStrengthEquip(tid, id, level)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_STRENGTH_EQUIP then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = level
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressHunhuan(id, level)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_HUNHUAN]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByHunhuan(v, id, level)
       end
    end
end

function task_module:updateTaskProgressByHunhuan(tid, id, level)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_HUNHUAN then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = level
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressSkillLevel(id, level)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_SKILL_LEVEL]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressBySkillLevel(v, id, level)
       end
    end
end

function task_module:updateTaskProgressBySkillLevel(tid, id, level)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_SKILL_LEVEL then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = level
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressFriendlines(id, level)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_FRIENDLINES]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByFriendlines(v, id, level)
       end
    end
end

function task_module:updateTaskProgressByFriendlines(tid, id, level)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_FRIENDLINES then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = level
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressReachPlace(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_REACH_PLACE]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByReachPlace(v, id)
       end
    end
end

function task_module:updateTaskProgressByReachPlace(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_REACH_PLACE then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

--TCT_ACHIEVEMENT
--TCT_QIYU

function task_module:taskProgressRead(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_READ]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByRead(v, id)
       end
    end
end

function task_module:updateTaskProgressByRead(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_READ then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressUnlockMap(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_UNLOCK_MAP]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByUnlockMap(v, id)
       end
    end
end

function task_module:updateTaskProgressByUnlockMap(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_UNLOCK_MAP then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressKillMonsterNum(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_KILL_MONSTER_NUM]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByKillMonsterNum(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByKillMonsterNum(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_KILL_MONSTER_NUM then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressGetItem(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_GET_ITEM]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByGetItem(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByGetItem(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_GET_ITEM then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressUpgradeHunhuan(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_UPGRADE_HUNHUAN]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByUpgradeHunhuan(v, id, num)
       end
    end
end

function task_module:updateTaskProgressByUpgradeHunhuan(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_UPGRADE_HUNHUAN then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end


function task_module:taskProgressCloseUiWindow(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_CLOSE_UI_WINDOW]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByCloseUiWindow(v, id)
       end
    end
end

function task_module:updateTaskProgressByCloseUiWindow(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_CLOSE_UI_WINDOW then
                if v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressDazuo(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_DAZUO]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByDazuo(v, id)
       end
    end
end

function task_module:updateTaskProgressByDazuo(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_DAZUO then
                if v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressReachPlaceTimer(id, time)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByReachPlaceTimer(v, id, time)
       end
    end
end

function task_module:updateTaskProgressByReachPlaceTimer(tid, id, time)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_REACH_PLACE_TIMER then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = time
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressFollowNpc(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_FOLLOW_NPC]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByFollowNpc(v, id)
       end
    end
end

function task_module:updateTaskProgressByFollowNpc(tid, id)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_FOLLOW_NPC then
                if v.finish[index] == false then
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end


function task_module:taskProgressSellGoods(id, num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_SELL_GOODS]
    if taskprogress[id] then
        for i, v in pairs(taskprogress[id]) do
            self:updateTaskProgressBySellGoods(v, id, num)
        end
    end
end

function task_module:updateTaskProgressBySellGoods(tid, id, num)
    local v = self._task_progress[tid]
    if v then
        for index, value in ipairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_SELL_GOODS then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][2] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressNpcItem(npc,id,num)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_NPC_ITEM]
    if taskprogress[npc] then
        for k, v in pairs(taskprogress[npc]) do
            self:updateTaskProgressByNpcItem(v,npc,id,num)
        end
    end
end

function task_module:updateTaskProgressByNpcItem(tid,npc,id,num)
    local v = self._task_progress[tid]
    if v then
        for index, value in pairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_NPC_ITEM then
                if v.request[index][1] == npc and v.request[index][2] == id and v.finish[index] == false then
                    v.process[index] = v.process[index] + num
                    if v.process[index] >= v.request[index][3] then
                        v.finish[index] = true
                    end
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressMonsterMinHP(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_MONSTER_MIN_HP]
    if taskprogress[id] then
        for k, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByMonsterMinHP(v,id)
        end
    end
end

function task_module:updateTaskProgressByMonsterMinHP(tid,id)
    local v = self._task_progress[tid]
    if v then
        for index, value in pairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_MONSTER_MIN_HP then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = 1
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:taskProgressGetHunhuan(id)
    local taskprogress = self._progress_all[TASK_CONDITION_TYPE.TCT_GET_HUNHUAN]
    if taskprogress[id] then
        for k, v in pairs(taskprogress[id]) do
            self:updateTaskProgressByGetHunhuan(v,id)
        end
    end
end

function task_module:updateTaskProgressByGetHunhuan(tid,id)
    local v = self._task_progress[tid]
    if v then
        for index, value in pairs(v.condition) do
            if value == TASK_CONDITION_TYPE.TCT_GET_HUNHUAN then
                if v.request[index][1] == id and v.finish[index] == false then
                    v.process[index] = 1
                    v.finish[index] = true
                    v.update = true
                    self._need_update_progress = true
                end
            end
        end
    end
end

function task_module:sendTaskInfo(ttype, taskid, state, process, time)
    local taskinfo = {
		ttype = ttype,
		taskid = taskid,
		state = state,
		process = process,
        time = time or 0,
	}
	self:sendMsg(_sm.SM_TASK_INFO, taskinfo, "SingleTaskInfo")
end

function task_module:sendTypeTaskInfo(ttype, done)
    local task = {}
    if ttype == TASK_TYPE.TTYPE_DAILY_XY then
        task = self._task_xy
    elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
        task = self._task_tddg
    elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        task = self._task_xldg
    --elseif ttype == TASK_TYPE.TTYPE_WEEK_WHD then
    --    task = self._task_whd
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        task = self._task_zj
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        task = self._task_branch
    elseif ttype == TASK_TYPE.TTYPE_BAOXIANG then
        task = self._task_baoxiang
    end
    local taskPb = {}
    for tid, v in pairs(task) do
        local check = false
        if done and done == 1 then
            if v.state == TASK_STATE.TSTATE_DONE then
                check = true
            end
        elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG or ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
            check = true
        elseif self._task_progress[tid] then
            check = true
        end
        if check then
            taskPb[#taskPb +1] = {
                taskid = tid,
                state = v.state,
                process = v.process,
                time = v.time,
            }
        end
    end
    if #taskPb > 0 then
        self:sendMsg(_sm.SM_TYPE_TASK_INFO, {ttype = ttype, task = taskPb}, "SmTypeTaskInfo")
    end
end

function task_module:sendTaskData()
    local data = {}
    data[#data+1] = self:getRecord(RECORD_TYPE.RT_XY_TASK_GIFT)
    data[#data+1] = self:getRecord(RECORD_TYPE.RT_ZZ_TASK_GIFT)

    self:sendMsg(_sm.SM_TASK_DATA, {data = data}, "SmTaskData")
end

function task_module:sendTaskRoundInfo()
    local data = {}
    for _, v in pairs(self._task_round) do
        data[#data+1] = v
    end
    self:sendMsg(_sm.SM_TASK_ROUND_INFO, {task = data}, "SmTaskRound")
end

function task_module:sendTaskWarTokenInfo()
    local data = {}
    for _, v in pairs(self._task_war_token) do
        data[#data+1] = v
    end
    self:sendMsg(_sm.SM_TASK_WAR_TOKEN_INFO, {task = data}, "SmTaskWarToken")
end

function task_module:updateTaskDB(ttype, task)
    local pb = {}
    if ttype == TASK_TYPE.TTYPE_TRUNK then
        pb = { cid = task.cid, tid = task.tid, state = task.state, progress = table.concat(task.progress, ","), time = task.time}
        self:dbUpdateData(_table.TAB_mem_chr_task_trunk, pb)
    elseif ttype == TASK_TYPE.TTYPE_BAOXIANG then
        pb = {cid = task.cid, tid = task.tid, state = task.state, progress = table.concat(task.progress, ","), time = task.time}
        self:dbUpdateData(_table.TAB_mem_chr_baoxiang_task, pb)
    elseif ttype == TASK_TYPE.TTYPE_DAILY_XY or ttype == TASK_TYPE.TTYPE_WEEK_TDDG or ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
        if task then
            pb[#pb+1] = {cid = self.cid, tid = task.tid, ttype = ttype, state = task.state, progress = table.concat(task.progress, ","), time = task.time}
        else
            local taskInfo = {}
            if ttype == TASK_TYPE.TTYPE_DAILY_XY then
                taskInfo = self._task_xy
            elseif ttype == TASK_TYPE.TTYPE_WEEK_TDDG then
                taskInfo = self._task_tddg
            elseif ttype == TASK_TYPE.TTYPE_WEEK_XLDG then
                taskInfo = self._task_xldg
            end
            for tid, v in pairs(taskInfo) do
                pb[#pb+1] = {
                    cid = self.cid,
                    tid = tid,
                    ttype = ttype,
                    state = v.state,
                    progress = table.concat(task.progress, ","),
                    time = v.time,
                }
            end
        end
        self:dbUpdateDataVector(_table.TAB_mem_chr_task_random, pb)
    elseif ttype == TASK_TYPE.TTYPE_BRANCH then
        if task then
            pb[#pb+1] = {cid = self.cid, tid = task.tid, state = task.state, progress = table.concat(task.progress, ","), time = task.time}
        else
            for tid, v in pairs(self._task_branch) do
                pb[#pb+1] = {
                    cid = self.cid,
                    tid = tid,
                    state = v.state,
                    progress = table.concat(task.progress, ","),
                    time = v.time,
                }
            end
        end
        self:dbUpdateDataVector(_table.TAB_mem_chr_task_branch, pb)
    elseif ttype == TASK_TYPE.TTYPE_ZHUANJI then
        if task then
            pb[#pb+1] = {cid = self.cid, tid = task.tid, state = task.state, progress = table.concat(task.progress, ","), time = task.time}
        else
            for tid, v in pairs(self._task_zj) do
                pb[#pb+1] = {
                    cid = self.cid,
                    tid = tid,
                    state = v.state,
                    progress = table.concat(task.progress, ","),
                    time = v.time,
                }
            end
        end
        self:dbUpdateDataVector(_table.TAB_mem_chr_task_zhuanji, pb)
    end
end

function task_module:updateTaskRoundDB(tids)
    if table.empty(self._task_round) then
        return
    end
    local pb = {}
    if tids then
        for _, tid in pairs(tids) do
            local task = self._task_round[tid]
            if task then
                pb[#pb+1] = {
                    cid = self.cid,
                    round = task.round,
                    tid = tid,
                    state = task.state,
                    progress = task.progress,
                }
            end
        end
    else
        for _, v in pairs(self._task_round) do
            pb[#pb+1] = {
                cid = self.cid,
                round = v.round,
                tid = v.tid,
                state = v.state,
                progress = v.progress,
            }
        end
    end
    if #pb > 0 then
        self:dbUpdateDataVector(_table.TAB_mem_chr_task_round, pb)
    end
end

function task_module:updateTaskWarTokenDB(tids)
    if table.empty(self._task_war_token) then
        return
    end
    local pb = {}
    if tids then
        for _, tid in pairs(tids) do
            local task = self._task_war_token[tid]
            if task then
                pb[#pb+1] = {
                    cid = self.cid,
                    tid = tid,
                    state = task.state,
                    progress = task.progress,
                }
            end
        end
    else
        for _, v in pairs(self._task_war_token) do
            pb[#pb+1] = {
                cid = self.cid,
                tid = v.tid,
                state = v.state,
                progress = v.progress,
            }
        end
    end
    if #pb > 0 then
        self:dbUpdateDataVector(_table.TAB_mem_chr_task_war_token, pb)
    end
end

return task_module