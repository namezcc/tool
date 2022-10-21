local PlayerModule = {}
local _Net = NetModule

function PlayerModule:init()
	Event:AddEvent(EventID.ON_CONNECT_CHAT_SERVER,self.onChatConnect)


	_Net:AddMsgCallBack(SMCODE.SM_PLAYER_INFO,self.onPlayerInfo,"SmPlayerInfo")
	_Net:AddMsgCallBack(SMCODE.SM_STORAGE_INFO,self.onStorageInfo,"StorageInfo")
	-- _Net:AddMsgCallBack(SMCODE.SM_EQUIP_INFO,self.onEquipInfo,"SmEquipInfo")
	_Net:AddMsgCallBack(SMCODE.SM_SERVER_TIME,self.onServerTime,"SmServerTime")
	_Net:AddMsgCallBack(SMCODE.SM_WUHUN_INFO,self.onShowData,"SmWuhunInfo")
	_Net:AddMsgCallBack(SMCODE.SM_CURRENCY_INFO,self.onShowData,"ProtoPairInt32Array","SM_CURRENCY_INFO")
	-- _Net:AddMsgCallBack(SMCODE.SM_ITEM_BAG,self.onShowData,"SmItemBag")
	-- _Net:AddMsgCallBack(SMCODE.SM_DROP_ITEM,self.onShowData,"DropItemList")
	_Net:AddMsgCallBack(SMCODE.SM_ENTER_MAP,self.onShowData,"SmEnterMap","SM_ENTER_MAP")
	-- _Net:AddMsgCallBack(SMCODE.SM_CLIENT_RECORD,self.onShowData,"SmRecordInfo","SM_CLIENT_RECORD")
	-- _Net:AddMsgCallBack(SMCODE.SM_MEM_ITEM_INFO,self.onShowData,"SmMemItem","SM_MEM_ITEM_INFO")
	_Net:AddMsgCallBack(SMCODE.SM_RELATION_INFO,self.onShowData,"SmRelationInfo","SM_RELATION_INFO")
	_Net:AddMsgCallBack(SMCODE.SM_RELATION_DELETE,self.onShowData,"PInt64","SM_RELATION_DELETE")
	_Net:AddMsgCallBack(SMCODE.SM_CHAT_SERVER_INFO,self.onChatServerInfo,"ProtoInt32Array","SM_CHAT_SERVER_INFO")
	_Net:AddMsgCallBack(SMCODE.SM_CHAT_INFO,self.onShowData,"ChatMsg","SM_CHAT_INFO")
	_Net:AddMsgCallBack(SMCODE.SM_REPLY_RES,self.onShowData,"SmReplyRes","SM_REPLY_RES")

	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_LIST,self.onShowData,"SmFamilyList","SM_FAMILY_LIST")
	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_INFO,self.onShowData,"SmFamilyInfo","SM_FAMILY_INFO")
	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_DELETE,self.onShowData,"ProtoInt32","SM_FAMILY_DELETE")
	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_MEMBER,self.onShowData,"SmFamilyMember","SM_FAMILY_MEMBER")
	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_APPLY,self.onShowData,"SmPlayerSimpleInfo","SM_FAMILY_APPLY")
	_Net:AddMsgCallBack(SMCODE.SM_FAMILY_INVITE,self.onShowData,"SmFamilyInvite","SM_FAMILY_INVITE")
	_Net:AddMsgCallBack(SMCODE.SM_DRAW_CARD_REWARD,self.onShowData,"SmDrawInfo","SM_DRAW_CARD_REWARD")
	
	-- _Net:AddMsgCallBack(SMCODE.SM_BONE_INFO,self.onShowData,"SmBoneInfo","SM_BONE_INFO")
	-- _Net:AddMsgCallBack(SMCODE.SM_CORE_INFO,self.onShowData,"SmCoreInfo","SM_CORE_INFO")
	
	-- _Net:AddMsgCallBack(SMCODE.SM_ANQI_INFO,self.onShowData,"SmAnqiInfo","SM_ANQI_INFO")
	

	-----------------
	CMD:AddCmdCall(self.ShowMid,"p","pam:mid show mid")
	CMD:AddCmdCall(self.doHotLoad,"hot","hot load")
	CMD:AddCmdCall(self.doDebug,"db","send cmd debug")
	CMD:AddCmdCall(self.doGetServerTime,"st","server tiem")
	CMD:AddCmdCall(self.doSpiritInherit,"spirit","pam:index_id level index")
	CMD:AddCmdCall(self.doRequest,"req","request test")
	CMD:AddCmdCall(self.doShowStor,"stor","pam:type slot or all -- show stor")
	CMD:AddCmdCall(self.doSetRecord,"rd","pam:type val ...")
	CMD:AddCmdCall(self.doItemLock,"lk","pam:type id val")
	CMD:AddCmdCall(self.doEnterChat,"cc","pam: 链接聊天服")
	CMD:AddCmdCall(self.doChat,"chat","pam:type tocid roomid msg")
	CMD:AddCmdCall(self.doCreateFamily,"fm-c","pam:name")
	
	CMD:AddCmdCall(self.doSendMsg,"me","pam:id -- make equip",{CMCODE.CM_MAKE_EQUIP,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"mv","pam:fst fidx tst tidx -- move item",{CMCODE.CM_MOVE_ITEM,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"use","pam:id num -- use bag item",{CMCODE.CM_USE_ITEM,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-sg","pam:storage slot -- equip strong",{CMCODE.CM_EQUIP_STRONG,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-sgr","pam:storage slot -- equip strong recycle",{CMCODE.CM_EQUIP_STRONG_RECYCLE,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-jl","pam:storage slot -- equip jinglian",{CMCODE.CM_EQUIP_JINGLIAN,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-star","pam:storage slot -- equip star",{CMCODE.CM_EQUIP_STAR,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-starr","pam:storage slot -- equip star recycle",{CMCODE.CM_EQUIP_STAR_RECYCLE,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-flon","pam:epst slot bagslot flslot -- equip fuling",{CMCODE.CM_EQUIP_FULING_ON,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"ep-floff","pam:epst slot flslot -- equip fuling off",{CMCODE.CM_EQUIP_FULING_OFF,"ProtoInt32Array"})

	CMD:AddCmdCall(self.doSendMsg,"bn-str","pam:slot 0 bagslot num... -- bone strong",{CMCODE.CM_BONE_STRONG,"ProtoPairInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"bn-jl","pam:slot -- bone jinglian",{CMCODE.CM_BONE_JINGLIAN,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"bn-star","pam:slot bagslot... -- bone star",{CMCODE.CM_BONE_STAR,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"bn-hs","pam:slot id bagslot num... -- bone hunsui",{CMCODE.CM_BONE_HUNSUI,"ProtoPairInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"pick","pam:time id num",{CMCODE.CM_PICK_ITEM,"ProtoInt32Array"})

	CMD:AddCmdCall(self.doSendMsg,"aq-str","pam: -- anqi strong",{CMCODE.CM_ANQI_STRONG,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"hq-str","pam: -- hunqi strong",{CMCODE.CM_HUNQI_STRONG,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"wing-fl","pam:id -- wing fuling",{CMCODE.CM_WING_FULING,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"coll","pam: id memid ",{CMCODE.CM_SELF_COLLECTION,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"rl-info","pam: ",{CMCODE.CM_GET_RELATION_INFO,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"rl-apply","pam: cid",{CMCODE.CM_FRIEND_APPLY,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"rl-apply-res","pam: cid res",{CMCODE.CM_FRIEND_RESP_APPLY,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"rl-black","pam: cid res",{CMCODE.CM_ADD_BLACK_LIST,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"rl-del","pam: cid",{CMCODE.CM_FRIEND_DELETE,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"rl-like","pam: cid",{CMCODE.CM_FRIEND_LIKE,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"rl-flower","pam: cid id num",{CMCODE.CM_FRIEND_SEND_FLOWER,"PInt64Array"})
	

	CMD:AddCmdCall(self.doSendMsg,"cpos","pam: x z",{CMCODE.CM_CHAT_UPDATE_POS,"ProtoInt32Array",true})
	CMD:AddCmdCall(self.doSendMsg,"draw","pam: active pool num",{CMCODE.CM_DRAW_CARD,"ProtoInt32Array"})
	
	
	CMD:AddCmdCall(self.doSendMsg,"fm-fl","family list",{CMCODE.CM_FAMILY_GET_LIST,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-del","family disband",{CMCODE.CM_FAMILY_DISBAND,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-q","family quit",{CMCODE.CM_FAMILY_QUIT,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-info","family info",{CMCODE.CM_FAMILY_GET_INFO,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-mem","family member",{CMCODE.CM_FAMILY_GET_MEMBER,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-gapl","family get apply",{CMCODE.CM_FAMILY_GET_APPLY,"null"})
	CMD:AddCmdCall(self.doSendMsg,"fm-apl","family apply	p:id...",{CMCODE.CM_FAMILY_APPLY,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"fm-dapl","family dela apply	p:cid res",{CMCODE.CM_FAMILY_DEAL_APPLY,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"fm-spow","family set power	P:val",{CMCODE.CM_FAMILY_SET_POWER,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"fm-iv","family invite	p:cid",{CMCODE.CM_FAMILY_INVITE,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"fm-div","family deal invite	p:res",{CMCODE.CM_FAMILY_DEAL_INVITE,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"fm-kick","family kick	p:cid",{CMCODE.CM_FAMILY_KICK,"PInt64"})
	CMD:AddCmdCall(self.doSendMsg,"fm-spos","family set position	p:cid pos",{CMCODE.CM_FAMILY_SET_POSITION,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"fm-flag","family set flag	p:id",{CMCODE.CM_FAMILY_SET_FLAG,"ProtoInt32"})
	CMD:AddCmdCall(self.doSendMsg,"fm-desc","family set desc	p:desc",{CMCODE.CM_FAMILY_SET_DESC,"PString"})
	CMD:AddCmdCall(self.doSendMsg,"fm-chat","family ban chat	p:cid res",{CMCODE.CM_FAMILY_BAN_CHAT,"PInt64Array"})
	CMD:AddCmdCall(self.doSendMsg,"fm-sapl","family set apply  p:lv auto",{CMCODE.CM_FAMILY_SET_APPLY,"ProtoInt32Array"})
	CMD:AddCmdCall(self.doSendMsg,"fm-gsend","family get send info ",{CMCODE.CM_FAMILY_GET_SEND_INFO,"null"})
	

end

function PlayerModule:initdata()
	self._storage = {}
end

---------------------- msg ---------------------------------

function PlayerModule:onPlayerInfo(data)
	if not IS_SINGLE then
		print("enter game ",self._account)
		return
	end
	print("*********** player info ---")
	printTable(data)
	
end

function PlayerModule:onStorageInfo(data)
	if not IS_SINGLE then
		return
	end

	if #data.slots <= 5 then
		print("------ stoage ----")
		printTable(data)
	end

	for i, v in ipairs(data.slots) do
		local st = table.get_table(self._storage,v.storage)
		st[v.slot] = v
	end
end

function PlayerModule:onEquipInfo(data)
	if not IS_SINGLE then
		return
	end
	print("-------- equip ----")
	printTable(data)
end

function PlayerModule:onServerTime(data)
	if not IS_SINGLE then
		return
	end
	print("server time")
	printTable(data)
end

function PlayerModule:onShowData(data,ext,pbstr)
	if not IS_SINGLE then
		return
	end
	print("")
	print(ext or "\t","\t",pbstr)
	printTable(data)
end

function PlayerModule:onChatServerInfo(d,ext)
	print(ext)
	printTable(d)
	self._chat_port = d.i32[1]
	self._chat_key = d.i32[2]
end

----------------  CMD ---------------------

local TN = tonumber

function PlayerModule:ShowMid( pam )
	local mid = TN(pam[1])
	if mid == 0 or mid == nil then
		if SHOW_MID == true then
			SHOW_MID = false
		else
			SHOW_MID = true
		end
	else
		print("get msg id ",mid,"=",MID_MAP[mid])
	end
end

function PlayerModule:sendMsg(mid,pb,proto)
	self:SendGameData(proto,mid,pb)
end

function PlayerModule:sendChatMsg(mid,pb,proto)
	_Net:SendData(self._chat_sock,proto,mid,pb)
end

function PlayerModule:doHotLoad()
	self:sendMsg(CMCODE.CM_TEST_HOT_LOAD,{},"ProtoInt32")
end

local CMD_TYPE = {
	none = 0,
	item = 1,
	clearbag = 2,
	money = 3,
	exp = 4,
	level = 5,
	hunshi = 6,
	task_process = 7,
	task_state = 8,
	allitem = 9,
	monster = 50,
	drop = 100,
}

function PlayerModule:doDebug(pam)
	local data = {}

	for i, v in ipairs(pam) do
		if i == 1 then
			data[i] = CMD_TYPE[v]
		else
			data[i] = TN(v)
		end
	end

	self:sendMsg(CMCODE.CM_DEBUG,{i32=data},"ProtoInt32Array")
end

function PlayerModule:doGetServerTime(pam)
	local pb = {
		client_time = 0,
	}

	self:sendMsg(CMCODE.CM_SERVER_TIME,pb,"CmServerTime")
end

function PlayerModule:doSpiritInherit(pam)
	local pb = {}
	for i = 1, 3 do
		pb[i] = TN(pam[i])
	end

	self:sendMsg(CMCODE.CM_SPIRIT_INHERIT,{i32=pb},"ProtoInt32Array")
end

function PlayerModule:doRequest(pam)
	local pb = {
		i32 = 555,
	}

	-- self:sendMsg(CMCODE.CM_REQUEST_TEST,pb,"ProtoInt32")
	self:sendMsg(CMCODE.CM_GAME_REQUEST_TEST,pb,"ProtoInt32")
	
end

function PlayerModule:doShowStor(pam)
	local st = TN(pam[1])
	local slot = nil
	if pam[2] then
		slot = TN(pam[2])
	end

	local tab = self._storage[st]
	if slot then
		tab = tab[slot]
	end

	printTable(tab)
end

function PlayerModule:doSetRecord(pam)
	local msg = {}
	for i = 1, #pam,2 do
		msg[#msg+1] = {type=TN(pam[i]),value=TN(pam[i+1])}
	end

	self:sendMsg(CMCODE.CM_CLIENT_RECORD_UPDATE,{info=msg},"SmRecordInfo")
end

function PlayerModule:doItemLock(p)
	local pb = {
		type = TN(p[1]),
		id = TN(p[2]),
		lock = TN(p[3]),
	}
	self:sendMsg(CMCODE.CM_SET_ITEM_LOCK,pb,"CmItemLock")
end

function PlayerModule:doEnterChat(p)
	if self._chat_port then
		print("to conn chatserver ip",self._login_ip,self._chat_port)
		local res = _Net:Connect(self._login_ip,self._chat_port,EventID.ON_CONNECT_CHAT_SERVER,self)
		if res == false then
			print("connect chat server fail",self._login_ip,self._chat_port)
		else
			print("conn chat success")
		end
	end
end

function PlayerModule:onChatConnect(sock)
	self._chat_sock = sock
	local pb = {
		data = {self.cid,self._chat_key}
	}
	print("on chat conn sock",sock)
	self:sendChatMsg(CMCODE.CM_CHAT_CHECK_ENTER,pb,"PInt64Array")
end

function PlayerModule:doChat(p)
	local pb = {
		type = TN(p[1]),
		cid = self.cid,
		tocid = TN(p[2]),
		roomid = TN(p[3]),
		msg = p[4],
	}

	self:sendChatMsg(CMCODE.CM_CHAT,pb,"ChatMsg")
end

function PlayerModule:doCreateFamily(p)
	local pb = {
		name = p[1],
		flag = 1,
		type = 1,
	}
	self:sendMsg(CMCODE.CM_FAMILY_CREATE,pb,"CmCreateFamily")
end

function PlayerModule:doSendMsg(pam,ext)
	local proc = ext[1]
	local proto = ext[2]
	local ischat = ext[3] or false

	local pb = {}

	if proto == "ProtoInt32" then
		pb.i32 = TN(pam[1])
	elseif proto == "ProtoInt32Array" then
		local vec = {}
		for i, v in ipairs(pam) do
			vec[#vec+1] = TN(v)
		end
		pb.i32 = vec
	elseif proto == "ProtoPairInt32Array" then
		local vec = {}
		for i = 1, #pam, 2 do
			vec[#vec+1] = {
				data1 = TN(pam[i]),
				data2 = TN(pam[i+1]),
			}
		end
		pb.list = vec
	elseif proto == "PInt64" then
		pb.data = TN(pam[1])
	elseif proto == "PInt64Array" then
		local vec = {}
		for i, v in ipairs(pam) do
			vec[#vec+1] = TN(v)
		end
		pb.data = vec
	elseif proto == "PInt64Pair32Array" then
		pb.i64 = TN(pam[1])
		local vec = {}
		for i = 2, #pam,2 do
			vec[#vec+1] = {
				data1 = TN(pam[i]),
				data2 = TN(pam[i+1]),
			}
		end
		pb.array = vec
	elseif proto == "PString" then
		pb.data = pam[1]
	end
	if ischat then
		self:sendChatMsg(proc,pb,proto)
	else
		self:sendMsg(proc,pb,proto)
	end
end

------------------------------------------




return PlayerModule