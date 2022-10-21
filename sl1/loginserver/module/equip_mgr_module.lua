local _func = LFUNC
local _lc = LTOC
local _sermid = SERVER_MSG
local _net = nil
local _cfg = CFG_DATA
local _string = STRING_UTIL
local _IT = ITEM_TYPE
local _login_id = 0

local function split_int_vec(s)
	return _string.splite_int_vec(s)
end

local function concat_vec(v)
	return table.concat(v,":")
end

-- sql field to proto field
local MEM_COMMON_FIELD_BIND = {
	[ITEM_TYPE.IT_INSTANCE_HUNQI] = {
		field = {
			int1 = "exp",
			int2 = "level",
			int3 = "god_attr",
			int4 = "base_attr_index",
			string1 = "attr",
		},
		sql_to_proto = {
			string1 = split_int_vec
		},
		proto_to_sql = {
			attr = concat_vec
		}
	},
	[ITEM_TYPE.IT_INSTANCE_ITEM] = {
		field = {
			int1 = "extra",
		},
	},
}

local function updateMemCommonData(d,load)
	local f = MEM_COMMON_FIELD_BIND[d.type]
	if f then
		local sql_to_proto = f.sql_to_proto or {}
		local proto_to_sql = f.proto_to_sql or {}
		for sqlk, k in pairs(f.field) do
			if load then
				-- sql to proto
				if sql_to_proto[sqlk] then
					d[k] = sql_to_proto[sqlk](d[sqlk])
				else
					d[k] = d[sqlk] or d[k]
				end
			else
				-- proto to sql
				if proto_to_sql[k] then
					d[sqlk] = proto_to_sql[k](d[k])
				else
					d[sqlk] = d[k] or d[sqlk]
				end
			end
		end
	end
end

local UNIQUEID_TYPE = {
	UT_EQUIP = 1,
	UT_MAIL = 2,
	UT_TEAM = 3,
	UT_FAMILY = 4,
}

local _uniqueid = {}

local equip_mgr_module = {}

function equip_mgr_module:init()
	self._equip_pool = {}
	self._bone_pool = {}
	self._pet_pool = {}
	self._core_pool = {}
	self._mem_common_pool = {}

	_login_id = GAME_CONFIG.login_id

	
	for _, v in pairs(UNIQUEID_TYPE) do
		_uniqueid[v] = {
			num = 0,
			time = 0,
		}
	end

	_net = MOD.net_mgr_module
end
-- 绑定消息
function equip_mgr_module:init_func()
	
end

local UID_START_TIME = 1638500635

function equip_mgr_module:genUniqueId(type)
	local uid = _uniqueid[type]
	local now = LFUNC.getNowSecond()

	if now > uid.time then
		uid.time = now
		uid.num = 0
	end

	local id = (_login_id<<44)|((now-UID_START_TIME)<<12)|uid.num
	uid.num = uid.num + 1
	if uid.num >= 0xFFF then
		uid.num = 0
		uid.time = uid.time + 1
	end
	return id
end

function equip_mgr_module:loadPlayerEquip(vec)
	for i, v in ipairs(vec) do
		self._equip_pool[v.id] = v
	end
end

function equip_mgr_module:loadPlayerBone(vec)
	for i, v in ipairs(vec) do
		self._bone_pool[v.id] = v
	end
end

function equip_mgr_module:loadPlayerPet(vec)
	for i, v in ipairs(vec) do
		self._pet_poll[v.id] = v
	end
end

function equip_mgr_module:loadPlayerCore(vec)
	for i, v in ipairs(vec) do
		self._core_pool[v.id] = v
	end
end

function equip_mgr_module:loadPlayerMemCommon(vec)
	for i, v in ipairs(vec) do
		updateMemCommonData(v,true)
		self._mem_common_pool[v.id] = v
	end
end

local function randSlotNum(wtvec)
	local rv = math.random(wtvec[#wtvec][2])
	for i, wt in ipairs(wtvec) do
		if wt[2] >= rv then
			return wt[1]
		end
	end
	return 0
end

local BONE_KEYS = {
	"strong_lv",
	"strong_exp",
	"jinglian_lv",
	"star_lv",
	"star_exp",
	"hunsui1_lv",
	"hunsui2_lv",
	"hunsui3_lv",
	"hunsui4_lv",
	"hunsui5_lv",
	"hunsui1_exp",
	"hunsui2_exp",
	"hunsui3_exp",
	"hunsui4_exp",
	"hunsui5_exp",
}

function equip_mgr_module:checkBoneNew(b)
	for _, k in ipairs(BONE_KEYS) do
		if b[k] ~= 0 then
			return false
		end
	end
	return true
end

local EQUIP_KEY = {
	"strong_lv",
	"jinglian_lv",
	"star",
	"fuling_1",
	"fuling_2",
	"fuling_3",
}

function equip_mgr_module:checkEquipNew(e)
	for _, k in ipairs(EQUIP_KEY) do
		if e[k] > 0 then
			return false
		end
	end
	return true
end

local base_attr_lv_weight = {80,95,100}

function equip_mgr_module:createUniqueEquip(dbid,base,cid,reason,initfunc)
	local cfg = _cfg.equip(base)
	if cfg == nil then
		return
	end

	local flnum = 0
	local cfgfl = _cfg.equip_fuling_slot(cfg.order)
	if cfgfl then
		flnum = randSlotNum(cfgfl.weight)
	end

	local id = self:genUniqueId(UNIQUEID_TYPE.UT_EQUIP)

	local equip = {
		id = id,
		owner_id = cid,
		base = base,
		create_time = _func.getNowSecond(),
		bind = 0,
		lock = 0,
		strong_lv = 0,
		jinglian_lv = 0,
		star = 0,
		fuling_1 = 0,
		fuling_2 = 0,
		fuling_3 = 0,
		attr_lv = 0,
	}

	equip.attr_lv = _func.rand_weight_index(base_attr_lv_weight)

	for i = 1, flnum do
		equip["fuling_"..i] = -1
	end

	if initfunc then
		initfunc(equip)
	end

	self._equip_pool[id] = equip

	local pb = {
		type = reason,
		equip = equip,
	}
	-- 插入数据库
	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_EQUIP,pb,"DBEquipChange")

	return equip
end

function equip_mgr_module:getEquip(id)
	return self._equip_pool[id]
end

function equip_mgr_module:updateEquip(dbid,equip,reason)
	local pb = {
		type = reason,
		equip = equip,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_EQUIP,pb,"DBEquipChange")
end

function equip_mgr_module:deleteEquip(dbid,equip,reason)
	self._equip_pool[equip.id] = nil

	local pb = {
		type = reason,
		equip = equip,
	}

	for i = 1, 3 do
		local coid = equip["fuling_"..i]
		if coid > 0 then
			self:deleteCoreById(dbid,coid,reason)
		end
	end

	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_EQUIP,pb,"DBEquipChange")
end

function equip_mgr_module:deleteEquipById(dbid,id,reason)
	local equip = self._equip_pool[id]
	if equip == nil then
		return
	end

	self._equip_pool[equip.id] = nil

	local pb = {
		type = reason,
		equip = equip,
	}

	for i = 1, 3 do
		local coid = equip["fuling_"..i]
		if coid > 0 then
			self:deleteCoreById(dbid,coid,reason)
		end
	end

	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_EQUIP,pb,"DBEquipChange")
end

function equip_mgr_module:createUniqueBone(dbid,base,cid,reason)
	local cfg = _cfg.bone(base)
	if cfg == nil then
		return
	end

	local id = self:genUniqueId(UNIQUEID_TYPE.UT_EQUIP)

	local bone = {
		id = id,
		owner_id = cid,
		base = base,
		create_time = _func.getNowSecond(),
		bind = 0,
		lock = 0,
		strong_lv = 0,
		strong_exp = 0,
		jinglian_lv = 0,
		star_lv = 0,
		star_exp = 0,
		hunsui1_lv = 0,
		hunsui2_lv = 0,
		hunsui3_lv = 0,
		hunsui4_lv = 0,
		hunsui5_lv = 0,
		hunsui1_exp = 0,
		hunsui2_exp = 0,
		hunsui3_exp = 0,
		hunsui4_exp = 0,
		hunsui5_exp = 0,
	}

	self._bone_pool[id] = bone

	local pb = {
		type = reason,
		bone = bone,
	}
	-- 插入数据库
	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_BONE,pb,"DBBoneChange")

	return bone
end

function equip_mgr_module:getBone(id)
	return self._bone_pool[id]
end

function equip_mgr_module:updateBone(dbid,bone,reason)
	local pb = {
		type = reason,
		bone = bone,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_BONE,pb,"DBBoneChange")
end

function equip_mgr_module:deleteBone(dbid,bone,reason)
	self._bone_pool[bone.id] = nil

	local pb = {
		type = reason,
		bone = bone,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_BONE,pb,"DBBoneChange")
end

function equip_mgr_module:deleteBoneById(dbid,id,reason)
	local bone = self._bone_pool[id]
	if bone == nil then
		return
	end

	self._bone_pool[bone.id] = nil

	local pb = {
		type = reason,
		bone = bone,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_BONE,pb,"DBBoneChange")
end

function equip_mgr_module:createUniquePet(dbid,base,cid,reason)
	local cfg = _cfg.pet(base)
	if cfg == nil then
		return
	end

	local id = self:genUniqueId(UNIQUEID_TYPE.UT_EQUIP)

	local pet = {
		id = id,
		owner_id = cid,
		base = base,
		create_time = _func.getNowSecond(),
		level = 0,
		grade = 0,
		zizhi_1 = 0,
		zizhi_2 = 0,
		zizhi_3 = 0,
		zizhi_4 = 0,
		zizhi_5 = 0,
		attr_1 = 0,
		attr_2 = 0,
		attr_3 = 0,
		attr_4 = 0,
		attr_5 = 0,
		attr_num = 0,
		juexing = 0,
		neidan_1 = 0,
		neidan_2 = 0,
		neidan_3 = 0,
		neidan_4 = 0,
		neidan_5 = 0,
		skill_1 = 0,
		skill_2 = 0;
		skill_3 = 0,
		skill_4 = 0,
		skill_5 = 0,
		skill_6 = 0,
		skill_7 = 0,
		skill_8 = 0,
		skill_9 = 0,
		skill_10 = 0,
		skill_11 = 0,
		skill_12 = 0,
		skill_13 = 0,
		skill_14 = 0,
		skill_15 = 0,
		skill_16 = 0,
	}

	self._pet_pool[id] = pet

	local pb = {
		type = reason,
		pet = pet,
	}
	-- 插入数据库
	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_PET,pb,"DBPetChange")

	return pet
end

function equip_mgr_module:getPet(id)
	return self._pet_pool[id]
end

function equip_mgr_module:updatePet(dbid,pet,reason)
	local pb = {
		type = reason,
		pet = pet,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_PET,pb,"DBPetChange")
end

function equip_mgr_module:deletePet(dbid,pet,reason)
	self._pet_pool[pet.id] = nil

	local pb = {
		type = reason,
		pet = pet,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_PET,pb,"DBPetChange")
end

function equip_mgr_module:deletePetById(dbid,id,reason)
	local pet = self._pet_pool[id]
	if pet == nil then
		return
	end

	self._pet_pool[pet.id] = nil

	local pb = {
		type = reason,
		pet = pet,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_PET,pb,"DBPetChange")
end

function equip_mgr_module:createUniqueCore(dbid,base,cid,reason)
	local cfg = _cfg.core(base)
	if cfg == nil then
		return
	end

	local id = self:genUniqueId(UNIQUEID_TYPE.UT_EQUIP)

	local core = {
		id = id,
		owner_id = cid,
		base = base,
		create_time = _func.getNowSecond(),
		lock = 0,
		equip_id = 0,
		exp = 0,
		level = 1,
		bind = 0,
	}

	self._core_pool[id] = core

	local pb = {
		type = reason,
		core = core,
	}
	-- 插入数据库
	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_CORE,pb,"DBCoreChange")
	return core
end

function equip_mgr_module:getCore(id)
	return self._core_pool[id]
end

function equip_mgr_module:updateCore(dbid,core,reason)
	local pb = {
		type = reason,
		core = core,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_CORE,pb,"DBCoreChange")
end

function equip_mgr_module:deleteCore(dbid,core,reason)
	self._core_pool[core.id] = nil

	local pb = {
		type = reason,
		core = core,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_CORE,pb,"DBCoreChange")
end

function equip_mgr_module:deleteCoreById(dbid,id,reason)
	local core = self._core_pool[id]
	if core == nil then
		return
	end

	self._core_pool[core.id] = nil

	local pb = {
		type = reason,
		core = core,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_CORE,pb,"DBCoreChange")
end

function equip_mgr_module:createMemCommon(dbid,type,base,fielddata,cid,reason)
	local id = self:genUniqueId(UNIQUEID_TYPE.UT_EQUIP)

	fielddata = fielddata or {}

	local data = {
		id = id,
		owner_id = cid,
		type = type,
		base = base,
		create_time = _func.getNowSecond(),
		lock = 0,
		bind = 0,
		int1 = 0,
		int2 = 0,
		int3 = 0,
		int4 = 0,
		string1 = "",
	}

	updateMemCommonData(data,true)

	if not table.empty(fielddata) then
		for k, v in pairs(fielddata) do
			data[k] = v
		end
		updateMemCommonData(data)
	end

	self._mem_common_pool[id] = data

	local pb = {
		reason = reason,
		data = data,
	}
	-- 插入数据库
	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_MEM_COMMON,pb,"DBMemUniqueCommonChange")
	return data
end

function equip_mgr_module:randHunqiAttr(type,attrtype,hunqi)
	local randcfg = _cfg.hunqi_strong_attr_rand(type,attrtype,hunqi.level)
	if randcfg then
		local gdata = _cfg.hunqi_strong_attr(randcfg.strong_attr_group)
		if gdata then
			local check = {}
			local randvec = {}
			for _, id in ipairs(hunqi.attr) do
				check[id] = true
			end

			for _, v in ipairs(gdata) do
				if check[v.id] == nil then
					randvec[#randvec+1] = v.id
				end
			end
			return _func.rand_vector(randvec)
		end
	end
end

function equip_mgr_module:createHunqi(dbid,id,cid,reason)
	local cfg = _cfg.hunqi(id)
	if cfg == nil then
		return
	end

	local cfgvec = _cfg.hunqi_base_attr(cfg.type)
	if cfgvec == nil then
		return
	end

	local data = {
		level = 1,
		god_attr = 0,
		attr = {}
	}

	data.base_attr_index = _func.rand_weight_index_by_key(cfgvec,"weight")

	local rid = self:randHunqiAttr(cfg.type,cfg.attr_type,data)
	if rid then
		data.attr[1] = rid
	end

	-- 神赐属性
	if math.random(1,1000) <= cfg.god_attr_rate then
		local gdata = _cfg.hunqi_god_attr_group(cfg.god_attr_group)
		if gdata then
			local godcfg = _func.rand_weight(gdata,"weight")
			data.god_attr = godcfg.id
		end
	end

	return self:createMemCommon(dbid,_IT.IT_INSTANCE_HUNQI,id,data,cid,reason)
end

function equip_mgr_module:createMemItem(dbid,id,cid,reason)
	return self:createMemCommon(dbid,_IT.IT_INSTANCE_ITEM,id,{},cid,reason)
end

function equip_mgr_module:getMemCommon(id)
	return self._mem_common_pool[id]
end

function equip_mgr_module:updateMemCommon(dbid,data,reason)
	updateMemCommonData(data)
	local pb = {
		reason = reason,
		data = data,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_MEM_COMMON,pb,"DBMemUniqueCommonChange")
end

function equip_mgr_module:deleteMemCommon(dbid,data,reason)
	self._mem_common_pool[data.id] = nil

	local pb = {
		reason = reason,
		data = data,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_MEM_COMMON,pb,"DBMemUniqueCommonChange")
end

function equip_mgr_module:deleteMemCommonById(dbid,id,reason)
	local data = self._mem_common_pool[id]
	if data == nil then
		return
	end

	self._mem_common_pool[data.id] = nil

	local pb = {
		reason = reason,
		data = data,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_DELETE_MEM_COMMON,pb,"DBMemUniqueCommonChange")
end

function equip_mgr_module:addMail(dbid,cid,sender,title,content,reward,reason)
	local mail = {
		id = self:genUniqueId(UNIQUEID_TYPE.UT_MAIL),
		cid = cid,
		sender = sender,
		title = title,
		content = content,
		reward = reward,
		state = 0,
		reason = reason,
		time = _func.getNowSecond(),
	}

	_net:sendToDBMsg(dbid,_sermid.IM_DB_INSERT_MAIL,mail,"MemChrMail")
	return mail
end

function equip_mgr_module:updateMail(dbid,m)
	local msg = {
		id = m.id,
		state = m.state,
	}
	_net:sendToDBMsg(dbid,_sermid.IM_DB_UPDATE_MAIL,msg,"MemChrMail")
end

function equip_mgr_module:createTeam(module,target,private,minlv,maxlv)
	local team = {
		id = self:genUniqueId(UNIQUEID_TYPE.UT_TEAM),
		module = module,
        target = target,
		private = private,
        minlv = minlv,
        maxlv = maxlv,
		state = TEAM_STATE.TS_START,
		time = 0,
		dungeonid = 0,
		uniqueid = 0,
        leader = {},
		member = {},
    }
	return team
end

function equip_mgr_module:genFamilyId()
	return self:genUniqueId(UNIQUEID_TYPE.UT_FAMILY)
end

return equip_mgr_module