
local _msg_func = MSG_FUNC
local _cm = CM
local _sm = SM
local _net_mgr = nil
local _player_mgr = nil
local _cfg = CFG_DATA
local _table = TABLE_INDEX
local _func = LFUNC
local _time = TIME_UTIL
local _pack = PACK
local _system_cond = SYSTEM_OPEN_CONDITION
local _system_type = SYSTEM_UNLOCK_TYPE
local _record = RECORD_TYPE
local _map_type = MAP_TYPE
local _cr = CHANGE_REASON

local player_module = {}

function player_module:init()
	
	_net_mgr = MOD.net_mgr_module
	_player_mgr = MOD.player_mgr_module

	_msg_func.bind_player_proto_func(_cm.CM_DEBUG,self.onCmdDebug,"ProtoInt32Array")
	_msg_func.bind_async_player_proto(_cm.CM_REQUEST_TEST,self.onRequestTest,"ProtoInt32")
	_msg_func.bind_player_proto_func(_cm.CM_NEAR_PLAYER,self.onGetNearPlayer,"ProtoInt32")
	_msg_func.bind_async_player_proto(_cm.CM_NEW_NAME, self.onNewName, "PString")
	_msg_func.bind_player_proto_func(_cm.CM_FACE_DATA, self.onFaceData, "PInt64")

	_msg_func.bind_player_proto_func(_cm.CM_BUY_NHHY, self.onBuyNHHY, "ProtoInt32")
	_msg_func.bind_player_proto_func(_cm.CM_SWITCH_GAME,self.onSwitchGame,"SwitchGame")

	_msg_func.bind_async_player_proto(_cm.CM_DIG_MONSTER, self.onDigMonster, "ProtoInt32")
	
	MSG_FUNC.bind_player_server_proto_request(SERVER_MSG.IM_LOGIN_PLAYER_REQUEST_TEST,self.onGameRequestTest,"ProtoInt32")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_MONSTER_DIE,self.onMonsterDie,"ImMonsterDie")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_MONSTER_MIN_HP, self.onMonsterMinHP, "ProtoInt32")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_ADD_BUFF, self.onAddPlayerBuff, "ProtoInt32")
	MSG_FUNC.bind_player_server_proto_request(SERVER_MSG.IM_LOGIN_PLAYER_REVIVE,self.onGamePlayerRevive,"CmRevive")
	MSG_FUNC.bind_player_server_proto_request(SERVER_MSG.IM_LOGIN_CHECK_TELEPORT,self.onGameCheckTeleport,"CmMapTeleport")
	MSG_FUNC.bind_player_server_proto_request(SERVER_MSG.IM_LOGIN_CHECK_ENTER_DUNGEON,self.onGameCheckEnterDungeon,"ProtoInt32")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_MAP_DROP,self.onMapDrop,"ImMapDrop")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_ADD_BAG,self.onAddBag,"ImAddBag")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_SWITCH_GAME,self.onLoginSwitchGame,"ImSwitchGame")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_ENTER_MAP,self.onEnterMap,"ImEnterMap")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_PLAYER_ATK,self.onPlayerAtk,"ProtoInt32Array")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_CONTINUE_ATK,self.onPlayerContinueAtk,"ProtoInt32Array")
	MSG_FUNC.bind_player_server_proto(SERVER_MSG.IM_LOGIN_LEAVE_DUNGEON_FOR_SWITCH,self.onLeaveDungeonForSwitch,"ImSwitchGame")
end

function player_module:initDB(pdata)
	self._chr_info = pdata.chr_info
	self._attr_type = 1

	local jobcfg = _cfg.job(self._chr_info.job)
	if jobcfg then
		self._attr_type = jobcfg.attr_type
	end

	self._attr = {}

	self._record = {}
	for i, v in ipairs(pdata.record) do
		self._record[v.type] = v.value
	end

	self._danyao = {}
	for i, v in ipairs(pdata.danyao) do
		self._danyao[v.did] = v.num
	end

	self._level_gift = {}
	for i, v in ipairs(pdata.level_gift) do
		self._level_gift[v.level] = v.done
	end

	self._face = _func.checkPlayerData(pdata.face) and pdata.face or {cid=self._chr_info.cid, face="",time=0}
	

	self._msg_cd = {}
	--self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_LEVEL, self._attr[PLAYER_ATTR_SOURCE.PAS_LEVEL])
	self:sendPlayerInfo()
	self:sendLevelInfo()
end

local evt = OFFLINE_EVENT

function player_module:dealOfflineEvent(evs)
	if evs == nil or #evs == 0 then
		return
	end

	for _, v in ipairs(evs) do
		if v.type == evt.ON_GET_LIKE then
			self:getFriendLike(v.pi64)
		elseif v.type == evt.ON_GET_FLOWER then
			self:getFriendFlower(v.pi64,v.param1,v.param2)
		end
	end

	_net_mgr:dbDeleteData(_table.TAB_mem_chr_offline_event,{cid=self.cid})
end

function player_module:afterInit()
	self._chr_info.login_time = _func.getNowSecond()
	self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)

	self:checkTime()

	-- 在newXX come 之后发
	self:sendShopLimitInfo()
	self:sendSomePayInfo()
	self:sendMsg(SM.SM_NHHY_BUY_NUM,{i32=self:getRecord(RECORD_TYPE.RT_DAILY_NHHY_BUY_NUM)},"ProtoInt32")

	self:sendRecordValue()

	self:calcEatFoodValue(true)
	self:sendEatFoodInfo()
end

-- 玩家进入 game 之后调用的函数
function player_module:afterEnterGame()
	
end

function player_module:logout()
	local onlinetime = self:getRecord(RECORD_TYPE.RT_DAILY_ONLINE_TIME)
	local otime = _func.getNowSecond()-self._chr_info.login_time
	self:updateRecord(RECORD_TYPE.RT_DAILY_ONLINE_TIME,otime + onlinetime)
	self:addRecord(_record.RT_TOTAL_ONLINE_TIME,otime)
	self._chr_info.logout_time = _func.getNowSecond()
	self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
	-- print("player logout savedb")
	_net_mgr:dbSavePlayerDataRedisToDB(self.db_serid,self.cid,self.sid)
	_player_mgr:setPlayerSimpleInfo(self)

	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local pack = _pack.poppack()
		pack:writeint64(self.cid)
		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_PLAYER_LOGOUT,pack)
	end
	self:teamLeave()
	self:arenaLeave()
end

local OFFSET_5H = 5*3600

function player_module:checkTime()
	if _time.day_diff(self._chr_info.logout_time) > 0 then
		self:newDayCome()
	end

	-- 5点刷新
	if _time.day_diff(self._chr_info.logout_time,nil,OFFSET_5H) > 0 then
		self:newDay5hCome()
	end

	if _time.week_zero() ~= _time.week_zero(self._chr_info.logout_time) then
		self:newWeekCome()
	end

	-- 周1 5点
	if _time.week_zero(_func.getNowSecond()-OFFSET_5H) ~= _time.week_zero(self._chr_info.logout_time-OFFSET_5H) then
		self:newWeek5hCome()
	end

	if _time.get_month() ~= _time.get_month(self._chr_info.logout_time) then
		self:newMonthCome()
	end

end

function player_module:newMinuteCome()
	local onlineTime = _func.getNowSecond() - self._chr_info.login_time + self:getRecord(RECORD_TYPE.RT_DAILY_ONLINE_TIME)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_ONLINE_TIME, 0, math.floor(onlineTime / 60), 1)
	self:updateGlamours()
end

function player_module:newHourCome()
	self:checkResetVit()
	self:checkAutoReciveTask()
end

function player_module:recalcSomeInfo()
	self:updateSignUpInfo()
	self:sendSomePayInfo()
end

function player_module:newDayCome()
	self:clearRecord(RECORD_TYPE.RT_BEGIN,RECORD_TYPE.RT_DAILY_END)
	self:clearShopLimitCount(SHOP_LIMIT_TYPE.SLT_DAY)
	self:checkAndResetWartoken()
	self:recalcSomeInfo()
	self:updateNHHY()
end
-- 每天 5点
function player_module:newDay5hCome()
	self:clearRecord(RECORD_TYPE.RT_DAILY_END,RECORD_TYPE.RT_DAILY_5_END)
	self:clearMonsterDropInfo()
end

function player_module:newWeekCome()
	self:clearRecord(RECORD_TYPE.RT_DAILY_5_END,RECORD_TYPE.RT_WEEKLY_END)
	self:clearShopLimitCount(SHOP_LIMIT_TYPE.SLT_WEEK)

end
-- 每周1 5点
function player_module:newWeek5hCome()
	self:clearRecord(RECORD_TYPE.RT_WEEKLY_END,RECORD_TYPE.RT_WEEKLY_5_END)
end

function player_module:newMonthCome()
	self:clearRecord(RECORD_TYPE.RT_WEEKLY_END,RECORD_TYPE.RT_MONTHLY_END)
	self:clearShopLimitCount(SHOP_LIMIT_TYPE.SLT_MONTH)

end

function player_module:sendPlayerInfo()
	self:sendMsg(_sm.SM_PLAYER_INFO,self._chr_info,"SmPlayerInfo")
end

function player_module:sendLevelInfo()
	local chrinfo = self._chr_info
	local pb = 
	{
		level = chrinfo.level,
		hunshi = chrinfo.hunshi,
		xuantian1 = chrinfo.xuantian1,
		xuantian2 = chrinfo.xuantian2,
		xuantian3 = chrinfo.xuantian3,
		attr_level = chrinfo.attr_level,
		attr_point_1 = chrinfo.attr_point_1,
		attr_point_2 = chrinfo.attr_point_2,
		attr_point_3 = chrinfo.attr_point_3,
		attr_point_4 = chrinfo.attr_point_4,
		attr_point_5 = chrinfo.attr_point_5,
	}
	self:sendMsg(_sm.SM_LEVEL_INFO,pb,"SmLevelInfo")
end

function player_module:sendExpInfo()
	local chrinfo = self._chr_info
	local pb =
	{
		exp = chrinfo.exp,
	}
	self:sendMsg(_sm.SM_EXP_INFO,pb,"SmExpInfo")
end
-- 给客户端发消息
function player_module:sendMsg(mid,pb,pbname)
	_net_mgr:sendPlayerMsg(self.gate_serid,self.gate_index,mid,pb,pbname)
end
-- 给game的player发消息
function player_module:sendMsgToGame(mid,pb,pbname)
	_net_mgr:sendToGamePlayerMsg(self,mid, pb,pbname)
end

function player_module:sendMsgToOtherPlayer(cid,func,data)
	local ply = _player_mgr:getPlayerByCid(cid)
	if ply then
		func(ply,data)
	end
end

function player_module:dbUpdateData(table,pb)
	_net_mgr:dbUpdatePlayerData(self.db_serid,self.cid,table,pb)
end

function player_module:dbUpdateDataVector(table,pbvec)
	_net_mgr:dbUpdatePlayerDataVector(self.db_serid,self.cid,table,pbvec)
end

function player_module:dbDeleteData(table,pb)
	_net_mgr:dbDeletePlayerData(self.db_serid,self.cid,table,pb)
end

function player_module:dbDeleteDataVector(table,pbvec)
	_net_mgr:dbDeletePlayerDataVector(self.db_serid,self.cid,table,pbvec)
end

function player_module:sendRecordValue(tp,val)
	local pb = {}
	if tp == nil then
		for i = 1, 5 do
			local rt = _record.RT_COUNTRY_POWER_BEGIN+i-1
			pb[#pb+1] = {data1=rt,data2=self:getRecord(rt)}
		end
		pb[#pb+1] = {data1=_record.RT_TOTAL_ONLINE_TIME,data2=self:getRecord(_record.RT_TOTAL_ONLINE_TIME)}
		-- 配方解锁
		local rt = _record.RT_ITEM_COMPOSE_UNLOCK_BEGIN
		for i = 1, 10 do
			pb[#pb+1] = {data1=rt,data2=self:getRecord(rt)}
			rt = rt + 1
		end
	else
		pb[#pb+1] = {
			data1 = tp,
			data2 = val,
		}
	end
	self:sendMsg(_sm.SM_RECORD_VALUE,{list=pb},"ProtoPairInt32Array")
end

local CMD_TYPE = {
	CMD_ITEM = 1,
	CMD_CLEAR_BAG = 2,
	CMD_MONEY = 3,
	CMD_EXP = 4,
	CMD_LEVEL = 5,
	CMD_HUNSHI = 6,
	CMD_RECEIVE_TASK = 7,		-- 接取任务(type:tid)
	CMD_TASK_STATE = 8,			-- 完成任务(type:tid)
	CMD_GET_ALL_ITEM = 9,		-- 添加所有物品
	CMD_NEILI = 10,				-- 玄天功内力
	CMD_ACHIEVEMENT_POINT = 11,	-- 成就点
	CMD_VITALITY = 12,			-- 活跃点
	CMD_MAIL = 13,				-- 加邮件
	CMD_TIANFU_POINT = 14,		-- 增加天赋点
	CMD_FAMILY_RESOURCE = 15,	-- 加帮会资源
	CMD_OPEN_WING = 16,			-- 开启翅膀
	CMD_FAMILY_ACITVE = 17,		-- 加帮会活跃
	CMD_MAP_TELEPORT = 18,		-- 地图传送

	CMD_CALL_MONSTER = 50,		-- 招怪

	CMD_TEST = 100,
}

function player_module:onCmdDebug(data)

	if #data.i32 == 0 then
		return
	end

	local pam = data.i32
	local cmd = pam[1]

	if cmd == CMD_TYPE.CMD_ITEM then
		local cfg = {}
		for i = 1, 4 do
			cfg[i] = pam[i+1]
		end

		if self:addBagCheck({cfg}) then
			self:addBag({cfg},CHANGE_REASON.CR_CMD)
		end
	elseif cmd == CMD_TYPE.CMD_CLEAR_BAG then
		local id = pam[2]
		local num = pam[3]
		if id > 0 and num > 0 then
			self:delBag(_func.make_cfg_item(id,ITEM_TYPE.IT_ITEM,num),CHANGE_REASON.CR_CMD)
		else
			self:clearBag()
		end
	elseif cmd == CMD_TYPE.CMD_MONEY then
		local ct = pam[2]
		local num = pam[3]
		if ct == CURRENCY_TYPE.CT_DIAMOND then
			self:addGold(num,0,CHANGE_REASON.CR_CMD)
		elseif ct == CURRENCY_TYPE.CT_BIND_DIAMOND then
			self:addGold(0,num,CHANGE_REASON.CR_CMD)
		else
			self:addCurrency(ct,num,CHANGE_REASON.CR_CMD)
		end
	elseif cmd == CMD_TYPE.CMD_EXP then
		local exp = pam[2]
		self:addExp(exp, CHANGE_REASON.CR_CMD)
		--[[--local gamed = {
			game_server_id = 1001,
			map_id = 10040,
			map_index = 0,
			x = -40,
			y = 110,
			z = -40,
			cid = self.cid,
			sid = self.sid,
			uid = self.uid,
			unique_id = 99999,
		}
		_net_mgr:sendToGameMsg(self.game_serid, SERVER_MSG.IM_GAME_SWITCH_GAME, gamed, "ImSwitchGame")--]]
	elseif cmd == CMD_TYPE.CMD_LEVEL then
		local level = pam[2]
		self:setLevel(level, CHANGE_REASON.CR_CMD)
	elseif cmd == CMD_TYPE.CMD_HUNSHI then
		local hunshi = pam[2]
		self:setHunshi(hunshi, CHANGE_REASON.CR_CMD)
	elseif cmd == CMD_TYPE.CMD_TASK_STATE then
		local ttype = pam[2]
		local tid = pam[3]
		self:cmdUpdateTaskProgress(ttype, tid)
	elseif cmd == CMD_TYPE.CMD_RECEIVE_TASK then
		local ttype = pam[2]
		local tid = pam[3]
		self:cmdReceiveTask(ttype,tid)
	elseif cmd == CMD_TYPE.CMD_TEST then
		local svec = _func.make_cfg_item(pam[2],pam[3],pam[4])
		self:drop_reward_to_map(svec,{0,0,0})
	elseif cmd == CMD_TYPE.CMD_GET_ALL_ITEM then
		local allitem = {}
		local vec = _cfg.table("item")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_ITEM,1000)
		end
		vec = _cfg.table("equip")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_EQUIP,1)
		end
		vec = _cfg.table("bone")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_BONE,1)
		end
		vec = _cfg.table("core")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_CORE,1)
		end
		vec = _cfg.table("anqi")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_ANQI,1)
		end
		vec = _cfg.table("hunqi")
		for id, v in pairs(vec) do
			allitem[#allitem+1] = _func.make_cfg_item_one(id,ITEM_TYPE.IT_HUNQI,1)
		end

		if self:addBagCheck(allitem) then
			self:addBag(allitem,CHANGE_REASON.CR_CMD)
		end
	elseif cmd == CMD_TYPE.CMD_NEILI then
		local neili = pam[2]
		if neili > 0 then
			self:addNeili(neili)
		end
	elseif cmd == CMD_TYPE.CMD_ACHIEVEMENT_POINT then
		local point = pam[2]
		if point > 0 then
			self:addAchievementPoint(point)
			self:syncAchievement()
			self:sendAchievementInfo()
		end
	elseif cmd == CMD_TYPE.CMD_VITALITY then
		local vit = pam[2]
		if vit > 0 then
			self:addVit(vit)
		end
	elseif cmd == CMD_TYPE.CMD_MAIL then
		local mid = pam[2]
		self:addMailByid(mid,CHANGE_REASON.CR_CMD)
	elseif cmd == CMD_TYPE.CMD_TIANFU_POINT then
		local num1 = pam[2] or 0
		local num2 = pam[3] or 0
		local num3 = pam[4] or 0
		self:addTianfuPoint(num1,num2,num3)
	elseif cmd == CMD_TYPE.CMD_FAMILY_RESOURCE then
		local n1 = pam[2] or 0
		local n2 = pam[3] or 0
		local n3 = pam[4] or 0
		local n4 = pam[5] or 0
		self:gmAddFamilyResource(n1,n2,n3,n4)
	elseif cmd == CMD_TYPE.CMD_FAMILY_ACITVE then
		local val = pam[2] or 0
		self:addFamilyActive(val)
	elseif cmd == CMD_TYPE.CMD_OPEN_WING then
		self:openWing()
	else
		self:sendMsgToGame(_cm.CM_DEBUG,data,"ProtoInt32Array")
	end
end

function player_module:onSwitchGame(d)
	if self.game_serid == d.game_server_id then
		return
	end

	local gamed = {
		game_server_id = d.game_server_id,
		map_id = d.map_id,
		map_index = d.map_index,
		x = d.x,
		y = d.y,
		z = d.z,
		cid = self.cid,
		sid = self.sid,
		uid = self.uid,
	}

	_net_mgr:sendToGameMsg(self.game_serid, SERVER_MSG.IM_GAME_SWITCH_GAME, gamed, "ImSwitchGame")
end

function player_module:onLeaveDungeonForSwitch(d)
	if self.game_serid == d.game_server_id then
		return
	end

	player:switchGame(d.game_server_id, d.unique_id, d.map_id, d.map_index, d.x, d.y, d.z)

end

function player_module:onLoginSwitchGame(d)

	self.game_serid = d.game_server_id
	self._chr_info.map = d.map_id
	self._chr_info.x = d.x
	self._chr_info.y = d.y
	self._chr_info.z = d.z
	self._chr_info.map_index = d.map_index
	self._chr_info.unique_map_id = d.unique_id

	local gamepb = {
		gate_index = self.gate_index,
		gate_id = self.gate_serid,
		db_id = self.db_id,
		chr_info = self._chr_info,
		switch_server = 1,
		face_time = self._face.time,
	}
	self:loadAttr(gamepb)
	self:loadHunhuanSkill(gamepb)
	self:loadGrassSkill(gamepb)
	self:loadTianfuSkill(gamepb)
	self:loadAnqiSkill(gamepb)
	_net_mgr:sendToGameMsg(d.game_server_id, SERVER_MSG.IM_GAME_PLAYER_LOADED, gamepb, "ImGamePlayerLoaded")

	self:afterEnterGame()
end

function player_module:onRequestTest(d,coro)
	print("request test %d",d.i32)
	-- local repb = _net_mgr:requestGameMsg(self.game_serid,SERVER_MSG.IM_GAME_REQUEST_TEST,d,"ProtoInt32",coro,"ProtoInt32")
	local repb = _net_mgr:requestGamePlayerMsg(self,SERVER_MSG.IM_GAME_PLAYER_REQUEST_TEST,d,"ProtoInt32",coro,"ProtoInt32")
	if repb == nil then
		print("request out time")
	else
		print("get response %d",repb.i32)
	end
end

function player_module:onDigMonster(d, coro)
	local repb = _net_mgr:requestGamePlayerMsg(self,SERVER_MSG.IM_GAME_PLAYER_CHECK_MONSTER_DIG,d,"ProtoInt32",coro,"ProtoInt32")
	if repb == nil then
		return
	elseif repb.i32 > 0 then
		local mCfg = _cfg.monster(repb.i32)
		if mCfg == nil then
			return
		end
		if self:getCurrency(CURRENCY_TYPE.CT_NHHY) < mCfg.corpse_cost then
			return
		end
		self:addCurrency(CURRENCY_TYPE.CT_NHHY,-mCfg.corpse_cost,CHANGE_REASON.CR_MONSTER_DIG)
		--给奖励
		local dropItems = self:createDropItemsByIds(mCfg.corpse_dig)
		if not self:addBagCheck(dropItems) then
			print("drop group cannot add bag %d",repb.i32)
		else
			self:addBag(dropItems,_cr.CR_MONSTER_DIG)
		end

		-- 消耗体力处理
		local duse = self:addRecord(RECORD_TYPE.RT_DAILY_USE_TILI,mCfg.corpse_cost)
		self:checkShopMaillOpen(SHOP_OPEN_CONDITION.SOC_USE_TILI,duse)
	else
		return
	end
end

function player_module:onGameRequestTest(d,coidx)
	
	print("get req from game %d",d.i32)
	_net_mgr:responseGamePlayerMsg(self,coidx,d,"ProtoInt32")

end

function player_module:onGamePlayerRevive(d,coidx)
	--复活判断
	local repb = {i32 = 1}
	_net_mgr:responseGamePlayerMsg(self,coidx,repb,"ProtoInt32")
end

function player_module:onGameCheckTeleport(d,coidx)
	--传送判断
	local repb = {i32 = 1}
	_net_mgr:responseGamePlayerMsg(self,coidx,repb,"ProtoInt32")
end

function player_module:onGameCheckEnterDungeon(d,coidx)
	--传送判断
	local repb = {i32 = 1}
	_net_mgr:responseGamePlayerMsg(self,coidx,repb,"ProtoInt32")
end

function player_module:clearAttrCash(module)
	self._attr[module] = {}
end

local calcAttr = {
	[PLAYER_ATTR_SOURCE.PAS_EQUIP] = function (player)
		return player:calcEquipAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_BONE] = function (player)
		return player:calcBoneAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_ANQI] = function (player)
		return player:calcAnqiAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_WUHUN] = function (player)
		return player:calcWuhunAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_WING] = function (player)
		return player:calcWingAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_EBOW] = function (player)
		return player:calcEbowAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_POSITION] = function (player)
		return player:calcPositionAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_MEDAL] = function (player)
		return player:calcMedalAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_ACHIEVEMENT] = function(player)
		return player:calcAchievementAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_NEIGONG] = function(player)
		return player:calcNeigongAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_GRASS] = function(player)
		return player:calcGrassAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_TIANFU] = function(player)
		return player:calcTianfuAttr()
	end,
	[PLAYER_ATTR_SOURCE.PAS_TUJIAN] = function (player)
		return player:calcTujianAttr()
	end,
}

function player_module:updateModuleAttr(module,nosend)
	local attr = calcAttr[module](self)
	-- attr = {[type] = {[vtype] =val,...},...}
	local at = {}

	for tp, vtab in pairs(attr) do
		for vt, v in pairs(vtab) do
			at[#at+1] = {tp,vt,v}
		end
	end

	self._attr[module] = at
	if not nosend then
		self:sendAttrMsg(module,at)
	end
end

function player_module:updateSkill(id,level,hunyin)
	local pb = {skill_id = id, level = level, hunyin = hunyin}
	self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_SKILL_LEVEL_UPDATE,{skill_level_info = {pb}}, "ImSkillLevelInfo")
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_SKILL_LEVEL, id, level)
end

function player_module:updateSkillList(arr)
	local pb = {}
	for _, v in ipairs(arr) do
		pb[#pb+1] = {skill_id = v[1], level = v[2], hunyin = v[3]}
		self:updateProgressByType(TASK_CONDITION_TYPE.TCT_SKILL_LEVEL, v[1], v[2])
	end
	self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_SKILL_LEVEL_UPDATE,{skill_level_info = pb}, "ImSkillLevelInfo")
end

function player_module:loadAttr(pdata)
	local moduleattr = {}
	for module,attr in pairs(self._attr) do
		local attrdata = {}
		for k,v in pairs(attr) do
			attrdata[#attrdata+1] = {attr_type = v[1], value_type = v[2], attr_value = v[3]}
		end
		moduleattr[#moduleattr+1] = {module = module, attr = attrdata}
	end
	pdata.module_attr = moduleattr
end

function player_module:sendAttrMsg(module, attr)
	local attrdata = {}
	for k,v in ipairs(attr) do
		attrdata[#attrdata+1] = {attr_type = v[1], value_type = v[2], attr_value = v[3]}
	end

	local gamemodule = {
		module = module,
		attr = attrdata,
	}
	local playerattr = {
		uid = self.uid,
		sid = self.sid,
		game_module = gamemodule,
	}

	_net_mgr:sendToGameMsg(self.game_serid,SERVER_MSG.IM_GAME_MODULE_ATTR,playerattr,"PlayerModuleAttr")
end

function player_module:getRecord(type)
	return self._record[type] or 0
end

function player_module:updateRecord(type,value)
	local pb = {cid=self.cid,type=type,value=value}
	if value == 0 then
		self._record[type] = nil
		self:dbDeleteData(_table.TAB_mem_chr_record,pb)
	else
		self._record[type] = value
		self:dbUpdateData(_table.TAB_mem_chr_record,pb)
	end
end

function player_module:addRecord(type,val)
	local old = self._record[type] or 0
	old = old + val
	self:updateRecord(type,old)
	return old
end

function player_module:clearRecord(_beg,_end)
	local pbvec = {}
	local record = self._record
	local cid = self.cid
	for k, v in pairs(record) do
		if k >= _beg and k <= _end and v ~= 0 then
			record[k] = 0
			pbvec[#pbvec+1] = {cid=cid,type=k,value=0}
		end
	end
	if #pbvec > 0 then
		self:dbDeleteDataVector(_table.TAB_mem_chr_record,pbvec)
	end
end

function player_module:getLevel()
	return self._chr_info.level
end

function player_module:getName()
	return self._chr_info.name
end

function player_module:getJob()
	return self._chr_info.job
end

function player_module:getHunshiLevel()
	return self._chr_info.hunshi
end

function player_module:getOtherPlayerMap(cid)
	local ply = _player_mgr:getPlayerByCid(cid)
	if ply then
		return ply._chr_info.map
	end
	return 0
end

-- pam={val,...}
function player_module:replyMsg(proc,res,pam)
	local pb = {
		proc = proc,
		res = res,
		param = pam,
	}
	self:sendMsg(_sm.SM_REPLY_RES,pb,"SmReplyRes")
end

function player_module:onEnterMap(d)
	self._chr_info.map = d.map_id
	self._chr_info.x = d.x
	self._chr_info.y = d.y
	self._chr_info.z = d.z
	self._chr_info.back_map = d.back_map
	self._chr_info.back_gameserver_id = d.back_gameserver_id
	self._chr_info.back_map_index = d.back_map_index
	self._chr_info.back_x = d.back_x
	self._chr_info.back_y = d.back_y
	self._chr_info.back_z = d.back_z

	self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
end

function player_module:onMonsterDie(d)
	local mCfg = _cfg.monster(d.monster_id)
	if mCfg == nil then
		return
	end
	--任务
	local mmCfg = _cfg.map_monster(d.map_monster_id)
	if mmCfg then
		self:updateProgressByType(TASK_CONDITION_TYPE.TCT_KILL_MONSTER_GROUP, mmCfg.group, 1)
	end
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_KILL_MONSTER_NUM, mCfg.id, 1)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_KILL_MONSTER_LEVEL, mCfg.level, 1)
	if mCfg.quality and mCfg.quality >= 2 then
		self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_KILL_OR_PK,0,1)
	end
	if mCfg.element_type then
		self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_KILL_MONSTER, mCfg.element_type, 1)
		if mCfg.element_type == 1 then
			self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_MONSTER_ELE_FENG, 1)
		end

	end

	local drop = true
	if mmCfg then
		local mapCfg = _cfg.map(mmCfg.map)
		if mapCfg and mapCfg.type == _map_type.MT_NORMAL and self:checkMonsterDropped(d.map_monster_id) then
			drop = false
		end
	end
	if drop then
		--掉落
		local dropItems = self:createDropItemsByIds(mCfg.common_drop)
		if #dropItems ~= 0 then
			-- 掉地上
			self:drop_reward_to_map(dropItems, {d.x,d.y,d.z})

			-- if self:addBagCheck(dropItems) then
			-- 	self:addBag(dropItems, CHANGE_REASON.CR_MONSTER_DROP)

			-- 	local items = {}
			-- 	for index, value in ipairs(dropItems) do
			-- 		items[index]={item_type = value[2], item_id = value[1], item_num = value[3]}
			-- 	end
			-- 	self:sendMsg(_sm.SM_GRASS_INFO,{items = items},"SmGrassInfo")
			-- end
		end
	end
end

function player_module:onMonsterMinHP(d)
	local mmCfg = _cfg.map_monster(d.i32)
	if mmCfg == nil or mmCfg.monster <= 0 then
		return
	end

	-- 怪物达到血量百分比任务
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_MONSTER_MIN_HP, mmCfg.monster)
end

function player_module:onAddPlayerBuff(d)
	local buffId = d.i32
	if buffId > 0 then
		self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_BUFF, buffId, 1)
		if buffId >= 1001 and buffId <= 1007 then
			self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_BUFF_COUNT, 1, 1)
		end
	end
end

function player_module:onPlayerAtk(d)
	local dist = d.i32[1]
	if dist > 0 then
		self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_SHOOT, dist, 1)
	end
end

function player_module:onPlayerContinueAtk(d)
	local type = d.i32[1]
	local val = d.i32[2]
	if val > 0 then
		self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_CONTINUE_ATK, type, val, 1)
	end
end

function player_module:onMapDrop(pb)
	local dropItems = self:createDropItemsByIds(pb.drop_group)
	local p = pb.pos
	self:drop_reward_to_map(dropItems, {p.x,p.y,p.z})
end

function player_module:onAddBag(pb)
	local slots = {}
	for _, v in ipairs(pb.slots) do
		slots[#slots+1] = {v.id, v.type, v.count, v.bind}
	end
	if self:addBagCheck(slots) then
		self:addBag(slots, pb.reason)
	end
end

function player_module:addBagOrSendMail(reward,reason,mid)
	mid = mid or 11111
	if not self:addBagCheck(reward) then
		self:addMailReward(mid,reward,reason)
	else
		self:addBag(reward,reason)
	end
end

function player_module:checkCostGold(val,usebind)
	usebind = (usebind == nil) and true or false
	local info = self._chr_info
	if usebind then
		if val > info.gold_bind + info.gold_unbind then
			return
		end
		if val > info.gold_bind then
			return {gold_bind = info.gold_bind,gold_unbind=val-info.gold_bind}
		else
			return {gold_bind = val,gold_unbind = 0}
		end
	else
		if val > info.gold_unbind then
			return
		end
		return {gold_bind=0,gold_unbind=val}
	end
end

function player_module:costGold(conf,reason)
	local info = self._chr_info
	info.gold_bind = info.gold_bind - conf.gold_bind
	info.gold_unbind = info.gold_unbind - conf.gold_unbind
	self:dbUpdateData(_table.TAB_mem_chr,info)

	if conf.gold_bind > 0 then
		self:sendCurrency(CURRENCY_TYPE.CT_BIND_DIAMOND)
	end

	if conf.gold_unbind > 0 then
		self:sendCurrency(CURRENCY_TYPE.CT_DIAMOND)
	end
end

function player_module:addGold(val,bindval,reason)
	local info = self._chr_info
	if bindval > 0 then
		info.gold_bind = info.gold_bind + bindval
		self:sendCurrency(CURRENCY_TYPE.CT_BIND_DIAMOND)
	end
	if val > 0 then
		info.gold_unbind = info.gold_unbind + val
		self:sendCurrency(CURRENCY_TYPE.CT_DIAMOND)
	end
	self:dbUpdateData(_table.TAB_mem_chr,info)
end

function player_module:onGetNearPlayer(data)
	local map = data.i32
	local pb = {}
	local allPlayer = _player_mgr:getAllPlayer()
	for _, ply in pairs(allPlayer) do
		if ply._chr_info.map == map then
			pb[#pb+1] = ply._chr_info
		end
	end
	self:sendMsg(_sm.SM_NEAR_PLAYER_INFO,{player = pb},"MultiPlayerInfo")
end

function player_module:isFlagOn(type)
	local val = self:getRecord(RECORD_TYPE.RT_COMMON_FLAG)
	return _func.is_bit_on(val,type)
end

function player_module:setFlagOn(type)
	local val = self:getRecord(RECORD_TYPE.RT_COMMON_FLAG)
	val = _func.set_bit_on(val,type)
	self:updateRecord(RECORD_TYPE.RT_COMMON_FLAG,val)
end

function player_module:isDailyFlagOn(type)
	local val = self:getRecord(RECORD_TYPE.RT_DAILY_COMMON_FLAG)
	return _func.is_bit_on(val,type)
end

function player_module:setDailyFlagOn(type)
	local val = self:getRecord(RECORD_TYPE.RT_DAILY_COMMON_FLAG)
	val = _func.set_bit_on(val,type)
	self:updateRecord(RECORD_TYPE.RT_DAILY_COMMON_FLAG,val)
end

function player_module:checkInMsgCD(mid,sec)
	local t = self._msg_cd[mid] or 0
	if t > _func.getNowSecond() then
		return true
	else
		self._msg_cd[mid] = _func.getNowSecond() + sec
		return false
	end
end

function player_module:switchGame(gameserverid, unique_id,mapid, map_index, x,y,z)
	local gamed = {
		game_server_id = gameserverid,
		map_id = mapid,
		map_index = map_index,
		x = x,
		y = y,
		z = z,
		cid = self.cid,
		sid = self.sid,
		uid = self.uid,
		unique_id = unique_id,
	}
	_net_mgr:sendToGameMsg(self.game_serid, SERVER_MSG.IM_GAME_SWITCH_GAME, gamed, "ImSwitchGame")
end

function player_module:onNewName(d,coro)
	local name = d.data
	local msg = _net_mgr:requestDbMsg(self.db_serid,SERVER_MSG.IM_DB_UPDATE_PLAYER_NAME,{cid=self.cid,name=name},"ImDbUpdatePlayerName",coro,"ProtoInt32")
	local err = msg and msg.i32 or 1
	if err == 0 then
		self._chr_info.name = name
		self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
	end
	self:replyMsg(_cm.CM_NEW_NAME, ERROR_CODE.ERR_SUCCESS, {err})
end

function player_module:onBuyNHHY(data)
	local num = data.i32
	local costnum = self:getRecord(RECORD_TYPE.RT_DAILY_NHHY_BUY_NUM)
	if num ~= costnum then
		self:sendMsg(SM.SM_NHHY_BUY_NUM,{i32=costnum},"ProtoInt32")
		return
	end
	local cfgtili = _cfg.tili(num + 1)
	if cfgtili == nil then
		return
	end
	local conf = nil

	conf = self:checkCostGold(cfgtili.cost,false)
	if conf == nil then
		return
	end
	if conf then
		self:costGold(conf,CHANGE_REASON.CR_BUY_NHHY)
		self:addRecord(RECORD_TYPE.RT_DAILY_NHHY_BUY_NUM, 1)
		self:addCurrency(CURRENCY_TYPE.CT_NHHY,cfgtili.gain,CHANGE_REASON.CR_BUY_NHHY)
		self:sendMsg(SM.SM_NHHY_BUY_NUM,{i32=costnum + 1},"ProtoInt32")
	end
end

function player_module:getFace()
	return self._face
end

function player_module:onFaceData(data)
	local cid = data.data
	local player = _player_mgr:getPlayerByCid(cid)
	if not player then return end
	local face = player:getFace()
	self:sendMsg(_sm.SM_FACE_DATA, face, "SmFaceData")
end

function player_module:updateNHHY()
--更新凝华魂液最新值
	local maxNHHY = 0
	local hunshicfg = _cfg.hunshi_name(self._chr_info.hunshi)
	if hunshicfg ~= nil then
		maxNHHY = hunshicfg.tili
	end

	local lastChangeTime = self:getRecord(RECORD_TYPE.RT_LAST_NHHY_CHANGE_TIME)
	local cur = self:getRecord(RECORD_TYPE.RT_NHHY)
	local nowChangeTime = _func.getNowSecond()
	if cur < maxNHHY then
		local canAdd = math.modf((nowChangeTime - lastChangeTime)/360)
		if canAdd + cur >= maxNHHY then
			self:addRecord(RECORD_TYPE.RT_NHHY,maxNHHY - cur)
			self:updateRecord(RECORD_TYPE.RT_LAST_NHHY_CHANGE_TIME, nowChangeTime)
			self:sendMsg(SM.SM_LAST_NHHY_CHANGE_TIME,{i32=nowChangeTime},"ProtoInt32")
		elseif canAdd ~= 0 then
			self:addRecord(RECORD_TYPE.RT_NHHY,canAdd)
			nowChangeTime = lastChangeTime + canAdd * 360
			self:updateRecord(RECORD_TYPE.RT_LAST_NHHY_CHANGE_TIME, nowChangeTime)
			self:sendMsg(SM.SM_LAST_NHHY_CHANGE_TIME,{i32=nowChangeTime},"ProtoInt32")
		end
	else
		self:updateRecord(RECORD_TYPE.RT_LAST_NHHY_CHANGE_TIME, nowChangeTime)
		self:sendMsg(SM.SM_LAST_NHHY_CHANGE_TIME,{i32=nowChangeTime},"ProtoInt32")
	end
end

function player_module:checkSystemOpen(type,val)
	if type == _system_cond.SOC_TASK then
		if _cfg.new_open_task(val) == nil then
			return
		end
	end

	local state = self:getRecord(RECORD_TYPE.RT_SYSTEM_OPEN)
	local old = state
	for _, v in pairs(_system_type) do
		if not _func.is_bit_on(state,v) then
			local cfg = _cfg.new_open(v)
			if cfg then
				local open = true
				for _, cond in ipairs(cfg.condition) do
					if cond[1] == _system_cond.SOC_LEVEL then
						if self:getLevel() < cond[2] then
							open = false
							break
						end
					else
						local taskdone = false
						for i = 2, #cond do
							if self:isTaskComplete(cond[i]) then
								taskdone = true
								break
							end
						end
						if taskdone == false then
							open = false
							break
						end
					end
				end
				if open then
					state = _func.set_bit_on(state,v)
					self:checkShopMaillOpen(SHOP_OPEN_CONDITION.SOC_SYSTEM_OPEN,v)
				end
			end
		end
	end
	if old ~= state then
		self:updateRecord(RECORD_TYPE.RT_SYSTEM_OPEN,state)
	end
end

function player_module:checkChangeModel(tid)
	if not self._chr_info or self._chr_info.model ~= 0 then
		return
	end
	if tid == 1001097 or tid == 1002161 or tid == 1003100 or tid == 1004166 or tid == 1005385 then
		self._chr_info.model = 1
		self:sendPlayerInfo()
		local allPlayer = _player_mgr:getAllPlayer()
		for _, ply in pairs(allPlayer) do
			ply:sendMsg(_sm.SM_CHR_MODEL_CHANGE,{cid=self.cid},"SmModelChange")
		end
		self:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_CHANGE_MODEL, {i32 = 1}, "ProtoInt32")
	end
end

function player_module:eatFood(val)
	local old = self:calcEatFoodValue(false)
	if old >= 100 then
		return false
	end

	old = old + val
	if old > 100 then
		old = 100
	end
	self:updateRecord(_record.RT_EAT_FOOD_VALUE,old)
	self:updateRecord(_record.RT_EAT_FOOD_VALUE_TIME,_func.getNowSecond())
	self:sendEatFoodInfo()
	return true
end

function player_module:calcEatFoodValue(update)
	local val = self:getRecord(_record.RT_EAT_FOOD_VALUE)
	local time = _func.getNowSecond() - self:getRecord(_record.RT_EAT_FOOD_VALUE_TIME)

	local down = math.floor(time/60)
	time = time % 60
	if val > 0 then
		val = val - down
		if val < 0 then
			val = 0
			time = 0
		end
		if update then
			self:updateRecord(_record.RT_EAT_FOOD_VALUE,val)
			self:updateRecord(_record.RT_EAT_FOOD_VALUE_TIME,_func.getNowSecond() - time)
		end
	end
	return val
end

function player_module:sendEatFoodInfo()
	local pb = {
		self:getRecord(_record.RT_EAT_FOOD_VALUE),
		self:getRecord(_record.RT_EAT_FOOD_VALUE_TIME),
	}
	self:sendMsg(_sm.SM_EAT_FOOD_INFO,{i32=pb},"ProtoInt32Array")
end

return player_module