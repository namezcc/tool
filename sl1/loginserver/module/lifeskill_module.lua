local _cfg = CFG_DATA
local _sm = SM
local _table = TABLE_INDEX
local _func = LFUNC
local _equip_mgr = nil

LIFE_SKILL_TYPE = {
	EQUIP_MAKE = 1,
	LIANZHI = 2,		--炼制
	LIANJIN = 3,		--炼金
	COOK = 4,			--烹饪
	ITEM_MAKE = 5,		--制造
	FISH = 6,			--钓鱼
}

local SKILL_LV_FIELD = {
	[1] = "equip_lv",
	[2] = "lianzhi_lv",
	[3] = "lianjin_lv",
	[4] = "cook_lv",
	[5] = "item_make_lv",
	[6] = "fish_lv",
}

local SKILL_EXP_FIELD = {
	[1] = "equip_exp",
	[2] = "lianzhi_exp",
	[3] = "lianjin_exp",
	[4] = "cook_exp",
	[5] = "item_make_exp",
	[6] = "fish_exp",
}

local lifeskill_module = {}

function lifeskill_module:init()

	_equip_mgr = MOD.equip_mgr_module
	
	MSG_FUNC.bind_async_player_proto(CM.CM_FISH,self.onFish,"PInt64Array")

end

function lifeskill_module:initDB(data)
	if _func.checkPlayerData(data.lifeskill) then
		self._lifeskill = data.lifeskill
	else
		-- 需要初始化
		self._lifeskill = {
			cid = self.cid,
			equip_lv = 1,
			equip_exp = 0,
			lianzhi_lv = 1,
			lianzhi_exp = 0,
			lianjin_lv = 1,
			lianjin_exp = 0,
			cook_lv = 1,
			cook_exp = 0,
			item_make_lv = 1,
			item_make_exp = 0,
			fish_lv = 1,
			fish_exp = 0,
		}
	end
end

function lifeskill_module:afterInit()

	self:sendLifeskill()
end

function lifeskill_module:sendLifeskill()
	self:sendMsg(_sm.SM_LIFESKILL_INFO,self._lifeskill,"SmLifeSkill")
end

function lifeskill_module:getLifeSkillLv(type)
	return self._lifeskill[SKILL_LV_FIELD[type]] or 0
end

function lifeskill_module:getEquipMakeLv()
	return self._lifeskill.equip_lv
end

function lifeskill_module:addLifeSkillExp(type,val)
	local ls = self._lifeskill
	local flv = SKILL_LV_FIELD[type]
	local fexp = SKILL_EXP_FIELD[type]

	local cfg = _cfg.life_skill(type,ls[flv]+1)
	if cfg == nil then
		return
	end

	ls[fexp] = ls[fexp] + val
	if ls[fexp] >= cfg.exp then
		ls[flv] = ls[flv] + 1
		ls[fexp] = ls[fexp] - cfg.exp

		if type == LIFE_SKILL_TYPE.COOK then
			self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_COOK_LEVEL, 0, ls[flv], 1)
		elseif type == LIFE_SKILL_TYPE.LIANZHI then
			self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_LIANYAO_LV, 0, ls[flv], 1)
		elseif type == LIFE_SKILL_TYPE.EQUIP_MAKE then
			self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_MAKE_EQUIP_LV, 0, ls[flv], 1)
		end
	end
	self:sendLifeskill()
	self:dbUpdateData(_table.TAB_mem_chr_lifeskill,ls)

end

function lifeskill_module:addEquipMakeSkill(val)
	self:addLifeSkillExp(LIFE_SKILL_TYPE.EQUIP_MAKE,val)
end

function lifeskill_module:onFish(d,coro)
	if #d.data < 4 then
		return
	end

	local group = d.data[1]
	local fishrodid = d.data[2]
	local bugid = d.data[3]
	local res = d.data[4]

	local memrod = self:getSelfItem(fishrodid)
	if memrod == nil then
		return
	end

	local cost = _func.make_cfg_item(bugid,ITEM_TYPE.IT_ITEM,1)
	if not self:delBagCheck(cost) then
		return
	end

	-- 检查位置


	memrod.extra = memrod.extra + 1
	local itemcfg = _cfg.item(memrod.base)
	local bugcfg = _cfg.item(bugid)
	if itemcfg == nil or bugcfg == nil then
		return
	end
	if memrod.extra >= itemcfg.effect[1] then
		cost[#cost+1] = _func.make_cfg_item_one(memrod.id,ITEM_TYPE.IT_INSTANCE_ITEM,1)
		memrod = nil
	end

	if res > 0 then
		-- 成功
		local vec = _cfg.fish_drop(group)
		if vec == nil then
			return
		end

		local fishlv = self:getLifeSkillLv(LIFE_SKILL_TYPE.FISH)
		if fishlv > itemcfg.item_level then
			fishlv = itemcfg.item_level
		end

		local fishvec = {}
		local weight = 0
		for _, v in ipairs(vec) do
			if fishlv >= v.level then
				local fish = table.cloneSimple(v)
				if fish.type == bugcfg.effect[1] then
					fish.weight = fish.weight*bugcfg.effect[2]/100
				end
				weight = weight + fish.weight
				fish.weight = weight
				fishvec[#fishvec+1] = fish
			end
		end

		local fish = _func.rand_weight(vec,"weight")
		local fishcfg = _cfg.item(fish.item_id)
		if fishcfg == nil then
			return
		end

		local reward = _func.make_cfg_item(fishcfg.id,ITEM_TYPE.IT_ITEM,1)
		if not self:addBagCheck(reward) then
			return
		end

		local fishnum = self:getEquipMakeNum(LIFE_SKILL_TYPE.FISH,fishcfg.id)
		if fishnum < fishcfg.effect[1] then
			self:addEquipMakeNum(LIFE_SKILL_TYPE.FISH,fishcfg.id)
			self:addLifeSkillExp(LIFE_SKILL_TYPE.FISH,fishcfg.effect[2])
		end

		self:addBag(reward,CHANGE_REASON.CR_FISH)
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_FISH_NUM, 0, 1)
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_FISH_NUM,0,1)
	end

	if memrod then
		_equip_mgr:updateMemCommon(self.db_serid,memrod,CHANGE_REASON.CR_FISH)
	end
	self:delBag(cost,CHANGE_REASON.CR_FISH)
end

return lifeskill_module