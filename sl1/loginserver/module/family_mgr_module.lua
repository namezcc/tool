local _log = LOG
local _func = LFUNC
local _table = TABLE_INDEX
local _cfg = CFG_DATA

local _player_mgr = nil
local _net_mgr = nil
local _equip_mgr = nil
local _schedule = nil

FAMILY_POSITION = {
	FP_LEADER = 1,
	FP_FBZ = 2,
	FP_LIT = 3,		--力堂
	FP_WUT = 4,		--武堂
	FP_YUT = 5,		--御堂
	FP_MINT = 6,	--敏堂
	FP_YAOT = 7,	--药堂
	FP_JINGYING = 8,	--精英
	FP_MEMBER = 9,
}

FAMILY_POSITION_LEVEL = {
	[FAMILY_POSITION.FP_LEADER] = 1,
	[FAMILY_POSITION.FP_FBZ] = 2,
	[FAMILY_POSITION.FP_LIT] = 3,
	[FAMILY_POSITION.FP_WUT] = 3,
	[FAMILY_POSITION.FP_YUT] = 3,
	[FAMILY_POSITION.FP_MINT] = 3,
	[FAMILY_POSITION.FP_YAOT] = 3,
	[FAMILY_POSITION.FP_JINGYING] = 4,
	[FAMILY_POSITION.FP_MEMBER] = 5,
}

FAMILY_QUIT_TYPE = {
	DELETE = 0,
	QUIT = 1,
	KICK = 2,
}

local FAMILY_BUILDING = {
	FB_MAIN = 1,		--议事厅
	FB_LIT = 3,		--力堂
	FB_WUT = 4,		--武堂
	FB_YUT = 5,		--御堂
	FB_MINT = 6,	--敏堂
	FB_YAOT = 7,	--药堂
}

local BUILD_KEY = {
	[FAMILY_BUILDING.FB_MAIN] = "level";
	[FAMILY_BUILDING.FB_LIT] = "li_lv";
	[FAMILY_BUILDING.FB_WUT] = "wu_lv";
	[FAMILY_BUILDING.FB_YUT] = "yu_lv";
	[FAMILY_BUILDING.FB_MINT] = "min_lv";
	[FAMILY_BUILDING.FB_YAOT] = "yao_lv";
}

FAMILY_POWER = {
	DEAL_APPLY = 1,		--审批
	INVIATE = 2,		--邀请
	BAN_CHAT = 3,		--禁言
	KICK = 4,			--开除
}

local FAMILY_POSITION_POWER = {
	0xF,
	0xF,
	0x7,
	0x7,
	0x7,
	0x7,
	0x7,
	0x0,
	0x0,
}

FAMILY_EVENT = {
	FE_CREATE = 1,			--创建帮会 	s1:玩家名
	FE_JOIN = 2,			--加入		s1:玩家名
	FE_KICK = 3,			--被踢		s1:玩家名 s2:被踢玩家 i1:玩家职位
	FE_SET_POSITION = 4,	--职位变动	s1:玩家名 s2:被变玩家 i1:旧职位 i2:新职位
	FE_QUIT = 5,			--退出		s1:玩家名
	FE_DONATE = 6,			--捐献		s1:玩家名 i1:资源类型 i2:数量
	FE_BUILD_UP = 7,		--建筑升级	s1:玩家名 i1:建筑类型 i2:等级
}

local FAMILY_DEFAULT_POWER = 0
for i, v in ipairs(FAMILY_POSITION_POWER) do
	if i > 1 then
		FAMILY_DEFAULT_POWER = FAMILY_DEFAULT_POWER|(v<<((i-2)*8))
	end
end

local family_mgr_module = {}

function family_mgr_module:init()
	self._family = {}
	self._family_member = {}
	self._family_apply = {}
	self._family_event = {}
	self._family_red_packet = {}
	self._family_red_packet_record = {}

	self._all_member = {}
	self._invite_cash = {}
	self._red_packet_id = {}

	_player_mgr = MOD.player_mgr_module
	_net_mgr = MOD.net_mgr_module
	_equip_mgr = MOD.equip_mgr_module
	_schedule = MOD.schedule_mgr_module
end

function family_mgr_module:init_func()
	
	_schedule:addTaskTimePoint({min=0,sec = 1},function ()
		self:checkLeaderSendMail()
	end,-1,SCHEDULE_INDEX.CHECK_FAMILY_LEADER)

	MSG_FUNC.bind_mod_proto_func(SERVER_MSG.IM_LOGIN_LOAD_FAMILY_DATA,self,self.onLoadFamilyData,"DB_family_data")

end

local EVENT_SUB_SIZE = 100
local function pushEvent(evv,v)
	local vec = evv[#evv]
	if vec == nil or #vec.data >= EVENT_SUB_SIZE then
		vec = {
			data = {},
		}
		evv[#evv+1] = vec
	end
	vec.data[#vec.data+1] = v
end

function family_mgr_module:onLoadFamilyData(d)
	for _, v in ipairs(d.family) do
		self._family[v.id] = v
		self._family_member[v.id] = {}
		self._family_apply[v.id] = {}
		self._family_event[v.id] = {}
		self._family_red_packet[v.id] = {}
		self._family_red_packet_record[v.id] = {}
	end

	local leaders = {}

	for _, v in ipairs(d.member) do
		local fmember = self._family_member[v.family_id]
		fmember[#fmember+1] = v
		self._all_member[v.cid] = v
		if v.position == FAMILY_POSITION.FP_LEADER then
			self._family[v.family_id].leader = v.cid
			leaders[#leaders+1] = v.cid
		end
	end

	for fid, v in pairs(self._family) do
		local vec = self._family_member[fid]
		v.count = #vec
	end

	for _, v in ipairs(d.apply) do
		local fapply = self._family_apply[v.family_id]
		fapply[v.cid] = v
	end

	-- 排序
	-- for _, vec in pairs(d.event) do
	-- 	table.sort(vec,function (v1,v2)
	-- 		if v1.family_id == v2.family_id then
	-- 			return v1.id < v2.id
	-- 		else
	-- 			return v1.family_id < v2.family_id
	-- 		end
	-- 	end)
	-- end

	for _, v in ipairs(d.event) do
		local events = self._family_event[v.family_id]
		pushEvent(events,v)
	end

	for _, v in ipairs(d.red_packet) do
		local tab = self._family_red_packet[v.family_id]
		tab[#tab+1] = v
		local record = self._family_red_packet_record[v.family_id]
		record[v.id] = {}
	end

	for fid, vec in pairs(self._family_red_packet) do
		local id = 0
		for _, v in ipairs(vec) do
			if v.id > id then
				id = v.id
			end
		end
		self._red_packet_id[fid] = id
	end

	for _, v in ipairs(d.red_packet_record) do
		local record = self._family_red_packet_record[v.family_id][v.id]
		record[#record+1] = v
	end

	if #leaders > 0 then
		MSG_FUNC.doCoroFunc(function (coro,...)
			self:loadLeaderInfo(coro,...)
		end,leaders)
	end
end

function family_mgr_module:loadLeaderInfo(coro,idvec)
	local vec = _player_mgr:loadPlayerSimpleInfo(idvec,_net_mgr._db_serid,coro)
	for _, v in ipairs(vec) do
		local mem = self._all_member[v.cid]
		if mem then
			local fm = self._family[mem.family_id]
			if fm then
				fm.leader_name = v.name
			else
				_log.error("family nil fid:%d",mem.family_id)
			end
		else
			_log.error("member nil cid:%d",v.cid)
		end
	end
end

function family_mgr_module:newDayCome()
	self:cleanRedPacket()
end

local RED_PACKET_MAIL_ID = 9

function family_mgr_module:checkSendRedPacket(fid,packs,reward)
	local ctype = CURRENCY_TYPE.CT_DIAMOND
	local recordvec = self._family_red_packet_record[fid]
	for _, v in ipairs(packs) do
		if v.type == ctype then
			local value = v.value
			local record = recordvec[v.id]
			if record then
				for _, rinfo in ipairs(record) do
					value = value - rinfo.value
				end
			end
			if value > 0 then
				reward[1][3] = value
				_player_mgr:sendMailToPlayer(v.cid,RED_PACKET_MAIL_ID,reward,CHANGE_REASON.CR_FAMILY_RED_PACKET,{value})
			end
		end
	end
end

function family_mgr_module:cleanRedPacket(familyid)
	local reward = _func.make_cfg_item(ITEM_ID.II_DIAMOND,ITEM_TYPE.IT_ITEM,0)

	if familyid then
		local vec = self._family_red_packet[familyid]
		self:checkSendRedPacket(familyid,vec,reward)
		self._family_red_packet[familyid] = nil
		self._family_red_packet_record[familyid] = nil
		_net_mgr:dbDeleteData(_table.TAB_mem_family_red_packet,{family_id=familyid})
		_net_mgr:dbDeleteData(_table.TAB_mem_family_red_packet_record,{family_id=familyid})
	else
		for fid, vec in pairs(self._family_red_packet) do
			self:checkSendRedPacket(fid,vec,reward)
		end
	
		for fid, v in pairs(self._family) do
			self._family_red_packet[fid] = {}
			self._family_red_packet_record[fid] = {}
		end

		_net_mgr:dbDeleteData(_table.TAB_mem_family_red_packet,{})
		_net_mgr:dbDeleteData(_table.TAB_mem_family_red_packet_record,{})
	end
end

function family_mgr_module:getMemberByPosition(fid,ps,pe)
	local vec = {}
	local member = self._family_member[fid]
	if member then
		for _, v in ipairs(member) do
			if v.position >= ps and v.position <= pe then
				vec[#vec+1] = v.cid
			end
		end
	end
	return vec
end

function family_mgr_module:checkLeaderSendMail()
	local now = _func.getNowSecond()

	for fid, v in pairs(self._family) do
		local info = _player_mgr:getPlayerSimpleInfo(v.leader)
		if info and info.online == 0 then
			local hour = math.floor((now-info.logout_time)/3600)
			local vec = nil
			local mailid = 0
			if hour == 3*24 then
				mailid = 4
				vec = self:getMemberByPosition(fid,FAMILY_POSITION.FP_FBZ,FAMILY_POSITION.FP_FBZ)
			elseif hour == 7*24 then
				mailid = 5
				vec = self:getMemberByPosition(fid,FAMILY_POSITION.FP_LIT,FAMILY_POSITION.FP_YAOT)
			elseif hour == 15*24 then
				mailid = 6
				vec = self:getMemberByPosition(fid,FAMILY_POSITION.FP_JINGYING,FAMILY_POSITION.FP_MEMBER)
			end
			if vec and #vec > 0 then
				_player_mgr:sendMailToPlayerVector(vec,mailid,0)
			end
		end
	end
end

function family_mgr_module:getMember(cid)
	return self._all_member[cid]
end

function family_mgr_module:getFamily(fid)
	return self._family[fid]
end

function family_mgr_module:checkFamilyName(name)
	if name == "" or string.len(name) > 32 then
		return false
	end

	for _, v in pairs(self._family) do
		if v.name == name then
			return false
		end
	end
	return true
end

function family_mgr_module:createFamily(d,cid,name)
	local family = {
		id = _equip_mgr:genFamilyId(),
		level = 1,
		name = d.name,
		flag = d.flag,
		type = d.type,
		limit = d.limit or 0,
		auto_agree = d.auto_agree or 0,
		desc = d.desc or "",
		notice = "",
		time = _func.getNowSecond(),
		power = FAMILY_DEFAULT_POWER,
		li_lv = 0,
		wu_lv = 0,
		yu_lv = 0,
		min_lv = 0,
		yao_lv = 0,
		gold = 0,
		mine = 0,
		stone = 0,
		wood = 0,
		active_value = 0,
		build_time = 0,


		leader = cid,
		leader_name = name,
		count = 1,
	}

	local member = {
		cid = cid,
		family_id = family.id,
		position = FAMILY_POSITION.FP_LEADER,
		nochat = 0,
	}

	self._family[family.id] = family
	self._family_member[family.id] = {member}
	self._family_apply[family.id] = {}
	self._family_event[family.id] = {}
	self._family_red_packet[family.id] = {}
	self._family_red_packet_record[family.id] = {}
	self._red_packet_id[family.id] = 0
	self._all_member[cid] = member

	_net_mgr:dbInsertData(_table.TAB_mem_family,family)
	_net_mgr:dbInsertData(_table.TAB_mem_family_member,member)

	self:addEvent(family.id,FAMILY_EVENT.FE_CREATE,name)
	return family
end

function family_mgr_module:getFamilyProtoInfo(fid)
	local pb = {}
	local family = self._family[fid]
	if family then
		pb.family = family
	end
	return pb
end

function family_mgr_module:deleteFamily(fid)
	local family = self._family[fid]
	if family == nil then
		return
	end

	self._family[fid] = nil

	local member = self._family_member[fid]
	self._family_member[fid] = nil

	for _, v in ipairs(member) do
		self._all_member[v.cid] = nil
	end

	self._family_apply[fid] = nil
	self._family_event[fid] = nil
	self:cleanRedPacket(fid)

	local mem = {family_id = fid}
	local apply = {family_id = fid}
	local event = {family_id = fid}

	_net_mgr:dbDeleteData(_table.TAB_mem_family,family)
	_net_mgr:dbDeleteData(_table.TAB_mem_family_member,mem)
	_net_mgr:dbDeleteData(_table.TAB_mem_family_apply,apply)
	_net_mgr:dbDeleteData(_table.TAB_mem_family_event,event)
	-- 通知
	for _, v in ipairs(member) do
		local player = _player_mgr:getPlayerByCid(v.cid)
		if player then
			player:sendMsg(SM.SM_FAMILY_DELETE,{i32=FAMILY_QUIT_TYPE.DELETE},"ProtoInt32")
			player:quitFamilyChatRoom()
		end
	end
end

function family_mgr_module:deleteMember(cid,type)
	local member = self._all_member[cid]
	if member == nil then
		return
	end

	self._all_member[cid] = nil
	local memvec = self._family_member[member.family_id]
	for i, v in ipairs(memvec) do
		if v.cid == member.cid then
			table.remove(memvec,i)
			break
		end
	end

	local family = self._family[member.family_id]
	family.count = #memvec

	_net_mgr:dbDeleteData(_table.TAB_mem_family_member,member)

	local player = _player_mgr:getPlayerByCid(member.cid)
	if player then
		player:sendMsg(SM.SM_FAMILY_DELETE,{i32=type},"ProtoInt32")
		player:quitFamilyChatRoom()
	end
end

function family_mgr_module:addMember(fid,cid)
	if self._all_member[cid] ~= nil then
		return
	end
	
	local member = {
		cid = cid,
		family_id = fid,
		position = FAMILY_POSITION.FP_MEMBER,
		nochat = 0,
	}

	self._all_member[cid] = member
	local memvec = self._family_member[fid]
	memvec[#memvec+1] = member
	local family = self._family[fid]
	family.count = #memvec

	_net_mgr:dbInsertData(_table.TAB_mem_family_member,member)

	local player = _player_mgr:getPlayerByCid(cid)
	if player then
		player:sendFamilyInfo()
		player:checkFirstJoinFamily()
		player:enterFamilyChatRoom()
	end

	self:getMemberInfo(cid,function (info)
		self:addEvent(fid,FAMILY_EVENT.FE_JOIN,info.name)
	end)
end

function family_mgr_module:getMemberInfo(cid,func)
	MSG_FUNC.doCoroFunc(function (coro)
		local info = _player_mgr:loadPlayerSimpleInfo({cid},_net_mgr._db_serid,coro)
		if #info > 0 then
			func(info[1])
		end
	end)
end

local function getFamilyMaxNum(lv)
	local cfg = _cfg.family_build_level(FAMILY_BUILDING.FB_MAIN,lv)
	if cfg then
		return cfg.param1
	end
	return 22
end

function family_mgr_module:applyFamily(fidvec,cid,level)
	local vec = {}
	for _, fid in ipairs(fidvec) do
		local family = self._family[fid]
		if family == nil or family.limit > level then
			goto continue
		end

		local maxnum = getFamilyMaxNum(family.level)
		if family.count >= maxnum then
			goto continue
		end

		if family.auto_agree > 0 then
			self:addMember(fid,cid)
			vec = nil
			break
		end

		local apply = self._family_apply[fid]
		if apply == nil or apply[cid] ~= nil then
			goto continue
		end

		local info = {
			family_id = fid,
			cid = cid,
			time = _func.getNowSecond(),
		}

		vec[#vec+1] = info
		::continue::
	end

	if vec == nil then
		return true
	end

	for _, v in ipairs(vec) do
		local apply = self._family_apply[v.family_id]
		apply[v.cid] = v
	end

	if #vec > 0 then
		_net_mgr:dbInsertDataVector(_table.TAB_mem_family_apply,vec)
		return true
	else
		return false
	end
end

function family_mgr_module:havePower(type,member)
	if member.position == FAMILY_POSITION.FP_LEADER then
		return true
	end

	local family = self._family[member.family_id]
	if family == nil then
		return false
	end

	local pindex = (member.position-2)*8+type
	return _func.is_bit_on(family.power,pindex)
end

function family_mgr_module:dealApply(fid,cid,res)
	local apply = self._family_apply[fid]
	local family = self._family[fid]
	if apply == nil or family == nil then
		return false
	end
	local maxnum = getFamilyMaxNum(family.level)
	if cid == 0 then
		if res > 0 then
			for _, v in pairs(apply) do
				if family.count >= maxnum then
					break
				end
				self:addMember(fid,v.cid)
			end
		end
		local delvec = {}
		for _, v in pairs(apply) do
			delvec[#delvec+1] = v
		end
		_net_mgr:dbDeleteDataVector(_table.TAB_mem_family_apply,delvec)
		self._family_apply[fid] = {}
	else
		local info = apply[cid]
		if info == nil then
			return false
		end
		if res > 0 then
			if family.count >= maxnum then
				return false
			end
			self:addMember(fid,info.cid)
		end
		apply[cid] = nil
		_net_mgr:dbDeleteData(_table.TAB_mem_family_apply,info)
	end
	return true
end

function family_mgr_module:changePower(fid,power)
	local family = self._family[fid]
	if family == nil then
		return
	end
	family.power = power
	_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
end

function family_mgr_module:addInviteCash(cid,fid)
	self._invite_cash[cid] = fid
end

function family_mgr_module:dealInvite(cid,res)
	local fid = self._invite_cash[cid]
	if fid == nil then
		return
	end
	self._invite_cash[cid] = nil
	if res > 0 then
		local family = self._family[fid]
		if family == nil then
			return
		end

		local maxnum = getFamilyMaxNum(family.level)
		if family.count >= maxnum then
			return
		end

		self:addMember(fid,cid)
	end
end

function family_mgr_module:checkPowerBig(m1,m2)
	local lv1 = FAMILY_POSITION_LEVEL[m1.position]
	local lv2 = FAMILY_POSITION_LEVEL[m2.position]
	return lv1 < lv2
end

function family_mgr_module:getLeaderInfo(coro,fid,cid)
	local vec = _player_mgr:loadPlayerSimpleInfo({cid},_net_mgr._db_serid,coro)
	if #vec > 0 then
		local family = self._family[fid]
		family.leader = cid
		family.leader_name = vec[1].name
	end
end

function family_mgr_module:changePosition(fid,cid,position)
	local memvec = self._family_member[fid]
	if memvec == nil then
		return
	end
	local member = self:getMember(cid)
	local old = nil
	if position < FAMILY_POSITION.FP_JINGYING then
		for _, v in ipairs(memvec) do
			if v.position == position and v.cid ~= cid then
				old = v
				break
			end
		end
	end

	if old then
		old.position = FAMILY_POSITION.FP_MEMBER
	end
	member.position = position

	_net_mgr:dbUpdateDataVector(_table.TAB_mem_family_member,{member,old})

	if position == FAMILY_POSITION.FP_LEADER then
		MSG_FUNC.doCoroFunc(function (coro,...)
			self:getLeaderInfo(coro,...)
		end,fid,cid)
	end
end

function family_mgr_module:changeFlag(fid,flag)
	local family = self._family[fid]
	if family then
		family.flag = flag
		_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	end
end

function family_mgr_module:changeDesc(fid,desc)
	local family = self._family[fid]
	if family then
		family.desc = desc
		_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	end
end

function family_mgr_module:changeNotice(fid,desc)
	local family = self._family[fid]
	if family then
		family.notice = desc
		_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	end
end

function family_mgr_module:updateMember(mem)
	_net_mgr:dbUpdateData(_table.TAB_mem_family_member,mem)
end

function family_mgr_module:setApply(fid,limit,auto_agree)
	local family = self._family[fid]
	if family then
		family.limit = limit
		family.auto_agree = auto_agree
		_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	end
end

function family_mgr_module:selfRecommend(mem,player)
	local family = self._family[mem.family_id]
	if family == nil then
		return false
	end

	local linfo = _player_mgr:getPlayerSimpleInfo(family.leader)
	if linfo == nil or linfo.online > 0 then
		return false
	end

	local hour = math.floor((_func.getNowSecond()-linfo.logout_time)/3600)
	if hour < 3*24 then
		return false
	elseif hour < 7*24 then
		if mem.position > FAMILY_POSITION.FP_FBZ then
			return false
		end
	elseif hour < 15*24 then
		if mem.position >= FAMILY_POSITION.FP_JINGYING then
			return false
		end
	end

	local lmem = self:getMember(family.leader)

	lmem.position = FAMILY_POSITION.FP_MEMBER
	mem.position = FAMILY_POSITION.FP_LEADER

	family.leader = mem.cid
	family.leader_name = player:getName()

	_net_mgr:dbUpdateDataVector(_table.TAB_mem_family_member,{mem,lmem})
	return true
end

local EVENT_OUT_TIME = 3*86400

local function checkDeleteEvent(evv)
	local delvec = {}
	local d1,d2 = 0,0
	local now = _func.getNowSecond()
	local pend = false
	for i, vec in ipairs(evv) do
		for j, v in ipairs(vec.data) do
			if now - v.time > EVENT_OUT_TIME then
				delvec[#delvec+1] = v
				d2 = j
			else
				pend = true
				break
			end
		end
		if pend then
			break
		end
		d1 = i
		d2 = 0
	end

	if #delvec > 0 then
		_net_mgr:dbDeleteDataVector(_table.TAB_mem_family_event,delvec)

		for i = 1, d1 do
			table.remove(evv,1)
		end
		if d2 > 0 then
			local vec = evv[1]
			for i = 1, d2 do
				table.remove(vec.data,1)
			end
		end
	end
end

local function getLastEvent(evv)
	local vec = evv[#evv]
	if vec == nil then
		return nil
	else
		return vec.data[#vec.data]
	end
end

function family_mgr_module:addEvent(fid,type,str1,str2,int1,int2)
	local event = self._family_event[fid]
	if event == nil then
		return
	end

	local last = getLastEvent(event)
	local ev = {
		family_id = fid,
		id = last ==nil and 1 or last.id+1,
		type = type,
		time = _func.getNowSecond(),
		string1 = str1,
		string2 = str2,
		int1 = int1,
		int2 = int2,
	}

	pushEvent(event,ev)
	_net_mgr:dbInsertData(_table.TAB_mem_family_event,ev)
	checkDeleteEvent(event)
end

function family_mgr_module:buildUpgrade(fid,type,position)
	if position > FAMILY_POSITION.FP_FBZ and type ~= position then
		return false
	end
	
	local family = self:getFamily(fid)
	local key = BUILD_KEY[type]
	local lv = family[key]
	local cfg = _cfg.family_build_level(type,lv+1)
	if cfg == nil then
		return false
	end

	if cfg.limit > family.level or cfg.gold > family.gold or
		cfg.mine > family.mine or cfg.stone > family.stone or
		cfg.wood > family.wood then
		return false
	end

	family[key] = lv + 1
	family.gold = family.gold - cfg.gold
	family.mine = family.mine - cfg.mine
	family.stone = family.stone - cfg.stone
	family.wood = family.wood - cfg.wood
	family.buildUpgrade = _func.getNowSecond()
	_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	return true,lv+1
end

function family_mgr_module:newWeek5hCome()
	local vec = {}
	for _, v in pairs(self._family) do
		if v.active_value > 0 then
			v.active_value = 0
			vec[#vec+1] = v
		end
	end
	if #vec > 0 then
		_net_mgr:dbUpdateDataVector(_table.TAB_mem_family,vec)
	end
end

function family_mgr_module:addActiveValue(fid,val)
	local family = self._family[fid]
	if family then
		family.active_value = family.active_value + val
		_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
	end
end

function family_mgr_module:addGold(fid,gold,nosend)
	local family = self:getFamily(fid)
	if family then
		family.gold = family.gold + gold
		if not nosend then
			_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
		end
	end
end

local MATERIAL_TYPE = {
	MINE = 1,
	STONE = 2,
	WOOD = 3,
}

function family_mgr_module:addMaterial(fid,mat,name)
	local family = self:getFamily(fid)
	if family == nil then
		return
	end

	for k, v in pairs(mat) do
		if k == MATERIAL_TYPE.MINE then
			family.mine = family.mine + v
		elseif k == MATERIAL_TYPE.STONE then
			family.stone = family.stone + v
		elseif k == MATERIAL_TYPE.WOOD then
			family.wood = family.wood + v
		end
		if v > 0 then
			self:addEvent(fid,FAMILY_EVENT.FE_DONATE,name,nil,k,v)
		end
	end

	_net_mgr:dbUpdateData(_table.TAB_mem_family,family)
end

function family_mgr_module:addRedPacket(fid,type,cid,job,name,value,num)
	local family = self:getFamily(fid)
	if family == nil then
		return
	end

	local id = self._red_packet_id[fid]
	self._red_packet_id[fid] = id + 1
	local red_packet = {
		family_id = fid,
		id = id+1,
		cid = cid,
		type = type,
		num = num,
		value = value,
		job = job,
		name = name,
		time = _func.getNowSecond(),
	}

	local vec = self._family_red_packet[fid]
	vec[#vec+1] = red_packet
	_net_mgr:dbInsertData(_table.TAB_mem_family_red_packet,red_packet)
end

function family_mgr_module:getRedPacket(fid,id)
	local vec = self._family_red_packet[fid]
	for _, v in ipairs(vec) do
		if v.id == id then
			return v
		end
	end
	return nil
end

function family_mgr_module:checkRedPacket(fid,id,cid,value,maxnum)
	local record = self._family_red_packet_record[fid][id]
	if record == nil then
		record = {}
		self._family_red_packet_record[fid][id] = record
	end
	if #record >= maxnum  then
		return 0
	end

	local getval = 0
	for _, v in ipairs(record) do
		if v.cid == cid then
			return 0
		end
		getval = getval + v.value
	end

	local lessnum = maxnum - #record
	if lessnum == 1 then
		return value - getval
	end

	local avg = math.floor((value-getval)/lessnum)
	getval = math.random(avg*2)
	return getval
end

function family_mgr_module:addRedPacketRecord(fid,id,cid,value,job,name)
	local record = self._family_red_packet_record[fid][id]
	if record == nil then
		record = {}
		self._family_red_packet_record[fid][id] = {}
	end

	local rinfo = {
		family_id = fid,
		id = id,
		cid = cid,
		value = value,
		job = job,
		name = name,
	}
	record[#record+1] = rinfo
	_net_mgr:dbInsertData(_table.TAB_mem_family_red_packet_record,rinfo)
end

function family_mgr_module:isApply(fid,cid)
	return self._family_apply[fid][cid] ~= nil
end

function family_mgr_module:getRedPackeNum(fid)
	local num = 0
	local packvec = self._family_red_packet[fid]
	local record = self._family_red_packet_record[fid]

	if packvec == nil then
		return num
	end

	for _, p in ipairs(packvec) do
		local rv = record[p.id]
		if rv and #rv >= p.num then
			num = num + 1
		end
	end
	return num
end

return family_mgr_module