local _msg_func = MSG_FUNC
local _player = ALL_PLAYER
local _ply_simple_info = PLAYER_SIMPLE_INFO
local _func = LFUNC
local _time = TIME_UTIL
local _pack = PACK
local _cfg = CFG_DATA
local _string_util = STRING_UTIL
local _record = RECORD_TYPE
local _table = TABLE_INDEX

local player_mgr_module = {}
local _net_mgr = nil
local _equip_mgr = nil
local _schedule = nil

function player_mgr_module:init()
	self._player = {}
	_net_mgr = MOD.net_mgr_module
	_equip_mgr = MOD.equip_mgr_module
	_schedule = MOD.schedule_mgr_module
end

function player_mgr_module:init_func()

	_schedule:addTaskTimePoint({hour=0,min=0,sec = 1},function ()
		self:newDayCome()
	end,-1,SCHEDULE_INDEX.NEWDAY_COME)

	_schedule:addTaskTimePoint({hour=5,min=0,sec = 1},function ()
		self:newDay5hCome()
	end,-1,SCHEDULE_INDEX.NEWDAY_5h_COME)

	_schedule:addTaskTimePoint({sec = 1},function ()
		self:newMinuteCome()
	end,-1,SCHEDULE_INDEX.NEW_MINUTE_COME)

	_schedule:addTaskTimePoint({min=0,sec = 1},function ()
		self:newHourCome()
	end,-1,SCHEDULE_INDEX.NEW_HOUR_COME)
	

	_msg_func.bind_mod_func(CTOL.CTOL_REMOVE_PLAYER,self,self.onRemovePlayer)
	_msg_func.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_PLAYER_LOADED,self,self.onLoadPlayerData,"DBPlayerData")
	_msg_func.bind_mod_proto_func(CM.CM_TEST_HOT_LOAD,self,self.onHotLoad,"ProtoInt32")
	_msg_func.bind_mod_pack_func(SERVER_MSG.IM_LOGIN_HOT_LOAD,self,self.onHotLoad_master)
	_msg_func.bind_mod_proto_func(SERVER_MSG.IM_GAME_KICK_PLAYER,self,self.onKickPlayer,"GameKickPlayer")
	_msg_func.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_INTERNAL_REMOVE_USER,self,self.onRemoveUser,"GameKickPlayer")
	_msg_func.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_LOAD_SERVER_MAIL,self,self.onLoadServerMail,"MailList")
end

function player_mgr_module:onLoadPlayerData(pdata)
	local player = {}
	player.uid = pdata.chr_info.uid
	player.cid = pdata.chr_info.cid
	player.sid = pdata.chr_info.sid
	player.gate_serid = pdata.gate_server_id
	player.gate_index = pdata.gate_index

	--临时
	player.db_serid = 1

	-- 临时用1000 需要跟loginserver.cpp中一样的逻辑
	player.game_serid = 1000
	if pdata.chr_info.map == 1000 then
		player.game_serid = 1000
	end

	print("player load cid:%d sid:%d",player.cid,player.sid)
	
	setPlayerImpFunc(player)

	--加载装备
	_equip_mgr:loadPlayerEquip(pdata.equips)
	--魂骨
	_equip_mgr:loadPlayerBone(pdata.bone)
	--灵宠
	_equip_mgr:loadPlayerPet(pdata.pet)
	--魔核
	_equip_mgr:loadPlayerCore(pdata.core)
	--通用实例
	_equip_mgr:loadPlayerMemCommon(pdata.memCommon)
	
	player:initDB(pdata)

	self:sendChatServer(player)
	player:dealOfflineEvent(pdata.offline_event)
	player:afterInit()

	local index = _func.int32To64(player.gate_serid,player.gate_index)
	-- local scid = _func.int32To64(player.sid,player.cid)
	_player[index] = player
	self._player[player.cid] = player

	local gamepb = {
		gate_index = pdata.gate_index,
		gate_id = pdata.gate_server_id,
		db_id = player.db_serid,
		chr_info = pdata.chr_info,
		switch_server = 0,
		face_time = player._face.time,
	}
	player:loadAttr(gamepb)
	player:loadHunhuanSkill(gamepb)
	player:loadGrassSkill(gamepb)
	player:loadTianfuSkill(gamepb)
	player:loadAnqiSkill(gamepb)
	_net_mgr:sendToGameMsg(player.game_serid, SERVER_MSG.IM_GAME_PLAYER_LOADED, gamepb, "ImGamePlayerLoaded")

	player:afterEnterGame()
end

function player_mgr_module:update(second)
	for _, ply in pairs(_player) do
		ply:update(second)
	end
end

function player_mgr_module:newMinuteCome()
	for _, ply in pairs(_player) do
		ply:newMinuteCome()
	end
end

function player_mgr_module:newHourCome()
	for _, ply in pairs(_player) do
		ply:newHourCome()
	end
end

function player_mgr_module:newDayCome()
	print("newday come")
	for _, ply in pairs(_player) do
		ply:newDayCome()
	end

	if _time.get_week() == 1 then
		self:newWeekCome()
	end

	if _time.get_day_of_month() == 1 then
		self:newMonthCome()
	end

	MOD.family_mgr_module:newDayCome()
end

function player_mgr_module:newDay5hCome()
	for _, ply in pairs(_player) do
		ply:newDay5hCome()
	end

	if _time.get_week() == 1 then
		self:newWeek5hCome()
	end
end

function player_mgr_module:newWeekCome()
	print("newWeek come")
	for _, ply in pairs(_player) do
		ply:newWeekCome()
	end
end

function player_mgr_module:newWeek5hCome()
	MOD.family_mgr_module:newWeek5hCome()

	for _, ply in pairs(_player) do
		ply:newWeek5hCome()
	end
end

function player_mgr_module:newMonthCome()
	print("newMonth come")
	for _, ply in pairs(_player) do
		ply:newMonthCome()
	end
end

function player_mgr_module:getPlayerByGateSidx(sid,index)
	return _player[_func.int32To64(sid,index)]
end

function player_mgr_module:getPlayerByCid(cid)
	return self._player[cid]
end

function player_mgr_module:getAllPlayer()
	return self._player
end

function player_mgr_module:onRemovePlayer(sid,sidx)
	local index = _func.int32To64(sid,sidx)
	local player = _player[index]

	if player then
		_player[index] = nil
		-- local scid = _func.int32To64(player.sid,player.cid)
		self._player[player.cid] = nil

		player:logout()
	end
end

function player_mgr_module:onKickPlayer(data)
	self:onRemovePlayer(data.gate_server_id,data.gate_index)
	
	print("kick player")
	_net_mgr:sendToGameMsg(data.game_server_id,SERVER_MSG.IM_GAME_KICK_PLAYER,data,"GameKickPlayer")

end

function player_mgr_module:onRemoveUser(data)
	
	print("remove user")
	_net_mgr:sendToLoginMsg(SERVER_MSG.IM_LOGIN_INTERNAL_REMOVE_USER,data,"GameKickPlayer")

end

function player_mgr_module:onHotLoad()

	HotLoadModule()
end

function player_mgr_module:onHotLoad_master(pack)
	local str = pack:readstring()
	local func = loadstring(str)
	if func then
		func()
	end
end

function player_mgr_module:onLoadServerMail(data)
	SERVER_MAIL = data.data
end

function player_mgr_module:genSimpleInfo(player,online)
	local chrinfo = player._chr_info
	return {
		cid = player.cid,
		level = chrinfo.level,
		name = chrinfo.name,
		online = online,
		logout_time = _func.getNowSecond(),
		job = chrinfo.job,
		family_active = player:getRecord(_record.RT_WEEKLY_5_FAMILY_ACTIVE_VALUE),
		hunshi_level = player:getHunshiLevel(),
		sex = chrinfo.sex,
	}
end

function player_mgr_module:setPlayerSimpleInfo(player)
	_ply_simple_info[player.cid] = self:genSimpleInfo(player,0)
end

function player_mgr_module:loadPlayerSimpleInfo(idvec,dbid,coro)
	local pb = {}

	if #idvec == 0 then
		return pb
	end

	local loadid = {}
	local plymap = self._player
	for _, cid in ipairs(idvec) do
		local player = plymap[cid]
		if player then
			pb[#pb+1] = self:genSimpleInfo(player,1)
		else
			local info = _ply_simple_info[cid]
			if info then
				pb[#pb+1] = info
			else
				loadid[#loadid+1] = cid
			end
		end
	end

	if #loadid > 0 and coro ~= nil then
		local msg = _net_mgr:requestDbMsg(dbid,SERVER_MSG.IM_DB_LOAD_SIMPLE_INFO,{data=loadid},"PInt64Array",coro,"PlayerSimpleInfoList")
		if msg then
			for _, v in ipairs(msg.data) do
				_ply_simple_info[v.cid] = v
				pb[#pb+1] = v
			end
		end
	end
	return pb
end

function player_mgr_module:getPlayerSimpleInfo(cid)
	local player = self._player[cid]
	if player then
		return self:genSimpleInfo(player,1)
	else
		return _ply_simple_info[cid]
	end
end

function player_mgr_module:getRelation(cid,rcid,dbid,coro)
	local player = self:getPlayerByCid(cid)
	if player == nil then
		local pb = {data={cid,rcid}}
		local msg = _net_mgr:requestDbMsg(dbid,SERVER_MSG.IM_DB_GET_RELATION,pb,"PInt64Array",coro,"DB_chr_relation")
		if msg == nil then
			return 0
		end
		return msg.type
	else
		return player:getRelation(rcid)
	end
end

function player_mgr_module:setRelation(cid,type,rcid,dbid,coro)
	local player = self:getPlayerByCid(cid)
	if player == nil then
		local pb = {
			cid = cid,
			rcid = rcid,
			type = type,
			time = _func.getNowSecond(),
		}
		_net_mgr:dbUpdatePlayerData(dbid,cid,TABLE_INDEX.TAB_mem_chr_relation,pb)
	else
		player:setRelation(rcid,type,coro)
	end
end

function player_mgr_module:deleteRelation(cid,rcid,dbid)
	local player = self:getPlayerByCid(cid)
	if player then
		player:deleteRelation(rcid)
	else
		local pb = {
			cid = cid,
			rcid = rcid,
		}
		_net_mgr:dbDeletePlayerData(dbid,cid,TABLE_INDEX.TAB_mem_chr_relation,pb)
	end
end

function player_mgr_module:sendChatServer(player)
	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local key = math.random(1,1000000)
		local pack = _pack.poppack()
		pack:writeint64(player.cid)
		pack:writeint32(key)
		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_PLAYER_LOGIN,pack)

		local data = {chatport,key}
		player:sendMsg(SM.SM_CHAT_SERVER_INFO,{i32=data},"ProtoInt32Array")
	end
end

function player_mgr_module:chatServerReload()
	for _, v in pairs(self._player) do
		self:sendChatServer(v)
		v:enterFamilyChatRoom()
		v:enterTeamChatRoom()
	end
end

function player_mgr_module:getPlayerByMap(map)
	local players = {}
	for _, ply in pairs(_player) do
		if map == ply._chr_info.map then
			players[#players+1] = ply
		end
	end
	return players
end

function player_mgr_module:sendMailToPlayerVector(cidvec,mailid,reason,contp)
	local cfg = _cfg.mail(mailid)
	local content = cfg.content
	if contp then
		content = _string_util.format_content(content,contp)
	end

	for _, cid in ipairs(cidvec) do
		local player = self:getPlayerByCid(cid)
		if player then
			player:addMail(cfg.sender,cfg.title,content,cfg.reward,reason)
		else
			_equip_mgr:addMail(_net_mgr._db_serid,cid,cfg.sender,cfg.title,content,cfg.reward,reason)
		end
	end
end

function player_mgr_module:sendMailToPlayer(cid,mailid,slots,reason,contp)
	local cfg = _cfg.mail(mailid)
	local reward = _string_util.combin_vec2(slots)
	local content = cfg.content
	if contp then
		content = _string_util.format_content(content,contp)
	end
	local player = self:getPlayerByCid(cid)
	if player then
		player:addMail(cfg.sender,cfg.title,content,reward,reason)
	else
		_equip_mgr:addMail(_net_mgr._db_serid,cid,cfg.sender,cfg.title,content,reward,reason)
	end
end

function player_mgr_module:addOfflineEvent(cid,type,p1,p64,p2)
	local pb = {
		cid = cid,
		type = type,
		param1 = p1,
		pi64 = p64,
		param2 = p2,
	}
	_net_mgr:dbInsertData(_table.TAB_mem_chr_offline_event,pb)
end

return player_mgr_module