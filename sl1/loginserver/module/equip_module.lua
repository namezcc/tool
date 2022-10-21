
local _cfg = CFG_DATA
local _bind = BIND_TYPE
local _cr = CHANGE_REASON
local _func = LFUNC
local _IT = ITEM_TYPE
local _equip_mgr = nil
local _sm = SM
local _table = TABLE_INDEX

local ELEMENT_TYPE = {
	HUO = 1,	--火
	BING = 2,	--冰
	DI = 3,		--地
	DIAN = 4,	--电
	FENG = 5,	--风
	SEHNG = 6,	--圣
	AN = 7,		--暗
	DU = 8,		--毒
}


local ITEM_EXP = _ITEM_EXP


local equip_module = {}

function equip_module:init()

	_equip_mgr = MOD.equip_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_MAKE_EQUIP,self.onMakeEquip,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_STRONG,self.onEquipStrong,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_STRONG_RECYCLE,self.onEquipStrongRecycle,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_JINGLIAN,self.onEquipJinglian,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_STAR,self.onEquipStar,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_STAR_RECYCLE,self.onEquipStarRecycle,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_FULING_ON,self.onEquipFulingOn,"CmEquipFuling")
	MSG_FUNC.bind_player_proto_func(CM.CM_EQUIP_FULING_OFF,self.onEquipFulingOff,"CmEquipFuling")
	MSG_FUNC.bind_player_proto_func(CM.CM_CORE_LEVEL_UP,self.onCoreLevelUp,"PInt64Array")

	MSG_FUNC.bind_player_proto_func(CM.CM_BONE_STRONG,self.onBoneStrong,"PInt64Pair32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_BONE_JINGLIAN,self.onBoneJinglian,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_BONE_STAR,self.onBoneStar,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_BONE_HUNSUI,self.onBoneHunsui,"PInt64Pair32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_BONE_ORDER_UPGRADE,self.onBoneOrder,"PInt64Array")

end

function equip_module:initDB(data)
	local equip_make = {}
	self._equip_make = equip_make

	local make_num = data.equip_make or {}
	for i, v in ipairs(make_num) do
		local make = table.getOrNewTable(equip_make,v.type)
		make[v.id] = v
	end
	self:sendMsg(_sm.SM_EQUIP_MAKE,{data = make_num},"SmEquipMake")
end

function equip_module:afterEnterGame()
	local pb = {}

	for k, v in pairs(self._chr_bone) do
		if v.id <= 0 then
			goto continue
		end

		local bone = self:getSelfBone(v.id)
		if bone == nil then
			goto continue
		end

		local bcfg = _cfg.bone(bone.base)
		if bcfg == nil then
			goto continue
		end

		if bcfg.buff > 0 then
			pb[#pb+1] = bcfg.buff
		end
		::continue::
	end

	self:addPlayerBuff(pb)
end

function equip_module:addPlayerBuff(idvec)
	if #idvec == 0 then
		return
	end
	local pb = {}
	for _, v in ipairs(idvec) do
		pb[#pb+1] = {
			data1 = v,
			data2 = 0,
		}
	end
	self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_ADD_BUFF,{list=pb},"ProtoPairInt32Array")
end

function equip_module:removePlayerBuff(id)
	self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_REMOVE_BUFF,{i32=id},"ProtoInt32")
end

function equip_module:sendEquipMake(info)
	self:sendMsg(_sm.SM_EQUIP_MAKE,{data = {info}},"SmEquipMake")
end

function equip_module:getEquipMakeNum(type,id)
	local make = table.getOrNewTable(self._equip_make,type)
	local info = make[id]
	if info then
		return info.num
	else
		return 0
	end
end

function equip_module:addEquipMakeNum(type,id)
	local make = table.getOrNewTable(self._equip_make,type)
	local info = make[id]
	if info == nil then
		info = {
			cid = self.cid,
			type = type,
			id = id,
			num = 0,
		}
		make[id] = info
	end
	info.num = info.num + 1
	self:sendEquipMake(info)
	self:dbUpdateData(_table.TAB_mem_chr_equip_make,info)
end

local BONE_SUIT = {
	BONE = 1,
	STRONG = 2,
	JINGLIAN = 3,
	STAR = 4,
	HUNSUI = 5,
}

local function setBoneSuitValue(tab,type,val)
	if type == BONE_SUIT.STAR then
		tab[type] = tab[type] + val
	else
		if val < tab[type] then
			tab[type] = val
		end
	end
end

local function getBoneSuitCfg(type,val)
	local cfgvec = _cfg.bone_suit(type)
	if cfgvec == nil then
		return
	end
	local cfg = nil
	for i, v in ipairs(cfgvec) do
		if v.level > val then
			break
		else
			cfg = v
		end
	end
	return cfg
end

function equip_module:calcBoneAttr()
	local attr = {}
	local attrtype = self._attr_type
	local suitval = {999,999,999,0,999}
	local suitnum = {}

	for k, v in pairs(self._chr_bone) do
		if v.id <= 0 then
			setBoneSuitValue(suitval,BONE_SUIT.BONE,0)
			goto continue
		end

		local bone = self:getSelfBone(v.id)
		if bone == nil then
			setBoneSuitValue(suitval,BONE_SUIT.BONE,0)
			goto continue
		end

		local bcfg = _cfg.bone(bone.base)
		if bcfg == nil then
			setBoneSuitValue(suitval,BONE_SUIT.BONE,0)
			goto continue
		end

		if bcfg.suit_id > 0 then
			local stab = table.getOrNewTable(suitnum,bcfg.suit_id)
			stab[#stab+1] = bcfg
		end

		setBoneSuitValue(suitval,BONE_SUIT.BONE,bcfg.order)

		setBoneSuitValue(suitval,BONE_SUIT.JINGLIAN,bone.jinglian_lv)
		if bone.jinglian_lv > 0 then
			local tmp = table.clone(bcfg.attr)
			local jlcfg = _cfg.bone_jinglian(bone.jinglian_lv)
			if jlcfg then
				for i, at in ipairs(tmp) do
					at[3] = math.floor(at[3]*(1+jlcfg.rate*0.001))
				end
			end
			_func.combindAttr(attr,tmp)
		else
			_func.combindAttr(attr,bcfg.attr)
		end

		setBoneSuitValue(suitval,BONE_SUIT.STAR,bone.star_lv)
		if bone.star_lv > 0 then
			local tmp = table.clone(bcfg.talent_attr)
			local scfg = _cfg.bone_star(bone.star_lv)
			if scfg then
				for i, at in ipairs(tmp) do
					at[3] = math.floor(at[3]*(1+scfg.rate*0.001))
				end
			end
			_func.combindAttr(attr,tmp)
		else
			_func.combindAttr(attr,bcfg.talent_attr)
		end

		setBoneSuitValue(suitval,BONE_SUIT.STRONG,bone.strong_lv)
		if bone.strong_lv > 0 then
			local strcfg = _cfg.bone_strong_attr(attrtype,bcfg.type,bone.strong_lv)
			if strcfg then
				_func.combindAttr(attr,strcfg.attr)
			end
		end

		for i = 1, 5 do
			local lv = bone["hunsui"..i.."_lv"] or 0
			setBoneSuitValue(suitval,BONE_SUIT.HUNSUI,lv)
			if lv > 0 then
				local atcfg = _cfg.bone_hunsui_attr(i,lv)
				if atcfg then
					_func.combindAttr(attr,atcfg.attr)
				end
			end
		end

		::continue::
	end

	local starrate = 0

	for i, v in ipairs(suitval) do
		local cfg = getBoneSuitCfg(i,v)
		if cfg then
			if cfg.type == 4 then
				starrate = cfg.rate
			else
				_func.combindAttr(attr,cfg.attr)
			end
		end
	end

	local matchnum = 0
	while true do
		local vec = nil
		for id, v in pairs(suitnum) do
			if vec == nil then
				vec = v
			else
				if v[1].order > vec[1].order then
					vec = v
				elseif v[1].order == vec[1].order then
					if v[1].suit_common > 0 then
						vec = v
					elseif vec[1].suit_common == 0 then
						if #v > #vec then
							vec = v
						elseif #v == #vec then
							local tv = _func.get_min_item_key(v,"type",true)
							local tvec = _func.get_min_item_key(vec,"type",true)
							if tv < tvec then
								vec = v
							end
						end
					end
				end
			end
		end

		if vec == nil then
			break
		end
		local suit_id = vec[1].suit_id
		local cfgvec = _cfg.bone_num_suit(suit_id)
		local usesuitnum = 0
		local vecnum = #vec
		if cfgvec then
			local atcfg = nil
			for i, v in ipairs(cfgvec) do
				if v.num > vecnum + matchnum then
					break
				else
					atcfg = v
					usesuitnum = atcfg.num
					if starrate > 0 then
						local temp = table.clone(atcfg.attr)
						for _, v in ipairs(temp) do
							v[3] = math.floor(v[3]*(1+starrate/1000))
						end
						_func.combindAttr(attr,temp)
					else
						_func.combindAttr(attr,atcfg.attr)
					end

					if atcfg.num > vecnum then
						matchnum = matchnum - (atcfg.num - vecnum)
					end
				end
			end
		end
		if vec[1].suit_common > 0 and vecnum > usesuitnum then
			matchnum = matchnum + vecnum - usesuitnum
		end
		suitnum[suit_id] = nil
	end

	return attr
end

function equip_module:getBoneSkillAddon()
	local res = {}
	for k, v in pairs(self._chr_bone) do
		if v.id > 0 then
			local bone = self:getSelfBone(v.id)
			if bone then
				local cfg = _cfg.bone(bone.base)
				if cfg and cfg.skill_level > 0 then
					res[cfg.skill_index] = (res[cfg.skill_index] or 0) + cfg.skill_level
				end
			end
		end
	end
	return res
end

local MAKE_ATTR_LV_ITEM = {
	[1] = 1120,
	[2] = 1121,
}

function equip_module:onMakeEquip(data)
	if #data.i32 < 2 then
		return
	end

	local eid = data.i32[1]
	local num = data.i32[2]
	local mtp = data.i32[3]

	if num <= 0 then
		return
	end

	local cfg = _cfg.equip(eid)
	if cfg == nil then
		return
	end

	local makenum = self:getEquipMakeNum(LIFE_SKILL_TYPE.EQUIP_MAKE,eid)
	if num > 1 and makenum < cfg.make_num then
		return
	end

	local makelv = self:getEquipMakeLv()
	if cfg.make_level > makelv then
		return
	end

	local cost_item = table.clone(cfg.make_item)
	if mtp > 0 then
		cost_item[#cost_item+1] = _func.make_cfg_item_one(MAKE_ATTR_LV_ITEM[mtp],_IT.IT_ITEM,1)
	end

	if num > 1 then
		for i, v in ipairs(cost_item) do
			v[3] = v[3] * num
		end
	end

	local res,bind = self:delBagCheck(cost_item)
	if not res then
		return
	end

	local addchange = _func.make_cfg_item(cfg.id,ITEM_TYPE.IT_EQUIP,num,bind)
	if not self:addBagCheck(addchange) then
		return
	end

	local newchange = {}

	for i = 1, num do
		local equip = _equip_mgr:createUniqueEquip(self.db_serid,eid,self.cid,_cr.CR_MAKE_EQUIP,function (e)
			e.attr_lv = mtp+1
		end)
	
		if equip then
			newchange[#newchange+1] = _func.make_cfg_item_one(equip.id,_IT.IT_INSTANCE_EQUIP,1,bind)
			self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_MAKE_EQUIP_X, cfg.level, 1)
		end
	end

	if makenum < cfg.make_num then
		self:addEquipMakeNum(LIFE_SKILL_TYPE.EQUIP_MAKE,eid)
		if makelv == cfg.make_level then
			self:addEquipMakeSkill(cfg.make_cost)
		end
	end

	self:delBag(cost_item,_cr.CR_MAKE_EQUIP,true,false)
	self:addBag(newchange,_cr.CR_MAKE_EQUIP)
	self:replyMsg(CM.CM_MAKE_EQUIP,ERROR_CODE.ERR_SUCCESS)
end

function equip_module:onEquipStrong(data)
	local eid = data.data
	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local equipcfg = _cfg.equip(equip.base)
	if equipcfg == nil then
		return
	end

	local cfg = _cfg.equip_strong(equipcfg.type,equip.strong_lv + 1)
	if cfg == nil then
		return
	end

	if self:getLevel() < cfg.player_lv or self:getCurrency(CURRENCY_TYPE.CT_JINHUNBI) < cfg.cost then
		return
	end

	if not self:delBagCheck(cfg.cost_item) then
		return
	end

	self:delBag(cfg.cost_item,_cr.CR_EQUIP_STRONG)

	self:addCurrency(CURRENCY_TYPE.CT_JINHUNBI,-cfg.cost,_cr.CR_EQUIP_STRONG)
	equip.strong_lv = equip.strong_lv + 1
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_STRONG)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_EQUIP_STRONG, 0, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_STRENGTH_EQUIP, equip.base, equip.strong_lv)
end

function equip_module:onEquipStrongRecycle(data)
	local eid = data.data
	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local equipcfg = _cfg.equip(equip.base)
	if equipcfg == nil then
		return
	end

	local cfg = _cfg.equip_strong(equipcfg.type,equip.strong_lv)
	if cfg == nil then
		return
	end

	if not self:addBagCheck(cfg.recycle_item) then
		return
	end

	self:addBag(cfg.recycle_item,_cr.CR_EQUIP_STRONG_RECYCLE)

	self:addCurrency(CURRENCY_TYPE.CT_JINHUNBI,cfg.recycle,_cr.CR_EQUIP_STRONG_RECYCLE)
	equip.strong_lv = 0
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_STRONG_RECYCLE)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
end

function equip_module:onEquipJinglian(d)
	local eid = d.data
	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local cfgequip = _cfg.equip(equip.base)
	if cfgequip == nil then
		return
	end

	local cfg = _cfg.equip_jinglian(cfgequip.type,equip.jinglian_lv + 1)
	if cfg == nil or self:getLevel() < cfg.player_lv then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,_cr.CR_EQUIP_JINGLIAN)
	
	local res = 0
	if math.random(100) <= cfg.rate then
		equip.jinglian_lv = cfg.level
		_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_JINGLIAN)
		self:sendOneEquipInfo(equip)
		res = ERROR_CODE.ERR_SUCCESS
	elseif cfg.delv > 0 then
		equip.jinglian_lv = equip.jinglian_lv - 1
		_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_JINGLIAN)
		self:sendOneEquipInfo(equip)
		res = ERROR_CODE.ERR_FAIL
	end

	self:replyMsg(CM.CM_EQUIP_JINGLIAN,res)

	self:checkCalcEquip(eid)
end

function equip_module:onEquipStar(d)
	local eid = d.data
	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local equipcfg = _cfg.equip(equip.base)
	if equipcfg == nil then
		return
	end

	local cfg = _cfg.equip_star(equipcfg.type,equipcfg.order,equip.star + 1)
	if cfg == nil or self:getLevel() < cfg.player_lv then
		return
	end

	if not self:delBagCheck(cfg.cost) then
		return
	end

	self:delBag(cfg.cost,_cr.CR_EQUIP_STAR)
	equip.star = cfg.level
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_STAR)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
end

function equip_module:onEquipStarRecycle(d)
	local eid = d.data
	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local equipcfg = _cfg.equip(equip.base)
	if equipcfg == nil then
		return
	end

	local cfg = _cfg.equip_star(equipcfg.type,equipcfg.order,equip.star)
	if cfg == nil then
		return
	end

	if not self:addBagCheck(cfg.recycle) then
		return
	end

	self:addBag(cfg.recycle,_cr.CR_EQUIP_STAR_RECYCLE)

	equip.star = 0
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_STAR_RECYCLE)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
end

function equip_module:onEquipFulingOn(d)
	local eid = d.equip_id
	local flslot = d.index 	-- 附灵孔
	local flid = d.core_id 		-- 魔核id

	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local flcore = self:getSelfCore(flid)
	if flcore == nil then
		return
	end

	if flcore.equip_id > 0 and self:getSelfEquip(flcore.equip_id) then
		return
	end

	local flcfg = _cfg.core(flcore.base)
	if flcfg == nil then
		return
	end

	-- 判断是否有相同元素
	local oldfl = nil
	local oldcore = nil
	for i = 1, 3 do
		local flid = equip["fuling_"..i]
		if i == flslot then
			oldfl = flid
		else
			if flid > 0 then
				oldcore = self:getSelfCore(flid)
				if oldcore then
					local oflcfg = _cfg.core(oldcore.base)
					if oflcfg and oflcfg.element == flcfg.element then
						return
					end
				end
			end
		end
	end

	-- 没解锁
	if oldfl == nil or oldfl == 0 then
		return
	end

	local update = {flcore}

	flcore.equip_id = eid
	_equip_mgr:updateCore(self.db_serid,flcore,_cr.CR_EQUIP_FULING_ON)
	if oldcore then
		update[#update+1] = oldcore
		oldcore.equip_id = 0
		_equip_mgr:updateCore(self.db_serid,oldcore,_cr.CR_EQUIP_FULING_ON)
	end

	--替换
	equip["fuling_"..flslot] = flid
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_FULING_ON)

	self:sendCoreInfo(update)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_CORE_PUTON, 0, self:getEquipCoreNum(), 1)
end

function equip_module:onEquipFulingOff(d)
	local eid = d.equip_id
	local flslot = d.index 	--附灵孔

	local equip = self:getSelfEquip(eid)
	if equip == nil then
		return
	end

	local flid = equip["fuling_"..flslot]
	if flid == nil or flid <= 0 then
		return
	end

	local flcore = self:getSelfCore(flid)
	if flcore then
		flcore.equip_id = 0
		_equip_mgr:updateCore(self.db_serid,flcore,_cr.CR_EQUIP_FULING_OFF)
		self:sendCoreInfo({flcore})
	end

	equip["fuling_"..flslot] = -1
	_equip_mgr:updateEquip(self.db_serid,equip,_cr.CR_EQUIP_FULING_OFF)
	self:sendOneEquipInfo(equip)
	self:checkCalcEquip(eid)
end

function equip_module:onCoreLevelUp(d)
	if #d.data < 2 then
		return
	end

	local check = {}
	local core = nil
	local cocfg = nil
	local cost = {}
	local exp = 0

	for i, id in ipairs(d.data) do
		if check[id] then
			return
		end
		check[id] = true
		if i == 1 then
			core = self:getSelfCore(id)
			if core == nil then
				return
			end
			cocfg = _cfg.core(core.base)
			if cocfg == nil then
				return
			end
		else
			local mem = self:getSelfCore(id)
			if mem == nil or mem.equip_id > 0 then
				return
			end
			local cfg = _cfg.core(mem.base)
			if cfg == nil or cocfg.element ~= cfg.element then
				return
			end

			local lvcfg = _cfg.core_level(cfg.order,mem.level)
			if lvcfg == nil then
				return
			end

			exp = exp + mem.exp + lvcfg.total_exp
			cost[#cost+1] = _func.make_cfg_item_one(id,_IT.IT_INSTANCE_CORE,1)
		end
	end

	local lvcfg = _cfg.core_level(cocfg.order,core.level + 1)
	if lvcfg == nil then
		return
	end

	self:delBag(cost,_cr.CR_CORE_LEVEL_UP)

	core.exp = core.exp + exp

	while true do
		if lvcfg == nil or lvcfg.exp > core.exp then
			break
		end

		core.level = core.level + 1
		core.exp = core.exp - lvcfg.exp

		lvcfg = _cfg.core_level(cocfg.order,core.level + 1)
	end

	_equip_mgr:updateCore(self.db_serid,core,_cr.CR_CORE_LEVEL_UP)
	self:sendCoreInfo({core})
	if core.equip_id then
		self:checkCalcEquip(core.equip_id)
	end
end

function equip_module:onBoneStrong(d)
	if #d.array <= 0 then
		return
	end

	local boneid = d.i64
	local costcfg = {}
	local exp = 0

	for i, v in ipairs(d.array) do
		costcfg[#costcfg+1] = _func.make_cfg_item_one(v.data1,_IT.IT_ITEM,v.data2)
		if ITEM_EXP[v.data1] == nil then
			return
		end
		exp = exp + ITEM_EXP[v.data1]*v.data2
	end

	local bone = self:getSelfBone(boneid)
	if bone == nil then
		return
	end

	if not self:delBagCheck(costcfg) then
		return
	end

	self:delBag(costcfg,CHANGE_REASON.CR_BONE_STRONG)
	bone.strong_exp = bone.strong_exp + exp

	while true do
		local cfg = _cfg.bone_strong(bone.strong_lv + 1)
		if cfg and bone.strong_exp >= cfg.exp then
			bone.strong_lv = bone.strong_lv + 1
			bone.strong_exp = bone.strong_exp - cfg.exp
		else
			break
		end
	end

	_equip_mgr:updateBone(self.db_serid,bone,CHANGE_REASON.CR_BONE_STRONG)
	self:sendOneBoneInfo(bone)
	self:checkCalcBone(boneid)
end

function equip_module:onBoneJinglian(d)
	local id = d.data
	local bone = self:getSelfBone(id)
	if bone == nil then
		return
	end

	local cfg = _cfg.bone_jinglian(bone.jinglian_lv + 1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_BONE_JINGLIAN)
	bone.jinglian_lv = bone.jinglian_lv + 1

	_equip_mgr:updateBone(self.db_serid,bone,CHANGE_REASON.CR_BONE_JINGLIAN)
	self:sendOneBoneInfo(bone)
	self:checkCalcBone(id)
end

function equip_module:onBoneStar(d)
	local boneid = 0
	local costcfg = {}
	local exp = 0
	local check = {}
	if #d.data < 2 then
		return
	end

	for i, v in ipairs(d.data) do
		if check[v] then
			return
		end
		check[v] = true

		if i == 1 then
			boneid = v
		else
			local b = self:getSelfBone(v)
			if b == nil then
				return
			end

			local bcfg = _cfg.bone(b.base)
			if bcfg == nil then
				return
			end

			exp = exp + bcfg.star_exp

			costcfg[#costcfg+1] = _func.make_cfg_item_one(v,_IT.IT_INSTANCE_BONE,1)
		end
	end

	local bone = self:getSelfBone(boneid)
	if bone == nil then
		return
	end

	if not self:delBagCheck(costcfg) then
		return
	end

	self:delBag(costcfg,CHANGE_REASON.CR_BONE_STAR)

	bone.star_exp = bone.star_exp + exp

	while true do
		local cfg = _cfg.bone_star(bone.star_lv + 1)
		if cfg and bone.star_exp >= cfg.exp then
			bone.star_lv = bone.star_lv + 1
			bone.star_exp = bone.star_exp - cfg.exp
		else
			break
		end
	end

	_equip_mgr:updateBone(self.db_serid,bone,CHANGE_REASON.CR_BONE_STAR)
	self:sendOneBoneInfo(bone)
	self:checkCalcBone(boneid)
end

function equip_module:onBoneHunsui(d)
	local boneid = d.i64
	local id = 0
	local costcfg = {}
	local exp = 0

	for i, v in ipairs(d.array) do
		if i == 1 then
			id = v.data1
		else
			if ITEM_EXP[v.data1] == nil then
				return
			end
			exp = exp + ITEM_EXP[v.data1]*v.data2

			costcfg[#costcfg+1] = _func.make_cfg_item_one(v.data1,_IT.IT_ITEM,v.data2)
		end
	end

	if id < 1 or id > 5 then
		return
	end
	
	local bone = self:getSelfBone(boneid)
	if bone == nil then
		return
	end

	local klv = "hunsui"..id.."_lv"

	if bone[klv] == 0 then
		local cfg = _cfg.bone_hunsui_unlock(id)
		if cfg == nil then
			return
		end

		if not self:delBagCheck(cfg.item) then
			return
		end

		if cfg.need_id > 0 then
			local klv2 = "hunsui"..cfg.need_id.."_lv"
			if cfg.need_lv > bone[klv2] then
				return
			end
		end

		self:delBag(cfg.item,CHANGE_REASON.CR_BONE_HUNSUI)
		bone[klv] = 1
	else
		if not self:delBagCheck(costcfg) then
			return
		end
	
		self:delBag(costcfg,CHANGE_REASON.CR_BONE_HUNSUI)
	
		local kexp = "hunsui"..id.."_exp"
	
		bone[kexp] = bone[kexp] + exp
	
		while true do
			local cfg = _cfg.bone_hunsui(bone[klv] + 1)
			if cfg and bone[kexp] >= cfg.exp then
				bone[klv] = bone[klv] + 1
				bone[kexp] = bone[kexp] - cfg.exp
			else
				break
			end
		end
	end


	_equip_mgr:updateBone(self.db_serid,bone,CHANGE_REASON.CR_BONE_HUNSUI)
	self:sendOneBoneInfo(bone)
	self:checkCalcBone(boneid)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_TGLR_HUNSUI, 0, 1)
end

function equip_module:onBoneOrder(d)
	if #d.data < 2 then
		return
	end

	local check = {}
	local bone = nil
	local costcfg = {}
	local ordercfg = nil

	for i, v in ipairs(d.data) do
		if check[v] then
			return
		end
		check[v] = true

		local b = self:getSelfBone(v)
		if b == nil then
			return
		end

		if i == 1 then
			bone = b
			ordercfg = _cfg.bone_order_upgrade(b.base)
			if ordercfg == nil then
				return
			end
		else
			if b.base ~= ordercfg.cost_id then
				return
			end

			if not _equip_mgr:checkBoneNew(b) then
				return
			end

			costcfg[#costcfg+1] = _func.make_cfg_item_one(v,_IT.IT_INSTANCE_BONE,1)
		end
	end

	if #costcfg ~= ordercfg.cost_num then
		return
	end

	if not self:delBagCheck(costcfg) then
		return
	end

	self:delBag(costcfg,CHANGE_REASON.CR_BONE_ORDER_UP)

	bone.base = ordercfg.next_id

	_equip_mgr:updateBone(self.db_serid,bone,CHANGE_REASON.CR_BONE_STAR)
	self:sendOneBoneInfo(bone)
	self:checkCalcBone(bone.id)

	local bcfg = _cfg.bone(bone.base)
	if bcfg and bcfg.skill_level > 0 and self:checkBonePuton(bone.id) then
		self:updateHunhuanSkill()
	end
end

function equip_module:getEquipCoreNum()
	if table.empty(self._mem_core) then
		return 0
	end
	local num = 0
	for _, v in pairs(self._mem_core) do
		if v.equip_id and v.equip_id > 0 then
			num = num + 1
		end
	end
	return num
end

return equip_module