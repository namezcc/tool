local _cfg = CFG_DATA
local _record = RECORD_TYPE
local _func = LFUNC
local _table = TABLE_INDEX
local _net_mgr = nil

local active_common_module = {}

function active_common_module:init()

	_net_mgr = MOD.net_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_DRAW_CARD,self.onDrawCard,"ProtoInt32Array")

end

function active_common_module:initDB(d)
	local drow_item = {}
	for _, v in ipairs(d.drow_item) do
		local tab = table.getOrNewTable(drow_item,v.type)
		tab[v.itemid] = v
	end
	self._drow_item = drow_item
end

function active_common_module:afterInit()
	

	self:sendDrawInfo()
end

function active_common_module:checkFirstDrow(type,itemid,uptab)
	local drow = table.getOrNewTable(self._drow_item,type)
	if drow[itemid] then
		return 0
	else
		local info = {
			cid = self.cid,
			type = type,
			itemid = itemid,
		}
		uptab[#uptab+1] = info
		drow[info.itemid] = info
		return 1
	end
end

function active_common_module:sendDrawInfo()
	local pb = {}
	for i = 1, 5 do
		pb[#pb+1] = self:getRecord(_record.RT_DRAW_COUNT_BEGIN+i)
	end
	for i = 1, 5 do
		pb[#pb+1] = self:getRecord(_record.RT_DRAW_UP_COUNT_BEGIN+i)
	end
	self:sendMsg(SM.SM_DRAW_COUNT,{i32=pb},"ProtoInt32Array")
end

local function draw_group(id)
	local cfgvec = _cfg.draw_group(id)
	local cfg = _func.rand_weight(cfgvec,"weight")
	return table.cloneSimple(cfg.reward[1])
end

function active_common_module:draw_up_group(cfg,upgroup)
	local fixnum = self:getRecord(_record.RT_DRAW_UP_FIX_BEGIN+cfg.id)
	local v = nil
	if fixnum >= cfg.fix_num then
		v = draw_group(upgroup)
		self:updateRecord(_record.RT_DRAW_UP_FIX_BEGIN+cfg.id,0)
	else
		if math.random(100) < 50 then
			v = draw_group(upgroup)
			self:updateRecord(_record.RT_DRAW_UP_FIX_BEGIN+cfg.id,0)
		else
			v = draw_group(cfg.group)
			self:updateRecord(_record.RT_DRAW_UP_FIX_BEGIN+cfg.id,fixnum+1)
		end
	end
	return v
end

local DRAW_COST_GOLD = 100

function active_common_module:onDrawCard(d)
	if #d.i32 ~= 3 then
		return
	end

	local activeid = d.i32[1]
	local poolid = d.i32[2]
	local num = d.i32[3]

	if num ~= 1 and num ~= 10 then
		return
	end

	local bindinfo = {}
	local itemid = activeid == 0 and ITEM_ID.II_DRAW_CARD_ITEM or ITEM_ID.II_DRAW_UP_CARD_ITEM
	local costitem = {itemid,ITEM_TYPE.IT_ITEM,0}
	local costconf = nil
	local ibind = self:getItemNum(itemid)
	if ibind > 0 then
		local unum = ibind >= num and num or ibind
		for i = 1, unum do
			bindinfo[#bindinfo+1] = true
		end
		num = num - unum
	end

	costitem[3] = #bindinfo

	if num == 0 then
		num = #bindinfo
	else
		--扣钱
		costconf = self:checkCostGold(num*DRAW_COST_GOLD)
		if costconf == nil then
			return
		end
		for i = 1, num do
			if i*DRAW_COST_GOLD > costconf.gold_unbind then
				bindinfo[#bindinfo+1] = true
			else
				bindinfo[#bindinfo+1] = false
			end
		end
	end

	num = #bindinfo

	local upgroup = {}

	if activeid > 0 then
		local actcfg = _cfg.draw_up_active(activeid)
		if actcfg == nil then
			return
		end
		if _func.getNowSecond() < actcfg.time_start or _func.getNowSecond() > actcfg.time_end then
			return
		end
		poolid = actcfg.pool_id
		upgroup = actcfg.group_up
	end

	local vec = _cfg.draw_pool(poolid)
	if vec == nil then
		return
	end

	local reward = {}
	local drawcoin1,drawcoin2 = 0,0
	local rtchange = {}
	local extnums = {}
	local groupid = {}

	for i = 1, num do
		for _, cfg in ipairs(vec) do
			local ratecfg = _cfg.draw_rate_func(cfg.rate_func)
			local rate = 0
			local savenum = true
			local drawnum = 0
			local upid = upgroup[cfg.group] or 0
			local rt = (upid > 0 and _record.RT_DRAW_UP_COUNT_BEGIN or _record.RT_DRAW_COUNT_BEGIN)+cfg.id
			if #ratecfg == 1 and ratecfg[1].add_rate == 0 then
				savenum = false
				rate = ratecfg[1].start_rate
			else
				drawnum = (rtchange[rt] or self:getRecord(rt)) + 1
				for _, rf in ipairs(ratecfg) do
					if drawnum <= rf.num_max then
						rate = rf.start_rate + (drawnum-rf.num_min)*rf.add_rate
						break
					end
				end
			end

			if math.random(10000) < rate then
				local item = nil
				if upid > 0 then
					item = self:draw_up_group(cfg,upid)
				else
					item = draw_group(cfg.group)
				end
				item[4] = bindinfo[i] and BIND_TYPE.BT_BIND or BIND_TYPE.BT_UNBIND
				reward[#reward+1] = item
				groupid[#groupid+1] = cfg.group
				if savenum then
					rtchange[rt] = 0
				end
				if cfg.ext_item_id == ITEM_ID.II_DRAW_CARD_COIN_1 then
					drawcoin1 = drawcoin1 + cfg.ext_item_num
				elseif cfg.ext_item_id == ITEM_ID.II_DRAW_CARD_COIN_2 then
					drawcoin2 = drawcoin2 + cfg.ext_item_num
				end
				extnums[i] = {cfg.ext_item_id,cfg.ext_item_num}
				break
			else
				if savenum then
					rtchange[rt] = drawnum
				end
			end
		end
	end

	if drawcoin1 > 0 then
		reward[#reward+1] = _func.make_cfg_item_one(ITEM_ID.II_DRAW_CARD_COIN_1,ITEM_TYPE.IT_ITEM,drawcoin1)
	end
	if drawcoin2 > 0 then
		reward[#reward+1] = _func.make_cfg_item_one(ITEM_ID.II_DRAW_CARD_COIN_2,ITEM_TYPE.IT_ITEM,drawcoin2)
	end

	if costitem[3] > 0 then
		self:delBag({costitem},CHANGE_REASON.CR_DRAW_CARD)
	end

	if costconf then
		self:costGold(costconf,CHANGE_REASON.CR_DRAW_CARD)
	end

	self:addBagOrSendMail(reward,CHANGE_REASON.CR_DRAW_CARD)

	for k, v in pairs(rtchange) do
		self:updateRecord(k,v)
	end

	local drowfirst = {}
	local pb = {}
	local log = {}
	local cid = self.cid
	local nowtime = _func.getNowSecond()
	for i = 1, num do
		local v = reward[i]
		local ext = extnums[i]
		local first = self:checkFirstDrow(v[1],v[2],drowfirst)
		pb[#pb+1] = {
			item = {
				item_id = v[1],
				item_type = v[2],
				item_num = v[3],
			},
			extid = ext[1],
			extnum = ext[2],
			first = first,
			group = groupid[i],
		}

		log[#log+1] = {
			cid = cid,
			item_id = v[1],
			item_type = v[2],
			num = v[3],
			active = activeid,
			time = nowtime,
		}
	end
	if #drowfirst > 0 then
		_net_mgr:dbInsertDataVector(_table.TAB_mem_chr_drow_item,drowfirst)
	end
	self:sendMsg(SM.SM_DRAW_CARD_REWARD,{data=pb},"SmDrawInfo")
	self:sendDrawInfo()
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_QIYUAN,0,num)
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_QIFU, num)
	_net_mgr:dbLogVector(_table.TAB_log_draw_card,log)
end

return active_common_module