-- 放一些简单的单一的功能协议

local _cfg = CFG_DATA
local _cr = CHANGE_REASON
local _sm = SM
local _sermid = SERVER_MSG
local _table = TABLE_INDEX
local _func = LFUNC
local _string_util = STRING_UTIL
local _shop_cond = SHOP_OPEN_CONDITION
local _net_mgr = nil
local _equip_mgr = nil


local MAX_MAIL_NUM = 200
MAIL_STATE = {
	MS_NONE = 0,
	MS_READ = 1,
	MS_GET = 2,
}

local complex_module = {}

function complex_module:init()

	_net_mgr = MOD.net_mgr_module
	_equip_mgr = MOD.equip_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_ITEM_COMPOSE,self.onItemCompose,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_ITEM_COMPOSE_UNLOCK,self.onItemComposeUnlock,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_INSTANCE_RECYCLE,self.onInstanceRecycle,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_COOK,self.onCook,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_CLIENT_RECORD_UPDATE,self.onClientRecordUpdate,"SmRecordInfo")
	MSG_FUNC.bind_player_proto_func(CM.CM_SHOP_MALL_BUY,self.onShopMallBuy,"ProtoInt32Array")
	MSG_FUNC.bind_async_player_proto(CM.CM_SELF_COLLECTION,self.onGetCollection,"PInt64Array")
	
	MSG_FUNC.bind_player_proto_func(CM.CM_MAIL_READ,self.onMailRead,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_MAIL_GET,self.onMailGetReward,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_MAIL_DELETE,self.onMailDelete,"PInt64Array")
	
end

function complex_module:initDB(d)
	local record = {}

	if d.client_record then
		for i, v in ipairs(d.client_record) do
			record[v.type] = v.value
		end

		self:sendMsg(_sm.SM_CLIENT_RECORD,{info=d.client_record},"SmRecordInfo")
	else
		self:sendMsg(_sm.SM_CLIENT_RECORD,{info={}},"SmRecordInfo")
	end
	self._client_record = record

	local shoplimit = {}

	if d.shop_limit then
		for _, v in ipairs(d.shop_limit) do
			shoplimit[v.shop_id] = v
		end
	end
	self._shop_limit = shoplimit

	local collection = {}
	if d.collection then
		for _, v in ipairs(d.collection) do
			collection[v.id] = v
		end
		self:sendMsg(_sm.SM_SELF_COLLECTION,{data = d.collection},"SmSelfCollection")
	end
	self._collection = collection

	local collection_forever = {}
	if d.collection_forever then
		for _, v in ipairs(d.collection_forever) do
			collection_forever[v.id] = v
		end
		self:sendMsg(_sm.SM_SELF_COLLECTION_FOREVER,{data = d.collection_forever},"SmSelfCollectionForever")
	end
	self._collection_forever = collection_forever

	-- 邮件
	local server_mail = {}
	if d.server_mail then
		for _, v in ipairs(d.server_mail) do
			server_mail[v.id] = v
		end
	end
	self._server_mail = server_mail

	local mail = {}
	local sendmail = d.mail
	self._mail_num = 0
	if d.mail then
		self._mail_num = #d.mail
		for _, v in ipairs(d.mail) do
			mail[v.id] = v
		end
	end
	self._mail = mail
	self:addServerMail()

	if self._mail_num > MAX_MAIL_NUM then
		self:clearMailForMaxNum(0)
		sendmail = {}
		for _,v in pairs(mail) do
			sendmail[#sendmail+1] = v
		end
	end
	if sendmail then
		self:sendMsg(_sm.SM_MAIL_INFO,{data=sendmail},"SmMailInfo")
	end

end

function complex_module:sendShopLimitInfo(d)
	local msg = {}

	if d then
		msg = d
	else
		for _, v in pairs(self._shop_limit) do
			msg[#msg+1] = v
		end
	end
	self:sendMsg(_sm.SM_SHOP_LIMIT_INFO,{data = msg},"SmShopLimitInfo")
end

function complex_module:clearShopLimitCount(type)
	local cash = {}
	for _, v in pairs(self._shop_limit) do
		if v.limit_type == type and v.count > 0 then
			v.count = 0
			cash[#cash+1] = v
		end
	end

	if #cash > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_shop_limit,cash)
	end
end

function complex_module:onItemCompose(d)
	local id = d.i32[1]
	local num = d.i32[2]

	local cfg = _cfg.item_compose(id)
	if cfg == nil then
		return
	end

	if not self:checkItemComposeUnlock(id) then
		return
	end

	local makelv = 0
	if cfg.make_level > 0 then
		makelv = self:getLifeSkillLv(cfg.skill_type)
		if cfg.make_level > makelv then
			return
		end
	end

	local makenum = 0
	if cfg.make_num > 0 then
		makenum = self:getEquipMakeNum(cfg.skill_type,id)
		if num > 1 and makenum < cfg.make_num and makelv == cfg.make_level then
			return
		end
	end

	local cost = table.clone(cfg.cost)
	local reward = table.clone(cfg.reward)
	for i, v in ipairs(cost) do
		v[3] = v[3]*num
	end
	for i, v in ipairs(reward) do
		v[3] = v[3]*num
	end

	if not self:delBagCheck(cost) then
		return
	end

	if not self:addBagCheck(reward) then
		return
	end

	if cfg.make_cost > 0 and makenum < cfg.make_num and makelv == cfg.make_level then
		self:addEquipMakeNum(cfg.skill_type,id)
		self:addLifeSkillExp(cfg.skill_type,cfg.make_cost)
	end

	if cfg.skill_type == LIFE_SKILL_TYPE.LIANJIN then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_LIANJING,0,num)
	elseif cfg.skill_type == LIFE_SKILL_TYPE.LIANZHI then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_COOK_DANYAO,0,num)
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_DANYAO, 0, 1)
	elseif cfg.skill_type == LIFE_SKILL_TYPE.COOK then
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_COOK, 0, num)
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_COOK_DANYAO,0,num)
		self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_COOK_NUM, 1)
		self:updateProgressByType(TASK_CONDITION_TYPE.TCT_COOK, reward[1][1], reward[1][3])
	end

	self:delBag(cost,_cr.CR_ITEM_COMPOSE,true,false)
	self:addBag(reward,_cr.CR_ITEM_COMPOSE)
	self:replyMsg(CM.CM_ITEM_COMPOSE,ERROR_CODE.ERR_SUCCESS,{id})
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_BUILD_ITEM, id, num)
	if reward[1][1] == 2702 then
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_MAKE_FTSZ, 0, 1)
	elseif reward[1][1] >= 5301 and reward[1][1] <= 5345 then
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_SHUXINGDAN, 0, 1)
	end
end

function complex_module:onItemComposeUnlock(d)
	local cfg = _cfg.item_compose_unlock(d.i32)
	if cfg == nil then
		return
	end

	local group = math.floor((cfg.index-1)/32)
	if group < 0 or group >= 30 then
		return
	end
	local index = cfg.index%32
	if index == 0 then
		index = 32
	end

	local rt = RECORD_TYPE.RT_ITEM_COMPOSE_UNLOCK_BEGIN+group
	local val = self:getRecord(rt)
	if _func.is_bit_on(val,index) then
		return
	end

	if #cfg.cost == 0 then
		return
	end

	if not self:delBagCheck(cfg.cost) then
		return
	end

	self:delBag(cfg.cost,CHANGE_REASON.CR_ITEM_COMPOSE_UNLOCK)
	val = _func.set_bit_on(val,index)
	self:updateRecord(rt,val)
	self:sendRecordValue(rt,val)
end

function complex_module:taskItemComposeUnlock(tid)
	local id = _cfg.item_compose_unlock_task(tid)
	if id == nil then
		return
	end
	local cfg = _cfg.item_compose_unlock(id)
	if cfg == nil then
		return
	end

	local group = math.floor((cfg.index-1)/32)
	if group < 0 or group >= 30 then
		return
	end
	local index = cfg.index%32
	if index == 0 then
		index = 32
	end

	local rt = RECORD_TYPE.RT_ITEM_COMPOSE_UNLOCK_BEGIN+group
	local val = self:getRecord(rt)
	if _func.is_bit_on(val,index) then
		return
	end

	val = _func.set_bit_on(val,index)
	self:updateRecord(rt,val)
	self:sendRecordValue(rt,val)
end

function complex_module:checkItemComposeUnlock(id)
	local cfg = _cfg.item_compose_unlock(id)
	if cfg == nil then
		return true
	end

	local group = math.floor((cfg.index-1)/32)
	if group < 0 or group >= 30 then
		return false
	end
	local index = cfg.index%32
	if index == 0 then
		index = 32
	end

	local val = self:getRecord(RECORD_TYPE.RT_ITEM_COMPOSE_UNLOCK_BEGIN+group)
	return _func.is_bit_on(val,index)
end

function complex_module:onInstanceRecycle(d)
	if #d.data < 2 then
		return
	end

	local type = d.data[1]
	local id = d.data[2]

	local cfg = nil

	if type == ITEM_TYPE.IT_INSTANCE_EQUIP then
		local ins = self:getSelfEquip(id)
		if ins == nil then
			return
		end

		if not _equip_mgr:checkEquipNew(ins) then
			return
		end
		if self:checkInPuton(type,id) then
			return
		end

		cfg = _cfg.equip(ins.base)
	elseif type == ITEM_TYPE.IT_INSTANCE_BONE then
		local ins = self:getSelfBone(id)
		if ins == nil then
			return
		end
		if not _equip_mgr:checkBoneNew(ins) then
			return
		end
		if self:checkInPuton(type,id) then
			return
		end

		cfg = _cfg.bone(ins.base)
	else
		return
	end

	if not self:addBagCheck(cfg.recycle) then
		return
	end

	local del = _func.make_cfg_item(id,type,1)

	self:delBag(del,_cr.CR_INS_RECYCLE)
	self:addBag(cfg.recycle,_cr.CR_INS_RECYCLE)
	if type == ITEM_TYPE.IT_INSTANCE_EQUIP then
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_EQUIP_DECOMPOSE, 0, 1)
	end
end

function complex_module:onCook(d)
	local len = #d.i32
	if len < 4 or len%2 ~= 0 then
		return
	end
	local id = d.i32[1]
	local totalnum = d.i32[2]
	local itemnum = {}

	for i = 3, #d.i32,2 do
		itemnum[d.i32[i]] = d.i32[i+1]
	end

	local cfg = _cfg.cook(id)
	if cfg == nil then
		return
	end
	local makelv = self:getLifeSkillLv(LIFE_SKILL_TYPE.COOK)
	if cfg.make_level > makelv then
		return
	end

	local makenum = self:getEquipMakeNum(LIFE_SKILL_TYPE.COOK,id)
	if totalnum > 1 and makenum < cfg.make_num then
		return
	end

	local cost = {}

	for i, num in ipairs(cfg.cost_num) do
		local fn = 0

		local vec = cfg.cost_id[i]
		for _, fid in ipairs(vec) do
			if itemnum[fid] then
				fn = fn + itemnum[fid]
				cost[#cost+1] = _func.make_cfg_item_one(fid,ITEM_TYPE.IT_ITEM,itemnum[fid])
			end
		end
		if fn < num*totalnum then
			return
		end
	end

	local reward = table.clone(cfg.reward)
	for i, v in ipairs(reward) do
		v[3] = v[3]*totalnum
	end

	if not self:delBagCheck(cost) then
		return
	end

	if not self:addBagCheck(reward) then
		return
	end

	if makenum < cfg.make_num and makelv == cfg.make_level then
		self:addEquipMakeNum(LIFE_SKILL_TYPE.COOK,id)
		self:addLifeSkillExp(LIFE_SKILL_TYPE.COOK,cfg.make_cost)
	end

	self:delBag(cost,_cr.CR_COOK,true,false)
	self:addBag(reward,_cr.CR_COOK)
	self:replyMsg(CM.CM_COOK,ERROR_CODE.ERR_SUCCESS,{id})
	self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_COOK, 0, totalnum)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_COOK_DANYAO,0,totalnum)
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_COOK_NUM, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_COOK, reward[1][1], reward[1][3])
end

function complex_module:onClientRecordUpdate(d)
	if #d.info == 0 then
		return
	end

	local record = self._client_record
	local cid = self.cid
	local upvec,delvec = {},{}
	for i, v in ipairs(d.info) do
--		if v.type < 1 or v.type > 1000 then
--			return
--		end
		v.cid = cid
		if v.value == "" or v.value == "0" then
			record[v.type] = nil
			delvec[#delvec+1] = v
		else
			record[v.type] = v.value
			upvec[#upvec+1] = v
		end
	end

	self:dbDeleteDataVector(_table.TAB_mem_chr_client_record,delvec)
	self:dbUpdateDataVector(_table.TAB_mem_chr_client_record,upvec)
	self:sendMsg(_sm.SM_CLIENT_RECORD,d,"SmRecordInfo")
end

function complex_module:checkShopMaillOpen(type,val)
	local data = {}
	local vec = _cfg.table("shop_common_condtion")
	for _, v in ipairs(vec) do
		if v.open_condtion[1] == type then
			local info = self._shop_limit[v.id]
			if info == nil or info.discount_time == 0 then
				local open = false
				if type == _shop_cond.SOC_USE_TILI then
					if val >= v.open_condtion[2] then
						open = true
					end
				elseif type == _shop_cond.SOC_SYSTEM_OPEN then
					if val == v.open_condtion[2] then
						open = true
					end
				end
				if open then
					if info == nil then
						local cfgmall = _cfg.shop_mall(v.id)
						info = {
							cid = self.cid,
							shop_id = v.id,
							count = 0,
							limit_type = cfgmall.limit_type,
							discount_time = 0,
						}
					end
					info.discount_time = _func.getNowSecond() + v.discount_time
					data[#data+1] = info
				end
			end
		end
	end
	if #data > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_shop_limit,data)
		self:sendShopLimitInfo(data)
	end
end

function complex_module:onShopMallBuy(d)
	if #d.i32 < 2 then
		return
	end

	local id = d.i32[1]
	local num = d.i32[2]
	local country_lv = d.i32[3]

	local cfgmall = _cfg.shop_mall(id)
	local cfgshop = _cfg.shop_common(id)
	if num <=0 or cfgmall == nil or cfgshop == nil then
		return
	end

	local oldinfo = self._shop_limit[id]
	if cfgmall.limit_type ~= SHOP_LIMIT_TYPE.SLT_NONE then
		local total = num
		if oldinfo then
			total = total + oldinfo.count
		end
		if total > cfgmall.limit_count then
			return
		end
	end

	local cost = cfgshop.cost_value
	if oldinfo and oldinfo.discount_time > _func.getNowSecond() then
		cost = cfgshop.discount_value
	end

	if cfgmall.type >= 1 and cfgmall.type <= 5 then
		-- 势力商店打折
		if country_lv and country_lv > 0 then
			local cfgsl = _cfg.shili_level(country_lv);
			if cfgsl then
				local power = self:getRecord(RECORD_TYPE.RT_COUNTRY_POWER_BEGIN+cfgmall.type - 1)
				if power >= cfgsl.value then
					cost = math.ceil(cost*cfgsl.discount/100)
				end
			end
		end
	end

	cost = cost*num
	local conf = nil
	if cost > 0 then
		if cfgshop.cost_type == CURRENCY_TYPE.CT_DIAMOND then
			conf = self:checkCostGold(cost,false)
			if conf == nil then
				return
			end
		elseif cfgshop.cost_type == CURRENCY_TYPE.CT_BIND_DIAMOND then
			conf = self:checkCostGold(cost,true)
			if conf == nil then
				return
			end
		else
			if cost > self:getCurrency(cfgshop.cost_type) then
				return
			end
			if cfgshop.cost_type == CURRENCY_TYPE.CT_FAMILY_CONTRIBUTE then
				if not self:haveFamily() then
					return
				end
			end
		end
	end

	local item = table.clone(cfgshop.item)
	for _, v in ipairs(item) do
		v[3] = v[3]*num
	end

	if not self:addBagCheck(item) then
		return
	end

	if cost > 0 then
		if conf then
			self:costGold(conf,CHANGE_REASON.CR_SHOP_BUY)
		else
			self:addCurrency(cfgshop.cost_type,-cost,CHANGE_REASON.CR_SHOP_BUY)
			if cfgshop.cost_type == CURRENCY_TYPE.CT_FAMILY_CONTRIBUTE then
				self:checkFamilyShopTask()
			end
		end
	end

	self:addBag(item,CHANGE_REASON.CR_SHOP_BUY)

	if cfgmall.limit_type ~= SHOP_LIMIT_TYPE.SLT_NONE then
		if oldinfo == nil then
			oldinfo = {
				cid = self.cid,
				shop_id = id,
				count = 0,
				limit_type = cfgmall.limit_type,
				discount_time = 0,
			}
			self._shop_limit[id] = oldinfo
		end

		oldinfo.count = oldinfo.count + num

		self:sendShopLimitInfo({oldinfo})
		self:dbUpdateData(_table.TAB_mem_chr_shop_limit,oldinfo)
	end
	if cfgmall.type == 10 then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_ZM_SHOP,0,num)
	end
	self:replyMsg(CM.CM_SHOP_MALL_BUY,ERROR_CODE.ERR_SUCCESS,{id})
end

function complex_module:onGetCollection(d,coro)
	if #d.data < 2 then
		return
	end

	local id = d.data[1]
	local toolid = d.data[2]

	local cfg = _cfg.collection_self(id)
	if cfg == nil then
		return
	end

	local info = nil
	local num = 0
	local gindex = math.fmod(id,64) + 1

	if cfg.cd <= 0 then
		-- 永久
		local gid = math.floor(id/64)
		info = self._collection_forever[gid]
		if info == nil then
			info = {
				cid = self.cid,
				id = gid,
				value = 0,
			}
			self._collection_forever[gid] = info
		end
	else
		info = self._collection[id]
		if info == nil then
			info = {
				cid = self.cid,
				id = id,
				num = 0,
				time = 0,
			}
			self._collection[id] = info
		end
		num = info.num
		if _func.getNowSecond() > info.time then
			num = 0
		end
	end

	if num >= cfg.num then
		return
	end

	local useitem = nil
	local itemcfg = nil
	if cfg.need_item_type > 0 then
		useitem = self:getSelfItem(toolid)
		if useitem == nil then
			return
		end
		itemcfg = _cfg.item(useitem.base)
		if itemcfg == nil or itemcfg.type ~= cfg.need_item_type or cfg.level > itemcfg.item_level then
			return
		end
	end

	-- 位置检查
	local reqmsg = {math.floor(cfg.x),math.floor(cfg.y),math.floor(cfg.z),5}
	local repb = _net_mgr:requestGamePlayerMsg(self,SERVER_MSG.IM_GAME_PLAYER_REQUEST_CHECK_POS,{i32=reqmsg},"ProtoInt32Array",coro,"ProtoInt32")
	if repb == nil or repb.i32 == 0 then
		return
	end

	if cfg.cd <= 0 and _func.is_bit_on(info.value,gindex) then
		return
	end

	local drop = self:createDropItemsByIds(cfg.reward,drop)

	if #drop > 0 and not self:addBagCheck(drop) then
		return
	end

	if useitem then
		useitem.extra = useitem.extra + 1
		if useitem.extra >= itemcfg.effect[1] then
			self:delBag(_func.make_cfg_item(useitem.id,ITEM_TYPE.IT_INSTANCE_ITEM,1),CHANGE_REASON.CR_COLLECTION,true,false)
		else
			_equip_mgr:updateMemCommon(self.db_serid,useitem,CHANGE_REASON.CR_COLLECTION)
		end
	end

	
	self:addBag(drop,CHANGE_REASON.CR_COLLECTION)
	
	if cfg.cd <= 0 then
		info.value = _func.set_bit_on(info.value,gindex)
		self:dbUpdateData(_table.TAB_mem_chr_collection_forever,info)
		self:sendMsg(_sm.SM_SELF_COLLECTION_FOREVER,{data = {info}},"SmSelfCollectionForever")
	else
		info.num = num + 1
		if _func.getNowSecond() > info.time then
			info.time = _func.getNowSecond() + cfg.cd
		end
		self:dbUpdateData(_table.TAB_mem_chr_collection,info)
		self:sendMsg(_sm.SM_SELF_COLLECTION,{data = {info}},"SmSelfCollection")
	end

	if cfg.type == 1 then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_CAIJI,0,1)
		self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_CAIJI_CAOYAO, 1)
	elseif cfg.type == 2 then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_WAKUANG,0,1)
		--self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_CAIJI_MINE, 1)
	elseif cfg.type == 4 then
		--self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_CAIJI_TIANFU, 1)
		self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_TANGMEN_QCYN, 0, 1)
	end
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_CAIJI, id, 1)
end

function complex_module:clearMailForMaxNum(add)
	local vec = {}
	for _, v in pairs(self._mail) do
		vec[#vec+1] = v
	end

	table.sort(vec,function (a,b)
		return a.id > b.id
	end)

	local delvec = {}
	local unread = {}
	local unget = {}

	local dnum = #vec - MAX_MAIL_NUM + add
	for i = #vec, 1,-1 do
		local m = vec[i]
		if m.reward == "" then
			if m.state == MAIL_STATE.MS_READ then
				delvec[#delvec+1] = m.id
				dnum = dnum - 1
				if dnum <= 0 then
					break
				end
			else
				unread[#unread+1] = m.id
			end
		else
			if m.state == MAIL_STATE.MS_GET then
				delvec[#delvec+1] = m.id
				dnum = dnum - 1
				if dnum <= 0 then
					break
				end
			else
				unget[#unget+1] = m.id
			end
		end
	end

	if dnum > 0 then
		for i = 1, #unread do
			delvec[#delvec+1] = unread[i]
			dnum = dnum - 1
			if dnum <= 0 then
				break
			end
		end
	end

	if dnum > 0 then
		for i = 1, #unget do
			delvec[#delvec+1] = unget[i]
			dnum = dnum - 1
			if dnum <= 0 then
				break
			end
		end
	end

	self:deleteMail(delvec,add > 0)
end

function complex_module:deleteMail(idvec,send)
	local mail = self._mail
	for _, id in ipairs(idvec) do
		mail[id] = nil
	end

	self._mail_num = self._mail_num - #idvec

	_net_mgr:sendToDBMsg(self.db_serid,_sermid.IM_DB_DELETE_MAIL,{data=idvec},"PInt64Array")

	if send then
		self:sendMsg(_sm.SM_MAIL_DELETE,{data=idvec},"PInt64Array")
	end
end

function complex_module:sendMailInfo(m)
	local msg = {
		data = {m}
	}
	self:sendMsg(_sm.SM_MAIL_INFO,msg,"SmMailInfo")
end

function complex_module:onMailRead(d)
	local mail = self._mail[d.data]
	if mail == nil or mail.state ~= MAIL_STATE.MS_NONE then
		return
	end

	mail.state = MAIL_STATE.MS_READ

	_equip_mgr:updateMail(self.db_serid,mail)
	self:sendMailInfo(mail)
end

function complex_module:onMailGetReward(d)
	local mail = self._mail[d.data]
	if mail == nil or mail.state == MAIL_STATE.MS_GET or mail.reward == "" then
		return
	end

	local reward = _string_util.splite_int_vec2(mail.reward)
	if #reward == 0 then
		return
	end

	if not self:addBagCheck(reward) then
		return
	end

	self:addBag(reward,CHANGE_REASON.CR_GET_MAIL)
	mail.state = MAIL_STATE.MS_GET
	_equip_mgr:updateMail(self.db_serid,mail)
	self:sendMailInfo(mail)
end

function complex_module:onMailDelete(d)
	if #d.data == 0 then
		return
	end

	local delvec = {}
	local mail = self._mail
	for _, id in ipairs(d.data) do
		local m = mail[id]
		if m ~= nil and (m.reward == "" or m.state == MAIL_STATE.MS_GET) then
			delvec[#delvec+1] = id
		end
	end
	self:deleteMail(delvec,true)
end

function complex_module:addMail(sender,title,content,reward,reason)
	local mail = _equip_mgr:addMail(self.db_serid,self.cid,sender,title,content,reward,reason)
	self._mail[mail.id] = mail
	self._mail_num = self._mail_num + 1
	self:sendMailInfo(mail)
end

function complex_module:addMailByid(id,reason,reward,contentparam)
	local cfg = _cfg.mail(id)
	if cfg == nil then
		return
	end

	local title = cfg.title
	local content = cfg.content
	reward = reward or cfg.reward

	if contentparam then
		content = _string_util.format_content(content,contentparam)
	end

	self:addMail(cfg.sender,title,content,reward,reason)
end

function complex_module:addMailReward(mid,cfgvec,reason)
	local cfg = _cfg.mail(mid)
	if cfg == nil then
		return
	end

	local reward = _string_util.combin_vec2(cfgvec)
	self:addMail(cfg.sender,cfg.title,cfg.content,reward,reason)
end

function complex_module:addServerMail()
	local add = {}
	local smail = self._server_mail
	for _, v in ipairs(SERVER_MAIL) do
		if smail[v.id] == nil then
			local sm = {
				cid = self.cid,
				id = v.id,
				time = v.time,
			}

			add[#add+1] = sm
			smail[v.id] = sm
			self:addMail(0,v.title,v.content,v.reward,CHANGE_REASON.CR_SERVER_MAIL)
		end
	end

	if #add > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_server_mail,add)
	end
end

return complex_module