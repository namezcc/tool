local _log = LOG
local _func = LFUNC
local _table = TABLE_INDEX
local _cfg = CFG_DATA

local _player_mgr = nil
local _net_mgr = nil
local _equip_mgr = nil
local _schedule = nil


local arena_mgr_module = {}

function arena_mgr_module:init()
    _player_mgr = MOD.player_mgr_module
	_net_mgr = MOD.net_mgr_module
	_equip_mgr = MOD.equip_mgr_module
	_schedule = MOD.schedule_mgr_module
end

function arena_mgr_module:init_func()
	MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_ARENA_SIGN_UP_RESULT,self,self.onArenaSignUpResult,"ArenaSignUpResultWithDgn")
    MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_DUNGEON_WAIT_CONFIRM,self,self.onDungeonWaitConfirm,"DungeonCenterWaitConfirm")
    MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_DUNGEON_ENTER_DUNGEON,self,self.onDungeonEnterDungeon,"DungeonCenterEnter")
    MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_DUNGEON_CONFIRM_INFO,self,self.onDungeonConfirmInfo,"DungeonCenterWaitConfirm")
    MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_DUNGEON_SIGN_INFO,self,self.onDungeonSignInfo,"DungeonSignInfo")
    MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_ARENA_SIGN_INFO,self,self.onArenaSignInfo,"DungeonSignInfo")
end

function arena_mgr_module:onArenaSignUpResult(d)

    if d.aresult.result ==  ARENA_SIGN_UP_STATE.SS_SUCCESS then
        for i, v in ipairs(d.aresult.team1.members) do
            local player = _player_mgr:getPlayerByCid(v.cid)
            if player then
                player:sendMsg(SM.SM_ARENA_DAILY_SIGN_RESULT,d.aresult,"ArenaSignUpResult")
                player:switchGame(d.gameserverid, d.dungeonid,10040, 0, -40, 110, -40)
            end
        end

        for i, v in ipairs(d.aresult.team2.members) do
            local player = _player_mgr:getPlayerByCid(v.cid)
            if player then
                player:sendMsg(SM.SM_ARENA_DAILY_SIGN_RESULT,d.aresult,"ArenaSignUpResult")
                player:switchGame(d.gameserverid, d.dungeonid,10040, 0, -40, 110, -40)
            end
        end
    end

end

function arena_mgr_module:onDungeonEnterDungeon(d)
    local dgn = _cfg.dungeon(d.dungeonid)
    if dgn ~= nil then
        for i, v in ipairs(d.signinfo) do
            local player = _player_mgr:getPlayerByCid(v.cid)
            if player then
                player:updateSignInfo(d.uniqueid, d.dungeonid, v.teamid, 4)
                player:sendTeamInfo()
                player:switchGame(d.gameserverid, d.uniqueid,d.dungeonid, 0, dgn.x, dgn.y, dgn.z)
            end
        end
    end
end

function arena_mgr_module:onDungeonWaitConfirm(d)
    local uniqueid = d.unique_id
    local dungeonid = d.dungeonid

    for i, v in ipairs(d.signup) do
        local sid = v.serverid
        if sid == GAME_CONFIG.login_id then
            for ii,vv in ipairs(v.signinfo) do
                local player = _player_mgr:getPlayerByCid(vv.cid)
                if player then
                    local succ = player:waitConfirm(uniqueid, dungeonid, vv.teamid)
                    if succ == 1 then
                        player:sendTeamInfo()
                        player:sendMsg(SM.SM_DUNGEON_WAIT_CONFIRM,d,"DungeonCenterWaitConfirm")
                    end
                end
            end
        end
    end
end

function arena_mgr_module:onDungeonConfirmInfo(d)
    local uniqueid = d.unique_id
    local dungeonid = d.dungeonid

    for i, v in ipairs(d.signup) do
        local sid = v.serverid
        if sid == GAME_CONFIG.login_id then
            for ii,vv in ipairs(v.signinfo) do
                local player = _player_mgr:getPlayerByCid(vv.cid)
                if player then
                    if vv.confirmed == 1 then
                        player:updateConfirm(uniqueid, dungeonid, vv.teamid)
                    end
                    player:sendMsg(SM.SM_DUNGEON_CONFIRM_INFO,d,"DungeonCenterWaitConfirm")
                end
            end
        end
    end
end


function arena_mgr_module:onDungeonSignInfo(d)
    local uniqueid = d.uniqueid
    local dungeonid = d.dungeonid
    local teamid = d.teamid
    local infotype = d.infotype

    for i, v in ipairs(d.cids) do
        local player = _player_mgr:getPlayerByCid(v)
        if player then
            player:updateSignInfo(uniqueid, dungeonid, teamid, infotype)
            player:sendTeamInfo()
            player:sendMsg(SM.SM_DUNGEON_SIGN_INFO,d,"DungeonSignInfo")
        end

    end
end


function arena_mgr_module:onArenaSignInfo(d)
    local teamid = d.teamid
    local infotype = d.infotype

    for i, v in ipairs(d.cids) do
        local player = _player_mgr:getPlayerByCid(v)
        if player then
            player:updateArenaSignInfo(teamid, infotype, d.cids)
        end

    end
end

return arena_mgr_module