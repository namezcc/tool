package.path = package.path..";./lua/loginserver/?.lua;"

collectgarbage("setpause", 200)  --200
collectgarbage("setstepmul", 5000)

pb.loadfile("./lua/loginserver/proto/allproto.pb")

require("class")

persent = require("util.persent")
require("util.table_index")
require("util.netpack")
require("util.data_define")
require("util.string_util")
require("log")
require("msg_define")
require("function")
require("msg_dispatch")
require("util.time_util")
require("util.hotload_util")

CFG_DATA = require("util.cfgdata")

--全局数据
ALL_PLAYER = {}				--玩家数据
DROP_ITEM_MAP = {}			--玩家掉落数据
SERVER_MAIL = {}			--全服邮件
PLAYER_SIMPLE_INFO = {}		--玩家简略信息
ALL_TEAM = {}				--全服队伍数据

GAME_CONFIG = {}
MOD = {}
mod_name = require("lua_module")
local modmgr = {}
local modplayer = {}
local mgrupdatemod = {}


function initModule()
	for i,v in ipairs(mod_name.mgr_module) do
		local m = require("module."..v)
		m.name = v
		MOD[v] = m
		modmgr[#modmgr+1] = m
	
		if m.update then
			mgrupdatemod[#mgrupdatemod+1] = m
		end
	end
	
	for i,v in ipairs(mod_name.player_module) do
		local m = require("module."..v)
		m.name = v
		MOD[v] = m
		modplayer[#modplayer+1] = m
		bind_player_func(m,v)
	end
	
	for i, v in ipairs(modmgr) do
		if v.init == nil then
			LOG.error("mod %s need init func",v.name)
		else
			v:init()
		end
	end
	
	for i, v in ipairs(modmgr) do
		if v.init_func == nil then
			LOG.error("mgr mod need init_func",v.name)
		else
			v:init_func()
		end
	end
	
	for i, v in ipairs(modplayer) do
		if v.init == nil then
			LOG.error("mod %s need init func",v.name)
		else
			v:init()
		end
	end
end


-- update
local _time = TIME_DATA
function onFrameUpdate(tick,now)
	_time.TICK_TIME_STAMEP = tick
	local old = _time.TIME_STAMEP
	_time.TIME_STAMEP = now

	if old ~= now then
		for i, m in ipairs(mgrupdatemod) do
			m:update(now)
		end
	end
end
BindLuaFunc(CTOL.CTOL_FRAME_UPDATE,onFrameUpdate)

function main(loginid)
	_time.TIME_STAMEP = os.time()
	_time.TICK_TIME_STAMEP = os.time()*1000

	GAME_CONFIG.login_id = loginid

	initModule()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

print("load login main lua ...")