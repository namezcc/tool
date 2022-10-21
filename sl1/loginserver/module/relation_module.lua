local _func = LFUNC
local _table = TABLE_INDEX
local _cfg = CFG_DATA

local _player_mgr = nil
local _net_mgr = nil


local RELATION_TYPE = {
	RT_NONE = 0,
	RT_APPLY = 1,		--申请
	RT_FRIEND = 2,		--好友
	RT_BLACK = 3,		--黑名单
}

local relation_module = {}

function relation_module:init()
	
	_net_mgr = MOD.net_mgr_module
	_player_mgr = MOD.player_mgr_module

	MSG_FUNC.bind_async_player_proto(CM.CM_GET_RELATION_INFO,self.onGetRelationInfo,"ProtoInt32",60)
	MSG_FUNC.bind_async_player_proto(CM.CM_FRIEND_APPLY,self.onFriendApply,"PInt64",5)
	MSG_FUNC.bind_async_player_proto(CM.CM_FRIEND_RESP_APPLY,self.onFriendRespApply,"PInt64Array")
	MSG_FUNC.bind_async_player_proto(CM.CM_ADD_BLACK_LIST,self.onAddBlackList,"PInt64Array")
	MSG_FUNC.bind_player_proto_func(CM.CM_FRIEND_DELETE,self.onFriendDelete,"PInt64")
	MSG_FUNC.bind_player_proto_func(CM.CM_FRIEND_RECOMMEND,self.onFriendRecommend,"ProtoInt32",30)
	MSG_FUNC.bind_async_player_proto(CM.CM_FRIEND_SEARCH,self.onFriendSearch,"PString",5)
	MSG_FUNC.bind_async_player_proto(CM.CM_FRIEND_LIKE,self.onFriendLike,"PInt64")
	MSG_FUNC.bind_async_player_proto(CM.CM_FRIEND_SEND_FLOWER,self.onFriendSendFlower,"PInt64Array")
	

end

function relation_module:initDB(d)
	local relation = {}
	if d.relation then
		for _, v in ipairs(d.relation) do
			relation[v.rcid] = v
		end
	end

	if d.friend_like then
		self._friend_like = d.friend_like
	else
		self._friend_like = {
			time = _func.getNowSecond(),
			data = {},
		}
	end

	self._relation = relation
	self._friend_recommend = {}
end

function relation_module:sendFriendLike()
	self:sendMsg(SM.SM_FRIEND_LIKE,self._friend_like,"SmFriendLike")
end

function relation_module:getRelation(rcid)
	local info = self._relation[rcid]
	if info then
		return info.type
	end
	return 0
end

function relation_module:setRelation(rcid,type,coro)
	local info = self._relation[rcid]
	if info == nil then
		info = {
			cid = self.cid,
			rcid = rcid,
			type = type,
			value = 0,
		}
		self._relation[rcid] = info
	end

	info.type = type
	info.time = _func.getNowSecond()
	self:dbUpdateData(_table.TAB_mem_chr_relation,info)

	local infovec = _player_mgr:loadPlayerSimpleInfo({rcid},self.db_serid,coro)
	local data = {info}
	local pb = {
		data = data,
		info = infovec,
		update = 1,
	}
	self:sendMsg(SM.SM_RELATION_INFO,pb,"SmRelationInfo")
end

function relation_module:sendRelationInfo(info)
	local data = {info}
	local pb = {
		data = data,
		update = 1,
	}
	self:sendMsg(SM.SM_RELATION_INFO,pb,"SmRelationInfo")
end

function relation_module:deleteRelation(rcid)
	local info = self._relation[rcid]
	if info == nil then
		return
	end
	self._relation[rcid] = nil
	self:dbDeleteData(_table.TAB_mem_chr_relation,info)
	self:sendMsg(SM.SM_RELATION_DELETE,{data=rcid},"PInt64")
end

function relation_module:onGetRelationInfo(d,coro)
	local idvec = {}
	local dvec = {}
	for cid, v in pairs(self._relation) do
		idvec[#idvec+1] = cid
		dvec[#dvec+1] = v
	end

	local infovec = _player_mgr:loadPlayerSimpleInfo(idvec,self.db_serid,coro)
	local pb = {
		data = dvec,
		info = infovec,
	}
	self:sendMsg(SM.SM_RELATION_INFO,pb,"SmRelationInfo")
	self:sendFriendLike()
end

function relation_module:onFriendApply(d,coro)
	local rtval = self:getRelation(d.data)
	if rtval == RELATION_TYPE.RT_FRIEND or rtval == RELATION_TYPE.RT_BLACK then
		return
	end

	rtval = _player_mgr:getRelation(d.data,self.cid,self.db_serid,coro)
	if rtval ~= RELATION_TYPE.RT_NONE then
		return
	end

	_player_mgr:setRelation(d.data,RELATION_TYPE.RT_APPLY,self.cid,self.db_serid,coro)
	self:replyMsg(CM.CM_FRIEND_APPLY,ERROR_CODE.ERR_SUCCESS)
end

function relation_module:onFriendRespApply(d,coro)
	if #d.data ~= 2 then
		return
	end

	local rcid = d.data[1]
	local res = d.data[2]
	local rtype = self:getRelation(rcid)
	if rtype ~= RELATION_TYPE.RT_APPLY then
		return
	end

	if res == 0 then
		self:deleteRelation(rcid)
	else
		rtype = _player_mgr:getRelation(rcid,self.cid,self.db_serid,coro)
		if rtype == RELATION_TYPE.RT_BLACK then
			return
		end
		self:setRelation(rcid,RELATION_TYPE.RT_FRIEND,coro)
		_player_mgr:setRelation(rcid,RELATION_TYPE.RT_FRIEND,self.cid,self.db_serid,coro)
	end
end

function relation_module:onAddBlackList(d,coro)
	if #d.data ~= 2 then
		return
	end

	local rcid = d.data[1]
	local res = d.data[2]
	local rtype = self:getRelation(rcid)
	if res == 0 then
		if rtype ~= RELATION_TYPE.RT_BLACK then
			return
		end
		self:deleteRelation(rcid)
	else
		if rtype == RELATION_TYPE.RT_BLACK then
			return
		end
		self:setRelation(rcid,RELATION_TYPE.RT_BLACK,coro)
		if rtype == RELATION_TYPE.RT_FRIEND then
			_player_mgr:deleteRelation(rcid,self.cid,self.db_serid)
		end
	end
end

function relation_module:onFriendDelete(d)
	local rtype = self:getRelation(d.data)
	if rtype ~= RELATION_TYPE.RT_FRIEND then
		return
	end

	self:deleteRelation(d.data)
	_player_mgr:deleteRelation(d.data,self.cid,self.db_serid)
end

local function sort_friend(p1,p2)
	if p1._diff_level == p2._diff_level then
		if p1._diff_hunshi == p2._diff_hunshi then
			return p1._cid < p2._cid
		else
			return p1._diff_hunshi < p2._diff_hunshi
		end
	else
		return p1._diff_level < p2._diff_level
	end
end

function relation_module:onFriendRecommend()
	local allplayer = _player_mgr:getAllPlayer()
	local playervec = {}
	local check = self._friend_recommend
	local selfcid = self.cid
	for cid, player in pairs(allplayer) do
		if cid ~= selfcid and check[cid] == nil then
			local rtype = self:getRelation(cid)
			local trtype = player:getRelation(selfcid)
			if rtype == RELATION_TYPE.RT_NONE and trtype == RELATION_TYPE.RT_NONE then
				playervec[#playervec+1] = {
					_cid = cid,
					_player = player,
					_diff_level = math.abs(self:getLevel()-player:getLevel()),
					_diff_hunshi = math.abs(self:getHunshiLevel()-player:getHunshiLevel()),
				}
			end
		end
	end
	
	local pb = {}

	if #playervec > 0 then
		table.sort(playervec,sort_friend)
		local num = 5
		if #playervec < num then
			num = #playervec
		end

		for i = 1, num do
			check[playervec[i]._cid] = true
			pb[#pb+1] = _player_mgr:genSimpleInfo(playervec[i]._player,1)
		end
	end
	self:sendMsg(SM.SM_FRIEND_RECOMMEND,{data = pb},"SmPlayerSimpleInfo")
end

function relation_module:onFriendSearch(d,coro)
	if d.data == "" then
		return
	end
	local allplayer = _player_mgr:getAllPlayer()
	local pb = {}
	for _, v in pairs(allplayer) do
		if v._chr_info.name == d.data then
			pb[#pb+1] = _player_mgr:genSimpleInfo(v,1)
			break
		end
	end

	if #pb == 0 then
		local msg = _net_mgr:requestDbMsg(self.db_serid,SERVER_MSG.IM_DB_FRIEND_SEARCH,d,"PString",coro,"PlayerSimpleInfoList")
		if msg then
			for _, v in ipairs(msg.data) do
				pb[#pb+1] = v
			end
		end
	end
	self:sendMsg(SM.SM_FRIEND_RECOMMEND,{data = pb},"SmPlayerSimpleInfo")
end

function relation_module:onFriendLike(d)
	local info = self._relation[d.data]

	if info == nil or info.type ~= RELATION_TYPE.RT_FRIEND then
		return
	end

	local like = self._friend_like
	if TIME_UTIL.day_zero() ~= TIME_UTIL.day_zero(like.time) then
		like.data = {}
	end

	if #like.data >= 10 then
		return
	end
	for _, cid in ipairs(like.data) do
		if cid == d.data then
			return
		end
	end

	info.value = info.value + 10
	self:dbUpdateData(_table.TAB_mem_chr_relation,info)

	like.time = _func.getNowSecond()
	like.data[#like.data+1] = d.data
	_net_mgr:dbUpdateData(_table.TAB_mem_chr_friend_like,like,self.cid)

	self:sendFriendLike()
	self:sendRelationInfo(info)

	-- 别人处理
	local iplayer = _player_mgr:getPlayerByCid(d.data)
	if iplayer then
		iplayer:getFriendLike(self.cid,true)
	else
		_player_mgr:addOfflineEvent(d.data,OFFLINE_EVENT.ON_GET_LIKE,0,self.cid,0)
	end
end

function relation_module:getFriendLike(cid,issend)
	local info = self._relation[cid]
	if info == nil or info.type ~= RELATION_TYPE.RT_FRIEND then
		return
	end

	info.value = info.value + 10
	self:dbUpdateData(_table.TAB_mem_chr_relation,info)
	self:addRecord(RECORD_TYPE.RT_FRIEND_CHARM,10)
	if issend then
		self:sendRelationInfo(info)
	end
end

function relation_module:onFriendSendFlower(d)
	if #d.data ~= 3 then
		return
	end

	local cid = d.data[1]
	local itemid = d.data[2]
	local num = d.data[3]
	if num <= 0 then
		return
	end

	local info = self._relation[cid]
	if info == nil or info.type ~= RELATION_TYPE.RT_FRIEND then
		return
	end

	local itemcfg = _cfg.item(itemid)
	if itemcfg == nil or itemcfg.type ~= ITEM_SUB_TYPE.FLOWER then
		return
	end

	local cost = _func.make_cfg_item(itemid,ITEM_TYPE.IT_ITEM,num)
	if not self:delBagCheck(cost) then
		return
	end

	self:delBag(cost,CHANGE_REASON.CR_FRIEND_SEND_FLOWER)

	info.value = info.value + itemcfg.effect[1]*num
	self:dbUpdateData(_table.TAB_mem_chr_relation,info)
	self:sendRelationInfo(info)
	self:updateVitTaskProgress(VITALITY_TASK_TYPE.VITALITY_FRIEND_GIFT, num)

	-- 别人处理
	local iplayer = _player_mgr:getPlayerByCid(cid)
	if iplayer then
		iplayer:getFriendFlower(self.cid,itemcfg.id,num,true)
	else
		_player_mgr:addOfflineEvent(cid,OFFLINE_EVENT.ON_GET_FLOWER,itemid,self.cid,num)
	end

end

function relation_module:getFriendFlower(cid,id,num,issend)
	local itemcfg = _cfg.item(id)
	if itemcfg == nil or itemcfg.type ~= ITEM_SUB_TYPE.FLOWER then
		return
	end

	local info = self._relation[cid]
	if info == nil or info.type ~= RELATION_TYPE.RT_FRIEND then
		return
	end

	info.value = info.value + itemcfg.effect[1]*num
	self:dbUpdateData(_table.TAB_mem_chr_relation,info)
	self:addRecord(RECORD_TYPE.RT_FRIEND_CHARM,itemcfg.effect[2])
	if issend then
		self:sendRelationInfo(info)
	end
end

return relation_module