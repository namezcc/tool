local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _attr_mod = PLAYER_ATTR_SOURCE
local _IT = ITEM_TYPE
local MAX_POSITION_LEVEL = 16


local position_module = {}

function position_module:init()
	MSG_FUNC.bind_player_proto_func(CM.CM_POSITION_LV_UP,self.onPositionLvUp,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_MEDAL_LV_UP,self.onMedalLvUp,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_GET_POSITION_REWARD,self.onGetPositionReward,"ProtoInt32")
end

function position_module:initDB(data)
	local position = nil
	if _func.checkPlayerData(data.position) then
		position = data.position
	else
		position = {
			cid = self.cid,
			pt_level = 0,
			pt_star = 0,
			med_lv = 0,
			pt_exp = 0,
			pt_exp_cur = 0,
		}
	end

	self._position = position
	self:sendPositionInfo()

	self._pt_reward = {}
	if data.position_reward and data.position_reward.cid ~=0 then
		self._pt_reward = data.position_reward
	else 
		self._pt_reward = {
			cid = self.cid,
			get_state = 0,
		}
	end
	self:sendPositionRewardInfo()
end

function position_module:afterInit()
	self:updateModuleAttr(_attr_mod.PAS_POSITION,true)
	self:updateModuleAttr(_attr_mod.PAS_MEDAL,true)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_POSITION, self._position.pt_level, 1, 1)
end

function position_module:sendPositionInfo()
	self:sendMsg(_sm.SM_POSITION_INFO,self._position,"SmPositionInfo")
end

function position_module:sendPositionRewardInfo()
	self:sendMsg(_sm.SM_POSITION_REWARD_INFO,self._pt_reward,"SmPositionRewardInfo")
end

-- function position_module:sendMedalTaskInfo(info)
-- 	local pb = {}
-- 	if info then
-- 		pb[#pb+1] = info
-- 	else
-- 		for k, v in pairs(self._medal_task) do
-- 			pb[#pb+1] = v
-- 		end
-- 	end

-- 	self:sendMsg(_sm.SM_MEDAL_TASK_INFO,{data=pb},"SmMedalTaskInfo")
-- end

function position_module:calcPositionAttr()
	local attr = {}
	local position = self._position
	local cfg_p = _cfg.position(position.pt_level, position.pt_star)
	if cfg_p  then
		_func.combindAttr(attr,cfg_p.attr)
	end
	return attr
end

function position_module:calcMedalAttr()
	local attr = {}
	local position = self._position
	local cfg_p = _cfg.medal(position.med_lv)
	if cfg_p then
		_func.combindAttr(attr,cfg_p.attr)
	end
	return attr
end

-- function position_module:onPositionLvUp(d)
-- 	if #d.i32<3 then
-- 		return
-- 	end
-- 	local count = d.i32[1]
-- 	local itemid = {}
-- 	local num = {}
-- 	if count<1 then
-- 		return
-- 	end
-- 	local n = 1
-- 	for i=1,count do
-- 		itemid[i] = d.i32[i+n]
-- 		num[i] = d.i32[i+n+1]
-- 		n = n + 1
-- 	end

-- 	local position = self._position
-- 	local level = position.pt_level
-- 	local star = position.pt_star
-- 	local bStarUp = false
-- 	local cfg = nil
-- 	if star + 1 == 10 then
-- 		cfg = _cfg.position(level+1, 0)
-- 	else
-- 		bStarUp = true
-- 		cfg = _cfg.position(level, star+1)
-- 	end
	
-- 	if cfg == nil then
-- 		return
-- 	end

-- 	local cost = {}
-- 	local totalexp = 0
-- 	for k, v in ipairs(itemid) do
-- 		local expCfg = _cfg.exp_item(v)
-- 		if expCfg==nil then
-- 			return
-- 		end

-- 		if expCfg.type ~= 9 then
-- 			return
-- 		end

-- 		totalexp = expCfg.exp*num[k]
-- 		cost[#cost+1] = _func.make_cfg_item_one(v,_IT.IT_ITEM,num[k])
-- 	end	

-- 	if not self:delBagCheck(cost) then
-- 		return
-- 	end

-- 	self:delBag(cost,CHANGE_REASON.CR_POSITION_LV_UP)

-- 	position.pt_exp = position.pt_exp + totalexp
-- 	position.pt_exp_cur = position.pt_exp_cur + totalexp

-- 	if position.pt_exp_cur >= cfg.exp then
-- 		if bStarUp then
-- 			position.pt_star = position.pt_star + 1
-- 		else
-- 			position.pt_level = position.pt_level + 1
-- 			position.pt_star = 0
-- 		end
-- 		position.pt_exp_cur = position.pt_exp_cur - cfg.exp
-- 	end
	
-- 	self:sendPositionInfo()
-- 	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_position,position)
-- 	self:updateModuleAttr(_attr_mod.PAS_POSITION)
-- end

function position_module:onPositionLvUp(d)
	if #d.i32<3 then
		return
	end
	local count = d.i32[1]
	local itemid = {}
	local num = {}
	if count<1 then
		return
	end
	local n = 1
	for i=1,count do
		itemid[i] = d.i32[i+n]
		num[i] = d.i32[i+n+1]
		n = n + 1
	end

	local cost = {}
	local totalexp = 0
	for k, v in ipairs(itemid) do
		local expCfg = _cfg.exp_item(v)
		if expCfg==nil then
			return
		end

		if expCfg.type ~= 9 then
			return
		end

		totalexp = totalexp + expCfg.exp*num[k]
		cost[#cost+1] = _func.make_cfg_item_one(v,_IT.IT_ITEM,num[k])
	end	

	if not self:delBagCheck(cost) then
		return
	end

	local position = self._position
	local pt_exp_cur = position.pt_exp_cur + totalexp
	repeat
		local level = position.pt_level
		local star = position.pt_star
		local bStarUp = false
		local cfg = nil
		if star + 1 == 10 or (level==0 and star==0) then
			cfg = _cfg.position(level+1, 0)
		else
			bStarUp = true
			cfg = _cfg.position(level, star+1)
		end

		if cfg==nil then
			return
		end

		if pt_exp_cur >= cfg.exp then
			if bStarUp then
				position.pt_star = position.pt_star + 1
			else
				position.pt_level = position.pt_level + 1
				position.pt_star = 0
			end
			pt_exp_cur = pt_exp_cur - cfg.exp
		end
	until(pt_exp_cur < cfg.exp or position.pt_level>=MAX_POSITION_LEVEL)

	position.pt_exp = position.pt_exp + totalexp
	position.pt_exp_cur = pt_exp_cur;

	self:delBag(cost,CHANGE_REASON.CR_POSITION_LV_UP)

	self:sendPositionInfo()
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_position,position)
	self:updateModuleAttr(_attr_mod.PAS_POSITION)
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_POSITION, position.pt_level, 1, 1)
	self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_POSITION, position.pt_level, 1, 1)
end

function position_module:onMedalLvUp()
    local position = self._position
	
	local cfg_p = _cfg.position(position.pt_level, position.pt_star)
	if cfg_p == nil then
		return
	end
	local level = position.med_lv

	if level >= cfg_p.medal_lv then
		return
	end

	local cfg = _cfg.medal(level+1)
	if cfg == nil then
		return
	end

	if not self:delBagCheck(cfg.item) then
		return
	end

	-- if not self:addBagCheck(cfg.reward) then
	-- 	return
	-- end

	self:delBag(cfg.item,CHANGE_REASON.CR_MEDAL_LV_UP)
	--self:addBag(cfg.reward,CHANGE_REASON.CR_MEDAL_LV_UP)

	position.med_lv = position.med_lv + 1

	self:sendPositionInfo()
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_position,position)
	self:updateModuleAttr(_attr_mod.PAS_MEDAL)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_MEDAL,0,position.med_lv,1)
end

-- function position_module:onGetMedalReward(d)
-- 	local med_lv = d.i32[1]
-- 	local index = d.i32[2] --index从1开始

-- 	local cfg_m = _cfg.medal(med_lv)
-- 	if cfg_m == nil then
-- 		return
-- 	end
-- 	if #cfg_m.tids < index then
-- 		return
-- 	end

-- 	local tid = cfg_m.tids[index]
-- 	local cfg = _cfg.medal_task(tid)
-- 	if cfg == nil then
-- 		return
-- 	end

-- 	local medal_task = self._medal_task[cfg.id]
-- 	if medal_task==nil then
-- 		return
-- 	end

-- 	if medal_task.state ~= TASK_STATE.TSTATE_DONE then
-- 		return
-- 	end
	
-- 	if not self:addBagCheck(cfg.reward) then
-- 		return
-- 	end

-- 	self:addBag(cfg.reward,CHANGE_REASON.CR_MEDAL_LV_UP)
-- 	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_medal_task,medal_task)
-- 	self:sendMedalTaskInfo(medal_task)
-- end

function position_module:onGetPositionReward(d)
	local level = d.i32 --level从1开始
	if level < 1 or level > MAX_POSITION_LEVEL then
		return
	end

	local pt_reward = self._pt_reward
	--是否已领取
    local state = pt_reward.get_state
    if _func.is_bit_on(state,level+1) then
        return
    end

	local cfg = _cfg.position_reward(level)
	if cfg == nil then
		return
	end

	local position = self._position
	if position.pt_level < level then
		return
	end
	
	if not self:addBagCheck(cfg.reward) then
		return
	end

	self:addBag(cfg.reward,CHANGE_REASON.CR_POSITION_LV_UP)
	state=_func.set_bit_on(state,level+1)
    pt_reward.get_state = state
	
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_position_reward,pt_reward)
	self:sendPositionRewardInfo(pt_reward)
end

function position_module:updataMedalTaskProgress(tid,step)
	step = step or 1
	local cfg = _cfg.medal_task(tid)
	if cfg == nil then
		return
	end

	local medal_task = self._medal_task[tid]
	if medal_task==nil then
		return
	end
	
	if medal_task.progress >= cfg.progress then
		medal_task.state = TASK_STATE.TSTATE_DONE
	else
		medal_task.progress = medal_task.progress + step
	end
	
end

return position_module