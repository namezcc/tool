local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _IT = ITEM_TYPE
local _attr_mod = PLAYER_ATTR_SOURCE
local _equip_mgr = nil

local ITEM_EXP = _ITEM_EXP

local wuhun_module = {}

function wuhun_module:init()
	
	_equip_mgr = MOD.equip_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_WUHUN_STRONG,self.onWuhunStrong,"ProtoPairInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_WUHUN_JINGHUA,self.onWuhunJinghua,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_WUHUN_JUEXING,self.onWuhunJuexing,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_HUNQI_STRONG,self.onHunqiStrong,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_HUNQI_GOD_ATTR,self.onHunqiGodAttr,"PInt64")

end

function wuhun_module:initDB(data)
	
	if _func.checkPlayerData(data.wuhun) then
		self._wuhun = data.wuhun
	else
		self._wuhun = {
			cid = self.cid,
			strong_lv = 0,
			strong_exp = 0,
			jinghua_lv = 0,
			juexing_lv = 0,
		}
	end

	self:sendWuhunInfo()
end

function wuhun_module:afterInit()
	self:updateModuleAttr(_attr_mod.PAS_WUHUN,true)
end

function wuhun_module:sendWuhunInfo()
	self:sendMsg(_sm.SM_WUHUN_INFO,self._wuhun,"SmWuhunInfo")
end

function wuhun_module:updateWuhunDB()
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_wuhun,self._wuhun)
end

function wuhun_module:calcWuhunAttr()
	local attr = {}
	local job = self._chr_info.job
	local suitnum = {}

	for k, v in pairs(self._chr_hunqi) do
		local hunqi = self:getSelfHunqi(v.id)
		if hunqi == nil then
			goto continue
		end

		local hqcfg = _cfg.hunqi(hunqi.base)
		if hqcfg then
			suitnum[hqcfg.suitid] = (suitnum[hqcfg.suitid] or 0) + 1

			local lvcfg = _cfg.hunqi_level(hunqi.level)

			local basecfg = _cfg.hunqi_base_attr(hqcfg.type)[hunqi.base_attr_index]
			if basecfg then
				local baseattr = table.clone(basecfg.attr)
				for i, vec in ipairs(baseattr) do
					vec[3] = hqcfg.base_attr_value
				end

				if lvcfg then
					for i, vec in ipairs(baseattr) do
						vec[3] = vec[3] + lvcfg.base_attr_value
					end
				end
				_func.combindAttr(attr,baseattr)
			end
		end

		for i, id in ipairs(hunqi.attr) do
			local strongcfg = _cfg.hunqi_strong_attr_level(id,hunqi.level)
			if strongcfg then
				_func.combindAttr(attr,strongcfg)
			end
		end

		if hunqi.god_attr > 0 then
			local godcfg = _cfg.hunqi_god_attr(hunqi.god_attr)
			if godcfg then
				_func.combindAttr(attr,godcfg)
			end
		end
		::continue::
	end

	local attrrate = {}
	for sid, num in pairs(suitnum) do
		local vec = _cfg.hunqi_suit(sid)
		if vec then
			local suitcfg = nil
			for _, scfg in ipairs(vec) do
				if num >= scfg.num then
					suitcfg = scfg
				else
					break
				end
			end
			if suitcfg then
				_func.combindAttr(attr,suitcfg.attr)

				for _, rate in ipairs(suitcfg.attrrate) do
					local at = rate[1]
					if attrrate[at] then
						attrrate[at] = attrrate[at] + rate[2]
					else
						attrrate[at] = rate[2]
					end
				end
			end
		end
	end

	for at, rate in pairs(attrrate) do
		local atab = attr[at]
		if atab and atab[1] ~= nil then
			atab[1] = math.floor(rate*0.0001*atab[1])
		end
	end

	local cfg = _cfg.wuhun(job)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	cfg = _cfg.wuhun_jinhua(job,self._wuhun.jinghua_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	cfg = _cfg.wuhun_juexing(job,self._wuhun.juexing_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	cfg = _cfg.wuhun_strong(job,self._wuhun.strong_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	return attr
end

function wuhun_module:onWuhunStrong(data)
	local costcfg = {}
	local exp = 0

	for i, v in ipairs(data.list) do
		costcfg[#costcfg+1] = _func.make_cfg_item_one(v.data1,_IT.IT_ITEM,v.data2)
		if ITEM_EXP[v.data1] == nil then
			return
		end
		exp = exp + ITEM_EXP[v.data1]*v.data2
	end

	if not self:delBagCheck(costcfg) then
		return
	end

	self:delBag(costcfg,CHANGE_REASON.CR_WUHUN_STRONG)

	local wuhun = self._wuhun
	wuhun.strong_exp = wuhun.strong_exp + exp

	while true do
		local cfg = _cfg.wuhun_strong(self._chr_info.job,wuhun.strong_lv + 1)
		if cfg and wuhun.strong_exp >= cfg.needexp then
			wuhun.strong_lv = wuhun.strong_lv + 1
			wuhun.strong_exp = wuhun.strong_exp - cfg.needexp
		else
			break
		end
	end

	self:sendWuhunInfo()
	self:updateWuhunDB()
	self:updateModuleAttr(_attr_mod.PAS_WUHUN)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WUHUN_STRONG, 0, 1)
end

function wuhun_module:onWuhunJinghua()
	local wh = self._wuhun
	local cfg = _cfg.wuhun_jinhua(self._chr_info.job,wh.jinghua_lv + 1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_WUHUN_JINGHUA)

	wh.jinghua_lv = wh.jinghua_lv + 1
	
	self:sendWuhunInfo()
	self:updateWuhunDB()
	self:updateModuleAttr(_attr_mod.PAS_WUHUN)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WUHUN_JINHUA, 0, 1)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_WUHUN_JINHUA, wh.jinghua_lv, 1)
end

function wuhun_module:onWuhunJuexing()
	local wh = self._wuhun
	local cfg = _cfg.wuhun_juexing(self._chr_info.job,wh.juexing_lv + 1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_WUHUN_JUEXING)

	wh.juexing_lv = wh.juexing_lv + 1
	
	self:sendWuhunInfo()
	self:updateWuhunDB()
	self:updateModuleAttr(_attr_mod.PAS_WUHUN)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WUHUN_JUEXING, 0, 1)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_WUHUN_JUEXING, wh.juexing_lv, 1, 1)
end

function wuhun_module:onHunqiStrong(d)
	local mdata = nil
	local mat = {}
	local totalexp = 0
	local delvec = {}

	for i, mid in ipairs(d.data) do
		if i == 1 then
			mdata = _equip_mgr:getMemCommon(mid)
			if mdata == nil then
				return
			end
		else
			if mat[mid] then
				return
			end
			mat[mid] = true

			local mem = _equip_mgr:getMemCommon(mid)
			if mem == nil then
				return
			end

			local cfg = _cfg.hunqi_level(mem.level)
			if cfg == nil then
				return
			end
			totalexp = totalexp + cfg.total_exp + mem.exp
			delvec[#delvec+1] = _func.make_cfg_item_one(mid,_IT.IT_INSTANCE_HUNQI,1)
		end
	end

	local hqcfg = _cfg.hunqi(mdata.base)
	if hqcfg == nil or mdata.level >= hqcfg.max_level then
		return
	end

	mdata.exp = mdata.exp + totalexp
	local lvChange = 0
	while true do
		if mdata.level >= hqcfg.max_level then
			break
		end

		local cfg = _cfg.hunqi_level(mdata.level + 1)
		if cfg == nil or mdata.exp < cfg.exp then
			break
		end
		mdata.level = mdata.level + 1
		mdata.exp = mdata.exp - cfg.exp
		lvChange = lvChange + 1

		local rid = _equip_mgr:randHunqiAttr(hqcfg.type,hqcfg.attr_type,mdata)
		if rid then
			mdata.attr[#mdata.attr+1] = rid
		end
	end
	
	self:delBag(delvec,CHANGE_REASON.CR_HUNQI_STRONG,true)
	_equip_mgr:updateMemCommon(self.db_serid,mdata,CHANGE_REASON.CR_HUNQI_STRONG)
	self:sendHunqiInfo({mdata})
	if lvChange > 0 then
		if self:checkInPuton(_IT.IT_INSTANCE_HUNQI) then
			self:updateModuleAttr(_attr_mod.PAS_WUHUN)
		end

		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_HUNQI_UPGRADE, 0, lvChange)
	end
end

function wuhun_module:onHunqiGodAttr(d)
	local mem = self:getSelfHunqi(d.data)
	if mem == nil or mem.god_attr > 0 then
		return
	end

	local hqcfg = _cfg.hunqi(mem.base)
	if hqcfg == nil then
		return
	end

	local cfg = _cfg.hunqi_master_attr(hqcfg.type,hqcfg.qulity,1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.cost_item) then
		return
	end

	self:delBag(cfg.cost_item,CHANGE_REASON.CR_HUNQI_GOD_ATTR)
	mem.god_attr = cfg.godid
	_equip_mgr:updateMemCommon(self.db_serid,mem,CHANGE_REASON.CR_HUNQI_GOD_ATTR)
	self:sendHunqiInfo({mem})

	if self:checkInPuton(_IT.IT_INSTANCE_HUNQI) then
		self:updateModuleAttr(_attr_mod.PAS_WUHUN)
	end
end

return wuhun_module