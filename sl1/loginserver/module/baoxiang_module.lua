local _ST = STORAGE_TYPE
local _IT = ITEM_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _cm = CM
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _net_mgr = nil
local _strutil = STRING_UTIL
local _time = TIME_DATA
local _ct = CURRENCY_TYPE
local _cr = CHANGE_REASON
local _bx_state = BAOXIANG_STATE

local baoxiang_module = {}
local BAOXIANG_ADD_MAP = 1
local BAOXIANG_ADD_BAG = 2

function baoxiang_module:init()
    _net_mgr = MOD.net_mgr_module
    _msg_func.bind_player_proto_func(_cm.CM_OPEN_BAOXIANG, self.onOpenBaoxiang, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_BAOXIANG_INFO, self.onBaoxiangInfo, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_SET_BAOXIANG_OPEN, self.onSetBaoxiangOpen, "ProtoInt32")
    _msg_func.bind_player_proto_func(_cm.CM_CHANGE_BAOXIANG_STATE, self.onChangeBaoxiangState, "CmChangeBaoxiangState")
end

function baoxiang_module:initDB(data)
	self._baoxiang = {}
	for i, v in ipairs(data.baoxiang) do
		self._baoxiang[v.bid] = v
	end

	self._baoxiang_group = {}
	for i, v in ipairs(data.baoxiang_group) do
		self._baoxiang_group[v.group] = v
	end

    self._baoxiang_explore = {}
end

function baoxiang_module:afterInit()
    local chr_info = self._chr_info
    local baoxiangs = self._baoxiang
    local baoxianggroup = self._baoxiang_group
    local baoxiangexplore = self._baoxiang_explore

    local baoxiangfirst = {} --从来没被打开过的宝箱之外宝箱的数量
    local baoxiangleft = {}  --打开过的中当前不是已打开状态的

    local expbaoxiangfirst = {} --从来没被打开过的宝箱之外宝箱的数量
    local expbaoxiangleft = {}  --打开过的中当前不是已打开状态的

    self._baoxiang_opened = {}
    local baoxiangrefreshcfg = _cfg.table("baoxiang_refresh")

    for i, v in pairs(baoxiangs) do
        local curgroupopened = table.getOrNewTable(self._baoxiang_opened, v.groupid)
        if v.opennum > 0 then
            if baoxiangfirst[v.groupid] ~= nil then
                baoxiangfirst[v.groupid] = baoxiangfirst[v.groupid] + 1
            else
                baoxiangfirst[v.groupid] = 1
            end

            local bcfg = _cfg.baoxiang(v.bid)
            if bcfg ~= nil then
                if expbaoxiangfirst[bcfg.explore_id] ~= nil then
                    expbaoxiangfirst[bcfg.explore_id] = expbaoxiangfirst[bcfg.explore_id] + 1
                else
                    expbaoxiangfirst[bcfg.explore_id] = 1
                end
            end

            if v.state ~= _bx_state.OPENED then
                if baoxiangleft[v.groupid] ~= nil then
                    baoxiangleft[v.groupid] = baoxiangleft[v.groupid] + 1
                else
                    baoxiangleft[v.groupid] = 1
                end
                if bcfg ~= nil then
                    if expbaoxiangleft[bcfg.explore_id] ~= nil then
                        expbaoxiangleft[bcfg.explore_id] = expbaoxiangleft[bcfg.explore_id] + 1
                    else
                        expbaoxiangleft[bcfg.explore_id] = 1
                    end
                end
            else
                curgroupopened[#curgroupopened+1] = v.bid
            end
        end
    end

    for i,v in pairs(baoxiangrefreshcfg) do
        local firstnum = baoxiangfirst[v.groupid]
        local leftnum = baoxiangleft[v.groupid]

        if firstnum == nil then
            firstnum = 0
        end
        if leftnum == nil then
            leftnum = 0
        end

        if baoxianggroup[v.groupid] == nil then
            local groupdata = {cid = chr_info.cid, group = v.groupid, first_num = firstnum, left_num = leftnum, next_refresh_time = 0}
            baoxianggroup[v.groupid] = groupdata
        else
            baoxianggroup[v.groupid].first_num = firstnum
            baoxianggroup[v.groupid].left_num = leftnum
        end
    end

    local mapexplorecfg = _cfg.table("map_explore")
    for i,v in pairs(mapexplorecfg) do
        local firstnum = expbaoxiangfirst[v.groupid]
        local leftnum = expbaoxiangleft[v.groupid]

        if firstnum == nil then
            firstnum = 0
        end
        if leftnum == nil then
            leftnum = 0
        end

        if baoxiangexplore[v.groupid] == nil then
            local groupdata = {first_num = firstnum, left_num = leftnum}
            baoxiangexplore[v.groupid] = groupdata
        else
            baoxiangexplore[v.groupid].first_num = firstnum
            baoxiangexplore[v.groupid].left_num = leftnum
        end
    end

    self:sendBaoxiangGroup()
end


function baoxiang_module:update(second)
    local baoxiangrefreshcfg = _cfg.table("baoxiang_refresh")

    local baoxianggroup = self._baoxiang_group
    for i, v in pairs(baoxiangrefreshcfg) do
        if baoxianggroup[v.groupid] then
            while (baoxianggroup[v.groupid].next_refresh_time < second)
            do
                local firstnum = baoxianggroup[v.groupid].first_num
                local leftnum = baoxianggroup[v.groupid].left_num
                local totalnum = _cfg.baoxiang_group_num(v.groupid)
                if totalnum == nil then
                    totalnum = 0
                end
                if totalnum - firstnum + leftnum < v.refresh_limit then
                    local baoxiangopened = self._baoxiang_opened[v.groupid] --从这些中随机一个
                    if baoxiangopened ~= nil and #baoxiangopened > 0 then
                        local idx = math.random(#baoxiangopened)
                        local baoxiangid = baoxiangopened[idx]
                        table.remove(baoxiangopened, idx)

                        local baoxiangcfg = _cfg.baoxiang(baoxiangid)
                        if baoxiangcfg then
                            self._baoxiang[baoxiangid].state = _bx_state.LOCK
                            self._baoxiang[baoxiangid].map = baoxiangcfg.mapid
                            self._baoxiang[baoxiangid].x = baoxiangcfg.x
                            self._baoxiang[baoxiangid].y = baoxiangcfg.y
                            self._baoxiang[baoxiangid].z = baoxiangcfg.z

                            self:updateBaoxiangDB(self._baoxiang[baoxiangid])
                            --客户端发数据
                            self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
                        end

                        baoxianggroup[v.groupid].left_num = baoxianggroup[v.groupid].left_num + 1
                        baoxianggroup[v.groupid].next_refresh_time = second + v.refresh_time
                        self:updateBaoxiangGroupDB(baoxianggroup[v.groupid])

                        local baoxiangexplore = self._baoxiang_explore[baoxiangcfg.explore_id]
                        if baoxiangexplore == nil then
                            self._baoxiang_explore[baoxiangcfg.explore_id] = {
                                first_num = 0,
                                left_num = 0,
                            }
                            baoxiangexplore = self._baoxiang_explore[baoxiangcfg.explore_id]
                        end
                        baoxiangexplore.left_num = baoxiangexplore.left_num + 1
                    else
                        break
                    end
                else
                    break
                end
            end
        end
    end

end

function baoxiang_module:sendBaoxiangInfo(baoxianglist, sendtype)
    local baoxiang = {}
    for i, v in ipairs(baoxianglist) do
        local baoxiangdata = {
            bid = v.bid,
            type = v.type,
            map = v.map,
            x = v.x,
            y = v.y,
            z = v.z,
            state = v.state,
            time = v.time,
        }
        baoxiang[#baoxiang + 1] = baoxiangdata
    end

	self:sendMsg(_sm.SM_BAOXIANG_INFO, {baoxiang = baoxiang, type = sendtype}, "SmBaoxiangInfo")
end

function baoxiang_module:onOpenBaoxiang(data)
    local baoxiangid = data.i32
    local baoxiangdata = self._baoxiang[baoxiangid]
    if baoxiangdata == nil then
        return
    end

    if baoxiangdata.state ~= _bx_state.CAN_OPEN then
        return
    end
    local baoxiangcfg = _cfg.baoxiang(baoxiangid)
    if baoxiangcfg == nil then
        return
    end

    local baoxianggroup = self._baoxiang_group[baoxiangcfg.groupid]
    if baoxianggroup == nil then
        return
    end

    local baoxiangexplore = self._baoxiang_explore[baoxiangcfg.explore_id]
    if baoxiangexplore == nil then
        baoxiangexplore = {
            first_num = 0,
            left_num = 0,
        }
        self._baoxiang_explore[baoxiangcfg.explore_id] = baoxiangexplore
    end

    --to do 判断位置

    --to do 生成掉落
    if baoxiangdata.opennum == 0 then
        if baoxiangcfg.add_type == BAOXIANG_ADD_MAP then
            self:drop_reward_to_map(baoxiangcfg.first_reward_items, { baoxiangcfg.x, baoxiangcfg.y, baoxiangcfg.z}) 
        elseif baoxiangcfg.add_type == BAOXIANG_ADD_BAG then
            if not self:addBagCheck(baoxiangcfg.first_reward_items) then
                self:drop_reward_to_map(baoxiangcfg.first_reward_items, {baoxiangcfg.x, baoxiangcfg.y, baoxiangcfg.z})
            else
                self:addBag(baoxiangcfg.first_reward_items,_cr.CR_OPEN_BAOXIANG)
            end
        end
        baoxianggroup.first_num = baoxianggroup.first_num + 1
        baoxiangexplore.first_num = baoxiangexplore.first_num + 1
    else
        local dropItems = self:createDropItemsByIds(baoxiangcfg.reward_items)
        if baoxiangcfg.add_type == BAOXIANG_ADD_MAP then
            self:drop_reward_to_map(dropItems, {baoxiangcfg.x, baoxiangcfg.y, baoxiangcfg.z})
        elseif baoxiangcfg.add_type == BAOXIANG_ADD_BAG then
            if not self:addBagCheck(dropItems) then
                self:drop_reward_to_map(dropItems, {baoxiangcfg.x, baoxiangcfg.y, baoxiangcfg.z})
            else
                self:addBag(dropItems,_cr.CR_OPEN_BAOXIANG)
            end
        end
        baoxianggroup.left_num = baoxianggroup.left_num - 1
        baoxiangexplore.left_num = baoxiangexplore.left_num - 1
    end

    if baoxiangcfg.add_type == BAOXIANG_ADD_MAP then
        self:taskProgressCollect(baoxiangid, 1)
    else
        self:taskProgressDig(baoxiangid, 1)
    end

    self:updateBaoxiangGroupDB(baoxianggroup)

    local baoxiangopened = table.getOrNewTable(self._baoxiang_opened, baoxiangcfg.groupid)
    baoxiangopened[#baoxiangopened + 1] = baoxiangid

    baoxiangdata.state = _bx_state.OPENED
    baoxiangdata.opennum = baoxiangdata.opennum + 1
    baoxiangdata.time = _time.TIME_STAMEP

    self:dbUpdateData(_table.TAB_mem_chr_baoxiang, baoxiangdata)
    self:sendBaoxiangInfo({baoxiangdata}, 2)
    self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_BAOXIANG, 0, 1)
    self:sendBaoxiangGroup()
end

function baoxiang_module:onBaoxiangInfo(data)
    local baoxiang = {}
    for i, v in pairs(self._baoxiang) do
        local baoxiangdata = {
            bid = v.bid,
            type = v.type,
            map = v.map,
            x = v.x,
            y = v.y,
            z = v.z,
            state = v.state,
            time = v.time,
        }
        baoxiang[#baoxiang + 1] = baoxiangdata
    end

	self:sendMsg(_sm.SM_BAOXIANG_INFO, {baoxiang = baoxiang, type = 1}, "SmBaoxiangInfo")
end

function baoxiang_module:onChangeBaoxiangState(data)
    local baoxiangid = data.baoxiang_id
    local chr_info = self._chr_info
    local baoxiangcfg = _cfg.baoxiang(baoxiangid)
    if baoxiangcfg == nil then
        return
    end
    --0表示宝箱 1表示机关机关才可以修改状态
    if baoxiangcfg.type == 0 then
        return
    end

    local baoxiangdata = self._baoxiang[baoxiangid]
    if baoxiangdata == nil then
        baoxiangdata = {}
        baoxiangdata.state = _bx_state.LOCK
        baoxiangdata.map = baoxiangcfg.mapid
        baoxiangdata.x = baoxiangcfg.x
        baoxiangdata.y = baoxiangcfg.y
        baoxiangdata.z = baoxiangcfg.z
        baoxiangdata.groupid = baoxiangcfg.groupid
        baoxiangdata.cid = chr_info.cid
        baoxiangdata.bid = baoxiangcfg.id
        baoxiangdata.time = 0
        baoxiangdata.type = 1
        baoxiangdata.opennum = 0
        self._baoxiang[baoxiangid] = baoxiangdata
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    end

    if data.state ~= baoxiangdata.state then
        return
    end

    if #baoxiangcfg.request ~= 0 and baoxiangcfg.request[1] == 2 then
        if baoxiangdata.state == _bx_state.LOCK and data.password ~= baoxiangcfg.request[2] then
            return
        end
    end

    if baoxiangdata.state == _bx_state.LOCK then
        baoxiangdata.state = _bx_state.CAN_OPEN
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    elseif baoxiangdata.state == _bx_state.CAN_OPEN then
        baoxiangdata.state = _bx_state.LOCK
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    end

    if baoxiangcfg.relate ~= 0 then
        self:setBaoxiangState(baoxiangcfg.relate, baoxiangdata.state) 
    end
end

function baoxiang_module:setBaoxiangState(baoxiangid, baoxiangstate)
    local baoxiangcfg = _cfg.baoxiang(baoxiangid)
    if baoxiangcfg == nil then
        return
    end
    local baoxiangdata = self._baoxiang[baoxiangid]
    if baoxiangdata == nil then
        baoxiangdata = {}
        baoxiangdata.state = baoxiangstate
        baoxiangdata.map = baoxiangcfg.mapid
        baoxiangdata.x = baoxiangcfg.x
        baoxiangdata.y = baoxiangcfg.y
        baoxiangdata.z = baoxiangcfg.z
        baoxiangdata.groupid = baoxiangcfg.groupid
        baoxiangdata.cid = chr_info.cid
        baoxiangdata.bid = baoxiangcfg.id
        baoxiangdata.time = 0
        baoxiangdata.type = 1
        baoxiangdata.opennum = 0
        self._baoxiang[baoxiangid] = baoxiangdata
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    else
        baoxiangdata.state = baoxiangstate
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    end
    if baoxiangcfg.relate ~= 0 then
        self:setBaoxiangState(baoxiangcfg.relate, baoxiangdata.state) 
    end
end

function baoxiang_module:onSetBaoxiangOpen(data)
    local baoxiangid = data.i32
    local chr_info = self._chr_info
    local baoxiangcfg = _cfg.baoxiang(baoxiangid)
    if baoxiangcfg == nil then
        return
    end

    local baoxiangdata = self._baoxiang[baoxiangid]
    if baoxiangdata == nil then
        if #baoxiangcfg.request ~= 0 and baoxiangcfg.request[1] ~= 1 then
            --to do 判断位置
            baoxiangdata = {}
            baoxiangdata.state = _bx_state.CAN_OPEN
            baoxiangdata.map = baoxiangcfg.mapid
            baoxiangdata.x = baoxiangcfg.x
            baoxiangdata.y = baoxiangcfg.y
            baoxiangdata.z = baoxiangcfg.z
            baoxiangdata.groupid = baoxiangcfg.groupid
            baoxiangdata.cid = chr_info.cid
            baoxiangdata.bid = baoxiangcfg.id
            baoxiangdata.time = 0
            baoxiangdata.type = 1
            baoxiangdata.opennum = 0
            self._baoxiang[baoxiangid] = baoxiangdata
            self:updateBaoxiangDB(self._baoxiang[baoxiangid])
            self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
        else
            return
        end
    elseif baoxiangdata.state == _bx_state.LOCK then
        --to do 判断位置
        baoxiangdata.state = _bx_state.CAN_OPEN
        self:updateBaoxiangDB(self._baoxiang[baoxiangid])
        self:sendBaoxiangInfo({self._baoxiang[baoxiangid]}, 2)
    else
        return
    end
end

function baoxiang_module:updateBaoxiangDB(baoxiang)
    self:dbUpdateData(_table.TAB_mem_chr_baoxiang, baoxiang)
end

function baoxiang_module:updateBaoxiangGroupDB(baoxianggroup)
    self:dbUpdateData(_table.TAB_mem_chr_baoxiang_group, baoxianggroup)
end

function baoxiang_module:sendBaoxiangGroup()
    local baoxiangexplore = self._baoxiang_explore
    local grouplist = {}
    for i, v in ipairs(baoxiangexplore) do
        grouplist[#grouplist+1] = {
            group_id = v.group,
            opened_num = v.first_num
        }
    end
    self:sendMsg(_sm.SM_BAOXIANG_GROUP_INFO, {list = grouplist}, "SmBaoxiangGroupInfo")
end


return baoxiang_module