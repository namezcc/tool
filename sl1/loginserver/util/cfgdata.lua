_CFG = {}

_ITEM_EXP = {}

local CFG = _CFG
-- 获取数据生成函数
local getfunc = {}
-- 获取数据函数
local cfgfunc = {}

local conf = require("util.cfg_conf")
-- 需要导入的表
local cfgfile = conf.cfgfile
-- 多级的table -> 对应单条数据
local nmapconf = conf.nmapconf
-- 多级table -> 对应vec 一组数据
-- [tabname] = {key1,...}
local nmapvecconf = conf.nmapvecconf



-- 表初始化函数,用于加载,构造成新的表结构
local initfunc = {
	
}

local function genGetFunckey(data)
	return function( k )
		return data[k]
	end
end

-- 加载完成之后的一些初始化函数,构造成新的表结构
local afterloadinit = {
	["equip_fuling_slot"] = function (data)
		for _, v in pairs(data) do
			local w = 0
			for i, wt in ipairs(v.weight) do
				w = w + wt[2]
				wt[2] = w
			end
		end
	end,
	["drop_group"] = function (data)
		for _, v in pairs(data) do
			local w = 0
			for i, c in ipairs(v) do
				w = w + c.probability
				c.probability = w
			end
		end
	end,

	["baoxiang"] = function (data)
		local newdata = {}
		local tabname = "baoxiang_group_num"
		for i, v in ipairs(data) do
			if newdata[v.groupid] ~= nil then
				newdata[v.groupid] = newdata[v.groupid] + 1
			else
				newdata[v.groupid] = 1
			end
		end

		CFG[tabname] = newdata
		cfgfunc[tabname] = function (group)
			return newdata[group]
		end
	end,
	["hunqi_god_attr"] = function (data)
		local newdata = {}
		local tabname = "hunqi_god_attr_group"
		for i, v in ipairs(data) do
			local tab = table.getOrNewTable(newdata,v.group)
			tab[#tab+1] = v
		end
		for _, tab in pairs(newdata) do
			local w = 0
			for i, v in ipairs(tab) do
				w = w + v.weight
				v.weight = w
			end
		end
		CFG[tabname] = newdata
		cfgfunc[tabname] = genGetFunckey(newdata)
	end,
	["hunqi_base_attr"] = function (data)
		for k, v in pairs(data) do
			local w = 0
			for _, cfg in ipairs(v) do
				w = w + cfg.weight
				cfg.weight = w
			end
		end
	end,
	["exp_item"] = function (data)
		for id, v in pairs(data) do
			_ITEM_EXP[id] = v.exp
		end
	end,
	["draw_group"] = function (data)
		for _, v in pairs(data) do
			local w = 0
			for i, c in ipairs(v) do
				w = w + c.weight
				c.weight = w
			end
		end
	end,
	["family_send"] = function (data)
		local newdata = {}
		local tabname = "family_send_type"
		for _, v in pairs(data) do
			local tab = table.getOrNewTable(newdata,v.type)
			tab[#tab+1] = v
		end
		CFG[tabname] = newdata
		cfgfunc[tabname] = genGetFunckey(newdata)
	end,
	["shop_common"] = function (data)
		local newdata = {}
		local tabname = "shop_common_condtion"
		for _, v in pairs(data) do
			if #v.open_condtion > 0 then
				newdata[#newdata+1] = v
			end
		end
		CFG[tabname] = newdata
		-- cfgfunc[tabname] = genGetFunckey(newdata)
	end,
	["new_open"] = function (data)
		local newdata = {}
		local tabname = "new_open_task"
		for _, v in pairs(data) do
			for _, cond in ipairs(v.condition) do
				if cond[1] == 2 then
					for i = 2, #cond do
						newdata[cond[i]] = v.id
					end
				end
			end
		end
		CFG[tabname] = newdata
		cfgfunc[tabname] = genGetFunckey(newdata)
	end,
	["item_compose_unlock"] = function (data)
		local newdata = {}
		local tabname = "item_compose_unlock_task"
		for _, v in pairs(data) do
			for i, tid in ipairs(v.param) do
				newdata[tid] = v.id
			end
		end
		CFG[tabname] = newdata
		cfgfunc[tabname] = genGetFunckey(newdata)
	end
}

local function getKeyTabal( d,k )
	local t = d[k]
	if t == nil then
		t = {}
		d[k] = t
	end
	return t
end
-- 生成多级table -> 单条数据
local function genNMapFunc( ks )
	return function( data )
		local nt = {}
		for i,v in ipairs(data) do
			local last = nt
			for j=1,#ks-1 do
				last = getKeyTabal(last,v[ks[j]])
			end
			last[v[ks[#ks]]] = v
		end
		return nt
	end
end

-- 生成多级table -> vec 多条数据
local function genNMapVecFunc( ks )
	return function( data )
		local nt = {}
		for i,v in ipairs(data) do
			local last = nt
			for j=1,#ks do
				last = getKeyTabal(last,v[ks[j]])
			end
			last[#last+1] = v
		end
		return nt
	end
end

local function genGetFunc2key(data)
	return function( k1,k2 )
		local d = data[k1]
		if d then
			return d[k2]
		end
	end
end

local function genGetFunc3key(data)
	return function( k1,k2,k3 )
		local d = data[k1]
		if d then
			d = d[k2]
			if d then
				return d[k3]
			end
		end
	end
end

for k, conf in pairs(nmapconf) do
	initfunc[k] = genNMapFunc(conf)
	if #conf == 2 then
		getfunc[k] = genGetFunc2key
	elseif #conf == 3 then
		getfunc[k] = genGetFunc3key
	end
end

for k, conf in pairs(nmapvecconf) do
	initfunc[k] = genNMapVecFunc(conf)
	if #conf == 2 then
		getfunc[k] = genGetFunc2key
	elseif #conf == 3 then
		getfunc[k] = genGetFunc3key
	end
end



cfgfunc.table = function( name )
	return CFG[name]
end

local function genGetFunc( name )
	local _tab = CFG[name]

	if getfunc[name] then
		return getfunc[name](_tab)
	else
		return function( id )
			return _tab[id]
		end
	end
end

local function loadcfg(v)
	local data = require("cfgdata."..v)
	if initfunc[v] then
		data = initfunc[v](data)
	end

	if afterloadinit[v] then
		afterloadinit[v](data)
	end
	
	CFG[v] = data
end

local function loaderror(err)
	LOG.error(err)
end

for i,v in ipairs(cfgfile) do
	xpcall(loadcfg,loaderror,v)
end

for i,v in ipairs(cfgfile) do
    cfgfunc[v] = genGetFunc(v)
end

function ReloadCfgData( orgname )
	local name = "cfgdata."..orgname
	package.loaded[name] = nil
	
	local data = require (name)

	if initfunc[orgname] then
		data = initfunc[orgname](data)
	end

	if afterloadinit[orgname] then
		afterloadinit[orgname](data)
	end

	CFG[orgname] = data
	cfgfunc[orgname] = genGetFunc(name)
	print("hot load cfg %s",orgname)
end

return cfgfunc