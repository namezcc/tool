local _cm = CM
local _sm = SM
local _msg_func = MSG_FUNC
local _func = LFUNC
local _team = ALL_TEAM
local _pack = PACK
local _equip_mgr = nil
local _net_mgr = nil
local _ply_mgr = nil

local MAX_TEAM_MEMBER_COUNT = 6
local TEAM_ACTION = {
    REFUSE_APPLY = 1,
    REFUSE_INVIT = 2,
    KICK_MEMBER = 3,
    KICK_ME = 4,
    LEAVE = 5,
    DISSMISS = 6,
    TRANSFER = 7,
    JOIN = 8,
}

local team_module = {}

function team_module:init()
    _equip_mgr = MOD.equip_mgr_module
	_net_mgr = MOD.net_mgr_module
	_ply_mgr = MOD.player_mgr_module
	_msg_func.bind_player_proto_func(_cm.CM_TEAM_ACT, self.onTeamAct, "PInt64Array")
    _msg_func.bind_player_proto_func(_cm.CM_TEAM_CONFIRM_DUNGEON, self.onTeamConfirmDungeon, "PInt64")
end

function team_module:initDB(data)
    self._team = nil
    self._team_apply = {}
    self._team_applyrec = {}
end

function team_module:afterInit()
    self:sendTeamInfo()
end

function team_module:onTeamAct(d)
    local act = d.data[1]
    if act == 1 then
        local type = d.data[2]
        local param1 = d.data[3]
        local param2 = d.data[4]
        self:sendTeamInfo(type, param1, param2)
    elseif act == 2 then
        local module = d.data[2]
        local target = d.data[3]
        local private = d.data[4]
        local minlv = d.data[5]
        local maxlv = d.data[6]
        self:createTeam(module,target,private,minlv,maxlv) -- 创建队伍
    elseif act == 3 then
        local teamId = d.data[2]
        self:teamApply(teamId) -- 申请入队
    elseif act == 4 then
        local apply_cid = d.data[2]
        local agree = d.data[3]
        self:teamApplyManage(apply_cid,agree) -- 同意/拒绝入队申请(仅队长可操作)
    elseif act == 5 then
        local invited_cid = d.data[2]
        self:teamInvite(invited_cid) -- 邀请入队
    elseif act == 6 then
        local invit_id = d.data[2]
        local invit_target = d.data[3]
        local invit_cid = d.data[4]
        local agree = d.data[5]
        self:teamInviteManage(invit_target,invit_id,invit_cid,agree) -- 同意/拒绝入队邀请
    elseif act == 7 then
        local member_cid = d.data[2]
        self:teamKick(member_cid) -- 队伍踢人(仅队长可操作)
    elseif act == 8 then
        local member_cid = d.data[2]
        self:teamtransfer(member_cid) -- 队长位置转让
    elseif act == 9 then
        self:teamLeave() -- 离队(队长离队自动转让队长位置)
    elseif act == 10 then
        self:teamDismiss() -- 解散队伍(仅队长可操作)
    elseif act == 11 then
        self:updateReady() -- 准备/准备中切换
    elseif act == 12 then
        local dungeonid = d.data[2]
        self:signUpDungeon(dungeonid)
    elseif act == 13 then
        local dungeonid = d.data[2]
        local result = d.data[3]
        self:dungeonSignResult(dungeonid, result);
    elseif act == 14 then
        local dungeonid = d.data[2]
        self:cancelSignDungeon(dungeonid)
    end
end

function team_module:createTeam(module,target,private,minlv,maxlv)
    if self._team then
        return
    end
    if not module or not target or not private or not minlv or not maxlv then
        return
    end
    local team = _equip_mgr:createTeam(module,target,private,minlv,maxlv)
    team.leader = {
        cid = self.cid,
        sex = self._chr_info.sex,
        job = self._chr_info.job,
        level = self._chr_info.level,
        name = self._chr_info.name,
        ready = 0
    }
    self._team = team
    self._team_apply = {}
    self._team_applyrec = {}
    _team[#_team+1] = team
    self:sendTeamInfo()
    self:enterTeamChatRoom()
end

function team_module:teamApply(teamId)
    if self._team then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,1})
        return
    end
    if not teamId or teamId < 1 then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,2})
        return
    end
    local index = self:getTeamById(teamId)
    if index < 0 then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,3})
        return
    end
    local team = _team[index]
    if not team or team.id ~= teamId then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,3})
        return
    end
    if self._chr_info.level < team.minlv or self._chr_info.level > team.maxlv then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,4})
        return
    end
    if #team.member >= MAX_TEAM_MEMBER_COUNT then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,5})
        return
    end
    local preApply = 0
    for k, v in pairs(self._team_apply) do
        if v.teamId == teamId then
            preApply = k
            break
        end
    end
    if preApply > 0 then
        if _func.getNowSecond() - self._team_apply[preApply].time < 60 then
            self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {3,teamId,6})
            return
        else
            self._team_apply[preApply].time = _func.getNowSecond()
        end
    else
        -- 我的申请记录
        self._team_apply[#self._team_apply+1] = {
            target = team.target,
            teamId = teamId,
            cid = team.leader.cid,
            sex = team.leader.sex,
            job = team.leader.job,
            level = team.leader.level,
            name = team.leader.name,
            time = _func.getNowSecond(),
        }
    end

    -- 发送申请记录给前端
    if self._team_apply then
        self:sendMsg(_sm.SM_TEAM_APPLY,{log = self._team_apply},"SmTeamApplyLog")
    end

    -- 发送申请消息给队长
    local data = {
        cid = self.cid,
        sex = self._chr_info.sex,
        job = self._chr_info.job,
        level = self._chr_info.level,
        name = self._chr_info.name,
        time = _func.getNowSecond(),
        agree = 0,
    }
    self:sendMsgToOtherPlayer(team.leader.cid,self.teamApplyRec,data)
end

function team_module:teamApplyRec(data)
    if not data then
        return
    end
    local index = 0
    for k, v in pairs(self._team_applyrec) do
        if v.cid == data.cid and v.agree ~= 1 then
            index = k
            break
        end
    end
    if index > 0 then
        self._team_applyrec[index] = data
    else
        self._team_applyrec[#self._team_applyrec+1] = data
    end
    self:sendTeamApplyRecInfo()
end

function team_module:teamApplyManage(cid,agree)
    -- 同意/拒绝入队申请
    if not cid or not agree then
        return
    end
    if #self._team.member >= MAX_TEAM_MEMBER_COUNT then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {4,cid,1})
        return
    end
    if self.cid ~= self._team.leader.cid then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {4,cid,2})
        return
    end
    for _, v in ipairs(self._team.member) do
        if v.cid == cid then
            self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {4,cid,3})
            return
        end
    end
    if self:checkInTeam(cid) > 0 then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {4,cid,4})
        return
    end
    local ply = _ply_mgr:getPlayerByCid(cid)
    if not ply or not ply._chr_info then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {4,cid,5})
        return
    end
    local recId = 0
    local apply = {}
    for k, v in pairs(self._team_applyrec) do
        if v.cid == cid then
            recId = k
            apply = {
                cid = v.cid,
                sex = v.sex,
                job = v.job,
                level = v.level,
                name = v.name,
                ready = 0,
            }
            break
        end
    end

    if agree == 1 then
        -- 同意入队,通知全队成员,改变申请者队伍消息
        self._team.member[#self._team.member+1] = apply
        local index = self:getTeamById(self._team.id)
        _team[index].member = self._team.member
        local data = {cid=cid,name=apply.name,type=TEAM_ACTION.JOIN}
        self:sendTeamAction(data)

        -- 自身更新信息,队友更新信息
        self:sendTeamInfo()
        for _, v in pairs(self._team.member) do
            self:sendMsgToOtherPlayer(v.cid,self.teamAddMember,data)
        end
        self._team_applyrec[recId].agree = 1
        self:sendTeamApplyRecInfo()
    else
        -- 通知被拒绝者
        self:sendMsgToOtherPlayer(cid,self.sendTeamAction,{cid=self.cid,name=apply.name,type=TEAM_ACTION.REFUSE_APPLY})
        self._team_applyrec[recId].agree = 2
        self:sendTeamApplyRecInfo()
    end
end

function team_module:teamAddMember(data)
    if data.cid == self.cid then
        self._team_apply = {}
        self:enterTeamChatRoom()
    end
    self:updateTeamInfo()
    self:sendTeamAction(data)
end

function team_module:teamInvite(cid)
    if not self._team then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {5,cid,1})
        return
    end
    if not cid then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {5,cid,2})
        return
    end
    if self:checkInTeam(cid) > 0 then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {5,cid,3})
        return
    end
    if #self._team.member >= MAX_TEAM_MEMBER_COUNT then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {5,cid,4})
        return
    end
    local ply = _ply_mgr:getPlayerByCid(cid)
    if not ply or not ply._chr_info then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {5,cid,5})
        return
    end

    -- 发送邀请消息给被邀请者
    local data = {
        target = self._team.target,
        teamId = self._team.id,
        cid = self.cid,
        sex = self._chr_info.sex,
        job = self._chr_info.job,
        level = self._chr_info.level,
        name = self._chr_info.name,
        time = _func.getNowSecond(),
    }
    self:sendMsgToOtherPlayer(cid,self.teamInviteRec,data)
end

function team_module:teamInviteRec(data)
    if data then
        self:sendMsg(_sm.SM_TEAM_INVIT,data,"SmTeamInvit")
    end
end

function team_module:teamInviteManage(target,teamId,cid,agree)
    -- 同意/拒绝邀请
    if self._team then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {6,cid,1})
        return
    end
    if not target or not teamId or not cid or not agree then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {6,cid,2})
        return
    end
    if target < 0 or teamId < 0 then
        self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {6,cid,2})
        return
    end
    if agree == 1 then
        local index = self:getTeamById(teamId)
        if index < 0 then
            self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {6,cid,3})
            return
        end
        if #_team[index].member >= MAX_TEAM_MEMBER_COUNT then
            self:replyMsg(_cm.CM_TEAM_ACT, ERROR_CODE.ERR_TEAM_FAIL, {6,cid,4})
            return
        end
        local invite = {
            cid = self.cid,
            sex = self._chr_info.sex,
            job = self._chr_info.job,
            level = self._chr_info.level,
            name = self._chr_info.name,
            ready = 0,
        }
        local member = _team[index].member
        member[#member+1] = invite
        _team[index].member = member
        self._team = _team[index]

        -- 同意,通知组里其他成员
        self:sendTeamInfo()
        local data = {cid=self.cid,name=self._chr_info.name,type=TEAM_ACTION.JOIN}
        self:sendMsgToOtherPlayer(self._team.leader.cid,self.teamAddMember,data)
        for _, v in pairs(member) do
            -- 需要更新队友的信息
            self:sendMsgToOtherPlayer(v.cid,self.teamAddMember,data)
        end
    else
        -- 拒绝，通知被拒绝者
        self:sendMsgToOtherPlayer(cid,self.sendTeamAction,{cid=self.cid,name=self._chr_info.name,type=TEAM_ACTION.REFUSE_INVIT})
    end
end

function team_module:teamKick(cid)
    if not cid or cid == self.cid then
        return
    end
    if self.cid ~= self._team.leader.cid then
        return
    end
    local idx = 0
    for k, v in pairs(self._team.member) do
        if v.cid == cid then
            idx = k
            break
        end
    end
    if idx == 0 then
        return
    end
    local index = self:checkInTeam(cid)
    if index < 0 then
        return
    end
    local name = self._team.member[idx].name
    table.remove(self._team.member,idx)
    table.remove(_team[index].member,idx)

    -- 通知被踢者，所有组员
    self:sendTeamInfo()
    for _, v in pairs(self._team.member) do
        self:sendMsgToOtherPlayer(v.cid,self.teamKicked,{cid=cid,name=name,type=TEAM_ACTION.KICK_MEMBER})
    end
    self:sendMsgToOtherPlayer(cid,self.teamKicked,{cid=self.cid,name=self._chr_info.name,type=TEAM_ACTION.KICK_ME})
end

function team_module:teamKicked(data)
    if data.type == TEAM_ACTION.KICK_MEMBER then
        self:updateTeamInfo()
    elseif data.type == TEAM_ACTION.KICK_ME then
        self._team = nil
        self:sendTeamInfo()
        self:quitTeamChatRoom()
    end
    self:sendTeamAction(data)
end

function team_module:teamLeave()
    if not self._team then
        return
    end
    local data = {cid=self.cid,name=self._chr_info.name,type=TEAM_ACTION.LEAVE}
    if self.cid == self._team.leader.cid then
        -- 自身是队长，那下一位队友是队长,且通知所有成员，如果当前无队友则解散队伍
        if #self._team.member > 0 then
            local index = self:getTeamById(self._team.id)
            _team[index].leader = self._team.member[1]
            table.remove(_team[index].member,1)
            self._team = nil
            self._team_applyrec = {}
            self:sendTeamInfo()
            self:sendTeamAction(data)
            self:quitTeamChatRoom()

            -- 通知组员
            self:sendMsgToOtherPlayer(_team[index].leader.cid,self.teamLeft,data)
            for _, v in pairs(_team[index].member) do
                self:sendMsgToOtherPlayer(v.cid,self.teamLeft,data)
            end
        else
            local index = self:getTeamById(self._team.id)
            table.remove(_team, index)
            self._team = nil
            self._team_applyrec = {}
            self:sendTeamInfo()
            self:sendTeamAction(data)
        end
    else
        local idx = 0
        for k, v in pairs(self._team.member) do
            if v.cid == self.cid then
                idx = k
                break
            end
        end
        if idx == 0 then
            return
        end
        local index = self:getTeamById(self._team.id)
        table.remove(_team[index].member,idx)
        self._team = nil
        self:sendTeamInfo()
        self:sendTeamAction(data)
        self:quitTeamChatRoom()

        -- 通知组员
        self:sendMsgToOtherPlayer(_team[index].leader.cid,self.teamLeft,data)
        for _, v in pairs(_team[index].member) do
            self:sendMsgToOtherPlayer(v.cid,self.teamLeft,data)
        end
    end
end

function team_module:teamLeft(data)
    self:updateTeamInfo()
    self:sendTeamAction(data)
end

function team_module:teamDismiss()
    if not self._team then
        return
    end
    if self.cid ~= self._team.leader.cid then
        return
    end
    -- 通知组员
    local data = {cid=self.cid,name=self._chr_info.name,type=TEAM_ACTION.DISSMISS}
    self:sendTeamAction(data)
    self:quitTeamChatRoom()
    for _, v in pairs(self._team.member) do
        self:sendMsgToOtherPlayer(v.cid,self.teamDismissed,data)
    end
    local index = self:getTeamById(self._team.id)
    table.remove(_team, index)
    self._team = nil
    self._team_applyrec = {}
    self:sendTeamInfo()
end

function team_module:teamDismissed(data)
    self._team = nil
    self:sendTeamInfo()
    self:sendTeamAction(data)
    self:quitTeamChatRoom()
end

function team_module:teamtransfer(cid)
    if not cid or cid == self.cid then
        return
    end
    if self.cid ~= self._team.leader.cid then
        return
    end
    local idx = 0
    for k, v in pairs(self._team.member) do
        if cid == v.cid then
            idx = k
            break
        end
    end
    if idx == 0 then
        return
    end
    self._team.leader,self._team.member[idx] =self._team.member[idx], self._team.leader
    local index = self:getTeamById(self._team.id)
    _team[index] = self._team

    --通知组员
    local data = {cid=cid,name=self._team.leader.name,type=TEAM_ACTION.TRANSFER}
    self:sendTeamInfo()
    self:sendMsgToOtherPlayer(self._team.leader.cid,self.teamtransfered,data)
    for _, v in pairs(self._team.member) do
        if v.cid ~= self.cid then
            self:sendMsgToOtherPlayer(v.cid,self.teamtransfered,data)
        end
    end
end

function team_module:teamtransfered(data)
    self:updateTeamInfo()
    self:sendTeamAction(data)
end

function team_module:updateReady()
    if not self._team then  -- 0:未准备 1:已准备
        return
    end
    local index = self:getTeamById(self._team.id)
    if self.cid == self._team.leader.cid then
        if self._team.leader.ready == 1 then
            self._team.leader.ready = 0
        else
            self._team.leader.ready = 1
        end
        _team[index] = self._team

        self:sendTeamInfo()
        for _, v in pairs(self._team.member) do
            self:sendMsgToOtherPlayer(v.cid,self.sendTeamInfo)
        end
    else
        for k, v in pairs(self._team.member) do
            if self.cid == v.cid then
                if self._team.member[k].ready == 1 then
                    self._team.member[k].ready = 0
                else
                    self._team.member[k].ready = 1
                end
                break
            end
        end
        _team[index] = self._team

        self:sendTeamInfo()
        self:sendMsgToOtherPlayer(self._team.leader.cid,self.sendTeamInfo)
        for _, v in pairs(self._team.member) do
            if v.cid ~= self.cid then
                self:sendMsgToOtherPlayer(v.cid,self.sendTeamInfo)
            end
        end
    end
end

function team_module:updateTeamInfo()
    local index = -1
    if self._team then
        index = self:getTeamById(self._team.id)
    else
        index = self:checkInTeam(self.cid)
    end
    if index < 0 or not _team[index] then
        return
    end
    self._team = _team[index]
    self:sendTeamInfo()
end

function team_module:updateTeamInfoWithoutSend()
    local index = -1
    if self._team then
        index = self:getTeamById(self._team.id)
    else
        index = self:checkInTeam(self.cid)
    end
    if index < 0 or not _team[index] then
        return
    end
    self._team = _team[index]
end

function team_module:getTeamById(teamId)
    for k, v in pairs(_team) do
        if v.id == teamId then
            return k
        end
    end
    return -1
end

function team_module:checkInTeam(cid)
    for k, v in pairs(_team) do
        if v.leader.cid == cid then
            return k,0
        end
        for index, vv in pairs(v.member) do
            if vv.cid == cid then
                return k,index
            end
        end
    end
    return -1,-1
end

function team_module:sendTeamInfo(type,param1,param2)
    local tp = type or 1    -- tp: 1-my,2-near,3-all,4-team_id,5-cid

    local pb = {}
    if tp == 1 then
        if self._team then
            pb[#pb+1] = self._team
        end
    elseif tp == 2 then
        for _, v in pairs(_team) do
            if v.private ~= 1 and self._chr_info.map == self:getOtherPlayerMap(v.leader.cid) then
                pb[#pb+1] = v
            end
        end
    elseif tp == 3 then
        local module = param1
        local target = param2
        if module < 0 or target < 0 then
            return
        end
        for _, v in pairs(_team) do
            if v.private ~= 1 then
                if module == 0 or module == v.module then
                    if target == 0 or target == v.target then
                        pb[#pb+1] = v
                    end
                end
            end
        end
    elseif tp == 4 then
        local teamId = param1
        for _, v in pairs(_team) do
            if v.id == teamId then
                pb[#pb+1] = v
                break
            end
        end
    elseif tp == 5 then
        local cid = param1
        local index = self:checkInTeam(cid)
        if index > 0 then
            pb[#pb+1] = _team[index]
        end
    end
    self:sendMsg(_sm.SM_TEAM_INFO,{type=tp, team=pb},"SmTeamInfo")
end

function team_module:sendTeamApplyRecInfo()
    if not self._team then
        return
    end
    if self._team.leader.cid ~= self.cid then
        return
    end
    if #self._team_applyrec > 0 then
        self:sendMsg(_sm.SM_TEAM_APPLY_REC,{apply = self._team_applyrec},"SmTeamApplyRec")
    end
end

function team_module:sendTeamAction(data)
    if data then
        self:sendMsg(_sm.SM_TEAM_ACTION,data,"SmTeamAction")
    end
end

function team_module:enterTeamChatRoom()
	if self._team == nil then
		return
	end
	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local pack = _pack.poppack()
		pack:writeint64(self.cid)
		pack:writeint32(1)
		pack:writeint64(self._team.id)
		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_ENTER_TEAM,pack)
	end
end

function team_module:quitTeamChatRoom()
	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local pack = _pack.poppack()
		pack:writeint64(self.cid)
		pack:writeint32(1)

		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_QUIT_TEAM,pack)
	end
end

function team_module:signUpDungeon(dungeonid)
    --只有队长才能发起
    if self._team == nil then
        return
    end
    if self.cid ~= self._team.leader.cid then
        return
    end
    if self._team.state ~= TEAM_STATE.TS_START and self._team.state ~= TEAM_STATE.TS_SUCC and not (self._team.state == TEAM_STATE.TS_WAIT_SIGN and _func.getNowSecond() > self._team.time + 15  ) then
        return
    end

    local index = self:getTeamById(self._team.id)
    if index == -1 then
        return
    end

    if self._team.state == TEAM_STATE.TS_WAIT_SIGN then
        for _, v in pairs(self._team.member) do
            v.ready = 0
        end
    end
    self._team.uniqueid = 0
    self._team.dungeonid = dungeonid
    self._team.state = TEAM_STATE.TS_WAIT_SIGN
    self._team.time = _func.getNowSecond()
    self._team.leader.ready = 1
    _team[index] = self._team

    if #self._team.member == 0 then
        self:dungeonSignUp()
        self:sendTeamInfo()
    else
        for _, v in pairs(self._team.member) do
            self:sendMsgToOtherPlayer(v.cid,self.teamSignUpDungeon,dungeonid)
        end
    end
end

function team_module:cancelSignDungeon(dungeonid)
    --只有队长才能发起
    if self._team == nil then
        return
    end
    if self.cid ~= self._team.leader.cid then
        return
    end
    if self._team.state ~= TS_SIGNED then
        return
    end
    if self._team.dungeonid ~= dungeonid then
        return
    end
    _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_CANCEL_SIGN_DUNGEON,{data=self._team.id},"PInt64")
end

function team_module:teamSignUpDungeon(dungeonid)
    self:updateTeamInfo()
    local data = {
        dungeonid = dungeonid,
    }
    self:sendMsg(_sm.SM_REQUEST_SIGN_DUNGEON,data,"SmRequestSignDungeon")
end

function team_module:dungeonSignResult(dungeonid, result)
    if self._team == nil then
        return
    end
    if self._team.dungeonid ~= dungeonid then
        return
    end
    if self._team.state ~= TEAM_STATE.TS_WAIT_SIGN then
        return
    end
    local index = self:getTeamById(self._team.id)
    if index == -1 then
        return
    end

    if self._team.leader.cid == self.cid then
        self._team.leader.ready = result
    else
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = result
            end
        end
    end
    local readynum = 0
    if self._team.leader.ready == 1 then
        readynum = readynum + 1
    end

    for _, v in pairs(self._team.member) do
        if v.ready == 1 then
            readynum = readynum + 1
        end
    end

    if readynum == (#self._team.member + 1) then
        self:dungeonSignUp()
    end
    _team[index] = self._team

    self:sendMsgToOtherPlayer(self._team.leader.cid,self.updateTeamInfo)
    for _, v in pairs(self._team.member) do
        -- 需要更新队友的信息
        self:sendMsgToOtherPlayer(v.cid,self.updateTeamInfo)
    end
end

function team_module:dungeonSignUp()
    if self._team == nil then
        return
    end

    local pb = 
    {
        serverid = GAME_CONFIG.login_id,
        teamid = self._team.id,
        dungeonid = self._team.dungeonid,
        signinfo = {},
    }
    local signinfo = {}
    local player = _ply_mgr:getPlayerByCid(self._team.leader.cid)
    if player ~= nil then
        local chrinfo = player._chr_info
        signinfo[#signinfo+1] = {
            cid = player.cid,
            name = chrinfo.name,
            job = chrinfo.job,
            level = chrinfo.level,
            fight_type = 0,
            score = 0,
        }
    end

    for _, v in pairs(self._team.member) do
        local tplayer = _ply_mgr:getPlayerByCid(v.cid)
        if tplayer ~= nil then
            local chrinfo = tplayer._chr_info
            signinfo[#signinfo+1] = {
                cid = tplayer.cid,
                name = chrinfo.name,
                job = chrinfo.job,
                level = chrinfo.level,
                fight_type = 0,
                score = 0,
            }
        end
    end

    pb.signinfo = signinfo
    _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_DUNGEON_SIGN_UP,pb,"DungeonCenterSignUp")
end

function team_module:waitConfirm(uniqueid, dungeonid, teamid)
    if self._team == nil then
        return 0
    end
    if self._team.id ~= teamid then
        return 0
    end
    if self._team.dungeonid ~= dungeonid then
        return 0
    end

    if self._team.uniqueid == 0 and self._team.state == TEAM_STATE.TS_SIGNED then
        self._team.uniqueid = uniqueid
        self._team.state = TEAM_STATE.TS_PENDED
        self._team.leader.ready = 0
        for _, v in pairs(self._team.member) do
            v.ready = 0
        end
        local index = self:getTeamById(self._team.id)
        _team[index] = self._team
        self:sendMsgToOtherPlayer(self._team.leader.cid,self.updateTeamInfoWithoutSend)
        for _, v in pairs(self._team.member) do
            -- 需要更新队友的信息
            self:sendMsgToOtherPlayer(v.cid,self.updateTeamInfoWithoutSend)
        end 
    end

    return 1
end

function team_module:updateConfirm(uniqueid, dungeonid, teamid)
    if self._team == nil then
        return
    end
    if self._team.id ~= teamid then
        return
    end
    if self._team.dungeonid ~= dungeonid then
        return
    end

    if self._team.uniqueid ~= uniqueid then
        return
    end

    if self._team.state ~= TEAM_STATE.TS_PENDED then
        return
    end

    if self._team.leader.cid == self.cid then
        self._team.leader.ready = 1
    else
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = 1
            end
        end
    end
    local index = self:getTeamById(teamid)
    _team[index] = self._team
    self:sendTeamInfo()
    self:sendMsgToOtherPlayer(self._team.leader.cid,self.updateTeamInfoWithoutSend)
    for _, v in pairs(self._team.member) do
        -- 需要更新队友的信息
        self:sendMsgToOtherPlayer(v.cid,self.updateTeamInfoWithoutSend)
    end
end

function team_module:updateSignInfo(uniqueid, dungeonid, teamid, infotype)
    if self._team == nil then
        return
    end
    if self._team.id ~= teamid then
        return
    end
    if self._team.dungeonid ~= dungeonid then
        return
    end

    if infotype == 1 then
        if self._team.state ~= TEAM_STATE.TS_WAIT_SIGN then
            return
        end
        self._team.state = TEAM_STATE.TS_SIGNED
        self._team.leader.ready = 1
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = 1
            end
        end
    elseif infotype == 2 then
        if self._team.uniqueid ~= uniqueid then
            return
        end
        if self._team.state ~= TEAM_STATE.TS_PENDED then
            return
        end
        self._team.uniqueid = 0
        self._team.state = TEAM_STATE.TS_SIGNED
        self._team.leader.ready = 1
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = 1
            end
        end
    elseif infotype == 3 then
        if self._team.uniqueid ~= uniqueid then
            return
        end
        if self._team.state ~= TEAM_STATE.TS_PENDED then
            return
        end
        self._team.uniqueid = 0
        self._team.state = TEAM_STATE.TS_START
        self._team.dungeonid = 0
        self._team.time = 0
        self._team.leader.ready = 0
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = 0
            end
        end
    elseif infotype == 4 then
        if self._team.uniqueid ~= uniqueid then
            return
        end
        if self._team.state ~= TEAM_STATE.TS_PENDED then
            return
        end
        self._team.state = TEAM_STATE.TS_SUCC
    elseif infotype == 5 then
        if self._team.state ~= TEAM_STATE.TS_SIGNED then
            return
        end
        self._team.uniqueid = 0
        self._team.state = TEAM_STATE.TS_START
        self._team.dungeonid = 0
        self._team.time = 0
        self._team.leader.ready = 0
        for _, v in pairs(self._team.member) do
            if v.cid == self.cid then
                v.ready = 0
            end
        end
    end

    local index = self:getTeamById(teamid)
    _team[index] = self._team
    self:sendMsgToOtherPlayer(self._team.leader.cid,self.updateTeamInfoWithoutSend)
    for _, v in pairs(self._team.member) do
        -- 需要更新队友的信息
        self:sendMsgToOtherPlayer(v.cid,self.updateTeamInfoWithoutSend)
    end
end

function team_module:onTeamConfirmDungeon(d)
    local uniqueid = d.data
    if self._team == nil then
        return
    end
    if self._team.uniqueid ~= uniqueid then
        return
    end
    if self._team.state ~= TEAM_STATE.TS_PENDED then
        return
    end
    if self.cid == self._team.leader.cid then
        if self._team.leader.ready == 1 then
            return
        else
            --self._team.leader.ready = 1
            --center确认
            local data = {}
            data[#data+1] = self._team.id
            data[#data+1] = uniqueid
            data[#data+1] = self.cid
            local pb = {
                data = data,
            }
            _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_DUNGEON_CONFIRM,pb,"PInt64Array")
        end
    else
        for k, v in pairs(self._team.member) do
            if self.cid == v.cid then
                if self._team.member[k].ready == 1 then
                    return
                else
                    --self._team.member[k].ready = 1
                    --center确认
                    local data = {}
                    data[#data+1] = self._team.id
                    data[#data+1] = uniqueid
                    data[#data+1] = self.cid
                    local pb = {
                        data = data,
                    }
                    _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_DUNGEON_CONFIRM,pb,"PInt64Array")
                end
            end
        end
    end
end

return team_module