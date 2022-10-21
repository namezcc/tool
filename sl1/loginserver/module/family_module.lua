local _cfg = CFG_DATA
local _func = LFUNC
local _record = RECORD_TYPE
local _table = TABLE_INDEX
local _pack = PACK
local _family_mgr = nil
local _player_mgr = nil
local _net_mgr = nil

local MAX_FLAG = 8

local family_module = {}

function family_module:init()
	_family_mgr = MOD.family_mgr_module
	_player_mgr = MOD.player_mgr_module
	_net_mgr = MOD.net_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_LIST,self.onGetFamilyList,"null",1)
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_CREATE,self.onCreateFamily,"CmCreateFamily")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_DISBAND,self.onDisbandFamily,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_QUIT,self.onQuitFamily,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_INFO,self.onGetFamilyInfo,"null")
	MSG_FUNC.bind_async_player_proto(CM.CM_FAMILY_GET_MEMBER,self.onGetFamilyMember,"null",1)
	MSG_FUNC.bind_async_player_proto(CM.CM_FAMILY_GET_APPLY,self.onGetFamilyApply,"null",1)
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_APPLY,self.onFamilyApply,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_DEAL_APPLY,self.onDealFamilyApply,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_POWER,self.onChangeFamilyPower,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_INVITE,self.onInviteFamily,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_DEAL_INVITE,self.onDealInviteFamily,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_KICK,self.onKickFamilyMember,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_POSITION,self.onChangeFamilyPosition,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_FLAG,self.onChangeFamilyFlag,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_DESC,self.onChangeFamilyDesc,"PString")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_NOTICE,self.onFamilySetNotice,"PString")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_BAN_CHAT,self.onFamilyBanChat,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SET_APPLY,self.onFamilySetApply,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SELF_RECOMMEND,self.onFamilySelfRecommend,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_EVENT,self.onGetFamilyEvent,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_BUILD_UP,self.onFamilyBuildUp,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_ACTIVE_REWARD,self.onFamilyGetActiveReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_DONATE_MONEY,self.onFamilyDonateMoney,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_DONATE_ITEM,self.onFamilyDonateItem,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_PLAYER_INFO,self.onGetFamilyPlayerInfo,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_SEND_INFO,self.onGetFamilySendInfo,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_FRIEND_SEND,self.onFamilyFriendSend,"ProtoInt32Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_FRIEND_SEND_CANCLE,self.onFamilySendCancle,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_FRIEND_SEND_GET_REWARD,self.onFamilySendGetReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_TASK_REWARD,self.onFamilyTaskGetReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_RED_PACKET_INFO,self.onGetFamilyRedPackeInfo,"null")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_GET_RED_PACKET,self.onGetFamilyRedPacke,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_FAMILY_SEND_RED_PACKET,self.onFamilySendRedPacket,"ProtoInt32Array")
	MSG_FUNC.bind_async_player_proto(CM.CM_WATCH_PLAYER_INFO,self.onWatchPlayerInfo,"PInt64",1)
	
end

function family_module:initDB(d)
	local family_send = {}
	if d.family_send then
		for i, v in ipairs(d.family_send) do
			family_send[v.type] = v
		end
	end
	self._family_send = family_send
end

function family_module:afterInit()
	self:checkFirstJoinFamily()
	self:enterFamilyChatRoom()
	self:sendFamilyPlayerMember()
end

function family_module:haveFamily()
	return _family_mgr:getMember(self.cid) ~= nil
end

function family_module:sendFamilyPlayerInfo()
	local pb = {
		self:getRecord(_record.RT_WEEKLY_5_FAMILY_ACTIVE_VALUE),
		self:getRecord(_record.RT_WEEKLY_5_FAMILY_ACTIVE_REWARD),
		self:getRecord(_record.RT_DAILY_ONLINE_TIME),
		self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_DONATE_MONEY),
		self:getRecord(_record.RT_DAILY_FAMILY_DONATE_ITEM_VALUE_1),
		self:getRecord(_record.RT_DAILY_FAMILY_DONATE_ITEM_VALUE_2),
		self:getRecord(_record.RT_DAILY_FAMILY_DONATE_ITEM_VALUE_3),
		0,0,0,0
	}

	for i = 1, 4 do
		if self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_TASK_ONLINE_GET+i-1) then
			pb[7+i] = 2
		elseif i > 1 then
			if self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_TASK_SEND+i-2) then
				pb[7+i] = 1
			end
		end
	end
	self:sendMsg(SM.SM_FAMILY_PlAYER_INFO,{i32=pb},"ProtoInt32Array")
end

function family_module:sendFamilyPlayerMember()
	local member = _family_mgr:getMember(self.cid)
	if member then
		self:sendMsg(SM.SM_FAMILY_PLAYER_MEMBER,member,"FamilyMember")
	end
end

function family_module:sendFamilyInfo(sendempty)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		if sendempty then
			self:sendMsg(SM.SM_FAMILY_INFO,{},"SmFamilyInfo")
		end
		return
	end

	local pb = _family_mgr:getFamilyProtoInfo(member.family_id)
	self:sendMsg(SM.SM_FAMILY_INFO,pb,"SmFamilyInfo")
end

function family_module:checkFirstJoinFamily()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	local family = _family_mgr:getFamily(member.family_id)
	if not self:isFlagOn(COMMON_FLAG_TYPE.CFT_FIRST_JOIN_FAMILY) then
		self:addMailByid(3,CHANGE_REASON.CR_CREATE_FAMILY,nil,{family.name})
		self:setFlagOn(COMMON_FLAG_TYPE.CFT_FIRST_JOIN_FAMILY)
	end
end

local FAMILY_ACTIVE_TASK = {
	FAT_ONLINE = 1,
	FAT_SEND = 2,
	FAT_DONATE = 3,
	FAT_SHOPPING = 4,
}

local FAMILY_ACTIVE_VALUE = {
	[FAMILY_ACTIVE_TASK.FAT_ONLINE] = 200,
	[FAMILY_ACTIVE_TASK.FAT_SEND] = 300,
	[FAMILY_ACTIVE_TASK.FAT_DONATE] = 300,
	[FAMILY_ACTIVE_TASK.FAT_SHOPPING] = 200,
}

function family_module:getDailyOnlineTime()
	local onlinetime = self:getRecord(_record.RT_DAILY_ONLINE_TIME)
	return _func.getNowSecond()-self._chr_info.login_time + onlinetime
end

function family_module:onGetFamilyList()
	local pb = {}
	local info = {}
	local cid = self.cid
	for _, v in pairs(_family_mgr._family) do
		pb[#pb+1] = v
		local ply = _player_mgr:getPlayerByCid(v.leader)
		info[#info+1] = {
			leader_online = ply ~= nil and 1 or 0,
			apply = _family_mgr:isApply(v.id,cid) and 1 or 0,
		}
	end
	self:sendMsg(SM.SM_FAMILY_LIST,{data = pb,info=info},"SmFamilyList")
end

local FAMILY_CREATE_ITEM = 14501

function family_module:onCreateFamily(d)
	-- if self:getLevel() < 10 then
	-- 	return
	-- end

	local mem = _family_mgr:getMember(self.cid)
	if mem then
		return
	end

	if d.flag < 1 or d.flag > MAX_FLAG then
		return
	end

	if d.type < 1 or d.type > 3 then
		return
	end

	if not _family_mgr:checkFamilyName(d.name) then
		self:replyMsg(CM.CM_FAMILY_CREATE,ERROR_CODE.ERR_FAMILY_SAME_NAME)
		return
	end

	local cost = _func.make_cfg_item(FAMILY_CREATE_ITEM,ITEM_TYPE.IT_ITEM,1)
	if not self:delBagCheck(cost) then
		return
	end

	_family_mgr:createFamily(d,self.cid,self._chr_info.name)

	self:delBag(cost,CHANGE_REASON.CR_CREATE_FAMILY)

	if not self:isFlagOn(COMMON_FLAG_TYPE.CFT_FIRST_CREATE_FAMILY) then
		self:addMailByid(2,CHANGE_REASON.CR_CREATE_FAMILY,nil,{d.name})
		self:setFlagOn(COMMON_FLAG_TYPE.CFT_FIRST_CREATE_FAMILY)
	else
		self:addMailByid(8,CHANGE_REASON.CR_CREATE_FAMILY,nil,{d.name})
	end

	self:checkFirstJoinFamily()

	self:sendFamilyInfo()
	self:enterFamilyChatRoom()
end

function family_module:onDisbandFamily()
	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:deleteFamily(member.family_id)
end

-- local QUIT_FAMILY_CD = 3600*2
local QUIT_FAMILY_CD = 60

function family_module:onQuitFamily()
	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position == FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:deleteMember(self.cid,FAMILY_QUIT_TYPE.QUIT)
	self:updateRecord(RECORD_TYPE.RT_FAMILY_QUIT_TIME,_func.getNowSecond()+QUIT_FAMILY_CD)
	_family_mgr:addEvent(member.family_id,FAMILY_EVENT.FE_QUIT,self:getName())
end

function family_module:onGetFamilyInfo()
	self:sendFamilyInfo(true)
end

function family_module:onGetFamilyMember(d,coro)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local memvec = _family_mgr._family_member[member.family_id]
	local idvec = {}
	for _, v in ipairs(memvec) do
		idvec[#idvec+1] = v.cid
	end

	local infovec = _player_mgr:loadPlayerSimpleInfo(idvec,self.db_serid,coro)
	local pb = {
		data = memvec,
		info = infovec,
	}
	self:sendMsg(SM.SM_FAMILY_MEMBER,pb,"SmFamilyMember")
end

function family_module:onGetFamilyApply(d,coro)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local apply = _family_mgr._family_apply[member.family_id]
	local idvec = {}
	for _, v in pairs(apply) do
		idvec[#idvec+1] = v.cid
	end
	local infovec = _player_mgr:loadPlayerSimpleInfo(idvec,self.db_serid,coro)
	local pb = {
		data = infovec,
	}
	self:sendMsg(SM.SM_FAMILY_APPLY,pb,"SmPlayerSimpleInfo")
end

function family_module:onFamilyApply(d)
	if #d.data == 0 then
		return
	end
	local check = {}

	for _, id in ipairs(d.data) do
		if check[id] ~= nil then
			return
		end
		check[id] = true
	end

	local member = _family_mgr:getMember(self.cid)
	if member then
		return
	end

	if self:getRecord(_record.RT_FAMILY_QUIT_TIME) > _func.getNowSecond() then
		self:replyMsg(CM.CM_FAMILY_APPLY,ERROR_CODE.ERR_FAMILY_JOIN_CD,{self:getRecord(_record.RT_FAMILY_QUIT_TIME)})
		return
	end

	if _family_mgr:applyFamily(d.data,self.cid,self:getLevel()) then
		self:replyMsg(CM.CM_FAMILY_APPLY,ERROR_CODE.ERR_SUCCESS)
	else
		self:replyMsg(CM.CM_FAMILY_APPLY,ERROR_CODE.ERR_FAIL)
	end
end

function family_module:onDealFamilyApply(d)
	if #d.data < 2 then
		return
	end
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if not _family_mgr:havePower(FAMILY_POWER.DEAL_APPLY,member) then
		return
	end

	local cid = d.data[1]
	local res = d.data[2]

	local code = ERROR_CODE.ERR_SUCCESS
	if not _family_mgr:dealApply(member.family_id,cid,res) then
		code = ERROR_CODE.ERR_FAIL
	end
	self:replyMsg(CM.CM_FAMILY_DEAL_APPLY,code)
end

function family_module:onChangeFamilyPower(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:changePower(member.family_id,d.data)
	self:replyMsg(CM.CM_FAMILY_SET_POWER,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onInviteFamily(d)
	local cid = d.data
	local iply = _player_mgr:getPlayerByCid(cid)
	if iply == nil then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if not _family_mgr:havePower(FAMILY_POWER.INVIATE,member) then
		return
	end

	local imem = _family_mgr:getMember(cid)
	if imem ~= nil then
		return
	end

	if iply:getRecord(_record.RT_FAMILY_QUIT_TIME) > _func.getNowSecond() then
		self:replyMsg(CM.CM_FAMILY_INVITE,ERROR_CODE.ERR_FAMILY_JOIN_CD,{iply:getRecord(_record.RT_FAMILY_QUIT_TIME)})
		return
	end

	_family_mgr:addInviteCash(cid,member.family_id)

	local family = _family_mgr:getFamily(member.family_id)
	local pb = {
		invite_name = self:getName(),
		family_name = family.name,
	}
	iply:sendMsg(SM.SM_FAMILY_INVITE,pb,"SmFamilyInvite")

	self:replyMsg(CM.CM_FAMILY_INVITE,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onDealInviteFamily(d)
	local res = d.i32
	_family_mgr:dealInvite(self.cid,res)
end

function family_module:onKickFamilyMember(d)
	local cid = d.data
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	if not _family_mgr:havePower(FAMILY_POWER.KICK,member) then
		return
	end

	local imem = _family_mgr:getMember(cid)
	if imem == nil or imem.family_id ~= member.family_id then
		return
	end
	if not _family_mgr:checkPowerBig(member,imem) then
		return
	end

	_family_mgr:deleteMember(cid,FAMILY_QUIT_TYPE.KICK)
	_family_mgr:getMemberInfo(cid,function (info)
		_family_mgr:addEvent(member.family_id,FAMILY_EVENT.FE_KICK,self:getName(),info.name,member.position)
	end)
	self:replyMsg(CM.CM_FAMILY_KICK,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onChangeFamilyPosition(d)
	if #d.data < 2 then
		return
	end

	local cid = d.data[1]
	local position = d.data[2]

	if cid == self.cid or FAMILY_POSITION_LEVEL[position] == nil then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	local imem = _family_mgr:getMember(cid)
	if imem == nil or imem.family_id ~= member.family_id then
		return
	end

	local oldpos = imem.position
	_family_mgr:changePosition(member.family_id,cid,position)
	_family_mgr:getMemberInfo(cid,function (info)
		_family_mgr:addEvent(member.family_id,FAMILY_EVENT.FE_SET_POSITION,self:getName(),info.name,oldpos,position)
	end)

	self:replyMsg(CM.CM_FAMILY_SET_POSITION,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onChangeFamilyFlag(d)
	if d.i32 < 1 or d.i32 > MAX_FLAG then
		return
	end
	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:changeFlag(member.family_id,d.i32)
	self:replyMsg(CM.CM_FAMILY_SET_FLAG,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onChangeFamilyDesc(d)
	if string.len(d.data) > 256 then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:changeDesc(member.family_id,d.data)
	self:replyMsg(CM.CM_FAMILY_SET_DESC,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onFamilySetNotice(d)
	if string.len(d.data) > 256 then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil or member.position ~= FAMILY_POSITION.FP_LEADER then
		return
	end

	_family_mgr:changeNotice(member.family_id,d.data)
	self:replyMsg(CM.CM_FAMILY_SET_NOTICE,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onFamilyBanChat(d)
	if #d.data < 2 then
		return
	end

	local cid = d.data[1]
	local res = d.data[2]

	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	if not _family_mgr:havePower(FAMILY_POWER.BAN_CHAT,member) then
		return
	end

	local imem = _family_mgr:getMember(cid)
	if imem == nil or imem.family_id ~= member.family_id then
		return
	end
	if not _family_mgr:checkPowerBig(member,imem) then
		return
	end

	imem.nochat = res
	_family_mgr:updateMember(imem)

	self:replyMsg(CM.CM_FAMILY_BAN_CHAT,ERROR_CODE.ERR_SUCCESS)

	local iplayer = _player_mgr:getPlayerByCid(cid)
	if iplayer then
		iplayer:sendFamilyPlayerMember()
	end
end

function family_module:onFamilySetApply(d)
	if #d.i32 < 2 then
		return
	end

	local limit = d.i32[1]
	local auto_agree = d.i32[2]
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	if not _family_mgr:havePower(FAMILY_POWER.DEAL_APPLY,member) then
		return
	end

	_family_mgr:setApply(member.family_id,limit,auto_agree)
	self:replyMsg(CM.CM_FAMILY_SET_APPLY,ERROR_CODE.ERR_SUCCESS)
end

function family_module:onFamilySelfRecommend()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	if _family_mgr:selfRecommend(member,self) then
		local memvec = _family_mgr._family_member[member.family_id]
		local cidvec = {}
		for i, v in ipairs(memvec) do
			cidvec[i] = v.cid
		end
		_player_mgr:sendMailToPlayerVector(cidvec,7,0,{self:getName()})
		self:replyMsg(CM.CM_FAMILY_SELF_RECOMMEND,ERROR_CODE.ERR_SUCCESS)
	end
end

function family_module:onGetFamilyEvent()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local event = _family_mgr._family_event[member.family_id]
	local pb = {
		data = event,
	}
	self:sendMsg(SM.SM_FAMILY_EVENT,pb,"SmFamilyEventVec2")
end

function family_module:onFamilyBuildUp(d)
	local type = d.i32
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end
	local res,lv = _family_mgr:buildUpgrade(member.family_id,type,member.position)
	if res then
		self:sendFamilyInfo()
		_family_mgr:addEvent(member.family_id,FAMILY_EVENT.FE_BUILD_UP,self:getName(),nil,type,lv)
	end
end

function family_module:onFamilyGetActiveReward(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local family = _family_mgr:getFamily(member.family_id)
	if family == nil then
		return
	end

	local type = 1
	local id = d.i32
	if family.level > 5 then
		type = 2
	end
	local cfg = _cfg.family_active_reward(type,id)
	if cfg == nil or cfg.value > family.active_value then
		return
	end

	local state = self:getRecord(RECORD_TYPE.RT_WEEKLY_5_FAMILY_ACTIVE_REWARD)
	if _func.is_bit_on(state,id) then
		return
	end

	if not self:addBagCheck(cfg.reward) then
		return
	end

	state = _func.set_bit_on(state,id)
	self:updateRecord(RECORD_TYPE.RT_WEEKLY_5_FAMILY_ACTIVE_REWARD,state)
	self:addBag(cfg.reward,CHANGE_REASON.CR_FAMILY_ACTIVE_REWARD)
	self:sendFamilyPlayerInfo()
end

local ct = CURRENCY_TYPE
local DONATE_MONEY = {
	100,
	100,
	100,
}

local DONATE_TYPE = {
	ct.CT_JINHUNBI,
	ct.CT_BIND_DIAMOND,
	ct.CT_DIAMOND,
}
function family_module:onFamilyDonateMoney(d)
	local type = d.i32
	if type < 1 or type > 3 then
		return
	end

	local ctype = DONATE_TYPE[type]

	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_DONATE_MONEY) then
		return
	end

	if DONATE_MONEY[type] > self:getCurrency(ctype) then
		return
	end

	if ctype == ct.CT_JINHUNBI then
		self:addCurrency(ctype,-DONATE_MONEY[type],CHANGE_REASON.CR_FAMILY_DONATE)
	else
		local conf = self:checkCostGold(DONATE_MONEY[type],ctype == ct.CT_BIND_DIAMOND)
		self:costGold(conf,CHANGE_REASON.CR_FAMILY_DONATE)
		if ctype == ct.CT_DIAMOND then
			_family_mgr:addRedPacket(member.family_id,ct.CT_BIND_DIAMOND,self.cid,self:getJob(),self:getName(),DONATE_MONEY[type],10)
		end
	end

	local rcfg = _cfg.common_reward(type)
	if rcfg then
		self:addBagOrSendMail(rcfg.reward,CHANGE_REASON.CR_FAMILY_DONATE)
	end

	self:setDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_DONATE_MONEY)

	_family_mgr:addGold(member.family_id,DONATE_MONEY[type],true)
	self:setFamilyTaskDown(FAMILY_ACTIVE_TASK.FAT_DONATE)

	self:sendFamilyPlayerInfo()
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_JUANXIAN, 1)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_JUANXIAN,0,1)
end

function family_module:onFamilyDonateItem(d)
	if #d.i32 % 2 ~= 0 then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local mat = {0,0,0}
	local cost = {}

	for i = 1, #d.i32,2 do
		local cfg = _cfg.family_donate_item(d.i32[i])
		if cfg == nil then
			return
		end
		local value = d.i32[i+1]*cfg.num
		mat[cfg.type] = mat[cfg.type] + value
		cost[#cost+1] = _func.make_cfg_item_one(d.i32[i],ITEM_TYPE.IT_ITEM,d.i32[i+1])
	end

	if not self:delBagCheck(cost) then
		return
	end

	for key, v in pairs(mat) do
		local rt = _record.RT_DAILY_FAMILY_DONATE_ITEM_VALUE_1+key-1
		local oldval = self:getRecord(rt)
		oldval = oldval + v
		self:updateRecord(rt,oldval)
		if oldval >= 1000 then
			local rcfg = _cfg.common_reward(COMMON_REWARD_TYPE.CRT_DONATE_FAMILY_ITEM_1+key-1)
			if rcfg then
				self:addBagOrSendMail(rcfg.reward,CHANGE_REASON.CR_FAMILY_DONATE)
			end
		end
	end

	self:delBag(cost,CHANGE_REASON.CR_FAMILY_DONATE)
	_family_mgr:addMaterial(member.family_id,mat,self:getName())

	self:setFamilyTaskDown(FAMILY_ACTIVE_TASK.FAT_DONATE)

	self:sendFamilyPlayerInfo()
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_JUANXIAN, 1)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_JUANXIAN,0,1)
end

function family_module:checkFamilyShopTask()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	self:setFamilyTaskDown(FAMILY_ACTIVE_TASK.FAT_SHOPPING)
end

function family_module:onGetFamilyPlayerInfo()
	self:sendFamilyPlayerInfo()
end

local function randFamilySend(type,lv,cid,num,exceptid)
	local vec = _cfg.family_send_type(type)
	if vec == nil then
		return {}
	end

	local rvec = {}
	for i, v in ipairs(vec) do
		if lv >= v.need_level and exceptid[v.id] == nil then
			rvec[#rvec+1] = v
		end
	end

	if #rvec == 0 then
		return {}
	end

	local res = {}
	for i = 1, num do
		local cfg,index = _func.rand_vector(rvec)
		if cfg then
			local info = {
				cid = cid,
				type = type*10+i,
				id = cfg.id,
				friend1 = 0,
				friend2 = 0,
				friend3 = 0,
				time = 0,
			}
			res[#res+1] = info
		end
		table.remove(rvec,index)
	end
	return res
end

function family_module:onGetFamilySendInfo()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local reftime = self:getRecord(_record.RT_FAMILY_SEND_REF_TIME)
	if _func.getNowSecond() > reftime then
		local family = _family_mgr:getFamily(member.family_id)
		local tab = _cfg.table("family_send_type")
		local update = {}
		for k, v in pairs(tab) do
			local exceptid = {}
			local refkey = {}

			for i = 1, 4 do
				local info = self._family_send[k*10+i]
				if info == nil or info.time <= 0 then
					refkey[#refkey+1] = k*10+i
				else
					exceptid[info.id] = true
				end
			end
			if #refkey > 0 then
				local vec = randFamilySend(k,family.level,self.cid,#refkey,exceptid)
				for i, value in ipairs(vec) do
					value.type = refkey[i]
					self._family_send[refkey[i]] = value
					update[#update+1] = value
				end
			end
		end
		reftime = _func.getNowSecond() + 3600*3
		self:updateRecord(_record.RT_FAMILY_SEND_REF_TIME,reftime)
		self:dbUpdateDataVector(_table.TAB_mem_chr_family_send,update)
	end

	local vec = {}
	for _, v in pairs(self._family_send) do
		vec[#vec+1] = v
	end

	local pb = {
		ref_time = reftime,
		data = vec,
	}
	self:sendMsg(SM.SM_FAMILY_SEND_INFO,pb,"SmFamilySendInfo")
end

function family_module:onFamilyFriendSend(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if #d.i32 ~= 4 then
		return
	end

	if d.i32[2] == 0 and d.i32[3] == 0 and d.i32[4] == 0 then
		return
	end

	local stype = d.i32[1]
	local friendvec = {d.i32[2],d.i32[3],d.i32[4]}

	local info = self._family_send[stype]
	if info == nil or info.time ~= 0 then
		return
	end

	local check = {}
	local insendnum = 0
	for _, v in pairs(self._family_send) do
		if v.time > 0 then
			insendnum = insendnum + 1
			check[v.friend1] = true
			check[v.friend2] = true
			check[v.friend3] = true
		end
	end

	if insendnum >= 2 then
		return
	end

	for _, fid in ipairs(friendvec) do
		if fid > 0 then
			if check[fid] or not self:haveNpcTujian(fid) then
				return
			end
			check[fid] = true
		end
	end

	local cfg = _cfg.family_send(info.id)
	if cfg == nil then
		return
	end

	info.time = _func.getNowSecond() + cfg.time
	info.friend1 = friendvec[1]
	info.friend2 = friendvec[2]
	info.friend3 = friendvec[3]

	self:setFamilyTaskDown(FAMILY_ACTIVE_TASK.FAT_SEND)
	self:dbUpdateData(_table.TAB_mem_chr_family_send,info)
	self:onGetFamilySendInfo()
end

function family_module:onFamilySendCancle(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local info = self._family_send[d.i32]
	if info == nil or info.time < _func.getNowSecond() then
		return
	end

	info.time = 0
	info.friend1 = 0
	info.friend2 = 0
	info.friend3 = 0
	self:dbUpdateData(_table.TAB_mem_chr_family_send,info)
	self:onGetFamilySendInfo()
end

function family_module:onFamilySendGetReward(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local info = self._family_send[d.i32]
	if info == nil or info.time <= 0 or info.time > _func.getNowSecond() then
		return
	end

	local cfg = _cfg.family_send(info.id)
	if cfg == nil then
		return
	end

	if not self:addBagCheck(cfg.reward) then
		return
	end

	self:addBag(cfg.reward,CHANGE_REASON.CR_FAMILY_SEND)
	info.time = -1
	info.friend1 = 0
	info.friend2 = 0
	info.friend3 = 0
	self:dbUpdateData(_table.TAB_mem_chr_family_send,info)
	self:onGetFamilySendInfo()
end

function family_module:setFamilyTaskDown(tp)
	tp = tp - 1
	if tp < 0 then
		return
	end
	if not self:isDailyFlagOn(tp) then
		self:setDailyFlagOn(tp)
	end
end

function family_module:addFamilyActive(val)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	self:addRecord(_record.RT_WEEKLY_5_FAMILY_ACTIVE_VALUE,val)
	_family_mgr:addActiveValue(member.family_id,val)
	self:sendFamilyPlayerInfo()
end

function family_module:onFamilyTaskGetReward(d)
	if d.i32 < 1 or d.i32 > 4 then
		return
	end

	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_TASK_ONLINE_GET+d.i32-1) then
		return
	end

	if d.i32 == FAMILY_ACTIVE_TASK.FAT_ONLINE then
		local onlinetime = self:getDailyOnlineTime()
		if onlinetime < 30*60 then
			return
		end
	else
		if not self:isDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_TASK_SEND+d.i32-2) then
			return
		end
	end

	local cfg = _cfg.common_reward(COMMON_REWARD_TYPE.CRT_FAMILY_TASK_ONLINE+d.i32-1)
	if cfg == nil then
		return
	end

	if not self:addBagCheck(cfg.reward) then
		return
	end

	self:addBag(cfg.reward,CHANGE_REASON.CR_FAMILY_TASK)
	self:addRecord(_record.RT_WEEKLY_5_FAMILY_ACTIVE_VALUE,FAMILY_ACTIVE_VALUE[d.i32])
	_family_mgr:addActiveValue(member.family_id,FAMILY_ACTIVE_VALUE[d.i32])

	self:setDailyFlagOn(DAILY_COMMON_FLAG.DCF_FAMILY_TASK_ONLINE_GET+d.i32-1)

	self:sendFamilyPlayerInfo()
	self:replyMsg(CM.CM_FAMILY_GET_TASK_REWARD,ERROR_CODE.ERR_SUCCESS)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_TASK_ZONGMEN,0,1)
	self:updateTaskWarTokenProgress(TASK_WAR_TOKEN_TYPE.TWTT_ZM_GONGXIAN,0,FAMILY_ACTIVE_VALUE[d.i32])
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_TASK_ZONGMEN, 1)
end

function family_module:onGetFamilyRedPackeInfo()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local packs = _family_mgr._family_red_packet[member.family_id]
	local recordtab = _family_mgr._family_red_packet_record[member.family_id]

	local record = {}

	for id, v in pairs(recordtab) do
		record[#record+1] = {
			id = id,
			data = v,
		}
	end

	local pb = {
		packet = packs,
		record = record,
	}
	self:sendMsg(SM.SM_FAMILY_RED_PACKET_INFO,pb,"SmRedPacketInfo")
end

function family_module:onGetFamilyRedPacke(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local pack = _family_mgr:getRedPacket(member.family_id,d.i32)
	if pack == nil then
		return
	end

	local value = _family_mgr:checkRedPacket(member.family_id,pack.id,self.cid,pack.value,pack.num)

	if value <= 0 then
		return
	end

	if pack.type == ct.CT_DIAMOND then
		self:addGold(value,0,CHANGE_REASON.CR_FAMILY_RED_PACKET)
	else
		self:addGold(0,value,CHANGE_REASON.CR_FAMILY_RED_PACKET)
	end

	_family_mgr:addRedPacketRecord(member.family_id,pack.id,self.cid,value,self:getJob(),self:getName())
	self:onGetFamilyRedPackeInfo()
end

function family_module:onFamilySendRedPacket(d)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	if #d.i32 ~= 2 then
		return
	end

	local value = d.i32[1]
	local num = d.i32[2]

	if value < 1000 or num < 5 or num > 50 then
		return
	end

	local conf = self:checkCostGold(value,false)
	if conf == nil then
		return
	end

	local packnum = _family_mgr:getRedPackeNum(member.family_id)
	if packnum >= 10 then
		return
	end

	_family_mgr:addRedPacket(member.family_id,ct.CT_DIAMOND,self.cid,self:getJob(),self:getName(),value,num)
	self:costGold(conf,CHANGE_REASON.CR_FAMILY_RED_PACKET)
	self:onGetFamilyRedPackeInfo()
end

function family_module:gmAddFamilyResource(gold,mine,stone,wood)
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local mat = {mine,stone,wood}

	_family_mgr:addGold(member.family_id,gold,true)
	_family_mgr:addMaterial(member.family_id,mat,self:getName())
end

function family_module:enterFamilyChatRoom()
	local member = _family_mgr:getMember(self.cid)
	if member == nil then
		return
	end

	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local pack = _pack.poppack()
		pack:writeint64(self.cid)
		pack:writeint32(0)
		pack:writeint64(member.family_id)
		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_ENTER_TEAM,pack)
	end
end

function family_module:quitFamilyChatRoom()
	local chatport = _net_mgr:getChatServerPort()
	if chatport > 0 then
		local pack = _pack.poppack()
		pack:writeint64(self.cid)
		pack:writeint32(0)
		_net_mgr:sendToChatPack(SERVER_MSG.IM_CHAT_QUIT_TEAM,pack)
	end
end

function family_module:onWatchPlayerInfo(d,coro)
	local res = _player_mgr:loadPlayerSimpleInfo({d.data},self.db_serid,coro)
	if #res == 0 then
		return
	end

	local pb = {}
	pb.info = res[1]

	local member = _family_mgr:getMember(d.data)
	if member then
		pb.family_position = member.position
		pb.nochat = member.nochat
		local family = _family_mgr:getFamily(member.family_id)
		if family then
			pb.family_flag = family.flag
			pb.family_name = family.name
			pb.family_id = family.id
		end
	end
	self:sendMsg(SM.SM_WATCH_PLAYER_INFO,pb,"SmWatchPlayerInfo")
end

return family_module