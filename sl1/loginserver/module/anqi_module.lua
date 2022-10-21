local _cfg = CFG_DATA
local _cr = CHANGE_REASON
local _table = TABLE_INDEX
local _IT = ITEM_TYPE
local _func = LFUNC
local _sm = SM
local _str_tool = STRING_UTIL
local _attr_mod = PLAYER_ATTR_SOURCE

--强化
local ITEM_EXP = _ITEM_EXP

local anqi_module = {}

function anqi_module:init()

	MSG_FUNC.bind_player_proto_func(CM.CM_ANQI_STRONG,self.onAnqiStrong,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_ANQI_ORDER_UP,self.onAnqiOrderUp,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_ANQI_SKILL_UP,self.onAnqiSkillUp,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_ANQI_JINGLIAN,self.onAnqiJinglian,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_ANQI_STAR_UP,self.onAnqiStarUp,"ProtoInt32Array")

end

function anqi_module:initDB(d)
	local anqi = {}
	if d.anqi then
		for k, v in pairs(d.anqi) do
			local info = table.cloneSimple(v)
			anqi[info.id] = info
		end
	end
	self._anqi = anqi
end

function anqi_module:afterInit()
	
	self:sendAnqiInfo()
end

function anqi_module:loadAnqiSkill(pbdata)
	local skillinfo = pbdata.skill_level_info

	for k, v in pairs(self._anqi) do
		local cfg = _cfg.anqi(k)
		if cfg then
			for i, id in ipairs(cfg.skillid) do
				skillinfo[#skillinfo+1] = {skill_id = id,level = v.skill_lv}
			end
		end
	end
end

local ANQI_SUIT = {
	ANQI = 1,
	STRONG = 2,
	JINGLIAN = 3,
	STAR = 4,
}

local function setAnqiSuitValue(tab,type,qua,val)
	info = table.getOrNewTable(tab,type)
	info = table.getOrNewTable(info,qua,{num = 0,val = 999})

	info.num = info.num + 1
	if val < info.val then
		info.val = val
	end
end

local function getAnqiSuitCfg(type,qua,info)
	local vec = _cfg.anqi_suit(type,qua)
	if vec == nil then
		return
	end
	local cfg = nil
	for i, v in ipairs(vec) do
		if v.num > info.num or v.level > info.val then
			break
		else
			cfg = v
		end
	end
	return cfg
end

function anqi_module:calcAnqiAttr()
	local attr = {}
	local suitval = {}

	for id, v in pairs(self._anqi) do
		local cfg = _cfg.anqi(id)
		if cfg == nil then
			goto continue
		end

		setAnqiSuitValue(suitval,ANQI_SUIT.ANQI,cfg.qulity,1)

		local rate = 0

		if v.star_lv > 0 then
			setAnqiSuitValue(suitval,ANQI_SUIT.STAR,cfg.qulity,v.star_lv)
			local atcfg = _cfg.anqi_star(id,v.star_lv)
			if atcfg then
				rate = rate + atcfg.rate
			end
		end

		if v.jinglian_lv > 0 then
			setAnqiSuitValue(suitval,ANQI_SUIT.JINGLIAN,cfg.qulity,v.jinglian_lv)
			local atcfg = _cfg.anqi_jinglian(id,v.jinglian_lv)
			if atcfg then
				rate = rate + atcfg.rate
			end
		end

		if rate > 0 then
			local temp = table.clone(cfg.attr)
			for _, vec in ipairs(temp) do
				vec[3] = math.floor(vec[3]*(1+rate/1000))
			end
			_func.combindAttr(attr,temp)
		else
			_func.combindAttr(attr,cfg.attr)
		end


		if v.strong_lv > 0 then
			setAnqiSuitValue(suitval,ANQI_SUIT.STRONG,cfg.qulity,v.strong_lv)
			local atcfg = _cfg.anqi_strong(id,v.strong_lv)
			if atcfg then
				_func.combindAttr(attr,atcfg.attr)
			end
		end

		

		if v.order_lv > 0 then
			local atcfg = _cfg.anqi_order(id,v.order_lv)
			if atcfg then
				_func.combindAttr(attr,atcfg.attr)
			end
		end

		::continue::
	end

	for type, qvec in pairs(suitval) do
		for qua, info in pairs(qvec) do
			local cfg = getAnqiSuitCfg(type,qua,info)
			if cfg then
				_func.combindAttr(attr,cfg.attr)
			end
		end
	end
	
	return attr
end

function anqi_module:sendAnqiInfo(info)
	local pb = {}
	if info then
		pb[#pb+1] = info
	else
		for k, v in pairs(self._anqi) do
			pb[#pb+1] = v
		end
	end
	self:sendMsg(_sm.SM_ANQI_INFO,{data=pb},"SmAnqiInfo")
end

function anqi_module:haveAnqi(id)
	return self._anqi[id] ~= nil
end

function anqi_module:anqiActive(id)
	if self._anqi[id] then
		return
	end
	local anqi = {
		cid = self.cid,
		id = id,
		strong_lv = 0,
		strong_exp = 0,
		order_lv = 0,
		order_exp = 0,
		skill_lv = 1,
		jinglian_lv = 0,
		star_lv = 0,
		star_exp = 0,
	}
	self._anqi[id] = anqi
	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_ANQI_NUM, 0, 1)
	local icfg = _cfg.anqi(id)
	if icfg then
		if icfg.qulity then
			self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_ANQI_ACTIVE, icfg.qulity, 1)
		end
		local skillvec = {}
		for i, sid in ipairs(icfg.skillid) do
			skillvec[#skillvec+1] = {sid,anqi.skill_lv}
		end
		self:updateSkillList(skillvec)
	end
end

function anqi_module:onAnqiStrong(d)
	local id = d.i32[1]
	local cost = {}

	local totalexp = 0

	for i = 2, #d.i32,2 do
		local itemid = d.i32[i]
		local num = d.i32[i+1]
		if ITEM_EXP[itemid] == nil then
			return
		end
		totalexp = ITEM_EXP[itemid]*num
		cost[#cost+1] = _func.make_cfg_item_one(itemid,_IT.IT_ITEM,num)
	end

	local anqi = self._anqi[id]
	if anqi == nil then
		return
	end

	if self:delBagCheck(cost) == false then
		return
	end

	local cfg = _cfg.anqi_strong(id,anqi.strong_lv+1)
	if anqi.order_lv < cfg.order_lv then
		return
	end

	self:delBag(cost,_cr.CR_ANQI_STRONG)

	anqi.strong_exp = anqi.strong_exp + totalexp

	while true do
		if cfg == nil or anqi.strong_exp < cfg.exp or anqi.order_lv < cfg.order_lv then
			break
		end

		anqi.strong_lv = anqi.strong_lv + 1
		anqi.strong_exp = anqi.strong_exp - cfg.exp

		cfg = _cfg.anqi_strong(id,anqi.strong_lv+1)
	end

	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
end

function anqi_module:onAnqiOrderUp(d)
	local id = d.i32[1]
	local cost = {}

	local totalexp = 0
	for i = 2, #d.i32,2 do
		local itemid = d.i32[i]
		local num = d.i32[i+1]
		if ITEM_EXP[itemid] == nil then
			return
		end
		totalexp = ITEM_EXP[itemid]*num
		cost[#cost+1] = _func.make_cfg_item_one(itemid,_IT.IT_ITEM,num)
	end

	local anqi = self._anqi[id]
	if anqi == nil then
		return
	end

	if self:delBagCheck(cost) == false then
		return
	end

	self:delBag(cost,_cr.CR_ANQI_ORDER_UP)

	anqi.order_exp = anqi.order_exp + totalexp
	local lvChange = 0

	while true do
		local cfg = _cfg.anqi_order(id,anqi.order_lv+1)
		if cfg == nil or anqi.order_exp < cfg.exp then
			break
		end

		anqi.order_lv = anqi.order_lv + 1
		anqi.order_exp = anqi.order_exp - cfg.exp
		lvChange = lvChange + 1
	end

	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
	if lvChange > 0 then
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_ANQI_CUILIAN, 0, lvChange)
	end
end

function anqi_module:onAnqiSkillUp(d)
	local id = d.i32
	local anqi = self._anqi[id]
	if anqi == nil then
		return
	end

	local aqcfg = _cfg.anqi(id)
	if aqcfg == nil then
		return
	end

	local cfg = _cfg.anqi_skill(id,anqi.skill_lv+1)
	if cfg == nil or anqi.order_lv < cfg.order_lv then
		return
	end

	if self:delBagCheck(cfg.cost) == false then
		return
	end

	self:delBag(cfg.cost,_cr.CR_ANQI_SKILL_UP)

	anqi.skill_lv = anqi.skill_lv + 1

	local skillvec = {}
	for i, sid in ipairs(aqcfg.skillid) do
		skillvec[#skillvec+1] = {sid,anqi.skill_lv}
	end
	self:updateSkillList(skillvec)

	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_ANQI_SKILL, 0, 1)
end

function anqi_module:onAnqiJinglian(d)
	local id = d.i32[1]
	local anqi = self._anqi[id]
	if anqi == nil then
		return
	end

	local cfg = _cfg.anqi_jinglian(id,anqi.jinglian_lv + 1)
	if cfg == nil then
		return
	end

	if self:delBagCheck(cfg.cost) == false then
		return
	end

	self:delBag(cfg.cost,_cr.CR_ANQI_JINGLIAN)
	anqi.jinglian_lv = cfg.level
	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_ANQI_JINGLIAN, 0, 1)
end

function anqi_module:onAnqiStarUp(d)
	local id = d.i32[1]
	local itemid = d.i32[2]
	local num = d.i32[3]
	local cost = {}

	local aqcfg = _cfg.anqi(id)
	if aqcfg == nil or aqcfg.star_id ~= itemid then
		return
	end

	local totalexp = 500*num
	cost[#cost+1] = _func.make_cfg_item_one(itemid,_IT.IT_ITEM,num)

	local anqi = self._anqi[id]
	if anqi == nil then
		return
	end

	if self:delBagCheck(cost) == false then
		return
	end

	local cfg = _cfg.anqi_star(id,anqi.star_lv+1)
	if cfg == nil then
		return
	end

	self:delBag(cost,_cr.CR_ANQI_STAR)

	anqi.star_exp = anqi.star_exp + totalexp

	while true do
		if cfg == nil or anqi.star_exp < cfg.exp then
			break
		end

		anqi.star_lv = anqi.star_lv + 1
		anqi.star_exp = anqi.star_exp - cfg.exp

		cfg = _cfg.anqi_star(id,anqi.star_lv+1)
	end

	self:dbUpdateData(_table.TAB_mem_chr_anqi,anqi)
	self:sendAnqiInfo(anqi)
	self:updateModuleAttr(_attr_mod.PAS_ANQI)
end

return anqi_module