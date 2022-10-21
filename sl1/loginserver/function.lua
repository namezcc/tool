local cstate = CLuaState
function CallCFunc( findex,... )
    return cstate:luaCallC(findex,...)
end

function BindLuaFunc(findex, _func )
    cstate:bindLuaFunc(findex, _func)
end

function BindModLuaFunc(findex, mod, _func )
    cstate:bindLuaFunc(findex, function(...)
        return _func(mod,...)
    end)
end

local IMPL_FUNC = {}
local INIT_DB_FUNC = {}
local AFTER_INIT = {}
local AFTER_ENTER_GAME = {}
local LOGOUT_FUNC = {}
local UPDATE_FUNC = {}

IMPL_FUNC["initDB"] = function(ply,...)
	for k, f in pairs(INIT_DB_FUNC) do
		f(ply,...)
	end
end

IMPL_FUNC["afterInit"] = function(ply,...)
	for k, f in pairs(AFTER_INIT) do
		f(ply,...)
	end
end

IMPL_FUNC["afterEnterGame"] = function(ply,...)
	for k, f in pairs(AFTER_ENTER_GAME) do
		f(ply,...)
	end
end

IMPL_FUNC["logout"] = function(ply)
	for k, f in pairs(LOGOUT_FUNC) do
		f(ply)
	end
end

IMPL_FUNC["update"] = function(ply,...)
	for k, f in pairs(UPDATE_FUNC) do
		f(ply,...)
	end
end

local function imp_func( ply,fname )
	return IMPL_FUNC[fname]
end

-- 绑定模块函数到玩家的成员函数,不能有相同的函数名会覆盖,init除外
function bind_player_func( mod,modname,hotload )
	for k,v in pairs(mod) do
		if type(v) == "function" then
			if k == "initDB" then
				INIT_DB_FUNC[modname] = v
			elseif k == "logout" then
				LOGOUT_FUNC[modname] = v
			elseif k == "afterInit" then
				AFTER_INIT[modname] = v
			elseif k == "afterEnterGame" then
				AFTER_ENTER_GAME[modname] = v
			elseif k == "update" then
				UPDATE_FUNC[modname] = v
			elseif k ~= "init" then
				if hotload == nil and IMPL_FUNC[k] ~= nil then
					LOG_ERROR("have same name %s !!! need change",k)
				end
				IMPL_FUNC[k] = v
			end
        end
    end
end

function setPlayerImpFunc( ply )
	-- setmetatable(ply, {__index = imp_func})
	setmetatable(ply, {__index = IMPL_FUNC})
end

table.copy = function( tab )
    local ntab = {}
    for k,v in pairs(tab) do
        ntab[k] = v
    end
    return ntab
end

table.copyValue = function( dst,src )
    for k,v in pairs(src) do
        dst[k] = v
    end
end

table.insertArray = function( arr,arr2 )
	for i,v in ipairs(arr2) do
		arr[#arr+1] = v
	end
end

table.swapKV = function(tab)
	local ntab = {}
	for k,v in pairs(tab) do
		ntab[v] = k
	end
	return ntab
end

table.empty = function(tab)
    if not tab then
        return true
    end
	return next(tab) == nil
end

table.getn = function(tab)
    if tab == nil then
        return 0
    end
    local num = 0
    for k,v in pairs(tab) do
        num = num + 1
    end
    return num
end

table.getOrNewTable = function( tab,key,val )
	local t = tab[key]
	if t == nil then
		t = val or {}
		tab[key] = t
	end
	return t
end

function table.cloneSimple(tab)
	local res = {}
	for k, v in pairs(tab) do
		if type(v) == "table" then
			assert(false,"canot clone value type table use this function!!!")
		end
		res[k] = v
	end
	return res
end

function table.clone(tab)
    if tab == nil or type(tab) ~= "table" then
        return nil
    end
    local res = {}
    for k,v in pairs(tab) do
        if type(k) == "table" then
            if type(v) == "table" then
                res[table.clone(k)] = table.clone(v)
            else
                res[table.clone(k)] = v
            end
        else
            if type(v) == "table" then
                res[k] = table.clone(v)
            else
                res[k] = v
            end
        end
    end
    return res
end

local function int32To64(hei,low)
	return (hei << 32)|low
end

local _time = TIME_DATA
local function getNowTick()
	return _time.TICK_TIME_STAMEP
end

local function getNowSecond()
	return _time.TIME_STAMEP
end

local function set_bit_on(v,b)
	return v|(1<<(b-1))
end

local function set_bit_off(v,b)
	return v&(~(1<<(b-1)))
end

local function is_bit_on(v,b)
	return (v&(1<<(b-1)))~=0
end

local function combindAttr(attr,cfg)
	if type(cfg) ~= "table" then
		return
	end
	for i, v in ipairs(cfg) do
		local old = table.getOrNewTable(attr,v[1])
		local vt = v[2]
		old[vt] = (old[vt] or 0) + v[3]
	end
end

local function combindJobAttr(attr,cfg,job)
	if type(cfg) ~= "table" then
		return
	end
	for i, v in ipairs(cfg) do
		if v[4]==nil or v[4]==job then
			local old = table.getOrNewTable(attr,v[1])
			local vt = v[2]
			old[vt] = (old[vt] or 0) + v[3]
		end
	end
end

--{w1,w2,..wmax}
local function rand_weight_index(vec)
	local rv = math.random(vec[#vec])
	for i, w in ipairs(vec) do
		if w >= rv then
			return i
		end
	end
	return 1
end

local function rand_weight(vec,wk)
	local rv = math.random(vec[#vec][wk])
	for i, obj in ipairs(vec) do
		if obj[wk] >= rv then
			return obj
		end
	end
	return vec[1]
end

-- vec = {{wk=w},...,{wk=maxw}}
local function rand_weight_index_by_key(vec,wk)
	local rv = math.random(vec[#vec][wk])
	for i, obj in ipairs(vec) do
		if obj[wk] >= rv then
			return i
		end
	end
	return 1
end

-- vec = {v1,v2,...}
local function rand_vector(vec)
	local rv = math.random(#vec)
	return vec[rv],rv
end

local function make_cfg_item_one(id,tp,num,bind)
	return {id,tp,num,bind}
end

local function make_cfg_item(id,tp,num,bind)
	return {{id,tp,num,bind}}
end

local function get_min_item_key(tab,key,getval)
	local item = nil
	for i, v in ipairs(tab) do
		if i == 1 then
			item = v
		else
			if v[key] < item[key] then
				item = v
			end
		end
	end
	if getval then
		return item[key]
	end
	return item
end

local function get_max_item_key(tab,key,getval)
	local item = nil
	for i, v in ipairs(tab) do
		if i == 1 then
			item = v
		else
			if v[key] > item[key] then
				item = v
			end
		end
	end
	if getval then
		return item[key]
	end
	return item
end

local function checkPlayerData(d)
	if d and d.cid > 0 then
		return true
	else
		return false
	end
end

LFUNC = {
	CallCFunc = CallCFunc,
	int32To64 = int32To64,
	getNowTick = getNowTick,
	getNowSecond = getNowSecond,
	set_bit_on = set_bit_on,
	set_bit_off = set_bit_off,
	is_bit_on = is_bit_on,
	combindAttr = combindAttr,
	combindJobAttr = combindJobAttr,
	rand_weight_index = rand_weight_index,
	rand_weight_index_by_key = rand_weight_index_by_key,
	rand_vector = rand_vector,
	rand_weight = rand_weight,
	make_cfg_item = make_cfg_item,
	make_cfg_item_one = make_cfg_item_one,
	get_min_item_key = get_min_item_key,
	get_max_item_key = get_max_item_key,
	checkPlayerData = checkPlayerData,
}