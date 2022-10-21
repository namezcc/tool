local _ST = STORAGE_TYPE
local _IT = ITEM_TYPE
local _ITS = ITEM_SUB_TYPE
local _BIND = BIND_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _cm = CM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _cr = CHANGE_REASON
local _II = ITEM_ID
local _record = RECORD_TYPE
local _ct = CURRENCY_TYPE
local _func = LFUNC
local _drop_item = DROP_ITEM_MAP
local _attr_mod = PLAYER_ATTR_SOURCE
local _usefunc = require("util.item_effect")
local _net_mgr = MOD.net_mgr_module

local MAX_BAG_EQUIP_SIZE = 100
local MAX_BAG_MATERIAL_SIZE = 100
local MAX_BAG_4_SIZE = 100

local MAX_CHR_EQUIP_SIZE = 8
local MAX_CHR_BONE_SIZE = 6
local MAX_HUNQI_SIZE = 6
local CURRENCY_ITEM_MAX_ID = 99
local MAX_CHR_HUNYIN_SIZE = 27

local MAX_BAG_SIZE = {
	[_IT.IT_ITEM] = 2000,
	[_IT.IT_EQUIP] = 1000,
	[_IT.IT_BONE] = 1000,
	[_IT.IT_NO_USE] = 0,
	[_IT.IT_CORE] = 1000,
	[_IT.IT_ANQI] = 1000,
	[_IT.IT_HUNQI] = 1000,
}

local _equip_mgr = nil

local bag_module = {}

local function makeSlot(slot,id,tp,num,bind)
	return {
		slot = slot,
		id = id,
		type = tp,
		count = num,
		bind = bind or _BIND.BT_BIND,
	}
end

local function getStorageClientPb(st,slot,tp,id,count,bind)
	return {
		storage = st,
		slot = slot,
		type = tp,
		id = id,
		count = count,
		bind = bind,
	}
end

local function getStorageDbPb(cid,sid,st,slot,tp,id,count,bind)
	return {
		cid = cid,
		sid = sid,
		storage = st,
		slot = slot,
		type = tp,
		id = id,
		count = count,
		bind = bind,
	}
end

local function is_slot_valid(st,slot)
	if st == _ST.ST_BAG_EQUIP then
		return slot >= 1 and slot <= MAX_BAG_EQUIP_SIZE
	elseif st == _ST.ST_BAG_MATERIAL then
		return slot >= 1 and slot <= MAX_BAG_MATERIAL_SIZE
	elseif st == _ST.ST_BAG_4 then
		return slot >= 1 and slot <= MAX_BAG_4_SIZE
	elseif st == _ST.ST_CHR_EQUIP then
		return slot >= 1 and slot <= MAX_CHR_EQUIP_SIZE
	elseif st == _ST.ST_CHR_BONE then
		return slot >= 1 and slot <= MAX_CHR_BONE_SIZE
	elseif st == _ST.ST_CHR_HUNYIN then
		return slot >= 1 and slot <= MAX_CHR_HUNYIN_SIZE
	elseif st == _ST.ST_WUHUN_HUNQI then
		return slot >= 1 and slot <= MAX_HUNQI_SIZE
	end
end

local function get_storage_size(st)
	if st == _ST.ST_BAG_EQUIP then
		return MAX_BAG_EQUIP_SIZE
	elseif st == _ST.ST_BAG_MATERIAL then
		return MAX_BAG_MATERIAL_SIZE
	elseif st == _ST.ST_BAG_4 then
		return MAX_BAG_4_SIZE
	elseif st == _ST.ST_CHR_EQUIP then
		return MAX_CHR_EQUIP_SIZE
	elseif st == _ST.ST_CHR_BONE then
		return MAX_CHR_BONE_SIZE
	elseif st == _ST.ST_CHR_HUNYIN then
		return MAX_CHR_HUNYIN_SIZE
	elseif st == _ST.ST_WUHUN_HUNQI then
		return MAX_HUNQI_SIZE
	end
end

local get_table = table.getOrNewTable

local DROP_OUT_TIME = 300
local function check_drop_item_outtime(drop)
	local remove = {}
	local now = _func.getNowSecond()

	for t, v in pairs(drop) do
		if now > t + DROP_OUT_TIME then
			remove[#remove+1] = t
		end
	end

	for i, t in ipairs(remove) do
		drop[t] = nil
	end
end

function bag_module:init()
	

	_equip_mgr = MOD.equip_mgr_module

	_msg_func.bind_player_proto_func(CM.CM_ITEM_PUT_ON,self.onItemPutOn,"CmMoveItem")
	_msg_func.bind_player_proto_func(CM.CM_ITEM_PUT_DOWN,self.onItemPutDown,"CmMoveItem")
	_msg_func.bind_player_proto_func(CM.CM_USE_ITEM,self.onUseItem,"ProtoInt32Array")
	_msg_func.bind_player_proto_func(CM.CM_PICK_ITEM,self.onPickItem,"ProtoInt32Array")
	_msg_func.bind_player_proto_func(CM.CM_SET_ITEM_LOCK,self.onItemLock,"CmItemLock")
	_msg_func.bind_player_proto_func(CM.CM_ITEM_DELETE,self.onItemDelete,"PInt64Array")

end

function bag_module:initDB(data)
	self._slot_change = {}

	self._item_bag = {}
	self._item_change = {}

	self._mem_item = {}
	self._mem_equip = {}
	self._mem_bone = {}
	self._mem_core = {}
	self._mem_hunqi = {}
	self._mem_pet = {}

	self._bag_use_size = {0,0,0,0,0,0,0}

	self._chr_equip = {}
	self._chr_bone = {}
	self._chr_hunyin = {}
	self._chr_hunqi = {}

	self._item_cd = {}

	for i, v in ipairs(data.storage) do
		if v.storage == _ST.ST_CHR_EQUIP then
			self._chr_equip[v.slot] = table.cloneSimple(v)
		elseif v.storage == _ST.ST_CHR_BONE then
			self._chr_bone[v.slot] = table.cloneSimple(v)
		elseif v.storage == _ST.ST_CHR_HUNYIN then
			self._chr_hunyin[v.slot] = table.cloneSimple(v)
		elseif v.storage == _ST.ST_WUHUN_HUNQI then
			self._chr_hunqi[v.slot] = table.cloneSimple(v)
		end
	end
	
	local usize = 0
	for i, v in ipairs(data.item) do
		if v.bind_count > 0 then
			usize = usize + 1
		end
		self._item_bag[v.item] = v
	end

	self._bag_use_size[_IT.IT_ITEM] = usize

	for i, v in ipairs(data.equips) do
		self._mem_equip[v.id] = v
	end
	self._bag_use_size[_IT.IT_EQUIP] = #data.equips

	for i, v in ipairs(data.bone) do
		self._mem_bone[v.id] = v
	end
	self._bag_use_size[_IT.IT_BONE] = #data.bone

	for i, v in ipairs(data.core) do
		self._mem_core[v.id] = v
	end
	self._bag_use_size[_IT.IT_CORE] = #data.core

	local hunqisend = {}
	local memitem = {}
	for i, v in ipairs(data.memCommon) do
		if v.type == _IT.IT_INSTANCE_HUNQI then
			self._mem_hunqi[v.id] = v
			hunqisend[#hunqisend+1] = v
		elseif v.type == _IT.IT_INSTANCE_ITEM then
			self._mem_item[v.id] = v
			memitem[#memitem+1] = v
		end
	end

	self._bag_use_size[_IT.IT_HUNQI] = #hunqisend
	self._bag_use_size[_IT.IT_ITEM] = self._bag_use_size[_IT.IT_ITEM] + #memitem

	for i, v in ipairs(data.pet) do
		self._mem_pet[v.id] = v
	end

	-- 装备信息
	self:sendEquipInfo(data.equips)
	-- 魂骨
	self:sendBoneInfo(data.bone)
	-- 魔核
	self:sendCoreInfo(data.core)
	-- 魂器
	self:sendHunqiInfo(hunqisend)
	-- 实例物品
	self:sendMemItem(memitem)

	-- 发给客户端
	self:sendMsg(_sm.SM_STORAGE_INFO,{slots=data.storage},"StorageInfo")
	self:sendMsg(_sm.SM_ITEM_BAG,{data=data.item},"SmItemBag")

	-- 掉落
	local drop = get_table(_drop_item,self.cid)
	check_drop_item_outtime(drop)
	self._drop_map = drop
	self:sendDropItemMap(drop)

	--怪物掉落记录
	self._monster_drop = {}
	for _, v in ipairs(data.monster_drop) do
		self._monster_drop[v.monster] = v.drop
	end
	self:sendMsg(_sm.SM_MONSTER_DROP_INFO, {list = data.monster_drop}, "SmMonsterDropInfo")
end

--在initDB之后调用的
function bag_module:afterInit()

	--货币信息
	self:sendCurrency()

	--计算属性
	self:updateModuleAttr(_attr_mod.PAS_EQUIP,true)
	self:updateModuleAttr(_attr_mod.PAS_BONE,true)
	self:updateModuleAttr(_attr_mod.PAS_ANQI,true)
end

function bag_module:addBagUseSize(tp,num)
	local n = self._bag_use_size[tp] + num
	self._bag_use_size[tp] = n
	if n < 0 then
		_log.error("error bag size < 0 tp=%d",tp)
	end
end

-- 属性等级 -> 基础属性加成
local base_attr_per = {0.85,0.90,1}

function bag_module:calcEquipAttr()
	local attr = {}

	local jlsuit = {0,0,0,0,0,0,0,0}

	for k, v in pairs(self._chr_equip) do
		if v.id <= 0 then
			goto continue
		end

		local equip = self:getSelfEquip(v.id)
		if equip == nil then
			goto continue
		end

		local ecfg = _cfg.equip(equip.base)
		if ecfg == nil then
			goto continue
		end

		if equip.attr_lv == 3 and equip.jinglian_lv == 0 then
			_func.combindAttr(attr,ecfg.talent_attr)
		else
			local per = base_attr_per[equip.attr_lv] or base_attr_per[1]
			if equip.jinglian_lv > 0 then
				jlsuit[k] = equip.jinglian_lv
				local jlcfg = _cfg.equip_jinglian(ecfg.type,equip.jinglian_lv)
				if jlcfg then
					per = per * (1+jlcfg.attr_add/10000)
				end
			end

			for i, vec in ipairs(ecfg.talent_attr) do
				local vt = get_table(attr,vec[1])
				vt[vec[2]] = per*vec[3]
			end
		end
		
		_func.combindAttr(attr,ecfg.attr)

		if equip.strong_lv > 0 then
			local attrcfg = _cfg.equip_strong_attr(ecfg.equip_job,ecfg.type,equip.strong_lv)
			if attrcfg then
				_func.combindAttr(attr,attrcfg.attr)
			end
		end

		if equip.star > 0 then
			local attrcfg = _cfg.equip_star_attr(ecfg.type,equip.star)
			if attrcfg then
				_func.combindAttr(attr,attrcfg.attr)
			end
		end

		for i = 1, 3 do
			local flid = equip["fuling_"..i]
			if flid > 0 then
				local core = _equip_mgr:getCore(flid)
				if core then
					local ccfg = _cfg.core(core.base)
					if ccfg then
						_func.combindAttr(attr,ccfg.attr)
						local clvcfg = _cfg.core_level(ccfg.order,core.level)
						if clvcfg then
							_func.combindAttr(attr,clvcfg.attr)
						end
					end
				end
			end
		end

		::continue::
	end

	local deflv = 99
	local atklv = 99
	for i, v in ipairs(jlsuit) do
		if i <= 4 then
			if v < deflv then
				deflv = v
			end
		else
			if v < atklv then
				atklv = v
			end
		end
	end

	if deflv > 0 then
		local cfg = _cfg.equip_jinglian_suit(deflv)
		if cfg then
			_func.combindAttr(attr,cfg.attr_def)
		end
	end
	if atklv > 0 then
		local cfg = _cfg.equip_jinglian_suit(atklv)
		if cfg then
			_func.combindAttr(attr,cfg.attr_atk)
		end
	end

	return attr
end

function bag_module:checkInPuton(type,eid)
	if type == _IT.IT_INSTANCE_EQUIP then
		for _, v in pairs(self._chr_equip) do
			if v.id == eid then
				return true
			end
		end
	elseif type == _IT.IT_INSTANCE_BONE then
		for _, v in pairs(self._chr_bone) do
			if v.id == eid then
				return true
			end
		end
	elseif type == _IT.IT_INSTANCE_HUNQI then
		for _, v in pairs(self._chr_hunqi) do
			if v.id == eid then
				return true
			end
		end
	end
	return false
end

function bag_module:checkCalcEquip(eid)
	for _, v in pairs(self._chr_equip) do
		if v.id == eid then
			self:updateModuleAttr(_attr_mod.PAS_EQUIP)
			break
		end
	end
end

function bag_module:checkBonePuton(eid)
	for _, v in pairs(self._chr_bone) do
		if v.id == eid then
			return true
		end
	end
	return false
end

function bag_module:checkCalcBone(eid)
	for _, v in pairs(self._chr_bone) do
		if v.id == eid then
			self:updateModuleAttr(_attr_mod.PAS_BONE)
			break
		end
	end
end

function bag_module:getSelfItem(id)
	return self._mem_item[id]
end

function bag_module:getSelfEquip(id)
	return self._mem_equip[id]
end

function bag_module:getSelfBone(id)
	return self._mem_bone[id]
end

function bag_module:getSelfCore(id)
	return self._mem_core[id]
end

function bag_module:getSelfHunqi(id)
	return self._mem_hunqi[id]
end

function bag_module:getSelfPet(id)
	return self._mem_pet[id]
end

function bag_module:sendOneEquipInfo(e)
	if e == nil then
		return
	end
	local pb = {
		equip = {e}
	}
	self:sendMsg(_sm.SM_EQUIP_INFO,pb,"SmEquipInfo")
end

function bag_module:sendEquipInfo(vec)
	if vec == nil or #vec == 0 then
		return
	end
	local pb = {
		equip = vec
	}
	self:sendMsg(_sm.SM_EQUIP_INFO,pb,"SmEquipInfo")
end

function bag_module:sendOneBoneInfo(e)
	if e == nil then
		return
	end
	local pb = {
		bone = {e}
	}
	self:sendMsg(_sm.SM_BONE_INFO,pb,"SmBoneInfo")
end

function bag_module:sendBoneInfo(vec)
	if vec == nil or #vec == 0 then
		return
	end
	
	local pb = {
		bone = vec,
	}
	self:sendMsg(_sm.SM_BONE_INFO,pb,"SmBoneInfo")
end

function bag_module:sendCoreInfo(vec)
	if vec == nil or #vec == 0 then
		return
	end
	
	local pb = {
		data = vec,
	}
	self:sendMsg(_sm.SM_CORE_INFO,pb,"SmCoreInfo")
end

function bag_module:sendHunqiInfo(vec)
	if vec == nil or #vec == 0 then
		return
	end
	
	local pb = {
		data = vec,
	}
	self:sendMsg(_sm.SM_HUNQI_INFO,pb,"SmMemHunQi")
end

function bag_module:sendMemItem(vec)
	if vec == nil or #vec == 0 then
		return
	end
	
	local pb = {
		data = vec,
	}
	self:sendMsg(_sm.SM_MEM_ITEM_INFO,pb,"SmMemItem")
end

function bag_module:get_slot_data(st,slot)
	if st == _ST.ST_CHR_EQUIP then
		return self._chr_equip[slot]
	elseif st == _ST.ST_CHR_BONE then
		return self._chr_bone[slot]
	elseif st == _ST.ST_CHR_HUNYIN then
		return self._chr_hunyin[slot]
	elseif st == _ST.ST_WUHUN_HUNQI then
		return self._chr_hunqi[slot]
	end
end

function bag_module:update_slot_data(st,slot,sdata)
	if st == _ST.ST_CHR_EQUIP then
		self._chr_equip[slot] = sdata
	elseif st == _ST.ST_CHR_BONE then
		self._chr_bone[slot] = sdata
	elseif st == _ST.ST_CHR_HUNYIN then
		self._chr_hunyin[slot] = sdata
	elseif st == _ST.ST_WUHUN_HUNQI then
		self._chr_hunqi[slot] = sdata
	end
	self:set_slot_change(st,slot)
end

function bag_module:set_slot_change(stor,slot)
	local change = table.getOrNewTable(self._slot_change,stor)
	change[slot] = true
end

-- 同步格子改变,db和客户端
function bag_module:sync_slot_change()
	if table.empty(self._slot_change) then
		return
	end

	local clientpb = {}
	local dbupdate = {}
	local dbdelete = {}
	local cid,sid = self.cid,self.sid

	for st, stor in pairs(self._slot_change) do
		for slot, _ in pairs(stor) do
			local sdata = self:get_slot_data(st,slot)
			local cpb,dbpb = nil,nil
			if sdata == nil then
				cpb = getStorageClientPb(st,slot,0,0,0)
				dbpb = getStorageDbPb(cid,sid,st,slot)

				dbdelete[#dbdelete+1] = dbpb
			else
				cpb = getStorageClientPb(st,slot,sdata.type,sdata.id,sdata.count,sdata.bind)
				dbpb = getStorageDbPb(cid,sid,st,slot,sdata.type,sdata.id,sdata.count,sdata.bind)

				dbupdate[#dbupdate+1] = dbpb
			end

			clientpb[#clientpb+1] = cpb
		end
	end

	self:sendMsg(_sm.SM_STORAGE_INFO,{slots=clientpb},"StorageInfo")

	if #dbupdate > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_storage,dbupdate)
	end
	if #dbdelete then
		self:dbDeleteDataVector(_table.TAB_mem_chr_storage,dbdelete)
	end

	self._slot_change = {}
end

function bag_module:sync_item_change()
	if table.empty(self._item_change) then
		return
	end

	local clientpb = {}
	local dbupdate = {}
	local dbdelete = {}
	local ibag = self._item_bag

	for k, _ in pairs(self._item_change) do
		local item = ibag[k]
		clientpb[#clientpb+1] = item
		if item.bind_count == 0 then
			dbdelete[#dbdelete+1] = item
			ibag[k] = nil
		else
			dbupdate[#dbupdate+1] = item
		end
	end

	self:sendMsg(_sm.SM_ITEM_BAG,{data=clientpb},"SmItemBag")

	if #dbupdate > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_item,dbupdate)
	end
	if #dbdelete > 0 then
		self:dbDeleteDataVector(_table.TAB_mem_chr_item,dbdelete)
	end

	self._item_change = {}
end
-- vec={{id,tp,num,bind},...}
function bag_module:addBagCheck(slotvec,notice)
	local useslot = {0,0,0,0,0,0,0}
	local ibag = self._item_bag

	for i, v in ipairs(slotvec) do
		local id = v[1]
		local tp = v[2]
		local num = v[3]

		if num <= 0 then
			return false
		end

		if tp == _IT.IT_ITEM then
			if id > CURRENCY_ITEM_MAX_ID then
				local item = ibag[id]
				if item == nil then
					useslot[_IT.IT_ITEM] = useslot[_IT.IT_ITEM] + 1
				else
					if item.bind_count == 0 then
						useslot[_IT.IT_ITEM] = useslot[_IT.IT_ITEM] + 1
					end
				end
			end
		else
			if tp == _IT.IT_EQUIP then
				local ecfg = _cfg.equip(id)
				if ecfg == nil then
					_log.error("equip cfg nil id:%d",id)
					return false
				end
			elseif tp == _IT.IT_BONE then
				local bcfg = _cfg.bone(id)
				if bcfg == nil then
					return false
				end
			elseif tp == _IT.IT_CORE then
				local bcfg = _cfg.core(id)
				if bcfg == nil then
					return false
				end
			elseif tp == _IT.IT_ANQI then
				if _cfg.anqi(id) == nil then
					return false
				end
			elseif tp == _IT.IT_HUNQI then
				if _cfg.hunqi(id) == nil then
					return false
				end
			else
				return false
			end
			useslot[tp] = useslot[tp] + num
		end
	end

	for k, v in pairs(useslot) do
		if v > 0 then
			if self._bag_use_size[k] + v > MAX_BAG_SIZE[k] then
				-- 背包空间不足
				if notice then
					self:replyMsg(_cm.CM_PICK_ITEM,ERROR_CODE.ERR_BAG_FULL,{k})
				end
				return false
			end
		end
	end
	return true
end

function bag_module:update_equip_owner(e,sendMem,reason)
	e.owner_id = self.cid
	_equip_mgr:updateEquip(self.db_serid,e,reason)

	for i = 1, 3 do
		local coreid = e["fuling_"..i]
		if coreid > 0 then
			local core = _equip_mgr:getCore(coreid)
			if core and core.owner_id ~= self.cid then
				core.owner_id = self.cid
				_equip_mgr:updateCore(self.db_serid,core,reason)
				local sendtab = get_table(sendMem,_IT.IT_CORE)
				sendtab[#sendtab+1] = core
			end
		end
	end
end

local function get_item_bag(ibag,type,id,cid)
	local item = ibag[id]
	if item == nil then
		item = {
			cid = cid,
			type = type,
			item = id,
			count = 0,
			bind_count = 0,
		}
		ibag[id] = item
	end
	return item
end

local function checkMemItem(type)
	if type == _ITS.GAO or type == _ITS.FUTOU or type == _ITS.YUGAN then
		return true
	end
	return false
end
-- vec={{id,tp,num,bind},...}
function bag_module:addBag(slotvec,reason)
	if slotvec == nil or #slotvec == 0 then
		return
	end

	local ibag = self._item_bag
	local cid = self.cid
	local dbid = self.db_serid

	local sendMem = {}
	local logvec = {}
	local additem = 0
	local now = _func.getNowSecond()

	for i, v in ipairs(slotvec) do
		local id = v[1]
		local tp = v[2]
		local num = v[3]
		-- local bind = v[4] or _BIND.BT_BIND

		local log = {
			cid = cid,
			itemid = id,
			type = tp,
			num = num,
			reason = reason,
			realid = 0,
			time = now,
		}

		if tp == _IT.IT_ITEM then
			if id > CURRENCY_ITEM_MAX_ID then
				local cfg = _cfg.item(id)
				if cfg then
					if checkMemItem(cfg.type) then
						if num >= 100 then
							num = 1
						end
						for i = 1, num do
							local mem = _equip_mgr:createMemItem(dbid,id,cid,reason)
							if mem then
								local sendtab = get_table(sendMem,_IT.IT_ITEM)
								sendtab[#sendtab+1] = mem
								self._mem_item[mem.id] = mem

								local mlog = table.cloneSimple(log)
								mlog.realid = mem.id
								mlog.num = 1
								logvec[#logvec+1] = mlog
							end
						end
					else
						local item = get_item_bag(ibag,tp,id,cid)
						if item.bind_count == 0 then
							additem = additem + 1
						end
						item.bind_count = item.bind_count + num
						self._item_change[id] = true
						logvec[#logvec+1] = log
					end
					self:updateProgressByType(TASK_CONDITION_TYPE.TCT_GET_ITEM, id, num)
					self:updateProgressByType(TASK_CONDITION_TYPE.TCT_REQ_ITEM, id, self:getItemTotalNum(id))
				end
			else
				-- 货币
				self:addCurrencyById(id,num,reason)
				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_INSTANCE_ITEM then
			-- 物品实例
			local mem = _equip_mgr:getMemCommon(id)
			if mem then
				if mem.owner_id ~= cid  then
					mem.owner_id = cid
					_equip_mgr:updateMemCommon(dbid,mem,reason)
				end
				local sendtab = get_table(sendMem,_IT.IT_ITEM)
				sendtab[#sendtab+1] = mem
				self._mem_item[mem.id] = mem
				self:updateProgressByType(TASK_CONDITION_TYPE.TCT_GET_ITEM, id, num)
				self:updateProgressByType(TASK_CONDITION_TYPE.TCT_REQ_ITEM, id, self:getItemTotalNum(id))

				log.realid = id
				log.itemid = mem.base
				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_EQUIP then
			-- 生成装备
			for i = 1, num do
				local equip = _equip_mgr:createUniqueEquip(dbid,id,cid,reason)
				if equip then
					local sendtab = get_table(sendMem,_IT.IT_EQUIP)
					sendtab[#sendtab+1] = equip
					self._mem_equip[equip.id] = equip

					local mlog = table.cloneSimple(log)
					mlog.realid = equip.id
					mlog.num = 1
					logvec[#logvec+1] = mlog
				end
			end
		elseif tp == _IT.IT_INSTANCE_EQUIP then
			-- 更新装备
			local equip = _equip_mgr:getEquip(id)
			if equip then
				if equip.owner_id ~= cid  then
					self:update_equip_owner(equip,sendMem,reason)
				end
				local sendtab = get_table(sendMem,_IT.IT_EQUIP)
				sendtab[#sendtab+1] = equip
				self._mem_equip[equip.id] = equip

				log.realid = id
				log.itemid = equip.base
				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_BONE then
			-- 生成魂骨
			for i = 1, num do
				local bone = _equip_mgr:createUniqueBone(dbid,id,cid,reason)
				if bone then
					local sendtab = get_table(sendMem,_IT.IT_BONE)
					sendtab[#sendtab+1] = bone
					self._mem_bone[bone.id] = bone

					local mlog = table.cloneSimple(log)
					mlog.realid = bone.id
					mlog.num = 1
					logvec[#logvec+1] = mlog
				end
			end
		elseif tp == _IT.IT_INSTANCE_BONE then
			-- 更新魂骨
			local bone = _equip_mgr:getBone(id)
			if bone then
				if bone.owner_id ~= cid  then
					bone.owner_id = cid
					_equip_mgr:updateBone(dbid,bone,reason)
				end
				local sendtab = get_table(sendMem,_IT.IT_BONE)
				sendtab[#sendtab+1] = bone
				self._mem_bone[bone.id] = bone

				log.realid = id
				log.itemid = bone.base
				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_CORE then
			-- 生成魔核
			for i = 1, num do
				local core = _equip_mgr:createUniqueCore(dbid,id,cid,reason)
				if core then
					local sendtab = get_table(sendMem,_IT.IT_CORE)
					sendtab[#sendtab+1] = core
					self._mem_core[core.id] = core

					local mlog = table.cloneSimple(log)
					mlog.realid = core.id
					mlog.num = 1
					logvec[#logvec+1] = mlog
				end
			end
		elseif tp == _IT.IT_INSTANCE_CORE then
			-- 更新魔核
			local core = _equip_mgr:getCore(id)
			if core then
				if core.owner_id ~= cid  then
					core.owner_id = cid
					_equip_mgr:updateCore(dbid,core,reason)
				end
				local sendtab = get_table(sendMem,_IT.IT_CORE)
				sendtab[#sendtab+1] = core
				self._mem_core[core.id] = core

				log.realid = id
				log.itemid = core.base
				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_ANQI then
			local cfg = _cfg.anqi(id)
			if cfg then
				if self:haveAnqi(id) then
					-- 暗器自动分解
					if cfg then
						local item = get_item_bag(ibag,_IT.IT_ITEM,cfg.item,cid)
						item.bind_count = item.bind_count + num*cfg.item_count
						self._item_change[cfg.item] = true
					end
				else
					self:anqiActive(id)
				end

				logvec[#logvec+1] = log
			end
		elseif tp == _IT.IT_HUNQI then
			-- 生成魂器
			for i = 1, num do
				local data = _equip_mgr:createHunqi(dbid,id,cid,reason)
				if data then
					local sendtab = get_table(sendMem,_IT.IT_HUNQI)
					sendtab[#sendtab+1] = data
					self._mem_hunqi[data.id] = data

					local mlog = table.cloneSimple(log)
					mlog.realid = data.id
					mlog.num = 1
					logvec[#logvec+1] = mlog
				end
			end
		elseif tp == _IT.IT_INSTANCE_HUNQI then
			--更新魂器
			local data = _equip_mgr:getMemCommon(id)
			if data then
				if data.owner_id ~= cid  then
					data.owner_id = cid
					_equip_mgr:updateMemCommon(dbid,data,reason)
				end
				local sendtab = get_table(sendMem,_IT.IT_HUNQI)
				sendtab[#sendtab+1] = data
				self._mem_hunqi[data.id] = data

				log.realid = id
				log.itemid = data.base
				logvec[#logvec+1] = log
			end
		end
	end

	for tp, vec in pairs(sendMem) do
		if tp == _IT.IT_ITEM then
			self:sendMemItem(vec)
		elseif tp == _IT.IT_EQUIP then
			self:sendEquipInfo(vec)
		elseif tp == _IT.IT_BONE then
			self:sendBoneInfo(vec)
		elseif tp == _IT.IT_CORE then
			self:sendCoreInfo(vec)
		elseif tp == _IT.IT_HUNQI then
			self:sendHunqiInfo(vec)
			self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNQI, 0, #vec)
		end
		self:addBagUseSize(tp,#vec)
	end
	self:addBagUseSize(_IT.IT_ITEM,additem)

	self:sync_item_change()

	if #logvec > 0 then
		_net_mgr:dbLogVector(_table.TAB_log_useitem,logvec)
	end
end

function bag_module:addCurrencyById(id,num,reason)
	if id == _II.II_JINHUNBI then
		self:addCurrency(_ct.CT_JINHUNBI,num,reason)
	elseif id == _II.II_JINHUNBI_2 then
		self:addCurrency(_ct.CT_JINHUNBI_2,num,reason)
	elseif id == _II.II_JINHUNBI_3 then
		self:addCurrency(_ct.CT_JINHUNBI_3,num,reason)
	elseif id == _II.II_DRAW_CARD_COIN_1 then
		self:addCurrency(_ct.CT_DRAW_CARD_COIN_1,num,reason)
	elseif id == _II.II_DRAW_CARD_COIN_2 then
		self:addCurrency(_ct.CT_DRAW_CARD_COIN_2,num,reason)
	elseif id == _II.II_HUNSHI_EXP then
		self:addExp(num,reason)
	elseif id == _II.II_NHHY then
		self:addCurrency(_ct.CT_NHHY, num, reason)
	elseif id >= _II.II_COUNTRY_GOLD_1 and id <= _II.II_COUNTRY_GOLD_5 then
		self:addCurrency(_ct.CT_COUNTRY_GOLD_1+id-_II.II_COUNTRY_GOLD_1,num,reason)
	elseif id == _II.II_DIAMOND then
		self:addGold(num,0,reason)
	elseif id == _II.II_BIND_DIAMOND then
		self:addGold(0,num,reason)
	elseif id == _II.II_TIANFU_POINT_1 then
		self:addTianfuPoint(num,0,0)
	elseif id == _II.II_TIANFU_POINT_2 then
		self:addTianfuPoint(0,num,0)
	elseif id == _II.II_TIANFU_POINT_3 then
		self:addTianfuPoint(0,0,num)
	elseif id == _II.II_NEILI then
		self:addNeili(num)
	elseif id >= _II.II_COUNTRY_1 and id <= _II.II_COUNTRY_5 then
		local val = self:addRecord(_record.RT_COUNTRY_POWER_BEGIN+id-_II.II_COUNTRY_1,num)
		self:sendRecordValue(_record.RT_COUNTRY_POWER_BEGIN+id-_II.II_COUNTRY_1,val)
		self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_WEIWANG, id-_II.II_COUNTRY_1+1, val, 1)
	end
end

function bag_module:addCurrency(ct,num,reason)
	if ct >= 0 and ct < _ct.CT_ADD_EDN then
		if ct == _ct.CT_NHHY then
			self:updateNHHY()
		end
		self:addRecord(_record.RT_CURRENCY_BEGIN + ct,num)
		self:sendCurrency(ct)
		if num < 0 then
			self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_COST_CURRENCY, ct, -num, 1)
			if ct == _ct.CT_NHHY then
				self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_COST_TILI,0,-num)
			end
		end
	end
end

function bag_module:getCurrency(ct)
	if ct < _ct.CT_ADD_EDN then
		if ct == _ct.CT_NHHY then
			self:updateNHHY()
		end
		return self:getRecord(_record.RT_CURRENCY_BEGIN+ct)
	else
		if ct == _ct.CT_DIAMOND then
			return self._chr_info.gold_unbind
		elseif ct == _ct.CT_BIND_DIAMOND then
			return self._chr_info.gold_bind
		end
	end
end

function bag_module:sendCurrency(ct)
	local pb = {}

	if ct == nil then
		for _, tp in pairs(CURRENCY_TYPE) do
			pb[#pb+1] = {data1=tp,data2=self:getCurrency(tp)}
		end
	else
		pb[#pb+1] = {data1=ct,data2=self:getCurrency(ct)}
	end

	self:sendMsg(_sm.SM_CURRENCY_INFO,{list=pb},"ProtoPairInt32Array")
end

local function get_delbag_cashuse(cash,id)
	local info = cash[id]
	if info == nil then
		info = {
			count = 0,
			bind_count = 0,
		}
		cash[id] = info
	end
	return info
end
-- vec={{id,tp,num,bind},...}
function bag_module:delBagCheck(slotvec)
	local ibag = self._item_bag
	local havebind = _BIND.BT_UNBIND
	local cashuse = {}

	for i, v in ipairs(slotvec) do
		local id = v[1]
		local tp = v[2]
		local num = v[3]

		if num <= 0 then
			return false
		end

		if tp == _IT.IT_ITEM then
			local item = ibag[id]
			if item == nil then
				return false
			end

			local cash = get_delbag_cashuse(cashuse,id)
			cash.bind_count = cash.bind_count + num
			if item.bind_count > 0 then
				havebind = _BIND.BT_BIND
			end
			if cash.bind_count > item.bind_count then
				return false
			end
		else
			local ins = nil
			if tp == _IT.IT_INSTANCE_ITEM then
				ins = self._mem_item[id]
			elseif tp == _IT.IT_INSTANCE_EQUIP then
				ins = self._mem_equip[id]
			elseif tp == _IT.IT_INSTANCE_BONE then
				ins = self._mem_bone[id]
			elseif tp == _IT.IT_INSTANCE_CORE then
				ins = self._mem_core[id]
			elseif tp == _IT.IT_INSTANCE_HUNQI then
				ins = self._mem_hunqi[id]
			else
				return false
			end
			if ins == nil then
				return false
			end
			if ins.bind == _BIND.BT_BIND then
				havebind = _BIND.BT_BIND
			end
		end
	end
	return true,havebind
end

function bag_module:getItemTotalNum(id)
	local item = self._item_bag[id]
	if item == nil then
		return 0
	else
		return item.bind_count
	end
end

function bag_module:getItemNum(id)
	local item = self._item_bag[id]
	if item == nil then
		return 0
	else
		return item.bind_count
	end
end
-- vec={{id,tp,num,bind},...}
-- delins:是否删除实例
-- send 是否同步消息
function bag_module:delBag(slotvec,reason,delins,send)
	local ibag = self._item_bag
	local delmsg = {}
	local delnum = {0,0,0,0,0,0,0}
	local dbid = self.db_serid
	delins = delins or true

	local cid = self.cid
	local logvec = {}

	for i, v in ipairs(slotvec) do
		local id = v[1]
		local tp = v[2]
		local num = v[3]

		local log = {
			cid = cid,
			itemid = id,
			type = tp,
			num = -num,
			reason = reason,
			realid = 0,
			time = now,
		}

		if tp == _IT.IT_ITEM then
			local item = ibag[id]
			if item == nil then
				return
			end
			item.bind_count = item.bind_count - num
			if item.bind_count == 0 then
				delnum[_IT.IT_ITEM] = delnum[_IT.IT_ITEM] + 1
			end
			self._item_change[id] = true
		elseif tp == _IT.IT_INSTANCE_ITEM then
			local mem = self._mem_item[id]
			self._mem_item[id] = nil
			delnum[_IT.IT_ITEM] = delnum[_IT.IT_ITEM] + 1
			delmsg[#delmsg+1] = {type = tp,id = id}
			if delins then
				_equip_mgr:deleteMemCommonById(dbid,id,reason)
			end
			log.realid = id
			log.itemid = mem.base
		elseif tp == _IT.IT_INSTANCE_EQUIP then
			local mem = self._mem_equip[id]
			self._mem_equip[id] = nil
			delmsg[#delmsg+1] = {type = tp,id = id}
			delnum[_IT.IT_EQUIP] = delnum[_IT.IT_ITEM] + 1
			if delins then
				_equip_mgr:deleteEquipById(dbid,id,reason)
			end
			log.realid = id
			log.itemid = mem.base
		elseif tp == _IT.IT_INSTANCE_BONE then
			local mem = self._mem_bone[id]
			self._mem_bone[id] = nil
			delnum[_IT.IT_BONE] = delnum[_IT.IT_ITEM] + 1
			delmsg[#delmsg+1] = {type = tp,id = id}
			if delins then
				_equip_mgr:deleteBoneById(dbid,id,reason)
			end
			log.realid = id
			log.itemid = mem.base
		elseif tp == _IT.IT_INSTANCE_CORE then
			local mem = self._mem_core[id]
			self._mem_core[id] = nil
			delnum[_IT.IT_CORE] = delnum[_IT.IT_ITEM] + 1
			delmsg[#delmsg+1] = {type = tp,id = id}
			if delins then
				_equip_mgr:deleteCoreById(dbid,id,reason)
			end
			log.realid = id
			log.itemid = mem.base
		elseif tp == _IT.IT_INSTANCE_HUNQI then
			local mem = self._mem_hunqi[id]
			self._mem_hunqi[id] = nil
			delnum[_IT.IT_HUNQI] = delnum[_IT.IT_ITEM] + 1
			delmsg[#delmsg+1] = {type = tp,id = id}
			if delins then
				_equip_mgr:deleteMemCommonById(dbid,id,reason)
			end
			log.realid = id
			log.itemid = mem.base
		end

		logvec[#logvec+1] = log
	end

	--同步实例删除
	if #delmsg > 0 then
		self:sendMsg(_sm.SM_DELETE_INSTANCE,{list=delmsg},"SmDelete_instance")
	end

	for tp, n in pairs(delnum) do
		if n > 0 then
			self:addBagUseSize(tp,-n)
		end
	end

	if send == false then
		return
	end
	self:sync_item_change()
end

function bag_module:clearBag()
	for k, v in pairs(self._item_bag) do
		-- v.count = 0
		v.bind_count = 0
		self._item_change[k] = true
	end

	self:sync_item_change()
end

function bag_module:onItemPutOn(d)
	if is_slot_valid(d.storage,d.slot) == false then
		return
	end

	if d.storage == _ST.ST_CHR_EQUIP then
		self:chrEquipPuton(d.id,d.slot)
	elseif d.storage == _ST.ST_CHR_BONE then
		self:chrBonePuton(d.id,d.slot)
	elseif d.storage == _ST.ST_CHR_HUNYIN then
		self:chrHunyinPuton(d.id,d.slot)
	elseif d.storage == _ST.ST_WUHUN_HUNQI then
		self:chrHunqiPuton(d.id,d.slot)
	end
end

function bag_module:onItemPutDown(d)
	if is_slot_valid(d.storage,d.slot) == false then
		return
	end

	if d.storage == _ST.ST_CHR_EQUIP then
		self:chrEquipPutDown(d.slot)
	elseif d.storage == _ST.ST_CHR_BONE then
		self:chrBonePutDown(d.slot)
	elseif d.storage == _ST.ST_CHR_HUNYIN then
		self:chrHunyinPutDown(d.slot)
	elseif d.storage == _ST.ST_WUHUN_HUNQI then
		self:chrHunqiPutDown(d.slot)
	end
end

function bag_module:chrEquipPuton(id,toslot)
	local tdata = self:get_slot_data(_ST.ST_CHR_EQUIP,toslot)

	local fequip = self:getSelfEquip(id)
	if fequip == nil then
		return
	end

	local cfg = _cfg.equip(fequip.base)
	if cfg == nil or cfg.type ~= toslot then
		return
	end

	local havejob = false
	for i, job in ipairs(cfg.job) do
		if job == self._chr_info.job then
			havejob = true
			break
		end
	end

	if havejob == false then
		return
	end

	if tdata ~= nil then
		local tequip = self:getSelfEquip(tdata.id)
		if tequip == nil then
			return
		end

		local change = false
		if tequip.strong_lv > fequip.strong_lv then
			fequip.strong_lv,tequip.strong_lv = tequip.strong_lv,fequip.strong_lv
			change = true
		end
		if tequip.jinglian_lv > fequip.jinglian_lv then
			fequip.jinglian_lv,tequip.jinglian_lv = tequip.jinglian_lv,fequip.jinglian_lv
			change = true
		end
		if tequip.star > fequip.star then
			fequip.star,tequip.star = tequip.star,fequip.star
			change = true
		end

		if change then
			_equip_mgr:updateEquip(self.db_serid,fequip,_cr.CR_MOVE_ITEM)
			_equip_mgr:updateEquip(self.db_serid,tequip,_cr.CR_MOVE_ITEM)
			self:sendEquipInfo({fequip,tequip})
		end

		tdata.id = id
	else
		tdata = makeSlot(toslot,id,_IT.IT_INSTANCE_EQUIP,1)
	end

	self:update_slot_data(_ST.ST_CHR_EQUIP,toslot,tdata)
	self:sync_slot_change()
	self:updateModuleAttr(_attr_mod.PAS_EQUIP)
	local eNum = self:getChrPutonNum(_ST.ST_CHR_EQUIP, 1, cfg.level)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_EQUIP, cfg.level, eNum, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_EQUIP, fequip.base)
end

function bag_module:chrEquipPutDown(slot)
	local fdata = self:get_slot_data(_ST.ST_CHR_EQUIP,slot)
	if fdata == nil then
		return
	end

	self:update_slot_data(_ST.ST_CHR_EQUIP,slot,nil)
	self:sync_slot_change()
	self:updateModuleAttr(_attr_mod.PAS_EQUIP)
end

local function boneBatter(on,off)
	local change = false

	if off.strong_lv > on.strong_lv then
		off.strong_lv,on.strong_lv = on.strong_lv,off.strong_lv
		change = true
	end
	if off.strong_exp > on.strong_exp then
		off.strong_exp,on.strong_exp = on.strong_exp,off.strong_exp
		change = true
	end
	if off.jinglian_lv > on.jinglian_lv then
		off.jinglian_lv,on.jinglian_lv = on.jinglian_lv,off.jinglian_lv
		change = true
	end

	for i = 1, 5 do
		local k = "hunsui"..i.."_lv"
		if off[k] > on[k] then
			off[k],on[k] = on[k],off[k]
			change = true
		end

		k = "hunsui"..i.."_exp"
		if off[k] > on[k] then
			off[k],on[k] = on[k],off[k]
			change = true
		end
	end
	return change
end

function bag_module:chrBonePuton(id,toslot)
	local tdata = self:get_slot_data(_ST.ST_CHR_BONE,toslot)

	local fbone = _equip_mgr:getBone(id)
	if fbone == nil then
		return
	end

	local cfg = _cfg.bone(fbone.base)
	if cfg == nil or cfg.type ~= toslot then
		return
	end

	local skillchange = false
	if cfg.skill_level > 0 then
		skillchange = true
	end

	if tdata ~= nil then
		local tbone = _equip_mgr:getBone(tdata.id)
		if tbone == nil then
			return
		end

		if boneBatter(fbone,tbone) then
			_equip_mgr:updateBone(self.db_serid,fbone,_cr.CR_MOVE_ITEM)
			_equip_mgr:updateBone(self.db_serid,tbone,_cr.CR_MOVE_ITEM)
			self:sendBoneInfo({fbone,tbone})
		end

		local tcfg = _cfg.bone(tbone.base)
		if tcfg then
			if tcfg.skill_level > 0 then
				skillchange = true
			end
			if tcfg.buff > 0 then
				self:removePlayerBuff(tcfg.buff)
			end
		end

		tdata.id = id
	else
		tdata = makeSlot(toslot,id,_IT.IT_INSTANCE_BONE,1)
	end

	self:update_slot_data(_ST.ST_CHR_BONE,toslot,tdata)
	self:sync_slot_change()
	self:updateModuleAttr(PLAYER_ATTR_SOURCE.PAS_BONE)

	if cfg.buff > 0 then
		self:addPlayerBuff({cfg.buff})
	end

	if skillchange then
		self:updateHunhuanSkill()
	end
	local bNum = self:getChrPutonNum(_ST.ST_CHR_BONE, 1, cfg.order)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_BONE, cfg.order, bNum, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_EQUIP, fbone.base)
end

function bag_module:chrBonePutDown(slot)
	local fdata = self:get_slot_data(_ST.ST_CHR_BONE,slot)
	if fdata == nil then
		return
	end

	self:update_slot_data(_ST.ST_CHR_BONE,slot,nil)
	self:sync_slot_change()
	self:updateModuleAttr(PLAYER_ATTR_SOURCE.PAS_BONE)

	local fbone = _equip_mgr:getBone(fdata.id)
	if fbone then
		local cfg = _cfg.bone(fbone.base)
		if cfg then
			if cfg.skill_level > 0 then
				self:updateHunhuanSkill()
			end
			
			if cfg.buff > 0 then
				self:removePlayerBuff(cfg.buff)
			end
		end
	end
end

function bag_module:chrHunyinPuton(id,toslot)
	if not self:checkCanPutonHunyin(toslot, id) then
		return
	end

	local tdata = self:get_slot_data(_ST.ST_CHR_HUNYIN,toslot)
	local cfg = _cfg.hunyin(id)
	if cfg == nil then
		return
	end

	if tdata ~= nil then
		local addcfg = _func.make_cfg_item(tdata.id,tdata.type,1,tdata.bind)
		if not self:addBagCheck(addcfg) then
			return
		end

		self:addBag(addcfg,_cr.CR_HUNYIN_PUTDOWN)
		self:update_slot_data(_ST.ST_CHR_HUNYIN,toslot,nil)
	end

	local bindcount = self:getItemNum(id)
	local bindtype = _BIND.BT_UNBIND
	if bindcount == 0 then
		return
	end

	local delcfg = _func.make_cfg_item(id,_IT.IT_ITEM,1,bindtype)
	if not self:delBagCheck(delcfg) then
		return
	end
	self:delBag(delcfg,_cr.CR_HUNYIN_PUTON)

	local slotdata = makeSlot(toslot,id,_IT.IT_ITEM,1, bindtype)
	self:update_slot_data(_ST.ST_CHR_HUNYIN,toslot,slotdata)
	self:sync_slot_change()
	self:updateHunyinInfo(toslot)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNYIN_PUTON, 0, self:getChrPutonNum(_ST.ST_CHR_HUNYIN), 1)
	local hyNum = self:getChrPutonNum(_ST.ST_CHR_HUNYIN, 1, cfg.quality)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_HUNYIN, cfg.quality, hyNum, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_EQUIP, id)
end

function bag_module:chrHunyinPutDown(fromslot)
	local fdata = self:get_slot_data(_ST.ST_CHR_HUNYIN,fromslot)
	if fdata == nil then
		return
	end

	local addcfg = _func.make_cfg_item(fdata.id,fdata.type,1,fdata.bind)
	if not self:addBagCheck(addcfg) then
		return
	end

	self:addBag(addcfg,_cr.CR_HUNYIN_PUTDOWN)
	self:update_slot_data(_ST.ST_CHR_HUNYIN,fromslot,nil)
	
	self:sync_slot_change()
	self:updateHunyinInfo(fromslot)
end

function bag_module:chrHunqiPuton(id,toslot)
	local tdata = self:get_slot_data(_ST.ST_WUHUN_HUNQI,toslot)

	local fdata = _equip_mgr:getMemCommon(id)
	if fdata == nil then
		return
	end

	local cfg = _cfg.hunqi(fdata.base)
	if cfg == nil or cfg.type ~= toslot then
		return
	end

	if tdata ~= nil then
		tdata.id = id
	else
		tdata = makeSlot(toslot,id,_IT.IT_INSTANCE_HUNQI,1)
	end

	self:update_slot_data(_ST.ST_WUHUN_HUNQI,toslot,tdata)
	self:sync_slot_change()
	local hqNum = self:getChrPutonNum(_ST.ST_WUHUN_HUNQI, 1, cfg.qulity)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_PUTON_SUIT_HUNQI, cfg.qulity, hqNum, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_EQUIP, fdata.base)
end

function bag_module:chrHunqiPutDown(slot)
	local fdata = self:get_slot_data(_ST.ST_WUHUN_HUNQI,slot)
	if fdata == nil then
		return
	end

	self:update_slot_data(_ST.ST_WUHUN_HUNQI,slot,nil)
	self:sync_slot_change()
end

function bag_module:getChrPutonNum(st, type, param)
	if st ~= _ST.ST_CHR_EQUIP and st ~= _ST.ST_CHR_BONE and st ~= _ST.ST_CHR_HUNYIN and st ~= _ST.ST_WUHUN_HUNQI then
		return 0
	end
	local num = 0
	local size = get_storage_size(st)
	for slot = 1, size, 1 do
		local sdata = self:get_slot_data(st, slot)
		if sdata then
			if type and param then
				local bCheck = false
				if st == _ST.ST_CHR_EQUIP then
					local uEquip = self:getSelfEquip(sdata.id)
					if uEquip then
						local iCfg = _cfg.equip(uEquip.base)
						if iCfg then
							if type == 1 and iCfg.level >= param then --等级
								bCheck = true
							end
						end
					end
				elseif st == _ST.ST_CHR_BONE then
					local uBone = _equip_mgr:getBone(sdata.id)
					if uBone then
						local iCfg = _cfg.bone(uBone.base)
						if iCfg then
							if type == 1 and iCfg.order >= param then --等阶
								bCheck = true
							end
						end
					end
				elseif st == _ST.ST_CHR_HUNYIN then
					local iCfg = _cfg.hunyin(sdata.id)
					if iCfg then
						if type == 1 and iCfg.quality == param then --品质
							bCheck = true
						end
					end
				elseif st == _ST.ST_WUHUN_HUNQI then
					local uHunqi = _equip_mgr:getMemCommon(sdata.id)
					if uHunqi then
						local iCfg = _cfg.hunqi(uHunqi.base)
						if iCfg then
							if type == 1 and iCfg.qulity >= param then --品质
								bCheck = true
							end
						end
					end
				end
				if bCheck then
					num = num + 1
				end
			else
				num = num + 1
			end
		end
	end
	return num
end

function bag_module:onUseItem(d)
	local itemid = d.i32[1]
	local num = d.i32[2]

	local cfg = _cfg.item(itemid)
	if cfg == nil then
		return
	end

	local usefunc = _usefunc[cfg.type]
	if usefunc == nil then
		return
	end

	local itemcfg = _func.make_cfg_item(itemid,_IT.IT_ITEM,num,_BIND.BT_BIND)
	if not self:delBagCheck(itemcfg) then
		return
	end

	if cfg.cd > 0 and self._item_cd[cfg.type] and _func.getNowSecond() < self._item_cd[cfg.type] then
		return
	end

	if usefunc(self,itemid,num,cfg) == false then
		return
	end

	if cfg.cd > 0 then
		self._item_cd[cfg.type] = _func.getNowSecond() + cfg.cd
	end

	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_USE_ITEM, cfg.id, num)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_REQ_ITEM, cfg.id, self:getItemTotalNum(cfg.id))
	self:delBag(itemcfg,_cr.CR_USE_ITEM)
end

function bag_module:createDropItems(dropId, dropItems)
	local cfgDrop = _cfg.common_group_drop(dropId)
	if cfgDrop then
		for i = 1, cfgDrop.count do
			if math.random(1, 10000) <= cfgDrop.probability then
				local dropGroup = _cfg.drop_group(cfgDrop.group_id)
				if dropGroup and #dropGroup ~= 0 then
					local index = _func.rand_weight_index_by_key(dropGroup,"probability")
					local dropItem = dropGroup[index]
					if dropItem.item_num > 0 then
						dropItems[#dropItems+1] = {dropItem.item_id, dropItem.item_type, dropItem.item_num, dropItem.bind}
					end
				end
			end
		end
	end
end

function bag_module:checkMonsterDropped(mapMonsterId)
	local key = math.floor(mapMonsterId / 30)
	local index = (mapMonsterId % 30) + 1
	local checkVal = self._monster_drop[key]
	if checkVal and _func.is_bit_on(checkVal, index) then
		return true
	end

	if not checkVal then
		checkVal = 0
	end
	checkVal = _func.set_bit_on(checkVal, index)
	self._monster_drop[key] = checkVal
	_net_mgr:dbUpdateData(_table.TAB_mem_chr_monster_drop, {monster=key,drop=checkVal},self.cid)
	self:sendMsg(_sm.SM_MONSTER_DROP_INFO, {list={{monster=key,drop=checkVal}}}, "SmMonsterDropInfo")
	return false
end

function bag_module:clearMonsterDropInfo()
	self._monster_drop = {}
	_net_mgr:dbDeleteData(_table.TAB_mem_chr_monster_drop,{cid=self._chr_info.cid})
end

function bag_module:createDropItemsByIds(dropIds)
	local dropItems = {}
	if dropIds then
		for _, dropId in pairs(dropIds) do
			self:createDropItems(dropId, dropItems)
		end
	end
	return dropItems
end

--pos{x,y,z}
function bag_module:drop_reward_to_map(cfg,pos)
	if #cfg == 0 then
		return
	end
	local drop = self._drop_map
	check_drop_item_outtime(drop)
	
	local item = {}
	local ndrop = {
		pos = pos,
		item = item,
	}

	for i, v in ipairs(cfg) do
		item[#item+1] = {
			item_id = v[1],
			item_type = v[2],
			item_num = v[3],
			bind = v[4] or _BIND.BT_BIND,
		}
	end

	local t = _func.getNowSecond()
	while drop[t] do
		t = t + 1
	end

	drop[t] = ndrop
	self:sendDropItemMap({[t]=ndrop})
end

function bag_module:sendDropItemMap(drop)
	local data = {}

	for t, v in pairs(drop) do
		local info = {
			time = t,
			x = v.pos[1],
			y = v.pos[2],
			z = v.pos[3],
			item = v.item,
		}
		data[#data+1] = info
	end
	self:sendMsg(_sm.SM_DROP_ITEM,{data=data},"DropItemList")
end

function bag_module:onPickItem(d)
	if #d.i32 < 3 then
		return
	end

	local t = d.i32[1] 		--时间戳
	local id = d.i32[2] 	--物品id
	local num = d.i32[3] 	--数量

	local drop = self._drop_map
	local info = drop[t]
	if info == nil then
		return
	end

	local index = nil
	local item = nil
	for i, v in ipairs(info.item) do
		if v.item_id == id then
			index = i
			item = v
			if num > v.item_num then
				num = v.item_num
			end
			break
		end
	end

	if item == nil then
		return
	end

	local cfg = _func.make_cfg_item(item.item_id,item.item_type,num,item.bind)
	if not self:addBagCheck(cfg) then
		return
	end

	self:addBag(cfg,_cr.CR_PICK_ITEM)

	item.item_num = item.item_num - num
	if item.item_num == 0 and index ~= #info.item then
		info.item[#info.item],info.item[index] = info.item[index],info.item[#info.item]
	end
	info.item[#info.item] = nil
	if #info.item == 0 then
		drop[t] = nil
	end

	self:replyMsg(_cm.CM_PICK_ITEM,ERROR_CODE.ERR_SUCCESS,d.i32)
end

function bag_module:onItemLock(d)
	if d.type == _IT.IT_INSTANCE_EQUIP then
		local mem = self:getSelfEquip(d.id)
		if mem then
			mem.lock = d.lock
			_equip_mgr:updateEquip(self.db_serid,mem,_cr.CR_ITEM_LOCK)
			self:sendOneEquipInfo(mem)
		end
	elseif d.type == _IT.IT_INSTANCE_BONE then
		local mem = self:getSelfBone(d.id)
		if mem then
			mem.lock = d.lock
			_equip_mgr:updateBone(self.db_serid,mem,_cr.CR_ITEM_LOCK)
			self:sendOneBoneInfo(mem)
		end
	elseif d.type == _IT.IT_INSTANCE_CORE then
		local mem = self:getSelfCore(d.id)
		if mem then
			mem.lock = d.lock
			_equip_mgr:updateCore(self.db_serid,mem,_cr.CR_ITEM_LOCK)
			self:sendCoreInfo({mem})
		end
	elseif d.type == _IT.IT_INSTANCE_HUNQI then
		local mem = self:getSelfHunqi(d.id)
		if mem then
			mem.lock = d.lock
			_equip_mgr:updateMemCommon(self.db_serid,mem,_cr.CR_ITEM_LOCK)
			self:sendHunqiInfo({mem})
		end
	end
end

function bag_module:onItemDelete(d)
	local npc = d.data[1]
	local count = d.data[2]
	for i = 0, count - 1, 1 do
		local id = d.data[i*4+3]
		local tp = d.data[i*4+4]
		local num = d.data[i*4+5]
		local bind = d.data[i*4+6]

		if id and tp and num and bind then
			local delcfg = _func.make_cfg_item(id,tp,num,bind)
			if self:delBagCheck(delcfg) then
				self:delBag(delcfg, _cr.CR_ITEM_DELETE)
				if npc > 0 then
					self:updateProgressByType(TASK_CONDITION_TYPE.TCT_NPC_ITEM, npc, id, num)
				end
			end
		end
	end
end

return bag_module