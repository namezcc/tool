
local _func = LFUNC
local _pbencode = pb.encode
local _lc = LTOC
local _ser_mid = SERVER_MSG
local _proto_name = TABLE_PROTO_NAME
local _rediskey = REDIS_KEY
local _log = LOG
local _pack = PACK
local CORO_OUT_TIME = 10

local _player_mgr = nil

local net_mgr_module = {}

local SERVER_TYPE = {
	ST_GAME = 1,
	ST_LOGIN = 2,
	ST_DB = 3,
	ST_GATE = 4,
	ST_PROXY = 5,
	ST_CHAT = 6,
	ST_CENTER = 7,
	ST_LOG = 8,
}

function net_mgr_module:init()
	self._coroTab = {}
	self._coindex = 1
	self._cocheckTime = 0
	self._chat_port = 0
	self._db_serid = 0

	_player_mgr = MOD.player_mgr_module
end

function net_mgr_module:init_func()
	MSG_FUNC.bind_mod_pack_func(SERVER_MSG.IM_LOGIN_RESPONSE_MSG,self,self.onResponseCoroMsg)
	MSG_FUNC.bind_mod_pack_func(SERVER_MSG.IM_LOGIN_CONNECTED,self,self.onServerConnect)
	MSG_FUNC.bind_mod_pack_func(SERVER_MSG.IM_LOGIN_SERVER_DISCONNECT,self,self.onServerDisConnect)

end

function net_mgr_module:update(second)
	if second < self._cocheckTime then
		return
	end
	self._cocheckTime = second + 10 --10s一次
	local rem = {}
	for k, v in pairs(self._coroTab) do
		if second > v.time then
			rem[#rem+1] = k
			v.co(nil)
		end
	end

	for i, k in ipairs(rem) do
		self._coroTab[k] = nil
	end
end

function net_mgr_module:sendPlayerMsg(gateSerid,gateIndex,mid,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_PLAYER_MSG,gateSerid,gateIndex,mid,buff)
end

function net_mgr_module:sendToGameMsg(serid,proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_GAME,serid,proc,buff)
end

function net_mgr_module:sendToCenterMsg(serid,proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_CENTER,GAME_CONFIG.login_id,proc,buff)
end

function net_mgr_module:sendToGamePlayerMsg(player,proc,pb,pbname)
	local pack = _pack.poppack()

	pack:writestring(player.uid)
	pack:writeint32(player.sid)
	pack:writeint32(proc)
	pack:writepb(pb,"Proto."..pbname)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_GAME,player.game_serid,_ser_mid.IM_GAME_TO_PLAYER_MSG,pack:buff())
end

function net_mgr_module:get_coindex()
	local idx = self._coindex
	if idx >= 200000000 then
		idx = 0
	end
	self._coindex = idx + 1
	return idx
end

-- 以同步阻塞的方式请求game的消息,若超时返回 nil
function net_mgr_module:requestGameMsg(serid,proc,pb,pbname,coro,repname)
	local pack = _pack.poppack()
	local coidex = self:get_coindex()

	pack:writeint32(coidex)
	pack:writepb(pb,"Proto."..pbname)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_GAME,serid,proc,pack:buff())

	self._coroTab[coidex] = {
		co = coro,
		pbname = "Proto."..repname,
		time = TIME_DATA.TIME_STAMEP + CORO_OUT_TIME,
	}
	return coroutine.yield()
end

-- 以同步阻塞的方式请求db的消息,若超时返回 nil
function net_mgr_module:requestDbMsg(serid,proc,pb,pbname,coro,repname)
	local pack = _pack.poppack()
	local coidex = self:get_coindex()

	pack:writeint32(coidex)
	pack:writepb(pb,"Proto."..pbname)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_DB,serid,proc,pack:buff())

	self._coroTab[coidex] = {
		co = coro,
		pbname = "Proto."..repname,
		time = TIME_DATA.TIME_STAMEP + CORO_OUT_TIME,
	}
	return coroutine.yield()
end

-- 以同步阻塞的方式请求game的 player 的消息,若超时返回 nil
function net_mgr_module:requestGamePlayerMsg(player,proc,pb,pbname,coro,repname)
	local pack = _pack.poppack()
	local coidex = self:get_coindex()

	pack:writestring(player.uid)
	pack:writeint32(player.sid)
	pack:writeint32(proc)
	pack:writeint32(coidex)
	pack:writepb(pb,"Proto."..pbname)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_GAME,player.game_serid,SERVER_MSG.IM_GAME_TO_PLAYER_MSG,pack:buff())

	self._coroTab[coidex] = {
		co = coro,
		pbname = "Proto."..repname,
		time = TIME_DATA.TIME_STAMEP + CORO_OUT_TIME,
	}
	return coroutine.yield()
end

function net_mgr_module:onResponseCoroMsg(pack)
	local coid = pack:readint32()

	local coinfo = self._coroTab[coid]
	if coinfo == nil then
		return
	end

	self._coroTab[coid] = nil
	local data = pack:decode(coinfo.pbname)
	if data then
		coinfo.co(data)
	end
end

function net_mgr_module:responseGamePlayerMsg(player,coidx,pb,pbname)
	local pack = _pack.poppack()

	pack:writestring(player.uid)
	pack:writeint32(player.sid)
	pack:writeint32(_ser_mid.IM_GAME_PLAYER_RESPONSE_MSG)

	pack:writeint32(coidx)
	pack:writepb(pb,"Proto."..pbname)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_GAME,player.game_serid,_ser_mid.IM_GAME_TO_PLAYER_MSG,pack:buff())
end

function net_mgr_module:sendToGamePack(serid,proc,pack)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_GAME,serid,proc,pack:buff())
end

function net_mgr_module:sendToDBMsg(serid,proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_DB,serid,proc,buff)
end

function net_mgr_module:sendToLoginMsg(proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_LOGIN,0,proc,buff)
end

function net_mgr_module:sendToChatPack(proc,pack)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG_PACK,SERVER_TYPE.ST_CHAT,0,proc,pack:buff())
end

function net_mgr_module:sendToChatMsg(proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_CHAT,0,proc,buff)
end

function net_mgr_module:sendToLogMsg(proc,pb,pbname)
	local buff = _pbencode("Proto."..pbname,pb)
	_func.CallCFunc(_lc.LTOC_SEND_SERVER_MSG,SERVER_TYPE.ST_LOG,0,proc,buff)
end

local function get_sql_data(table,pb)
	local pro = _proto_name[table]
	if pro == nil then
		_log.error("update player err proname nil table:%d",table)
		_log.info(debug.traceback())
		return
	end

	local redisk = _rediskey[table]
	if redisk == nil then
		_log.error("redis key nil table:%d",table)
		return
	end

	local datavec = {}
	local ks = {}
	local buf = _pbencode(pro,pb)
	if buf == nil then
		return
	end

	for ik, k in ipairs(redisk) do
		ks[ik] = tostring(pb[k])
	end
	datavec[1] = {
		keys = ks,
		data = buf,
	}

	return datavec
end

local function get_sql_data_vec(table,pbvec)
	if #pbvec == 0 then
		return
	end
	
	local pro = _proto_name[table]
	if pro == nil then
		_log.error("update player err proname nil table:%d",table)
		_log.info(debug.traceback())
		return
	end

	local redisk = _rediskey[table]
	if redisk == nil then
		_log.error("redis key nil table:%d",table)
		return
	end

	local datavec = {}

	for i, v in ipairs(pbvec) do
		local ks = {}
		local buf = _pbencode(pro,v)
		if buf == nil then
			return
		end

		for ik, k in ipairs(redisk) do
			ks[ik] = tostring(v[k])
		end
		datavec[i] = {
			keys = ks,
			data = buf,
		}
	end
	return datavec
end

function net_mgr_module:dbUpdatePlayerData(dbserid,cid,table,pb)
	if pb["cid"] == nil then
		_log.error("cid nil table:%d cid:%d",table,cid)
	end
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	if table == TABLE_INDEX.TAB_mem_chr_anqi then
		if pb.id < 2700 or pb.id > 2800 then
			local x = 1 + nil
		end
	end

	local msg = {
		cid = cid,
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(dbserid,_ser_mid.IM_DB_UPDATE_PLAYER,msg,"DB_sql_data_list")
end

function net_mgr_module:dbUpdatePlayerDataVector(dbserid,cid,table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		cid = cid,
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(dbserid,_ser_mid.IM_DB_UPDATE_PLAYER,msg,"DB_sql_data_list")
end

function net_mgr_module:dbDeletePlayerData(dbserid,cid,table,pb)
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	local msg = {
		cid = cid,
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(dbserid,_ser_mid.IM_DB_DELETE_PLAYER,msg,"DB_sql_data_list")
end

function net_mgr_module:dbDeletePlayerDataVector(dbserid,cid,table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		cid = cid,
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(dbserid,_ser_mid.IM_DB_DELETE_PLAYER,msg,"DB_sql_data_list")
end

function net_mgr_module:dbSavePlayerDataRedisToDB(dbserid,cid,sid)
	local msg = {
		cid = cid,
		sid = sid,
	}
	self:sendToDBMsg(dbserid,_ser_mid.IM_DB_SAVE_PLAYER,msg,"DB_sql_data_list")
end

function net_mgr_module:dbInsertData(table,pb)
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_INSERT_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbInsertDataVector(table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_INSERT_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbUpdateData(table,pb,cid)
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	local msg = {
		cid = cid,
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_UPDATE_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbUpdateDataVector(table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_UPDATE_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbDeleteData(table,pb)
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_DELETE_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbDeleteDataVector(table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToDBMsg(self._db_serid,_ser_mid.IM_DB_DELETE_DATA,msg,"DB_sql_data_list")
end

function net_mgr_module:dbLog(table,pb)
	local dates = get_sql_data(table,pb)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToLogMsg(_ser_mid.IM_LOG_LOG,msg,"DB_sql_data_list")
end

function net_mgr_module:dbLogVector(table,pbvec)
	local dates = get_sql_data_vec(table,pbvec)
	if dates == nil then
		return
	end

	local msg = {
		table = table,
		datas = dates,
	}
	self:sendToLogMsg(_ser_mid.IM_LOG_LOG,msg,"DB_sql_data_list")
end


function net_mgr_module:onServerConnect(pack)
	local type = pack:readint32()
	local sid = pack:readint32()

	print("on server connect type:%d sid:%d",type,sid)

	if type == SERVER_TYPE.ST_CHAT then
		self._chat_port = pack:readint32()
		_player_mgr:chatServerReload()
	elseif type == SERVER_TYPE.ST_DB then
		self._db_serid = sid
	end
end

function net_mgr_module:onServerDisConnect(pack)
	local type = pack:readint32()
	local sid = pack:readint32()

	print("on server disconnect type:%d sid:%d",type,sid)

	if type == SERVER_TYPE.ST_CHAT then
		self._chat_port = 0
	end
end

function net_mgr_module:getChatServerPort()
	return self._chat_port
end

return net_mgr_module