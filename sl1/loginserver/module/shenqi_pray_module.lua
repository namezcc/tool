local _IT = ITEM_TYPE
local _BIND = BIND_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _cr = CHANGE_REASON

local shenqi_pray_module = {}

function shenqi_pray_module:init()
  
	-- _msg_func.bind_player_proto_func(CM.CM_SPIRIT_INHERIT,self.onSpiritInherit,"ProtoInt32Array")
end

function shenqi_pray_module:initDB(data)
end

--在initDB之后调用的
function shenqi_pray_module:afterInit()
end

return shenqi_pray_module