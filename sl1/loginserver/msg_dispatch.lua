local _log = LOG
local _pbdecode = pb.decode
local _pack = PACK

local msg_func_tab = {}
local func_tab = {}

local function bind_mod_proto_func(mid,mod,f,proto)
	local _pro = "Proto."..proto
	msg_func_tab[mid] = function (netmsg,...)
		local mdata = _pbdecode(_pro,netmsg)
		if mdata then
			f(mod,mdata,...)
		end
	end
end

local function bind_mod_pack_func(mid,mod,f)
	msg_func_tab[mid] = function (buff,pack)
		local netpack = _pack.netpack(pack)
		f(mod,netpack)
	end
end
-- 绑定来自客户端的玩家的消息
local function bind_player_proto_func(mid,f,proto,limittime)
	local _pro = "Proto."..proto
	local ply_mgr = MOD.player_mgr_module
	msg_func_tab[mid] = function (netmsg,gateserid,gateIndex)
		local ply = ply_mgr:getPlayerByGateSidx(gateserid,gateIndex)
		if ply == nil then
			_log.error("no player in lua gateser:%d gateidx:%d",gateserid,gateIndex)
			return
		end
		if limittime then
			if ply:checkInMsgCD(mid,limittime) then
				_log.debug("in msg cd %d",mid)
				return
			end
		end
		local mdata = _pbdecode(_pro,netmsg)
		if mdata then
			-- local cid = ply.cid
			f(ply,mdata,mid)
		end
	end
end

-- 绑定需要同步请求的消息
local function bind_async_player_proto(mid,f,proto,limittime)
	local ply_mgr = MOD.player_mgr_module
	local _pro = "Proto."..proto
	msg_func_tab[mid] = function (netmsg,gateserid,gateIndex)
		local player = ply_mgr:getPlayerByGateSidx(gateserid,gateIndex)
		if player == nil then
			_log.error("on player server proto player nil gatesid:%d gateidx:%d",gateserid,gateIndex)
			return
		end
		if limittime then
			if player:checkInMsgCD(mid,limittime) then
				_log.debug("in msg cd %d",mid)
				return
			end
		end
		local mdata = _pbdecode(_pro,netmsg)
		if mdata then
			local coro = coroutine.wrap(f)
			coro(player,mdata,coro)
			-- f(player,mdata)
		end
	end
end

local function doCoroFunc(f,...)
	local coro = coroutine.wrap(f)
	coro(coro,...)
end

-- 绑定来自服务器的玩家的消息
local function bind_player_server_proto(mid,f,proto)
	local ply_mgr = MOD.player_mgr_module
	local _pro = "Proto."..proto
	msg_func_tab[mid] = function (buff,pack)
		local netpack = _pack.netpack(pack)
		local cid = netpack:readint64()
		local player = ply_mgr:getPlayerByCid(cid)
		if player == nil then
			_log.error("on player server proto player nil cid:%d",cid)
			return
		end
		local mdata = netpack:decode(_pro)
		if mdata then
			f(player,mdata)
		end
	end
end

-- 绑定来自game的同步请求消息
local function bind_player_server_proto_request(mid,f,proto)
	local ply_mgr = MOD.player_mgr_module
	local _pro = "Proto."..proto
	msg_func_tab[mid] = function (buff,pack)
		local netpack = _pack.netpack(pack)
		local cid = netpack:readint64()
		local player = ply_mgr:getPlayerByCid(cid)
		if player == nil then
			_log.error("on player server proto req player nil cid:%d",cid)
			return
		end
		local coidx = netpack:readint32()
		local mdata = netpack:decode(_pro)
		if mdata then
			f(player,mdata,coidx)
		end
	end
end

local function bind_mod_func(mid,mod,f)
	func_tab[mid] = function (...)
		f(mod,...)
	end
end

local function onNetMsg(mid,netmsg,...)
	local f = msg_func_tab[mid]
	if f then
		f(netmsg,...)
	else
		_log.error("netmsg not bind func %d",mid)
	end
end

local function onMsg(mid,...)
	local f = func_tab[mid]
	if f then
		f(...)
	else
		_log.error("cmsg not bind func:%d",mid)
	end
end

BindLuaFunc(CTOL.CTOL_NET_MSG,onNetMsg)
BindLuaFunc(CTOL.CTOL_MSG,onMsg)

MSG_FUNC = {
	bind_mod_proto_func = bind_mod_proto_func,
	bind_mod_func = bind_mod_func,
	bind_player_proto_func = bind_player_proto_func,
	bind_player_server_proto = bind_player_server_proto,
	bind_player_server_proto_request = bind_player_server_proto_request,
	bind_mod_pack_func = bind_mod_pack_func,
	bind_async_player_proto = bind_async_player_proto,
	doCoroFunc = doCoroFunc,
}