local _string = STRING_UTIL
local _sm = SM
local _table = TABLE_INDEX
local _func = LFUNC
local _IT = ITEM_TYPE
local _cfg = CFG_DATA
local _attr_mod = PLAYER_ATTR_SOURCE

local ITEM_EXP = _ITEM_EXP

local wing_module = {}

function wing_module:init()

	MSG_FUNC.bind_player_proto_func(CM.CM_WING_STRONG,self.onWingStrong,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_WING_ORDER,self.onWingOrder,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_WING_STAR,self.onWingStar,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_WING_FULING,self.onWingFuling,"ProtoInt32")

end

function wing_module:initDB(data)
	local wing = nil
	if _func.checkPlayerData(data.chr_wing) then
		wing = data.chr_wing
	else
		wing = {
			cid = self.cid,
			strong_lv = 0,
			strong_exp = 0,
			order_lv = -1,
			star_lv = 0,
			fuling_lv = "0,0,0,0,0,0,0,0",
		}
	end

	wing.fuling = _string.splite_int_vec(wing.fuling_lv,",")

	self._wing = wing
end

function wing_module:afterInit()
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING,true)

end

function wing_module:afterEnterGame()
	self:loadWingSkill()
end

function wing_module:openWing()
	self._wing.order_lv = 0
	self:dbUpdateData(_table.TAB_mem_chr_wing,self._wing)
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_WING, 1, 1)
end

function wing_module:loadWingSkill()
	local cfg = _cfg.wing_star_skill(self._chr_info.job,self._wing.star_lv)
	local ordercfg = _cfg.wing_order(self._chr_info.job,self._wing.order_lv)

	local buffid = {}
	if cfg and ordercfg then
		for _, id in ipairs(ordercfg.unlock_skill) do
			buffid[#buffid+1] = id
		end
	end
	self:addPlayerBuff(buffid)
end

function wing_module:sendWingInfo()
	self:sendMsg(_sm.SM_WING_INFO,self._wing,"SmWing")
end

function wing_module:calcWingAttr()
	local attr = {}

	local wing = self._wing

	local cfg = _cfg.wing_strong(wing.strong_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	cfg = _cfg.wing_order(self._chr_info.job,wing.order_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	cfg = _cfg.wing_star(self._chr_info.job,wing.star_lv)
	if cfg then
		_func.combindAttr(attr,cfg.attr)
	end

	for id, lv in ipairs(wing.fuling) do
		local flcfg = _cfg.wing_fuling(lv)
		if flcfg then
			cfg = _cfg.wing_fuling_attr(id,flcfg.real_level)
			if cfg then
				_func.combindAttr(attr,cfg.attr)
			end
		end
	end
	return attr
end

function wing_module:onWingStrong(d)
	if #d.i32 == 0 or math.fmod(#d.i32,2) ~= 0 then
		return
	end

	local cost = {}
	local exp = 0

	for i = 1, #d.i32,2 do
		local id = d.i32[i]
		local num = d.i32[i+1]

		if ITEM_EXP[id] == nil then
			return
		end

		exp = exp + ITEM_EXP[id]*num
		cost[#cost+1] = _func.make_cfg_item_one(id,_IT.IT_ITEM,num)
	end

	local wing = self._wing
	if wing.order_lv < 0 then
		return
	end

	local cfg = _cfg.wing_strong(wing.strong_lv+1)
	if cfg == nil or cfg.need_order > wing.order_lv then
		return
	end

	if not self:delBagCheck(cost) then
		return
	end

	self:delBag(cost,CHANGE_REASON.CR_WING_STRONG)
	wing.strong_exp = wing.strong_exp + exp

	while true do
		if cfg.exp > wing.strong_exp then
			break
		end

		wing.strong_lv = wing.strong_lv + 1
		wing.strong_exp = wing.strong_exp - cfg.exp

		cfg = _cfg.wing_strong(wing.strong_lv+1)

		if cfg == nil or cfg.need_order > wing.order_lv then
			break
		end
	end

	self:dbUpdateData(_table.TAB_mem_chr_wing,wing)
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING)
end

function wing_module:onWingOrder(d)
	
	local wing = self._wing
	if wing.order_lv < 0 then
		return
	end

	local cfg = _cfg.wing_order(self._chr_info.job,wing.order_lv+1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_WING_ORDER)
	wing.order_lv = wing.order_lv + 1

	self:dbUpdateData(_table.TAB_mem_chr_wing,wing)
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WING_ORDER, 0, 1)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_WING_TUPO, wing.order_lv, 1)
end

function wing_module:onWingStar(d)
	local wing = self._wing
	if wing.order_lv < 0 then
		return
	end

	local cfg = _cfg.wing_star(self._chr_info.job,wing.star_lv+1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_WING_STAR)

	wing.star_lv = wing.star_lv + 1
	self:dbUpdateData(_table.TAB_mem_chr_wing,wing)
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING)

	cfg = _cfg.wing_star_skill(self._chr_info.job,wing.star_lv)
	local ordercfg = _cfg.wing_order(self._chr_info.job,wing.order_lv)
	
	if cfg and ordercfg then
		local arr = {}
		for _, id in ipairs(ordercfg.unlock_skill) do
			arr[#arr+1] = id
		end
		self:addPlayerBuff(arr)
	end
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WING_STAR, 0, 1)
end

function wing_module:onWingFuling(d)
	local id = d.i32
	local wing = self._wing
	if wing.order_lv < 0 then
		return
	end

	local cfg = _cfg.wing_fuling(wing.fuling[id]+1)
	
	if cfg == nil or cfg.need_order > wing.order_lv then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	self:delBag(cfg.item,CHANGE_REASON.CR_WING_FULING)

	wing.fuling[id] = wing.fuling[id]+1
	wing.fuling_lv = table.concat(wing.fuling,",")

	self:dbUpdateData(_table.TAB_mem_chr_wing,wing)
	self:sendWingInfo()
	self:updateModuleAttr(_attr_mod.PAS_WING)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_WING_FULING, 0, 1)
end

return wing_module