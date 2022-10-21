local _cfg = CFG_DATA
local _func = LFUNC
local _IT = ITEM_TYPE
local _cm = CM
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _net_mgr = nil
local _ply_mgr = nil


local arena_module = {}

function arena_module:init()
    _ply_mgr = MOD.player_mgr_module
    _net_mgr = MOD.net_mgr_module
    _msg_func.bind_player_proto_func(_cm.CM_ARENA_DAILY_INFO, self.onArenaDailyInfo, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_ARENA_DAILY_SIGN_UP, self.onArenaDailySignUp, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_REPLY_ARENA_DAILY_SIGN_UP, self.onReplyArenaDailySignUp, "PInt64Array")

end

function arena_module:initDB(data)
	if _func.checkPlayerData(data.arena) then
		self._arena = data.arena
	else
		self._arena = {
			cid = self.cid,
			score = 1000,
			win = 0,
			lose = 0,
			draw = 0,
			time = 0,
		}
	end

	self._arena_sign = {
        state = ARENA_SIGN_UP_STATE.SS_NONE,
        partner_cid = 0,
        time = 0,
        teamid = 0,
    }
end

function arena_module:afterInit()
    

end

function arena_module:loadArenaData(pdata)
    pdata.arena = self._arena
end

function arena_module:onArenaDailyInfo(d)
    self:sendArenaDailyInfo()
end

function arena_module:getAllTeamMember()
    local team = self._team
    if team == nil then
        return {}
    else
        if team.leader.cid == self.cid then
            local member = {}
            for _, v in ipairs(self._team.member) do
                member[#member+1] = v.cid
            end
            return member
        else
            local member = {}
            member[#member+1] = team.leader.cid
            for _, v in ipairs(self._team.member) do
                if v.cid ~= self.cid then
                    member[#member+1] = v.cid
                end
            end
            return member
        end
    end
end

function arena_module:arenaSignUp()

    local pb = 
    {
        serverid = GAME_CONFIG.login_id,
        partner_cid = self.cid,
        signinfo = {},
    }
    local chrinfo = self._chr_info
    local signinfo = {}
    signinfo[#signinfo+1] = 
    {
        cid = self.cid,
        name = chrinfo.name,
        job = chrinfo.job,
        level = chrinfo.level,
        score = self._arena.score,
    }

    if self._arena_sign.partner_cid ~= self.cid then
        local player = _ply_mgr:getPlayerByCid(self._arena_sign.partner_cid )
        if player ~= nil then
            local pcharinfo = player._chr_info
            signinfo[#signinfo+1] = 
            {
                cid = player.cid,
                name = pcharinfo.name,
                job = pcharinfo.job,
                level = pcharinfo.level,
                score = player._arena.score,
            }
        end
    end

    --if #self._arena_sign.teammember ~= 0 then
    --    for i, v in ipairs(self._arena_sign.teammember) do
    --        signinfo[#signinfo+1] = v
    --    end
    --end
    pb.signinfo = signinfo
    _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_ARENA_SIGN_UP,pb,"ArenaCenterSignUp")
end

function arena_module:onArenaDailySignUp(d)
    local signtype = d.i32
    if signtype == 1 then
        if self._arena_sign.state == ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM then
            if _func.getNowSecond() - self._arena_sign.time < 15 then
                return
            else
                self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
                self._arena_sign.partner_cid = 0
                self._arena_sign.time = 0
            end
        elseif self._arena_sign.state ~= ARENA_SIGN_UP_STATE.SS_NONE then
            return
        end

        local teammember = self:getAllTeamMember()
        if #teammember == 1 then
            local player = _ply_mgr:getPlayerByCid(teammember[1])
            if player ~= nil then
                local chrinfo = self._chr_info
                local requestdata = {
                    cid = self.cid,
                    name = chrinfo.name,
                    job = chrinfo.job,
                    level = chrinfo.level,
                    score = self._arena.score,
                }
                local succ = player:requestArenaSign(requestdata, self.cid)
                if succ ~= 0 then
                    self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM
                    self._arena_sign.partner_cid = player.cid
                    self._arena_sign.time = succ
                    self:sendArenaSignUpResult(ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM)
                end
            else
                return
            end
        elseif #teammember == 0 then
            self:arenaSignUp()
        else
            return
        end
    else
        --取消报名
        self:arenaLeave()
    end
end

function arena_module:arenaLeave()
    if self._arena_sign.state ~= ARENA_SIGN_UP_STATE.SS_PENDING then
        return
    end
    _net_mgr:sendToCenterMsg(0,SERVER_MSG.IM_CENTER_CANCEL_SIGN_ARENA,{data = self.cid},"PInt64")
end

function arena_module:updateArenaSignInfo(teamid, infotype, cids)
    if infotype == ARENA_SIGN_UP_STATE.SS_NONE then
        self._arena_sign.state = infotype
        self._arena_sign.partner_cid = 0
        self._arena_sign.time = 0
        self._arena_sign.teamid = teamid
        self:sendArenaSignUpResult(infotype)
    elseif infotype == ARENA_SIGN_UP_STATE.SS_PENDING then
        self._arena_sign.state = infotype
        if #cids == 2 then
            for i, v in ipairs(cids) do
                if v.cid ~= self.cid then
                    self._arena_sign.partner_cid = v.cid
                    self._arena_sign.teamid = teamid
                end
            end
        end
        self:sendArenaSignUpResult(infotype)
    end
end

function arena_module:arenaSignUpReplyed(rep, cid)
    if self._arena_sign.state ~= ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM then
        return 0
    end
    if self._arena_sign.partner_cid ~= cid then
        return 0
    end
    local curnow =  _func.getNowSecond()
    if curnow - self._arena_sign.time > 15 then
        return 0
    end
    if rep == 1 then
        --报名
        self:arenaSignUp()
    else
        --拒绝报名
        self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
        self._arena_sign.time = 0
        self._arena_sign.partner_cid = 0
        self:sendArenaSignUpResult(ARENA_SIGN_UP_STATE.SS_REFUSED)
    end

    return 1
end

function arena_module:onReplyArenaDailySignUp(d)
    if #d.data ~= 2 then
        return
    end
    local rep = d.data[1]
    local cid = d.data[2]
    if rep == 1 then
        local player = _ply_mgr:getPlayerByCid(cid)
        if player ~= nil then
            local succ = player:arenaSignUpReplyed(rep, self.cid)
            if succ ~= 1 then
                self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
                self._arena_sign.partner_cid = 0
                self._arena_sign.time = 0
                self:sendArenaSignUpResult(ARENA_SIGN_UP_STATE.SS_NONE)
            end
        else
            self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
            self._arena_sign.partner_cid = 0
            self._arena_sign.time = 0
            self:sendArenaSignUpResult(ARENA_SIGN_UP_STATE.SS_NONE)
        end
    else
        local player = _ply_mgr:getPlayerByCid(cid)
        if player ~= nil then
            player:arenaSignUpReplyed(rep, self.cid)
        end
        self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
        self._arena_sign.partner_cid = 0
        self._arena_sign.time = 0
    end
end

function arena_module:sendArenaSignUpResult(result)
    local pb = {
        result = result,
    }
    if result == ARENA_SIGN_UP_STATE.SS_PENDING then
        local team1 = {
            teamid = self._arena_sign.teamid,
        }
        local chrinfo = self._chr_info
        local members = {}
        members[#members+1] =
        {
            cid = self.cid,
            name = chrinfo.name,
            job = chrinfo.job,
            level = chrinfo.level,
            score = self._arena.score,
        }

        if self._arena_sign.partner_cid ~= self.cid then
            local player = _ply_mgr:getPlayerByCid(self._arena_sign.partner_cid )
            if player ~= nil then
                local pcharinfo = player._chr_info
                members[#members+1] = 
                {
                    cid = player.cid,
                    name = pcharinfo.name,
                    job = pcharinfo.job,
                    level = pcharinfo.level,
                    score = player._arena.score,
                }
            end
        end
        team1.members = members
        pb.team1 = team1
    end

    self:sendMsg(_sm.SM_ARENA_DAILY_SIGN_RESULT,pb,"ArenaSignUpResult")
end

function arena_module:requestArenaSign(data, partner_cid)
    local curnow =  _func.getNowSecond()
    if self._arena_sign.state == ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM then
        if curnow - self._arena_sign.time >= 15 then
            self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_NONE
            self._arena_sign.partner_cid = 0
        end
    end

    if self._arena_sign.state == ARENA_SIGN_UP_STATE.SS_NONE and self._arena_sign.partner_cid == 0 then
        self._arena_sign.state = ARENA_SIGN_UP_STATE.SS_WAIT_CONFIRM
        self._arena_sign.partner_cid = partner_cid
        self._arena_sign.time = curnow
        self:sendMsg(_sm.SM_ARENA_SIGN_REQUEST,data,"ArenaSignRequest")
        return curnow
    end
    return 0
end

function arena_module:sendArenaDailyInfo()
	self:sendMsg(_sm.SM_ARENA_DAILY_INFO,{score = self._arena.score},"ArenaDailyInfo")
end

return arena_module